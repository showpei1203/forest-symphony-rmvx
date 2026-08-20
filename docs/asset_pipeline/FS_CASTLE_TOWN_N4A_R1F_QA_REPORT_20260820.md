# FS Castle Town — N4A-R1F QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N4A | NE Inner Wall Tower / Stair Tower

Original bbox: `[1017,64,1076,280]`

## Boundary Continuity Audit
Result: **ORIGINAL LEFT EDGE FAIL -> CORRECTED PASS**

Master inspection showed the left roof overhang extending approximately 1–3 px beyond the original `x=1017` boundary. Top/right/bottom boundaries had sufficient margin.

Corrected bbox: `[1013,64,1076,280]`
Corrected workcell: `63×216`
Placement remains `(1013,64)`.
No resize, redraw or Ground movement was used.

## Extraction / cleanup history
- R1: semantic carve found tower/stairs but carried cliff/vegetation/grass background.
- R1A–R1E: geometry-owner cleanup progressively isolated roof, tower body, banner, landing and structural staircase.
- R1F: final lower-right ownership cleanup. Local `x>=39, y>=165` was removed after coordinate-grid inspection proved the true stair right rail is the gold vertical structure at local `x≈38`; the removed region contained neighboring Ground/prop fragments.

R1F removed exactly `57` pixels versus R1E, restricted to local x=`39..47`, y=`165..174`.

## N4A-R1F result
**FORMAL VISUAL PASS**

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `5,269`
- transparent pixels: `8,339`
- local alpha bbox: `[5,34,52,187]`
- no resize: PASS
- no redraw: PASS
- integer placement: PASS

Visual QA:
- roof silhouette: PASS
- tower body: PASS
- banner: PASS
- landing: PASS
- staircase: PASS
- left stair rail: PASS
- right stair rail: PASS
- cliff/background vegetation excluded: PASS
- lower-right neighboring fragments excluded: PASS
- broad Ground-class leak: not observed

## Persistent local files
- `FS_CASTLE_TOWN_N4A_R1F_BINARY_MASK_63x216.png`
- `FS_CASTLE_TOWN_N4A_R1F_EXTRACTED_PAR_63x216.png`
- `FS_CASTLE_TOWN_N4A_R1F_CHECKER.png`
- `FS_CASTLE_TOWN_N4A_R1F_ON_GROUND_RECOMPOSED_1448x1086.png`
- `FS_CASTLE_TOWN_N4A_R1F_QA_REPORT.json`

## SHA256
- mask: `24444e07b8329bd3015a1a443511425f526cdfe8942b79039150025a8fbcfd21`
- PAR: `af5fb4775a49156c7c24c00701a9101379ae7c5e6f15e7585a1591b2250f7e5e`
- checker: `03f542e19cea49d814e7c3eec03c8e264f0a98253d7229b1cc7a581cf971c0d9`
- recomposition: `c1e1969ba1a9bb088fb2653d5e29608b6bcfd28b8ef2ec5517139c0961893f29`

## Next legal action
Proceed to N4B / NE Garden Structural Props under v2.6 Boundary Continuity Audit. Flowers/grass remain Ground; only structural garden props may enter PAR.
