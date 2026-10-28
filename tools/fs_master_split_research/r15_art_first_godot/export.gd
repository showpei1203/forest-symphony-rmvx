extends SceneTree
const MODES := ["MASTER", "PAR", "COMPOSITE", "ACTOR_BACK", "ACTOR_FRONT"]

func _initialize() -> void:
    call_deferred("_render_output")

func _render_output() -> void:
    var viewport := SubViewport.new()
    viewport.size = Vector2i(1280,928)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var scene: Node2D = load("res://ArtFirstVillage.tscn").instantiate()
    viewport.add_child(scene)
    var directory: String = ProjectSettings.globalize_path("res://exported")
    DirAccess.make_dir_recursive_absolute(directory)
    for mode in MODES:
        scene.set_capture_mode(mode)
        await process_frame
        await process_frame
        await create_timer(0.12).timeout
        var img: Image = viewport.get_texture().get_image()
        if img.is_empty() or img.get_size() != Vector2i(1280,928):
            push_error("Render invalid "+mode)
            quit(4)
            return
        var p: String = directory.path_join("R15_" + mode + ".png")
        var rc: Error = img.save_png(p)
        if rc != OK:
            push_error("PNG error "+mode)
            quit(5)
            return
        print("R15_GODOT_RENDER ", mode, " -> ", p)
    quit()