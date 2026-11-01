# Forest Symphony Stage16 A29 — Source-owned tree diversity and isolated VX bootstrap
Date: 2026-11-01 (Asia/Taipei)
**State: A29 original Ground+PAR Godot engineering provisional PASS; 8/8 cold-native-Godot SHA pass. Visual user approval pending; native RPG Maker VX map/occlusion/passability NOT TESTED; Formal Seal NO.**

## Source/authority references
- Permanent procedural authority: `authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md` (read before work).
- A28 starting point `STAGE16_A28_PAR_TONE_RENDER_HANDOFF_20261101.md`, original user Drive tree registry `FS_SOURCE_ASSET_LOCATION_REGISTRY_V1`.
- Ground unchanged from A27/A28 model native original, 544×416 PNG SHA256 `35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce`.
- A28 category-aware color tone method retained, no rescaling of Ground or loss of per-pixel alpha. New charged PixelLab generations **ZERO**. Do not touch sealed FS.

## A29 actual additions and exclusions
- Located real Drive Trees folder (17 original tree sprites indexed), independently retrieved Plants folder and tested source `Hanzo-VSFlowers01.png`. Reviewed on exact alpha, not only visual previews.
- New scene sprite from actual user Drive `1_Treee.png` (Drive file ID `1SgE5BjBTtQ3r9-E8JZCL7N60RAE_Wb_i`), SHA256 `ddf6b0cbe31362923d685cdde0ec8d830ba946966fcefc4bc37803616a31fc51`, source 208×192 RGBA. Original image is a **complete individually isolated** round-leaf tree; transparent alpha. Source edges [top0,bottom59,left0,right0] under threshold128; 8px transparent padding and exact NEAREST 60% produces 134×125 source-owned tree. Tone pass RGB-only keeps each alpha value identical. New sprite replaces duplicate PixelLab tree in southwest; new sprite rectangle x17,y252, actual root foot (84,372) stays unchanged.
- Current scene **4 whole trees**: 3 original Drive-derived trees (two from `Trees1.png`, one from `1_Treee.png`), one remaining earlier PixelLab isolated asset (clearly labeled). Original rocks, lamps, barrels retained, **12 independent PAR objects**. No fake panorama-strip tree objects.
- Rejected source candidate examples to prevent repeat mistakes: `tree variation.png` large candidate cropped at atlas edge (opaque >=128 on boundary); other `Trees1.png` manually guessed middle/right crops cut foliage/trunk (opaque edge detected); `tree01.png` pine rooted at bottom boundary 255 (incomplete); `Hanzo-VSTrees03.png` and flower atlas contain collection/patch assets not yet approved as single walkable ground-cover individuals. The flowers include raised bushes, **not permitted as invisible/no-collision Ground by default**. Source discovery does not mean using flawed candidates.
- A29 does not spend generations generating another tree to compensate for these rejections.

## Real Ground/PAR engineering evidence
- Raw PixelLab Ground is still byte-identical. A29 PAR is an actual transparent standalone PNG assembled from source-owned tree and prior object sprites using ascending footpoint y-sort, with a separate composite `A29_GROUND_PAR_REAL_DRIVE_DIVERSITY_544x416.png` and source manifest `A29_SOURCE_DIVERSITY_SCENE_MANIFEST.json`.
- Do not confuse picture x/y with footpoint. All trees 100% within 544×416 canvas; alpha clipping verification PASS for selected source.
- 17×13 = 221 tiles: 12 blocker foot cells, **209 walkable / 209 BFS-reachable**. All 7 actor test foot tiles are legal; canopy itself does not block ground.
- Ran actual native **Godot 4.7.2 OpenGL Compatibility** on user's RX 6700 XT, with real original FS `$actor01`, **8 native screenshots**: one no-actor, Drive tree front/back and actor on road.
- A29 native no-actor screen vs static PIL alpha-composite: **3473 pixel positions differ**, every per-channel RGB error at most **1/255**, **0 pixels error >1**. Therefore within tolerance PASS, pixel-perfect absolute zero difference still FAIL. All 7 actor cells legal.
- Cold independent full private ZIP extraction `E:\FS_STAGE16_A29_GODOT_COLD_20261101` and new native GPU Godot rerender: **8 / 8 screenshots SHA256 match original**. ZIP CRC and per-file SHA verified.
- Private ZIP: `FS_STAGE16_A29_DRIVE_SOURCE_DIVERSITY_NATIVE_GODOT_PRIVATE_20261101.zip`, size **4,980,965 bytes**, SHA256 `a8b8e265ae11ee8218bf8633bb9ed57e842b8cd9901e3cc388653f1f9b9c30b0`, 84 members. Includes reproducible renderer, source provenance, user-private sprites, quality checks; NO published binary sprites to public GitHub.

## Isolated RPG Maker VX bootstrap test: important blocker, not PASS
- Created **independent directory** `E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\VX_NATIVE_SMOKE_ISOLATED` from existing E-drive `VX_A09_3_INENGINE_BRIDGE` baseline. Full original Data/Graphics/Audio/Overlays cloned, original Game.exe, Data/Scripts.rvdata and Data/System.rvdata verified SHA256 unchanged. Separate `Game.ini` title `A29_VX_SANDBOX_ONLY`.
- Copied matching original TRGSSX.dll, TCap.dll, screenshot.dll from old baseline into isolate; before this, modal said TRGSSX.dll missing.
- Test executed **real native Game.exe** under Windows, window class `RGSS Player` and native modal `#32770` detected. Missing Graphics/Pictures/Locked resolved by full resource copy. Final observed native startup error is in prior baseline script `FS_BattleRegression_AIEdgeI v1.0` at line 2644: `NameError undefined method p45b_prepare_resources for class Module`. Neither original sealed baseline nor copied Scripts.rvdata was modified. 
- No A29 overlay has been registered as actual VX map; `Overlays/ground999.png` and `par999.png` are **staged files only**, not proof of native map display. **VX native map/occlusion/passability = BLOCKED / NOT TESTED**, do not conflate a live bootstrap window with successful map test.
- Avoid uploading the ~500MB VX independent clone by default; source stays private/local; QA and exact blocker text included in handoff. Continue with an independently working VX boot baseline or focused fix in a new sandbox, not a silent production script patch.

## QA table
| Gate | Result |
| --- | --- |
| Ground native PNG source SHA same | PASS |
| Ground model generation charges A29 | 0 |
| Indexed Drive source ownership and visible species difference | PASS 1 new species |
| Tree alpha edge and canvas geometry | PASS selected, candidate rejections logged |
| Pure transparent PAR + independent collision and fixed x/y/foot | PASS |
| Godot native GPU 8 screenshots, 7 valid actor feet | PASS |
| Godot vs static composite max RGB channel <=1 | PASS, 3473 changed positions |
| Cold independent Godot rebuild screenshot SHA | 8/8 PASS |
| VX Game.exe isolated window/bootstrap | RAN; script NameError blocker |
| VX map screen, sprite occlusion, movement | NOT TESTED |
| Final art / FS Ground3 reference approval | PENDING |
| Formal Seal | NO |

## Files / next stage
- Source local private A29 directory: `E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101`.
- Main `A29_GROUND_PAR_REAL_DRIVE_DIVERSITY_544x416.png`, alpha `A29_PAR_BALANCED_DRIVE_DIVERSITY_RGBA_544x416.png`, `A29_GODOT_NATIVE_8_SCREENS_CONTACT_1X.png`.
- QA `A29_BUILD_QA.json`, `A29_COLD_NATIVE_GODOT_QA.json`, `A29_NATIVE_VX_DIALOG_QA.json`, `A29_NATIVE_VX_WINDOW_QA.json`.
- A30 should focus on: (1) isolate a bootable VX runtime/script baseline while recording real scene screenshots, (2) test VX coordinate/alpha masks in a copied scene, (3) enrich flora only using source-owned genuine ground-hugging assets, never place raised bushes into Ground; (4) continue to improve art style without unnecessarily rebuying PixelLab generations, (5) update Drive+GitHub authority/handoff and keep Formal Seal NO until all gates.
