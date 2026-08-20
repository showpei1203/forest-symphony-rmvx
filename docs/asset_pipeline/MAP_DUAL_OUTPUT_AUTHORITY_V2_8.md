# MAP_DUAL_OUTPUT_AUTHORITY_V2_8

Date: 2026-08-21
Scope: Shared deterministic Ground + Complete PAR authoring, extending v2.7.

## Inheritance
All v2.7 rules remain mandatory unless explicitly superseded below.

## New mandatory gate: Ground Semantic Purity
A visually correct `GROUND + PAR` recomposition is not sufficient if non-Ground structure is still baked into Ground.

Ground must contain only legal Ground classes. Structural objects that are owned by PAR must be removed from Ground even when the PAR layer would visually cover the duplicate during normal recomposition.

## Ground-remnant cleanup is a separate authority from PAR ownership
**Do not assume the PAR owner mask can be reused as the Ground cleanup mask.**

Two different masks may be required:

1. **PAR owner mask**
   - follows Master object geometry;
   - determines which exact Master pixels belong to the PAR asset;
   - opaque owner RGB remains Master-exact;
   - structural alpha remains binary `{0,255}` unless an explicit exception exists.

2. **Ground-remnant cleanup mask**
   - follows the actual unwanted structural remnant visible in the current Ground image;
   - may differ from the PAR owner mask if Ground reconstruction drifted, resized locally, changed silhouette, or retained only part of the structure;
   - exists only to produce semantically pure Ground and does not grant PAR ownership.

## Aligned vs drifted Ground remnants
### Aligned remnant
If Ground structure is spatially aligned with the PAR owner, cleanup should stay as close to the owner mask as possible. This minimizes visible replacement texture outside the future PAR overlay.

### Drifted remnant
If Ground retains a shifted or differently shaped structural remnant, the cleanup mask may be larger or differently shaped than the PAR owner mask. The full Ground remnant must be removed.

M3A West Plaza Fountain demonstrated this case: the Ground fountain remnant was not byte-aligned with the Master-derived PAR owner mask.

## Legal Ground replacement
When structural pixels are removed from Ground:
- replacement pixels must belong to the correct semantic Ground class for that location, e.g. water surface, grass/flowers, road/plaza/floor;
- prefer deterministic source-copy / patch-copy from existing legal Ground pixels;
- do not use smooth interpolation, feathered alpha, anti-aliasing, or generative repositioning as hidden error correction;
- exact replacement texture does not need to reconstruct invisible historical pixels under a structure, but it must remain visually coherent and pixel-crisp;
- outside the declared cleanup mask, Ground must remain unchanged.

## Recomposition requirements
For every accepted child/parent:
- PAR owner pixels must recompose Master-exact;
- child ownership overlap must remain zero unless a dependency transfer is explicitly recorded and resolved;
- corrected Ground + accepted PAR must pass visual recomposition QA;
- a numeric owner-exact result cannot override an obvious visual cleanup artifact outside the PAR owner silhouette.

## Dependency rule
If a newly completed foreground asset reveals pixels previously owned by a rear/background asset, transfer ownership to the visible foreground object and revalidate all affected dependencies. Do not damage a now-complete foreground asset merely to preserve an older overlap certificate.

## Evidence that established v2.8
### M0 Central Goddess Monument
Proved that Working Ground could retain structural basin/curb pixels even when PAR ownership was otherwise correct.

### M3 West Plaza Fountain
Proved that:
- Ground remnant geometry may differ from Master-derived PAR geometry;
- using a PAR mask directly as a Ground eraser can leave structural residue;
- overly broad Ground cleanup can create visible replacement seams outside PAR;
- cleanup geometry must therefore be independently audited and whole-parent visual recomposition remains mandatory.

## Status formula
A local/zone layer split may only PASS when all are true:

`OWNER_UNIQUENESS_PASS`

`PAR_COMPLETENESS_PASS`

`GROUND_SEMANTIC_PURITY_PASS`

`BOUNDARY_CONTINUITY_PASS`

`MASTER_EXACT_OWNER_RGB_PASS`

`VISUAL_RECOMPOSITION_PASS`

No single metric is sufficient on its own.
