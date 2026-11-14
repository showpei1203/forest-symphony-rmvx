class_name FSBattleActorAnimator
extends Node2D
## Godot-first state-driven battle actor. A37 has RUN only: no placeholder states.
## One texture sheet + one manifest + two playback profiles, no VX frame count limit.

signal motion_started(motion: StringName, profile: StringName)
signal motion_unavailable(motion: StringName)

@export var sprite_sheet: Texture2D
@export_file("*.json") var manifest_file := "res://assets/actor01_animation_manifest.json"
@export var initial_motion: StringName = &"run"
@export var initial_profile: StringName = &"run_tuned"
@export_range(0.2, 3.0, 0.05) var playback_multiplier := 1.0

@onready var actor_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _manifest: Dictionary = {}
var _active_motion: StringName = &""
var _active_profile: StringName = &""

func _ready() -> void:
    if sprite_sheet == null:
        push_error("FS A37: required sprite_sheet is absent")
        return
    var text := FileAccess.get_file_as_string(manifest_file)
    if text.is_empty():
        push_error("FS A37: manifest unreadable: " + manifest_file)
        return
    var parsed: Variant = JSON.parse_string(text)
    if not (parsed is Dictionary):
        push_error("FS A37: manifest JSON invalid")
        return
    _manifest = parsed as Dictionary
    var grid: Dictionary = _manifest.get("grid", {})
    var frame_width: int = int(grid.get("frame_width", 0))
    var frame_height: int = int(grid.get("frame_height", 0))
    var columns: int = int(grid.get("columns", 0))
    var count: int = int(grid.get("frame_count", 0))
    if frame_width <= 0 or frame_height <= 0 or columns <= 0 or count <= 0:
        push_error("FS A37: invalid frame grid")
        return
    var image_dimensions := sprite_sheet.get_size()
    if image_dimensions.x != frame_width * columns or image_dimensions.y != frame_height * int(grid.get("rows", 0)):
        push_error("FS A37: source sheet / manifest dimensions disagree")
        return
    var frame_bank := SpriteFrames.new()
    var profiles: Dictionary = _manifest.get("animation_profiles", {})
    for key in profiles.keys():
        var profile: Dictionary = profiles[key]
        var durations: Array = profile.get("durations", [])
        if durations.size() != count:
            push_error("FS A37: wrong duration count for " + str(key))
            continue
        var anim_name := str(key)
        frame_bank.add_animation(anim_name)
        frame_bank.set_animation_loop(anim_name, bool(profile.get("loop", true)))
        frame_bank.set_animation_speed(anim_name, float(profile.get("fps", 8.0)))
        for i in range(count):
            var atlas := AtlasTexture.new()
            atlas.atlas = sprite_sheet
            atlas.region = Rect2(float(i % columns * frame_width), float((i / columns) * frame_height), float(frame_width), float(frame_height))
            atlas.filter_clip = true
            frame_bank.add_frame(anim_name, atlas, float(durations[i]))
    actor_sprite.sprite_frames = frame_bank
    actor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor_sprite.speed_scale = playback_multiplier
    actor_sprite.centered = true
    play_motion(initial_motion, initial_profile)

func play_motion(motion: StringName, profile: StringName = &"run_tuned") -> bool:
    if motion != &"run" or not actor_sprite.sprite_frames.has_animation(profile):
        motion_unavailable.emit(motion)
        return false
    _active_motion = motion
    _active_profile = profile
    actor_sprite.play(profile)
    motion_started.emit(motion, profile)
    return true

func set_profile(profile: StringName) -> bool:
    return play_motion(_active_motion, profile)

func set_playback_multiplier(factor: float) -> void:
    playback_multiplier = clampf(factor, 0.2, 3.0)
    actor_sprite.speed_scale = playback_multiplier

func get_frame_index() -> int:
    return actor_sprite.frame

func get_profile() -> StringName:
    return _active_profile

func is_motion_supported(motion: StringName) -> bool:
    return motion == &"run" and actor_sprite.sprite_frames != null
