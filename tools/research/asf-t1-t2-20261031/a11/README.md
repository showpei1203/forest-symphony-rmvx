# Forest Symphony / ASF A11 - Layered Rig Attack Candidate (2026-10-31)

**Status: A11 TECH PASS (ASF and Godot); ART GATE NOT PASS; image-to-video NOT RUN.** This is an isolated test branch. K4/N5/R17 maps, Tankentai, LPC, PMD and all SEALED content are unchanged.

## Correct project goal

AI generates **one Master character/monster**, animation tools use identity-preserving transformations or generation to produce game-ready transparent frames, ASF `build_animation_clips.py` and `export_engine.py` compile sprite sheets and animations, then Godot/VX and human visual tests decide acceptance.

A10 proved source-pixel-only full-body warp could produce 11 legal clips, but the scout's attack was not a sword stroke. A11 therefore upgrades **only two attack actions**, preserving the other nine A10 actions.

## What A11 actually generated

- **T1 Forest Scout:** a single unchanged A10 Master supplies body, face, garments and right arm; a hand-authored mask isolates the near-arm, shoulder pivot rotates it, and a **separate short-sword accessory cropped from a second, previously AI-generated attack-pose image** rotates around the inferred wrist. 8 new 96×112 PNG attack frames. **This is one actor master + accessory, NOT a pure single-image input**. Original sheathed sword is still painted on the clothing and the arm looks stiff, therefore visual approval is pending.
- **T2 Moss-Antler:** every pixel originates from the original A10 one Master, transformed as a coherent body charging/lunging. 8 new 96×96 attack frames, 7 unique (first and last are the intentionally identical rest frame). Initial independent head/antler segmentation caused floating leaves/horn fragments; it was **rejected** and replaced by coherent rigid transform. Still a somewhat stiff attack, not articulated paw motion.
- Both have binary RGBA alpha, content without cropped canvas edges, 1x pixel sources, and deterministic manifests. The T1 sword introduces additional source colours; no false claim that all T1 frames use only pixels from Master.

## Actual ASF and GPU run, not a mock

On the user's authorized Windows machine (AMD RX 6700 XT), A11 isolated working root:
`E:\GameAssetToolLab_20261023\ASF_Test_20261031\A11_LAYERED_RIG`

Frames transferred through independently verified lossless RGBA-zlib packets; **16/16 byte-pixel SHA256 checks PASS** before replacing attack frames. All other original A10 frames and clips were copied into the isolated test without editing A10.

| Tool/gate | T1 scout | T2 creature |
|---|---|---|
| Source frames in full A11 animation set | 46 | 38 |
| Actions | 6 | 5 |
| Revised attack | 8 frames | 8 frames |
| ASF strict `build_animation_clips.py` | PASS, 0 warnings | PASS, 0 warnings |
| ASF `export_engine.py --target all` | Aseprite JSON, Godot SpriteFrames/3D PASS | same, PASS |
| Godot true runtime | Godot 4.7.2 / AMD OpenGL | same |

Godot 4.7.2 rendered all **11** exported ASF clips in **two 1170x430 native GPU frames**, using the original nearest sampling. The screenshot pixels were compared to the correct referenced 1x source PNG via the source manifest and `clip.frames[frame]` mapping, with compositing over the same background: **22/22 native ROI comparisons exact; max RGB delta 0**. This proves import and animation pixel transport, NOT anatomical quality.

Fail-closed negative: remove `attack_03.png` from a separate copy of T1, run ASF `--strict` → **exit 1; no output directory**. PASS.

## Numeric differences are not art quality

T1 average RGBA pixels changed from frame 0: A10 1082.75 → A11 1561.0. T2: 1277.88 → 1547.88. That shows greater pose displacement; it is **not evidence** that the character is anatomically better. T1's sword stroke is now visible but the hands are stiff; T2's limbs are not really galloping. **G7 stays NOT PASSED.**

## Provenance and private artifacts

The local source code `scripts/rig_a11.py`, `scripts/extract_weapon.py` and all QA JSONs are published here; screenshots, original PNGs, cropped sword pixels, and derived sprite graphics stay in private artifacts.

- Conversation downloadable candidate ZIP: `A11_LAYERED_RIG_ATTACK_CANDIDATES_20261031.zip`, 34 files, 249,787 bytes, CRC PASS, SHA256 `450f7a0a398bd49d0e57f7dcc53bdef5d1aed45d8445daf6f5bd4134ebc4c8ed`. Contains 16 new attack frames, comparison charts, source tools, GIFs and accessory.
- Complete PRIVATE Windows ASF compiled atlas, engine project and GPU captures: `E:\GameAssetToolLab_20261023\ASF_Test_20261031\A11_LAYERED_RIG\A11_WINDOWS_COMPLETE_PRIVATE_20261031.zip`, **627 files, 2,653,930 bytes**, CRC PASS, SHA256 `75da6c8e33b17b9d2149c6985ad6579096fa678646c02da6cc39bb47870277fa`. The private binary ZIP has **NOT** been uploaded to Google Drive or public GitHub.
- The local scripts require the prior A10 Master files and a separate sword accessory to regenerate the image pixels; source images are not publicly committed, per asset provenance.

## Gate decisions and A12 next

G1 single Master: prior A10 identity PASS TECH, two original Masters unchanged.
G2 source identity: T1 single body Master + externally sourced blade; T2 single creature Master, deterministic.
G3-RIG: two attack candidate motions generated. **G3-I2V model route: NOT RUN**.
G4 transparency/registration: TECH PASS.
G5 ASF strict and all targets: TECH PASS.
G6 Godot real GPU: TECH PASS 22/22 exact; new VX art import NOT RUN.
G7 FS visual animation: PENDING/FAIL for fully natural strike and four-legged locomotion. **No formal SEALED.**

A12: further separate the right-hand from the scabbard, implement a physically plausible arm-weapon held pose (or use an AI model-generated attack keyframe rather than warping the idle body), and animate quadruped front/rear legs. Evaluate `JatCool/AI-Sprite-Animation` as an optional Unity test only after verifying compatible Unity Editor installation (project requires Unity 6000.6; this machine has Unity Hub but editor version not established). The community `comfyui-rinsei` reports Wan2.2 I2V running on RX6700 XT via custom ROCm; **not installed or validated locally**; do not replace Windows GPU drivers or download heavy models without separate controlled installation plan.

Stop calling ASF compilation “AI-generated video motions”. Continue stage-by-stage fail-closed audit.
