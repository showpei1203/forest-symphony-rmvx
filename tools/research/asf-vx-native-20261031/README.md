# ASF × Forest Symphony native Kaduki/Tankentai test | 2026-10-31

**Scope: PRIVATE ART ON USER'S WINDOWS PC; PUBLIC REPOSITORY STORES ONLY CODE, SCHEMA AND HASH/QA.**
**Status: ASF original-asset 4-facing animation adapter TECH PASS; Godot 4.7.2 real GPU pixel parity PASS; NEW native VX Game.exe execution NOT RUN; human SBS art acceptance NOT CLAIMED.**

## Actual authenticated source
- Read-only source K4 baseline: `E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE`.
- `Graphics/Characters/$actor01.png` 96x128 pixels, 3x4 Kaduki frames of exactly 32x32, 12 valid cells. SHA256 `df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5`.
- `Graphics/System/IconSet.png` original SHA256 `8273bc643025f92496a7471cf080cd6a87d0a762fc04731c7f016e00f0c0bb2c`, icon #2 crop x48 y0 w24 h24.
- Source file authority read from Drive `TANKENTAI_COMPATIBILITY_RULES_G0_1B_PASS_20260821`: body root **(16,21)** not foot row (16,32), Godot AnimatedSprite2D has `centered=false` and `offset=(-16,-21)`, orientation order down/left/right/up, RGSS angle to Godot sign invert, actual visible `VERT_SWING` RGSS [-75,-15,+45] -> Godot [+75,+15,-45], weapon pivot bottom-right.
- Source `$actor01_5.png` **5/12** occupied grid cells, `$actor01_7.png` **6/12**. Treat those numbered action sheets as sparse; do not invent missing orientations or silently export full four-direction animations.

## Real executed tests

1. [`scripts/build_native_adapter.py`](scripts/build_native_adapter.py) copied **12** RGBA cells byte-pixel-identical from the user's original sheet into isolated work space and wrote [`data/clips.v2.json`](data/clips.v2.json) with **8** clips: four facing `idle_*` and four `walk_*`. Walk sequence uses actual 3-column authored poses 1→0→1→2, duration 150 ms per sample. No AI image generation, no reillustration, no scale/interpolation. Input original source and IconSet checksums persisted.
2. `build_animation_clips.py` from installed ASF repository parsed original 12 32x32 frames, **8 clips**, zero warnings, result `needs-visual-review` (tool does not grant human visual PASS).
3. ASF `export_engine.py` exported **Aseprite JSON** and **Godot SpriteFrames/atlas**, each export PASS self-parse.
4. Windows Godot **4.7.2**, actual AMD Radeon RX 6700 XT OpenGL 3.3 graphical render, 560×340 GPU capture at two different time points, source-native figure positions. [`scripts/vx_native_capture.gd`](scripts/vx_native_capture.gd) loads 8 clips and overlays original icon #2 in 3 configurations. Captures were stored in isolated local folder.
5. [`scripts/compare_native.py`](scripts/compare_native.py) compared exact source RGBA frames composited over actual RGB screenshot background with **8 Godot crop ROIs (4 directions × 2 instants)**: **MAE 0.0 and max channel error 0 in all eight**. A captures original col1, B col2. Time-separated pixel differences down=471, left=384, right=384, up=370. Full numeric evidence: [`data/native_godot_parity_report.json`](data/native_godot_parity_report.json).
6. Negative gate [`scripts/negative_missing_frame_specific.py`](scripts/negative_missing_frame_specific.py) reproduced **11 of 12 required source frames with only down-0 missing**, verified ASF emits non-zero error and **does not publish** any output. [`data/negative_test_result.json`](data/negative_test_result.json).
7. Source K4 baseline checked again post-test for SHA unchanged; original sealed source never modified. [`data/run_qa.json`](data/run_qa.json).

## Critical boundaries

- **This does not prove six new original-FS-style actions.** The earlier six-action code-art SVG model, and this real-FS 4-direction sheet, are different tests. You cannot combine their PASS counts to claim a new native-quality FS actor with six actions.
- **This does not constitute a fresh native RPG Maker VX battle parity run.** Prior G0-1B compatible mapping was applied and drawn in Godot, but original VX battle rendering and weapon overlap need another native test in isolated build and visual approval.
- Exported `.tres` uses original image atlas; no original sprites or cropped icons may be published in this public GitHub branch until rights verified. This is deliberate; reproducible script plus SHA is the public artifact, while local evidence ZIP keeps authorized source images.
- No changes to sealed FS N5, Map900, 505 Scripts, Tankentai D32A3a, LPC v0.5/v0.6 or R17 Ground/PAR pipeline.

## Portable local bundle (NOT uploaded as ZIP)

`E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031\ASF_FS_VX_NATIVE_ADAPTER_TEST_20261031.zip`
- 95 files; **457,291 bytes**; CRC PASS; SHA256 `a8b942a9a1e78fe93cd7d1793d20584504bdecf9f35f31dee092d39bb95de3bb`.
- Local-only encrypted? **No**. Private original art included. DO NOT upload it to a public repository or imply Drive backup completed.

## Handoff / next task

Match numbered `$actor01_1...` to actual Tankentai action rules from Script Authority, reject incomplete directions on _5/_7, then build a **separate** native VX battle preview with original sealed source and exact body/weapon pivot. Only after parity at runtime, test ASF-assisted **new** FS-style animation as a fresh candidate, with human visual approval and exact RGBA/weapon identity across all actions. Keep all work under the isolated lab and collect paired screenshots as evidence.
