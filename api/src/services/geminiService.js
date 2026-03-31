import { getGenAI } from '../config/gemini.js';
import { systemPrompt } from '../knowledge/campusData.js';

// In-memory session store: sessionId → ChatSession
// Hackathon: fine as-is. Production: replace with Redis.
const sessions = new Map();

function createModel() {
  return getGenAI().getGenerativeModel({
    model: 'gemini-1.5-pro',
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
export async function sendMessage(sessionId, message) {
  const chat = getOrCreateSession(sessionId);
  try {
    const result = await chat.sendMessage(message);
    const text = result.response.text();
    if (!text) throw new Error('Empty response from AI');
    return text;
  } catch (err) {
    console.error('[Gemini error]', err.message);
    if (err.message.includes('API_KEY')) {
      throw new Error('AI service configuration error. Please contact support.');
    }
    throw new Error('AI service is temporarily unavailable. Please try again in a moment.');
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
