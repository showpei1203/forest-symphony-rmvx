# Forest Symphony A45 | biomechanical self-review of Actor01 sword attack
Godot 4.7.2 45-degree battle art. Standalone 12-frame 3-layer sprite sandbox.

## Run
Open project.godot with Godot 4.7.2; F5 loads the existing practice-target scene. Press A attack; R reset HP.
A45 sprite assets loaded by scripts/fs_actor_animator.gd, body path in assets/actor01_animation_manifest.json.
Attack and dynamic sword tip remain in one AnimationPlayer with F6 hit at 0.55s and 70ms hitstop.
The practice target is NOT the formal migrated Forest Symphony ATB battle system.

## Art
New assets/actor01_a45_body_12frames.png, actor01_a45_weapon_12frames.png, actor01_a45_fx_12frames.png.
Original A44 body/weapon/fx preserved for comparison and script-based regeneration.
New art source: qa/a45_pose_art_self_audit.py (reproducible and checks 1 connected component/frame, head pixel retention, stance <=15px).
Independent visual geometry test: qa/a45_independent_geometry_qa.py (measured boot centers, wrists touching blade, tips touching blade, FX glints near tip).
Raw 1x and 3x before/after 12-frame sheet and true native GPU GIF.

## QA
1. python qa/a45_pose_art_self_audit.py
2. python qa/a45_independent_geometry_qa.py
3. godot --headless --path . --editor --import
4. godot --path . --rendering-method gl_compatibility --script res://qa/a45_native_gpu_runtime_qa.gd
5. godot --path . --rendering-method gl_compatibility --script res://qa/a45_contact_damage_native_qa.gd

## Gates
BODY/WEAPON/FX generation and structural art checks PASS; native GPU and isolated contact damage PASS.
Aesthetic approval ART HOLD: upper torso anticipatory twist and weight remain less expressive than ideal.
Formal migrated Forest Symphony ATB/damage integration NOT RUN.
Do not conflate screenshot pixel correctness with subjective animation quality.
