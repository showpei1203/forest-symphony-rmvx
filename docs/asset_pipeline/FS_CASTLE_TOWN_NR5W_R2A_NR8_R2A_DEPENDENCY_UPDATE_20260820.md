# FS Castle Town — NR5W-R2A + NR8-R2A Dependency Update

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## NR5W-R2A — North-West Exterior Canopy

Predecessor: NR5W-R1A
BBox remains `[230,0,480,145]`, workcell `250×145`, placement `(230,0)`.

Residual completeness audit found the NW zone-seam conifer under-segmented inside the existing bbox. A dark-canopy topology candidate was reduced to a legal canopy-only addition.

Formal result: **PASS**
- old opaque: `21,932`
- added canopy: `885`
- final opaque: `22,817`
- Master-exact RGB: PASS
- alpha `{0,255}`
- partial alpha: `0`
- added 885 pixels: pre-recompose Master mismatch `885/885`; post-recompose mismatch `0/885`
- right/bottom natural termination
- top touch = legal map edge
- left touch = legal NORTH/WEST sibling seam
- added global x range is `230..266`; NP0 begins at `x=267`, so no new inter-owner collision is possible by geometry.

## NR8-R2A dependency correction

NR8-R1 was found to clip the upper white spiral/sign head of the right-side service prop. Corrected NR8 bbox is `[889,195,1011,315]`, workcell `122×120`.

The visible foreground sign requires ownership transfers from background assets:
- N3A -> NR8: `4 px`
- NR3 -> NR8: `35 px`
- NP2 -> NR8: `1 px`

Latest local dependency revisions after these transfers:
- N3A-R2C
- NR3-R1C
- NP2-R3E
- NR8-R2A

Post-transfer changed-owner overlap: `0`.

## Fresh aggregate policy

All completeness QA must use `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png` as the clean Ground base and recompose from current Formal PAR outputs. `FS_CASTLE_TOWN_N0A_ON_GROUND_CLEAN_1448x1086.png` is diagnostic/history only because it already contains baked PAR content.

## Residual classification note

A classifier candidate around the east-lower horizontal structure was reviewed and rejected as a North residual: it is the upper roof/edge of a building that continues into the future SOUTH/EAST sibling zone. Do not create a North residual anchor for that partial structure.
