# FS Castle Town — NP2-R1B QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
NP2 | North-east Wall Segment

Original bbox: `[805,99,1217,166]`
Corrected bbox: `[805,85,1217,166]`
Corrected workcell: `412×81`
Placement: `(805,85)`

## Boundary Continuity Audit
Wall body fit the original workcell, but attached wall-top banner/props extend above y=99. Top authority expanded to y=85; no resize or horizontal movement.

## NP2-R1B
Result: **FORMAL VISUAL PASS**

Mechanical gates:
- Master-exact RGB on opaque pixels: PASS
- alpha `{0,255}`
- partial alpha `0`
- opaque pixels `16,115`
- N0A Core overlap `0 px`
- N4A overlap `0 px`
- NP3 overlap `0 px`

Visual gates:
- wall face: PASS
- crenellations: PASS
- attached purple banner: PASS
- N4A join: PASS
- NP3 join: PASS
- broad Ground leak: not observed

Working Ground vegetation/flower texture differs from Master in the recomposition comparison; this is Ground-baseline variance, not PAR displacement.

Drive assets: PAR, binary mask, checker and QA JSON stored under `Forest Symphony/08_Assets/02_Working`.
