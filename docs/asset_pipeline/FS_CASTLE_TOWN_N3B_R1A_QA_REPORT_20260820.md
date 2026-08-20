# FS Castle Town — N3B-R1A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N3B | North-right Stall / Trellis Cluster

Original bbox: `[831,169,879,231]`

## Boundary Continuity / Placement Audit
Result: **ORIGINAL ANCHOR FAIL — POSITION + WIDTH**

The original bbox captured a large portion of the left-side path while clipping the right half of the trellis/stall structure.

Master-grid inspection places the visible trellis/stall structure approximately at:
`x=865..895`, `y=176..224`.

Corrected bbox with safety margin:
`[864,175,897,229]`

Corrected workcell: `33×54`
Placement: `(864,175)`
No resize, redraw or Ground movement.

## Structure mask
Because this object is an open trellis, its Ground-class grass openings must remain transparent. A full-object opaque silhouette would be incorrect.

Method:
- Master-exact source pixels;
- structure-color + geometry mask;
- red/brown/cream wood retained;
- green Ground-class pixels inside/opening around the frame excluded;
- dark structural beams retained;
- alpha restricted to binary `0/255`.

## N3B-R1A result
**FORMAL VISUAL PASS**

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `1,355`
- transparent pixels: `427`
- local alpha bbox: `[1,1,31,49]`
- no resize: PASS
- no redraw: PASS
- integer placement: PASS

Visual QA:
- upper red trellis panels: PASS
- cream vertical slats: PASS
- dark wood beams: PASS
- bottom wood frame: PASS
- green Ground visible through frame: transparent as required
- left path excluded: PASS
- original right-side clipping corrected: PASS
- broad Ground leak: not observed

## Persistent local files
- `FS_CASTLE_TOWN_N3B_R1A_BINARY_MASK_33x54.png`
- `FS_CASTLE_TOWN_N3B_R1A_EXTRACTED_PAR_33x54.png`
- `FS_CASTLE_TOWN_N3B_R1A_CHECKER.png`
- `FS_CASTLE_TOWN_N3B_R1A_ON_GROUND_RECOMPOSED_1448x1086.png`
- `FS_CASTLE_TOWN_N3B_R1A_QA_REPORT.json`

## SHA256
- mask: `c0cd347d202a907c92caa0d62b7270241134926d3c0ceb3b29a36741e223d460`
- PAR: `4270f3f4a411380c939d09118200692dfaea1d696af330f067e64dac49d14313`
- checker: `e6afeca26c49fca4aa1d1da3290eaf2f9da87909c34fd04295bebad988cfa7ec`
- recomposition: `c677d6914009c7fbb24631ebec9bfb8c16150f8b0069621c6614aeeb4a693d01`

## Next legal action
Proceed to N4A / NE Inner Wall Tower-Stair Tower. Run v2.6 Boundary Continuity Audit before extraction.
