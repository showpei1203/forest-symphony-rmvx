# FS A41 | Weighted Sword Strike, ONE Godot Timeline for Pose + Hit
**2026-11-14 | Godot 4.7.2 native GPU TECH PASS / Art HOLD / FS migrated battle NOT_RUN**

Continues A39 RUN/IDLE/native breathing and A40 ATTACK prototype without overwriting either source.
- Private Drive: complete self-contained Godot project **FS_A41_GODOT_WEIGHTED_SWORD_ATTACK_20261114** inside FS_AI_ASSET_FACTORY_Restricted_Binaries.
- Public GitHub branch: text source and reproducible QA ONLY, no private art binaries.
- A62 approved original SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`; unchanged. A35 original eight-frame RUN SHA256 `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`; unchanged.
- New private atlas: `assets/actor01_attack_weighted_sword_12frames.png` SHA256 `2621b31f53abdca251049f8d9dc740971e3d610f3de860e26ca2998ddd987746`, 256x192 RGBA, 4x3 grid of 64x64 cells, 12 frames/11 unique.
- Native pixel rig: independent legs, upper-body lean/shift, weapon-arm wrist, 45° original perspective and native-palette steel/gold sword drawn into 12 poses. 0 AI generation and no new RGB/antialias; A62 face/skin template copied rigidly.
- **ONE AnimationPlayer authoritative attack timeline**: `AnimatedSprite2D:frame` keys 0..11 at 12 fps and SAME AnimationPlayer METHOD key `_on_attack_contact()` t=0.55, at visible frame F6. Avoid separate atlas vs event time clocks.
- Actor emits `attack_hit(serial, 0.55)` (A40-compatible), **`attack_contact_anchor(serial, local, world)`** new precise origin: local `Vector2(28,11)`, with world anchor honoring actor transform. Cancellation before contact doesn't hit; speed2 hit at F6, pause/resume and no repeat all verified.
- Attack 1.0 second non-loop, then returns to A39 Shader `idle_rig`. RUN/IDLE A38 profiles remain; cast/hurt/death unavailable and do not substitute.

## Evidence
- Real AMD RX 6700 XT / Godot 4.7.2 Compatibility GPU; editor import EXIT=0.
- `qa/a41_weighted_runtime_gpu_qa.gd` actual GPU QA EXIT=0, tests RUN/IDLE/attack profiles, 2x/cancel/pause/dummy receiver, 12 independent GPU captures.
- `qa/a41_native_gpu_review.py`: image-by-image compares Godot-rendered RGBA to the private source 4x3 atlas: **0 pixel differences across all 12**; 11 distinct rendered poses, all alpha binary, no native boundary clipping, approved A62/ A35 original SHA unchanged.
- `qa/A41_NATIVE_GODOT_GPU_12FRAME_CONTACT.png` and `qa/A41_NATIVE_GODOT_GPU_ATTACK.gif` come from actual Godot GPU frames, NOT PIL substitute for rendering.
- See `qa/A41_FAILURE_LOG.md` for four bugs actually found and resolved, including the critical multi-clock hit drift.

## Honest acceptance
- TECH PASS (Godot 4.7.2 running code, events, GPU pixel exact).
- ART HOLD: stylized pixel sword/weight-shift is an experimental revision, not final artist-approved pose.
- True migrated FS battle (ATB, target acquisition, hurtboxes, damage, skills, enemy stats) NOT_RUN. Dummy contact verifies event contract, not gameplay feature completion.
- Use preview scene `scenes/battle_animation_preview.tscn`, key `7` for A41 weighted sword, `6` A39 idle, space pause.
- Only G: mounted private Drive for persistent artifacts, no E: RMVX write, GitHub `main` untouched.