import { Router } from 'express';
import {
  register,
  login,
  signTokens,
  verifyRefreshToken,
  getUserById,
  updateUserName,
} from '../services/authService.js';
import { requireAuth } from '../middleware/auth.js';

const router = Router();

// ── POST /api/auth/register ───────────────────────────────────────────────────
router.post('/register', async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        error: 'name, email and password are required',
      });
    }
    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        error: 'password must be at least 8 characters',
      });
    }
    await register({ name, email, password });
    const tokens = await login({ email, password });
    res.status(201).json({ success: true, data: tokens });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/login ──────────────────────────────────────────────────────
router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'email and password are required',
      });
    }
    const tokens = await login({ email, password });
    res.json({ success: true, data: tokens });
  } catch (err) {
    next(err);
  }
});

// ── POST /api/auth/refresh ────────────────────────────────────────────────────
router.post('/refresh', (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ success: false, error: 'refreshToken is required' });
    }
    const payload = verifyRefreshToken(refreshToken);
    const user = getUserById(payload.id);
    if (!user) {
      return res.status(401).json({ success: false, error: 'User not found' });
    }
    const tokens = signTokens(user);
    res.json({ success: true, data: tokens });
  } catch (_) {
    res.status(401).json({ success: false, error: 'Invalid or expired refresh token' });
  }
});

// ── GET /api/auth/me ──────────────────────────────────────────────────────────
router.get('/me', requireAuth, (req, res) => {
  res.json({ success: true, data: { user: req.user } });
});

// ── PATCH /api/auth/me ────────────────────────────────────────────────────────
router.patch('/me', requireAuth, (req, res, next) => {
  try {
    const { name } = req.body;
    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({ success: false, error: 'name is required' });
    }
    const updated = updateUserName(req.user.id, name.trim());
    res.json({ success: true, data: { user: updated } });
  } catch (err) {
    next(err);
  }
});

export { router as authRouter };
