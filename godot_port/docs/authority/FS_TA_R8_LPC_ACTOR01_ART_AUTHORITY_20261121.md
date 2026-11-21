# Forest Symphony｜T-A R8 正式美術與動作權威：LPC Skeleton × Approved ACTOR01 Identity

Date: 2026-11-21 (Asia/Taipei). Scope: ONLY `showpei1203/forest-symphony-rmvx`, branch `feat/fs-pixellab-ta-actor-20261121`, ACTOR01 RUN / ATTACK. Priority: user latest directive over former R1-R7 candidate methodology. Engine Godot 4.7.2 only.

## 1. Identity and animation authorities are separate
**MOTION = verified real LPC sprite skeletons and timing logic. VISUAL IDENTITY = original approved white-haired FS ACTOR01 art.** Never change actor identity to LPC armored/sword/shield/helm, never claim that repainting or moving just the sword constitutes a full-body attack, and never mistake RGB/SHA/GPU PASS for a satisfactory martial action. The hard goal is to use full-body head, torso, hips, shoulders, elbows, hands and feet POSE REFERENCES from LPC and redraw/retarget ACTOR01 with correct 45-degree top-down/3/4 FS battle angle.

### Approved LOCKED visual identity
- ACTOR01 A62 approved 64×64 idle pixel art, white spiky hair, face, green/dark battle outfit, boots; SHA256 `70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e`.
- ACTOR01 A52 genuine original 12×64×64 Body SHA `a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f`; original A52 Sword SHA `6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b`; FX SHA `46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c`.
- R6/R7 are historic *ART HOLD* references ONLY, NOT the R8 motion authority; preserve them unmodified. No reuse of R7 hand/weapon rotation schedule as a final attack without source-based LPC comparison.

### Authentic motion source / provenance
- Original upstream repository: https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator pinned historic snapshot `538641d9eb1b65ce3fd8b761446477a06ba07862` (2026-08-24 snapshot; the current upstream may differ).
- Historical local LPC Military 11-layer `custom:slash_128` approved source archive `TSG_P1C_LIBRESPRITE_LPC_11L_24F_EDITOR_20261024.zip`, SHA256 `5fbfc15c36e122d7bd38dcaafe2ca03f53e83330bd72338c1d6be18a2f3de582`, private Drive https://drive.google.com/file/d/1C0vaqsFkYxfIhxXUK8-0r0raqCdTrkFp/view . True 11 independent slots, 4 cardinal directions × 6 frames = 24; each output cell 128×128; body/head/hair/boots/etc original source elements 64×64 embedded at +32,+32. Official ASE tags slash_up/left/down/right. Only original `custom:slash_128` 11-slot origin source proven. Source archive is mixed license; original pixels and composed frames MUST stay PRIVATE Drive.
- Additional historical 18-animation **composited** motion reference: `TSG_P1_LPC_MILITARY_18ACTION_3PRESET_RECIPE_V1_20261024.zip`, SHA256 `e6d57dbb38e86a80001edd676754b4b432d710fd481841d531c181a97f9de0c7`, private Drive https://drive.google.com/file/d/1HpZ33mefXE2lD0sghYUJoy4a56pfUr2H/view . Includes `attack_slash`, `attack_backslash`, `attack_halfslash`, `custom:slash_128`, `custom:backslash_128`, `custom:halfslash_128`, `combat_idle`, `run` and more. **18 action COMPOSITES ≠ 147 independently verified original layer slots**; the 147-layer original archive was not recovered; do not claim it was.
- The source LPC four cardinal directions (`up`, `left`, `down`, `right`) are **NOT 45°**. R8 must combine *movement/keyframe SEMANTICS* from the most visually appropriate right/down source with approved ACTOR01 45° camera, while independently reviewing the actual pose before saying 45° PASS. No silent mirror/rename trick.

## 2. Required blocking changes / why R7 was rejected
- P0: body-led slash, NOT sword-led float. Each pose must show causal chain foot pressure → hip yaw/weight transfer → chest/shoulder rotation → elbow/wrist → sword movement → head/eye reaction and believable face acting. Action must have meaningful foot placement and weight shift, not lower body frozen below y=51. Keep ground-contact footpoint stable enough for gameplay; *feet may deform/change poses*, unlike R6/R7 fixed-feet rule.
- P1: real high guard with blade and hilt trajectory matching arm; head/torso follow windup and strike; weapon geometry must have a single clean hilt connected to hand, avoid duplicate sword and cropped arc. Preserve A52 sword material/color ID, but movement path derived from LPC reference.
- P2: frame-specific readable facial acting at 1×: focus, tension, exertion, recovery; no generic color-dot pretending to be expression; maintain white hair silhouette and face proportions.
- P3: source-respecting keypose timing sequence should be 12 frames with coherent start → anticipation → high guard → acceleration → strike/contact → follow-through → recovery → exact reset. Rig visual-only F7=0.630sec, hitstop metadata=70ms. HP/MP/damage remain controlled by existing FSBattle/ATB authority.
- P4: 12×64×64, atlas256×192, separately exported **Body / Weapon / FX**, alpha, no clipping, native-nearest, preserve original source SHA; do not overwrite A52/R7, main, T-B, T-C.

## 3. Deliverables and strict Gates
- R8a stage: genuine LPC pose-source review sheet, 12-pose keypoint manifest, 1×/4× Actor01 identity-vs-motion side-by-side and full 12-frame draft; keep draft as **ART HOLD**, not final.
- R8b stage: retarget/redraw ACTOR01 Body/Weapon/FX from source-based keypoints + **actual Godot 4.7.2 time playback** + 1× and 4× comparison, original F7 visual event. If any real original source stage is missing, mark it NOT RUN rather than substitute synthetic PASS.
- Gate S0 historical ZIP SHA/exact assets/licensing; S1 45° camera and original white-hair/green outfit and sword material; S2 true hip/shoulder/head/legs animation; S3 distinct expression and high-guard action, no fake wrist-only arc; S4 no broken joints/weapon contact/cropping; S5 actual continuous real PNG Godot render/one-shot contact; S6 user ART acceptance. S5 never implies S6.
- No PixelLab new job unless actual model interface is available; `NOT RUN` / additional spend 0 is honest. No extra source copyright material in public GitHub. Cloud rule: binaries, QA and private art to user-private Google Drive only; scripts/policy/Handoff/Failure Log to T-A branch; **no user PC writes**, even temporary, without prior express approval. Check Drive WRITE→READBACK and GitHub commit. Linear SHO-38 after work.
- Previous trajectory-only patching (R6/R7) is formally superseded as primary method. Two full alternatives max before change of approach; failures stay in log.

## 4. R8 animation keypose authority / working motion storyboard
LPC original `custom:slash_128` direction `right` uses F0-F5, additionally inspect `custom:backslash_128/right` and `attack_backslash/right` full-body stride. Sources 6-frame cardinal are references, NOT unmodified final 45° output.
1. R8 F0: ACTOR01 neutral 45° ready, white hair face and boots unchanged.
2. F1: step/set base, eyes focus, hips counter-rotate, hand starts to draw back; LPC right backslash F0.
3. F2: weight into back foot, torso coils, front shoulder counter-turn, elbow flex; LPC right slash F1, attack backslash F1.
4. F3: sword hilt passes shoulder/ear; head and eyes follow; LPC right slash F2 + high guard reference separate from LPC if LPC alone insufficient.
5. F4: full high-guard silhouette, sword overhead, both head/torso/arms AND stance clearly braced; if no LPC pose actually overhead, artist-authored bridge required, never falsely label reference as exact.
6. F5: hip initiates forward drive, blade begins accelerated down diagonal, eyes lock target; LPC slash right F3 / backslash right F1.
7. F6: main cut accelerates, shoulder leads elbow, sword arc between high-right and lower-left; LPC backslash right F2.
8. F7: strike/contact (visual only at .630 sec), full body lunge and blade tip follow-through, new expression; LPC backslash right F3 / slash right F4.
9. F8: momentum continuation, blade travels beyond target, recovery starts, feet re-balance; LPC backslash right F4.
10. F9: upper torso rotates back, elbow lowers and sword clears body; LPC slash right F5.
11. F10: step back to grounded guard, head/eyes recover; LPC attack_slash/right recovery.
12. F11: exactly same visual identity/pose as idle F0, no cut, loop-safe.
