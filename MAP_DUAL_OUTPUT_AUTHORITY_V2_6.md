# Shared Map Layered Generation Authority v2.6

Effective: 2026-08-20
Scope: Forest Symphony / PMD AutoChess Proto / CG Pet Battle Prototype

This extends v2.5. All v2.5 source-asset, deterministic-placement, pixel-crisp, alpha-purity and Master-exact rules remain active.

## 1. Boundary Continuity Audit is mandatory before segmentation approval
A declared object/anchor bbox is not assumed complete merely because it was previously authored. Before an object/group may pass mask QA, inspect every workcell edge that the candidate structure approaches or touches.

If visible non-Ground structure continues beyond the current workcell boundary, the anchor/workcell is geometrically incomplete and must be expanded before segmentation can pass. Do not clip the structure to satisfy the old bbox.

## 2. Automatic warning profile
Any candidate mask whose meaningful opaque structure touches the top, bottom, left or right workcell edge is a Boundary Continuity WARNING by default. The workflow must inspect Master pixels immediately outside that edge.

The warning is cleared only when one of the following is true:
- the visible structure genuinely terminates at that boundary;
- the neighboring pixels are legally owned by a separately declared child/sibling anchor with explicit disjoint ownership;
- the bbox is expanded until the full structure terminates.

## 3. Geometry beats historical coordinates
An older anchor coordinate may be corrected when Master evidence proves that it clips a legally PAR-owned structure. Corrections must preserve integer registration and may not move/rescale accepted Ground to compensate.

## 4. Evidence from Castle Town
- N0A original bbox `[600,30,820,305]` clipped the main-castle front staircase. Corrected bottom became `315`.
- N2A original bbox `[451,161,565,313]` clipped the north-left house front porch/step structure. Corrected bottom became `323`.

Repeated clipping proves that bbox completeness needs its own pre-segmentation gate rather than being assumed from placement contracts.

## 5. Required order v2.6
`Ground -> Anchor Contract -> Boundary Continuity Audit -> corrected bbox if required -> semantic/mask extraction -> alpha/purity QA -> deterministic placement -> recomposition QA -> next object`

A visually attractive mask inside an incomplete workcell is FAIL, not a valid asset.
