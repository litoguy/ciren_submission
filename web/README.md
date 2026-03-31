# CampusAI — Central University Ghana

An AI-powered campus assistant for Central University Ghana, Miotso Campus.
Built at the CIReN Mini Hackathon 2026 in collaboration with MLH and Google.

## What It Does
Answers student questions about fees, exams, registration, facilities, and
campus life — using a Gemini-powered backend with a Central University
knowledge base.

## Monorepo Structure

```
campusAI/
├── app/        # Flutter mobile app (iOS + Android)
├── api/        # Node.js/Express backend — Gemini integration + knowledge base
└── web/        # React web app
```

## Tech Stack
- **App:** Flutter, Dart, Riverpod, GoRouter
- **API:** Node.js, Express, Google Gemini API
- **Web:** React, Vite, TailwindCSS
- **AI:** Google Gemini 1.5 Pro (long context window approach)

## Team
Built by [Your Team Name] at CIReN Mini Hackathon 2026
Central University Ghana, Miotso Campus

## Colors
- Primary Maroon: `#8B1A2B`
- Gold Accent: `#C9922A`
- Background: `#0F0205`

## Docs
- `app/PHASES.md` — Flutter app build plan
- `app/LOG.md` — Implementation log
- `app/CONTINUE.md` — Session handoff prompt
