# FS Castle Town — NR3-R1A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Anchor
NR3 | NE Inner Canopy + Fence Residual

Initial sweep region: `[930,140,1040,255]`
Boundary correction: the initial sweep missed the left continuation of the same canopy row.
Final bbox: `[865,145,1005,235]`
Workcell: `140×90`
Placement: `(865,145)`

## Boundary Continuity Audit
Result: **PASS** after leftward correction.

Final opaque local bbox: `[9,15,136,74]`.
No meaningful opaque structure touches any workcell edge.

## Extraction
Result: **FORMAL VISUAL PASS**

The canopy row and its attached inner wooden fence are treated as one residual ownership group because they are spatially interlocked in the flattened Master. This avoids unnecessary sub-anchor fragmentation while preserving exact pixel ownership.

Method:
- semantic canopy/fence carve;
- exact subtraction of already accepted house/tower owners;
- isolated-component cleanup;
- Master-only source pixels; no resize/redraw.

Mechanical gates:
- Master-exact RGB on every opaque pixel: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `3,779`
- transparent pixels: `8,821`
- isolated Ground fragment removed from R1: `34 px`

## Ownership checkpoint after NR3
- accepted PAR assets: `16`
- pairwise combinations checked: `120`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owners per pixel: `1`
- union opaque pixels: `130,656`

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NR3_R1A_EXTRACTED_PAR_140x90.png`
- `FS_CASTLE_TOWN_NR3_R1A_BINARY_MASK_140x90.png`
- `FS_CASTLE_TOWN_NR3_R1A_CHECKER.png`
- `FS_CASTLE_TOWN_NR3_R1A_QA_REPORT.json`

Next residual anchor: `NR4 / NE Garden Canopy / Shrub Residuals`.
