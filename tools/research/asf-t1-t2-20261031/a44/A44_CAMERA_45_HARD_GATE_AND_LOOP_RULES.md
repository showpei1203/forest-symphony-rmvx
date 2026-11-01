# FS A44 Camera-First 45-degree mandatory Gate + run-loop rule
2026-11-01

## A43 error confirmed
A43 matched 3 stored frames and [0,1,0,2] 4 temporal phase loop, but its A31 walking source has a 90-degree side profile, **not authentic 45-degree SBS battle art**. The user rejected it. Camera Gate: FAIL. It must not be used as approved battle art.
A31 motion approved does NOT mean its walking camera is approved. Actual FS native actor01_1 / actor01_2 / actor01_3 from the original game files are authoritative 45-degree battle camera references.

## Correct mandatory gates
- Exactly 3 stored frames per humanoid action, 40x40 each in the current test, 120x40 RGBA sheet. Do not conflate GIF 4 playback phases with 4 stored sprites.
- Moving to Close Attack loop: F0 both feet neutral, F1 left step, F2 right step; playback [0,1,0,2] repeat. Worldspace travel controlled separately by SBS script.
- Waiting, Critic Damaged, Magic Skill Use are LOOP actions per user. Damage, Dodging etc are SEQUENCE actions. Validate game-specific exceptions against actual SBS script before claiming formal PASS.
- Sprite ALWAYS unarmed; Tankentai SBS paper doll controls weapons separately.
- A37 Dodging T4 remains the user-selected candidate, unchanged.
- **Every** F0/F1/F2 must be individually compared at 8x+ magnification to the actual original FS actor01_1/_2/_3 battle camera, checking nose/eyes, front and side facial planes, nearer/farther shoulders, chest, hips, both feet. One 90-degree pure side profile means ART FAIL even if running mechanics work.
- The camera must remain coherent across all 3 frames, original 1:1 chibi proportions, no clipped limbs/weapons. Do not infer camera PASS from strings named SE45 or PixelLab direction parameter.

## Actual A44 test steps
(1) Read authentic actor01_1 / _2 / _3 native battle-view sprites; make an enlarged comparative source contact sheet.
(2) Use A34 true PixelLab native-battle view unarmed master as image first_frame, and A40 genuinely estimated 18-joint skeleton. Create 3 keypoints: F0 neutral, F1 left stride, F2 right stride. Hold all face/neck/shoulder keypoints exactly stable for all frames to prevent rotation.
(3) Submit once to real PixelLab /animate-with-skeleton-v3 using south-east camera, with SHA and submission lock. Store raw 3-frame provider PNG and separate clearly marked source-anchored assembly F0-original+F1/F2-provider if needed. Never repaint sprites with Python.
(4) Validate **Camera 45 degree EACH FRAME**, clear left/right leg changes, correct head/body, unarmed, no cropping, 3 stored frames, 4 phase [0,1,0,2] real loop playback and large in-browser preview.
(5) Any camera or motion failure is recorded as FAIL and not promoted to actual game. VX/Tankentai SBS engine, weapons and worldspace movement are untested until truly run.
- Original FS / PMD / A31-A43 and Dodging T4 are not overwritten.

## Regression prevention
Gates named: CAMERA_45_EACH_FRAME, ACTION_SEMANTIC_RUN_LOOP, SPRITE_FRAMES_EXACT3, CHIBI_IDENTITY, EMPTY_HANDS_SBS, ENGINE_VX. Do not conflate the gates.
