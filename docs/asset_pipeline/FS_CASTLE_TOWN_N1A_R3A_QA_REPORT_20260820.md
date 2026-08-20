# FS Castle Town — N1A-R3A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N1A | NW Chapel Plot

Original bbox: `[310,164,440,315]`
Corrected bbox: `[310,154,440,330]`
Corrected workcell: `130×176`
Placement: `(310,154)`

## Boundary Continuity Audit
Original geometry failed on both vertical sides of the workcell: the gold spire begins around global y=157, above the old y=164 top, while the front-step structure continues through about y=329, below the old y=315 bottom. Corrected top/bottom were expanded without resize or horizontal movement.

## N1A-R3A
Result: **FORMAL VISUAL PASS**

Mechanical gates:
- Master-exact RGB on opaque pixels: PASS
- alpha `{0,255}`
- partial alpha `0`
- opaque pixels `8,877`
- workcell `130×176`
- no resize/redraw

Visual gates:
- gold spire: PASS
- dome: PASS
- roof panels: PASS
- chapel body: PASS
- front door: PASS
- front steps: PASS
- broad Ground leak: not observed

Ownership consequence: corrected spire overlaps old NP1-R1F by 32 px. NP1 must advance to R1G by exact N1A subtraction before aggregate QA.

Drive assets: PAR, binary mask, checker and QA JSON stored under `Forest Symphony/08_Assets/02_Working`.
