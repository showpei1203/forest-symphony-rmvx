# F1R1 — Source-first new forest generated (2026-10-25)

## Evidence scope and preservation
- This is a **NEW** scene candidate, not the previous FS V21 544×416 remake. V21 map was used only as pixel-style texture training; its source Ground bitmap was not copied as F1 Ground.
- Technical stack: Seeded deterministic 32px patch quilting (non-blurry hard ownership seams), 1000 approved-source grass + 1000 dirt patches, newly drawn crossroad topology, approved **reused** 8 separate private props, independent semantic source files.
- This is *procedural recombination of old style pixels*, NOT a claim PixelLab/other paid image models drew new monster or custom props. Private test rights only. Source artwork license still needs a commercial rights assessment.
- All changes isolated `E:/GameAssetToolLab_20261023/TOOLCHAIN_PILOT_20261025`; no sealed FS, P1G or LPC binaries/scripts modified.

## Art/source metrics
- F1 original Ground differs from FS V21 old Ground in **226301/226304 pixels** (ratio ~99.999%). New geometry + road; not simply shifting old Ground.
- F1 first preview showed 191 pixel mismatch in lower-right tree+well overlap: input object order did not match ASF foot-anchor Y-sort. Explicitly mark F1 FAILED; F1R1 corrected with canonical Y-sort authority and preserved F1 failure.
- F1R1: 544×416 RGBA, VX 32×32 tile, 8 distinct *placed* independent source props (3 trees, 2 rocks, well, sign, hedge), 18 contact-blocked tiles, 203 walkable out of 221.
- Whole map recomposition Ground+PAR = master at exact RGBA diff **0** after correction.
- ASF `generate2dmap.map_bundle.v2` validation 0 errors; *warning* actorRadius 0 is intentional because tile collision is already footbox sampled by source FS scene rules, avoid double inflation.
- 17×13 tile centers 221/221 blocked parity; BFS from spawn (8,11) reaches 203/203 walkable cells.
- Tiled 1.12.2 exporter + built-in verification and actual native `tmxrasterizer.exe` all **0 RGBA pixel** diff with reference; collision and interaction object layers preserved but hidden visually to avoid spawn-marker pollution.
- Godot 4.7.2 actual AMD RX6700XT OpenGL3.3 GPU capture (544×416): 0 RGBA diff vs F1R1 rendered reference, after waiting for texture import.
- Godot physics API native point intersection: **221/221** grid centers match authoritative blocked 18 + walkable 203; human walkability test additionally available via cyan temporary playable actor.
- Godot native Y-sort: behind the tree 6 purple test pixels exposed, front 384, expected PASS.

## Failure ledger that must NOT be lost
1. F1 unsorted art compositor caused 191 wrong pixels; repaired in F1R1, not simply ignored.
2. Godot GPU capture script printed `CAPTURE_OK` while image resources initially failed to load; only compare actual exported screenshots to reference pixels after valid texture import. Never accept CLI exit=0 alone.
3. Initial physics canary used `Node` but called `get_world_2d`; wrong node/script type persisted. Corrected to Node2D + root Node2D.
4. JSON parse key conversion produced floating numeric `9.0` vs integer string `9`. Normalized integers. Native 221-grid signed log PASS.
5. Windows PowerShell `Tee-Object` emitted **UTF-16 LE** log; original Python QA misread as UTF-8 and failed. Add BOM-aware text decode. Retain failed staging directory.
6. A03.1 cold extraction needed `Godot --headless --path PROJECT --import` before scene launch. F1R1 repeats this cold start.

## Deliverables and handoff
- Private [Google Drive ZIP](https://drive.google.com/file/d/1A-N5OvQJRFXG3JVGaUCscl-g39H8Zf7w/view?usp=drivesdk): `FS_F1R1_NEW_GROUND_ASF_TILED_GODOT_PLAYABLE_20261025.zip`, **8,210,922 bytes**, **134 members**, SHA256 `28109ddacd408dd56441b166221e7e67347452879c6c76edb92f8740efd606c5`, CRC PASS; cold-extract all payload files checksum and **22/22 QA** PASS. Cold-unzip Godot native import+221/221 physics PASS after re-import.
- [Candidate new scene preview](https://drive.google.com/file/d/1WN_nrasfKVbhG-iQ4f2e_GtlDHWc_L5F/view?usp=drivesdk), [pure Ground](https://drive.google.com/file/d/1Z_8gRhkX-VSKRGNu0kR68VJL-nNL713s/view?usp=drivesdk), [real GPU](https://drive.google.com/file/d/12MunVjT2M43vvQFiUZoRyPXUdYAX9yen/view?usp=drivesdk).
- Four helper batch scripts: `START_F1R1_GODOT.cmd`, `OPEN_F1R1_TILED.cmd`, `RUN_F1R1_QA.cmd`, `RUN_F1R1_NATIVE_PHYSICS.cmd`.
- Includes source structure, original approved source-style reference (private), new Ground generator & Y-sort correction, manifest, RGBA reference renders, Tiled TMJ, Godot source, GPU images, checks, README, CURRENT_HANDOFF and NEXT_CHAT_PROMPT.
- Status: **TECH_PASS / HUMAN_VISUAL_PENDING / VX_NATIVE_PENDING**. Do NOT claim final art PASS, commercial rights or full Forest Symphony executable.

## Next milestones (priority)
1. Human artwork acceptance of new Ground’s crispness, grass/dirt naturalness, source style and tree/well occlusion at native 1:1.
2. Negative 1px shift/artifact checks in ongoing scene assembly. Convert scene from static 32px collision to full VX Game_Map native and repeat paths, no regressions to official other-conversation map branch.
3. Isolated new "juvenile → adult → elder" original monster 3-stage Source DNA/Idle/Attack art pilot using approved style guide. As provider credentials are NOT authorized, do not spend PixelLab/SpriteCook/AutoSprite credits; use already available OSS stylization tools or isolate a provider when user authorizes.
4. Keep failure taxonomy, ZIP, local CMD, Drive, GitHub and Linear synchronized, no sealed changes.
