# Forest Symphony · Godot-first map pilot A29

**Godot 4.7.2 stable.** This is a real Godot project with editable scene nodes using an owner-only A21 **1280×928** original Master, A18 **48×48** approved F0 and three same-XY source-locked A28 PAR cropped objects. This is not a new illustration. 

**Open the owner-only ZIP** from the corresponding FS Drive A29 delivery with Godot. Do not open this public-code-only checkout expecting full graphics: the private PNG files are intentionally **NOT in GitHub**. Never upload those PNG files to GitHub.

## What is already implemented

- Complete Master as static background, same bytes and same coordinates, no tile chopping.
- Three editable Sprite2D foreground objects (two tree sections and a bridge rail), source-locked by SHA, with editable depth limits in Godot Inspector.
- Per-character dynamically recomputed same-XY PAR with actor silhouette. Actor's feet use real Godot world XY, not VX `screen_y`.
- `CharacterBody2D` movement, camera following, nearest-neighbor rendering and world 32×32 grid toggle.
- Scene node reserved for collision TileMapLayer (NOT painted; no collision approved yet).

## Controls

- WASD / arrows: walk; Shift: faster.
- G: toggle 32×32 world grid.
- O: enable/disable PAR occlusion so you can compare alignment.

## Warning and scope

- Source art for A21 forest+bridge is ART HOLD. This step verifies engine architecture, not visual quality, collision, animations or the entire game.
- Actor01 uses static, approved F0 only. Walking changes position but not the 3-frame animation. It is not a new RUN asset.
- Trees/bridge per-pixel shading uses A27's *manually calibrated linear screen-row depth hint*, not a discovered 3D model. Do not infer `ART PASS` from 197/29 occluded pixels.
- No production FPS benchmark, navigation mesh, collision wall tracing, water logic, lighting or party system is claimed.
- 1st run requires private PNG assets. Public code-only CI (already real Godot 4.7.2 `PASS`): `godot --headless --path . --script res://tests/test_godot_code.gd`; structural check: `res://tests/test_scene_structure.gd`. Owner-only `res://tests/test_godot_real.gd` has been run on official Godot 4.7.2, **14/14 PASS**, four original XY cases 197/0/29/0, native character movement and camera. Four 544×416 real framebuffer screenshots are in the private ZIP `qa/`.
- Opening editor with source assets loads original full map and editor-editable occluder sprites. For art review, look at the true four-case native screenshots, which are not Pillow simulations. ART HOLD remains until user approves and occlusion flaws repaired.

## Future feature migration

1. Godot map pipeline/occlusion and edit tools (this A29 pilot).
2. 32px collision, character navigation, door/house interactions, tile layers and animated ground.
3. Actor/monster animation import pipeline (A62, PMD -> Godot actions).
4. Events, inventory, dialogues, save and scene transitions.
5. Six-actor battles, Tankentai SBS look, ATB, Break, Overdrive, Cover and summons, using original VX as test oracle.

See `docs/GODOT_FIRST_PORT.md` for gate status and source hashes.
