# A37 CORRECTED HANDOFF | 2026-11-14 | GODOT ONLY

## CRITICAL SUPERSESSION
The previous A37 handoff incorrectly read a November 2 legacy VX map, described a Master-first extraction pipeline, and called for VX QA. ALL of those directives are VOID. The generated concept art and tree-layout script are NOT production deliverables. Never use this branch as a replacement for Godot PR #16.

## Current authority (verified from owner-only Drive checkpoint)
- Godot 4.7.2 stable ONLY for active development and runtime QA. VX is a sealed historical reference, no VX tests or production work.
- Active Master v1.3 and PR #16 `feat/fs-godot-first-a29-20261113`, current `godot/forest_symphony/CURRENT_HANDOFF.md` have precedence.
- Active art pipeline: **Ground-only first -> independent complete transparent PAR objects -> independent SHADOW/LIGHT/WATER -> Godot scene + occlusion/collision -> native 1x screenshots and visual approval**. Do not extract production PAR from a completed Master scene.
- A36B R2 actual scene: `res://scenes/a36b_large_forest_tree_ecology_80x58.tscn`, 80x58 grid / 2560x1856, 326 independently selectable PAR objects, 11 source families including SIX tree species.
- A36B R2 native Godot private 2,621 checks PASS, public 1,973 checks PASS, 2 native 2560x1856 OpenGL framebuffer renders, cold rebuild 6/6 SHA. Art HOLD, collision HOLD, water animation NOT IMPLEMENTED, formal seal NO.
- A36B Ground SHA256 ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911; original Ground 1478x1064 scaled nearest to 2560x1856, not native 32px art.
- Private ZIP 54,150,993 bytes / 173 members, SHA256 7e1cd53397aeb76deb09ceed0dc3002b5b7cc56c0a7fe40fac684a32eda6ac2b, https://drive.google.com/file/d/15t5Yn6zdTC8vG1dOYrLmMEHGVYqjEjwO/view
- Original verified checkpoint: https://drive.google.com/file/d/1zZNfqOIHrfYuhBzn4PBtfN-MMWNcOnd0/view
- PR: https://github.com/showpei1203/forest-symphony-rmvx/pull/16

## A37 actual continuation
1. Re-read current PR #16 HEAD, CURRENT_HANDOFF, Active Master v1.3, verify real private ZIP/hash, no assumptions based on legacy documents.
2. Start from the actual A36B R2 scene, not the standalone generated village concept image.
3. Build 2-6 ADDITIONAL distinct full RGBA tree sources for a total of 8-12 families; correct palette/size differences among existing six; do not count mirrors or resizes as distinct tree species.
4. Implement deterministic biome-aware cluster placement in the real 80x58 Godot scene; dense forest, natural forest edge, village fringe, path clearance, no visible tiling or cut-off. Preserve existing Ground and PAR controls.
5. Produce true Godot native 1x before/after screenshots; collision/occlusion and source SHA gates; update Failure Log. Keep art HOLD until user approval.
6. Keep private art and ZIP in owner-only Drive, only safe scripts/manifest/scene metadata in GitHub. Do not overwrite main or sealed VX. No PC persistent artifacts.

## A37 previous artifacts status
- Six-tree image and generated village picture: visual concepts ONLY, not licensed/segmented/transparent validated engine assets.
- `tools/a37_forest_tree_layout.py`: unintegrated proposal generator, NOT RUN against the actual biome mask and does not prove collision or natural forest layout.
- No actual A37 Godot scene, screenshot, or runtime QA yet. No A37 implementation PASS.
- Legacy A37 document's 1280x928 baseline and Master-first/VX references are invalid and superseded here.
