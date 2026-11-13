extends SceneTree
## Only run on owner private source package, isolated native Godot engine. No GitHub art.
func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var packed: PackedScene = load("res://scenes/elf_forest_map.tscn")
    var scene: Node2D = packed.instantiate()
    get_root().add_child(scene)
    var player: CharacterBody2D = scene.get_node("Characters/Player")
    scene.get_node("HUD").visible = false  # art QA capture, not UX demo
    var output_dir := OS.get_environment("FS_A29_CAPTURE_DIR")
    if output_dir.is_empty():
        output_dir = "/mnt/data/fs_godot_a29/qa"
    DirAccess.make_dir_recursive_absolute(output_dir)
    var points := [
        ["TREE_BEHIND", Vector2(232, 556)],
        ["TREE_FRONT", Vector2(232, 596)],
        ["BRIDGE_BEHIND", Vector2(735, 621)],
        ["BRIDGE_FRONT", Vector2(735, 670)],
    ]
    await process_frame
    await process_frame
    for row in points:
        player.position = row[1]
        player.refresh_occlusion()
        await process_frame
        await process_frame
        var shot: Image = get_root().get_texture().get_image()
        var path := output_dir.path_join("GODOT_472_REAL_" + row[0] + ".png")
        var err := shot.save_png(path)
        if err != OK:
            push_error("Godot screenshot save failed: " + path)
            quit(1)
            return
        print("GODOT_REAL_SCREENSHOT ", path, " size=", shot.get_size())
    quit(0)
