class_name FSBattleActorAnimator
extends Node2D
## A38: Manifest-driven, multi-texture, multi-motion native Godot 4.7 battle animation actor.
## Does not invent missing battle animations; RUN and IDLE are the only supported motions.

signal motion_started(motion: StringName, profile: StringName)
signal motion_unavailable(motion: StringName)

@export_file("*.json") var manifest_file: String = "res://assets/actor01_animation_manifest.json"
@export var initial_motion: StringName = &"idle"
@export var initial_profile: StringName = &"idle_calm"
@export_range(0.25, 3.0, 0.05) var playback_multiplier: float = 1.0

@onready var actor_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var breath_rig: FSActorBreathRig = $BreathRig

var _profile_motion: Dictionary = {}
var _default_profiles: Dictionary = {}
var _active_motion: StringName = &""
var _active_profile: StringName = &""

func _ready() -> void:
    var text: String = FileAccess.get_file_as_string(manifest_file)
    if text.is_empty():
        push_error("FS A38: manifest missing: " + manifest_file)
        return
    var data: Variant = JSON.parse_string(text)
    if not (data is Dictionary):
        push_error("FS A38: invalid JSON manifest")
        return
    var manifest: Dictionary = data as Dictionary
    _default_profiles = manifest.get("default_profiles", {})
    var profiles: Dictionary = manifest.get("animation_profiles", {})
    var frame_bank := SpriteFrames.new()
    if frame_bank.has_animation("default"):
        frame_bank.remove_animation("default")
    for key in profiles.keys():
        var config: Dictionary = profiles[key]
        var motion: String = str(config.get("motion", ""))
        var sheet_path: String = str(config.get("sprite_sheet", ""))
        var texture: Texture2D = load(sheet_path) as Texture2D
        if texture == null or motion.is_empty():
            push_error("FS A38: missing motion texture or name for " + str(key))
            continue
        var grid: Dictionary = config.get("grid", {})
        var fw: int = int(grid.get("frame_width", 0))
        var fh: int = int(grid.get("frame_height", 0))
        var cols: int = int(grid.get("columns", 0))
        var rows: int = int(grid.get("rows", 0))
        var count: int = int(grid.get("frame_count", 0))
        if fw <= 0 or fh <= 0 or cols <= 0 or rows <= 0 or count <= 0 or count > cols * rows:
            push_error("FS A38: invalid grid for " + str(key))
            continue
        if texture.get_size() != Vector2(fw * cols, fh * rows):
            push_error("FS A38: manifest and sprite sheet mismatch for " + str(key))
            continue
        var durations: Array = config.get("durations", [])
        if durations.size() != count:
            push_error("FS A38: invalid duration count for " + str(key))
            continue
        var profile: String = str(key)
        frame_bank.add_animation(profile)
        frame_bank.set_animation_loop(profile, bool(config.get("loop", true)))
        frame_bank.set_animation_speed(profile, float(config.get("fps", 8.0)))
        for i in range(count):
            var atlas := AtlasTexture.new()
            atlas.atlas = texture
            var x: int = (i % cols) * fw
            var y: int = int(i / cols) * fh
            atlas.region = Rect2(x, y, fw, fh)
            atlas.filter_clip = true
            frame_bank.add_frame(profile, atlas, float(durations[i]))
        _profile_motion[profile] = motion
    actor_sprite.sprite_frames = frame_bank
    actor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor_sprite.centered = true
    actor_sprite.speed_scale = playback_multiplier
    if not play_motion(initial_motion, initial_profile):
        push_error("FS A38: initial motion or profile not available")

func play_motion(motion: StringName, profile: StringName = &"") -> bool:
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

func set_profile(profile: StringName) -> bool:
    return play_motion(_active_motion, profile)

func set_playback_multiplier(factor: float) -> void:
    playback_multiplier = clampf(factor, 0.25, 3.0)
    actor_sprite.speed_scale = playback_multiplier
    breath_rig.breath_player.speed_scale = playback_multiplier

func get_motion() -> StringName:
    return _active_motion

func get_profile() -> StringName:
    return _active_profile

func get_frame_index() -> int:
    if _active_profile == &"idle_rig":
        return breath_rig.get_phase_index()
    return actor_sprite.frame

func is_motion_supported(motion: StringName) -> bool:
    for available in _profile_motion.values():
        if str(available) == str(motion):
            return true
    return false
