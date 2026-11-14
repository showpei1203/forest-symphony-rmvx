extends SceneTree
## Native Godot OpenGL comparison using exact private A11/A62 source images.
## Does NOT imply ART approval; both variants remain candidates.
var checks := 0
func _initialize() -> void:
    call_deferred("capture")

func shot(folder:String, name:String) -> void:
    await process_frame
    await process_frame
    var screen := get_root().get_texture().get_image()
    if screen.get_size() != Vector2i(544,416) or screen.save_png(folder.path_join(name)) != OK:
        push_error("A31 native frame save failed: " + name)
        quit(1)
    checks += 1
    print("A31 GODOT FRAME ",name)

func capture() -> void:
    var scene: Node2D = load("res://scenes/elf_forest_map.tscn").instantiate() as Node2D
    get_root().add_child(scene)
    await process_frame
    await process_frame
    var player = scene.get_node("Characters/Player")
    player.set_physics_process(false)
    scene.get_node("HUD").visible = false
    var folder := OS.get_environment("FS_A31_CAPTURE_DIR")
    if folder.is_empty():
        push_error("FS_A31_CAPTURE_DIR is required")
        quit(1)
        return
    DirAccess.make_dir_recursive_absolute(folder)
    player.position=Vector2(232,556)
    player._set_visual(1)
    player.set_canopy_visibility_aid(false)
    await shot(folder,"GODOT_A31_TREE_BASE_A30.png")
    player.assisted_tree_alpha = 0.65
    player.set_canopy_visibility_aid(true)
    await shot(folder,"GODOT_A31_TREE_ASSIST_065.png")
    player.assisted_tree_alpha = 0.35
    player.set_canopy_visibility_aid(true)
    await shot(folder,"GODOT_A31_TREE_ASSIST_035.png")
    player.assisted_tree_alpha = 0.20
    player.set_canopy_visibility_aid(true)
    await shot(folder,"GODOT_A31_TREE_ASSIST_020.png")
    player.assisted_tree_alpha = 0.65
    player.set_canopy_visibility_aid(true)
    # Front case should look exactly the same with experimental aid.
    player.position=Vector2(232,596)
    player.refresh_occlusion()
    await shot(folder,"GODOT_A31_FRONT_ASSIST_065.png")
    player.set_canopy_visibility_aid(false)
    await shot(folder,"GODOT_A31_FRONT_A30.png")
    player.position=Vector2(735,621)
    player.refresh_occlusion()
    await shot(folder,"GODOT_A31_BRIDGE_BASE_A30.png")
    player.set_canopy_visibility_aid(true)
    await shot(folder,"GODOT_A31_BRIDGE_ASSIST.png")
    print("A31 GODOT NATIVE CAPTURE PASS %d screenshots" % checks)
    quit(0)
