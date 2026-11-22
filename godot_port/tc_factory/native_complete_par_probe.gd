extends SceneTree
## T-C D14: native GPU 1x two-layer evidence for images supplied outside Git.
## Private art remains in owner-only Drive; the GitHub CI fixture is synthetic.
## NOT an ART PASS, not an occlusion/collision pass, not a Master extraction.
const TARGET := Vector2i(1280, 928)

func _initialize() -> void:
    call_deferred("_run")

func _stop(message: String) -> void:
    push_error("FS_TC_NATIVE_PAIR_FAIL: " + message)
    quit(2)

func _run() -> void:
    var params: Dictionary = {}
    for argument in OS.get_cmdline_user_args():
        var item: String = str(argument)
        if item.begins_with("--") and item.contains("="):
            var pieces := item.substr(2).split("=", false, 1)
            if pieces.size() == 2:
                params[pieces[0]] = pieces[1]
    var ground_path: String = str(params.get("ground", ""))
    var par_path: String = str(params.get("par", ""))
    var out_dir: String = str(params.get("out", ""))
    var ground_sha: String = str(params.get("ground-sha", ""))
    if ground_path.is_empty() or par_path.is_empty() or out_dir.is_empty():
        _stop("Explicit --ground, --par and --out required; no implicit sample art")
        return
    if ground_path == par_path:
        _stop("Ground and CompletePAR must have different independent source paths")
        return
    if not FileAccess.file_exists(ground_path) or not FileAccess.file_exists(par_path):
        _stop("Both separate source image files must exist")
        return
    var version: Dictionary = Engine.get_version_info()
    if int(version.get("major", 0)) != 4 or int(version.get("minor", 0)) != 7 or int(version.get("patch", 0)) != 2:
        _stop("Engine must be Godot 4.7.2, got " + str(version))
        return
    if not ground_sha.is_empty() and FileAccess.get_sha256(ground_path) != ground_sha.to_lower():
        _stop("Locked Ground SHA256 mismatch; never silently replace the map")
        return
    var ground: Image = Image.load_from_file(ground_path)
    var par: Image = Image.load_from_file(par_path)
    if ground == null or par == null or ground.is_empty() or par.is_empty():
        _stop("Image loading failed")
        return
    if ground.get_size() != TARGET or par.get_size() != TARGET:
        _stop("Native 1x 1280x928 world shape required: G=" + str(ground.get_size()) + " PAR=" + str(par.get_size()))
        return
    if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
        _stop("Cannot create QA output directory")
        return
    var view := SubViewport.new()
    view.name = "FS_TC_D14_NATIVE_1X"
    view.size = TARGET
    view.disable_3d = true
    view.transparent_bg = false
    view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(view)

    # Authoring contract: GROUND and EVERY non-ground object drawn independently.
    # No occluder subsets, tilemap reconstruction, or per-object collision logic.
    var stage := Node2D.new()
    stage.name = "WORLD_ORIGIN_0_0"
    view.add_child(stage)
    var ground_sprite := Sprite2D.new()
    ground_sprite.name = "D11_LOCKED_GROUND"
    ground_sprite.centered = false
    ground_sprite.position = Vector2.ZERO
    ground_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    ground_sprite.texture = ImageTexture.create_from_image(ground)
    ground_sprite.z_index = 0
    stage.add_child(ground_sprite)
    var par_sprite := Sprite2D.new()
    par_sprite.name = "D13_ALL_NON_GROUND_PAR"
    par_sprite.centered = false
    par_sprite.position = Vector2.ZERO
    par_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    par_sprite.texture = ImageTexture.create_from_image(par)
    par_sprite.z_index = 1
    stage.add_child(par_sprite)
    if ground_sprite.position != Vector2.ZERO or par_sprite.position != Vector2.ZERO:
        _stop("Coordinate origin mismatch")
        return

    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var framebuffer: Image = view.get_texture().get_image()
    if framebuffer == null or framebuffer.get_size() != TARGET:
        _stop("Native rendered framebuffer dimensions wrong")
        return
    var png_path := out_dir.path_join("FS_TC_D14_GODOT472_NATIVE_1X_PAIR.png")
    if framebuffer.save_png(png_path) != OK:
        _stop("Godot framebuffer PNG write failed")
        return

    var qa := {
        "scene_id": str(params.get("scene-id", "FS_TC_SYNTHETIC")),
        "native_engine": str(version.get("string", "unknown")),
        "renderer": RenderingServer.get_current_rendering_driver_name(),
        "native_framebuffer": [TARGET.x, TARGET.y],
        "ground_texture": [ground.get_width(), ground.get_height()],
        "par_texture": [par.get_width(), par.get_height()],
        "ground_sha256": FileAccess.get_sha256(ground_path),
        "par_sha256": FileAccess.get_sha256(par_path),
        "render_png_sha256": FileAccess.get_sha256(png_path),
        "exact_world_xy_origin": [0, 0],
        "sprite_texture_filter": "NEAREST",
        "authoring_contract": "GROUND_FIRST_COMPLETE_PAR_ALL_NON_GROUND",
        "source_visual_placement": "HUMAN_VISUAL_QA_REQUIRED",
        "original_native_generation": "REQUIRES_SOURCE_PROVENANCE",
        "all_non_ground_object_coverage": "HUMAN_VISUAL_QA_REQUIRED",
        "actor_occlusion_subset": "NOT_CREATED",
        "art_gate": "HOLD",
        "technical_native_layer_render": "PASS"
    }
    var qa_path := out_dir.path_join("FS_TC_D14_GODOT472_NATIVE_1X_QA.json")
    var file := FileAccess.open(qa_path, FileAccess.WRITE)
    if file == null:
        _stop("Cannot save native QA report")
        return
    file.store_string(JSON.stringify(qa, "\t"))
    file.close()
    print("FS_TC_D14_NATIVE_1X_PASS:", JSON.stringify(qa))
    quit(0)
