# CampusAI API — Phase Plan

> **Source of truth for all AI interactions.** Both the Flutter app and the React
> web app talk to this API. Gemini is called here — never from the clients directly.
>
> **Workflow:** Claude handles architecture and spec. Gemini CLI executes file writes
> and terminal commands. Each phase produces a LOG.md entry.
>
> **Runtime:** Node.js 18+
> **Project root:** `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api`
> **Log file:** `api/LOG.md`
> **Handoff file:** `api/CONTINUE.md`
> **Contracts:** `api/CONTRACTS.md` — shared request/response shapes for app + web

---

## Architecture Overview

```
Flutter App  ──┐
               ├──▶  CampusAI API (Express)  ──▶  Google Gemini 1.5 Pro
React Web    ──┘         │
                         └──▶  (optional) SQLite/PostgreSQL for user sessions
```

### Why API-first
- Gemini API key never ships inside the mobile app or browser bundle
- Knowledge base updates happen in one place — the API — not in app releases
- Auth, rate limiting, and logging live centrally
- Both clients share identical AI responses and data structures

### Auth Strategy
The API supports two modes simultaneously:
- **Guest mode** — no token required. Chat works, history is not persisted.
- **Authenticated mode** — Bearer JWT. Chat history persisted, user profile stored.

Clients detect which mode they are in by whether a token is present.
The app/web can be fully functional in guest mode — auth is additive, not required.

---

## Folder Structure (target)

```
api/
├── src/
│   ├── config/
│   │   ├── gemini.js          ← Gemini client init + system prompt loader
│   │   └── db.js              ← DB connection (optional, for auth)
│   ├── middleware/
│   │   ├── auth.js            ← JWT verify middleware (optional routes)
│   │   ├── optionalAuth.js    ← Attaches user if token present, continues if not
│   │   ├── rateLimiter.js     ← Per-IP and per-user rate limiting
│   │   └── errorHandler.js    ← Global error handler
│   ├── routes/
│   │   ├── chat.js            ← POST /api/chat
│   │   ├── topics.js          ← GET /api/topics, GET /api/faqs
│   │   ├── auth.js            ← POST /api/auth/register, /login, /refresh
│   │   └── health.js          ← GET /health
│   ├── services/
│   │   ├── geminiService.js   ← Gemini API calls, session management
│   │   └── authService.js     ← JWT sign/verify, password hash
│   ├── knowledge/
│   │   └── campusData.js      ← CU knowledge base (the big text block)
│   └── app.js                 ← Express app setup
├── .env
├── .env.example
├── package.json
├── PHASES.md                  ← This file
├── LOG.md
├── CONTINUE.md
└── CONTRACTS.md               ← API contract for app + web clients
```

---

## Route Map

### Public routes (no auth required)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/api/topics` | List of topic categories |
| GET | `/api/faqs` | Frequently asked questions list |
| POST | `/api/chat` | Send a message, get AI reply (guest mode) |
| POST | `/api/auth/register` | Create account (optional) |
| POST | `/api/auth/login` | Login, receive JWT |
| POST | `/api/auth/refresh` | Refresh access token |

### Authenticated routes (Bearer JWT required)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/chat/history` | Get user's chat history |
| DELETE | `/api/chat/history` | Clear user's chat history |
| GET | `/api/user/profile` | Get user profile |
| PATCH | `/api/user/profile` | Update display name |

> Note: `/api/chat` works in BOTH guest and authenticated mode.
> If a valid JWT is present, the message is saved to history.
> If no JWT, it still works — history just isn't persisted.

---

## Phase 0 — Project Bootstrap
**Time estimate:** 20 minutes
**Owner:** Gemini executes

### Goal
Init Node.js project, install dependencies, create folder structure, set up
`.env`, verify the server starts and `/health` responds.

### Pre-flight reads
- None (clean folder)

### Actions

**[GEMINI EXECUTES]** Step 0.1 — Init project
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api
npm init -y
```

**[GEMINI EXECUTES]** Step 0.2 — Install dependencies
```bash
npm install express @google/generative-ai dotenv cors helmet express-rate-limit \
  jsonwebtoken bcryptjs uuid
npm install --save-dev nodemon
```

**[GEMINI EXECUTES]** Step 0.3 — Create folder structure
```bash
mkdir -p src/config src/middleware src/routes src/services src/knowledge
```

**[GEMINI EXECUTES]** Step 0.4 — Create `.env` and `.env.example`
`.env`:
```
PORT=3000
GEMINI_API_KEY=your_gemini_api_key_here
JWT_SECRET=your_jwt_secret_here_minimum_32_chars
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3001
```
`.env.example` — same but with empty values.

**[GEMINI EXECUTES]** Step 0.5 — Update `package.json` scripts
```json
"scripts": {
  "start": "node src/app.js",
  "dev": "nodemon src/app.js",
  "check": "node --check src/app.js"
}
```

**[GEMINI EXECUTES]** Step 0.6 — Create `.gitignore`
```
node_modules/
.env
*.log
```

### Verification
```bash
node --check src/app.js   # after Phase 1 writes app.js
```

### LOG.md entry
```
## Phase 0 — Project Bootstrap
- Date: [DATE]
- Status: COMPLETE
- Files created: package.json, .env, .env.example, .gitignore, src/ structure
- Verification: npm install successful
```

---

## Phase 1 — App Shell + Health Route
**Time estimate:** 20 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Create `src/app.js` with Express setup (CORS, Helmet, JSON parsing, rate limiter,
error handler) and wire up the `/health` route. Server must start and respond.

### Pre-flight reads
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/package.json`

### Actions

**[CLAUDE HANDLES]** — Write `src/app.js`
```javascript
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

const allowedOrigins = (process.env.ALLOWED_ORIGINS || '').split(',');

app.use(helmet());
app.use(cors({
  origin: (origin, cb) => {
    if (!origin || allowedOrigins.includes(origin)) return cb(null, true);
    cb(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));
app.use(express.json({ limit: '10kb' }));
app.use(rateLimiter);

app.use('/health', healthRouter);
app.use('/api/chat', chatRouter);
app.use('/api/topics', topicsRouter);  // also serves /api/faqs
app.use('/api/auth', authRouter);

app.use(errorHandler);

app.listen(PORT, () => console.log(`CampusAI API running on port ${PORT}`));

export default app;
```

> Note: uses ES modules. Add `"type": "module"` to package.json.

**[CLAUDE HANDLES]** — Write `src/routes/health.js`
```javascript
import { Router } from 'express';
const router = Router();

router.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'CampusAI API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

export { router as healthRouter };
```

**[CLAUDE HANDLES]** — Write `src/middleware/errorHandler.js`
```javascript
export function errorHandler(err, req, res, next) {
  const status = err.status || 500;
  const message = err.message || 'Internal server error';
  if (process.env.NODE_ENV !== 'production') console.error(err);
  res.status(status).json({ success: false, error: message });
}
```

**[CLAUDE HANDLES]** — Write `src/middleware/rateLimiter.js`
```javascript
import rateLimit from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: 60 * 1000,      // 1 minute
  max: 60,                   // 60 requests per minute per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, error: 'Too many requests. Please slow down.' },
});

// Stricter limiter for chat endpoint (AI calls are expensive)
export const chatRateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, error: 'Chat rate limit exceeded. Please wait a moment.' },
});
```

**[GEMINI EXECUTES]** — Create stub files so app.js imports don't crash:
- `src/routes/chat.js` — export `chatRouter = Router()` stub
- `src/routes/topics.js` — export `topicsRouter = Router()` stub
- `src/routes/auth.js` — export `authRouter = Router()` stub

### Verification
```bash
cd /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api
npm run dev
# In another terminal:
curl http://localhost:3000/health
```
Expected: `{"status":"ok","service":"CampusAI API",...}`

### LOG.md entry
```
## Phase 1 — App Shell + Health Route
- Date: [DATE]
- Status: COMPLETE
- Files created: src/app.js, src/routes/health.js, src/middleware/errorHandler.js,
  src/middleware/rateLimiter.js, stub routes (chat, topics, auth)
- Verification: GET /health → 200 OK confirmed
```

---

## Phase 2 — Knowledge Base + Gemini Service
**Time estimate:** 30 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Port the CU knowledge base into `src/knowledge/campusData.js` and build
`src/services/geminiService.js` that manages Gemini sessions per user/guest.

### Pre-flight reads
- `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/PHASES.md`
  (Phase 2 section — knowledge base template to reuse)

### Actions

**[CLAUDE HANDLES]** — Write `src/config/gemini.js`
```javascript
import { GoogleGenerativeAI } from '@google/generative-ai';

let _genAI = null;

export function getGenAI() {
  if (!_genAI) {
    if (!process.env.GEMINI_API_KEY) throw new Error('GEMINI_API_KEY not set');
    _genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }
  return _genAI;
}
```

**[CLAUDE HANDLES]** — Write `src/knowledge/campusData.js`
```javascript
// Populated by content research teammate.
// Replace [PASTE ...] sections with real CU data before demo.
export const cuKnowledgeBase = `
## CENTRAL UNIVERSITY GHANA — CAMPUS KNOWLEDGE BASE
## Miotso Campus, Accra-Aflao Road, Near Dawhenya

### 1. ACADEMIC STRUCTURE
Schools: SET, SoP, Law, Medical Sciences, Nursing & Midwifery,
FASS, SADe, CBS, Graduate Studies, CODE (Distance Education)
[PASTE FULL PROGRAMME LIST AND YEAR STRUCTURE]

### 2. ACADEMIC CALENDAR
[PASTE SEMESTER DATES, EXAM PERIODS, REGISTRATION DEADLINES, HOLIDAYS]

### 3. FEES & FINANCE
[PASTE TUITION BY PROGRAMME AND LEVEL, PAYMENT DEADLINES]
Payment methods: MTN MoMo, Vodafone Cash, AirtelTigo Money, Bank transfer, Cash (Finance Office)
Finance Office: +2330303318580

### 4. REGISTRATION & ADMISSIONS
Student portal: https://student.central.edu.gh/login
Eligibility checker: https://eligibility.central.edu.gh
Online application: https://central.edu.gh/online
[PASTE REGISTRATION STEPS, DEADLINES, REQUIRED DOCUMENTS]

### 5. CAMPUS FACILITIES
Library: https://central.edu.gh/library — [PASTE HOURS AND LOCATION]
Counselling: https://central.edu.gh/couselling-career-service
Exam timetable: https://webcms.central.edu.gh/wp-content/uploads/2026/01/Exams-Timetable.pdf
[PASTE CANTEEN HOURS, COMPUTER LAB LOCATIONS, CHAPEL, SRC OFFICE LOCATION]

### 6. KEY CONTACTS
Main phone (Miotso): +2330303318580
Admissions: +2330307020540
WhatsApp: +2330233313180
Email: verification@central.edu.gh | pr@central.edu.gh
[PASTE DEPARTMENTAL OFFICERS, REGISTRAR, FINANCE CONTACTS]

### 7. EXAMINATIONS & GRADING
[PASTE GPA SCALE, GRADE BOUNDARIES, EXAM RULES, RESIT PROCESS]
Resit timetable: https://webcms.central.edu.gh/wp-content/uploads/2026/02/Resit-Timetable.pdf
Student handbook: https://webcms.central.edu.gh/wp-content/uploads/2026/02/undergraduate-students-handbook-FINAL-compressed.pdf

### 8. STUDENT LIFE
[PASTE CLUBS, SRC STRUCTURE, HOSTEL NAMES, APPLICATION PROCESS, TRANSPORT]

### 9. CURRENT ANNOUNCEMENTS
[PASTE ACTIVE NOTICES, DEADLINES, EVENTS THIS SEMESTER]
`;

export const systemPrompt = `
You are CampusAI, an intelligent assistant for Central University Ghana, Miotso Campus.
Help students, prospective students, and staff get accurate, helpful answers about
campus life, academics, fees, facilities, and administrative processes.

ONLY answer using the knowledge base below. If the answer is not there, say:
"I don't have that information. Please contact the relevant office or visit central.edu.gh."
Do NOT guess or make up any information.

Tone: Friendly, concise, like a knowledgeable senior student.
If user writes in Twi or Pidgin, respond in kind.
For fees: append "Please confirm with the Finance Office as fees may change."
For deadlines: append "Please verify with the Registrar's Office."

--- KNOWLEDGE BASE ---
${cuKnowledgeBase}
--- END KNOWLEDGE BASE ---
`;
```

**[CLAUDE HANDLES]** — Write `src/services/geminiService.js`
```javascript
import { getGenAI } from '../config/gemini.js';
import { systemPrompt } from '../knowledge/campusData.js';

// In-memory session store: sessionId → ChatSession
// For a hackathon this is fine. Replace with Redis for production.
const sessions = new Map();

function getModel() {
  return getGenAI().getGenerativeModel({
    model: 'gemini-1.5-pro',
    systemInstruction: systemPrompt,
    generationConfig: {
      temperature: 0.3,
      maxOutputTokens: 512,
    },
  });
}

export function getOrCreateSession(sessionId) {
  if (!sessions.has(sessionId)) {
    const model = getModel();
    sessions.set(sessionId, model.startChat({ history: [] }));
  }
  return sessions.get(sessionId);
}

export async function sendMessage(sessionId, message) {
  const chat = getOrCreateSession(sessionId);
  try {
    const result = await chat.sendMessage(message);
    return result.response.text();
  } catch (err) {
    console.error('Gemini error:', err.message);
    throw new Error('AI service unavailable. Please try again.');
  }
}

export function clearSession(sessionId) {
  sessions.delete(sessionId);
}

export function getSessionHistory(sessionId) {
  const chat = sessions.get(sessionId);
  if (!chat) return [];
  // google-generative-ai exposes _history internally
  return chat._history || [];
}
```

### Verification
```bash
node --check src/services/geminiService.js
node --check src/knowledge/campusData.js
```
Expected: no syntax errors.

### LOG.md entry
```
## Phase 2 — Knowledge Base + Gemini Service
- Date: [DATE]
- Status: COMPLETE
- Files created: src/config/gemini.js, src/knowledge/campusData.js,
  src/services/geminiService.js
- Note: campusData.js has placeholder sections — fill before demo
- Verification: node --check passed on both files
```

---

## Phase 3 — Chat Route
**Time estimate:** 25 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Implement `POST /api/chat`. Works in guest mode (session cookie/ID) and
authenticated mode (JWT). In both cases returns a Gemini reply.
When authenticated, history is available via GET /api/chat/history.

### Pre-flight reads
- `src/routes/chat.js` (current stub)
- `src/services/geminiService.js`
- `src/middleware/rateLimiter.js`

### Actions

**[CLAUDE HANDLES]** — Write `src/middleware/optionalAuth.js`
```javascript
import jwt from 'jsonwebtoken';

// Attaches req.user if valid token present. Never blocks the request.
export function optionalAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return next();
  try {
    req.user = jwt.verify(header.slice(7), process.env.JWT_SECRET);
  } catch (_) { /* invalid token — treat as guest */ }
  next();
}
```

**[CLAUDE HANDLES]** — Write `src/routes/chat.js`
```javascript
import { Router } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { sendMessage, clearSession, getSessionHistory } from '../services/geminiService.js';
import { optionalAuth } from '../middleware/optionalAuth.js';
import { chatRateLimiter } from '../middleware/rateLimiter.js';

const router = Router();

// Resolve a stable session ID:
// - Authenticated users: use their userId
// - Guests: use X-Session-ID header, or generate one and send it back
function resolveSessionId(req, res) {
  if (req.user) return { sessionId: `user_${req.user.id}`, isGuest: false };
  let sid = req.headers['x-session-id'];
  if (!sid) {
    sid = uuidv4();
    res.setHeader('X-Session-ID', sid); // client should persist this
  }
  return { sessionId: `guest_${sid}`, isGuest: true };
}

// POST /api/chat
router.post('/', optionalAuth, chatRateLimiter, async (req, res, next) => {
  try {
    const { message } = req.body;
    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({ success: false, error: 'message is required' });
    }
    if (message.length > 1000) {
      return res.status(400).json({ success: false, error: 'message too long (max 1000 chars)' });
    }

    const { sessionId, isGuest } = resolveSessionId(req, res);
    const reply = await sendMessage(sessionId, message.trim());

    res.json({
      success: true,
      data: {
        reply,
        sessionId: isGuest ? sessionId.replace('guest_', '') : undefined,
        isGuest,
      },
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/chat/history (authenticated only)
router.get('/history', optionalAuth, (req, res) => {
  if (!req.user) {
    return res.status(401).json({ success: false, error: 'Authentication required' });
  }
  const history = getSessionHistory(`user_${req.user.id}`);
  res.json({ success: true, data: { history } });
});

// DELETE /api/chat/history
router.delete('/history', optionalAuth, (req, res) => {
  const { sessionId } = resolveSessionId(req, res);
  clearSession(sessionId);
  res.json({ success: true, message: 'Chat history cleared' });
});

export { router as chatRouter };
```

### Verification
```bash
npm run dev
# Test guest chat:
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What are the fees for Engineering level 200?"}'
```
Expected: `{"success":true,"data":{"reply":"...","isGuest":true}}`

### LOG.md entry
```
## Phase 3 — Chat Route
- Date: [DATE]
- Status: COMPLETE
- Files created: src/middleware/optionalAuth.js
- Files modified: src/routes/chat.js
- Verification: POST /api/chat → 200 with Gemini reply confirmed
```

---

## Phase 4 — Topics & FAQ Route
**Time estimate:** 15 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Implement `GET /api/topics` and `GET /api/faqs`. These are static data endpoints —
no AI call needed. Clients use them to render the Topics screen.

### Actions

**[CLAUDE HANDLES]** — Write `src/routes/topics.js`
```javascript
import { Router } from 'express';
const router = Router();

const topics = [
  { id: 'fees', label: 'Fees & Payments', icon: '💰',
    prompt: 'What are the tuition fees for this academic year?' },
  { id: 'exams', label: 'Exam Dates', icon: '📅',
    prompt: 'When are the upcoming examinations?' },
  { id: 'registration', label: 'Registration', icon: '📝',
    prompt: 'How do I register for courses this semester?' },
  { id: 'facilities', label: 'Campus Facilities', icon: '🏛️',
    prompt: 'What facilities are available on the Miotso campus?' },
  { id: 'handbook', label: 'Student Handbook', icon: '📖',
    prompt: 'Where can I find the student handbook?' },
  { id: 'contacts', label: 'Key Contacts', icon: '📞',
    prompt: 'What are the key office contacts at Central University?' },
  { id: 'admissions', label: 'Admissions', icon: '🎓',
    prompt: 'What are the admission requirements for Central University?' },
  { id: 'hostels', label: 'Accommodation', icon: '🏠',
    prompt: 'Tell me about hostels and accommodation at Central University.' },
];

const faqs = [
  { id: 1, question: 'How much are Level 200 Engineering fees?' },
  { id: 2, question: 'When does second semester registration close?' },
  { id: 3, question: 'Where is the library and what are its hours?' },
  { id: 4, question: 'How do I check my admission status?' },
  { id: 5, question: 'What is the GPA grading scale at Central University?' },
  { id: 6, question: 'How do I apply for a resit examination?' },
  { id: 7, question: 'Where is the Finance Office?' },
  { id: 8, question: 'What Mobile Money options are accepted for fees?' },
  { id: 9, question: 'How do I access the student portal?' },
  { id: 10, question: 'What clubs and societies are available?' },
];

router.get('/topics', (req, res) => {
  res.json({ success: true, data: { topics } });
});

router.get('/faqs', (req, res) => {
  res.json({ success: true, data: { faqs } });
});

export { router as topicsRouter };
```

> Note: In `app.js`, mount this as `app.use('/api', topicsRouter)` so routes
> are `/api/topics` and `/api/faqs`.

### Verification
```bash
curl http://localhost:3000/api/topics
curl http://localhost:3000/api/faqs
```
Expected: both return `{"success":true,"data":{...}}`

### LOG.md entry
```
## Phase 4 — Topics & FAQ Route
- Date: [DATE]
- Status: COMPLETE
- Files modified: src/routes/topics.js
- Verification: GET /api/topics and /api/faqs → 200 confirmed
```

---

## Phase 5 — Auth Routes (Optional User Accounts)
**Time estimate:** 40 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Implement optional user registration and login. The app and web work without
this. When a user signs up, their chat sessions are persistent and tied to
their account. Uses JWT (access + refresh token pattern).

### Note on storage
For the hackathon, store users in a JSON file (`data/users.json`) — no DB needed.
This is replaced by PostgreSQL in production. Claude will note this clearly in comments.

### Pre-flight reads
- `src/routes/auth.js` (current stub)

### Actions

**[CLAUDE HANDLES]** — Write `src/services/authService.js`
```javascript
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { v4 as uuidv4 } from 'uuid';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DB_PATH = join(__dirname, '../../data/users.json');

function readUsers() {
  if (!existsSync(DB_PATH)) return [];
  return JSON.parse(readFileSync(DB_PATH, 'utf-8'));
}

function writeUsers(users) {
  writeFileSync(DB_PATH, JSON.stringify(users, null, 2));
}

export async function register({ name, email, password }) {
  const users = readUsers();
  if (users.find(u => u.email === email)) {
    throw Object.assign(new Error('Email already registered'), { status: 409 });
  }
  const hashed = await bcrypt.hash(password, 10);
  const user = { id: uuidv4(), name, email, password: hashed, createdAt: new Date().toISOString() };
  writeUsers([...users, user]);
  return { id: user.id, name: user.name, email: user.email };
}

export async function login({ email, password }) {
  const users = readUsers();
  const user = users.find(u => u.email === email);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    throw Object.assign(new Error('Invalid email or password'), { status: 401 });
  }
  return signTokens(user);
}

export function signTokens(user) {
  const payload = { id: user.id, email: user.email, name: user.name };
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });
  const refreshToken = jwt.sign({ id: user.id }, process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' });
  return { accessToken, refreshToken, user: payload };
}

export function verifyRefreshToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

export function getUserById(id) {
  return readUsers().find(u => u.id === id) || null;
}
```

**[CLAUDE HANDLES]** — Write `src/routes/auth.js`
```javascript
import { Router } from 'express';
import { register, login, verifyRefreshToken, signTokens, getUserById }
  from '../services/authService.js';

const router = Router();

// POST /api/auth/register
router.post('/register', async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ success: false, error: 'name, email and password are required' });
    }
    if (password.length < 8) {
      return res.status(400).json({ success: false, error: 'password must be at least 8 characters' });
    }
    const user = await register({ name, email, password });
    const tokens = await login({ email, password });
    res.status(201).json({ success: true, data: tokens });
  } catch (err) { next(err); }
});

// POST /api/auth/login
router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'email and password are required' });
    }
    const tokens = await login({ email, password });
    res.json({ success: true, data: tokens });
  } catch (err) { next(err); }
});

// POST /api/auth/refresh
router.post('/refresh', (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ success: false, error: 'refreshToken is required' });
    }
    const payload = verifyRefreshToken(refreshToken);
    const user = getUserById(payload.id);
    if (!user) return res.status(401).json({ success: false, error: 'User not found' });
    const tokens = signTokens(user);
    res.json({ success: true, data: tokens });
  } catch (err) {
    res.status(401).json({ success: false, error: 'Invalid or expired refresh token' });
  }
});

export { router as authRouter };
```

**[GEMINI EXECUTES]** — Create data directory
```bash
mkdir -p /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/data
echo '[]' > /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/data/users.json
echo 'data/users.json' >> /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/.gitignore
```

### Verification
```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Kevin","email":"kevin@test.com","password":"testpass123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"kevin@test.com","password":"testpass123"}'
```
Expected: both return `{"success":true,"data":{"accessToken":"...","refreshToken":"..."}}`

### LOG.md entry
```
## Phase 5 — Auth Routes
- Date: [DATE]
- Status: COMPLETE
- Files created: src/services/authService.js, data/users.json
- Files modified: src/routes/auth.js
- Verification: register + login → JWT confirmed
```

---

## Phase 6 — User Profile Route + Auth Middleware
**Time estimate:** 15 minutes
**Owner:** Claude writes spec, Gemini executes

### Goal
Add GET/PATCH `/api/user/profile` for authenticated users.
Add `src/middleware/auth.js` (strict — blocks if no token).

### Actions

**[CLAUDE HANDLES]** — Write `src/middleware/auth.js`
```javascript
import jwt from 'jsonwebtoken';

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
```

**[CLAUDE HANDLES]** — Add to `src/routes/auth.js` (append these routes):
```javascript
import { requireAuth } from '../middleware/auth.js';
import { readFileSync, writeFileSync } from 'fs';

// GET /api/user/profile
router.get('/user/profile', requireAuth, (req, res) => {
  res.json({ success: true, data: { user: req.user } });
});

// PATCH /api/user/profile  (update display name only)
router.patch('/user/profile', requireAuth, (req, res, next) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ success: false, error: 'name is required' });
    // update in file store
    const users = JSON.parse(readFileSync(DB_PATH, 'utf-8'));
    const idx = users.findIndex(u => u.id === req.user.id);
    if (idx === -1) return res.status(404).json({ success: false, error: 'User not found' });
    users[idx].name = name;
    writeFileSync(DB_PATH, JSON.stringify(users, null, 2));
    res.json({ success: true, data: { user: { ...req.user, name } } });
  } catch (err) { next(err); }
});
```

> Mount these in app.js: `app.use('/api', authRouter)` so paths are
> `/api/user/profile`.

### Verification
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"kevin@test.com","password":"testpass123"}' | \
  node -e "let d='';process.stdin.on('data',c=>d+=c).on('end',()=>console.log(JSON.parse(d).data.accessToken))")

curl http://localhost:3000/api/user/profile \
  -H "Authorization: Bearer $TOKEN"
```
Expected: `{"success":true,"data":{"user":{"id":"...","name":"Kevin",...}}}`

### LOG.md entry
```
## Phase 6 — User Profile Route
- Date: [DATE]
- Status: COMPLETE
- Files created: src/middleware/auth.js
- Files modified: src/routes/auth.js
- Verification: GET /api/user/profile with JWT → 200 confirmed
```

---

## Phase 7 — Integration Test + Final Wiring
**Time estimate:** 20 minutes
**Owner:** Gemini executes

### Goal
Run full API integration: guest chat works, auth chat works, topics/faqs work.
Confirm all routes align with CONTRACTS.md.

### Actions

**[GEMINI EXECUTES]** — Full integration test sequence
```bash
# 1. Health
curl http://localhost:3000/health

# 2. Topics + FAQs
curl http://localhost:3000/api/topics
curl http://localhost:3000/api/faqs

# 3. Guest chat
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Where is the library?"}'

# 4. Auth register + login
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test2@cu.gh","password":"password123"}'

# 5. Auth chat
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer [TOKEN]" \
  -d '{"message":"What are the Engineering fees?"}'

# 6. Chat history
curl http://localhost:3000/api/chat/history \
  -H "Authorization: Bearer [TOKEN]"
```

### LOG.md entry
```
## Phase 7 — Integration Test
- Date: [DATE]
- Status: COMPLETE
- All 6 curl tests passed
- API ready for client consumption
```

---

## Phase Summary

| Phase | Description | Est. Time | Status |
|---|---|---|---|
| 0 | Project Bootstrap | 20 min | ✅ |
| 1 | App Shell + Health | 20 min | ✅ |
| 2 | Knowledge Base + Gemini | 30 min | ✅ |
| 3 | Chat Route | 25 min | ✅ |
| 4 | Topics & FAQ Route | 15 min | ✅ |
| 5 | Auth Routes | 40 min | ⬜ |
| 6 | User Profile | 15 min | ⬜ |
| 7 | Integration Test | 20 min | ⬜ |
| | **Total** | **2h 45min** | |
