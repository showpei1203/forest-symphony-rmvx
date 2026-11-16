# FS A44 to A45 | Independent Motion Self-Audit + Godot Native Handoff | 2026-11-15

## Intent
Respond to the instruction to self-review battle motion, not merely validate PNG dimensions. Godot 4.7.2 native on RX 6700 XT. Preserve the user's approved A62 head/body style and A44 contact-test semantics.

## Actual visual findings
- Prior F6 Body had disconnected 7px island (x55-56 y40-43). This looked like an unwanted floating fragment.
- A44 legs were overextended, reducing balance of 45-degree pose; boot colors/limb length differ from original A62 stance.
- F6/F7 gold effect had a long angular spur that reads as a second blade.
- Upper torso/shoulder still do not twist enough for perfect natural movement, so independent art approval remains HOLD.

## Actual fixes and measured self QA
- New full 256x192 A45 Body, Weapon, FX RGBA atlases; A44 unchanged.
- Redrew planted rear and advancing front boots with original A62 color family and more compact shin geometry. 10px anticipation stance, 12px acceleration, 14px at F6/F7, 13px recovery.
- Silhouette 8-connectivity: exactly one Body component per frame; 7 floating F6 pixels removed.
- Rig/body wrist and blade-hilt distance: zero px across 10 active sword frames. Actual sword tips touch weapon geometry zero px.
- F1-F4 and F6-F7 measured planted foot centroids stable (no slide).
- Shorter FX alpha max 130 and sword-tip proximity max 6.08px.
- Original A44 head upper 34 pixel rows preserved all 12 frames, weapon atlas exact source pixels retained; original A44 available as fallback.
- 12x native Godot rendered PNG, 4x rendered GIF and direct A44-vs-A45 full-body before/after for user visual review.

## Native Godot engine and isolated contact testing
- Godot v4.7.2.stable.official.ed1daf0bf; real OpenGL 3.3 AMD Radeon RX6700XT.
- Editor import EXIT0, GPU 12x0 pixel mismatch + all no-crop PASS, 11 unique poses, single-clock F6 hit (0.55s), hitstop 70ms, restore idle.
- Isolated practice target real hit HP 100→75→50, in/out-range, same serial duplicate suppression, 2x speed and cancel-during-hit all PASS.
- A45 uses A44 practice dummy scene and its old class name intentionally, not full migrated FS battle.
- Formal migrated FS ATB/enemy stats/skills NOT RUN.

## Reproduction and output
- qa/a45_pose_art_self_audit.py creates 3 source atlases and GIF from preserved A44.
- qa/a45_independent_geometry_qa.py independently checks rendered geometry.
- qa/a45_native_gpu_runtime_qa.gd and qa/a45_contact_damage_native_qa.gd load new A45 through Godot.
- QA log, failure log, original 12 GPU png and reference composited atlas in release.
- No local permanent files; private Drive/GitHub authoritative.

## Honest gate
ENGINE/GPU/GEOMETRY FIXES PASS.
FULL AESTHETIC ART HOLD (torso rotation and attack loading still slightly rigid).
FORMAL FS FULL BATTLE MIGRATION NOT RUN.
