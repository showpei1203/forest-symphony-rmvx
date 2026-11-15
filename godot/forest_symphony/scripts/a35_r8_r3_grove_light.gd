extends "res://scripts/a35_r8_r2_light_balance.gd"
## A35 R8 R3: replace overbright northeast cottage lamp with isolated grove accent.
## The original R8/R2 scenes and sprite/physics resources remain untouched.
## This remains an artistic, nonphysical unshadowed-fill approximation.
@export var r3_grove_position: Vector2 = Vector2(805.0, 90.0)
@export_range(0.0, 0.60, 0.01) var r3_grove_energy: float = 0.29
@export_range(1.4, 3.2, 0.05) var r3_grove_scale: float = 2.20
@export_range(0.0, 0.4, 0.01) var r3_grove_fill: float = 0.14

func _ready() -> void:
    # Must set position before parent constructs the actual PointLight2D children.
    second_light_position = r3_grove_position
    super._ready()
    if secondary_key == null or secondary_fill == null:
        push_error("A35 R8 R3 expected secondary key and fill from sealed R2")
        return
    secondary_key.texture_scale = r3_grove_scale
    secondary_fill.texture_scale = r3_grove_scale
    secondary_key.color = Color(0.76, 0.86, 0.97)
    secondary_fill.color = Color(0.85, 0.92, 1.0)
    secondary_key.shadow_color = Color(0.10, 0.16, 0.18, 0.72)
    _apply_secondary_light()
    print("A35 R8 R3 northeast GROVE light at ", secondary_key.position,
        " with total energy ", r3_grove_energy,
        " radius-scale ", r3_grove_scale, " multi=", multi_light_enabled)

func _apply_secondary_light() -> void:
    # Important: R2 demonstrated that energy=0 is NOT enough to disable a
    # PointLight2D. We retain the explicit enabled gate.
    super._apply_secondary_light()
    if secondary_key == null or secondary_fill == null:
        return
    var active: bool = multi_light_enabled and study_enabled and r3_grove_energy > 0.0
    secondary_key.enabled = active
    secondary_fill.enabled = active and r3_grove_fill > 0.0001
    secondary_key.energy = r3_grove_energy * (1.0 - r3_grove_fill) if active else 0.0
    secondary_fill.energy = r3_grove_energy * r3_grove_fill if active else 0.0

func set_grove_energy(value: float) -> void:
    r3_grove_energy = clampf(value, 0.0, 0.60)
    _apply_secondary_light()

func set_grove_fill(value: float) -> void:
    r3_grove_fill = clampf(value, 0.0, 0.40)
    _apply_secondary_light()
