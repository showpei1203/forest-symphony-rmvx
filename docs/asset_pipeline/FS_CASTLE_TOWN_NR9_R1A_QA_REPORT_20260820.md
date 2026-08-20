# FS Castle Town — NR9-R1A QA Report

Date: 2026-08-20
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7
Branch workflow: SHO-39

## Anchor
NR9 | West-Central Horizontal Wood Rail / Sign Prop

Final bbox: `[572,309,634,342]`
Workcell: `62×33`
Placement: `(572,309)`

## Residual completeness finding
Fresh Master-vs-recomposition QA showed a complete horizontal wooden sign/rail structure missing from PAR while flowers and grass remained present in Ground.

## R1A extraction
Result: **FORMAL PASS**

Ownership:
- PAR: main horizontal wood sign/rail body and center support post
- Ground: surrounding grass and purple flowers beneath the structure

Mechanical gates:
- opaque pixels: `820`
- local alpha bbox: `[4,6,57,30]`
- workcell edge touches: none
- Master-exact RGB: PASS
- alpha `{0,255}`
- partial alpha: `0`
- overlap with prior 23 accepted assets: `0 px`
- all 820 owned pixels differed from Master before insertion
- owned-pixel diff after insertion: `0 px`

Aggregate after NR9:
- assets: `24`
- pairwise checks: `276`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- union opaque: `250,141 px`

No resize, redraw or Ground movement.
