# Forest Symphony A44 | Godot 4.7.2 Battle Attack Sandbox

Standalone battle-art engineering project, not the migrated FS main/ATB.

## Play immediately
- Open this Godot project and press F5: a44_contact_demo.tscn is the main scene.
- Press A to strike the practice target, R to reset HP.
- A44 Body/Weapon/FX 12-frame art, five AnimationPlayer tracks (3 layers + moving hit marker + event).
- Contact t=0.55 seconds / F6, hitstop 70ms, F6 sword-tip marker local (29,9).
- Practice Area2D radius 29px, damage 25 HP in range, once per serial. Red flash + 7px knockback.

## Native tests
1. godot --path . --rendering-method gl_compatibility --script res://qa/a44_native_gpu_runtime_qa.gd
2. godot --path . --rendering-method gl_compatibility --script res://qa/a44_contact_damage_native_qa.gd
See qa/A44_QA_SUMMARY.json, raw log and qa/output/a44 screenshots.
qa/a44_art_kinematic_poses.py reproduces art assets from the preserved A43 source.

## Gates
ENGINE/IMPORT/GPU/ISOLATED-CONTACT PASS. ART aesthetic HOLD. Formal FS migrated ATB NOT RUN.
E: RMVX untouched. Old A42/A43 atlases preserved.
