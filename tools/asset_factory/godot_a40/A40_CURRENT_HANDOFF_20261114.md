# A40 CURRENT HANDOFF | 2026-11-14
**Status**: TECH PASS / Native GPU 4.7.2 PASS / ART HOLD / migrated FS battle ATB+damage NOT_RUN.

## Scope
Continuing A39 Actor01 controlled breathing with FIRST genuine nonloop ATTACK. A40 owner-only Google Drive folder: https://drive.google.com/drive/folders/1DacQcC9htWs824sVLYfBGJpJp-wru2ih . Parent is owner-only restricted binaries.

## Art/source contract
- A62 approved face/skin/head/boots kept intact. Source 64×64 SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`, same in A39 and A40.
- A35 RUN original atlas SHA256 `ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b`, same in A39 and A40.
- A40 256×128 8-frame new attack atlas SHA256 `ec4550458df647ba96b30f6640bccf6cd32aab31578e5bcb37d1961f9b7cb073`.
- Eight semantics: ready/brace/draw/windup/contact/follow-through/recover/settle; 10fps, 0.80sec, nonloop; 7 distinct GPU poses (F0 and F7 exactly equal to original).
- All 8 A40 Godot actual GPU RGBA images pixel-equal to their approved-source-based atlas cell (0 differences). Face y15..33 and boot y47..49 unchanged in source and in GPU.
- Art remains HOLD: needs more physical weight, leg step, full arm bones and potentially independent weapon, without losing 45° view or changing face.

## Engine and event
- Modified reusable `FSBattleActorAnimator`, explicit manifest `attack_slash`, real Godot `AnimationPlayer` `AttackClock`.
- METHOD track at t=0.44s invokes `_on_attack_contact` on actor itself; emits `attack_hit(serial, 0.44)`; no real damage is calculated.
- After nonloop finished, auto restores A39 `idle_rig` (tested). Prevent double-trigger, 2x speed, cancel before hit, pause/resume tested.
- A38 original five profiles and A39 native breathing remain available. Not implemented: cast/hurt/death, official FS battle systems.

## Actual test evidence
- Original desktop Godot 4.7.2 AMD RX6700XT Compatibility renderer.
- `--editor --import --quit` exit 0.
- `res://qa/a40_attack_runtime_gpu_qa.gd` exit 0: first hit only after 0.44s timeline, once each normal/speed2/resumed; no phantom cancel hit; 8 screenshots; 7 distinct poses; screenshot full battle scene.
- PIL audit after actual GPU exports: F0..F7 native framebuffer vs A40 atlas cell RGBA **all exact 0 changed pixels**; head & boots identical A62 source.
- Evidence under private folder `qa/output/A40_NATIVE_GPU_ATTACK_F00..F07.png`, `qa/A40_REAL_GODOT_GPU_ATTACK_CONTACT.png`, `qa/A40_REAL_GODOT_GPU_ATTACK_LOOP.gif`.
- Failures and fixes: mask foot boundary and AnimationPlayer root-node path; `qa/A40_FAILURE_LOG.md`.
- First successful preview cannot replace canonical FS Battle art until owner visual review; maintain **ART HOLD**.

## Cloud policy and next actions
- No E: RMVX project edits. No public art upload; no modification to GitHub `main`, `feature/fs-godot-phase1`, or map branch. Private Drive and branch `feat/fs-asset-factory-v1-20261107` only.
- Need next A41: refine full-body 45° actual sword/physical weight across multi-keypose attack, formal effect anchor/target timing, then wire A40 `attack_hit` into actual Godot migration branch's ATB/battle state only after dedicated integration test.
- Must continue Source/QA/Failure Log/Handoff and real native test screenshots before claiming completion.