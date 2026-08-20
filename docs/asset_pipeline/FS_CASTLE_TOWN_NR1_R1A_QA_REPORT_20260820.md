# FS Castle Town — NR1-R1A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Anchor
NR1 | NW Inner Canopy Cluster

Initial residual sweep region: `[385,140,530,250]`
Final safe bbox: `[420,140,540,260]`
Workcell: `120×120`
Placement: `(420,140)`

The larger sweep region was intentionally reduced to a safe residual-object workcell after inspecting neighboring N1A/N2A/NP1 ownership. The final workcell has visible safety margin on every side.

## Boundary Continuity Audit
Result: **PASS**

Final opaque local bbox: `[27,22,114,97]`.
No meaningful opaque structure touches left/top/right/bottom workcell edges.

## Extraction
Result: **FORMAL VISUAL PASS**

Method:
- semantic GrabCut canopy carve from Master;
- exact subtraction of all 13 previously accepted NORTH owners;
- targeted removal of purple roof-contact color components touching N2A ownership;
- no resize or redraw.

Mechanical gates:
- Master-exact RGB on every opaque pixel: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `3,965`
- transparent pixels: `10,435`

Visual QA:
- canopy cluster: PASS
- path / grass Ground: excluded
- N2A roof-contact fragments: excluded
- broad Ground leak: not observed

## Ownership checkpoint after NR1
- accepted PAR assets: `14`
- pairwise combinations checked: `91`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owners per pixel: `1`
- union opaque pixels: `124,742`

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NR1_R1A_EXTRACTED_PAR_120x120.png`
- `FS_CASTLE_TOWN_NR1_R1A_BINARY_MASK_120x120.png`
- `FS_CASTLE_TOWN_NR1_R1A_CHECKER.png`
- `FS_CASTLE_TOWN_NR1_R1A_QA_REPORT.json`

Next residual anchor: `NR2 / NW Service Props Cluster`.
