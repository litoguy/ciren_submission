# CampusAI API

Node.js/Express backend serving the Gemini knowledge base API.
Shared between the Flutter app and the React web app.

## Status
Not started. Focus is on `app/` first.

## Planned Stack
- Node.js + Express
- Google Gemini API (`@google/generative-ai`)
- dotenv for config

## Planned Endpoints
- `POST /api/chat` — accepts `{ message, history[] }`, returns `{ reply }`
- `GET /api/topics` — returns list of topic categories
- `GET /api/faqs` — returns frequently asked questions list
- `GET /health` — health check

## When to Start
After the Flutter app is demo-ready (Phase 8 complete).
