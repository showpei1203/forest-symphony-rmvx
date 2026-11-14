@tool
extends "res://scripts/a36b_world.gd"
## A36C R10: 148 source-derived river collision candidates, disabled until native QA.
const CANDIDATE_JSON := "res://data/a36_terrain_semantic_candidates.json"
var water_collision_enabled := false
var candidate_cells: Array = []
func _ready() -> void:
    super._ready()
    if Engine.is_editor_hint(): return
    var f := FileAccess.open(CANDIDATE_JSON, FileAccess.READ)
    if f == null:
        push_error("R10 missing water candidate source"); return
    var data = JSON.parse_string(f.get_as_text())
    if typeof(data) != TYPE_DICTIONARY or data.get("river_cell_count", -1) != 148:
        push_error("R10 invalid water candidate source"); return
    candidate_cells = data["river_blocked_cells"]
    _build_candidate_shapes()
    print("R10: 148 candidate water cells; physical collision OFF until river/bridge art QA")
func _build_candidate_shapes() -> void:
    var layer := $RiverCollisionCandidates
    for xy in candidate_cells:
        var b := StaticBody2D.new()
        b.name = "water_%02d_%02d" % [int(xy[0]), int(xy[1])]
        b.position = Vector2((int(xy[0]) + 0.5) * 32.0, (int(xy[1]) + 0.5) * 32.0)
        b.collision_layer = 1 if water_collision_enabled else 0
        b.collision_mask = 0
        var s := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(32, 32)
        s.shape = shape
        b.add_child(s)
        layer.add_child(b)
func set_water_collision_enabled(enabled: bool) -> void:
    water_collision_enabled = enabled
    if not has_node("RiverCollisionCandidates"): return
    for body in $RiverCollisionCandidates.get_children():
        body.collision_layer = 1 if enabled else 0
