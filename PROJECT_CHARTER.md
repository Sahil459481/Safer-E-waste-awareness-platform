# Project Charter

## Data-Driven E-Waste Awareness and Management Platform

### Purpose
Create a small, evidence-informed resource that helps the college community understand e-waste and find safer, formal disposal pathways. The pilot combines India-wide official data context with practical Maharashtra facility information.

### Pilot audience and expansion
- Initial pilot: students, campus visitors, and campus staff at the user's college.
- Later expansion: the general public across age groups, after the campus version has been reviewed and improved.
- Data context: selected India-wide e-waste indicators, with source, reporting period, units, and definitions shown.
- Local directory: a limited Maharashtra pilot. Publish a facility only after checking it against current official MPCB or CPCB material and recording the check date.

### Objectives
1. Explain official e-waste indicators without conflating generation estimates with amounts reported as collected or recycled.
2. Provide plain-language guidance that points people toward formal take-back and authorised channels.
3. Help users identify a candidate facility while clearly asking them to confirm acceptance before visiting.
4. Evaluate whether users can identify a safe next step and understand key disposal information.

### Data views requested
The desired dashboard measures are:
- E-waste generated.
- E-waste reported as collected.
- E-waste reported as recycled.

The desired drill-down path is country → state → district → facility. This is a target for investigation, not yet a confirmed property of the official datasets. Before designing the dashboard around it, the team must check which measures are available at each geographic level, how each measure is defined, and whether records can be reliably assigned to districts and facilities. Where data are unavailable or incomparable, the app should say so rather than estimate or imply a complete breakdown.

### Out of scope
The project will not collect, store, transport, dismantle, repair, or certify devices or recyclers; guarantee facility hours or acceptance; provide hazardous-waste handling instructions; or claim that the pilot caused actual recycling or waste diversion. No predictive model is planned.

### Survey handling
If an optional, voluntary survey is conducted, it will avoid direct identifiers and report results only in aggregate. The planned retention period for raw responses is until the main version is presented; the team should confirm the deletion process and exact presentation milestone with its supervisor before collecting responses.

### Initial success measures
- Each published data value has a source URL, reporting period, unit, definition, and geographic level.
- Each published facility has an official source and a recorded last-checked date; ambiguous records are excluded.
- Outreach reach and usability feedback are reported with their measurement method and sample size.
- Survey findings describe respondents only and are not presented as representative of all students or the public.
- The raw survey response file is deleted at the agreed presentation milestone.

### Decisions recorded
- Pilot audience: students and campus staff at the user's college initially; general public of all ages in a later expansion.
- Measures: generated, reported collected, and recycled e-waste.
- Desired drill-down: country to state to district to facility, subject to source-data availability and comparability.
- Survey response retention: until the main version is presented, then delete raw responses as agreed with the supervisor.

### Data availability check (12 November 2026)
An initial review of official sources shows that one complete country → state → district → facility drill-down is not supported for all three measures:

| Measure / level | What the reviewed official sources provide | Implication for the dashboard |
|---|---|---|
| Generated — country | CPCB generation estimates for FY 2023–24 and FY 2024–25. The release says these are estimated nationally from registered-producer sales and average product life. | Show national annual estimates with their method and caveat. |
| Generated — state, district, facility | No corresponding state, district, or facility generation breakdown in the reviewed release. | Do not allocate national generation down to lower levels. |
| Collected — country | The release reports one combined percentage for e-waste “collected, dismantled and recycled / disposed” (61.94% and 70.71% for the two years), rather than separate collected tonnage. | Label this exactly as the combined official measure; do not call it a collection-only rate. |
| Collected — state, district, facility | No matching breakdown in the reviewed release. | No drill-down for this measure unless a suitable official source is found. |
| Processed — state | The same release provides state-wise e-waste processed quantities from annual reports received from registered recyclers for FY 2023–24 and FY 2024–25, covering 19 states. Maharashtra is listed as 40,664.231 MT and 52,597.803 MT respectively. | A state comparison is possible, but use the source's term “processed”; it is not a district or facility throughput table. |
| Facilities — Maharashtra | MPCB links an authorised-facility list with names, addresses, facility type, capacity, authorization information, and contact fields. The linked PDF is titled March 2024. | A facility directory can be organized by state and parsed to district from addresses, but this is location filtering, not district-level waste quantities. The list must be rechecked before publication because the linked copy is dated. |

**Revised design implication:** use measure-specific navigation. National generation and the combined management percentage can be shown at country level; reported processed quantities can be compared by state; the Maharashtra facility directory can filter facility records by district. Do not present all three as one continuous quantitative drill-down, and do not imply facility-level processed tonnage from facility capacity or authorization records.

**Sources reviewed:** [PIB / Ministry of Environment, Forest and Climate Change parliamentary reply, 24 July 2025](https://www.pib.gov.in/PressReleseDetailm.aspx?PRID=2147876) and [MPCB Electronic Waste page](https://www.mpcb.gov.in/en/node/4297), which links the [March 2024 authorised facility list](https://www.mpcb.gov.in/sites/default/files/Establishment%20of%20MPCB/Seniority%20list/2014/Authorised_E-Waste_Recyclers_%26_Refurbishers-March-2024.pdf).

### Data refresh decision
Use a scheduled source check with human review before publishing changes. The dashboard will read a dated, source-linked dataset. A scheduled check may identify new official releases or facility lists, but it will not publish extracted values automatically. A team member will verify the source, reporting period, units, definitions, and geographic level, then approve the updated dataset. The dashboard will show the reporting period and last-checked date. If a check fails or the available source is old, retain the last verified data and label its age clearly.
