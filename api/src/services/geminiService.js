import { getGenAI } from '../config/gemini.js';
import { systemPrompt } from '../knowledge/campusData.js';

// In-memory session store: sessionId → ChatSession
// Hackathon: fine as-is. Production: replace with Redis.
const sessions = new Map();

function createModel() {
  return getGenAI().getGenerativeModel({
    model: 'gemini-2.5-flash-lite',
    systemInstruction: systemPrompt,
    generationConfig: {
      temperature: 0.3,      // low = factual, not creative
      maxOutputTokens: 600,  // concise replies for mobile
    },
  });
}

/**
 * Get existing chat session or create a new one.
 * sessionId format: "user_<uuid>" or "guest_<uuid>"
 */
export function getOrCreateSession(sessionId) {
  if (!sessions.has(sessionId)) {
    const model = createModel();
    sessions.set(sessionId, model.startChat({ history: [] }));
  }
  return sessions.get(sessionId);
}

/**
 * Send a message and get the AI reply.
 */
/**
 * Send a message and get the AI reply.
 * Surfaces specific error codes so the route can return the right HTTP status.
 */
export async function sendMessage(sessionId, message) {
  const chat = getOrCreateSession(sessionId);
  try {
    const result = await chat.sendMessage(message);
    const text = result.response.text();
    if (!text) throw new Error('Empty response from AI');
    return text;
  } catch (err) {
    console.error('[Gemini error]', err.message);

    const msg = err.message || '';

    if (msg.includes('API_KEY') || msg.includes('API key')) {
      const e = new Error('AI service configuration error. Please contact support.');
      e.status = 500;
      throw e;
    }
    if (msg.includes('429') || msg.includes('Too Many Requests') || msg.includes('quota')) {
      const e = new Error('The AI service is currently rate limited. Please try again in a minute.');
      e.status = 429;
      throw e;
    }
    if (msg.includes('503') || msg.includes('Service Unavailable') || msg.includes('high demand')) {
      const e = new Error('The AI service is temporarily unavailable due to high demand. Please try again in a few seconds.');
      e.status = 503;
      throw e;
    }

    const e = new Error('AI service is temporarily unavailable. Please try again in a moment.');
    e.status = 502;
    throw e;
  }
}

/**
 * Clear a session (user clears chat history).
 */
export function clearSession(sessionId) {
  sessions.delete(sessionId);
}

/**
 * Get session history for an authenticated user.
 */
export function getSessionHistory(sessionId) {
  const chat = sessions.get(sessionId);
  if (!chat) return [];
  return chat._history || [];
}

/**
 * Active session count — useful for monitoring.
 */
export function getActiveSessionCount() {
  return sessions.size;
}
