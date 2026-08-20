# FS Castle Town — NR2-R2 QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Anchor
NR2 | NW Service Props Cluster

Initial residual sweep region: `[420,235,500,320]`
Final safe bbox: `[430,235,482,323]`
Workcell: `52×88`
Placement: `(430,235)`

## Boundary Continuity Audit
Result: **PASS**

Final opaque local bbox: `[7,5,49,84]`.
No meaningful opaque structure touches any workcell edge.

## Extraction
Result: **FORMAL VISUAL PASS**

Method:
- multi-seed semantic GrabCut for service props;
- vegetation/grass exclusion outside object zones;
- accepted-owner subtraction;
- Master-only source pixels; no resize/redraw.

Mechanical gates:
- Master-exact RGB on every opaque pixel: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `2,135`
- transparent pixels: `2,441`

Visual QA:
- upper container/basket: PASS
- five light sacks/containers: PASS
- wooden frame/posts: PASS
- grass between props: transparent / Ground
- flower / Ground decoration remains Ground
- broad Ground leak: not observed

## Ownership checkpoint after NR2
- accepted PAR assets: `15`
- pairwise combinations checked: `105`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owners per pixel: `1`
- union opaque pixels: `126,877`

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NR2_R2_EXTRACTED_PAR_52x88.png`
- `FS_CASTLE_TOWN_NR2_R2_BINARY_MASK_52x88.png`
- `FS_CASTLE_TOWN_NR2_R2_CHECKER.png`
- `FS_CASTLE_TOWN_NR2_R2_QA_REPORT.json`

Next residual anchor: `NR3 / NE Inner Canopy / Shrub Residuals`.
