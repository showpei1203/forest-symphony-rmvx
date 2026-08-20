# FS Castle Town — N4B-R1C QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N4B | NE Garden Structural Props

Original bbox: `[1062,176,1176,307]`
Corrected bbox: `[1062,176,1183,314]`
Corrected workcell: `121×138`
Placement: `(1062,176)`

## Boundary Continuity Audit
Original geometry failed: right trellis post extended beyond x=1176 and lower stone structure continued through global y=313. Corrected bbox adds right/bottom safety coverage without moving or resizing source pixels.

## R1C extraction
Result: **FORMAL VISUAL PASS**

Ownership rule:
- PAR: wooden trellis/frame/lattice, stone garden structures and other non-Ground structural props.
- Ground: flowers, grass, vegetation and terrain surface.

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `5,728`
- transparent pixels: `10,970`
- local alpha bbox: `[5,20,120,137]`
- no resize/redraw: PASS
- N4A overlap: `0 px`

Visual QA:
- outer trellis frame: PASS
- internal trellis structure: PASS
- flowers / grass excluded from PAR ownership: PASS
- left stone garden prop: PASS
- right stone garden prop: PASS
- broad Ground leak: not observed

Residual Master/recomposition differences are primarily from the Working Ground flower/grass texture, not PAR displacement.

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_N4B_R1C_EXTRACTED_PAR_121x138.png`
- `FS_CASTLE_TOWN_N4B_R1C_BINARY_MASK_121x138.png`
- `FS_CASTLE_TOWN_N4B_R1C_CHECKER.png`
- `FS_CASTLE_TOWN_N4B_R1C_QA_REPORT.json`
