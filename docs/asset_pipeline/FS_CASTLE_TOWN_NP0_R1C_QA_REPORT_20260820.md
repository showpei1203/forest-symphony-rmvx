# FS Castle Town — NP0-R1C QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
NP0 | NW Perimeter Tower

Original bbox: `[267,59,317,246]`
Corrected bbox: `[267,59,317,260]`
Corrected workcell: `50×201`
Placement: `(267,59)`

## Boundary Continuity Audit
Original geometry failed: the vertical tower/corner structure was still continuing at the original bottom boundary y=246. Master inspection shows the structure completing around y=258, so bottom authority was extended to y=260. No resize or global movement was used.

## R1C extraction
Result: **FORMAL VISUAL PASS**

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial alpha: `0`
- opaque pixels: `4,837`
- transparent pixels: `5,213`
- local alpha bbox: `[7,34,45,200]`
- no resize/redraw: PASS

Visual QA:
- purple perimeter-tower roof: PASS
- tower body: PASS
- lower corner structure: PASS
- left vegetation / water contamination: removed
- adjacent right-side roof: excluded
- broad Ground leak: not observed

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NP0_R1C_EXTRACTED_PAR_50x201.png`
- `FS_CASTLE_TOWN_NP0_R1C_BINARY_MASK_50x201.png`
- `FS_CASTLE_TOWN_NP0_R1C_CHECKER.png`
- `FS_CASTLE_TOWN_NP0_R1C_QA_REPORT.json`

Next north anchor: NP1 North-west Wall Segment `[285,99,608,166]`, starting with v2.6 Boundary Continuity Audit.
