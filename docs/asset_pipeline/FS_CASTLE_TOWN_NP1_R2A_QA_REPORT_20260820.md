# FS Castle Town — NP1-R2A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Anchor
NP1 | North-west Back Wall Segment

Supersedes: NP1-R1G.

Corrected bbox: `[285,85,608,201]`
Workcell: `323×116`
Placement: `(285,85)`

## Completeness correction
The previous NP1 version correctly owned the upper horizontal wall but left the lower west back-wall face unowned. Master/recomposition QA showed Ground grass where visible dark stone wall should exist.

R2A preserves all NP1-R1G pixels and adds only three visible lower-wall intervals from global y=160 through y=199:

- `[315,160,420,200]`
- `[445,160,545,200]`
- `[565,160,585,200]`

Actual vertical floor/path openings remain Ground:

- `[420,160,445,200]`
- `[545,160,565,200]`
- `[585,160,608,200]`

N1A, N2A, NR1 and NP0 foreground ownership is subtracted exactly.

## Formal result
**FORMAL VISUAL AND MECHANICAL PASS**

Mechanical gates:
- source RGB Master-exact: PASS
- alpha values: `{0,255}`
- partial alpha: `0`
- opaque pixels: `18,637`
- transparent pixels: `18,831`
- local alpha bbox: `[22,5,322,114]`
- top/bottom Boundary Continuity: PASS
- left: PASS after NP0 subtraction
- right: legal owner seam toward central/right-side structure

## Completeness proof
- lower extension geometry tested: `9,000 px`
- Master vs NP1-R2A context recomposition diff inside that geometry: **0 px**

## Aggregate revalidation
Replacing NP1-R1G with NP1-R2A in the current North 21-asset set yields:
- assets: `21`
- pairwise checks: `210`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count: `1`
- union opaque pixels: `245,287`

No resize, redraw, or Ground movement was used.

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NP1_R2A_EXTRACTED_PAR_323x116.png`
- `FS_CASTLE_TOWN_NP1_R2A_BINARY_MASK_323x116.png`
- `FS_CASTLE_TOWN_NP1_R2A_CHECKER.png`
- `FS_CASTLE_TOWN_NP1_R2A_QA_REPORT.json`
