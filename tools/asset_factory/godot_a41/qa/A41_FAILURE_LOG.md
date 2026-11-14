# A41 FAILURE LOG | 2026-11-14
Stage: FS A41 weighted sword attack, Godot 4.7.2 GPU, owner-only Drive.

## A41-F01 Sword crossed approved face ROI
- First 12-pose rig attempted backward high-windup sword ending at x37,y27. The blade overwrote approved source hair/face native pixels, causing automated head-lock check failure at F2 x37,y26.
- Fix: move F2–F4 wrist and sword high-windup trajectories to right-of-face, not across the original portrait.
- Validation: generation succeeds with native source face exact after integer rigid body offset; same original A62 palette, no invented face RGB. RESOLVED.

## A41-F02 Clipped/slash effect visually detached on right edge
- Initial F6/F7 sword tips went to x62 and effects almost beyond canvas; enlarged montage showed effect detached and cropped-looking.
- Fix: shorten right-facing sword tips F6 x59/y41, F7 x56/y52; constrain 2px native slash guide to x<=59 and remove the off-canvas arc.
- Validation: 12/12 native GPU frames have ZERO non-transparent pixels on outermost canvas border; contact and sword appear in-frame. RESOLVED.
- Artistic strength still HOLD, especially fine sword anatomy/stance polish.

## A41-F03 Major: independent time sources desync visible hit
- Initial A41 used A40 AnimatedSprite2D timed atlas separately from Godot AnimationPlayer's 0.55s method track. Under actual GPU frame timing, callbacks were delivered on pose frame 7/8 rather than required frame 6. A41 QA correctly FAILED.
- Fix: move all 12 Sprite2D `frame` keys (times n/12.0) into SAME `AnimationPlayer` as hit method t=0.55, set `callback_mode_method=IMMEDIATE`, stop AnimatedSprite2D standalone playback during attack. AnimationPlayer finished signal restores idle.
- Validation: two normal/speed2 hit callbacks report **F6**, cancellation/pause/resume and actual 12 GPU frames pass. RESOLVED.
- Reuse rule: animation pose and contact are ONE authoritative clock, not two timers.

## A41-F04 Invalid GPU-to-atlas test reference
- First GPU audit showed 12 false positive mismatches, despite PIL comparing original atlas PNG to actual GPU F0 as **0 pixel differences**.
- Test bug 1: GDScript `i/4` produced fractional row offset; the QA indexed wrong atlas rows for F1+.
- Test bug 2: `Texture2D.get_image()` is imported texture representation, not necessarily byte-identical to original PNG for raw pixel audit.
- Fix: index atlas row with `int(i/4)`, load the original lossless PNG using `Image.load_from_file()`.
- Validation: **12/12 GPU captures RGBA pixel-identical with original atlas cells, 0 changed pixels**, original face/feet source pinned for original endpoints. RESOLVED.

## Outstanding gates
- **ART HOLD**: This is an improved weight-shifting 12-pose sword prototype, not owner-accepted finalized art. Limb segmentation and weapon/impact aesthetics can still improve. Do not quietly replace canonical character.
- **FS GAMEPLAY NOT_RUN**: `attack_contact_anchor` and `attack_hit` are verified via independent dummy receiver, NOT connected to true migrated FS ATB, enemy stats, skills, collision, hurt or HP flows.
- **OWNER-ONLY**: original E: VX, GitHub main, migration and map branches not touched; project binaries private Drive only. No new PixelLab credits used.