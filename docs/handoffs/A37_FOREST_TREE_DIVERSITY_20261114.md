# A37 Forest Diversity | Handoff 2026-11-14

Status: SPEC + SIX-TREE VISUAL CANDIDATE ONLY. NOT QA PASS; NOT integrated map.

## Source and authority
- Continue from latest verified A36B R2 2560x1856 forest map as stated in preceding handoff, but actual binary assets and latest working branch must be verified before modifications.
- Follow current FS authority index and cloud-only policy. Master-first authoring supersedes archived Ground-first instructions. Ground and PAR are derived from the same approved master image.
- Keep all persistent files in private GitHub/Drive; never overwrite sealed assets or publish private artwork.

## Tree family
T1 sapling (small); T2 squat broadleaf (small-medium); T3 slender tall (medium); T4 split trunk (medium-large); T5 broad mature canopy (large); T6 ancient hollow tree (landmark).
Generated image is a **concept candidate**, not a transparent verified PNG atlas. Do not claim segmentation or integration complete.

## Placement algorithm
1. Derive biome masks: deep forest, transition edge, village fringe, path corridor, clearings.
2. Use deterministic seeded Poisson-disk cluster centers, not uniform grids. Vary cluster radius, canopy diameter, and spacing with local biome.
3. Deep forest: 70-90% canopy target; edge 40-65%; village fringe 15-35%; clearing 0-15%. These are design targets requiring visual QA, not measured results.
4. Favor T5/T6 in deep forest, T2/T3/T4 at edges, T1/T2 near village. T6 sparse landmark only.
5. Avoid same tree silhouette adjacent more than twice; use controlled mirroring only where anatomy permits, no arbitrary noninteger pixel scaling.
6. Place root collision around trunks, not entire canopies; preserve walkable paths and 32px grid. Canopies may occlude actor according to height/footpoint ordering.
7. Forest clusters may extend beyond map borders; never visibly cut off a standalone tree inside the playable viewport.
8. Retain flowers, grass and ground variety. No obvious circular stamping, repeated rows, or rectangular seams.

## Pipeline
Approved master composite -> Ground (complete image) -> PAR (aligned occlusion mask, pixel-exact from master) -> collision/navigation -> Godot native render -> VX compatibility check -> screenshot comparison -> art review.
Do not create independent ground/par art generations that diverge.

## QA gates
- 6 visually distinct species and consistent palette; each isolated asset genuinely transparent.
- Master/Ground pixel alignment; PAR dimensions match master; no grass accidentally in PAR.
- Canopy overlap and root placement coherent; paths traversable; edge forests continue offscreen.
- Record pixel metrics, native screenshots, failure log, reproducible seed, file SHA256, and private links.
- ART HOLD until user approves actual composite; ENGINE PASS only with real test evidence.

## Failure prevention
Past failures: repeated identical trees, clipped canopies, tiled forest seams, wrong PAR, blurry ground, pretty concept mistaken for runtime map. Treat each as regression gate.

## Next
Verify authoritative A36B R2 assets and source branch, prepare actual isolated tree PNGs, create seeded biome placement on 2560x1856 master, derive PAR and run Godot/VX tests. This document alone is not implementation evidence.
