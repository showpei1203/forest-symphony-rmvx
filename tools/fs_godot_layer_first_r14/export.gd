extends SceneTree

const CANVAS_SIZE := Vector2i(544, 416)
const MODES := ["BASE", "PAR", "FULL", "ACTOR_BACK", "ACTOR_FRONT"]

func _initialize() -> void:
    call_deferred("_render_all")

func _render_all() -> void:
    var canvas := SubViewport.new()
    canvas.name = "FSLayerViewport"
    canvas.size = CANVAS_SIZE
    canvas.transparent_bg = true
    canvas.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    canvas.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(canvas)
    var map: Node2D = load("res://LayeredPilot.tscn").instantiate()
    canvas.add_child(map)
    var directory: String = ProjectSettings.globalize_path("res://exported")
    DirAccess.make_dir_recursive_absolute(directory)
    for mode in MODES:
        map.set_export_mode(mode)
        await process_frame
        await process_frame
        await create_timer(0.10).timeout
        var result: Image = canvas.get_texture().get_image()
        if result.is_empty():
            push_error("Viewport returned empty image for mode " + mode)
            quit(6)
            return
        var path: String = directory.path_join("GODOT_" + mode + ".png")
        var status: Error = result.save_png(path)
        if status != OK:
            push_error("PNG export failure " + mode + " " + str(status))
            quit(7)
            return
        print("R14_GODOT_EXPORT ", mode, " -> ", path, " size=", result.get_width(),"x",result.get_height())
    print("R14_GODOT_LAYER_EXPORT_DONE modes=", MODES.size())
    quit()