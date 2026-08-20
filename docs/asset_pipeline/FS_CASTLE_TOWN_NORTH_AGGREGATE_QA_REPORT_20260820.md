# FS Castle Town — NORTH Aggregate QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Structural ownership result
Accepted structural PAR assets: 13

`N0A Core, N0B, N1A, N2A, N3A, N3B, N4A, N4B, N4C, NP0, NP1, NP2, NP3`

Mechanical aggregate gates:
- pairwise combinations checked: `78`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owner count per pixel: `1`
- union opaque pixels: `120,777`

Result: **STRUCTURAL_OWNERSHIP_PASS**

## Important dependency correction
N1A was re-audited before aggregate acceptance because its earlier R1A had never received Formal PASS. Boundary Continuity found the original N1A bbox `[310,164,440,315]` clipped both the upper gold spire and lower entrance stairs. Final N1A-R3A uses `[310,154,440,330]`.

This geometry correction invalidated the earlier NP1 overlap result and exposed `32 px` overlap. NP1 was revised from R1F to R1G by subtracting exactly those N1A-owned pixels. Final N1A/NP1 overlap is `0 px`.

## Aggregate recomposition
Declared-anchor recomposition passes for placement/ownership. However, Master vs recomposition still contains visible non-Ground objects with no declared PAR owner.

Observed residual classes:
- tree/canopy clusters;
- shrubs/bushes that are not Ground grass/flowers;
- barrels/stools/service props;
- small structural/decor props.

Therefore current NORTH status is:

**`STRUCTURAL_OWNERSHIP_PASS / PAR_COMPLETENESS_NOT_YET_PASS`**

This is not Zone Formal PASS.

## Initial Residual PAR regions
- `NR1` NW Inner Canopy Cluster `[385,140,530,250]`
- `NR2` NW Service Props Cluster `[420,235,500,320]`
- `NR3` NE Inner Canopy / Shrub Residuals `[930,140,1040,255]`
- `NR4` NE Garden Canopy / Shrub Residuals `[1120,140,1210,265]`
- `NR5` North Exterior Canopy Sweep `[230,20,1300,145]`

These are sweep regions, not guaranteed final anchor bboxes. Each must pass v2.6 Boundary Continuity before final geometry is accepted.

## Next legal action
Start `NR1`, assign every confirmed NW inner non-Ground residual to deterministic PAR ownership, then rerun aggregate pairwise + recomposition QA.
