import { Router } from 'express';
const router = Router();

router.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'CampusAI API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    geminiReady: !!process.env.GEMINI_API_KEY,
  });
});

export { router as healthRouter };
