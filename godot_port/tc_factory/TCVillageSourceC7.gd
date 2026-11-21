extends "res://tc_factory/TCVillagePilot.gd"
## Complete FS A36G-R4 original-source art C7. A36G source.blocking semantics
## control collision. This is NOT a historical 193-tree collision revalidation.
var c7_tree_roots_loaded := 0

func _ready() -> void:
    super._ready()
    _build_c7_source_tree_roots()

func _build_c7_source_tree_roots() -> void:
    var file := FileAccess.open(generated_dir + "TC_C7_ROOT_FOOTPRINTS.json",FileAccess.READ)
    if file == null:
        push_error("C7 source tree root metadata unavailable")
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        push_error("C7 independent original source blocking manifest invalid")
        return
    for entry in parsed.get("colliders",[]):
        var r: Array = entry.get("bbox",[])
        if r.size()!=4 or entry.get("original_manifest_blocking",false)!=true:
            push_error("C7 must never create collision for R4 nonblocking props")
            return
        var x0 := float(r[0])
        var y0 := float(r[1])
        var x1 := float(r[2])
        var y1 := float(r[3])
        if x1<=x0 or y1<=y0:
            push_error("C7 blocking source tree footprint invalid")
            return
        var body := StaticBody2D.new()
        body.name = "C7_ORIGINAL_ROOT_" + str(entry["id"])
        body.collision_layer = 1
        body.collision_mask = 0
        add_child(body)
        var shape := CollisionShape2D.new()
        var rect := RectangleShape2D.new()
        rect.size = Vector2(x1-x0,y1-y0)
        shape.shape = rect
        shape.position = Vector2((x0+x1)*0.5,(y0+y1)*0.5)
        body.add_child(shape)
        c7_tree_roots_loaded += 1
