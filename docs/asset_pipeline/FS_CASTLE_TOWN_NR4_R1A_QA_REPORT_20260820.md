# FS Castle Town — NR4-R1A QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Anchor
NR4 | NE Garden Canopy + Shrub Residuals

Initial residual sweep region: `[1120,140,1210,265]`
Final bbox: `[1145,155,1220,275]`
Workcell: `75×120`
Placement: `(1145,155)`

## Boundary Continuity Audit
Initial sweep right/bottom bounds were too tight for visible vegetation. Final object-specific workcell expands right/bottom while retaining safe margins around all accepted opaque pixels.

Final opaque local bbox: `[9,12,67,102]`.
No meaningful opaque structure touches any workcell edge.

## Extraction
Result: **FORMAL VISUAL PASS**

R1 checker initially made the shadowed large conifer read like background/tower shadow. Master overlay plus exact recomposition confirmed it is legitimate vegetation ownership. R1A therefore preserves the same pixels as R1; the version change records semantic confirmation rather than a redraw/resegmentation.

Mechanical gates:
- Master-exact RGB on every opaque pixel: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `2,923`
- transparent pixels: `6,077`
- no resize/redraw: PASS

Visual QA:
- small conifer: PASS
- large shadowed conifer: PASS
- lower small shrub/conifer: PASS
- purple flower bed: Ground
- white flower cluster: Ground
- tower/garden structural owners: excluded by exact accepted-owner subtraction
- broad Ground leak: not observed

## Ownership checkpoint after NR4
- accepted PAR assets: `17`
- pairwise combinations checked: `136`
- nonzero overlap pairs: `0`
- multi-owned pixels: `0`
- max owners per pixel: `1`
- union opaque pixels: `133,579`

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NR4_R1A_EXTRACTED_PAR_75x120.png`
- `FS_CASTLE_TOWN_NR4_R1A_BINARY_MASK_75x120.png`
- `FS_CASTLE_TOWN_NR4_R1A_CHECKER.png`
- `FS_CASTLE_TOWN_NR4_R1A_QA_REPORT.json`

Next residual sweep: `NR5 / North Exterior Canopy Sweep`.
