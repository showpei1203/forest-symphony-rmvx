# FS A43 正式 Handoff（2026-11-01）：Moving to Close Attack 跑步 LOOP 修正

## 使用者糾正與上一階段錯誤
A42 generated as "wind up → step → plant" and looked like a Damage reaction. User rejected A42 and clarified exact run-loop semantics:
**[both feet neutral, step LEFT, both feet neutral, step RIGHT] repeated**.
Formal 3 stored sprites [F0=neutral,F1=left,F2=right]; playback time sequence **0,1,0,2**. Other loop-class action types include Waiting, Critical Damage and Magic Skill Use. These are distinct from non-loop ordered SEQUENCE actions.
No need to design a hero lunging forward or extra body-shift keyframes; pixel art should be a simple running cycle. SBS world-coordinate translation is a separate engine feature.

## A43 ACTUALLY produced
Source: A31 accepted native original-motion 45° styled candidate 160×40, A31_SE45_NATIVE_4FRAME_CYCLE_CANDIDATE.png, real PixelLab output derived from genuine original FS actor01 source. The old A31 four playback phases c0 c1 c2 c3 had c1 == c3 exactly at 40×40 RGBA pixel level.
A43 chose real source sprite columns **c1, c0, c2** (neutral, left, right) and wrote a new real 120×40 RGBA image with EXACTLY three stored frames. No painting, no resynthesis, no paid PixelLab calls, original source unaltered.
- A43_MOVING_TO_CLOSE_ATTACK_RUN_3FRAME_120x40.png: final 3-column candidate.
- A43_RUN_LOOP_PLAYBACK_0_1_0_2_8X.gif: **640×392 pixelated preview**, 4 playback phases but only three real stored sprites, infinite loop, 115 ms each.
- A43_MOVING_TO_CLOSE_ATTACK_3FRAME_LARGE_PREVIEW.png: label F0/F1/F2, large size 1050×435.
- A43_A42_FAIL_VS_CORRECT_RUN_LOOP.png: two rows 3 frames old rejected vs new.
- A43_RUN_LOOP_QA.json: real source file SHA, source-to-output columns, differences of neutral to left 426 pixels and neutral to right 420 pixels, left to right 218, bboxes, right/bottom no clipping.
- A43_LOOP_AND_SEQUENCE_RULES.md: authoritative corrected loop/sequence workflow.

## Validation
Format PASS: 40×40 per source cell, 120×40, RGBA, three columns, no edge cropping; A31 center c1 and c3 pixel-identical; GIF loop [0,1,0,2] with 4 time slices and loops forever. Larger visible preview fixes previous complaints about a 40px GIF appearing as a tiny person surrounded by browser black.
Art assessment: the step legs alternate from A31 actual source sprites (user approved A31 walk). **User has not yet formally reviewed A43 high-speed running playback.** The local SBS/VX paper-doll weapon overlays, actual worldspace movement toward target, and return-to-home are NOT TESTED. No formal engine PASS.
No additional paid generations, last known balance 1693.7 / 2000 after A42. This turn did not call PixelLab.

## Important loop-class finding
WAITING may remain three same neutral frames while looping. CRITICAL DAMAGE A40 "ready→impact→collapse" is currently a non-loop research pose and MUST NOT be blindly set to a repeating injured state, since it would visually revive and get hit again each cycle; later generate a genuine wounded-state 3-frame loop. MAGIC SKILL USE similarly requires its own 3-frame casting loop and external magic VFX, not a one-shot sprite baked with effects. This is an **unresolved art production task**, not already completed.
Dodging T4 remains the user's selected model. All original Forest Symphony, PMD and Tankentai SBS game assets remain unmodified. Do not regress A31 or A37.

## Next
After visual review A43, produce a minimal isolated VX/Tankentai SBS loop preview with actual frame index pattern, separate from game project, then wounded idle critical LOOP and magic chant LOOP with their own semantic pose design and image sources. Art/speed/camera/collision and weapon layering acceptance before formal engine integration.
