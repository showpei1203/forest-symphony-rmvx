extends SceneTree
## Private locked-source real 4.7.2 test; no private inputs are uploaded to GitHub.
const SHA_MASTER := "091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530"
var checks := 0
var failures: Array[String] = []

func check(test: bool, label: String) -> void:
    checks += 1
    if not test:
        failures.append(label)
        push_error("A31 REAL FAIL: " + label)

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    check(FileAccess.get_sha256("res://private_assets/full_ground.png") == SHA_MASTER,"master original SHA unchanged")
    var packed: PackedScene = load("res://scenes/elf_forest_map.tscn")
    check(packed != null, "same actual A30 scene")
    if packed == null: quit(1);return
    var scene: Node2D = packed.instantiate()
    get_root().add_child(scene)
    await process_frame
    await process_frame
    var player = scene.get_node("Characters/Player")
    player.set_physics_process(false)
    check(player.original_actor != null and not player.original_actor.is_empty(), "approved F0 loaded")
    check(player.assisted_canopy_visibility == false,"opt-in mode is OFF by default")
    check(is_equal_approx(player.assisted_tree_alpha,0.35),"inspector assistance alpha is 0.35")
    check(player.run_frames.size()==3,"A62 approved 3-frame battle Run preserved")
    # True same-world-position comparisons
    player.position=Vector2(232,556)
    player._set_visual(-1)
    player.set_canopy_visibility_aid(false)
    var original: Image = player.last_overlay_cpu.duplicate()
    check(player.last_overlay_cpu.get_size()==Vector2i(48,48), "no resize / native 1x actor")
    var base_count := _count_opaque(original)
    check(base_count==197, "original A30 TREE_BEHIND source count 197")
    player.set_canopy_visibility_aid(true)
    var aided: Image = player.last_overlay_cpu.duplicate()
    check(_count_opaque(aided)==base_count, "aided mask retains exact same source footprint")
    var changed := 0
    for y in range(original.get_height()):
        for x in range(original.get_width()):
            var b: Color = original.get_pixel(x,y)
            var a: Color = aided.get_pixel(x,y)
            check(is_equal_approx(a.r,b.r) and is_equal_approx(a.g,b.g) and is_equal_approx(a.b,b.b), "unchanged owner-source RGB")
            if b.a > 0.0:
                changed += 1
                check(a.a < b.a and abs(a.a-0.35) < 0.006, "only canopy overlay alpha reduced")
            else:
                check(a.a==0.0,"no overlay pixels generated outside source")
    check(changed==197, "197 source pixels adjusted with A31 opt-in mode")
    player.set_canopy_visibility_aid(false)
    check(player.last_overlay_cpu.get_data()==original.get_data(),"opt-in OFF restores original A30 overlay byte for byte")
    player.position=Vector2(232,596)
    player.refresh_occlusion()
    check(_count_opaque(player.last_overlay_cpu)==0,"tree in-front original mask=0")
    player.set_canopy_visibility_aid(true)
    check(_count_opaque(player.last_overlay_cpu)==0,"tree in-front assisted mask=0")
    player.position=Vector2(735,621)
    player.set_canopy_visibility_aid(false)
    var bridge_baseline: Image = player.last_overlay_cpu.duplicate()
    check(_count_opaque(bridge_baseline)==29,"bridge behind original mask=29")
    player.set_canopy_visibility_aid(true)
    check(player.last_overlay_cpu.get_data()==bridge_baseline.get_data(),"bridge rail unaffected by tree assist, every RGBA byte identical")
    player.position=Vector2(232,556)
    player._set_visual(1)
    player.refresh_occlusion()
    check(player.current_actor == player.run_frames[1],"actual A62 RUN2 is in use")
    check(player.last_visual_id==1,"frame switch invalidated dynamic foreground")
    player._set_visual(2)
    player.refresh_occlusion()
    check(player.last_visual_id==2,"A62 RUN3 also invalidates dynamic foreground")
    check(player.get_node("Camera2D") != null,"original real camera retained")
    scene.queue_free()
    if failures.is_empty():
        print("A31 GODOT NATIVE PASS %d checks | A30 source parity retained | bridge unchanged | real A62 frames" % checks)
        quit(0)
    else:
        print("A31 GODOT NATIVE FAIL %d checks, %d failures" % [checks,failures.size()])
        quit(1)

func _count_opaque(img: Image) -> int:
    var n := 0
    for y in img.get_height():
        for x in img.get_width():
            if img.get_pixel(x,y).a > 0.0:n += 1
    return n
