extends "res://scripts/a35_r7_shadow_study.gd"
## A35 R8: real painted-pixel canopy -> Godot OccluderPolygon2D pipeline.
## Preserves the existing R7 trunk shadows and all original PAR/physics.
## Toggle P for canopy shadows independently; O still toggles all lighting shadows.
## Source polygons are from exact owner-only tree sprite PNGs, not rectangles.
@export var canopy_enabled: bool = false
@export var soften_shadows: bool = true
const PROFILE_FILE := "res://data/a35_r8_canopy_profiles.json"
var canopy_caster_count: int = 0
var canopy_profile_count: int = 0
var canopy_setup_usec: int = 0
var canopy_nodes: Array[LightOccluder2D] = []
var canopy_errors: int = 0

func _ready() -> void:
    super._ready()
    var started := Time.get_ticks_usec()
    _create_canopy_casters()
    canopy_setup_usec = Time.get_ticks_usec() - started
    if study_light != null and soften_shadows:
        study_light.set("shadow_filter", 1) # Godot Light2D PCF5: moderate 2D shadow softening
        study_light.set("shadow_filter_smooth", 2.0)
    set_canopy_enabled(canopy_enabled)
    print("A35 R8 original-alpha canopy occluders=", canopy_caster_count,
        " unique source profiles=", canopy_profile_count,
        " setup_usec=", canopy_setup_usec, " errors=", canopy_errors)

func _create_canopy_casters() -> void:
    if not FileAccess.file_exists(PROFILE_FILE):
        push_error("A35 R8 missing source-derived canopy profile file")
        canopy_errors += 1
        return
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PROFILE_FILE))
    if not (data is Dictionary):
        push_error("A35 R8 invalid JSON profile")
        canopy_errors += 1
        return
    var payload: Dictionary = data
    var profiles: Dictionary = payload["profiles"]
    var lookup: Dictionary = payload["owners"]
    canopy_profile_count = profiles.size()
    var owner_layer: Node2D = get_parent().get_node("YSort") as Node2D
    var polygon_cache: Dictionary = {}
    for owner in owner_layer.get_children():
        if owner is CharacterBody2D:
            continue
        if owner.get("source_semantic") != "tree":
            continue
        var path: String = str(owner.get("source_file"))
        var expected: String = str(lookup.get(str(owner.name), ""))
        if expected != path or not profiles.has(path):
            canopy_errors += 1
            push_error("A35 R8 source profile mismatch " + str(owner.name))
            continue
        if not polygon_cache.has(path):
            var profile: Dictionary = profiles[path]
            var points := PackedVector2Array()
            for coord in profile["polygon"]:
                points.append(Vector2(float(coord[0]), float(coord[1])))
            if points.size() < 8 or points.size() > 48:
                canopy_errors += 1
                push_error("A35 R8 invalid vertex budget in " + path)
                continue
            var geometry := OccluderPolygon2D.new()
            geometry.closed = true
            geometry.polygon = points
            polygon_cache[path] = geometry
        if not polygon_cache.has(path):
            continue
        var mask := LightOccluder2D.new()
        mask.name = "R8_CanopyLightOccluder"
        mask.occluder = polygon_cache[path]
        mask.occluder_light_mask = 1
        mask.sdf_collision = false
        mask.position = Vector2.ZERO
        owner.add_child(mask)
        canopy_nodes.append(mask)
        canopy_caster_count += 1
    if canopy_caster_count != 175:
        canopy_errors += 1
        push_error("A35 R8 must add canopy light masks for all 175 trees")

func set_canopy_enabled(on: bool) -> void:
    canopy_enabled = on
    for mask in canopy_nodes:
        mask.visible = on
        mask.occluder_light_mask = 1 if on else 0

func _unhandled_key_input(event: InputEvent) -> void:
    super._unhandled_key_input(event)
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_P:
            set_canopy_enabled(not canopy_enabled)
