# FS Castle Town — NP3-R2E QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
NP3 | NE Perimeter Tower

Original bbox: `[1185,57,1242,247]`
Corrected bbox: `[1185,57,1266,260]`
Corrected workcell: `81×203`
Placement: `(1185,57)`

## Boundary Continuity Audit
Original geometry failed on two sides: x=1242 cut directly through the tower body and y=247 clipped the lower tower/corner structure. Right and bottom bounds were expanded without resize or source movement.

## NP3-R2E
Result: **FORMAL VISUAL PASS**

Mechanical gates:
- Master-exact RGB on opaque pixels: PASS
- alpha `{0,255}`
- partial alpha `0`
- opaque pixels `5,088`
- N4A overlap `0 px`

Visual gates:
- roof/spire: PASS
- tower body: PASS
- window/shadow pixels remain opaque source pixels: PASS
- vegetation cleanup limited to external boundary band: PASS
- broad Ground leak: not observed

R2D was rejected because global green exclusion opened transparent holes in the tower window. R2E restores a fully opaque internal silhouette and limits vegetation cleanup to the exterior boundary only.

Drive assets: PAR, binary mask, checker and QA JSON stored under `Forest Symphony/08_Assets/02_Working`.
