# ASF T1/T2 R2 actual engine validation | 2026-10-31

**Central project objective (unchanged): one AI-generated, visually approved, standalone master character or monster → generate genuinely new actions from that same master → Agent Sprite Forge builds transparent sprite animations and sprite sheets → Godot/VX import and human style gate.**

## Honest milestone

**The second half of the pipeline now PASSes on both new prototype characters, but the first half is still blocked.**

- T1: forest scout, **6 action clips / 24 RGBA frames**, 48x64 px, shared anchor (24,61).
- T2: plant creature, **5 action clips / 20 RGBA frames**, 48x48 px, shared anchor (24,45).
- **The 44 initial poses were already painted inside an AI-generated infographic**, NOT produced by single-master image-to-video. They were isolated, keyed and registered locally. The original image-generation tool **again returned a labeled infographic instead of an isolated master**. No claim of G1/G3 success is permitted.
- Per-action pixel palette quantization to 32 colours is an explicit finishing transform. Transport to the user's Windows machine was validated per image via **SHA256 of 44 actual RGBA arrays** against the locally quantized source. An earlier palette transfer which segmented a concatenated image by rows was wrong; discarded and logged as **TRANSPORT_ORDER_FAIL**.
- On Windows ASF pinned source `5324342fdfab`, **real CLI** `build_animation_clips.py --strict` successfully compiled T1=6 clips/24 frames, T2=5 clips/20 frames, **0 warnings** in both cases. This is not a self-written imitation.
- On Windows ASF `export_engine.py --target all` generated and parsed both Aseprite JSON atlases, Godot SpriteFrames and Godot Sprite3D, **one atlas per character**.
- On AMD RX6700XT real **Godot 4.7.2 OpenGL GPU render** loaded the *exported ASF Godot scenes*, played all **11 action clips**, captured A and B timestamps. Python compared **22 Godot 1:1 crop rectangles (11 x 2) with their exact corresponding 32-color source RGBA frames**, composited over the actual background: **22/22 max RGB difference 0**. Two timestamps changed pixels in **11/11** clips.
- Negative test: deliberately deleted `T1_hero/attack_02.png`, ran strict builder: exit code **1**, no published output directory. Fail-closed PASS.
- **Human art gate is NOT PASSED**: T1 attack has no clearly readable sword swing; T1 jump has no convincing air phase; T2 action identity needs independent inspection against official FS style. All 11 action clips remain *candidate*, not SEALED.
- Image-to-video route availability: `forge_doctor.py` shows image host tool available but **video route none** (no configured paid API and no local Grok CLI). **G3 absent**. Do not call the existing clips "single-master animated".
- **VX runtime on these T1/T2 prototypes NOT RUN**. Earlier VX A09 testing was separate and is not evidence of T1/T2 game integration.

## Gate status matrix

| Gate | Status |
|---|---|
| G1: real single-object AI master | FAIL: image generator returned report infographic |
| G2: fixed identity across AI motions | PENDING: independently painted poses, no master-lock proof |
| G3: source-master image-to-video poses | BLOCKED / NOT RUN: no video route |
| G4: alpha, consistent size, shared anchor | PASS TECH for 44 frame candidates |
| G5: real ASF strict clip compilation and all engine exports | **PASS TECH** |
| G6: actual engine import/animation | **Godot GPU PASS**, VX pending |
| G7: official FS pixel-art style and animation quality | **FAIL/PENDING** |

No formal asset acceptance until **all** gates pass; do not modify SEALED FS/R17/PMD/LPC.

## Reproducible tool command sequence (Windows)

```powershell
$root = 'E:\GameAssetToolLab_20261023\ASF_Test_20261031\T1T2_NEW_PIPELINE'
$tool = 'E:\GameAssetToolLab_20261023\ASF_SkillRegistry_20261030\generate2dsprite\scripts'
python "$root\decode_full_r2.py"
python "$tool\build_animation_clips.py" --manifest "$root\T1_hero\r2\clips.json" --output-dir "$root\T1_hero\r2\compiled_strict" --strict --preview-scale 3
python "$tool\build_animation_clips.py" --manifest "$root\T2_monster\r2\clips.json" --output-dir "$root\T2_monster\r2\compiled_strict" --strict --preview-scale 3
python "$tool\export_engine.py" --clips "$root\T1_hero\r2\compiled_strict\animation-clips.json" --target all --output-dir "$root\T1_hero\r2\engine_all" --name forest-scout-r2 --sampling nearest
python "$tool\export_engine.py" --clips "$root\T2_monster\r2\compiled_strict\animation-clips.json" --target all --output-dir "$root\T2_monster\r2\engine_all" --name sproutling-r2 --sampling nearest
# Godot 4.7.2 GUI-compatible OpenGL runtime:
# --path "$root" --script "res://capture_r2_godot.gd" --rendering-driver opengl3
python "$root\verify_r2_pixels.py"
python "$root\negative_test_r2.py"
```

The tool refuses an existing output directory: use fresh paths on rerun. The compact transport payload is stored locally only and is NOT in this public repo due to underlying asset rights. Public source can be reused if supplied approved private images.

## Evidence and artifact inventory

- Private real Windows **ASF engine bundle + Godot A/B screenshots + code, reviewed PNGs**: `E:\GameAssetToolLab_20261023\ASF_Test_20261031\T1T2_NEW_PIPELINE\R2_ASF_WINDOWS_PRIVATE_PACKAGE_20261031.zip`, **390 files, 1,771,745 bytes**, ZIP CRC PASS, SHA256 `5ac25bba32a95abc9be95a551b003fa2c1a35498d66c6c64a4b4b6865f36ecc0`. It is **local Windows only**, not uploaded to public GitHub or Drive.
- Conversation downloadable portable **32-colour frames / sheet / preview-GIF / manifest / standalone Godot sample scene**, plus report: `T1_T2_ASF_R2_REAL_ENGINE_TEST_20261031.zip`, **75 files, 539,784 bytes**, CRC PASS, SHA256 `fe702c4eb64346e1c1807215e2ed053a6b98a2b618a0b5746c3d5bb168fd6b40`. This chat-sandbox ZIP is NOT the complete original ASF compiled bundle; the user can retrieve that from the connected Windows device.
- Exact numeric QA: `data/R2_FORMAL_QA.json`, `data/R2_NATIVE_PIXEL_PARITY_QA.json`, `data/R2_NEGATIVE_FAILCLOSED_QA.json`, plus strict manifests and source scripts (text only).
- The first original composite was AI-generated, source extraction performed with Pillow/SciPy. Neither images nor thumbnails were uploaded to this public repo.

## Next task

1. Recover a clean **single subject Master** without poster, typography or fake PASS claims; true alpha or explicit solid chroma key. Use the saved T1/T2 candidate art strictly as identity reference until a brand-new master is approved.
2. Enable and verify a real i2v route and run **T1 idle only**, then its walk/attack/hurt. Treat every action as a new generation from the single identical master. On no-route, mark BLOCKED, do not invent video output.
3. Repeat T2 and visually reject any face/limb/weapon/leaf drift. Then run the same ASF strict compile + actual Godot/GPU parity, and only after visual approval test VX/Tankentai.
