import jwt from 'jsonwebtoken';

/**
 * Strict auth middleware — blocks request if no valid token.
 * Use on routes that require a logged-in user.
 */
export function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Authentication required' });
  }
  try {
    req.user = jwt.verify(header.slice(7), process.env.JWT_SECRET);
    next();
  } catch (_) {
    res.status(401).json({ success: false, error: 'Invalid or expired token' });
  }
}
