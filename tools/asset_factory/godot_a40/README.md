# FS A40 | 8-keypose native Godot ATTACK + AnimationPlayer hit timing
**2026-11-14 | TECH/GPU PASS; ART HOLD; full FS battle damage/ATB integration NOT_RUN.**

Continues A39, not a new unrelated demo. **Private complete source and approved pixel artwork:** https://drive.google.com/drive/folders/1DacQcC9htWs824sVLYfBGJpJp-wru2ih

## Working feature
- 64x64 Actor01, 8 frames, 4x2 atlas, 10fps, 0.80 sec, non-looping.
- Pose semantics: ready / brace / draw / windup / **contact F4** / follow-through / recover / settle.
- Native Godot AnimationPlayer TYPE_METHOD track calls `_on_attack_contact()` at **0.44 seconds**; battle-facing signal `attack_hit(serial, contact_second)`. No queued placeholder damage.
- A successful attack raises exactly one hit and one finished signal, then returns to A39 `idle_rig`.
- One active attack at a time. Early cancel prevents phantom hits; `attack_cancelled` raised if cancelled before contact. Playback multiplier scales atlas and event clock. Pause/resume tested.
- Original A38/A39 `run_raw`, `run_tuned`, `idle_raw`, `idle_r2`, `idle_calm` and native `idle_rig` all retained; no fake cast/hurt/death.
- Approved original source SHA256: `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`.
- Original A35 8-frame RUN SHA256: `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`.
- New A40 atlas SHA256: `ec4550458df647ba96b30f6640bccf6cd32aab31578e5bcb37d1961f9b7cb073`.

## Native GPU QA
Executed in a copy on private G: Drive with Godot **4.7.2**, AMD Radeon **RX 6700 XT**, OpenGL Compatibility, not Python imitation:
- Fresh Godot editor import: exit 0.
- `qa/a40_attack_runtime_gpu_qa.gd`: **exit 0**, real 0.44s event; normal, speed x2, precontact cancel, pause/resume, non-looped auto return.
- Native GPU captured all 8 frames; **7 unique** (F0 and F7 are exact same original pixel art by design).
- GPU 64x64 screenshots against every source atlas frame: **0 RGBA pixel differences for 8/8**; face and boots equal A62 originals.
- `qa/A40_REAL_GODOT_GPU_ATTACK_CONTACT.png` and `A40_REAL_GODOT_GPU_ATTACK_LOOP.gif` derive exclusively from actual captured Godot GPU frames.
- Original A39 source and A35 RUN SHA rechecked byte-identical against A40 copy.

## Reuse without overwriting
1. Recover the **owner-only A39 full Godot project** from its Drive ZIP or use the A40 owner-only full project above.
2. A40 overlay paths under `tools/asset_factory/godot_a40/` match the Godot root paths; the original graphics are not public.
3. If reproducing from A39: run `qa/a40_generate_attack.py` and `qa/a40_install_manifest.py` in a private Drive workspace only. Copy the A40 script/scene/QA text files and run Godot import.
4. Preview key `7` = ATTACK, key `6` = native breath, `Space` pause. Godot scene `scenes/battle_animation_preview.tscn`.
5. Technical QA: Godot --script res://qa/a40_attack_runtime_gpu_qa.gd under real GL Compatibility GPU. Never claim a headless import is visual QA.

## Gates
**TECH PASS / ART HOLD**. The arm-jab reconstruction is clearly distinct from idle and structurally repeatable, but full-body anticipation/lunge, impact weight, sword style, and player visual approval are outstanding. **Official migrated FS ATB/damage/skills integration NOT_RUN**. The hit signal is a prepared contract, not proof of real damage execution.

No writes to E: RMVX original. GitHub `main` and map/migration branches untouched. Paid PixelLab calls: **0**. Preserve failures and handoff.