# A34 Handoff — native FS battle facing first frame and contaminated screenshot pose repair

## Why
A33 Dodging F0 is WRONG FACING (user feedback, hard FAIL); don't treat this as a mild improvement request.
A33 screenshot-derived Dodging reference pose F0 is itself side-facing; F1 has a foreign 44px disconnected fragment from the preceding row and F2 a 32px vertical line. Originals are preserved; only a COPY of F1 has the objective 44px component removed.

## Real FS native battle 45 view inputs
FS source $actor01_1.png r1c1 and r2c1 (32px originals) are each inserted losslessly at (x+4,y+6) into 40px transparent. Camera authority is original FS battle look, not $actor01.png row2 one-eye right-facing walk.
A31 teal/white-hair chibi appearance is reference. Do not put character-held weapons in sprite; SBS paper doll later.

## Actual PixelLab provider executions
- Trial with 1 frame /transfer-outfit-v2 returned HTTP 422, requires at least two frames, not billed.
- True FS battle-view identity transfer two real frames: job 264f8c8b-ea74-430a-9228-991f5ff53796, 10 generations, two 40px PNG outputs. Used first for new F0 and F2.
- Source pose-controlled 3frame Dodging: correct native view F0, cleaned user crouch F1, correct view F2, + new true native-view identity master as reference: job 0a60516c-98cc-4dd2-b8f1-4d833c0dffd8, 10 generations, three authentic returned 40px PNGs.
- Both jobs and billing verified read-back, A34 start 1781.8, end 1761.8 /2000. No duplicate submits.

## Outputs
A34_FIRST_FRAME_DIRECTION_GATE_REVIEW.png: native original, user-rejected A33, A34 new master, provider raw new F0, raw crouch F1.
A34_A33_VS_NEW_RAW_VS_F0_LOCK_REVIEW.png: all action frames; old A33 wrong F0 vs A34 raw vs F0/F2 EXACT native master copy as clearly labelled assembly. This is not manual repaint and is NEVER claimed to be raw provider result.
A34_B2_PROVIDER_RAW_ONE_SHOT.gif and A34_VIEW_LOCK_ASSEMBLY_ONE_SHOT.gif: short action previews, no artificial seamless cycle.
A34_NATIVE_F0_EXACT_VIEW_LOCK_CANDIDATE_3FRAMES.png: source-locked candidate: genuine master, real provider F1, same master.
A34_FINAL_QA.json: per-frame gates.

## FAIL-CLOSED ART Status
The new F0 now visually resembles original native FS battle direction more than old side-profile A33 F0. Yet precise 45-degree artistic gate is PENDING user review, and F1 is a deep tumbling crouch with feet high; three-frame transition may be abrupt. DO NOT mark full Dodging PASS, DO NOT overwrite official SBS, DO NOT blindly generate all 16 actions. Next: more detailed F1 motion interpolation or source pose re-selection only after viewing, and validate each F0/F1/F2 facing independently.

Original FS/PMD/Tankentai game asset files were not modified.
