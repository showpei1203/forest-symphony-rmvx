# FS Castle Town — NP1-R1G QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
NP1 | North-west Wall Segment

Base: NP1-R1F at corrected bbox `[285,85,608,166]`.

## R1G ownership correction
Corrected N1A-R3A extends into NP1 height range. Pairwise audit found 32 overlapping opaque pixels between old NP1-R1F and corrected N1A-R3A.

R1G is derived by exact subtraction of N1A-R3A ownership from NP1-R1F only.

Result: **FORMAL VISUAL PASS**

- removed pixels: `32`
- N1A overlap after correction: `0 px`
- alpha `{0,255}`
- partial alpha `0`
- opaque pixels `14,069`
- wall body: unchanged outside 32-pixel ownership patch
- wall-top props: unchanged
- no resize/redraw/global movement

Drive assets: R1G PAR, binary mask, checker and QA JSON stored under `Forest Symphony/08_Assets/02_Working`.
