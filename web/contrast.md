# CampusAI API — Contracts

> This file is the single source of truth for all request/response shapes.
> Both the Flutter app and the React web app must conform to these contracts.
> Do not change a contract without updating both clients.
>
> Base URL (dev):  `http://localhost:3000`
> Base URL (prod): `https://api.campusai.central.edu.gh` (TBD)

---

## General Response Envelope

Every response from the API follows this shape:

**Success:**
```json
{
  "success": true,
  "data": { }
}
```

**Error:**
```json
{
  "success": false,
  "error": "Human-readable error message"
}
```

HTTP status codes are always meaningful:
- `200` — OK
- `201` — Created (registration)
- `400` — Bad request (missing/invalid fields)
- `401` — Unauthorized (missing or invalid JWT)
- `404` — Not found
- `409` — Conflict (email already exists)
- `429` — Rate limit exceeded
- `500` — Server error

---

## Authentication

The API supports two modes:

### Guest mode
No token required. All public routes work.
The server assigns a session via the `X-Session-ID` response header.
Clients should persist this value (SharedPreferences / localStorage)
and send it back in the `X-Session-ID` request header on subsequent calls.
Chat history is in-memory only and lost when the server restarts.

### Authenticated mode
Send a Bearer token in the Authorization header:
```
Authorization: Bearer <accessToken>
```
Chat sessions are tied to the user account.
When the access token expires, use the refresh token to get a new one.

---

## Endpoints

---

### GET `/health`
No auth required.

**Response 200:**
```json
{
  "status": "ok",
  "service": "CampusAI API",
  "version": "1.0.0",
  "timestamp": "2026-03-31T09:00:00.000Z"
}
```

---

### POST `/api/chat`
Send a message to CampusAI. Works in guest and authenticated modes.

**Headers (guest):**
```
Content-Type: application/json
X-Session-ID: <uuid>          ← optional, server assigns one if missing
```

**Headers (authenticated):**
```
Content-Type: application/json
Authorization: Bearer <accessToken>
```

**Request body:**
```json
{
  "message": "What are the fees for Level 300 Engineering?"
}
```

| Field | Type | Required | Rules |
|---|---|---|---|
| `message` | string | yes | 1–1000 characters |

**Response 200:**
```json
{
  "success": true,
  "data": {
    "reply": "Level 300 Engineering fees for this academic year are...",
    "sessionId": "a1b2c3d4-...",
    "isGuest": true
  }
}
```

| Field | Type | Notes |
|---|---|---|
| `reply` | string | Gemini's response |
| `sessionId` | string \| undefined | Only returned for guests. Persist and reuse. |
| `isGuest` | boolean | `true` for guest, `false` for authenticated |

**Response headers (guest only):**
```
X-Session-ID: a1b2c3d4-...
```

**Error 400:**
```json
{ "success": false, "error": "message is required" }
```

**Error 429:**
```json
{ "success": false, "error": "Chat rate limit exceeded. Please wait a moment." }
```

---

### GET `/api/chat/history`
Get authenticated user's current session history.
**Requires: Bearer token**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "history": [
      { "role": "user", "parts": [{ "text": "What are the fees?" }] },
      { "role": "model", "parts": [{ "text": "The fees are..." }] }
    ]
  }
}
```

**Error 401:**
```json
{ "success": false, "error": "Authentication required" }
```

---

### DELETE `/api/chat/history`
Clear the current session's chat history (guest or authenticated).

**Response 200:**
```json
{ "success": true, "message": "Chat history cleared" }
```

---

### GET `/api/topics`
Get all topic categories for the Topics screen.
No auth required.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "topics": [
      {
        "id": "fees",
        "label": "Fees & Payments",
        "icon": "💰",
        "prompt": "What are the tuition fees for this academic year?"
      },
      {
        "id": "exams",
        "label": "Exam Dates",
        "icon": "📅",
        "prompt": "When are the upcoming examinations?"
      }
    ]
  }
}
```

| Field | Type | Notes |
|---|---|---|
| `id` | string | Unique identifier for the topic |
| `label` | string | Display label for the UI card |
| `icon` | string | Emoji icon |
| `prompt` | string | Pre-filled message to send to `/api/chat` when topic is tapped |

---

### GET `/api/faqs`
Get the frequently asked questions list.
No auth required.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "faqs": [
      { "id": 1, "question": "How much are Level 200 Engineering fees?" },
      { "id": 2, "question": "When does second semester registration close?" }
    ]
  }
}
```

| Field | Type | Notes |
|---|---|---|
| `id` | number | Unique identifier |
| `question` | string | The FAQ text — also used as the chat prompt when tapped |

---

### POST `/api/auth/register`
Create a new user account. Returns tokens immediately (auto-login).
No auth required.

**Request body:**
```json
{
  "name": "Kevin Afenyo",
  "email": "kevin@central.edu.gh",
  "password": "securepassword"
}
```

| Field | Type | Required | Rules |
|---|---|---|---|
| `name` | string | yes | 1–100 chars |
| `email` | string | yes | valid email |
| `password` | string | yes | min 8 chars |

**Response 201:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": "uuid",
      "name": "Kevin Afenyo",
      "email": "kevin@central.edu.gh"
    }
  }
}
```

**Error 409:**
```json
{ "success": false, "error": "Email already registered" }
```

---

### POST `/api/auth/login`
Login with email and password.
No auth required.

**Request body:**
```json
{
  "email": "kevin@central.edu.gh",
  "password": "securepassword"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": "uuid",
      "name": "Kevin Afenyo",
      "email": "kevin@central.edu.gh"
    }
  }
}
```

**Error 401:**
```json
{ "success": false, "error": "Invalid email or password" }
```

---

### POST `/api/auth/refresh`
Exchange a refresh token for a new access token.
No auth required.

**Request body:**
```json
{
  "refreshToken": "eyJ..."
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJ...",
    "refreshToken": "eyJ...",
    "user": {
      "id": "uuid",
      "name": "Kevin Afenyo",
      "email": "kevin@central.edu.gh"
    }
  }
}
```

**Error 401:**
```json
{ "success": false, "error": "Invalid or expired refresh token" }
```

---

### GET `/api/user/profile`
Get the authenticated user's profile.
**Requires: Bearer token**

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "Kevin Afenyo",
      "email": "kevin@central.edu.gh"
    }
  }
}
```

---

### PATCH `/api/user/profile`
Update the authenticated user's display name.
**Requires: Bearer token**

**Request body:**
```json
{
  "name": "Kevin A."
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "Kevin A.",
      "email": "kevin@central.edu.gh"
    }
  }
}
```

---

## Rate Limits

| Scope | Limit | Window |
|---|---|---|
| All routes | 60 requests | per 1 minute per IP |
| `/api/chat` | 20 requests | per 1 minute per IP |

Rate limit response (HTTP 429):
```json
{ "success": false, "error": "Too many requests. Please slow down." }
```

---

## Client Implementation Notes

### Flutter App
- Use `http` package for all API calls
- Store `accessToken`, `refreshToken`, and `sessionId` in `SharedPreferences`
- On 401 response: call `/api/auth/refresh` with the refreshToken, retry
- If refresh also fails: clear tokens, revert to guest mode
- Guest sessionId: read from `X-Session-ID` response header, store in SharedPreferences
- Send sessionId back in `X-Session-ID` request header on every chat call

### React Web App
- Use `fetch` or `axios` for API calls
- Store tokens in `localStorage` (or httpOnly cookies for production)
- Same 401 → refresh → retry pattern as Flutter
- Guest sessionId: read from `X-Session-ID` response header, store in `sessionStorage`

### Both clients
- The app works fully in guest mode — do not gate any core feature behind auth
- Auth is purely additive — it adds persistence and a display name, nothing more
- The `/api/chat` endpoint is the only AI call — never call Gemini directly from clients
