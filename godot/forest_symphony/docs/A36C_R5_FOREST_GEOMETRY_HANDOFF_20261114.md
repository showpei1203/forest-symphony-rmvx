# A36C R5 | Godot real forest geometry iteration | 2026-11-14

## Authority
Godot 4.7.2 ONLY, PR #16 branch `feat/fs-godot-first-a29-20261113`. A36B R2 immutable. Ground-only + full independent transparent PAR + independent SHADOW/LIGHT/WATER. No VX.

## Real authored scene
- `scenes/a36c_r5_natural_forest_clusters_80x58.tscn` (2560x1856) and `data/a36c_r5_natural_forest_clusters_manifest.json` committed.
- R4 moved tree `a36_tree_141` from (1800,1369) to (1724,1350), 78px.
- R5 moved another 28 independent tree owners 24-48px toward neighboring forest clusters. R5 algorithm excludes outermost map and immediate house vicinity, enforces minimum 52px between tree footpoints, preserves all sources/footprints.
- R2 previously rebalanced 40 same-dimension tree family sources; this R5 iteration modifies actual spatial tree positions.
- All 310 tree sources and 326 object owners retained, original Ground and SHADOW manifest unchanged, original A36B scene unchanged.
- New `tests/test_a36c_r5_public.py` source/scene regression test; added to `.github/workflows/fs-godot-a36b-tree-ecology.yml`.

## QA
- GitHub create-file operations PASS: R4 manifest fa7dbaf3, R4 scene fa960a8a, R5 manifest 652a228c, R5 scene cbd7d293, R5 test baf473d5, CI afdf1229.
- R5 native Godot 4.7.2 render NOT RUN. Python CI test has been committed but latest run not verified. Actual tree canopy, riverbanks, road clearance and footpoint collision NOT VISUALLY VERIFIED.
- 8-12 new complete tree species NOT CREATED; current sources six families. New Ground art and water animation NOT IMPLEMENTED.
- ART HOLD; COLLISION HOLD; FORMAL SEAL NO.

## Failure log
- Prior handoff used VX and Master-first, now void.
- R2 merely rebalanced color/source family; not equivalent to new species.
- R4 strict clustering moved only 1 tree, insufficient impact. R5 adjusted thresholds and moved 28 more, but visual art gate remains mandatory.
- Movement is a candidate, not proven path-safe without biome/path masks and native Godot screenshot. Do not merge or replace baseline before verification.

## Next
1. Run Python CI contract and actual private Godot 4.7.2 native render of R5 vs A36B R2, record 1x before/after, collisions, river, footpoint and edge.
2. Reject or revert moved nodes blocking path/river or looking unnatural; only promote verified subset.
3. Produce 2-6 new FULL RGBA independent tree silhouettes in owner-only Drive, validate source alpha/SHA and real palette; expand to 8-12 sources.
4. Keep source-only GitHub + private Drive artifacts; update CURRENT_HANDOFF each iteration.
