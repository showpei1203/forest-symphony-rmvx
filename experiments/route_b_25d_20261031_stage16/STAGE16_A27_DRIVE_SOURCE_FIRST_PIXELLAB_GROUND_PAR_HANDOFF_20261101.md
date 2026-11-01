# Forest Symphony Stage16 A27 — Real PixelLab Ground + verified Drive full trees + isolated Godot

Date: 2026-11-01. **True 544×416 Ground/PAR real-engine scene PASS (provisional); complete tree source edge QA PASS; cold-rebuild PASS 8/8; static PAR vs engine 2640 pixel differences (1.1666%, NOT pixel-exact); native VX NOT RUN; aesthetic user approval PENDING; Formal Seal NO.**

## Critical correction: existing Drive tree source was ignored in A26
- We had previously used small original VX `TileB.png` generic trees and arbitrary forest-edge PAR panorama strips. The strip source is inherently cropped, at `x=-30` and `x=484` with right-side sprite exceeding 544 px. This led to the user's complaint, correctly.
- The authoritative existing **FS_SOURCE_ASSET_LOCATION_REGISTRY_V1** on Drive had already indexed **17 full tree-sprite sheets** in `Forest Symphony/08_Assets/00_Reference_Original/01_Maps_Parallax/Trees/` folder ID `1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw`. Old A26 violated the canonical source-first lookup rule.
- We fetched actual Drive source files: `Trees1.png` (ID `1HXnhGKXAop7eR9eQiUDoFO4f0M-UohaQ`, 670083 bytes, SHA256 `d99c8bcc495b68ae1dc61e39047fb66ff7666dafaa704198d44e522fd0199635`); `1_Treee.png` (ID `1SgE5BjBTtQ3r9-E8JZCL7N60RAE_Wb_i`, 79005 bytes); `tree variation.png` (ID `1BqcJRuENtRd9XhJ6Mx-_qEQ5k1_u1CTR`, 121982 bytes); evaluated visually against `Trees1` with authentic alpha.
- `Trees1.png` was imported into the user's E drive source cache with SHA256 verification, not recreated with image generation.
- Two scene trees are **derived separately** from authentic full trees in that Drive sheet: (1) large broadleaf A, original crop (0,0)-(267,297); (2) large broadleaf B, original crop (0,512)-(285,860). Crop alpha border <128 on all four edges. An 8px transparent margin is added, native pixels scaled by exactly 50% NEAREST, no blur; each has own SHA256 in scene manifest. These are new controlled reuse sprites, not bogus 32px crops.
- Two other scene instances use PixelLab's native transparent `128×160` custom tree candidate #02, clearly labeled as AI output, **not generated from the Drive `Trees1` reference**, since that paid job was queued before discovering the canonical Drive source. Future generated FS-specific art must condition on the actual full Drive sprites.
- All original user Drive sprites have UNKNOWN/RESTRICTED license provenance: private research use only. Do NOT put binary art on public GitHub or imply publication approval.

## Actual fresh PixelLab jobs / cost
- A27 native Pro V2 **544×416 opaque Ground** `A27_PIXELLAB_PRO_NATIVE_GROUND_ORIGINAL_544x416.png` SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`. Seed 162701, emphasis on naturally clustered low-growing flowers, short grass, tiny pebbles, natural uneven density and an unobstructed curved sand path. **25 generations**.
- Separate 128×160 **alpha transparent complete tree** Pro V2 job, seed 162703. Four returned alternatives, candidate #02 used as optional comparison. PixelLab full-tree output has no opaque image-border pixels, alpha min 0, content bounding (14,29,113,133). **15 generations**.
- A27 total charged cost **40 generations**. Account reported 1913 before, 1873 after; other credit history between A25 and A27 was not attributed to this stage. One accepted submission per job; all job IDs, source hashes, provider proof recorded in private state JSON files.
- **Do not relabel postprocessed image as original PixelLab**. The model-native Ground remains unmodified.

## Real layers, positioning, collision
- Ground = PixelLab original opaque 544×416 image. PAR = standalone 544×416 transparent compositing of 8 FS source objects (four rocks, two barrels, two lamps) plus 4 complete tree sprite instances: 2 derived from user Drive and 2 AI diagnostic candidates. No forest panorama strips, no artificial painted full-scene PAR. Full scene `A27_SCENE_MANIFEST.json`.
- PAR composition `A27_TRUE_PAR_RGBA_544x416.png`; final preview `A27_GROUND_PAR_FULL_DRIVE_TREES_COMPOSITE_544x416.png`.
- **Important bug caught and fixed in engine**: source image top-left placement (x,y) and tree-root depth footpoint (foot) were conflated, yielding 46,345 mismatched pixels against Pillow. Fixed with a y-sorted `Node2D` pivot at root and Sprite2D child at exact local offset to preserve image top-left positions.
- After repair, independent actual Godot full scene versus static alpha-composite has **2640 different RGB pixels / 226304 (1.1666%)**, MAE 0.01064 per 8-bit channel. Mismatches mainly overlap regions of original trees and props due dynamic y-sort vs static manifest order. This is **not** zero and pixel-exact formal gate remains OPEN.
- 32×32 grid 17×13=221: **12 blocked root/prop foot tiles, 209 walkable**, all 209 reachable from start, Ground globally walkable by default; canopy does not occupy collision cells.
- **8 actual native Godot 4.7.2 OpenGL frames**, with real original FS `$actor01`, two Drive tree front/back, PixelLab tree front/back, and road. All **7 actor foot tiles inside walkable cells**. Source renderer project isolated at `E:\FS_ROUTE_B_STAGE16_A27_PIXELLAB_GROUND_FULL_TREE_20261101\GODOT_A27_ISOLATED`.
- Binary old FS project and production sealed builds not touched. **No RPG Maker VX Game.exe verification**.

## Cold rebuild and errors
- First fresh cold run timed out: portable ZIP omitted required `assets/A27_SCENE_MANIFEST.json`. In fresh Godot it caused JSON parse failure, and the SceneTree stalled rather than quitting. Added required manifest to archive.
- Second package pass initially had duplicate manifest entry from previous attempt; corrected archive list to exclude existing manifest before writing it once.
- Final private archive `FS_STAGE16_A27_PIXEL_LAB_GROUND_USER_DRIVE_FULL_TREES_PRIVATE_20261101.zip`: **4,368,561 bytes**, SHA256 `d64f1a9e77b82016c6b600b56472f5aaa2acb9b46f2fd649ba7a5c0b3f804701`, **59 files**, archive CRC and per-file SHA checks. Independent fresh extraction to `E:\FS_STAGE16_A27_COLD_VERIFY_R2_20261101` with native Godot 4.7.2 GPU rerender **8 of 8 screenshot SHA256 exact match**. This is a re-render, not mere filename inspection.

## A27 final gates
| Gate | Result |
|---|---|
| PixelLab true 544×416 native Ground original | PASS |
| Richer low-profile naturally grouped ground flora | PRODUCED, aesthetic review pending |
| Transparent separate original FS PAR objects | PASS |
| Full Drive-sourced tree extraction and alpha edge QA | PASS 2 / 2 |
| Off-canvas tree cropping | NONE in revised A27 scene |
| Actual Godot independent PNG output | PASS 8 / 8 |
| Actor foot tile legal / BFS grid | PASS 7 / 7 actors, 209 / 209 walkable |
| Godot/Pillow pixel-exact | FAIL 2640 pixels (1.1666%) |
| Cold real native GPU re-render | PASS 8 / 8 SHA |
| User aesthetic acceptance / native VX | PENDING / NOT RUN |
| Formal Seal | NO |

## Preview and handoff
- User Drive A27 mobile preview folder: `https://drive.google.com/drive/folders/1h7s9EfLu1M3tzalzRKvsosQmZ-BM5-jd`; connector readback verified the 544×416 raw Ground, transparent PAR, composite and 8-case Godot native contact sheet.
- Private archive available on authorized Windows E drive, pending Drive binary ZIP synchronization.
- Next gate: user visual review at 1× vs Ground3, more diverse user-origin trees from 17-file Drive folder and diverse flat ground flora; for any further PixelLab tree generation reference the **real Drive full-size source**. Correct remaining 2640 draw-order diffs by deriving static composite from same depth order as actual Godot and explicitly validate no sprite geometry shifts. Isolated native VX runtime test still necessary. Do not claim full art PASS.
