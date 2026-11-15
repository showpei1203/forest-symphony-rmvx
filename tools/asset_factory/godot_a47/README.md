# Forest Symphony A42 | Native Godot 3-layer Attack + F6 Hitstop
**2026-11-14: Engine/GPU TECH PASS; ART HOLD; migrated FS ATB/combat integration NOT RUN.**

## Actual implementation
Continues real A41 12-pose sword animation and A39 reusable native idle. It does **not** regenerate the approved Actor01 face, armor or legs. The same A41 approved source is separated into three independently editable 4x3 RGBA sprite atlases of 64x64 frames:
- `assets/actor01_a42_body_12frames.png` 12 poses
- `assets/actor01_a42_weapon_12frames.png` 12 poses
- `assets/actor01_a42_fx_12frames.png` 12 poses, source contains 2 unique states
All three can be rendered separately in Godot via `AnimatedSprite2D` nodes `AnimatedSprite2D`, `WeaponSprite`, `EffectSprite`, or independently disabled using `set_weapon_enabled()`/`set_fx_enabled()`. Godot AnimationPlayer drives three synchronized `frame` tracks plus one METHOD hit callback, all on the **same authoritative 1.0-second clock**. At 0.55s visible pose **F6**, actor emits `attack_hit(serial, 0.55)` and `attack_contact_anchor(serial, local, world)`. Active successful attacks then freeze animation for a 70ms native hitstop, after which speed resumes. At animation end it returns to existing A39 `idle_rig`. Cancel and mid-hit listener interruption do not generate delayed phantom hits/freeze idle.

## Repeatable source-locked 45-degree rig
The pose sequence was exported as `qa/A42_POSE_RIG_45DEG_V1.json` with wrist, sword-tip, torso, both-foot offsets, effect flags and F6 event marker. `qa/a42_extract_layers.py` consumes and verifies this data matches the A41 signed 12-pose baseline; does not silently retarget arbitrary future bodies. A new actor with different proportions will require explicit landmark retarget and art acceptance.

## Real verification
- Source A62 SHA256: `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`; A35 RUN: `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`, both unchanged.
- A41 source atlas SHA256 `2621b31f53abdca251049f8d9dc740971e3d610f3de860e26ca2998ddd987746`, unchanged.
- Private A42 3-layer atlas SHA256 values are in `qa/A42_LAYER_SOURCE_AUDIT.json`.
- Native Godot 4.7.2 RX 6700 XT OpenGL real GPU 12/12 frames compare **0 RGBA pixel differences** against A41 single-layer atlas. All 11 unique original poses retained. GPU captures `qa/output/A42_NATIVE_GPU_ALL_LAYERS_F00..F11.png`.
- Actual Godot signal/clock QA confirms F6 event, 70ms freeze and release, x2 speed, cancelled windup, manual pause and resume, immediate cancellation by external hit listener, no abandoned FX or post-cancel hit.
- Godot GPU F6 with weapon and FX disabled individually: captured results equal reference body and body+weapon native source **0 pixel differences**, reenable 3-layer roundtrip matches exactly. `qa/A42_NATIVE_GPU_LAYER_TOGGLE_AB.png`, `qa/A42_REAL_GPU_12_FRAME_CONTACT.png` and `qa/A42_REAL_GPU_BODY_WEAPON_FX.gif` are derived from actual Godot GPU captures.
- Original A38 five atlas RUN/IDLE profiles and A39 native breathing remain available.

## Files, preview and gates
- Private owner-only A42 complete runnable project under `FS_AI_ASSET_FACTORY_Restricted_Binaries/FS_A42_GODOT_SEPARATE_WEAPON_FX_HITSTOP_20261114`.
- Godot scene `scenes/battle_animation_preview.tscn`: key `7` attack, `8` toggle weapon, `9` toggle FX, `6` A39 idle, Space pause.
- `qa/a42_native_gpu_runtime_qa.gd` is the ACTUAL Godot GPU test; `qa/a42_native_gpu_review.py` inspects actual captures, not a substitute renderer.
- **TECH PASS, ART HOLD:** The artwork intentionally matches A41 exactly; separation improves editability and timing, **not yet user-approved visual quality**. Weapon hand anatomy, swing weight and new artistic effects still require review.
- **FS migration combat NOT_RUN:** no official ATB, targeting, damage/HP, skills or hurtboxes attached. A42 retains a tested signal contract rather than fake gameplay success.
- Cloud-only: no writes to E: original RMVX project; no edits to GitHub main, maps or Godot migration branches; no paid PixelLab generation.