import jwt from 'jsonwebtoken';

/**
 * Attaches req.user if a valid Bearer token is present.
 * Never blocks the request — treats invalid/missing token as guest.
 */
export function optionalAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return next();
  try {
    req.user = jwt.verify(header.slice(7), process.env.JWT_SECRET);
  } catch (_) {
  }
  next();
}
