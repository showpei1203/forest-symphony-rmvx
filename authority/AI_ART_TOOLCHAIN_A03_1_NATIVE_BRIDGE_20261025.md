# A03.1 | FS Real 32px Source → Agent Sprite Forge → Tiled + Godot | 2026-10-25

## Authority and non-regression
- Applies **only to isolated FS V21 user-approved forest scene**, not new SCENE21 V24 or FS v8 multi-height, and not formal sealed RMVX runtime.
- Leave existing FS sealed scripts, LPC/P1G monster assets, prior V21/V22 human-approved sources unchanged. All new files created in `E:/GameAssetToolLab_20261023/TOOLCHAIN_PILOT_20261025`.
- Public GitHub branch: `feature/ai-art-toolchain-pilot-20261025`. No private PNG or complete game ZIP committed to public GitHub.

## First real project adapter: PASS
- User-approved FS V21 source: 544×416, 17×13 grid, 32px tile, 9 independently sourced, hash-checked PAR objects.
- Adapter builds Agent Sprite Forge `generate2dmap.map_bundle.v2` using true approved Ground image and separate independent object sprites; no flattened-scene reconstruction.
- Original `Ground.png + PAR_COMPLETE.png = Recomposed.png` exact 0 RGBA diff; `map_bundle.v2` renderer exact 0 RGB/Alpha diff.
- The FS original authoritative collision grid has exactly **23 blocked tiles, 198 walkable**. New map bundle collision uses exactly these tiles, and the actor-footbox sampling is already baked into the original tile grid (ASF actorRadius=0 to avoid double inflation). New navigation grid center-of-tile parity 221/221; BFS 198/198 walkables reachable from (8,11).
- Regression negative gates PASS: move rock 1px causes 4,007 differing pixels; one-pixel channel source alteration produces SHA mismatch; removing one collision tile detected.

## Real Tiled 1.12.2 acceptance
- ASF `export_tiled.py` produced a full layered `map.tmj`, 9 independently editable prop instances, invisible collision layer and separate interactions layer; built-in exporter/reference rendering exact diff 0.
- Initial official Tiled rasterizer rendering had 549 pixel differences in a single bbox near spawn (256,347)-(279,380). Root cause: Tiled draws its point spawn marker when `interactions` layer is visible; artwork was correct.
- Hiding *only* metadata layers `collision` and `interactions` visually in `map.runtime_hidden_meta.tmj` while retaining their objects and data yields **official native `tmxrasterizer.exe` 544×416 full RGBA exact 0 diff**. Do not claim Tiled GUI manual-edit human acceptance: editor GUI remains unreviewed.
- Official manual documents using `tmxrasterizer` for PNG; `tiled.exe --export-map` is not the PNG tool.

## Real Godot GPU and physics acceptance
- Exported native Godot 4.7.2 scene with `Sprite2D`, y-sorted props, 23 `CollisionShape2D` rectangles, `Marker2D` spawn. All 9 original PNG assets preserved byte-for-byte.
- Godot 4.7.2 native Windows OpenGL 3.3 on AMD RX 6700 XT rendered 544×416 RGBA with **0 pixel differences** from FS V21 approved master, no headless/dummy GPU substitution.
- Native Godot Y-sort: debug magenta marker behind forest tree only 6 pixels exposed, moved in front exposes 384 pixels. Source props unchanged; debug sprite is test-only.
- Real Godot physics canary: collision when moving right into water-well block (x stop 151.75) and clear path from x267 to x295 successful. Test playable Godot project built with WASD/arrows and a cyan debug actor.
- On initial cold-unzip, native import *not awaited* yielded missing `.godot/imported/*.ctex` cache and a legitimate fail. Fixed by explicitly waiting for `Godot --headless --path PROJECT --import` before launching scene. Recreated from extracted ZIP, then native physics PASS; cache is never shipped.

## Delivered private, verified
- Drive: https://drive.google.com/file/d/1lCl-HO7mpgtC8fktp-ucFdfHozgLwxdQ/view?usp=drivesdk
- ZIP: `FS_A03_1_ASF_TILED_GODOT_COLD_NATIVE_PASS_20261025.zip`.
- Size **8,812,619 bytes**; **144 ZIP members**; **SHA256 6a3b0f4a23bc973e19952fe870c7342ef1fe7e75f3b2c23efd77fd635e89c794**. ZIP CRC PASS, independent cold extraction SHA/checksum 100% PASS and cold test included. Local G: mounted Drive copy same SHA, official Google Drive API confirmed folder and size.
- Shortcuts: `RUN_A03_PLAY_GODOT.cmd`, `RUN_A03_OPEN_TILED.cmd`, `RUN_A03_QUICK_TEST.cmd`, `RUN_A03_GODOT_PHYSICS_TEST.cmd`.
- Bundle contains self-contained private scene assets, both engine project sources, diagnostics and source scripts, source/provenance, real GPU screenshots, and `CURRENT_HANDOFF.md`.
- Account/API credentials for PixelLab, SpriteCook, MagicPixel, AutoSprite **not authorized**. Zero paid generation; no original new monster art validated at this stage.

## Next actions
1. Perform human GUI/playable review of A03.1; no claim this automatically approves art for future maps.
2. Build a **NEW** original Ground+Props forest benchmark from approved Style DNA, using ASF modular source pipeline and tests (rather than reversed flattened master).
3. Separate 32px P1G original three-stage chibi creature chain and action-specific Idle/Attack QA on isolated source, avoiding ongoing P1G branch writes.
4. Real RMVX actor/roof/collision acceptance for newly generated source-derived scenes before any formal promote.
5. Save private ZIP/LOG + update Drive/GitHub/Linear + Handoff each milestone.
