# Forest Symphony Godot-first A29
Status: **REAL_SOURCE_SCENE_BUILT / GODOT_RUNTIME_VERIFY_PENDING / ART_HOLD / COLLISION_PENDING**.
Godot version: **4.7.2 stable**, not Godot 4.8 beta.

## Authoritative decision
Godot 4.7.2 replaces RPG Maker VX as the primary future-development / map-editing runtime. FS original VX v2.3.3 and A36F remain sealed evidence and the baseline for mechanics and art. No blind conversion of scripts into Godot. Older FS AI Asset Factory ACTIVE MASTER v1.1 governs source provenance, F0, artwork, and no-PC-writing; Godot-first migration overrides its assumption that VX runtime is the only release engine.

## What is implemented
1. Editable Godot 2D scene with source-locked 1280×928 actual complete Master as background, no re-render or tile chopping.
2. Scene objects `LeftTree`, `RightTree`, `BridgeRail` each contain an original-XY masked crop and editable footpoint depth limits. Inspector editing changes render behavior immediately in editor and after playing.
3. Player F0 is genuine 48×48 FS source, **stationary pose**. Free movement with WASD/arrows and camera follow; actor physics layer distinct from future CollisionPaint TileMapLayer.
4. `fs_occlusion.gd` draws per-actor overlay only within that actor's own opaque pixels, copying the exact original-XY PAR pixel from the source object. This supports multiple independent characters and avoids the VX Switch203/4px screen_y defect.
5. G toggle 32px logic grid; O toggle PAR; Shift faster. `CollisionPaint` is deliberately empty; no invented water/door/roof collision pass.

## Gate and limitations
- Input Master SHA `091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530` (1280×928). F0 SHA `a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba` (48×48).
- Cropped masks provenance: A28 owner-only verified ZIP, source exact pixel, `ART_HOLD` for forest/bridge style.
- This is a small *playable scene pilot*, not a full demo or a replacement for all FS mechanics. Collision/Nav, second actor AI, animations, battles, data import, UI, player ART and final map production require separate gates.
- Godot editor can manipulate the three PAR object nodes and future CollisionPaint/scene objects more conveniently; it does **not** automatically convert flat Master images into true separate ground/roof geometry.
- Do not claim real Godot 4.7.2 runtime PASS until actual CI/editor run and screenshots are verified.
- No new paid PixelLab calls. main branch and locked source untouched.

## Next gated tasks
1. Confirm Godot parser, source SHA, four A27 parity cases, and actual headless screenshot on an isolated runner.
2. Author the walkable/non-walkable map from original FS collision witness rather than guessing blocked cells; paint Godot TileMapLayer with 32px Source-Grid.
3. Implement authentic semi-opaque roof/tree depth templates + dynamic water/trees under Godot, preserving full Ground art.
4. Incrementally port scene transitions/events, save, then six party characters, summons, ATB/Tankentai semantics. Use parity fixtures with known VX behavior, not blind translation.

## CI and public/private split
- Public GitHub: `.tscn`, GDScript, Godot project settings, source contracts, tests, GitHub Actions.
- Owner-only Drive: playable archive containing same code plus original Master, F0, three cropped PARs; screenshots and logs.
- Private images/rights are NOT uploaded to public GitHub.
