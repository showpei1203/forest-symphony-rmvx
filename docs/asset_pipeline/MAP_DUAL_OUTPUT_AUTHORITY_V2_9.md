# MAP_DUAL_OUTPUT_AUTHORITY_V2_9 — Ground Semantic Completeness / Restoration Authority

Date: 2026-08-21
Project: Forest Symphony Castle Town layered map authoring

## Inherits
This authority inherits v2.8 Ground-Remnant Cleanup Authority and all earlier v2.5–v2.7 source fidelity, deterministic placement, boundary continuity, ownership, residual completeness, and binary-alpha rules.

## New mandatory rule: Ground Semantic Completeness is bidirectional
Ground QA must detect both:
1. **PAR contamination in Ground** — structural/non-Ground pixels remain baked into Ground and must be removed.
2. **Legal Ground omission** — valid Ground-class pixels were removed together with an object and must be restored.

Ground is not valid merely because PAR objects are absent.

## Canonical classes remain unchanged
GROUND:
- terrain / true ground
- floor / road / plaza / terrain tiles
- grass
- flowers
- water surfaces

PAR:
- everything else, including buildings, walls, towers, roofs, trees, bushes, rocks/cliffs as objects, fountain/statue stone structure, curbs/planters, signs, props, furniture, lamps, crates, barrels, structural stairs, etc.

## Ground-remnant cleanup and Ground-restoration masks are independent QA artifacts
The Master-derived PAR owner mask is not automatically the Ground correction mask.

### Case A — aligned residual PAR in Ground
When a Ground structural remnant is aligned with the PAR owner, restrict cleanup to the owner mask unless visual evidence proves additional residual structure.

### Case B — drifted/reconstructed residual PAR in Ground
When the Ground remnant is shifted or reshaped relative to Master, derive an independent cleanup mask from the Ground remnant geometry.

### Case C — legal Ground removed with object
When Working Ground removed Ground-class content such as fountain water together with the PAR object, derive a **Ground restoration mask** from the legal Ground surface geometry and restore source-faithful Ground pixels. Do not fill such holes with grass/plaza merely because that is what the Working Ground currently contains.

## Formal gate
For every corrected workcell:
- PAR owner pixels must be Master-exact.
- Ground corrections may modify only the validated cleanup/restoration target.
- Outside-target Ground changes must be zero.
- `corrected Ground + accepted PAR` must reproduce Master on the complete semantic footprint: PAR owners plus any restored Ground-class pixels.
- Whole-workcell visual QA remains mandatory to catch exposed replacement textures outside PAR ownership.

## M4 precedent
M4 East Garden Fountain proved Case C:
- Working Ground removed the entire fountain, including legal flat basin water, to grass.
- PAR fountain structure = 392 px.
- Ground water restoration = 76 px.
- combined semantic footprint = 468 px.
- corrected Ground + PAR = 468/468 Master-exact.

This rule is mandatory for subsequent MID/SOUTH/EAST/WEST anchors and for final full-map Ground acceptance.
