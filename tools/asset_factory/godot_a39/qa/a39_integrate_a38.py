from pathlib import Path
import hashlib, shutil, json

root = Path(__file__).resolve().parent.parent
private = root.parent
old = private / 'FS_A38_GODOT_BATTLE_RUN_IDLE_20261114'
assert (old/'project.godot').exists(), old
assert (root/'scenes'/'actor01_breath_rig.tscn').exists()

def patch(src,find,repl,name):
    if find not in src: raise AssertionError(f'A39 PATCH CONTRACT FAILED: {name}')
    if src.count(find)!=1: raise AssertionError(f'A39 PATCH AMBIGUOUS: {name}')
    return src.replace(find,repl,1)

source_names = [
    'assets/actor01_animation_manifest.json',
    'assets/actor01_run_a35_8frames.png',
    'assets/actor01_idle_r1_raw_8phases.png',
    'assets/actor01_idle_r2_raw_8phases.png',
    'assets/actor01_idle_r1_calm_curated_8phases.png',
]
source_shas={}
for name in source_names:
    s=old/name; t=root/name
    if not s.exists(): raise FileNotFoundError(s)
    t.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(s,t)
    assert s.read_bytes()==t.read_bytes(), name
    source_shas[name]=hashlib.sha256(t.read_bytes()).hexdigest()
assert source_shas['assets/actor01_run_a35_8frames.png']=='ec0c7a59fb5983f13b1b3385323218edf0e77c23890db074c18c6e114e74408b'

sc=(old/'scripts/fs_actor_animator.gd').read_text(encoding='utf-8')
sc=patch(sc,'@onready var actor_sprite: AnimatedSprite2D = $AnimatedSprite2D', '@onready var actor_sprite: AnimatedSprite2D = $AnimatedSprite2D\n@onready var breath_rig: FSActorBreathRig = $BreathRig', 'rig binding')
a=sc.index('func play_motion(')
b=sc.index('func set_profile(',a)
sc=sc[:a]+'''func play_motion(motion: StringName, profile: StringName = &"") -> bool:
    var motion_key: String = str(motion)
    var profile_key: String = str(profile)
    if profile_key.is_empty():
        profile_key = str(_default_profiles.get(motion_key, ""))
    # A39 Godot AnimationPlayer breathing is a real procedural rig, not an atlas animation.
    if motion == &"idle" and profile_key == "idle_rig":
        actor_sprite.stop()
        actor_sprite.visible = false
        breath_rig.visible = true
        breath_rig.start_breathing()
        breath_rig.breath_player.speed_scale = playback_multiplier
        _active_motion = motion
        _active_profile = &"idle_rig"
        motion_started.emit(_active_motion, _active_profile)
        return true
    if not _profile_motion.has(profile_key) or str(_profile_motion[profile_key]) != motion_key:
        motion_unavailable.emit(motion)
        return false
    if actor_sprite.sprite_frames == null or not actor_sprite.sprite_frames.has_animation(profile_key):
        motion_unavailable.emit(motion)
        return false
    breath_rig.stop_breathing()
    breath_rig.visible = false
    actor_sprite.visible = true
    _active_motion = motion
    _active_profile = StringName(profile_key)
    actor_sprite.play(profile_key)
    motion_started.emit(_active_motion, _active_profile)
    return true

''' + sc[b:]
sc=patch(sc,'    actor_sprite.speed_scale = playback_multiplier\n\nfunc get_motion()', '    actor_sprite.speed_scale = playback_multiplier\n    breath_rig.breath_player.speed_scale = playback_multiplier\n\nfunc get_motion()', 'speed')
sc=patch(sc,'func get_frame_index() -> int:\n    return actor_sprite.frame', 'func get_frame_index() -> int:\n    if _active_profile == &"idle_rig":\n        return breath_rig.get_phase_index()\n    return actor_sprite.frame', 'frame index')
(root/'scripts/fs_actor_animator.gd').write_text(sc,encoding='utf-8')

scn=(old/'scenes/actor01.tscn').read_text(encoding='utf-8')
scn=patch(scn,'[gd_scene load_steps=2 format=3]', '[gd_scene load_steps=3 format=3]', 'tscn load_steps')
scn=patch(scn,'[ext_resource type="Script" path="res://scripts/fs_actor_animator.gd" id="1_actor"]', '[ext_resource type="Script" path="res://scripts/fs_actor_animator.gd" id="1_actor"]\n[ext_resource type="PackedScene" path="res://scenes/actor01_breath_rig.tscn" id="2_breath"]','tscn ext')
scn+='\n[node name="BreathRig" parent="." instance=ExtResource("2_breath")]\nvisible = false\n'
(root/'scenes/actor01.tscn').write_text(scn,encoding='utf-8')

battle=(old/'scenes/battle_animation_preview.tscn').read_text(encoding='utf-8')
battle=patch(battle,'initial_profile = &"idle_calm"','initial_profile = &"idle_rig"','initial mode')
(root/'scenes/battle_animation_preview.tscn').write_text(battle,encoding='utf-8')

preview=(old/'scripts/battle_animation_preview.gd').read_text(encoding='utf-8')
preview=patch(preview,'footer.text = "1 Idle R1  |  2 Idle Calm  |  3 Idle R2  |  4 Run Raw  |  5 Run Tuned  | Space Pause  | +/- Speed"','footer.text = "1 R1  |  2 Calm  |  3 R2  |  4 Run 8fps  |  5 Run 10fps  |  6 A39 Rig  |  Space Pause"','HUD')
preview=patch(preview,'KEY_5: run_actor.set_profile(&"run_tuned")','KEY_5: run_actor.set_profile(&"run_tuned")\n        KEY_6: idle_actor.set_profile(&"idle_rig")','key6')
preview=patch(preview,'                idle_actor.actor_sprite.pause()','                if idle_actor.get_profile() == &"idle_rig":\n                    idle_actor.breath_rig.breath_player.pause()\n                else:\n                    idle_actor.actor_sprite.pause()','pause')
preview=patch(preview,'                idle_actor.actor_sprite.play()','                if idle_actor.get_profile() == &"idle_rig":\n                    idle_actor.breath_rig.breath_player.play()\n                else:\n                    idle_actor.actor_sprite.play()','resume')
preview=patch(preview,'FS / A38 GODOT    RUN:', 'FS / A39 GODOT    RUN:', 'HUD title')
(root/'scripts/battle_animation_preview.gd').write_text(preview,encoding='utf-8')

p=(root/'project.godot').read_text(encoding='utf-8')
p=patch(p,'run/main_scene="res://scenes/a39_rig_preview.tscn"','run/main_scene="res://scenes/battle_animation_preview.tscn"','project main')
p=patch(p,'Forest Symphony | A39 Local Torso Breath Rig','FS A39 Battle RUN and Controlled IDLE Rig','project title')
(root/'project.godot').write_text(p,encoding='utf-8')

# Existing A38 QA scripts may still be separately executed, but A39 uses new QA tailored to the rig.
info={'stage':'A39','clone_source':'FS_A38_GODOT_BATTLE_RUN_IDLE_20261114','source_sha256':source_shas,'changed_code':['scripts/fs_actor_animator.gd','scripts/battle_animation_preview.gd','scenes/actor01.tscn','scenes/battle_animation_preview.tscn','project.godot'], 'preserve':'A38 five atlas profiles unchanged, A39 adds procedural idle_rig handled by AnimationPlayer and torso-only pixel shader'}
(root/'qa/A39_INTEGRATION_MANIFEST.json').write_text(json.dumps(info,indent=2,ensure_ascii=False),encoding='utf-8')
for name,v in source_shas.items():print('A39_COPIED_BYTE_IDENTICAL',name,v)
print('A39_A38_RUNTIME_INTEGRATION_PATCHED=true')
