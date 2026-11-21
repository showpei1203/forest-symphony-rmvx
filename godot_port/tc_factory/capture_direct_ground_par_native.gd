extends SceneTree
## Godot 4.7.2 native FULL frame of two independently-authored layers.
## Ground and complete PAR are both real textures, *not* one composite PNG.
const SCENE := preload("res://tc_factory/DirectGroundParPair.tscn")
const W := 1280
const H := 928

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var out := ProjectSettings.globalize_path("res://tc_factory/generated_direct/")
    DirAccess.make_dir_recursive_absolute(out)
    var vp := SubViewport.new()
    vp.size = Vector2i(W,H)
    vp.disable_3d = true
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var test_scene := SCENE.instantiate()
    vp.add_child(test_scene)
    await process_frame
    await process_frame
    if test_scene.floor_sprite.texture==null or test_scene.par_sprite.texture==null:
        push_error("D1 missing direct GROUND/PAR native textures")
        quit(1)
        return
    if test_scene.floor_sprite.texture.get_size()!=Vector2(W,H):
        push_error("D1 Ground texture not native 1280x928")
        quit(1)
        return
    if test_scene.par_sprite.texture.get_size()!=Vector2(W,H):
        push_error("D1 PAR texture not same original 1280x928 world coordinates")
        quit(1)
        return
    if test_scene.par_sprite.position!=Vector2.ZERO or test_scene.floor_sprite.position!=Vector2.ZERO:
        push_error("D1 independent layer world XY registration broken")
        quit(1)
        return
    var image := vp.get_texture().get_image()
    if image.get_size()!=Vector2i(W,H):
        push_error("D1 actual GPU framebuffer size mismatch")
        quit(1)
        return
    var save_path := out.path_join("D1_GODOT472_NATIVE_GROUND_PLUS_FULL_PAR_1X.png")
    if image.save_png(save_path)!=OK:
        push_error("D1 native real GPU screenshot could not be written")
        quit(1)
        return

    # Unlike old T-C code, never create an occluder list or subset.
    var qa := {
        "stage":"D1_DIRECT_GROUND_THEN_PAR_ALL_NON_GROUND",
        "engine":Engine.get_version_info().get("string","unknown"),
        "renderer":RenderingServer.get_current_rendering_driver_name(),
        "real_framebuffer":[W,H],
        "scene":"res://tc_factory/DirectGroundParPair.tscn",
        "ground_texture":"res://tc_factory/generated_direct/GROUND.png",
        "par_texture":"res://tc_factory/generated_direct/PAR.png",
        "ground_par_origin":[0,0],
        "par_contains_every_non_ground_according_to_compiler":true,
        "actor_occlusion_subset":"NOT_CREATED_NOT_SELECTED",
        "collision_and_passability":"NOT_PART_OF_THIS_TWO_LAYER_DELIVERY",
        "no_actor_preview":true,
        "gate":"GODOT472_NATIVE_1X_DIRECT_PAIR_RENDER_PASS",
        "art_gate":"HOLD_ARCHIVAL_SOURCE_BENCHMARK_NOT_NEW_AI_GENERATION"
    }
    var fd := FileAccess.open(out.path_join("D1_GODOT_NATIVE_QA.json"),FileAccess.WRITE)
    if fd==null:
        push_error("D1 native QA JSON inaccessible")
        quit(1)
        return
    fd.store_string(JSON.stringify(qa,"\t"))
    fd.close()
    print("FS_TC_D1_NATIVE_QA:",JSON.stringify(qa))
    quit(0)
