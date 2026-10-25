# FS Shared Art Pipeline | F2 + P2R1 Verified Isolated Technical Candidates
Date: 2026-10-25 | Branch: `feature/ai-art-toolchain-pilot-20261025`

## Frozen accepted authority
- F1R1 A04 forest: `F1R1_REFERENCE_ACCEPTED / USER_VISUAL_PASS`. Canonical ZIP SHA-256 `0a407d9dce66183703fe957193a396cc59648d3b4502cd0c83e4f83e3035272b`. Do not modify.
- F2 and P2R1 are **new isolated candidates** and have **no user Human Visual Gate F approval**. Existing other-conversation FS map or P1G monster project, LPC and sealed mainline all untouched.

## F2: complete NEW house integrated into accepted Forest Ground
- Isolated source `E:/GameAssetToolLab_20261023/TOOLCHAIN_PILOT_20261025/outputs/FS_F2_COTTAGE_SOURCE_FIRST_20261025`.
- Private [F2 full source, native VX, Godot, Tiled, ZIP](https://drive.google.com/file/d/1Wwj43fa2rMu08zhUd-0LRfwPUAa3qZ0G/view?usp=drivesdk).
- [F2 composed visual](https://drive.google.com/file/d/1YyQCDJc4svCGAGEN1eG-47BMHgJlMa9u/view?usp=drivesdk) | [uncropped new cottage sprite](https://drive.google.com/file/d/13KvgOxFqb5Ndlv6BDbQBFoHv_JcH5viW/view?usp=drivesdk).
- New house source is **original hand-coded procedural pixel geometry** with fully transparent 4 image edges, coherent roof/walls and distinct authoring masks for roof occlusion and contact-only collision. F1R1 approved Ground and 8 prior props reused, sign and rock positions adjusted in **separate** F2 manifest; 9 independent props total; 544×416, 32px grid. **No PixelLab/SpriteCook paid image generation used.**
- Ground is walkable by default; semantic wall-foot mask excludes the 32px doorway and front cell, contact blocking is 25 grid cells, 196/196 ground free cells reachable.
- ASF `map_bundle.v2`, native Tiled `tmxrasterizer` (metadata visually hidden but not deleted), Godot 4.7.2 AMD RX6700XT OpenGL 3.3 actual GPU rendering each **0 RGBA px difference** versus composed source.
- Native Godot 221/221 cells physics, Y-sort actor behind cottage 0 visible purple px and in front 384 px.
- Actually executed isolated **RPG Maker VX Game.exe** with RGSS2 `F2_VX_NATIVE_221_221_PASS`, 25 blocked/196 walkable, props=9, move/deny/camera PASS.
- ZIP: `FS_F2_NEW_COTTAGE_SOURCE_TILED_GODOT_VX_20261025.zip` **10,243,493 bytes**, SHA-256 `91565e7ac9b36480c66b9a9292c57af6a595710f8323e9d9bbb682d5fc5322ba`, CRC & independent cold-extract file hashes and source QA PASS. **Fresh cold unzip native Godot and original VX binary both re-executed PASS**. CMD to start both game engines and Tiled, CMD for quick source QA, logs, source, masks, manifest and handoff inside ZIP.
- Gate: `TECH_PASS / HUMAN_ART_PENDING` (not published to formal Forest Symphony).

## P2R1: ORIGINAL new 3-stage Moss Drake sprite family
- [Private full P2R1 ZIP](https://drive.google.com/file/d/1hOWsq2Dkh28h50gIkj2RPOgR5MxkokyX/view?usp=drivesdk) | [Style review montage](https://drive.google.com/file/d/1RL180WPWGyDYWnqlwqp2c03GMRk1oKbr/view?usp=drivesdk) | [Actual Godot native GPU screenshot](https://drive.google.com/file/d/1nIZny3iPpVw5z_rq3-X9vyim_PYAIFdb/view?usp=drivesdk).
- Original hand-coded chibi art, common teal/cream/amber palette, shared amber forehead diamond/antler family genetics, increasingly developed forest/leaf morphology. These are **not** sprites from PixelLab AI service, nor the parallel P1G branch. No paid credits, account keys or user subscriptions used.
- Juvenile, adult, final: **3 stages × 6 128×128 frames** (Idle×3 + Attack×3) = 18 frames. **7 editable component PNG layers** per stage and 384×256 (3 cols×2 rows) sheets.
- Every frame nonempty, matched source sheet pixels, zero nontransparent corner/edge crop after revision, seven-layer idle source recompiles exactly. Frame completeness, alpha edges, montage and anatomy source gates PASS.
- Actual Godot 4.7.2 AMD RX6700XT OpenGL3.3 GPU screenshots rendered for Idle0/Idle1/Attack1; captures demonstrably different. **Fresh cold extracted native Godot relaunch and GPU capture PASS**. Interactive demo SPACE=Attack, otherwise Idle.
- ZIP: `P2R1_ORIGINAL_3STAGE_MOSS_DRAKE_ANIMATION_20261025.zip`, **129,392 bytes**, SHA-256 `7ee1b6469ea28799eae2e6f6e72817317934cb9857d2df5fc9226eb728730f1b`, 119 files; CRC, cold SHA, frame+Godot QA PASS. Includes source generator, seven layers/stage, 18 PNG, stage sheets, native Godot project/launch CMD, logs, README and CURRENT_HANDOFF.
- Important: `HUMAN_ART_PENDING / VX_SBS_NOT_TESTED`. These are actual 2D sources but not yet complete Tankentai-compatible 3-action animation rigs.

## Failure taxonomy / preventive guardrails
1. F2 original collision mask doorway too narrow; VX footbox clipped entrance tile (7,5). First F2 failed output preserved; semantic wall-foot exclusion widened; door tile & front both PASS.
2. First F2 Godot imported textures asynchronously; missing `.ctex` produced stdout success but no valid imagery. Re-run native after verified import and explicitly compare actual PNG RGB+alpha.
3. P2 first character family sprites: 7 frames touched canvas edges at adult attacking nose/final-stage snout. First P2 source and staging both retained as FAIL; P2R1 revised cranial anatomy and all 18 edge checks PASS.
4. First cold-engine tester on cp950 Windows terminal raised UnicodeEncodeError while printing import log. Fixed output to ASCII-safe representation; **re-ran and passed actual cold native** without clearing any genuine failure record.
5. Do not equate cross-engine 0px drift with objective game art beauty, new house/creature Human Gate F, VX SBS runtime, or commercial rights. Existing F1R1 user Visual PASS is not inherited.

## Required next work
1. User visual review of F2 house (roof-wall style, scale, doorway/pixel crisp) and P2R1 evolution family (3-stage distinctiveness, actions) before formal art promotion.
2. Stress new roof occlusion with actor positions and clear door ingress; extend scene to varied houses, water/holes on separately authored mask and multiheight *only after style checks*.
3. Integrate isolated P2R1 Idle and Attack into Godot battle canary then RPG Maker VX Tankentai SBS convention; **real native battle actions** and palette/part stability before production.
4. Preserve user-approved F1R1 baseline; every new version ZIP, quick CMD, source manifest, previous fail logs, GitHub+Drive+Linear current handoff. Never touch active P1G files.
