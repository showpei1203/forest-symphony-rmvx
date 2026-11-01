# Forest Symphony Stage 16 — A29 detailed handoff / A30 execution contract

**Updated:** 2026-11-01 (Taiwan)  
**Branch of work:** FS pixel-art Ground/PAR, not the separate SBS sprite-sheet workflow.  
**Immutable predecessor:** A27 original PixelLab Ground → A28 reversible PAR RGB tone pass → A29 source-owned tree diversification.  
**A29 final:** Godot isolated engineering candidate PASS; native VX Game.exe launched in sandbox but **actual map + passability + occlusion NOT TESTED**; visual approval PENDING; **Formal Seal = NO**.

## 0. Non-negotiable start order

1. Read GitHub \`authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md\`.
2. Read Google Drive \`FS_SOURCE_ASSET_LOCATION_REGISTRY_V1\`, and relevant previous \`CURRENT_HANDOFF\`, A27 and A28.
3. Inspect real, complete, source-owned image assets in **Google Drive** before producing anything new. Do not search random local examples as if they were authoritative source trees.
4. Verify local A27/A28 SHA-256, alpha geometry and 544×416 pixel dimensions before edits.
5. Clone to an isolated A30 directory. Never modify existing sealed VX production, original model Ground, raw Drive source sheets, or A27/A28 outputs.
6. Keep \`formal_seal=NO\` until independent art, visual, Godot and **true** VX map tests pass.

**Public code/docs repository:** \`showpei1203/forest-symphony-rmvx\`  
**GitHub root for this stage:** \`experiments/route_b_25d_20261031_stage16/\`  
**Source Drive Trees folder:** https://drive.google.com/drive/folders/1Zth8u84_5-_pLTf-Ut_a86QiLBuhdaBw  
**Source Drive Plants folder:** https://drive.google.com/drive/folders/1lem9jNNVOqmpXMpu1Ns90bbuT6XtK59U  
**Source Drive Rocks folder:** https://drive.google.com/drive/folders/10gdWhmCjrZEroahJe8zeM90Q6wnjeYqI  
**Private A29 Google Drive:** https://drive.google.com/drive/folders/1Rqdo_qw1Vdvpfcx2a5iOf7joH83ncVtT

## 1. Directory authority / provenance

| Role | Real location |
|---|---|
| A27 source model scene | \`E:\FS_ROUTE_B_STAGE16_A27_PIXELLAB_GROUND_FULL_TREE_20261101\` |
| A28 tone+manifest baseline | \`E:\FS_ROUTE_B_STAGE16_A28_PAR_TONE_RENDER_20261101\` |
| A29 experimental output | \`E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\` |
| A29 isolated Godot project | \`E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\GODOT_A29_ISOLATED_SOURCE_DIVERSITY\` |
| Independent cold extraction | \`E:\FS_STAGE16_A29_GODOT_COLD_20261101\` |
| VX original **test baseline** (not sealed game) | \`E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_3_INENGINE_BRIDGE\` |
| Separate VX sandbox | \`E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\VX_NATIVE_SMOKE_ISOLATED\` |
| Synced Drive directory | \`G:\我的雲端硬碟\FS_ROUTE_B_STAGE16_20261031\STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\` |

The Drive original tree collection contains indexed sheets \`Trees1–4\`, \`Hanzo-VSTrees03/04\`, \`tree variation\`, etc. Real user-supplied files may have copyright or licensing restrictions: **private test only until proven cleared**. Commit procedures, hashes and logs to GitHub, not private sprites or full ZIP binaries.

## 2. Assets, transformations, and original-data invariants

### Ground
- A27 PixelLab Pro native full-scene **GROUND ONLY**, opaque 544×416; original file \`A27_PIXELLAB_PRO_NATIVE_GROUND_ORIGINAL_544x416.png\`.
- Locked SHA-256: \`35c454c82d4f32906de39702a8463ca72316b14e157239604c18971bd67d00ce\`.
- Contains organically clustered flat grass, small flowers, sand path, tiny pebbles; no tree or upright block. A28 and A29 did **not** regenerate or recolor the original Ground.
- A29 PixelLab generations charged = **0**. A27's earlier 40 generations are separate, historical baseline.

### Existing A28 PAR / tone
- \`A28_PAR_BASE_RGBA_544x416.png\` is kept original. Baseline SHA-256 \`f369f11b8cdb247e1f1cbb895c81bc6b9d8a998cacbb0131ad49a749dda4bea6\`.
- Reversible per-object RGB-only tone \`SOFT\` = 0.22, \`BALANCED\` = 0.46. Identical per-pixel alpha, unchanged transparent RGB, native nearest-neighbor pixel edges and object coordinates. Ground never repainted to match PAR.
- Quantitative leaf-to-grass RGB mean distance in A28: original 41.365, SOFT 22.872, BALANCED 13.885. **A number does not equal aesthetic approval**.
- Keep \`PAR_BASE\`, \`PAR_TONE\`, \`PAR_FINAL\`, per-object sprite source and preview independently; never flatten everything and claim layers are available.

### A29 true source-owned trees
- Previous A27: two big complete trees from **real Drive \`Trees1.png\`**, SHA \`d99c8bcc495b68ae1dc61e39047fb66ff7666dafaa704198d44e522fd0199635\`. Crops [0,0,267,297] and [0,512,285,860], padded 8px then resized using NEAREST 50%; positions and alpha remain manifest-controlled.
- New A29: **\`1_Treee.png\` from Drive** file ID \`1SgE5BjBTtQ3r9-E8JZCL7N60RAE_Wb_i\`, source 208×192 RGBA, SHA \`ddf6b0cbe31362923d685cdde0ec8d830ba946966fcefc4bc37803616a31fc51\`. Correct full source tree silhouette, boundary alpha [top 0, bottom 59, left 0, right 0]; threshold <128. 8px transparent border + nearest 60% → 134×125. New source sprite SHA \`d740093ac73067b876a5054145bd90e50451bb937e68f4d48fa00579dc23f344\`; toned variant SHA \`2d488ccbba56a498795fa7d2567a2ceb3f317ca3f6de28845ad7bf265bfd8ed3\`.
- The new A29 tree replaces an older PixelLab tree at \`x=17, y=252\`, foot \`(84,372)\` (collision/occlusion foot does not change).
- A29 inventory: **four total tree objects: three original Drive-derived + one existing PixelLab test tree**, as well as four rocks, two barrels, and two lamps = 12 independent objects.
- Do not say four Drive trees, and do not silently relabel the last PixelLab tree as a user-provided tree.
- Source \`Hanzo-VSFlowers01.png\` (Drive file ID \`1VTKD9xCNNagPsNXzLufhPy8Uj6B5NLxj\`, SHA \`3d39b5a25a75a886bba42380a567ab86aefd58e515d4ffb2ec109e5dcf50ddc3\`) was discovered and **not** automatically mixed into Ground because it includes raised shrubs and disconnected decorative arrangements.

### Rule: whole objects vs cut atlas
- Complete tree means canopy + trunk + root all present; alpha at asset boundaries <128, preferably transparent margin. The destination \`x/y\` sprite rectangle must be entirely on the 544×416 map.
- A29 rejected \`tree variation.png\` large atlas crop due to alpha touching boundary; several guessed \`Trees1.png\` segments with opaque boundaries; \`tree01.png\` (source 64×96, root touches bottom alpha 255); and complex \`Hanzo-VSTrees03.png\` clustering. **Do not solve crop failures by adding transparent padding around an already cut object.**
- A30 should inspect alpha-connected component geometry and original atlas positions, not repeatedly guess arbitrary rectangles and attempt to pass a cropped silhouette.

## 3. Core engineerable scene contract

- **GROUND** = continuous full-opaque 544×416 terrain, walkable default (except truly special terrain).
- **PAR** = original transparent object sprites in manifest; no trees baked into Ground. Depth-sorted static RGBA composite is a **preview**; dynamic real engine still uses individual sprites.
- **Scene manifest** = \`A29_SOURCE_DIVERSITY_SCENE_MANIFEST.json\`: authoritative image path, exact \`x/y\` top-left, sprite dimensions, original source metadata, \`foot\`, blocking and tone source. Do not generate scene-dependent images without it.
- **Y-sort** = parent pivot at foot, child offset \`x - foot.x\`, \`y - foot.y\`; do not use footpoint to alter global image position.
- **Collision** = 17×13 32px grid = 221 cells; 12 blocking **foot tiles**, 209 walkable, all 209 connected by BFS; canopy does NOT block the full visual silhouette.
- **Gameplay caveat**: collision model and snapshot foot legality are not equivalent to true interactive VX movement. Must not claim native VX collision PASS until the VX runtime executes those map coordinates.

## 4. Actual A29 test evidence and reproducibility

| Test | A29 measured result | What it does **not** prove |
|---|---|---|
| A29 independent Ground/PAR composite | \`A29_GROUND_PAR_REAL_DRIVE_DIVERSITY_544x416.png\` 544×416 | Dynamic front/behind |
| A29 alpha PAR | \`A29_PAR_BALANCED_DRIVE_DIVERSITY_RGBA_544x416.png\`, SHA \`bc78d1cca3935827edcb787e5ed7b7fbf1e023d2b8c2269f91e463bce24a7dd5\` | Art quality approval |
| Composite SHA | \`af2d180e04465e81d8270881e1760c1107b7d19e000f1003e6fb496b43345edb\` | Pixel-perfect engine equality |
| Godot 4.7.2 | **8 actual GPU OpenGL screenshots**, RX 6700 XT; \`A29_GODOT_NATIVE_8_SCREENS_CONTACT_1X.png\` | RPG Maker VX runtime |
| Actor foot legality | **7/7** legal walkable grid cells (original FS \`$actor01\`) | Motion simulation |
| Static composite vs Godot no actor | **3,473 pixel coordinates differ**, max RGB **1/255**, 0 pixels exceeding 1 | Literal 0-diff pixel-exact PASS |
| Cold independent rebuild | Unzip full private ZIP to fresh dir, re-run native Godot **8/8 screenshot SHA-256 exact matches** | VX or Ground3 visual acceptance |
| PixelLab charges A29 | **0 generations** | Commercial production readiness |

**Subtle test-coverage issue:** \`A29_BUILD_QA.json\` reports 0 changed pixels for \`A29_GODOT_03_DRIVE_EAST_BEHIND.png\` versus no actor. This likely means the actor is completely hidden by foliage: it proves hiding at this location, **but does not demonstrate a partly visible actor behind the crown**. A30 must include (a) behind-partial, (b) behind-full, (c) front-visible, (d) near trunk, (e) along-road walkable positions, recording actual overlaps and lawful feet. Don't relabel a zero-pixel case as an adequate occlusion-visibility test.

**Godot independent cold ZIP:** \`FS_STAGE16_A29_DRIVE_SOURCE_DIVERSITY_NATIVE_GODOT_PRIVATE_20261101.zip\`, **4,980,965 bytes**, SHA-256 \`a8b8e265ae11ee8218bf8633bb9ed57e842b8cd9901e3cc388653f1f9b9c30b0\`; **84 entries** with CRC and manifest SHA checks. Fresh executable re-render 8/8 SHA exact, exit 0. It is a **PRIVATE** artifact, stored in the user's Drive:
https://drive.google.com/file/d/1ZmHaqNYfV2qvQKKi0dLEsQeH7kJYEpTN/view

## 5. Real VX sandbox and exact failure chain

Sandbox: \`E:\FS_ROUTE_B_STAGE16_A29_SOURCE_DIVERSITY_VX_20261101\VX_NATIVE_SMOKE_ISOLATED\`. Source test baseline:
\`E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_3_INENGINE_BRIDGE\`.

**Sequence** (only in sandbox; no sealed project modification):
1. Initial isolated real \`Game.exe\` Windows window appeared but an alert reported missing \`TRGSSX.dll\`.
2. Copied \`TRGSSX.dll\`, \`TCap.dll\`, \`screenshot.dll\` from pre-existing test baseline with SHA checks.
3. Next error: missing \`Graphics/Pictures/Locked\`; resolved by full copy of original test baseline \`Graphics\`, \`Audio\`, \`Overlays\` into sandbox. The clone consumed many files (~2553 Graphics, 658 Audio, 91 original overlay files).
4. After resources were present, \`Game.exe\` genuinely reached old baseline RGSS2 scripts but stopped with:
   \`腳本節： 'FS_BattleRegression_AIEdgeI v1.0'，行號 2644：發生了 NameError。\`
   \`undefined method 'p45b_prepare_resources' for class 'Module'\`
5. Window class \`RGSS Player\`, modal \`#32770\`, UI text captured through Win32 window controls. This is **not** a displayed A29 map. The temporary \`Overlays/ground999.png\` and \`par999.png\` were staged only, **NOT registered to a VX map**.
6. Existing source baseline \`Game.exe\`, \`Data/Scripts.rvdata\`, and \`Data/System.rvdata\` SHA checked unchanged. Do not patch sealed production. Note that simple \`All_Scripts_Export.txt\` text search for \`p45b_prepare_resources\` returned zero hits, so don't claim the root cause or missing method definition has been fully established.

**Current VX gate: BLOCKED, map NOT TESTED, native character ordering NOT TESTED, native tile passage NOT TESTED.** The cloned baseline did launch, but the game's scene didn't reach gameplay. Preserve this precise distinction.

Next VX plan: in a **new sandbox copy**, locate a known reliably booting minimal RMVX test project, or use a documented isolated script inspection/fix. Preserve a byte-for-byte baseline and separate test patch with a diff/rollback record. Then attach explicit A29 Ground/PAR to a known test map and capture original VX screen for front/behind plus active movement; do not infer from Godot.

## 6. Failure register / regression-prevention (fail-closed)

| Failure class | Observed | Prevention / next gate |
|---|---|---|
| Full scene instead of actual Ground/PAR | Earlier non-engine image generation had no independent alpha layers | Reject flattened visual substitutes |
| Drive index ignored | A26 substituted generic 32px trees and sliced forest-edge PAR | Read canonical Drive tree registry first |
| Clipped tree fragments | A26 side-strip beyond canvas, A29 guessed atlas crops | Alpha edge, source sprite provenance and destination bounds tests |
| High flower bushes in flat Ground | Drive flora sheet includes vertical floral bushes | Classify low ground vs upright PAR before insertion |
| Footpoint confused with image x/y | A27 initial 46,345-pixel render mismatch | Pivot foot separately, child texture exact x/y |
| Wrong conclusion from tiny blending differences | A29 3,473 coordinates differ, max channel 1 | Record counts and actual per-channel max; don't claim 0 |
| Hidden character not inspected | East-behind case had 0 visible actor difference | Add partial-overlap test with explicit pixel evidence |
| Missing RGSS dependencies in isolate | \`TRGSSX.dll\`, \`Pictures/Locked\` missing initially | Copy clone dependencies, log list/hash, no source patch |
| Existing RGSS2 script error | \`FS_BattleRegression_AIEdgeI\` line 2644 NameError | Separate bootable VX sandbox or annotated test-only patch |
| False PASS status | Native VX merely opens a modal | Keep \`VX=BLOCKED\`, \`FormalSeal=NO\` |
| Failed image delivery | User could not see two-column picture in chat | Deliver a **mobile 544px-wide labeled vertical preview**, plus verified Drive link; don't rely on embedded image alone |

## 7. Deliverable map and image preview links

**Drive A29 folder:** https://drive.google.com/drive/folders/1Rqdo_qw1Vdvpfcx2a5iOf7joH83ncVtT  
**A29 raw 544×416 composite:** https://drive.google.com/file/d/1H2yJQfFD_Uuyh8joagmyN1RK5r6dqiOt/view  
**A29 true transparent PAR:** https://drive.google.com/file/d/1UgfdNy5mTR9z6EIQObbHoVbPo9ayXYw5/view  
**A29 actual Godot native 8-case contact sheet:** https://drive.google.com/file/d/1xUsht3VmU1yFzB7ugW2UHlsIG3jycc2h/view  
**A28 vs A29 two-column raw comparison:** https://drive.google.com/file/d/179qcXUYP561jHHKh0o9HerA0kPSZGI0o/view

**Mobile preview correction:** \`A28_A29_MOBILE_VERTICAL_COMPARE_544x934.png\` is generated from exact A28/A29 source halves, labels and layout only. Verified private Drive file ID `1X_vUXPvVrs4rIkNi6jSy-8BdcblmT3nr`: https://drive.google.com/file/d/1X_vUXPvVrs4rIkNi6jSy-8BdcblmT3nr/view . Source PNG 1088×416 unchanged; 544×934 mobile layout adds labels without modifying embedded scene pixels.

**Debug/QA files:**
\`A29_SOURCE_DIVERSITY_SCENE_MANIFEST.json\`,
\`A29_BUILD_QA.json\`,
\`A29_COLD_NATIVE_GODOT_QA.json\`,
\`A29_NATIVE_VX_DIALOG_QA.json\`,
\`A29_PRIVATE_DRIVE_SYNC_RECEIPT.json\`,
\`A29_SOURCE_PROBE.json\`.
Source code:
\`a29_build_source_owned_scene.py\`,
\`a29_native_qa.py\`,
\`a29_private_package_cold.py\`,
\`a29_vx_isolated_smoke.py\`,
\`a29_vx_dialog_diagnose.py\`,
\`a29_make_mobile_comparison.py\`.
Private full-stage ZIP retains per-object art and isolated Godot project. **Large ~500 MB VX isolated clone remains local and is intentionally not uploaded**.

## 8. A30 concrete acceptance plan (do not skip)

**A30 Gate A — true source inventory**
- Read registry + A29 manifest, enumerate original full trees / rocks / flora with exact Drive file IDs and alpha boundaries; choose intact, distinct species and clearly label AI fallback.
- Prove any added plant is ground-flush (non-blocking), else place in dynamic PAR with collision. Avoid mechanical uniform plant placement and preserve original model Ground semantics.

**A30 Gate B — map layers and tone**
- Preserve PixelLab Ground SHA \`35c454...\`; no PixelLab calls by default.
- Export new discrete sprites and source manifest \`x/y/foot/alpha/collision\`.
- Preserve per-pixel alpha and source original; support reversible A28 PAR tone options.
- Produce \`GROUND_ORIGINAL\`, \`PAR_BASE\`, \`PAR_TONE\`, \`PAR_FINAL\`, composite, and comparison preview; each must have a SHA.

**A30 Gate C — engine**
- Native Godot screenshots for no-actor, fully hidden behind, *partially visible behind*, visible in front, trunk left/right and road. Character foot must be on 32px walkable tile.
- Compare Godot no-actor vs depth-aligned PAR composite. Record raw differing coordinates, ratio, maximum channel error and count error >1. No interpolation.
- BFS must reach all declared walkable cells (A29 baseline 209/209); any collision alteration requires explicit footprint manifest update.

**A30 Gate D — real VX**
- First get an isolated RMVX Game.exe to complete startup with **no modal error**.
- Attach test map resources and map data explicitly; do not assume files called \`ground999\` are loaded.
- Screenshot genuine 544×416 in-game area with original FS actor and manipulate actor movement, verify front/back and blocked/walkable tiles, capture RGSS2 logs. Until then, **VX FAIL/BLOCKED**.

**A30 Gate E — cold rebuild and release**
- Write all scripted steps, candidate origins and failure reasons. Package a private ZIP with manifest per-file SHA and native screenshots. Unzip in **new** directory, re-run GPU and if available VX, prove rebuilt SHA.
- Sync Drive with per-file SHA readback and independently verify real Drive items. Commit docs/scripts only to GitHub.
- Upload/update \`CURRENT_HANDOFF\` with path, actual links, current status. **Do not claim Formal Seal** unless visuals and both engines fully pass.

## 9. Copy-paste-ready continuation message

「接續 Forest Symphony Stage16 A29 → A30。先讀 GitHub \`authority/FS_GROUND_PAR_SOURCE_FIRST_PRODUCTION_V1_20261101.md\`、本詳細 Handoff、\`CURRENT_HANDOFF_STAGE16_A29_20261101.md\`，與 Drive \`FS_SOURCE_ASSET_LOCATION_REGISTRY_V1\`。保留 A27 PixelLab 原生 Ground SHA，不把整張圖生成當 Ground/PAR。先處理隔離 VX Game.exe 的 RGSS2 NameError，完成真正 VX 地圖畫面與角色遮擋、通行測試；其餘 Ground/PAR 與 Godot 走來源可追溯、alpha 完整、x/y 與 foot 分離、零額度、冷重建驗收。全部真實結果同步 GitHub/Drive，A29 正式封版 = NO。」

---

**Last confirmed result:** A29 Godot / separate Ground+PAR / SHA cold rebuild **PASS**. User aesthetic approval **PENDING**. Native VX actual map **BLOCKED**. **Formal Seal = NO**.

## 10. Verified A29 current delivery links (authenticated Drive readback)

- Detailed A29 Handoff (this file, private Drive copy): https://drive.google.com/file/d/1yMZS6zdYazsMTXaZT60GTwovGfG41Fc3/view
- Revised CURRENT_HANDOFF (latest entry point): https://drive.google.com/file/d/1B-Lh39rEuqk_1zM-SM8-Ku3-I-aEZpAk/view
- **Mobile vertical 544px-wide A28→A29 comparison**: https://drive.google.com/file/d/1X_vUXPvVrs4rIkNi6jSy-8BdcblmT3nr/view
- Handoff + visual QA evidence mini ZIP: https://drive.google.com/file/d/1b219Y9__M5uZj77TudQmG3Vr0rncO0kR/view
- Private A29 stage folder: https://drive.google.com/drive/folders/1Rqdo_qw1Vdvpfcx2a5iOf7joH83ncVtT

This subsection was added *after* authenticated Drive readback verified exact file IDs and file sizes. The authoritative full private Godot ZIP remains separate (84 files; SHA in §4). Any later mini ZIP repackage must be hashed again and its manifest refreshed.
