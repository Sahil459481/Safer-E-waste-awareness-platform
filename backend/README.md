# Supabase facility search

The facility finder uses a public, read-only Supabase Edge Function. It has no facility submission, import, login, or administration routes.

## Supabase project

- Project: `safer-e-waste-awareness`
- Region: `ap-south-1`
- Project reference: `ezfnunyfoxlkatgickrk`
- Project URL: `https://ezfnunyfoxlkatgickrk.supabase.co`
- Database migrations: `create_secure_facilities_directory`, `enable_private_audit_rls`, `public_facility_search`, `restrict_public_facility_search_execute`, and `tighten_facility_search_function_acl`

The `facilities` and `facility_review_audit` tables are empty. RLS is enabled on both. Public API roles have no direct table grants, and the audit table has no client policy. The search function is owned by the non-login `facility_api_reader` role, which has SELECT-only access to the facilities table and is subject to the approved/current-record RLS policy. The Edge Function can execute only that specific search routine; its Supabase secret stays in the function runtime and is never sent to the browser.

## Security and publication rules

- The MPCB March 2024 PDF is historical source material, not proof of current authorisation. Entries remain hidden until a human verifies them against the current official register.
- Search returns only approved rows with an unexpired authorisation and verification within the previous 180 days. It omits reviewer and internal fields.
- The Edge Function accepts `GET` and CORS `OPTIONS` only. It rejects unknown or repeated query parameters and validates bounded query text, type, page, and page size with Zod.
- The database search is fixed SQL, escapes LIKE wildcards, has a 1.5-second statement timeout, and caps results to 25 rows and 40 pages. No user-provided SQL or filter expression is constructed.
- Public browser code contains only the Supabase project URL and publishable key. Never use a secret key, `service_role` key, or database password in a `PUBLIC_` variable or committed file.
- The browser uses the same-origin `/api/facilities` route. Astro dev proxies it locally, and `public/_redirects` configures the matching proxy for hosts that support the Netlify/Cloudflare Pages redirects convention. Confirm the selected host supports external 200 rewrites before launch.
- CORS is an exact-origin allowlist. Local development origins are built in. Before the public site is deployed, set the Edge Function environment variable `ALLOWED_ORIGINS` to the exact production origin(s), comma-separated, such as `https://example.org`. Do not use `*`.
- A small in-memory request limit is applied per Edge Function isolate using the platform client IP. It is best-effort and does not coordinate across isolates. Before a public launch with meaningful traffic, add a distributed limiter or edge/WAF rule and configure monitoring/alerts.
- Request query text and coordinates are not logged. Errors returned to visitors are generic.
- No facility records have been approved or imported. Visitors should check MPCB's current register and confirm accepted items and operating details before travelling.

## Local setup

1. Copy `.env.example` to `.env` and set `PUBLIC_SUPABASE_PUBLISHABLE_KEY` from Supabase **Settings → API Keys → Publishable key**. This is a public key by design, but the private/secret key must never be copied here.
2. Start the site with `npm run dev`. The local `/api/facilities` path proxies to the Supabase Edge Function; no local PostgreSQL server is needed.
3. The Edge Function source is `supabase/functions/facility-search/index.ts`. Its imports are version-pinned in the adjacent `deno.json`.

## Function deployment and origin setup

The deployed function must keep platform JWT verification disabled because it validates the publishable key through `@supabase/server` itself. The function source uses `auth: 'publishable'`, and its database work uses the server-only client. Never expose that server-side key.

The Supabase Dashboard's Edge Functions → Secrets page is where `ALLOWED_ORIGINS` is configured. Add the exact production site origin before deployment. If the site changes domain, update this allowlist and the static host's Content Security Policy together.

## Importing the MPCB list

The linked list is dated March 2024 and includes expired permissions and repeated records. Do not bulk-approve it. Parse entries into `candidate` rows, deduplicate by current facility/authorisation identity, then check each record against the current MPCB register before approval. Keep the document URL/date, date checked, validity date, reviewer, and verification date. A listing does not guarantee household drop-off acceptance; visitors must confirm before travelling.
