# FS Castle Town — NORTH South Guard-Band QA R2

Date: 2026-08-20
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7 + historical Step3C North `y>420` transparency gate

## Result
**PASS — no discrete North-local PAR residual in global y=350..420.**

## Correction
The earlier final report's wording `SOUTH seam = y=350` was too strong and is superseded. `y=350` is only a working review line, not the original North Authority boundary. The historically sourced hard gate is: **North must not add ownership below y=420.**

## Guard-band rule
- Ground-class road / floor / grass / flowers / water remains Ground.
- A PAR-class object that terminates fully inside y=350..420 would still belong to North and must be extracted.
- A visible structure that continues through/below y=420 is kept intact for the lower sibling zone. It is not split merely to make the North comparison look closer.

## Findings
- West: visible houses/roofs/trees in the guard band continue through/below y=420. Sibling-owned continuation.
- Center: large purple-roof building crosses y=420. Sibling-owned intact. Remaining differences are Ground circulation/vegetation.
- East: blue-roof/lower complex crosses y=420. Sibling-owned intact. Remaining differences are Ground garden/road/vegetation.
- Discrete North-local PAR residuals wholly contained in y=350..420: **0**.

## Fresh North mechanical authority retained
- current Formal PAR assets: 24
- independently re-solved Master-exact placements
- pairwise combinations: 276
- nonzero overlap pairs: 0
- multi-owned pixels: 0
- max owner count: 1
- union opaque pixels: 251,222

## Final North status
With the fresh 24-asset audit plus this guard-band correction, **NORTH remains FORMAL PASS**, but without claiming y=350 is the semantic south seam.

Persistent evidence:
- `FS_CASTLE_TOWN_NORTH_GUARD_BAND_350_420_EVIDENCE.png`
- `FS_CASTLE_TOWN_NORTH_GUARD_BAND_350_420_QA_REPORT.json`

This R2 report supersedes the boundary wording in `FS_CASTLE_TOWN_NORTH_ZONE_FINAL_QA_20260820.md`.
