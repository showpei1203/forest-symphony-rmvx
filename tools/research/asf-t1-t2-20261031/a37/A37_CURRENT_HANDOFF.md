# A37 Handoff: selected Dodging T4 + Damage PixelLab B/C tests (2026-11-01)

## User decision
User says '第4種，繼續製作' responding to A36 four 3-frame Dodging variants.
Lock T4 ANTICIPATE→ROLL→LAND, never revert to T3 or A35 18 frames.
T4 source is exactly A36 variant four, itself true A35 PixelLab source A02/A06/B07, 120x40 RGBA 3×40px, byte-identical to original T4. Standalone one-shot GIF 3 real frames, no GIF infinite loop, SHA bfc51f2656690f56b59a944620b9432883d959e3894bc301057605d5770f112a.

## New production: Damage real PixelLab trials, each strictly 3 frames
B (job fe856ee1-582f-4588-ae5d-a752867ccc2a, 10 generations): /transfer-outfit-v2, 3 input frames native battle view master F0/F2 + A33 genuine reference-controlled Damage F1, 3 true PixelLab results 40x40, output sheet 120x40. PASS source/geometry, ART FAIL because head mostly bows and hit recoil is too weak.
C (job 9bdfcd3b-fed5-4ece-a1bf-d2e31514e0ae, 10 generations): /edit-animation-v2 all 3 B frames, specifically instructed lean-back hit recoil plus constant 45-degree front/side head and shoulders, 3 genuine 40x40 results. Hit recoil more recognizable BUT F1 drifts toward 90° side face, failing the hard camera gate. No sneaky visual PASS.
Both provider jobs, billing, and remaining balance 1721.8 /2000 read back. Total 20 generations charged for A37. No repeat submissions.
Also prepared three candidate arrangements B/C/mixed (B F0 + C F1 + B F2) with real source pixels; all remain art FAIL for the same F1 camera problem, not game integrated. Original provider PNGs are kept untouched.

## Hard gates
Every action ALWAYS EXACTLY 3 frames, one row of three 40x40, 120x40 transparent.
Every frame must match $actor01_1/_2/_3 native 45-degree battle camera; F0 check first, all subsequent frames independently.
Every frame unarmed; Tankentai SBS weapon paper doll must be separate. 1:1 Q head body. No 90° pure side profile. Motion naturalness alone cannot override camera FAIL.
Formal native VX/SBS overlay not tested. Do NOT promote Damage C to approved. No game project sprite or SBS script overwritten.

## Deliverables
A37_DODGING_T4_USER_SELECTED_3FRAME_120x40.png; A37_DODGING_T4_USER_SELECTED_ONESHOT.gif; A37_DODGING_T4_USER_SELECTED_PREVIEW.png.
A37_DAMAGE_SOURCE_DIRECT_3FRAME_CANDIDATE.png; A37_DAMAGE_3FRAME_ONESHOT.gif.
A37_DAMAGE_COMPOSITE_3FRAME_CANDIDATE.png, A37_DAMAGE_B_VS_C_VS_CAMERA_LOCK_REVIEW.png, A37_DAMAGE_QA.json, A37_DAMAGE_B_C_COMPARE_QA.json, A37_FINAL_QA.json.
All real provider outputs, prompts, scripts, submission locks in local E:\GameAssetToolLab_20261023\A37_FS_T4_DODGE_AND_DAMAGE_20261101.

## Follow up
Keep T4 as user-selected Dodging variant. For Damage, DO NOT regenerate using just the same camera text prompt. Need frame-specific source reference from real FS battle view for impact F1. Fix and validate F1 facing before expanding to next action.
