# FS Godot-first A29 Handoff | 2026-11-13

## Decision
User wants Godot as FS's primary development/scene/map editor, gradually porting mechanics away from RPG Maker VX. This is the new direction. Godot stable 4.7.2, 4.8 currently beta. Existing FS VX 2.3.3 and A36F remain unmodified archived benchmarks. Source and art QA gates remain mandatory.

## Actual local isolated implementation
- `project.godot` + `scenes/elf_forest_map.tscn` + `scripts/*` + `tests/*` exist in the portable Godot project. Production scene has 1280×928 source Master, 3 isolated A28 cropped PAR source objects (LeftTree, RightTree, BridgeRail), Actor01 original F0, Camera2D, CharacterBody2D, CollisionPaint TileMapLayer placeholder and 32px editor/debug grid.
- Full Ground SHA `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530` preserved, F0 SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba` preserved, three crop hashes from A28 exactly matched.
- Per actor foreground is calculated as intersection of (actor opaque footprint, same XY original object alpha, screen-row calibrated depth threshold). This avoids RGSS2 Switch203 and screen_y issues as the game runtime.
- This stage introduces object inspector editing and Godot scene graph, not an entire FS game migration. It does NOT automatically derive collision masks from visual alpha.
- Public CI executed official Godot 4.7.2 and completed scene structure (16 nodes, 9 required), source-only synthetic 6 checks, without errors (Actions run 43428151185). Later workflow for binary artefact 43428413204 also succeeded. Owner-only local isolated real engine has now executed the true A21 Master, 3 A28 cropped PARs, A18 actor F0; all SHA locks pass, true framebuffers captured on Xvfb Mesa llvmpipe, four original-XY occlusion pixel counts 197/0/29/0, real CharacterBody2D movement + camera in 14 native checks all PASS. This is native Godot runtime verified; **not** Visual Art approval or a test of VX/Windows export.

## Failure Log
1. Prior A27 had per-actor Pillow-only render, A28 generated private PAR object PNGs + RGSS2 adapter; no Godot project existed in repo. This A29 adds native scene architecture without destructively changing either.
2. Original art is still ART_HOLD, notably tree occlusion excess/possible floating-head, and bridge source art. Do not hide by increasing alpha, smoothing or regenerating whole Master.
3. CollisionPaint TileMapLayer has not been painted or assigned a validated TileSet; world walking does not yet have water/house blockage. Mark COLLISION NOT_RUN, do NOT make fake physical restrictions.
4. Actor uses static 48px F0; movement works as spatial test, not animation or actual RUN conversion.
5. First green GitHub Actions run 43427390485 had a false-positive: scene parser dropped Characters/Player because the empty TileMapLayer scene block comment serialized incorrectly. A strict structure validator exposed 14 instead of 16 nodes. Fixed explicit `z_index` on CollisionPaint and `y_sort_enabled` on Characters; Godot full parser + 9 required nodes + 6 synthetic smoke PASS in run 43428151185. Never treat workflow success without parsing logs as enough.
6. Real Godot editor originally warned raw `Image.load_from_file()` is unsupported by exported PCK. Switched both map and occluders to import-aware `Texture2D load(path).get_image()`; true asset SHA still checked in editor, export packaging and distribution remain NOT_RUN.
7. Headless real-asset test initially falsely printed PASS despite `push_error` because `quit(1)` was overwritten by later `quit(0)` in the same frame. Fixed failure accumulation and CPU image parity; verified 14 native PASS plus real 544x416 screenshots. Only isolated runner had ALSA/llvmpipe warnings, no render errors.

## Next implementation queue
P1 DONE: Godot 4.7.2 CI syntax/scene + 6 synthetic QA PASS; isolated true F0/A21 source 14 native checks and 4 framebuffer screenshots PASS. P2 NEXT: review the real scene at 1x, fix occlusion tree/bridge Art HOLD without changing approved source pixels. P3 Paint verified 32px Collision/TileMapLayer and clickable zone transitions; confirm no unwarranted block. P4 Improve object depth mask source and camera scrolling; P5 import existing Actor01 A62 animation, then state machines/events; P6 gradual battle mechanics (Tankentai+ATB), summons, Break, Cover and Overdrive.

## Preservation and migration rules
Keep public source on separate Godot PR; private images/complete Godot playable project on owner-only Drive. No user PC writes or new installs; native Windows play requires authorization if it would create temporary files there. Every iteration needs QA, Failure Log, Handoff, cloud SHA readback, preserve the source and no main merge without approval.
