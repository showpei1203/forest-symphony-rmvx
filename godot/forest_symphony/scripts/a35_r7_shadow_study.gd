extends Node2D
## Forest Symphony A35 R7 | isolated real Godot 2D tree-trunk shadow study.
## Builds LightOccluder2D polygons on actual existing trees, without modifying
## sprite pixels, anchors, collision shapes or the historical R6 scene.
## O toggles study-cast shadow. This is a prototype, not art-approved HD-2D.
@export var shadows_enabled: bool = false
@export var study_enabled: bool = true
@export var test_lamp_position: Vector2 = Vector2(260.0, 785.0)
var study_light: PointLight2D
var caster_count: int = 0
var casters: Array[LightOccluder2D] = []

func _ready() -> void:
    _create_study_light()
    _create_tree_trunk_casters()
    set_shadows_enabled(shadows_enabled)

func _create_study_light() -> void:
    var bitmap := Image.create(128, 128, false, Image.FORMAT_RGBA8)
    for y in range(128):
        for x in range(128):
            var t := Vector2(float(x) - 63.5, float(y) - 63.5).length() / 63.5
            bitmap.set_pixel(x, y, Color(1.0, 1.0, 1.0, pow(maxf(0.0, 1.0 - t), 2.0)))
    study_light = PointLight2D.new()
    study_light.name = "ForestStudyPointLight"
    study_light.position = test_lamp_position
    study_light.texture = ImageTexture.create_from_image(bitmap)
    study_light.texture_scale = 3.9
    study_light.color = Color(1.0, 0.81, 0.53)
    study_light.energy = 0.98 if study_enabled else 0.0
    study_light.shadow_enabled = false
    study_light.shadow_color = Color(0.10, 0.16, 0.12, 0.78)
    add_child(study_light)

func _create_tree_trunk_casters() -> void:
    var owners: Node2D = get_parent().get_node_or_null("YSort") as Node2D
    if owners == null:
        push_error("FS R7 needs existing YSort; cannot build shadow occluders")
        return
    caster_count = 0
    for entry in owners.get_children():
        if not (entry is Node2D):
            continue
        if entry.get("source_semantic") != "tree":
            continue
        var width_px: float = float(entry.get("footprint_width_px"))
        var height_px: float = float(entry.get("footprint_height_px"))
        var width: float = clampf(maxf(width_px * 0.58, 6.0), 6.0, 18.0)
        var height: float = clampf(maxf(height_px * 0.85, 8.0), 8.0, 24.0)
        var polygon := OccluderPolygon2D.new()
        polygon.closed = true
        polygon.polygon = PackedVector2Array([
            Vector2(-width * 0.44, 0.0),
            Vector2(-width * 0.57, -height * 0.42),
            Vector2(-width * 0.34, -height),
            Vector2(width * 0.34, -height),
            Vector2(width * 0.57, -height * 0.42),
            Vector2(width * 0.44, 0.0)
        ])
        var occluder := LightOccluder2D.new()
        occluder.name = "R7_TrunkLightOccluder"
        occluder.occluder = polygon
        occluder.occluder_light_mask = 1
        occluder.sdf_collision = false
        occluder.position = Vector2.ZERO
        entry.add_child(occluder)
        casters.append(occluder)
        caster_count += 1
    print("FS A35 R7 real trunk LightOccluder2D count=", caster_count)

func set_shadows_enabled(on: bool) -> void:
    shadows_enabled = on
    if study_light != null:
        study_light.shadow_enabled = on

func set_study_enabled(on: bool) -> void:
    study_enabled = on
    if study_light != null:
        study_light.energy = 0.98 if on else 0.0

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_O:
            set_shadows_enabled(not shadows_enabled)
