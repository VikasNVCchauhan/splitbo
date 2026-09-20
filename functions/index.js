const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');

const geminiKey = defineSecret('GEMINI_API_KEY');

const PROMPT = `You are a receipt/bill parser. Analyze the image and return ONLY a JSON object (no markdown, no explanation):
{
  "amount": <final total as a number, e.g. 1250.50>,
  "description": "<vendor/merchant name, concise, max 40 chars>",
  "category": "<exactly one of: food, transport, accommodation, entertainment, utilities, shopping, medical, education, other>",
  "notes": "<one short phrase>"
}
If you cannot read something, use null. Return ONLY the JSON.`;

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
    return data;
  }
);
