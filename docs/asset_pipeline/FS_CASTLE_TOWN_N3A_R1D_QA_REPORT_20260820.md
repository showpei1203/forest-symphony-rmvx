# FS Castle Town — N3A-R1D QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N3A | North-right House

BBox: `[867,164,1020,312]`
Workcell: `153×148`
Placement: `(867,164)`

## Boundary Continuity Audit
Result: **PASS ORIGINAL BBOX**

The house has clear left/right/top margin inside the declared workcell. The lower facade terminates by global y≈311. Pixels from y=312 onward are Ground/path relation, so no bbox expansion is required.

## Extraction history
- R1: semantic carve candidate, but retained right-side prop/vegetation contamination.
- R1A/R1B: tightened house owner silhouette and removed neighboring prop cluster.
- R1C: removed green-dominant fringe.
- R1D: final x>=128 ownership cutoff removed the remaining adjacent non-house pixels while preserving the house silhouette.

## N3A-R1D result
**FORMAL VISUAL PASS**

Mechanical gates:
- Master-exact RGB on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `7,888`
- transparent pixels: `14,756`
- local alpha bbox: `[41,28,127,147]`
- no resize: PASS
- no redraw: PASS
- integer placement: PASS

Visual QA:
- roof: PASS
- house body: PASS
- front door: PASS
- left stall cluster excluded: PASS
- top tree background excluded: PASS
- right prop cluster excluded: PASS
- right neighbor fringe excluded: PASS
- broad Ground-class leak: not observed
- bottom Boundary Continuity warning cleared by outside-edge inspection

## Persistent local files
- `FS_CASTLE_TOWN_N3A_R1D_BINARY_MASK_153x148.png`
- `FS_CASTLE_TOWN_N3A_R1D_EXTRACTED_PAR_153x148.png`
- `FS_CASTLE_TOWN_N3A_R1D_CHECKER.png`
- `FS_CASTLE_TOWN_N3A_R1D_ON_GROUND_RECOMPOSED_1448x1086.png`
- `FS_CASTLE_TOWN_N3A_R1D_QA_REPORT.json`

## SHA256
- mask: `d35374a89ed5be35058f37ceb915f9c15ca1d4eeecd31d1c7a115a14eb35d7d4`
- PAR: `522080a66854f8b30dac844048a6b2f480cfcb4d4f9e666dbc7f957baecbf897`
- checker: `3ec376b0d4d43cfeeec10d679f8165ac21af6e7d09009f8cc67a4ab91c58cca9`
- recomposition: `1343f26043e3b403443e68939f04c60196fea953e2adbe60fb497ac74953f5a6`

## Next legal action
Proceed to N3B / North-right Stall-Trellis Cluster. Run v2.6 Boundary Continuity Audit before extraction.
