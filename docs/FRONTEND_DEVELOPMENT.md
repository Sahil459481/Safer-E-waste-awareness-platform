# Frontend Development Guide

This document describes the current frontend and facility API implementation for the Data-Driven E-Waste Awareness and Management Platform. It complements `PROJECT_WEBSITE_PLAN.md` and the root `AGENTS.md` guardrails.

## 1. Product scope

The website is a static public information site for the initial India/Maharashtra pilot, with a separate read-only API for the facility finder. Its purpose is to:

- explain safer next steps for unwanted electronics;
- summarize the Indian e-waste rules with links to official sources;
- help visitors find official facility information without presenting stale records as current;
- show carefully labeled e-waste measures at the geographic levels provided by the source; and
- make project scope, data limitations, and privacy boundaries visible.

It does not accept device uploads, user accounts, comments, facility submissions, contact forms, GPS coordinates, or survey responses. The API has no public write or admin routes. The site does not collect, certify, transport, store, dismantle, or repair devices. The public survey remains a separate Google Form and is not embedded in the site.

## 2. Technology choices

- **Astro static output:** produces public HTML pages at build time. The facility finder calls a same-origin API only when a visitor searches, with name/address, district, category, and pagination filters.
- **Supabase Edge Function + PostgreSQL:** serves only approved, unexpired facilities recently verified by the project team. The browser calls the function with a public publishable key; it never receives a database or secret key.
- **TypeScript:** used for the dashboard data, schemas, and browser-side interactions.
- **Zod:** validates browser search controls and server query parameters.
- **Plain CSS:** a small shared design system, no UI framework or runtime style dependency.
- **Native DOM and CSS bars/tables:** interactive dashboard and data presentation without a third-party chart runtime.
- **System font stack and local SVGs:** avoids font/CDN requests and third-party image dependencies.

The Edge Function pins `@supabase/server` and Zod versions in `supabase/functions/facility-search/deno.json`. No map SDK or public map token is required.

## 3. Page map

| Route | Purpose | Current behavior |
| --- | --- | --- |
| `/` | Entry page and next-step routes | Links to the guide, official facility sources, and dashboard. |
| `/guide/` | Practical handling information | Gives non-invasive steps for personal data, formal take-back, batteries, and damaged devices. |
| `/rules/` | Plain-language rules overview | Distinguishes broad regulated-entity duties from household guidance and links to official sources. |
| `/documents/` | In-page official document reader | Embeds CPCB and MoEFCC PDFs with publisher/date labels and direct-open fallbacks. The viewer depends on the official host allowing embedding. |
| `/facilities/` | Maharashtra-first facility locator | Bounded search calls the same-origin API. The page embeds the official March 2024 MPCB PDF as a dated historical reference and links the live authorisation register. |
| `/data/` | E-waste data dashboard | Offers measure-specific national or state views and an accessible data table. |
| `/sources/` | Source register, limitations, privacy and update notes | Records definitions, source dates, geographic limits, and project boundaries. |

The shared page shell is `src/layouts/BaseLayout.astro`. Navigation and footer live in `src/components/SiteHeader.astro` and `src/components/SiteFooter.astro`. Shared responsive styles are in `src/styles/global.css`.

## 4. Facility directory and freshness

The official MPCB e-waste page links a facility list dated March 2024. The facility finder embeds this PDF as historical reference. A record appearing in that old document is not enough to claim that its current registration, authorisation, consent, operations, contact details, or accepted items remain valid. The live register is linked separately for current status checks.

The Edge Function calls one bounded SQL routine in `backend/migrations/003_public_facility_search.sql`. That function is owned by the non-login `facility_api_reader` role, which has SELECT-only table access and is constrained by RLS. The browser has no direct table grants. The API returns only rows marked approved, with unexpired authorisation and project verification within 180 days. On 16 November 2026, 69 records from the live MPCB outward register were imported as review candidates; none are approved, so the public finder correctly returns no directory records until human review is completed. The March 2024 PDF remains a historical reference. No public import or administration route exists. Do not add sample facilities or infer district-level waste quantities from facility locations or capacity.

The current site does not ask for browser geolocation and does not include a map token. If a later version adds a map or “Near me” feature, ask permission only after an explicit click, process coordinates in the browser when possible, and do not send or log them without clear consent. Any geocoding endpoint must be rate limited and use bounded, validated inputs.

## 5. Dashboard data and definitions

`src/data/e-waste.ts` is the curated, read-only source dataset. It includes:

- national generation estimates for FY 2023–24 and FY 2024–25;
- the official combined national percentage for e-waste “collected, dismantled and recycled / disposed” for those years;
- an EPR-framework recycling snapshot reported as of 5 March 2026; and
- state-wise quantities reported as processed for the 19 states in the cited parliamentary reply.

These figures do not represent a single common measure or period. In particular:

- the combined percentage is not a collection-only rate;
- the EPR recycling snapshot is not directly comparable to an annual state processed quantity;
- state-wise processed data does not support district- or facility-level processing totals; and
- null values mean the source did not provide a value, not that the amount was zero.

Dashboard interaction is implemented in `src/pages/data.astro`. The user selects a measure, financial year, and (only for processed quantities) a state. `dashboardFilterSchema` validates the select values before display logic runs. The script creates text nodes with `textContent`, not HTML from user-controlled strings. Each view provides a text-based bar summary and a table; values remain readable without relying on colour.

### Updating data

1. Check CPCB/MoEFCC/PIB or the relevant state regulator for a new official release.
2. Record the source URL, publication date, reporting period, exact measure wording, unit, geographic scope, and date checked.
3. Compare definitions and units before replacing a value. Do not silently combine or extrapolate unlike measures.
4. Update the curated data and source notes in the same reviewed change.
5. Build the site and manually inspect the dashboard, including missing-value behavior and source links.

The site is not a live feed. A future scheduled source check may flag changes, but publication should remain behind human review. Do not add a public write endpoint for data refresh.

## 6. Input handling and safe rendering

`src/lib/input-schemas.ts` contains strict Zod schemas for directory filters, the directory response, and dashboard filters. Search text is trimmed, length-limited, and restricted to letters, numbers, spaces, and basic punctuation. The browser encodes validated search values in a same-origin GET request. The API validates again, caps pages at 40 and page size at 25, escapes SQL wildcard characters, and binds every filter as a PostgreSQL parameter. Results are built with DOM text nodes rather than HTML strings.

Static awareness content is authored in Astro templates and is not user-submitted Markdown. External official links use `target="_blank"` with `rel="noopener noreferrer"`. No `dangerouslySetInnerHTML` or raw HTML insertion is used.

## 7. Security and privacy

- The public API has no write/admin route, account, analytics, or location API. Supabase secret credentials remain in the function runtime and are never sent to the browser.
- `.env.example` contains only the public project URL and a blank publishable key. Never put a Supabase secret key, service-role key, or database password in a public variable or source file.
- The public dataset is imported at build time; browser interactions are read-only and local.
- The mobile menu changes only local presentation state. The header theme control supports light and dark appearance, follows the visitor's system preference initially, and stores an explicit choice in local storage. It stores no identity or location data.
- `public/_headers` contains a restrictive same-origin CSP, frame denial, content-type protection, referrer policy, permissions policy, and HSTS directive for static hosts that support the `_headers` convention.
- Before launch, confirm the chosen host applies those headers to built HTML and assets and serves HTTPS. HSTS must only be relied on for an HTTPS production domain. Do not assume this file configures a host that uses a different header mechanism.
- Avoid adding third-party scripts or external resources without reviewing the CSP, privacy impact, dependency health, and security implications.
- The Edge Function validates the publishable key, query parameters, method, exact allowed origin, and bounded page size. The database routine uses fixed SQL, escaped search text, a statement timeout, and only the SELECT-only reader role. A best-effort per-isolate request limit is not distributed; configure a distributed limiter or edge/WAF rule before a high-traffic public launch.
- The official-document page embeds only named CPCB and MoEFCC PDF URLs. `frame-src` is narrowly allowlisted for those publishers, while `frame-ancestors 'none'` and `X-Frame-Options: DENY` continue to prevent other sites framing this website. PDF requests use `no-referrer`; direct links provide a browser fallback. If a publisher changes its hosting policy or URL, use the direct source link and update the allowlist only after review.

There is no public promise that a website is “completely secure.” The implementation minimizes exposed functionality and should still receive a launch review, dependency checks, hosting configuration review, accessibility testing, and ongoing updates.

## 8. Accessibility and interface conventions

- Shared colors and spacing are CSS custom properties and repeated component classes.
- Headings follow a page-level hierarchy; navigation includes a skip link and current-page indicator.
- Interactive controls have visible labels, focus outlines, and live status messages.
- Tables accompany data bars; bar colors are decorative only.
- Layouts adapt at tablet and mobile breakpoints; reduced-motion preferences are respected.
- Continue review against WCAG 2.2 AA, including keyboard-only navigation, zoom/reflow, contrast, screen-reader output, and real-device testing.

## 9. Local development and build

Install Node.js 22.23.4 or newer. The static website runs with:

```sh
npm install
npm run dev
```

The facility finder uses the Supabase Edge Function described in `backend/README.md`. Its browser code sends the public publishable key in the `apikey` request header; it does not use or expose the server secret. Astro proxies `/api/facilities` to the function locally, and the static-host rewrite is in `public/_redirects`. Run `npm run dev`. No local database service is required.

Build static output and preview it locally:

```sh
npm run build
npm run preview
```

The generated website is written to `dist/`. The current host/domain is undecided; deployment configuration must be reviewed once selected. The host must support the external rewrite in `public/_redirects` or provide an equivalent same-origin proxy. Before production, set the Edge Function's `ALLOWED_ORIGINS` to the exact production site origin.

## 10. Work log

### 16 November 2026 — facility API connection and theme control

- Connected the facility search page to the existing read-only Edge Function through the same-origin `/api/facilities/` path, using the active public publishable key from the connected Supabase project. The trailing slash is required by this site's `trailingSlash: 'always'` setting. The local `.env` is ignored by Git and contains no server secret.
- Added a district search field and sends the validated name/address query, district, category, and bounded page values to the API.
- Added strict Zod validation for facility API responses and kept rendering text-only through DOM `textContent`.
- Updated facility-page messaging to explain that MPCB data is pending human verification and only approved records can appear. The current database has 69 candidates and no public-approved records.
- Added a separate, keyboard-accessible light/dark control in the shared header. It starts from the system preference, remembers an explicit choice locally, and updates the browser theme color.
- Added dark color tokens and adjusted facility search layout for tablet and mobile widths.
- Updated this guide and `backend/README.md` to record the current integration and data state.
- Ran `npm run build`; Astro generated all seven static pages successfully. No test suite was run.
- No new packages, analytics, GPS collection, public write endpoint, or new tests were added. Deployment routing still depends on the selected host supporting the documented rewrite.

### 16 November 2026 — local search error correction

- Traced the screenshot's “service is not available” message to an Astro 404: `/api/facilities` was missing the trailing slash required by this site's routing configuration, and the fetch correctly rejected Astro's redirect because `redirect: 'error'` is enabled.
- Confirmed the Supabase Edge Function itself returned HTTP 200 with the expected empty result shape. It returned zero rows because no facility candidates are approved for public listing yet.
- Changed the browser request to `/api/facilities/` and added the slash form to `public/_redirects`; kept the no-slash rewrite as a compatibility alias.
- Rechecked the corrected local proxy path: it returned HTTP 200 and the expected JSON response. Rebuilt successfully; all seven static pages generated.

## 11. Before public launch

- Re-verify facility data and publish only records with current official evidence and review dates.
- Recheck the latest E-Waste Rules/amendments and consumer guidance on official sites.
- Update source-backed metrics only after human review, preserving exact definitions and units.
- Choose a static host and confirm HTTPS, security headers, redirects, domain settings, and build artifact behavior.
- Review privacy notices against actual production data flows; do not add analytics or forms without a project decision and data-retention plan.
- Test responsive behavior, keyboard access, screen-reader labels, colour contrast, external links, and error/empty states.
- Check dependency advisories and ensure `.env` files are not committed.
