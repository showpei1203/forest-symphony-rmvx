extends "res://tc_factory/TCVillagePilot.gd"
## New C6 independent tree-root and waystone footprint colliders.
## DO NOT count these as historical 193 tree roots; only three NEW authored props.
var c6_root_colliders_loaded := 0

func _ready() -> void:
    super._ready()
    _build_c6_roots()

func _build_c6_roots() -> void:
    var fp := FileAccess.open(generated_dir + "TC_C6_ROOT_FOOTPRINTS.json", FileAccess.READ)
    if fp == null:
        push_error("C6 semantic root footprint manifest missing")
        return
    var obj: Variant = JSON.parse_string(fp.get_as_text())
    if not (obj is Dictionary):
        push_error("C6 semantic root footprint manifest invalid")
        return
    for footprint in obj.get("colliders", []):
        var r: Array = footprint.get("bbox", [])
        if r.size()!=4:
            push_error("C6 root bbox must have four source-defined values")
            return
        var x0 := float(r[0])
        var y0 := float(r[1])
        var x1 := float(r[2])
        var y1 := float(r[3])
        if x1<=x0 or y1<=y0:
            push_error("C6 root footprint width or height is invalid")
            return
        var body := StaticBody2D.new()
        body.name = "C6_ROOT_" + str(footprint["id"])
        body.collision_layer = 1
        body.collision_mask = 0
        add_child(body)
        var shape := CollisionShape2D.new()
        var rect := RectangleShape2D.new()
        rect.size = Vector2(x1-x0,y1-y0)
        shape.shape = rect
        shape.position = Vector2((x0+x1)/2,(y0+y1)/2)
        body.add_child(shape)
        c6_root_colliders_loaded += 1
