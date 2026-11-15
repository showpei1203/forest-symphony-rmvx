# Forest Symphony | A50 R3/R4 FORMAL ENGINEERING HANDOFF | 2026-11-16

## Authority and reason
Godot 4.7.2 exclusive new development, 45 degree SE combat, 64x64 frames, Body/Weapon/FX separate. A42-A48 relied on Pillow part slicing causing repeated limb disconnections. A49 shifted to genuine PixelLab estimate 18 joints and Skeleton V3. A50 continues with original actual model assets rather than manual Body redraw.

## Real R3 weapon breakthrough
R3 is A49 R2 genuine PixelLab fullbody Body with extracted original provider sword F6-F10. Raw R2 split Body+Sword returns precisely original provider 64px RGBA each frame, zero differences. F6 rises, F7 slashes horizontally. Attack hit switched from old F6 0.55s to F7 0.63s, actual sword-tip local (29,7), same global collision. Old FX spark debris corrected; F6/F7/F8 minimal FX 1/3/1 px adheres to model blade. Genuine R3 Body remained original SHA256 61f9ed460613c414917845ad8b999e7f20fa791f58383bc288568cc551ecbb35.

## R4 identity-lock real PixelLab generation
R4 created 10 new fullbody RGBA PNG frames through PixelLab Skeleton V3 job 1c671687-681a-4667-a4e7-956b15fc7eae (one bounded paid call, 3.0 generations), preserving R1 nose/eyes/ears/neck six joints and R2 active shoulders, hips, sword arm and planted boots. Original canonical A62 image used as F0 and F11; ten R4 raw generated frames preserved exactly in Godot atlas (not repainted). R4 Body source SHA256 0c5a6a8314528bb9708c837bbf5d139aba1f383d756178b57bb1356e3cbe9605. R4 no accidental baked weapon. Reused genuine R2 provider-extracted sword with only F9 (-1,0) and F10 (-2,0) rigid weapon/FX alignment, Body never touched. Alpha-connected union Body+Weapon PASS all active frames.

Quality measurement at full pixel source and motion-aligned head: R2 293 to R4 141 accumulated changed head pixels; shoulders/chest 366->401 changed pixels; hip/legs 337->218. That is identity and motion improvement evidence, NOT ART PASS. PixelLab paid total A49 6.1 plus A50 R4 3.0 = 9.1 generations; no third blind retry.

## Native proof
Both isolated Godot 4.7.2 projects had real Windows GPU on RX6700XT, new cold editor asset import EXIT0, true 12 native GPU frames diff=0, no edge crops, 11 unique poses. F7 contact 0.63s (no hit at old 0.55s), 70ms Hitstop, return to A39 breathing idle, real practice target HP100->75->50, range miss, cancel before/during hit, serial dedup, double-speed PASS. Native logs under qa and head_lock_R4/qa_native; screenshots native_godot_a50 and native_godot_a50_r4. Full FS formal migrated ATB and enemy/skill systems NOT RUN.

## Evidence
- R2_ORIGINAL_PIXEL_LAB_PROVENANCE retains approved A62 image, provider original real Skeleton 18-joint raw response, A49 R1 and R2 exact inputs (no token), original R2 10 real model PNGs and separated silver sword.
- head_lock_R4 retains third paid API full raw response, locked submission ID, ten raw R4 model PNGs and complete bone input.
- Two Godot 4.7.2 projects godot_a50 and godot_a50_r4 contain all GDScript and runtime sprite atlases.
- Preview: preview_final/A50_R3_VS_R4_NATIVE_GODOT_SIDE_BY_SIDE_5X.gif, preview_final/A50_R4_TRUE_MODEL_SWORD_FULL_ATTACK_5X.gif, preview_final/A50_R3_VS_R4_NATIVE_GPU_12FRAME_3X.png and real damage screenshot.
- QA: A50_MODEL_WEAPON_SOURCE_AND_INTEGRATION_QA.json, qa/A50_PROVIDER_BLADE_AND_HEAD_STABILITY_QA.json, head_lock_R4/A50_R4_COMPARATIVE_REAL_MODEL_ART_QA.json, head_lock_R4/A50_R4_GODOT_WIRING_QA.json, A50_R3_R4_FINAL_NATIVE_QA.json, A50_FAILURE_LOG.md.

## Final gate and next stage
ENGINE PASS. Genuine fullbody model generation confirmed. Prefer R4 as current art candidate, but keep ART HOLD until user watches original 1x motion and approves actual battle aesthetics, notably sword weight, chibi face and perspective. Main formal FS Godot ATB NOT RUN. No fabricated native integration. Private artwork only on owner-only Drive; technical source and report to GitHub feature branch. A42-A49, E: RMVX, main, unrelated maps and migration branches untouched. Temporary Windows C: Godot copies purged after native tests.