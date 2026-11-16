# Safer E‑Waste — public awareness website

A mostly static Astro website for an Indian e-waste awareness pilot, with a read-only Supabase Edge Function for facility search. It includes a public guide, rules overview, in-page official PDF readers, Maharashtra facility finder, sourced dashboard, and project source notes.

## Run locally

Requires Node.js 22.23.4 or newer.

```sh
npm install
npm run dev
```

Build and preview the static site:

```sh
npm run build
npm run preview
```

## Facility API

The facility finder calls a Supabase Edge Function. Read [backend/README.md](backend/README.md) for local setup, key handling, data verification, and deployment origins. The public browser uses only a publishable key; table access, imports, and approvals remain private.

## Security and data boundaries

- No user accounts, user submissions, analytics, or geolocation are used. Facility search is read-only and has no public write endpoints.
- The MPCB March 2024 PDF is embedded in the facility finder as historical reference. Its entries are not treated as currently authorised until individually rechecked against MPCB’s live register and approved; the API returns only recently verified, unexpired, approved rows.
- Dashboard values are static, source-linked snapshots. Update them only after checking an official source, period, definition, unit, and geographic level.
- `public/_headers` provides baseline headers for static hosts that support the `_headers` convention (including Cloudflare Pages and Netlify). Confirm the production host applies them and serves HTTPS before launch; HSTS should only be enabled on an HTTPS domain.
- No map token is currently required. If a public map token is added later, restrict it to the production domain and local development origins. Never expose private credentials.

## Content review

Regulatory text is a short public-information summary, not legal advice. Check the linked MoEFCC, CPCB, and MPCB sources before publishing revisions. The dataset metadata records the reporting period and source coverage; it must not be interpreted as a complete country-to-facility breakdown.
