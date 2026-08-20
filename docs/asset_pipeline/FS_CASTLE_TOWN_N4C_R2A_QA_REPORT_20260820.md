# FS Castle Town — N4C-R2A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N4C | NE Small Tower House

Original bbox: `[1174,229,1238,333]`
Corrected bbox: `[1174,229,1238,353]`
Corrected workcell: `64×124`
Placement: `(1174,229)`

## Boundary Continuity Audit
Result: **ORIGINAL GEOMETRY FAIL**.

The original bottom y=333 clipped the lower tower-house/door structure. Master evidence shows the building body continues to approximately global y=350. Bottom authority was extended to y=353; x/y placement and source scale were not changed.

## R2A extraction
Result: **FORMAL VISUAL PASS**

Method:
- Master-exact source pixels;
- semantic carve to recover roof/body;
- deterministic owner-silhouette clipping to remove surrounding vegetation/wall contamination;
- binary structural alpha.

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `3,336`
- transparent pixels: `4,600`
- local alpha bbox: `[12,24,53,123]`
- no resize/redraw: PASS
- N4B overlap: `0 px`

Visual QA:
- roof: PASS
- tower-house body: PASS
- upper window: PASS
- front door: PASS
- lower structural edge: PASS
- vegetation contamination removed: PASS
- broad Ground leak: not observed

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_N4C_R2A_EXTRACTED_PAR_64x124.png`
- `FS_CASTLE_TOWN_N4C_R2A_BINARY_MASK_64x124.png`
- `FS_CASTLE_TOWN_N4C_R2A_CHECKER.png`
- `FS_CASTLE_TOWN_N4C_R2A_QA_REPORT.json`

## Next North anchors
Remaining contract anchors after N4C: NP0, NP1, NP2, NP3. Start NP0 with v2.6 Boundary Continuity Audit.
