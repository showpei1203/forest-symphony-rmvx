class_name FSActorBreathRig
extends Node2D
## A39: Native Godot AnimationPlayer controls ONLY the local torso shader.
## Original approved 64x64 art is preserved byte-for-byte; all deformations are reversible.

signal inhale_peak

@onready var pixel_sprite: Sprite2D = $Sprite2D
@onready var breath_player: AnimationPlayer = $AnimationPlayer
const BREATH_SECONDS: float = 3.2
const PHASES: Array[float] = [0.0, 0.27, 0.55, 0.87, 1.0, 0.55, 0.27, 0.0]

func _ready() -> void:
    pixel_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    pixel_sprite.centered = true
    var track_animation := Animation.new()
    track_animation.length = BREATH_SECONDS
    track_animation.loop_mode = Animation.LOOP_LINEAR
    var track: int = track_animation.add_track(Animation.TYPE_VALUE)
    track_animation.track_set_path(track, NodePath("Sprite2D:material:shader_parameter/breath_phase"))
    track_animation.track_set_interpolation_type(track, Animation.INTERPOLATION_LINEAR)
    track_animation.value_track_set_update_mode(track, Animation.UPDATE_CONTINUOUS)
    for i in range(PHASES.size()):
        track_animation.track_insert_key(track, float(i) * BREATH_SECONDS / float(PHASES.size()), PHASES[i])
    track_animation.track_insert_key(track, BREATH_SECONDS, 0.0)
    var library := AnimationLibrary.new()
    library.add_animation("breathing", track_animation)
    breath_player.add_animation_library("", library)
    breath_player.play("breathing")

func start_breathing() -> void:
    if breath_player.has_animation("breathing"):
        breath_player.play("breathing")

func stop_breathing() -> void:
    breath_player.stop()
    set_breath(0.0)

func set_breath(value: float) -> void:
    (pixel_sprite.material as ShaderMaterial).set_shader_parameter("breath_phase", clampf(value, 0.0, 1.0))

func get_breath() -> float:
    return float((pixel_sprite.material as ShaderMaterial).get_shader_parameter("breath_phase"))

func get_phase_index() -> int:
    if breath_player.current_animation != "breathing":
        return 0
    return mini(7, int(floor(breath_player.current_animation_position / 0.4)))
