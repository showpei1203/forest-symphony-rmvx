# Forest Symphony / ASF A09-2: native Joe seven-pose proof (2026-10-31)

**TECH PASS: original Tankentai pose extraction -> strict ASF clips -> real Godot 4.7.2 GPU -> exact RGBA pixel parity.**
**PENDING: a paired screenshot of actual RPG Maker VX RGSS2 combat / original weapon synchronization; human SBS visual acceptance; new model-generated source art.**

This folder adds evidence to A08/A09-1. Main K4, N5, R17, sealed scripts, D32A3a and LPC sources have **not** been edited.

## Character-to-pose authority, not filename guesses
- `Data/Actors.rvdata` parsed with Ruby Marshal 4.8 reader: **actor #1 = 喬伊 (Joe), character sheet `$actor01`, weapon ID 2**.
- The 230 shared Tankentai pose keys in `All_Scripts_Export.txt` include **7 poses named for Joe** and **zero required source-cell gaps** for Joe's original numbered sheets. All nine prior conditional gaps were from Taylor-named keys and **must not be described as Joe's confirmed bugs**.
- Each Joe key also occurs in other script locations, including movement/action-sequence definitions. This is static evidence, **not a fully instrumented runtime dispatch trace**, and unnamed/generic shared poses still need separate reachability analysis.

## Seven *original*, unchanged combat pose clips

Source: user's private K4 baseline `Graphics/Characters/$actor01_1.png`, `$actor01_2.png`, `$actor01_7.png`. Actual `FileNo`, `Row`, `Fixed`, `Speed`, `Loop` are read from Tankentai's own source table, not guessed. The fixed-frame summoning pose uses exactly one source frame; no fake four directions. All individual source sprites are 32x32 RGBA. All outputs use the existing 16,21 battler root.

| Clip | Original named pose | FileNo | Row | Fixed | RGSS frame ticks |
|---|---|---:|---:|---:|---:|
| p00 | Joe defend | 7 | 0 | -1 | 16 |
| p01 | Joe normal attack | 2 | 2 | -1 | 4 |
| p02 | Joe summon pose | 2 | 0 | 2 | 4 |
| p03 | Joe second normal attack | 7 | 1 | -1 | 4 |
| p04 | Joe cast/activate | 7 | 0 | -1 | 4 |
| p05 | Joe standby | 1 | 0 | -1 | 16 |
| p06 | Joe advance | 1 | 3 | -1 | 16 |

`scripts/build_actor1_real_poses.py` exports **7 independent clips**, **19 authored 32x32 frame entries** (not 4-direction guesses). Correct existing speed cadence is `(Speed + 1)` frames at 60 Hz; the v2 ASF manifest uses explicit `ticks`. `build_animation_clips.py --strict` returned **0 warnings**; `export_engine.py` generated Aseprite JSON, Godot SpriteFrames and Sprite3D, **7 clips / 19 frames / 1 atlas**, all parse-level export checks passed.

## Native real Godot GPU, no code-drawn substitute

Actual Radeon RX 6700 XT / Godot 4.7.2 OpenGL produced **two 1050x365 screenshots**. Each contains seven independently played clips, at 1× pixel size for measuring and 3× nearest-neighbor scale for visual review. The screenshot/Godot script lives under `scripts/capture_a09.gd`, and local actual captures were retained in the **PRIVATE Windows test ZIP**, not uploaded to a public repository.

`scripts/verify_a09_7poses.py` compared **14 source vs GPU 32x32 ROIs** (7 × 2 times), using source RGBA composited on the actual screenshot background. Every one matched a legally authored `FileNo/Row/Fixed` source cell: **mean absolute RGB error 0, max RGB error 0**.

Temporal changed-pixel counts:
- p00 defend 305; p01 attack 570; p02 fixed summon 0 **as required**; p03 attack2 588; p04 cast 304; p05 standby 433; p06 advance 429.

The GPU data are in [`data/native_7pose_rgba_parity.json`](data/native_7pose_rgba_parity.json). No generated artwork was added and no source RGB pixel was altered.

## VX native capture blocker: explicitly **NOT PASS**

A fully separate copy of K4 baseline (3,860 files / ~524.8 MiB) was created at `E:\GameAssetToolLab_20261023\ASF_Test_20261031\VX_A09_NATIVE_ISOLATED`. The cloned `Game.exe` actually launched; a 544x416 window remained alive and the original `$actor01.png` SHA remained unchanged. However, remote `ImageGrab.grab(window=hwnd)` returned **0 nonblack pixels**. Screen-region capture showed the unrelated foreground browser, not VX. Forcing `ShowWindow/SwitchToThisWindow/SetWindowPos/SetForegroundWindow` did not obtain focus (`foreground_ok=false`). [`data/capture_focus_diagnostic.json`](data/capture_focus_diagnostic.json) records this. **This does not demonstrate VX battle, weapon angle parity or screen-art approval**. Do not pass off the black window as a battle screenshot.

## Authority and isolation

- Actor #1 source `$actor01.png` SHA256: `df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5`.
- Original 32×32 body root (16,21), weapon IconSet ID2 24×24; RGSS -75,-15,+45 ↔ Godot +75,+15,-45 mapping carried over from previously SEALED G0-1B authority; **not newly proven in VX native mode**.
- No source image, atlas or gameplay image with uncleared rights published here. These GitHub artifacts contain code, metadata and numeric reports only.
- Complete **private Windows-local** ZIP: `E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031\ASF_A09_2_JOE_SEVEN_POSES_PRIVATE_20261031.zip`, **168 files / 1,390,183 bytes**, CRC PASS, SHA256 `18a35b92a9dd67428033f33d6e4d4b56d1c283e75a808a97d669d74e6a6a8a69`. This binary ZIP was **not uploaded** to Drive or GitHub.

## Repro and next gate

1. Validate original asset SHA and actor mapping, and execute `scripts/build_actor1_real_poses.py` using the frozen read-only source.
2. Run ASF `build_animation_clips.py --manifest a09_2_actor_poses/clips.json --output-dir NEW_EMPTY_DIR --strict`.
3. Run ASF `export_engine.py --clips NEW_EMPTY_DIR/animation-clips.json --target all --output-dir ANOTHER_EMPTY_DIR --name fs-joe-pose7 --sampling nearest`.
4. Open the exported Godot 4.7.2 test project and execute the validated `capture_a09.gd` test to produce GPU PNG, then run `verify_a09_7poses.py`.
5. **A09-3:** Establish a reliable, authorized interactive VX display/capture session and run the same real battle action (RGSS2 weapon pivot, mirror, event timing, 1:1 screen compare). Until it passes, keep native VX parity pending. Independently evaluate original-looking six-action master art and 4-facing extension; no new art or Script changes become formal without user visual approval.
