# Forest Symphony｜P538E TRUE owner-original Godot 4.7.2 MENU GPU screenshot acceptance & fixes｜2026-11-24

**Project/workline:** FS (Forest Symphony) main original RPG Maker VX→Godot 4.7.2 migration, branch `feature/fs-godot-phase1`. T-A actor/T-B monster/T-C map pipelines not touched. Godot is the new official user-chosen production engine; older FS Skill saying VX is main engine is superseded only for migration engine choice. Original VX stays read-only.

## M1｜Real source and engine in the SAME private isolated runtime

Previous P538D blockers were real but now removed without touching owner PC:
1. Use **existing official pinned Godot4.7.2 binary** from GitHub-hosted Actions #45285924622 public artifact `fs-p536-public-godot472-engine` ID `14872195477`. Downloaded using GitHub Connector `download_workflow_artifact` (nested Actions ZIP `godot.zip`) into ChatGPT isolated Linux space. Real binary `Godot_v4.7.2-stable_linux.x86_64 --version` reported **`4.7.2.stable.official.ed1daf0bf`**. This replaces failed direct GitHub-release DNS access; no installation on user PC, no Codex.
2. Extract matching complete source Godot project from run #45285924622 public artifact `fs-p536-public-source` ID `14872580349`; this already includes P538D source & capture test.
3. Original private owner Drive ZIP `1OCeiV5ZZyxBUrZypIxI8UJv2ytHywbnT`, verified archive SHA256 **`c08ea693542e30f66586c6031016e7d7765f52c61ea5515c001e00079aeee9f6`** and correct 202 PNG manifest. Existing **`godot_port/tools/stage_private_ui_535.py`** dry-run PASS, stage PASS (202 records); native Godot `--editor --headless --import` generated private `.godot` texture imports. All operations in isolated Linux ephemeral workspace, never owner `E:\\`.
4. Use existing **real** `godot_port/tests/capture_fs_p538d_private.gd` under Xvfb with `--rendering-driver opengl3`, `--audio-driver Dummy`, explicitly `FS_PRIVATE_UI_QA=1`, only pre-existing approved temporary private directories; true Mesa **OpenGL 4.5, llvmpipe (LLVM 19.1.7)** renderer. Captured **11 original sprite-backed Godot viewport PNG at 544×416 and 11 at 1088×832** for baseline P538D. The larger frames are genuine Godot viewports, not offline PIL resizing.
5. **Real first-pass screenshot FAIL**: R0 STATUS values were near-black text over original original dark STATUS window; R0 HBox heading wrapped vertical Chinese characters; actor portrait on SKILLS/EQUIPMENT overprinted source `Description` title; synthetic QA status banner at bottom overprinted original footer.
6. **Actual FIX commit `f03bc2770a8d0a834bb926c66dede8be77ab342d`** (`FSOriginalMenuPage.gd`): STATUS data labels switched to high-contrast white `Color(0.92,0.97,0.95)` on true original black; heading replaced flex HBox with fixed source-safe Label at x144/y23 and no-wrap, source Back separately at x436/y73; actor selector moved to x213/y49 avoiding source tabs y78; skills/equip portrait reduced to x25,y16 size 82×88, no original Description overlap; synthetic QA/error feedback moved from source footer y402 to header safe x254,y22. Unknown/disabled mechanics remain fail-closed.
7. Re-ran **the same genuine PRIVATE Godot OpenGL capture** on actual fixed local source for **11+11 R1 screenshots**, all source SHA / six actor identities PASS. Local source `git hash-object FSOriginalMenuPage.gd` returned **`17cf6f434b0c8cce7a75ae6907dd6b1358ee19c0`**, exactly matching GitHub blob for commit `f03bc277`. No confusion about local vs committed code.

## M2｜Official Godot 4.7.2 reproducibility

- Native offline isolated `test_fs_p538d_original_party_slots.gd` PASS after UI fixes. 
- New public-source native regression `godot_port/tests/test_fs_p538e_original_ui_visual_regressions.gd` at commit `728a37584b8ee53ef845756380b1a41a303d8f9e`, uses **only generated colored textures** (never public private images) and exercises STATUS/SKILLS/ITEMS/EQUIP at both viewports, source page title no-wrap, original back button separate, STATUS bright typography, feedback safe area, source Descrip portrait bottom ≤108, tabs unoccluded, independent actor 2 portrait.
- GitHub Actions workflow adds P538E native guard commit `6c55d23aef1647797f49b8371852c390b1c9a189`; **official complete pinned Godot 4.7.2 CI #45301488209 SUCCESS, 101/101 workflow steps**. Link: https://github.com/showpei1203/forest-symphony-rmvx/actions/runs/45301488209 . This includes all P538A/B/C/D native regressions and source project integration. **Important distinction:** Github public CI uses safe synthetic color fixtures; original actual 44 screenshot proof is in private Drive, run by real Godot in isolated cloud, not shipped on public GitHub.

## M3｜Measured source screenshot FAIL→FIX (not invented)

- 544×416 STATUS numerical ROI (x169..334, y153..238): source R0 real Godot screenshot **0 bright numeric text pixels**; source R1 after commit **706**. Strong evidence of fixing unreadable black-on-black source STATUS data.
- 544×416 SKILLS original `Description` banner (x0..146, y108..143) compared against unchanged owner `MenuBack_skill.png`: R0 **1,358 modified/overprinted source pixels**; R1 **0**. This proves source label no longer covered by actor portrait.
- Heading wrap fixed visually by R0/R1 actual 544 & 1088 Godot captures. Additional deterministic native regression assertions added to stop reintroduction.
- No other mock-made FAIL: actual screenshot outputs all produced successfully in both runs; original Same-State VX 1:1 still not proven.

## M4｜Owner-only ORIGINAL native evidence uploaded and provider readback

**New private binary archive:** [FS_P538E_GODOT472_REAL_ORIGINAL_UI_NATIVE_20261124.zip](https://drive.google.com/file/d/16wtWALH4oJvrPIfxfAoYKGwoDwnK0GLp/view) Google Drive file **`16wtWALH4oJvrPIfxfAoYKGwoDwnK0GLp`**, in existing restricted-binaries folder `1_OAbjQ8-fsjli0jRv7EYDnQu629CUJms`, `shared=false`.

- ZIP **5,327,631 bytes**, SHA256 **`f64212d6140e56c4eda6ea90409d454745b439bda4f96dddd448ab4af055b9ca`**, ZIP CRC PASS, **51 files**. Authenticated upload success followed by Google Drive metadata `shared=false` and **real Drive download hash/CRC readback** matching byte-for-byte.
- **44 real ORIGINAL-sprite Godot screenshots:** R0 11×544 +11×1088, R1 11×544 +11×1088; plus 5 source-native before/after contact comparison PNG, QA JSON Manifest with hashes/engine provenance, README HOLD (51 total). Pages include MENU, STATUS, SKILLS, ITEMS, ITEM TARGETS, EQUIP, EQUIP CANDIDATES, FORMATION SIX ACTORS, SELECT FIRST, SWAP SIXTH, MIA actor2 STATUS. All image fingerprints included; code/manifest textual authority remains GitHub.
- Real original PNG binaries are still only on owner Drive, **not** pushed into GitHub. No owner-PC process/storage or extra software installs. Source 202 images are unmodified.

## Explicit gates still HOLD

- **Original sprite/native screenshot Gate:** upgraded from P538D `NOT RUN` to **PASS (22 R1 actual software-OpenGL source-view captures)**. This proves source PNG hash authenticity and Godot rendering, NOT original VX same-state pixel-parity/acceptance.
- **True VX runtime same-state screenshot comparison**: HOLD. The state/hp/mp, portraits and source art appear in Godot, but original VX exact typeface, windowskin semantics, frame placement and 1:1 matching not demonstrated. Need authorized source VX runtime screenshots, different from existing P538A source.
- **Original `FS_DB_AUTOSET.apply_all` final effective 11 tables/505 RGSS2 aliases**: HOLD. All sampled actor values synthetic.
- **User actual RX6700XT** physical GPU QA & final art approval: HOLD. This run is isolated Mesa llvmpipe.
- Unsupported Quest/Save/System, skill effects/subtabs: fail-closed; not fully migrated. Main engine Godot 4.7.2 unchanged. **Phase1 SEAL NO**.
- **Next whole P538F unit**: (a) 1:1 same-state original VX reference from authorized read-only runtime or existing Cloud-only witness; (b) original 11-table postApply engine data evidence; (c) use P538E 44 actual renderer images as permanent R0/R1 baseline for typography/WindowSkin parity; (d) continue functional migration beyond menu with original effective semantics instead of producing more decorative UI revisions. Continue M1→M2→M3→M4 and archive QA once.
