import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { healthRouter } from './routes/health.js';
import { chatRouter } from './routes/chat.js';
import { topicsRouter } from './routes/topics.js';
import { authRouter } from './routes/auth.js';
import { errorHandler } from './middleware/errorHandler.js';
import { rateLimiter } from './middleware/rateLimiter.js';

const app = express();
const PORT = process.env.PORT || 3000;

const allowedOrigins = (process.env.ALLOWED_ORIGINS || '').split(',').map(s => s.trim());

app.use(helmet());
app.use(cors({
  origin: (origin, cb) => {
    // Allow requests with no origin (mobile apps, curl, Postman)
    if (!origin || allowedOrigins.includes(origin)) return cb(null, true);
    cb(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));
app.use(express.json({ limit: '10kb' }));
app.use(rateLimiter);

// Routes
app.use('/health', healthRouter);
app.use('/api/chat', chatRouter);
app.use('/api', topicsRouter);    // serves /api/topics and /api/faqs
app.use('/api/auth', authRouter);

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`✅ CampusAI API running on port ${PORT}`);
  console.log(`   NODE_ENV: ${process.env.NODE_ENV}`);
  console.log(`   Gemini key set: ${!!process.env.GEMINI_API_KEY}`);
});

export default app;
