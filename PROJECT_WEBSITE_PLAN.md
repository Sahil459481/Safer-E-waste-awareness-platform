# Public E-Waste Awareness Website
## Initial planning outline for review

**Status:** Frontend pilot is implemented. The user has approved a narrow facility-search backend expansion; deployment and live data import remain pending.

## 1. Purpose and audience

Create a trustworthy public resource that explains e-waste in plain language, helps people choose a safer formal route for unwanted electronics, and presents carefully sourced Indian data. The first release can be designed for the public while using the college community as its first review group.

The site will provide information and directory links. It will not collect, store, transport, repair, dismantle, or certify electronic devices or facilities.

## 2. Proposed first-release pages

1. **Home:** What e-waste is, a clear “what should I do next?” path, and links to the guide, directory, and data.
2. **Understand e-waste:** Common device examples, why responsible handling matters, and plain-language explanations of reuse, refurbishment, collection, and recycling.
3. **What to do with a device:** Safer next steps such as checking a product maker’s take-back route or an officially listed facility. Include reminders to confirm item acceptance and operating details before travelling. Avoid instructions to open, dismantle, burn, or otherwise process devices.
4. **Rules in plain language:** Explain the scope of the E-Waste (Management) Rules and distinguish household guidance from the formal duties placed on regulated entities. Explain that batteries and some other waste streams may follow separate rules. Every legal summary will link to the source and show its review date.
5. **Find a facility:** Start with the Maharashtra directory pilot. Filter facility listings by district and type. Each entry needs an official source, status/check date, and a “confirm before visiting” note. A listing is not a guarantee of acceptance.
6. **Data dashboard:** Show measures only at the geographic levels supported by their sources: national generation estimates, the source’s combined national collected/dismantled/recycled/disposed percentage, and state-wise quantities reported as processed. Do not imply district or facility processing totals when they are not reported.
7. **Sources, about, and corrections:** Show source notes, definitions, limitations, update history, project ownership, and a simple way to report outdated information.

## 3. Content and source governance

- Use the official Gazette and Ministry of Environment, Forest and Climate Change pages as the authority for rule text. The Ministry lists the 2022 Rules and the 2023 and 2024 amendments; its 2024–25 annual report also records a 12 November 2024 change to Rule 23. Review the consolidated/current legal position before writing or updating summaries.
- Use CPCB guidance for consumer explanations and formal e-waste pathways. Avoid turning rules for producers, manufacturers, refurbishers, dismantlers, or recyclers into unsupported claims about household obligations.
- Treat batteries and other separately regulated streams distinctly; link to their official guidance rather than giving improvised handling instructions.
- For every number or facility, record source URL, exact source wording, unit, period, geographic level, publication date, date checked, and reviewer.
- Use scheduled source checks, then human review and approval before publishing updates. Display “reported for” and “last checked” dates. Keep the last verified version visible if an update check fails.

## 4. Privacy-first product boundary

For the first public release, avoid user accounts, comments, device uploads, public submissions, and a custom backend. Do not collect names, contact details, exact location, device identifiers, or survey responses on the website.

If the existing Google Form is linked from the site, keep it clearly separate from the site, explain its purpose and retention, and verify that email collection remains off and the linked response sheet is shared only with the project team and supervisor. Any future contact or feedback feature should have its data purpose, fields, access, retention, and deletion process agreed before it is added.

The Digital Personal Data Protection Act and Rules have a phased commencement timeline. Before launch, check the provisions then in force and review the site’s actual data flows and notices against current requirements; this plan is not a legal compliance determination.

## 5. Security and accessibility plan

No public website can be guaranteed completely secure. The goal is to minimize what can be attacked, build secure defaults in, and verify the site before launch and during maintenance.

**Initial architecture direction:** a static or statically generated site reading curated, versioned data files. A private scheduled job can flag new source material; a named team member reviews and approves changes before publication. The user approved one limited backend exception for the facility finder: a Supabase Edge Function with GET-only search and a database routine owned by a SELECT-only reader role. Public browser code has no direct facility-table grants. There are still no public accounts, submissions, or write routes. Facility imports and approvals require a separate protected database migration/review process. Other pages remain static.

**Security baseline to design and verify:**
- HTTPS everywhere; secure hosting and domain configuration.
- Least-privilege access to hosting, source control, and data; multi-factor authentication for administrators where available.
- No secrets in source code; protected deployment credentials; protected main branch and review before production changes.
- Minimal, maintained dependencies; dependency and secret scanning; remove unused plugins and third-party scripts.
- Appropriate response headers and a restrictive Content Security Policy; safe output handling; no unsafe HTML from submitted content.
- No public admin interface or file upload. Keep errors generic and avoid exposing internal details.
- Backups/version history, monitoring for uptime and changes, a named person to receive vulnerability reports, and a short incident/rollback procedure.
- Before launch, review against CERT-In’s secure application design/development/operations guidance and OWASP Top 10:2025. Arrange an independent security review appropriate to the hosting and project risks.
- Target WCAG 2.2 AA accessibility: keyboard use, screen-reader labels, readable contrast, text alternatives, responsive layouts, and plain language. Test with people using phones and assistive technologies.

## 6. Delivery phases

1. **Approve scope:** agree on pages, initial geographies, languages, and whether the form is linked or kept separate.
2. **Content and data blueprint:** create the source register, data dictionary, legal-topic outline, facility verification fields, and content review process.
3. **Page structure and visual plan:** sketch navigation and page layouts for mobile first; review with campus users.
4. **Build and populate:** implement the approved pages and initial verified content/data.
5. **Review and harden:** check sources, usability, accessibility, privacy settings, security controls, and backup/rollback process.
6. **Launch and maintain:** publish only after the review gates pass; assign named owners and a scheduled content/data review cadence.

## 7. Decisions for your review

1. **Languages:** English only for the first release, or English plus Marathi and/or Hindi?
2. **Initial directory scope:** Maharashtra only, matching the current pilot, or another starting area?
3. **Survey link:** link the current Google Form from the website, or keep it separate during the first release?
4. **Corrections:** should the first version provide a project email address for correction reports, or only show official-source links until a project contact is approved?
5. **Hosting and domain:** use a college-approved host/domain if available, or choose after the page and security requirements are approved?

## 8. Reference sources

- [MoEFCC rules and regulations page — E-Waste (Management) Rules and listed amendments](https://www.moef.gov.in/rules-regulations-3)
- [CPCB — E-Waste (Management) Rules, 2022](https://cpcb.nic.in/uploads/Projects/E-Waste/e-waste_rules_2022.pdf)
- [MoEFCC — E-Waste (Management) Amendment Rules, 2024](https://moef.gov.in/uploads/2024/03/E-Waste%20%28Management%29%20Amendment%20Rules%2C%208th%20March%202024.pdf)
- [CPCB — E-Waste Management FAQ (2024)](https://cpcb.nic.in/uploads/Projects/E-Waste/FAQ_ewaste_23012024.pdf)
- [CERT-In — Secure Application Design, Development, Implementation and Operations Guidelines](https://www.cert-in.org.in/PDF/Application_Security_Guidelines.pdf)
- [OWASP Top 10:2025](https://top10.owasp.org/2025/)
- [MeitY — Digital Personal Data Protection Rules, 2025 and related notices](https://www.meity.gov.in/documents/act-and-policies/digital-personal-data-protection-rules-2025-gDOxUjMtQWa)
- [W3C — Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/)

