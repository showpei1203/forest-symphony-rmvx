# FS Castle Town — M0B-R4A + M0 Parent Final QA

Date: 2026-08-21
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7 + MID Batch A Ground Semantic Purity Gate
Branch workflow: SHO-39

## M0B | Structural Planter / Curb Border
Original parent candidate bbox `[650,440,775,585]` was rejected for M0B because visible curb structure reached the left/right/bottom edges.

Corrected child bbox: `[638,488,798,587]`
Workcell: `160×99`
Placement: `(638,488)`

Result: **FORMAL VISUAL PASS**

Mechanical gates:
- Master-exact RGB on opaque pixels: PASS
- alpha `{0,255}`
- partial alpha: `0`
- opaque: `2,423 px`
- local alpha bbox: `[2,2,157,96]`
- all four child boundaries safe
- overlap with M0A: `0 px`
- no resize / redraw

Ground Semantic Purity proof:
- only explicit thin curb structural pixels are replaced in the local Ground proof
- changed Ground pixels: `2,422`
- outside-target Ground changes: `0`
- M0B owner recomposition: `2423/2423` Master-exact

M0B-R4A supersedes the rejected R1/R2/R3 candidates.

## Parent M0 | Central Goddess Monument Compound
Parent scope bbox for QA: `[638,440,798,587]`
Children:
- `M0A-R3B | Goddess Statue + Basin`
- `M0B-R4A | Structural Planter / Curb Border`

Parent result: **FORMAL PARENT PASS**

- child owner overlap: `0 px`
- max owner count: `1`
- union opaque: `4,607 px`
- recomposition exact on parent-owned pixels: `4607/4607`
- combined Ground semantic correction: `3,182 px`

Explicit exclusions remain future MID anchors and are not part of parent M0:
- nearby paired flag poles / banners
- free-standing plaza lamps

This does not promote the entire Castle Working Ground globally. It seals only the declared M0 semantic scope.

## Drive artifacts
M0B-R4A PAR, mask, checker and QA JSON plus the M0 parent final QA JSON are stored under `Forest Symphony/08_Assets/02_Working`.
