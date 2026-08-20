# FS Castle Town — N2A-R1B QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_6

## Anchor
N2A | North-left House

Original bbox: `[451,161,565,313]`
Original workcell: `114×152`

## Boundary Continuity Audit
Result: **ORIGINAL GEOMETRY FAIL**

Master inspection showed the visible front porch/step structure continues below the original bottom boundary. Structural pixels remain visible through approximately global `y=322`.

Corrected bbox: `[451,161,565,323]`
Corrected workcell: `114×162`
Placement remains `(451,161)`.
No resize, redraw or Ground movement was used.

## N2A-R1B extraction
Result: **CANDIDATE_READY_FOR_FORMAL_VISUAL_QA**

Method:
- Master-exact source pixels;
- semantic carve / GrabCut with house foreground priors;
- tree/ground/path/neighbor background priors;
- conservative upper-left tree-contact cleanup;
- binary structural alpha only.

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial-alpha pixels: `0`
- opaque pixels: `8,651`
- transparent pixels: `9,817`
- local alpha bbox: `[30,31,107,161]`
- no resize: PASS
- no redraw: PASS
- integer placement: PASS

Visual QA observed:
- main roof included;
- full house body included;
- front door included;
- front porch/step included through corrected global y=322;
- left tree cluster excluded;
- left prop cluster excluded;
- right grass strip excluded;
- upper-left tree wedge removed in R1B;
- no broad Ground-class leak observed.

## Persistent local candidate files
- `FS_CASTLE_TOWN_N2A_R1B_BINARY_MASK_114x162.png`
- `FS_CASTLE_TOWN_N2A_R1B_EXTRACTED_PAR_114x162.png`
- `FS_CASTLE_TOWN_N2A_R1B_CHECKER.png`
- `FS_CASTLE_TOWN_N2A_R1B_ON_GROUND_RECOMPOSED_1448x1086.png`
- `FS_CASTLE_TOWN_N2A_R1B_QA_REPORT.json`

## SHA256
- mask: `066a054ab3585eecf16498523edc4fcc86b0481e2d68b3ed6b0c983ad53d0c8c`
- PAR: `208eca5dc62ddc6a2585a300cff55405a3f071eecc5399e3fd1309e283182933`
- checker: `2b75e51bd20fb2e0d6114a3930989e1ab3e8facf90fa82e3705beaae24891f48`
- recomposition: `2044c21dff03ac144da88e93e2734f81ca7394d56dfbc5a78f7c44f4b278ac89`

## Next legal action
Run final visual acceptance on N2A-R1B. If accepted, lock corrected N2A bbox and proceed to N3A under v2.6 Boundary Continuity Audit first.
