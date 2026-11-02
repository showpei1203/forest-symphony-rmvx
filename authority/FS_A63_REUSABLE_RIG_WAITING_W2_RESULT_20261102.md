# A63 Result | Forest Symphony reusable animation rig + Waiting, 2026-11-02

A62 Moving to Close Attack is USER APPROVED. Its **real** generated first-frame PNG, 18-joint input poses and 0,1,0,2 loop motion have been frozen as a reproducible reusable motion recipe. No A57-to-A62 source rereading, estimating 45 original frames, or paid prompt experimentation is needed for another compatible two-legged chibi actor.

## Deliverables
- \`REUSABLE_RIG/A62_APPROVED_RUN_MOTION_RECIPE.json\`: approved relative motion and angle specification for run
- \`REUSABLE_RIG/A63_WAITING_BREATH_MOTION_RECIPE.json\`: latest W2 candidate breathing motion, with 0,1,2,1 playback
- \`REUSABLE_RIG/retarget_any_actor_offline.py\`: transfers BOTH actions via silhouette-height-normalized 18-joint deltas onto the new actor's own F0 and corrected first-frame skeleton; no API calls
- \`REUSABLE_RIG/prepare_new_character_actions_offline.py\`: register a new actor ONCE (skeleton reference and PNG SHA256 content cache), bulk prepare two action poses; prevents silent overwrite
- \`A63_RIG_REUSE_SELFTEST.json\`: FOUR successful offline regression checks on approved actor and synthetic-shift geometry
- \`W2_EXHALE_CORRECTION/A63_W2_WAITING_8X_LOOP.gif\`: real 3-frame animation (F0 F1 F2 F1)
- \`W2_EXHALE_CORRECTION/A63_ORIGINAL_W1_W2_SYNCHRONIZED.gif\`: original FS vs W1 vs W2 visual review
- \`W2_EXHALE_CORRECTION/A63_ORIGINAL_W1_W2_FRAME_COMPARISON.png\`: three full strips for visual review

## Real PixelLab generation and QA
W1: One locked, real v3 API generation. F0 / F1 distinct but F2 identical to F0 across all visual ROI; FAILED the third-pose Gate. Record the failed case. Feet didn't move meaningfully and original approved look remained close.
W2: One locked corrective v3 API generation; same A62 approved F0, same W1 inhale, only exhale F2 stronger and still feet planted in input 18-joint skeleton. Real third pose differs from first:
- Visible head zone F0/F2: 205 different pixels
- Torso/arms: 159 different pixels
- Feet: 5 different pixels
- All four canvas edges clear for all 3 frames
- W2 technical candidate: PASS, naturalness / true 45° / FS style: HUMAN PENDING
- Native VX not tested by user request, original FS project untouched.

## Future actor, one-time intake and no repeated research
Provide each new 3/4 southeast chibi humanoid's F0 image and 18-pt skeleton ONCE, then:
\`python REUSABLE_RIG/prepare_new_character_actions_offline.py --character-id actor02 --target-png actor02_F0.png --target-skeleton actor02_18.json --out CHARACTER_DRAFTS\`
Both RUN and WAITING are generated as offline 3-pose skeleton drafts with cached input+recipe hashes. Review pose/body side and target look before **one paid pixel generation per new action per new character**. The original A57 extraction/paid bone estimation and A43-A62 troubleshooting is NOT repeated. Other loops (Critical Damaged, Magi Skill Use) need distinct new motion recipes, NOT the run or waiting poses blindly reused.

## Status
- A62 run: USER VISUAL PASS, accepted reusable baseline (do not mutate)
- A63-W1 Waiting: 3-pose semantic FAIL, permanently retained and marked
- A63-W2 Waiting: real PixelLab 3-frame GIF, technical PASS, user visual acceptance PENDING
- A63 reusable rig / offline cache: PASS 4 regression tests
- FS native and VX/Tankentai: NOT TESTED

Source authority: FS original $actor01 16 actions; accepted A62 48px source. All files SHA256 checked.