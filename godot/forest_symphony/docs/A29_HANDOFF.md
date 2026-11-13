# FS Godot-first A29 Handoff | 2026-11-13

## Decision
User wants Godot as FS's primary development/scene/map editor, gradually porting mechanics away from RPG Maker VX. This is the new direction. Godot stable 4.7.2, 4.8 currently beta. Existing FS VX 2.3.3 and A36F remain unmodified archived benchmarks. Source and art QA gates remain mandatory.

## Actual local isolated implementation
- `project.godot` + `scenes/elf_forest_map.tscn` + `scripts/*` + `tests/*` exist in the portable Godot project. Production scene has 1280×928 source Master, 3 isolated A28 cropped PAR source objects (LeftTree, RightTree, BridgeRail), Actor01 original F0, Camera2D, CharacterBody2D, CollisionPaint TileMapLayer placeholder and 32px editor/debug grid.
- Full Ground SHA `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530` preserved, F0 SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba` preserved, three crop hashes from A28 exactly matched.
- Per actor foreground is calculated as intersection of (actor opaque footprint, same XY original object alpha, screen-row calibrated depth threshold). This avoids RGSS2 Switch203 and screen_y issues as the game runtime.
- This stage introduces object inspector editing and Godot scene graph, not an entire FS game migration. It does NOT automatically derive collision masks from visual alpha.
- Public CI only runs source-only synthetic Godot tests; private owner Drive package contains real artwork and a real input smoke script. Do not claim native real Godot PASS before running that smoke script and observing the scene in 1x.

## Failure Log
1. Prior A27 had per-actor Pillow-only render, A28 generated private PAR object PNGs + RGSS2 adapter; no Godot project existed in repo. This A29 adds native scene architecture without destructively changing either.
2. Original art is still ART_HOLD, notably tree occlusion excess/possible floating-head, and bridge source art. Do not hide by increasing alpha, smoothing or regenerating whole Master.
3. CollisionPaint TileMapLayer has not been painted or assigned a validated TileSet; world walking does not yet have water/house blockage. Mark COLLISION NOT_RUN, do NOT make fake physical restrictions.
4. Actor uses static 48px F0; movement works as spatial test, not animation or actual RUN conversion.
5. Godot parser/headless runner test must be recorded with actual Actions URL, not presumed from creating YAML.

## Next implementation queue
P1 Verify code-only Godot 4.7.2 headless CI, repair parse/runtime errors; if possible private read-only CI on isolated runner not GitHub. P2 Check real scene 1x and verify original Master F0 source; approve artistically or mark HOLD. P3 Paint verified 32px Collision/TileMapLayer and clickable zone transitions; confirm no unwarranted block. P4 Improve object depth mask source and camera scrolling; P5 import existing Actor01 A62 animation, then state machines/events; P6 gradual battle mechanics (Tankentai+ATB), summons, Break, Cover and Overdrive.

## Preservation and migration rules
Keep public source on separate Godot PR; private images/complete Godot playable project on owner-only Drive. No user PC writes or new installs; native Windows play requires authorization if it would create temporary files there. Every iteration needs QA, Failure Log, Handoff, cloud SHA readback, preserve the source and no main merge without approval.
