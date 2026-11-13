extends SceneTree
## Public CI: entirely synthetic. No owner art, Drive credentials or paid assets.
const Occlusion = preload("res://scripts/fs_occlusion.gd")
var checks := 0

func check(condition: bool, label: String) -> void:
    checks += 1
    if not condition:
        push_error("A29 TEST FAIL: " + label)
        quit(1)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var actor := Image.create_empty(3, 3, false, Image.FORMAT_RGBA8)
    actor.fill(Color(1, 1, 1, 1))
    var source := Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
    source.fill(Color.TRANSPARENT)
    source.set_pixel(1, 1, Color(1, 0, 0, 1))
    source.set_pixel(2, 2, Color(0, 1, 0, 1))
    var owners := [{
        "semantic": "tree_canopy",
        "rect": Rect2i(1, 1, 4, 4),
        "image": source,
        "far": 2,
        "near": 5,
    }]
    var back := Occlusion.build_overlay(actor, Vector2i(2, 2), Vector2i(2, 2), owners)
    check(Occlusion.opaque_count(back) == 2, "back actor source alpha count")
    check(back.get_pixel(0, 0).r > 0.95, "preserve red source texel")
    check(back.get_pixel(1, 1).g > 0.95, "preserve green source texel")
    var front := Occlusion.build_overlay(actor, Vector2i(2, 2), Vector2i(2, 6), owners)
    check(Occlusion.opaque_count(front) == 0, "foreground actor visible")
    actor.set_pixel(0, 0, Color.TRANSPARENT)
    var transparent_actor := Occlusion.build_overlay(actor, Vector2i(2, 2), Vector2i(2, 2), owners)
    check(Occlusion.opaque_count(transparent_actor) == 1, "actor alpha silhouette")
    check(transparent_actor.get_pixel(0, 0).a == 0.0, "no occlusion outside actor silhouette")
    print("A29 GODOT SOURCE-ONLY SYNTHETIC CI PASSED: %d checks" % checks)
    quit(0)
