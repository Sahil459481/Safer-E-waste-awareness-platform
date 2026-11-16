# AGENTS.md — E-Waste Awareness, Facility Locator & Data Dashboard

## 1. Project Overview
This project is a web platform dedicated to electronic waste (e-waste) awareness, featuring:
- **Educational Content & Guidelines:** Interactive guides on safe e-waste disposal, recycling rules, and regulatory compliance.
- **Facility Locator:** A searchable map and directory for finding certified e-waste collection and recycling centers.
- **Data Dashboard:** Interactive charts and metrics tracking e-waste generation, recycling rates, and regional impact.

## 2. Core Security Guardrails (Strict Enforcement)
- **Zero Hardcoded Secrets:** Never hardcode API keys (e.g., Google Maps, Mapbox, database URLs, analytics tokens) in frontend or backend files. Always load secrets via environment variables (`process.env.*` or `import.meta.env.*`).
- **Public vs. Private Env Variables:** Only expose strictly public, domain-restricted client keys (like a public map token with HTTP referrer restrictions) to the browser. Keep all database write keys and admin tokens server-side only.
- **Input Sanitization & Validation:** Validate and sanitize all user inputs (search queries, location coordinates, facility filter parameters, contact/submission forms) using strict schema validation (e.g., Zod) before database queries or API calls.
- **No Raw SQL / Injection Prevention:** Always use parameterized queries or an ORM. Never concatenate user search strings directly into database queries.
- **XSS Protection:** Sanitize any user-submitted or dynamically rendered markdown/HTML content in the awareness guidelines or facility descriptions. Never use `dangerouslySetInnerHTML` without strict sanitization (e.g., DOMPurify).

## 3. Feature-Specific Rules

### A. Facility Locator (Maps & Geolocation)
- **Privacy First:** Request browser geolocation (`navigator.geolocation`) only upon explicit user action (e.g., clicking "Near Me"). Never store or log user GPS coordinates on the server without explicit consent.
- **Rate Limiting:** Apply rate limiting to location search and geocoding API endpoints to prevent quota exhaustion and API billing abuse.
- **Data Integrity:** Only display verified, certified e-waste recyclers/collection centers. Ensure facility submission endpoints (if present) require moderation/admin approval before going live.
- **Facility API:** Public facility search is GET-only and read-only. The runtime database identity must have SELECT-only grants and must not own its tables. Imports and publication approvals remain private review operations; do not add a public import, edit, or admin route in this pilot.
- **Facility freshness:** Historical regulator lists are candidate sources only. Display a facility only after a human verifies it against the current official register, records the reviewer and check date, and confirms the listed authorisation validity. Show the source/check dates and remind visitors to confirm item acceptance before travelling.

### B. E-Waste Data Dashboard
- **Read-Only Public Access:** Public dashboard endpoints must be strictly GET/read-only.
- **Query Bounds:** Enforce pagination, date-range limits, and aggregation limits on dashboard data queries to prevent Denial-of-Service (DoS) via heavy database loads.
- **Safe Data Rendering:** Handle missing, null, or malformed dataset values gracefully so charts do not crash the UI.

### C. Guidelines & Awareness Hub
- **Accurate Regulatory Framing:** Ensure e-waste disposal guidelines include clear disclaimers and link to official environmental authority standards (e.g., CPCB/E-Waste Management Rules in India, EPA, or local municipal bodies).
- **External Links:** All external links to official guidelines or facility websites must include `rel="noopener noreferrer"` and `target="_blank"`.

## 4. Architecture & Coding Standards
- **Server-Side Authorization:** Any admin routes (e.g., adding/editing recycling facilities or updating dashboard datasets) must verify authentication and role permissions on the server/middleware—never rely solely on hiding UI buttons.
- **Error Handling:** Return generic, safe error messages to the client (e.g., "Unable to fetch facilities"). Never leak stack traces, database schemas, or internal API keys in error responses.
- **Abuse Controls:** Rate-limit public API requests, set request/query timeouts, bound page sizes and page numbers, and use same-origin routing. Do not enable wildcard CORS or trust forwarded headers from arbitrary clients.
- **Dependencies:** Do not install unverified or unnecessary npm/pip packages. Stick to established, well-maintained libraries for maps, charts, and validation.
- **Security Headers:** Ensure deployment configs enforce Content-Security-Policy (CSP), `X-Frame-Options: DENY`, and `Strict-Transport-Security` (HSTS).

## 5. Pre-Commit & Completion Checklist
Before finalizing any feature or pull request, verify:
1. No secrets or `.env` files are staged or committed.
2. All API routes validate inputs and handle errors gracefully.
3. Map API keys have referrer/domain restrictions noted in `.env.example`.
4. Admin/write actions are protected by server-side authentication.

> Before writing code for this feature, read this file. Ensure all user inputs (like location search or filter queries) are validated with a strict schema, no secrets are hardcoded, and any database queries are parameterized and read-only unless protected by server-side admin auth. Outline your security plan briefly before generating the files.
