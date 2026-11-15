extends "res://scripts/a35_r8_canopy_shadow.gd"
## A35 R8 R2: two independent real Godot 2D lights and shadow-safe fill.
## An unshadowed supplemental PointLight2D retains light under opaque canopy
## occluders. This is an ARTISTIC APPROXIMATION of translucency, not alpha-shadow
## transmission or physical volumetric lighting.
## F toggles gentle fill, M toggles second canopy-edge light.
const STUDY_KEY_ENERGY: float = 0.98
const SECONDARY_KEY_ENERGY: float = 0.66
const SECONDARY_FILL_FRACTION: float = 0.22

@export_range(0.0, 0.42, 0.01) var fill_fraction: float = 0.24
@export var multi_light_enabled: bool = false
@export var second_light_position: Vector2 = Vector2(1090, 280)

var fill_light: PointLight2D
var secondary_key: PointLight2D
var secondary_fill: PointLight2D
var brightness_controls_ready: bool = false

func _ready() -> void:
    super._ready()
    _create_fill_lights()
    brightness_controls_ready = true
    set_fill_fraction(fill_fraction)
    set_multi_light_enabled(multi_light_enabled)
    print("A35 R8 R2 dual-light study: canopy=",canopy_caster_count,
        " primary=",study_light.position," secondary=",second_light_position,
        " fill_fraction=",fill_fraction," multipoint=",multi_light_enabled)

func _create_fill_lights() -> void:
    if study_light == null:
        push_error("FS A35 R8 R2 requires original shadowed PointLight2D")
        return
    fill_light = PointLight2D.new()
    fill_light.name = "TranslucentCanopyFill"
    fill_light.texture = study_light.texture
    fill_light.texture_scale = study_light.texture_scale
    fill_light.position = study_light.position
    fill_light.color = Color(0.91, 0.95, 0.87)
    fill_light.shadow_enabled = false
    fill_light.energy = 0.0
    add_child(fill_light)

    secondary_key = PointLight2D.new()
    secondary_key.name = "SecondaryGroveLight"
    secondary_key.position = second_light_position
    secondary_key.texture = study_light.texture
    secondary_key.texture_scale = 3.4
    secondary_key.color = Color(0.66, 0.77, 0.96)
    secondary_key.shadow_enabled = true
    secondary_key.shadow_color = Color(0.11, 0.16, 0.21, 0.76)
    secondary_key.shadow_filter = CanvasItemLightShadowFilter.SHADOW_FILTER_PCF5
    secondary_key.shadow_filter_smooth = 2.2
    secondary_key.energy = 0.0
    add_child(secondary_key)

    secondary_fill = PointLight2D.new()
    secondary_fill.name = "SecondaryGroveFill"
    secondary_fill.position = second_light_position
    secondary_fill.texture = study_light.texture
    secondary_fill.texture_scale = secondary_key.texture_scale
    secondary_fill.color = Color(0.77, 0.87, 1.0)
    secondary_fill.shadow_enabled = false
    secondary_fill.energy = 0.0
    add_child(secondary_fill)

func set_fill_fraction(value: float) -> void:
    fill_fraction = clampf(value, 0.0, 0.42)
    if study_light != null:
        study_light.energy = STUDY_KEY_ENERGY * (1.0 - fill_fraction) if study_enabled else 0.0
    if fill_light != null:
        fill_light.energy = STUDY_KEY_ENERGY * fill_fraction if study_enabled else 0.0

func set_study_enabled(on: bool) -> void:
    super.set_study_enabled(on)
    # Called from outside after _ready; do not accidentally re-enable study lamp.
    set_fill_fraction(fill_fraction)
    _apply_secondary_light()

func set_multi_light_enabled(on: bool) -> void:
    multi_light_enabled = on
    _apply_secondary_light()

func _apply_secondary_light() -> void:
    if secondary_key == null or secondary_fill == null:
        return
    var active: bool = multi_light_enabled and study_enabled
    secondary_key.energy = SECONDARY_KEY_ENERGY * (1.0 - SECONDARY_FILL_FRACTION) if active else 0.0
    secondary_fill.energy = SECONDARY_KEY_ENERGY * SECONDARY_FILL_FRACTION if active else 0.0
    secondary_key.shadow_enabled = true

func _unhandled_key_input(event: InputEvent) -> void:
    super._unhandled_key_input(event)
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F:
            set_fill_fraction(0.0 if fill_fraction > 0.0 else 0.24)
        if event.keycode == KEY_M:
            set_multi_light_enabled(not multi_light_enabled)
