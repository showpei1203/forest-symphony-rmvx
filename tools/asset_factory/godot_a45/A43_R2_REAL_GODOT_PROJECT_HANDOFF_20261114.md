# A43 R2 | 2026-11-14

## Actual result
Source-locked A42 81-file Godot ZIP was downloaded from the signed Drive source. An isolated A43 R2 Godot project candidate was generated and archived; the original A42 ZIP remains immutable.

- Private Godot project ZIP (93 files, 478561 bytes): https://drive.google.com/file/d/1T79suZv8gz9n_h9xDWMzAc_c1zsbtw7_/view
- ZIP SHA256: d6dd71714a6c7c94262b96b67a608644a59ce55ace0dc345e59a6dc78b8a576b
- Added `assets/actor01_a43_r2_fx_12frames.png` and `assets/actor01_a43_r2_composite_12frames.png` (256x192 RGBA 4x3).
- Added `A43_R2_FULL_ACTOR.gif`, `assets/actor01_a43_r2_animation_manifest.json`, `qa/A43_R2_PIXEL_QA.json`, and reproducible `build_a43_r2.py`.
- Updated ONLY candidate `scripts/fs_actor_animator.gd` to use A43 R2 FX atlas with original A42 weapon. Same 12-pose Godot AnimationPlayer and F6 0.55s/70ms hitstop contract.
- FX activity strictly F4-F8, anchored to original sword tip, with curved motion-tail and F6 impact sparkle. A43 R1 angular effect was replaced.

## QA / blockers
- Pillow atlas and exact Body+Weapon+FX composite checks PASS; tip anchor pixel check PASS; frame activity PASS.
- Native Godot editor/runtime/GPU test NOT RUN. User PC not modified; no Windows temp workspace was authorized.
- **ART HOLD**: body/arm/shoulder poses are STILL A42 originals, no actual anatomy improvement. This is an FX refinement, not finished A43.
- FS ATB/hurtbox/damage integration NOT RUN.
- The local image preview is NOT a native Godot screenshot.
- Original A42 signed ZIP and all other branches untouched.

## Next actual engineering
Native Godot cold import and 12-frame GPU capture from this candidate; revise sword silhouette/arm/shoulder weight with 1x review; only then merge to a new battle animation version and integrate formal combat.
