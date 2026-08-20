# FS Castle Town — NP1-R1F QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
NP1 | North-west Wall Segment

Original bbox: `[285,99,608,166]`
Corrected bbox: `[285,85,608,166]`
Corrected workcell: `323×81`
Placement: `(285,85)`

## Boundary Continuity Audit
The wall body fit the original bbox, but attached wall-top structures did not: the small stone post and purple banners extend above y=99. Top authority was extended to y=85. No resize or global movement was used.

## R1F extraction
Result: **FORMAL VISUAL PASS**

Method:
- deterministic wall core band;
- connected-crenellation topology grown from wall body;
- explicit attached-prop windows for stone post and purple banners;
- vegetation/water and blue-gray background exclusions;
- exact NP0 ownership subtraction.

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial alpha: `0`
- opaque pixels: `14,101`
- transparent pixels: `12,062`
- local alpha bbox: `[22,5,322,80]`
- no resize/redraw: PASS
- overlap with NP0 / N0A / N1A / N2A: `0 px` each

Visual QA:
- wall body: PASS
- crenellations: PASS
- small wall-top stone post: PASS
- attached purple banners: PASS
- Ground water: excluded
- blue-gray/background fragments: removed
- broad Ground leak: not observed

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NP1_R1F_EXTRACTED_PAR_323x81.png`
- `FS_CASTLE_TOWN_NP1_R1F_BINARY_MASK_323x81.png`
- `FS_CASTLE_TOWN_NP1_R1F_CHECKER.png`
- `FS_CASTLE_TOWN_NP1_R1F_QA_REPORT.json`

Next north anchor: NP2 North-east Wall Segment `[805,99,1217,166]`.
