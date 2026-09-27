'use strict';

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

const geminiKey = defineSecret('GEMINI_API_KEY');

// ─────────────────────────────────────────────────────────────────────────────
// BALANCE RECOMPUTATION
//
// Full recompute from all expenses in the group — correct under concurrent
// writes because both conflicting executions read the complete expense set
// and converge on the same result. Idempotent by design.
//
// matrix[userId][otherUserId]: positive = otherUser owes userId
//                              negative = userId owes otherUser
// ─────────────────────────────────────────────────────────────────────────────

async function recomputeGroupBalances(groupId, prefix) {
  const snap = await db.collection(`${prefix}expenses`)
    .where('groupId', '==', groupId)
    .get();

  const matrix = {};

  for (const doc of snap.docs) {
    const e = doc.data();
    if (e.deletedAt) continue;
    const { paidBy, splits = [] } = e;
    if (!paidBy) continue;

    for (const split of splits) {
      const { userId: debtor, amount } = split;
      if (!debtor || debtor === paidBy || !amount || amount <= 0) continue;

      matrix[paidBy] = matrix[paidBy] || {};
      matrix[debtor] = matrix[debtor] || {};
      matrix[paidBy][debtor] = (matrix[paidBy][debtor] || 0) + amount;
      matrix[debtor][paidBy] = (matrix[debtor][paidBy] || 0) - amount;
    }
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  const batch = db.batch();

  for (const [userId, details] of Object.entries(matrix)) {
    const netAmount = Object.values(details).reduce((s, v) => s + v, 0);
    const ref = db.collection(`${prefix}balances`).doc(`${userId}_${groupId}`);
    batch.set(ref, { userId, groupId, netAmount, details, currency: 'INR', updatedAt: now });
  }

  if (Object.keys(matrix).length) await batch.commit();
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY FEED
// ─────────────────────────────────────────────────────────────────────────────

async function createActivityEntry(prefix, entry) {
  await db.collection(`${prefix}activity`).add({
    ...entry,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FCM PUSH NOTIFICATIONS
// ─────────────────────────────────────────────────────────────────────────────

async function pushToUsers(userIds, prefix, { title, body, data = {} }) {
  if (!userIds.length) return;

  const refs = userIds.map(uid => db.doc(`${prefix}users/${uid}`));
  const snaps = await db.getAll(...refs);

  const tokens = snaps.map(s => s.data()?.fcmToken).filter(Boolean);
  if (!tokens.length) return;

  try {
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
    });
  } catch (err) {
    console.error('FCM multicast error:', err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPENSE TRIGGERS  (prod: expenses / dev: dev_expenses)
// ─────────────────────────────────────────────────────────────────────────────

function makeExpenseTrigger(prefix, collection) {
  return onDocumentWritten(`${collection}/{expenseId}`, async (event) => {
    const before = event.data.before.exists ? event.data.before.data() : null;
    const after  = event.data.after.exists  ? event.data.after.data()  : null;

    const groupId = (after || before)?.groupId;
    if (!groupId) return;

    await recomputeGroupBalances(groupId, prefix);

    const expense   = after || before;
    const actorId   = after?.createdBy || before?.createdBy || expense?.paidBy;
    const actorName = expense?.memberDisplayNames?.[actorId] || 'Someone';
    const type      = !before ? 'expense_added' : !after ? 'expense_deleted' : 'expense_updated';

    const memberIds = [...new Set([
      expense?.paidBy,
      ...(expense?.splits || []).map(s => s.userId),
    ].filter(Boolean))];

    await createActivityEntry(prefix, {
      type,
      actorId,
      actorName,
      affectedUserIds: memberIds,
      groupId,
      groupName: expense?.groupName || null,
      relatedId: event.params.expenseId,
      snapshot: {
        description: expense?.description || '',
        amount: expense?.amount || 0,
        currency: expense?.currency || 'INR',
      },
    });

    if (type === 'expense_added') {
      const recipients = memberIds.filter(uid => uid !== actorId);
      await pushToUsers(recipients, prefix, {
        title: 'New expense added',
        body: `${actorName} added "${expense?.description}" — ₹${Number(expense?.amount || 0).toFixed(2)}`,
        data: { groupId, type: 'expense_added' },
      });
    }
  });
}

exports.onExpenseWrite    = makeExpenseTrigger('',     'expenses');
exports.onDevExpenseWrite = makeExpenseTrigger('dev_', 'dev_expenses');

// ─────────────────────────────────────────────────────────────────────────────
// SETTLEMENT TRIGGERS  (prod: settlements / dev: dev_settlements)
// ─────────────────────────────────────────────────────────────────────────────

function makeSettlementTrigger(prefix, collection) {
  return onDocumentWritten(`${collection}/{settlementId}`, async (event) => {
    const after = event.data.after.exists ? event.data.after.data() : null;
    if (!after) return; // settlements are immutable — ignore deletes

    const { groupId, fromUserId, toUserId, amount, note } = after;
    if (!groupId) return;

    await recomputeGroupBalances(groupId, prefix);

    const [fromSnap, toSnap] = await Promise.all([
      db.doc(`${prefix}users/${fromUserId}`).get(),
      db.doc(`${prefix}users/${toUserId}`).get(),
    ]);
    const fromName = fromSnap.data()?.displayName || 'Someone';
    const toName   = toSnap.data()?.displayName   || 'Someone';

    await createActivityEntry(prefix, {
      type: 'settlement_recorded',
      actorId: fromUserId,
      actorName: fromName,
      affectedUserIds: [fromUserId, toUserId],
      groupId,
      groupName: null,
      relatedId: event.params.settlementId,
      snapshot: {
        description: `${fromName} paid ${toName}`,
        amount: amount || 0,
        currency: 'INR',
      },
    });

    await pushToUsers([toUserId], prefix, {
      title: 'You got paid!',
      body: `${fromName} paid you ₹${Number(amount || 0).toFixed(2)}${note ? ` — "${note}"` : ''}`,
      data: { groupId, type: 'settlement_recorded' },
    });
  });
}

exports.onSettlementWrite    = makeSettlementTrigger('',     'settlements');
exports.onDevSettlementWrite = makeSettlementTrigger('dev_', 'dev_settlements');

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULED: expire stale invites (every Monday 02:00 UTC)
// ─────────────────────────────────────────────────────────────────────────────

exports.cleanupExpiredInvites = onSchedule('every monday 02:00', async () => {
  const now = admin.firestore.Timestamp.now();
  for (const prefix of ['', 'dev_']) {
    const snap = await db.collection(`${prefix}invites`)
      .where('status', '==', 'pending')
      .where('expiresAt', '<', now)
      .get();

    if (!snap.empty) {
      const batch = db.batch();
      snap.docs.forEach(doc => batch.update(doc.ref, { status: 'expired' }));
      await batch.commit();
      console.log(`Expired ${snap.size} invites in ${prefix}invites`);
    }
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// parseReceipt — Gemini 1.5 Flash OCR (callable)
// ─────────────────────────────────────────────────────────────────────────────

const RECEIPT_PROMPT = `You are an expert receipt and bill parser. Analyze the image and return ONLY a JSON object (no markdown, no explanation, no code fences):
{
  "amount": <final total as a number, e.g. 1250.50>,
  "description": "<vendor/merchant name, concise, max 40 chars>",
  "category": "<exactly one of: food, transport, accommodation, entertainment, utilities, shopping, medical, education, other>",
  "notes": "<one short descriptive phrase about what was purchased>",
  "groupName": "<name of a group, event, or trip visible on the receipt, or null if none>",
  "people": ["<name1>", "<name2>"]
}

For "people": extract any customer names, attendee names, or passenger names from the receipt. Return [] if none.
For "groupName": look for event names, table names, trip or booking references. Return null if none.
For "category": food for restaurants/groceries, transport for taxis/fuel/flights, accommodation for hotels,
entertainment for movies/events, utilities for bills, shopping for retail, medical for pharmacy/hospital,
education for courses/books.
If you cannot read a field, use null. Return ONLY the JSON.`;

exports.parseReceipt = onCall(
  { secrets: [geminiKey], maxInstances: 10, timeoutSeconds: 30 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Must be signed in.');
    }

    const { imageBase64, mimeType } = request.data;
    if (!imageBase64 || !mimeType) {
      throw new HttpsError('invalid-argument', 'imageBase64 and mimeType required.');
    }
    if (imageBase64.length > 5_000_000) {
      throw new HttpsError('invalid-argument', 'Image too large (max ~3.5 MB).');
    }

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey.value()}`;
    const body = {
      contents: [{
        parts: [
          { text: RECEIPT_PROMPT },
          { inline_data: { mime_type: mimeType, data: imageBase64 } },
        ],
      }],
      generationConfig: { temperature: 0.1, maxOutputTokens: 512 },
    };

    const fetch = (await import('node-fetch')).default;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
      throw new HttpsError('internal', `Gemini error: ${res.status}`);
    }

    const data = await res.json();
    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
    const cleaned = text.replace(/^```[a-z]*\n?/i, '').replace(/\n?```$/i, '').trim();

    let parsed;
    try {
      parsed = JSON.parse(cleaned);
    } catch {
      throw new HttpsError('internal', 'Could not parse Gemini response as JSON.');
    }

    return {
      amount:      parsed.amount      ?? null,
      description: parsed.description ?? null,
      category:    parsed.category    ?? null,
      notes:       parsed.notes       ?? null,
      groupName:   parsed.groupName   ?? null,
      people:      Array.isArray(parsed.people) ? parsed.people : [],
    };
  },
);
