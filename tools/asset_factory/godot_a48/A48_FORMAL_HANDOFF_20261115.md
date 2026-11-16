# Forest Symphony A47 -> A48 | Formal Engineering Handoff (2026-11-15)

## User's immediate request
A47 has **many disconnected-looking body parts**; fix real animation, not merely the QA rules. A47 prior ENGINE PASS stays but ART FAIL. The A48 deliverable is an actual rewritten 12-frame animation with native screenshots.

## Grounded source and method
A47 private owner-only final ZIP SHA256 e48cd680edd63a888deb2b370df4686a289253383fdbd7dc770df271df793ee5. A62 user-approved 64x64 Actor01 full-body canonical, 45-degree southeast battle direction. A48 starts from A62 complete unchanged pose for every attack frame; does NOT physically split or warp head/chest/waist/pelvis/legs. It redraws sword-arm only using explicit shoulder (39,36), per-frame elbows and A47 per-frame wrist endpoints. Joint-overlapping stroke widths 6/4/2px with original palette, gold shoulder pauldron, dark outline and brown glove. Native A47 weapon and FX and F6 tip marker (30,9) unchanged. F0/F11 exact canonical.
The first candidate temporarily painted hair at F3..5 and foot at F8; independent QA failed and caught it. Added original-head/floor occlusion to preserve every head RGBA pixel above y34 and all pelvis/boots at y>=47.
Technique is **manual deterministic pixel arm**, not PixelLab or completed 18-joint rig, though design prompt borrows A57/A62/A65 lessons.

## Real QA and evidence
- Independent reference: A47 distorted identity is negative; exact A62 head/boot region expected. A48 12/12 head, hips/boots, offhand exact A62.
- 12/12 unique alpha single component, 11 different poses, 10/10 shoulder/elbow/wrist joint adjacency. Independent bone mass minimum 16 opaque pixels in 5x5 arm segment sample; no detached thin-bridge pass.
- Godot 4.7.2 Windows AMD RX6700XT native OpenGL: import EXIT0, 12/12 GPU screenshot and expected RGBA composites pixel difference0, no crop. 0.55s contact at F6, 70ms hitstop, A39 breathing idle recovered.
- Godot practice target real damage HP 100->75->50, misses/out of range, cancel-before-contact, cancel-during-hit and accelerated playback PASS. Note practice target is NOT formal FS combat.
- Known A45 waist fails EXIT1, A62 passes EXIT0, A48 source+native frame passes EXIT0.
- True native Godot side-by-side GIF A48_A47_VS_A48_GODOT_NATIVE_GIF.gif and A48_GODOT_NATIVE_ATTACK_12FRAMES.gif. A48_A47_VS_A48_GODOT_1X.png/3X.png; QA JSON/logs, failure log and reproducible generator in qa/.
- No PixelLab API calls or charge. A42-A47 historical assets, GitHub main/map/migration and original E: RMVX untouched.

## Quality classification
ENGINE/GPU/ISOLATED DAMAGE PASS. USER-REPORTED BODY SEPARATION FIX: STRUCTURAL QA PASS. **FULL ART AESTHETIC HOLD**, needs user review because body is intentionally stable and upper torso twist is understated. Do not retroactively label art APPROVED.
FORMAL MIGRATED FS combat ATB/enemy/skill integration NOT RUN.

## Next production priority
From stable A48 baseline, draw additional deliberate shoulder/waist/arm poses as cohesive **whole-body authored sprites**, not by free coordinate image warp; validate all connections with A48 joint mass and A62 preservation, rerun Godot. A48 is intended to provide no disembodied parts before adding visual force.
