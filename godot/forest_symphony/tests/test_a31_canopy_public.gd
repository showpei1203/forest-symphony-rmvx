extends SceneTree
## Source-only native Godot 4.7.2 regression: default image identical,
## opt-in A31 tree alpha only, same master/source RGB, and bridge unchanged.
const Overlay = preload("res://scripts/fs_occlusion.gd")
var checks := 0
var errors: Array[String] = []

func ok(result: bool, description: String) -> void:
    checks += 1
    if not result:
        errors.append(description)
        push_error("A31 PUBLIC FAIL: " + description)

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var actor := Image.create_empty(8,8,false,Image.FORMAT_RGBA8)
    actor.fill(Color(0.94,0.91,0.87,1.0))
    var tree_src := Image.create_empty(8,8,false,Image.FORMAT_RGBA8)
    tree_src.fill(Color(0.09,0.62,0.11,1.0))
    var bridge_src := Image.create_empty(8,8,false,Image.FORMAT_RGBA8)
    bridge_src.fill(Color(0.67,0.37,0.24,1.0))
    var tree_owner := {"semantic":"tree_canopy", "rect":Rect2i(0,0,8,8),"image":tree_src, "far":2,"near":16}
    var bridge_owner := {"semantic":"bridge_near_rail", "rect":Rect2i(0,0,8,8),"image":bridge_src, "far":2,"near":16}
    var foot := Vector2i(4,1)
    var base := Overlay.build_overlay(actor,Vector2i.ZERO,foot,[tree_owner])
    var explicit := Overlay.build_overlay(actor,Vector2i.ZERO,foot,[tree_owner],1.0)
    ok(base.get_data() == explicit.get_data(),"default A30 same pixel bytes as 1.0 opacity")
    var aided := Overlay.build_overlay(actor,Vector2i.ZERO,foot,[tree_owner],0.65)
    ok(aided.get_size() == base.get_size(),"world coordinates/size unchanged")
    var adjusted := 0
    for y in range(8):
        for x in range(8):
            var src: Color = base.get_pixel(x,y)
            var dst: Color = aided.get_pixel(x,y)
            ok(is_equal_approx(src.r,dst.r) and is_equal_approx(src.g,dst.g) and is_equal_approx(src.b,dst.b),"source tree RGB always unchanged")
            if src.a > 0.0:
                ok(dst.a < src.a and abs(dst.a-0.65) <= (1.01/255.0),"tree alpha 0.65 within 8-bit tolerance")
                adjusted += 1
            else:
                ok(dst.a == 0.0,"never create new opaque pixels")
    ok(adjusted > 0,"tree source actually covered part of actor")
    var bridge_a := Overlay.build_overlay(actor,Vector2i.ZERO,foot,[bridge_owner],1.0)
    var bridge_b := Overlay.build_overlay(actor,Vector2i.ZERO,foot,[bridge_owner],0.65)
    ok(bridge_a.get_data() == bridge_b.get_data(),"bridge rail remains source-exact and unchanged")
    var front := Overlay.build_overlay(actor,Vector2i.ZERO,Vector2i(4,7),[tree_owner],0.65)
    # Depending on tree's depth hint, the final row may still be occluded: what
    # matters is the new aid doesn't invent occlusion where none exists.
    ok(Overlay.opaque_count(front) <= Overlay.opaque_count(aided),"further-forward actor not more covered")
    if errors.is_empty():
        print("A31 GODOT CANOPY PUBLIC PASS: %d checks | only tree alpha changes | A30 baseline identical" % checks)
        quit(0)
    else:
        print("A31 FAIL: ",errors)
        quit(1)
