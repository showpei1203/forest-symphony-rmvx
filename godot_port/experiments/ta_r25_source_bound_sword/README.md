# FS T-A R25 original A52 visible pixel bone-bound slash

**This is a real native engineering art prototype, NOT owner-approved paper-doll art.**

- Godot 4.7.2. **First open `godot_project/project.godot` in the editor to import/register GDScript `class_name`**, then run `scenes/r25_preview.tscn`. Clean CLI standalone QA before editor import can fail `Could not find type FSTASourceBoundSlashR25`; this is a documented bootstrap condition.
- Source-only generator `source/build_r25_parts.py` rebuilds 7 original F0 source masks and A52 F04/F05 near-arm chips from the original R23 source atlas under `godot_project/assets`. It verifies source A62 and A52 SHA256 before proceeding. It does not generate missing hidden garment underpaint or new artwork.
- R25 extends R24 exact existing Skeleton2D/Bone2D IK/AnimationPlayer and real source A52 sword. Head, near/far arm, original torso, belt, pants, boots are 9 independent original visible source Sprite2D objects parented to actual bones. Six core regions change original source frame by time; near-arm donor chips are split from original F04 or F05. Idle F00/F11 retains exact approved A62 source pixels.
- Run isolated native QA with an OpenGL-capable server: `godot --path godot_project --rendering-method gl_compatibility --audio-driver Dummy --script res://qa/r25_source_bound_native_qa.gd`. Final QA writes 24 native original-sword frames + 8 extra body-only frames to `res://qa/output/r25`.
- Original 7 visible-layer alpha masks do **not** contain source-native LPC hidden underpaint. Bone attachment changes original source-pixel placement and may leave gaps, so this cannot be claimed full production paper-doll art. F7 0.630s timing is only isolated actor event and is NOT FS Battle/ATB/HP.
- `evidence/R25_FAILURE_LOG.md` preserves the initial manual-pose hide error and 54ms/70ms timer observations. No pixel art generation cost, no real Windows GPU or user PC used.
