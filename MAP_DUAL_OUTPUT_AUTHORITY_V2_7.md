# Shared Map Layered Generation Authority v2.7

Effective: 2026-08-20
Scope: Forest Symphony / PMD AutoChess Proto / CG Pet Battle Prototype

This extends v2.6. All v2.6 source-asset, deterministic-placement, pixel-crisp, alpha-purity, Master-exact and Boundary Continuity rules remain active.

## 1. Zero overlap is necessary but not sufficient
A region may not be declared complete merely because all declared PAR anchors have disjoint ownership.

After all declared structural anchors pass, the workflow MUST run a Residual PAR Completeness Sweep against the Master/reference composition.

The region is only complete when both are true:
1. `multi_owned_pixels = 0` across all accepted PAR assets;
2. no visible non-Ground / PAR-class object remains unowned.

A zero-overlap assembly with missing trees, canopies, barrels, stools, signs, structural props or other non-Ground objects is `STRUCTURAL_OWNERSHIP_PASS / PAR_COMPLETENESS_FAIL`, not Formal Zone PASS.

## 2. Residual PAR Completeness Sweep
After aggregate recomposition:
- compare Master/reference against `Ground + all accepted PAR` at exact integer placement;
- inspect residual visible objects by region;
- classify each residual as either:
  - `PAR_RESIDUAL`: must receive a new anchor/owner, or
  - `GROUND_CONFIRMED`: explicitly legal Ground by Authority;
- create residual anchors for every confirmed PAR residual;
- repeat aggregate overlap + recomposition QA after residual anchors are added.

Residual detection is semantic, not raw RGB-difference alone. Working Ground may legitimately differ from Master in texture, flowers, grass or generated surface detail. Only residual objects that are legally PAR-class require ownership.

## 3. Dependency invalidation after bbox / owner changes
Any accepted anchor whose bbox, mask, or ownership changes invalidates previous overlap certificates for every geometrically intersecting neighbor.

Required response:
1. identify potentially intersecting accepted anchors;
2. rerun exact pixel ownership overlap for those neighbors;
3. if overlap exists, modify only the lower-priority / enclosing owner according to the declared ownership contract;
4. rerun aggregate pairwise audit before zone PASS.

Do not rely on an older `0 px overlap` result after a neighboring anchor changes.

Castle Town evidence: N1A was corrected from `[310,164,440,315]` to `[310,154,440,330]` after Boundary Continuity Audit found both a clipped spire and clipped front stairs. That correction created 32 px overlap with previously accepted NP1. NP1 was therefore revised from R1F to R1G by subtracting exactly those 32 N1A-owned pixels, restoring `0 px` overlap.

## 4. Aggregate ownership gate
Before a zone may enter residual completeness acceptance:
- enumerate every accepted PAR asset and exact global origin;
- compute all pairwise opaque-pixel intersections;
- require every pair to equal `0 px` unless an explicit parent/child contract states otherwise and the assembled final files are already disjoint;
- compute owner-count heatmap;
- require `max_owners_per_pixel = 1` and `multi_owned_pixels = 0`.

## 5. Castle Town NORTH evidence
The first NORTH aggregate contains 13 accepted structural PAR assets:
`N0A Core, N0B, N1A, N2A, N3A, N3B, N4A, N4B, N4C, NP0, NP1, NP2, NP3`.

Aggregate mechanical result:
- asset count: `13`
- pairwise combinations checked: `78`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owners per pixel: `1`
- union opaque pixels: `120,777`

Status: `STRUCTURAL_OWNERSHIP_PASS / PAR_COMPLETENESS_NOT_YET_PASS`.

Visible residual PAR-class objects remain, including tree/canopy clusters, shrubs that are not Ground grass/flowers, barrels/stools/service props and small structural/decor props.

Initial residual regions:
- `NR1` NW Inner Canopy Cluster `[385,140,530,250]`
- `NR2` NW Service Props Cluster `[420,235,500,320]`
- `NR3` NE Inner Canopy / Shrub Residuals `[930,140,1040,255]`
- `NR4` NE Garden Canopy / Shrub Residuals `[1120,140,1210,265]`
- `NR5` North Exterior Canopy Sweep `[230,20,1300,145]`

These are residual-search regions, not automatically final bboxes. Each must run v2.6 Boundary Continuity Audit before its own final anchor geometry is accepted.

## 6. Required order v2.7
`Ground -> Anchor Contract -> Boundary Continuity Audit -> corrected bbox if required -> semantic/mask extraction -> alpha/purity QA -> deterministic placement -> local recomposition QA -> dependency revalidation -> aggregate pairwise ownership audit -> aggregate recomposition -> Residual PAR Completeness Sweep -> residual anchors -> repeat aggregate QA -> Zone Formal PASS`

## 7. Zone PASS rule
A zone is Formal PASS only when:
- every accepted PAR pixel is Master-exact unless an explicitly generated replacement asset is governed by a separate generation contract;
- alpha purity passes;
- exact integer placement passes;
- all accepted PAR ownership is disjoint;
- Boundary Continuity has no unresolved warning;
- residual completeness sweep finds no unowned PAR-class object;
- all remaining visible residuals are explicitly Ground-confirmed.

`No overlap` proves ownership consistency. `No unowned PAR residual` proves completeness. Both are mandatory.
