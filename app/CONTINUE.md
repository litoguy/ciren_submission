# CampusAI — Session Handoff Prompt

> Paste this entire file as your FIRST message in a new Claude or Gemini session.
> It gives the new instance full context to continue without re-explanation.

---

## Who I Am
I am Kevin Afenyo (KT Innovations / TechKnowslogic), a full-stack developer
based in Ghana (Flutter, Node.js, PostgreSQL, Supabase, Redis).

## Workflow
- **Claude** handles architecture, spec writing, debugging logic, and design decisions.
  Claude produces complete implementation specs so Gemini only needs to write to disk.
- **Gemini CLI + Desktop Commander MCP** executes file writes and terminal commands.

## Project
**CampusAI** — An AI-powered campus assistant for Central University Ghana, Miotso Campus.
Built at the CIReN Mini Hackathon 2026 (MLH + Google).

## Repo Location
`/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/`

## Structure
```
campusAI/
├── app/        ← Flutter mobile app (PRIMARY FOCUS)
│   ├── PHASES.md   ← Full phase-by-phase build plan (READ THIS FIRST)
│   ├── LOG.md      ← Implementation log (check for completed phases)
│   └── CONTINUE.md ← This file
├── api/        ← Node.js/Express backend (not started yet)
└── web/        ← React web app (not started yet)
```

## Flutter Details
- Flutter binary: `/Users/kevinafenyo/flutter/bin/flutter`
- Project root: `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app`
- Package name: `com.ktinnovations.campus_ai`

## Design System
| Token | Hex | Usage |
|---|---|---|
| Background | `#0F0205` | Main background |
| Surface | `#120508` | Bottom sheet, cards |
| Primary | `#8B1A2B` | CU Maroon — buttons, active states |
| Gold | `#C9922A` | Accent — FAB, highlights |
| Text Primary | `#FFFFFF` | Headings |
| Text Secondary | `rgba(255,255,255,0.6)` | Labels |

Typography: Playfair Display (headings, 700) + DM Sans (body, 400/500)
Design language: Dark ambient, maroon radial glow blob, bottom sheet actions,
gold mic/send FAB. Based on reference image provided by Kevin.

## Pages (4)
1. Splash — logo, glow, auto-navigate to Home at 2.5s
2. Home — greeting, glow, topic cards, gold input bar
3. Chat — Gemini API conversation UI
4. Topics / FAQ — topic grid + FAQ list, both pre-fill chat

## AI Integration — ARCHITECTURE UPDATED
- **Gemini lives in the API, not the app.**
- The app calls `POST /api/chat` on the CampusAI API (Node.js/Express).
- The API handles Gemini, the knowledge base, and session management.
- The app's Phase 2 (GeminiService) is REPLACED by an `ApiService` that calls the API.
- API base URL: `http://localhost:3000` (dev) — set in `.env` as `API_BASE_URL`
- API contracts: `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/CONTRACTS.md`
- API phase plan: `/Users/kevinafenyo/Documents/GitHub/gemini/campusAI/api/PHASES.md`
- Complete the API (api/PHASES.md) before resuming app Phase 2+

## How to Resume

### Step 1 — Read current state
Ask Claude (or read manually):
```
Read these files and tell me what phase we are on and what is next:
- /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/PHASES.md
- /Users/kevinafenyo/Documents/GitHub/gemini/campusAI/app/LOG.md
```

### Step 2 — Confirm current phase
Check LOG.md for the last COMPLETE entry. The next phase after that is where to continue.

### Step 3 — Execute
Ask Claude to produce the implementation spec for the next phase, then hand to Gemini to execute.

## Output Format (Claude must always follow this)
1. **Pre-flight reads** — list every file to read before touching anything
2. **Actions** — numbered steps with exact file paths and what to change
3. **Verification** — command to run + expected output
4. **LOG.md entry** — exact text to append when done

Label every action:
- `[CLAUDE HANDLES]` — reasoning, architecture, writing code spec
- `[GEMINI EXECUTES]` — mechanical writes, terminal commands, file creation

## Current Status
> Update this section at the start of each session.

- Last completed phase: **None — PHASES.md v2 just written**
- Next phase: **Phase 0 — Project Bootstrap**
- Blockers: API must be running before Phase 5 (chat screen live test)
- Content teammate: Must fill `src/knowledge/campusData.js` in API before demo

## Important Notes
- PHASES.md is v2 — Gemini SDK removed, ApiService replaces it
- Phases 0–6 = fully working app. Phases 7–9 = polish + build.
- If time is short, stop at Phase 6 — you have a functional demo
- API must be running at `API_BASE_URL` in `.env` before Phase 5
- `.env` uses `10.0.2.2:3000` for Android emulator, `localhost:3000` for iOS sim
- Knowledge base content goes in `api/src/knowledge/campusData.js` — NOT in the app
- Commit after every phase
