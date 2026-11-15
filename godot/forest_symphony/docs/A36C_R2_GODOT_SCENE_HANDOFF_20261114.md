# A36C R2 | ACTUAL GODOT SCENE VARIANT | 2026-11-14

## Authority
- Godot 4.7.2 stable only. Draft PR #16 branch `feat/fs-godot-first-a29-20261113`. Art pipeline Ground-only -> independent full PAR -> SHADOW/LIGHT/WATER -> native Godot render.
- A36B R2 remains untouched. Private art is owner-only Drive. No VX QA. No changes to main.
- This lane is forest art only; NPC/events/battle in other lane.

## Actual deliverables
1. `scenes/a36c_r2_ecology_variant_80x58.tscn` real Godot scene with 326 independently editable original nodes and original `a36b_world.gd`.
2. `data/a36c_r2_ecology_variant_manifest.json` real manifest with 40 object source substitutions and traceable original IDs.
3. `tests/test_a36c_r2_public.py` immutable source/scene contract test.

## Changes
- Original 310 tree instances / six families retained. 30 oak_summer -> oak_golden (both 176x174, 32x18 collision footprint); 10 birch_blush -> birch_cream (both 122x170, 22x12 collision footprint).
- Original summer oak count 155 -> 125; golden oak 41 -> 71; blush birch 39 -> 29; cream birch 13 -> 23; pine 40 and willow 22 unchanged. Largest single source share 155/310=50.0% -> 125/310=40.32%.
- Selection deterministic by 220px local neighborhood source diversity; only swaps where local old-family count exceeds target-family count. Does not move footpoints, change dimensions, or fabricate new species. Biome art quality still HOLD.
- Baseline Ground SHA ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911 unchanged; SHADOW SHA 752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa unchanged.
- Scene preserves 326 source_object_id nodes and existing collisions/YSort. New scene uses original A36B world script and private assets, so source-only repository cannot display private art.

## Verification actually executed
- Read back live GitHub files; JS structural source comparison: 40 exact family swaps, zero unexpected object field mutations, 326 objects and 326 scene source nodes, Ground/SHADOW manifests unchanged: PASS.
- Python regression test added but NOT EXECUTED in runner. Godot native 1x screenshot NOT RUN. Runtime collision/occlusion NOT RUN. CI status for new HEAD NOT VERIFIED.
- Therefore ENGINE/ART QA remains HOLD and formal seal NO.

## Failure log
- Earlier A37 used VX and Master-first; superseded.
- A36C R1 audit initially rejected legitimate off-canvas feet; fixed.
- R2 cannot yet solve six-species silhouette repetition because it uses only existing assets; color-family rebalancing is an interim measure. Do not claim 8-12 species or art acceptance.
- No private A36B ZIP was downloaded this round, so no private native run.

## Next actionable step
- Run `python tests/test_a36c_r2_public.py` in Godot project root on a clean isolated runner and record output.
- Download private A36B ZIP, verify 54,150,993 bytes SHA256 7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b; overlay only the A36C R2 scene/manifest in a temporary copy.
- Run Godot 4.7.2 native framebuffer A/B, verify 40 tree ROI changes, footpoints/collision/water/1x visual.
- Add 2-6 new truly distinct full RGBA tree silhouettes in private art storage and rerun placement with proper ecological zoning, then user art gate.
- Each iteration: GitHub code+tests+failure log+handoff, private Drive source+screenshots+handoff, immutable baseline.
