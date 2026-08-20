# FS Castle Town — MID Placement Anchor Contract v1 / Batch A

Date: 2026-08-21
Authority: MAP_DUAL_OUTPUT_AUTHORITY_V2_7
Canvas: 1448×1086
Status: **MID_BATCH_A_ANCHOR_LOCKED_BEFORE_EXTRACTION**

## Zone policy
MID uses semantic-object ownership, not a blind horizontal cut. An object may cross a scan band; it must stay intact under one semantic owner. Existing NORTH R2 ownership remains sealed.

## M0 | Central Goddess Monument Compound
- parent bbox: `[650,440,775,585]`
- parent workcell: `125×145`
- placement: `(650,440)`
- deterministic coordinate tolerance: `0 px`

PAR owns:
- goddess statue / body
- stone pedestal / base
- stone basin / rim
- structural stone planter border

Ground owns:
- water surface
- grass
- flowers
- plaza / floor

Excluded from M0 and reserved for future anchors:
- nearby flag poles / banners
- free-standing plaza lamps

### Child ownership refinement
M0 is allowed to split into deterministic child outputs when purity is clearer than one compound mask:
- `M0A` = Goddess Statue + Central Basin
- `M0B` = Structural Planter / Curb Border

M0A may pass independently while M0B remains candidate. Parent M0 is not complete until both children pass.

Initial witness points (global): `(710,466)`, `(701,489)`, `(712,520)`, `(662,548)`, `(759,548)`.

## Ground Semantic Purity Gate
A PAR-class structure must not remain visually baked into Ground merely because the RGB is not byte-identical to Master. MID requires semantic Ground purity in addition to PAR completeness. Local deterministic Ground correction proofs are allowed before full Ground promotion.

## Next legal step
M0A may be sealed after deterministic geometry, purity, Master-exact RGB, binary-alpha and local Ground-purity proof. Continue M0B until parent M0 is complete; do not skip directly to broad MID extraction.
