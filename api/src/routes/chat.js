import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { sendMessage, clearSession, getSessionHistory } from '../services/geminiService.js';
import { optionalAuth } from '../middleware/optionalAuth.js';
import { chatRateLimiter } from '../middleware/rateLimiter.js';

const router = Router();

/**
 * Resolve a stable session ID for this request.
 *
 * - Authenticated user  → "user_<userId>"
 * - Guest with header   → "guest_<their-id>"
 * - Guest without header → generate new UUID, echo back via X-Session-ID header
 *
 * Clients (Flutter/React) must persist the X-Session-ID they receive
 * and send it on every request to maintain conversation continuity.
 */
function resolveSessionId(req, res) {
  if (req.user) {
    return { sessionId: `user_${req.user.id}`, isGuest: false };
  }
  let sid = req.headers['x-session-id'];
  const isNew = !sid;
  if (isNew) {
    sid = uuidv4();
    res.setHeader('X-Session-ID', sid);
  }
  return {
    sessionId: `guest_${sid}`,
    isGuest: true,
    sessionIdForClient: isNew ? sid : undefined,
  };
}

// ── POST /api/chat ────────────────────────────────────────────────────────────
router.post('/', optionalAuth, chatRateLimiter, async (req, res, next) => {
  try {
    const { message } = req.body;

    if (typeof message !== 'string') {
      return res.status(400).json({ success: false, error: 'message is required' });
    }
    if (message.trim().length === 0) {
      return res.status(400).json({ success: false, error: 'message cannot be empty' });
    }
    if (message.length > 1000) {
      return res.status(400).json({
        success: false,
        error: 'message too long (max 1000 characters)',
      });
    }

    const { sessionId, isGuest, sessionIdForClient } = resolveSessionId(req, res);
    const reply = await sendMessage(sessionId, message.trim());

    res.json({
      success: true,
      data: {
        reply,
        isGuest,
        ...(sessionIdForClient && { sessionId: sessionIdForClient }),
      },
    });
  } catch (err) {
    next(err);
  }
});

// ── GET /api/chat/history (authenticated only) ────────────────────────────────
router.get('/history', optionalAuth, (req, res) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required to view chat history',
    });
  }
  const history = getSessionHistory(`user_${req.user.id}`);
  res.json({ success: true, data: { history } });
});

// ── DELETE /api/chat/history ──────────────────────────────────────────────────
router.delete('/history', optionalAuth, (req, res) => {
  const { sessionId } = resolveSessionId(req, res);
  clearSession(sessionId);
  res.json({ success: true, message: 'Chat history cleared' });
});

export { router as chatRouter };
