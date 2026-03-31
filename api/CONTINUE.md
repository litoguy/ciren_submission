# CampusAI API — Session Handoff Prompt

> Paste this entire file as your FIRST message in a new Claude or Gemini session.

---

## Who I Am
Kevin Afenyo (KT Innovations / TechKnowslogic), full-stack developer, Ghana.
Stack: Flutter, Node.js, PostgreSQL, Supabase, Redis.

## Workflow
- **Claude** — architecture, spec, code that requires deep reasoning
- **Gemini CLI + Desktop Commander MCP** — file writes, terminal commands

## Project
**CampusAI** — AI campus assistant for Central University Ghana, Miotso.
Built at the CIReN Mini Hackathon 2026 (MLH + Google).

## Repo
`/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/`

## Structure
```
campusAI/
├── api/            ← Node.js/Express API (THIS FOLDER — PRIMARY NOW)
│   ├── PHASES.md   ← Full 7-phase API build plan (READ THIS FIRST)
│   ├── LOG.md      ← Implementation log
│   ├── CONTINUE.md ← This file
│   └── CONTRACTS.md← Request/response shapes for all clients
├── app/            ← Flutter app (on hold until API is running)
└── web/            ← React web app (not started)
```

## API Details
- Runtime: Node.js 18+ with ES modules (`"type": "module"`)
- Port: 3000 (dev)
- Framework: Express
- AI: Google Gemini 1.5 Pro via `@google/generative-ai`
- Auth: JWT (access + refresh token)
- Storage: JSON file (`data/users.json`) for hackathon, replace with PG later
- Sessions: In-memory Map (replace with Redis for production)

## Key Architecture Decisions
1. **Gemini lives in the API only** — clients never call Gemini directly
2. **Guest mode works everywhere** — no features gated behind auth
3. **Auth is additive** — signing up adds persistence + display name only
4. **Session ID for guests** — via `X-Session-ID` header, clients persist in storage
5. **Long-context approach** — full CU knowledge base in system prompt, no RAG

## Environment Variables
```
PORT=3000
GEMINI_API_KEY=
JWT_SECRET=
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3001
```

## How to Resume

### Step 1 — Check current state
```
Read these files:
- /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/PHASES.md
- /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/LOG.md
```

### Step 2 — Find last completed phase
Check LOG.md. Last COMPLETE entry = done. Next phase = start here.

### Step 3 — Execute
Ask Claude for the spec for the next phase. Hand to Gemini to execute.

## Output Format (Claude must always follow)
1. **Pre-flight reads** — files to read before touching anything
2. **Actions** — numbered, `[CLAUDE HANDLES]` or `[GEMINI EXECUTES]`
3. **Verification** — command + expected output
4. **LOG.md entry** — exact text to append

## Current Status
> Update at start of each session.

- Last completed phase: **None — API just planned**
- Next phase: **Phase 0 — Project Bootstrap**
- Blocker: Need `GEMINI_API_KEY` and `JWT_SECRET` in `.env` before Phase 2

## Important Notes
- Read `CONTRACTS.md` before making any route changes — contracts drive clients
- The app's `Phase 2` (Gemini Service) is now REPLACED by HTTP calls to this API
  Update `app/PHASES.md` Phase 2 when API Phase 3 (chat route) is complete
- Knowledge base placeholder sections in `src/knowledge/campusData.js` must be
  filled by the content research teammate before demo
- Commit after every phase
