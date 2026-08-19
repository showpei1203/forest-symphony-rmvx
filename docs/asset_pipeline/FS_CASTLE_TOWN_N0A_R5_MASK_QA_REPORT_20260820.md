# FS Castle Town — N0A-R5 Mask Completeness + Ground-Leak QA

Date: 2026-08-20
Workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_5
Scope: N0A Main Castle Compound only

## Result
**FAIL_AUTHORITY_GEOMETRY**

N0A is **NOT Formal PASS**. N0B remains forbidden.

## Input Authority
- Master: `FS_CASTLE_TOWN_MASTER_REFERENCE_1448x1086.png`
- Working Ground: `FS_CASTLE_TOWN_GROUND_WORKING_1448x1086.png`
- R4 PAR: `FS_CASTLE_TOWN_N0A_EXTRACTED_PAR_220x275.png`
- R4 mask: `FS_CASTLE_TOWN_N0A_BINARY_MASK_220x275.png`
- R4 composite: `FS_CASTLE_TOWN_N0A_ON_GROUND_CLEAN_1448x1086.png`
- Current N0A bbox: `[600,30,820,305]`
- Current workcell: `220x275`
- Fixed placement: `(600,30)`

## R4 Mechanical Gates
- Workcell size: PASS (`220x275`)
- Resize: PASS (`false`)
- Redraw: PASS (`false`)
- Placement: PASS by construction (`600,30`)
- Opaque RGB = Master: PASS
- Alpha values: PASS (`{0,255}` only)
- Partial alpha: PASS (`0`)
- R4 opaque pixels: `39,235`
- Current alpha last opaque local row: `273` (global `303`)

## R5 Visual / Semantic Gates

### 1. Castle non-Ground structure completeness
**FAIL**

The front structural staircase continues in the Master through global `y=314` (the first pure pavement row begins after it). The current N0A workcell covers global `y=30..304` only, and the R4 mask itself has no opaque pixels on global `y=304`.

Therefore the current R4 candidate misses staircase structure from at least global `y=304..314`.

This is not repairable by mask refinement alone while keeping the current `220x275` workcell, because global rows `305..314` do not exist inside that workcell.

### 2. Ground leak (grass / road / terrain)
**VISUAL PASS WITHIN INSPECTED R4 REGION, NOT SEALED**

The current mask already excludes the large road/grass areas around the castle. Negative witness checks on left/right road and lower grass/road regions are transparent.

No broad Ground-class capture was found during R5 inspection.

### 3. Roof / tower / castle body / flag / banner clipping
- Castle body: PASS visually
- Main roof: PASS visually
- Corner/front towers: PASS visually
- Flags/banners: PASS visually
- Front stairs: **FAIL — bottom clipped**

### 4. Per-anchor semantic purity
**REFINEMENT REQUIRED**

Two small top-edge patches of unrelated green background/canopy are still included by the R4 mask above/behind the rear wall. These are not Ground leakage, but they do not belong to the N0A castle asset and should be removed so later tree/background PAR owners cannot double-own those pixels.

## Hard Contradiction Found
R5 requires both:
1. all structural stairs to be complete; and
2. no resize/move of the current `220x275` workcell.

The Master proves the stair structure extends below the workcell boundary. Both conditions cannot be satisfied simultaneously.

This means the defect is now an **Anchor / Workcell Geometry Authority defect**, not merely a mask defect.

## Required Remediation Before N0A Can Pass
Create a geometry-correction step before another extraction candidate:

- keep origin / placement fixed at `(600,30)`;
- keep width `220`;
- extend bottom boundary from global `y=305` to `y=315`;
- corrected N0A bbox candidate: `[600,30,820,315]`;
- corrected workcell candidate: `220x285`;
- no scaling;
- no movement;
- no redraw;
- re-extract source RGB directly from Master;
- use binary alpha only;
- remove the two unrelated top background/canopy patches;
- rerun completeness / Ground-leak QA.

This is an Authority geometry correction, not a generative-layout exception.

## Next Legal Step
**N0A-R5A Anchor / Workcell Geometry Correction only.**

Do not start N0B until corrected N0A obtains Formal PASS.
