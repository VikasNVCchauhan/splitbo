const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');

const geminiKey = defineSecret('GEMINI_API_KEY');

const PROMPT = `You are an expert receipt and bill parser. Analyze the image and return ONLY a JSON object (no markdown, no explanation, no code fences):
{
  "amount": <final total as a number, e.g. 1250.50>,
  "description": "<vendor/merchant name, concise, max 40 chars>",
  "category": "<exactly one of: food, transport, accommodation, entertainment, utilities, shopping, medical, education, other>",
  "notes": "<one short descriptive phrase about what was purchased>",
  "groupName": "<name of a group, event, or trip visible on the receipt, or null if none>",
  "people": ["<name1>", "<name2>"]
}

For "people": extract any customer names, attendee names, or passenger names from the receipt. These are people who were part of this expense. Return an empty array [] if no names found.
For "groupName": look for event names, table names, trip references, booking references that suggest a group context. Return null if none.
For "category": choose the best fit — food for restaurants/groceries, transport for taxis/fuel/flights, accommodation for hotels, entertainment for movies/events, utilities for bills, shopping for retail, medical for pharmacy/hospital, education for courses/books.
If you cannot read a field, use null. Return ONLY the JSON, nothing else.`;

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
          { text: PROMPT },
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

    // Strip markdown fences if Gemini wraps in ```json ... ```
    const cleaned = text.replace(/^```[a-z]*\n?/i, '').replace(/\n?```$/i, '').trim();

    let parsed;
    try {
      parsed = JSON.parse(cleaned);
    } catch {
      throw new HttpsError('internal', 'Could not parse Gemini response as JSON.');
    }

    return {
      amount: parsed.amount ?? null,
      description: parsed.description ?? null,
      category: parsed.category ?? null,
      notes: parsed.notes ?? null,
      groupName: parsed.groupName ?? null,
      people: Array.isArray(parsed.people) ? parsed.people : [],
    };
  }
);
