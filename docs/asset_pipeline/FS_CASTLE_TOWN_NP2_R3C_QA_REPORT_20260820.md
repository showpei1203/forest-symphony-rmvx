# FS Castle Town — NP2-R3C QA Report

Date: 2026-08-20
Branch workflow: SHO-39
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7

## Anchor
NP2 | North-east East Back Wall Segment

Supersedes: NP2-R1B, NP2-R2C, NP2-R3B.

Corrected bbox: `[805,58,1217,201]`
Workcell: `412×143`
Placement: `(805,58)`

## Geometry authority
R3C abandons material-threshold extension and uses explicit structural geometry:

- upper high wall: `[805,59,928,124]`
- main wall band: `[805,124,1217,160]`
- lower wall band: `[860,160,1217,200]`
- global `x<860` in `y=160..199` is the vertical floor/path and remains Ground

Known accepted foreground owners are subtracted exactly rather than duplicated.

## Boundary Continuity Audit
- top: PASS; y=58 is a 1px safety row
- bottom: PASS; y=200/local final row is transparent
- left: legal owner seam toward central-castle/west-side structure
- right: legal owner seam toward NP3/east perimeter

## Formal result
**FORMAL VISUAL AND MECHANICAL PASS**

Mechanical gates:
- source RGB Master-exact on opaque pixels: PASS
- alpha values: `{0,255}`
- partial alpha: `0`
- opaque pixels: `29,210`
- transparent pixels: `29,706`
- local alpha bbox: `[0,1,411,141]`
- no resize/redraw/Ground movement: PASS

## Completeness proof
The complete wall geometry was recomposed with the accepted foreground owners and compared against Master:

- upper high wall: 7,995 expected px / **0 diff**
- main wall band: 14,832 expected px / **0 diff**
- lower wall band: 14,280 expected px / **0 diff**
- total wall geometry: 37,107 expected px / **0 diff**

Thus NP2 now satisfies both ownership and completeness. Earlier zero-overlap versions are diagnostic history only and are no longer authority.

## Persistent Drive assets
Stored under `Forest Symphony/08_Assets/02_Working`:
- `FS_CASTLE_TOWN_NP2_R3C_EXTRACTED_PAR_412x143.png`
- `FS_CASTLE_TOWN_NP2_R3C_BINARY_MASK_412x143.png`
- `FS_CASTLE_TOWN_NP2_R3C_CHECKER.png`
- `FS_CASTLE_TOWN_NP2_R3C_QA_REPORT.json`
