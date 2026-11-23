# Forest Symphony T-A R24 | Bone-driven sword slash engineering prototype

**Actual implementation:** Godot 4.7.2 Skeleton2D and 8 nested Bone2D, native two-bone IK shoulder/elbow/wrist, sword Sprite2D attached to Wrist Bone, actual A52 7×21 source crop, two distinct 12-key slash animations and real F7=0.630 signal + ~0.070s isolated hitstop.

## Test and preview
1. Open `godot_project/project.godot` with Godot 4.7.2 and run `scenes/r24_preview.tscn`. The scene autoplays an overhead loop in a 128×128 safe preview canvas.
2. For real GPU QA: `godot --path godot_project --rendering-method gl_compatibility --audio-driver Dummy --script res://qa/r24_real_skeleton_native_qa.gd` in an interactive OpenGL-capable environment (CI Linux uses Xvfb/Mesa). It saves 24 PNGs to `res://qa/output/r24/` and reports `R24_QA_STATUS PASS` when source and motion contracts hold.
3. QA source prerequisites: run `source/build_r24_private_assets.py --a52 PRIVATE_A52_ZIP --assets godot_project/assets --manifest source/SOURCE_MANIFEST.json` and `source/verify_r24_private_source.py --a52 ... --assets ... --manifest ...`.
4. The original full-body source is **STATIC for identity demonstration**. Animated diagnostic bones and real original sword are moving. This is NOT true skeletal skinning of complete LPC clothes, no original hidden pixels, not finished art and not integrated FS Battle.

## Original source and permissions
Approved A62 64x64 F0 SHA `70a8e6...`; original A52 sword 256x192 atlas SHA `6d274e0...`; original A52 body not altered; weapon is an untouched pixel-exact crop of source F1 `[38,24,45,45]` (grip crop-local `[3,19]`). These private image assets and all native images remain only in the owner's private Google Drive, NOT public GitHub. The source-only reimplementation is in the original T-A feature branch.

## Project chronology
R23 source-exact flattened visual layer masks: 12/12 source GPU pass, art HOLD. R24 adds actual articulated bones and big sword motion instead of modifying or rearranging old body images. No claim that holding sword in static A62 source with moving test rig is beautiful combat art. Preview is a mechanical engineering visualization only.
