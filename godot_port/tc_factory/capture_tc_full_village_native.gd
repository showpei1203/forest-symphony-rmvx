extends SceneTree
## C3 full-resolution real framebuffer, not an enlarged mockup.
const SCENE := preload("res://tc_factory/TCVillageFullCandidate.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var out := ProjectSettings.globalize_path("res://tc_factory/generated_full/")
    DirAccess.make_dir_recursive_absolute(out)
    var v := SubViewport.new()
    v.size = Vector2i(1280,928)
    v.disable_3d = true
    v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(v)
    var scene := SCENE.instantiate()
    v.add_child(scene)
    await process_frame
    await process_frame
    await process_frame
    if scene.owners_loaded < 7 or scene.floor_image.texture == null:
        push_error("T-C Full 1280x928 source or semantic owner assets unavailable.")
        quit(1)
        return
    if scene.floor_image.texture.get_width() != 1280 or scene.floor_image.texture.get_height() != 928:
        push_error("T-C Full image is not true native 1280x928.")
        quit(1)
        return
    # The original A36G integrated cottage has foot at (563,458).
    scene.set_test_actor_foot(Vector2(550,355))
    await process_frame
    await process_frame
    var img := v.get_texture().get_image()
    if img.get_width() != 1280 or img.get_height() != 928:
        push_error("T-C Full real Godot framebuffer wrong resolution.")
        quit(1)
        return
    var image_path := out.path_join("TC_FULL_VILLAGE_GODOT472_NATIVE_1X.png")
    if img.save_png(image_path) != OK:
        push_error("T-C Full native screenshot save failed.")
        quit(1)
        return
    var report := {
        "engine": Engine.get_version_info().get("string","unknown"),
        "scene": "res://tc_factory/TCVillageFullCandidate.tscn",
        "source_image":[scene.floor_image.texture.get_width(),scene.floor_image.texture.get_height()],
        "real_framebuffer":[img.get_width(),img.get_height()],
        "owners_loaded":scene.owners_loaded,
        "actor_behind_house_visible_owners":scene.visible_occlusion_owners(),
        "gate":"FULL_SCENE_GPU_1X_PASS_NOT_ART_PASS",
        "art_gate":"ART_HOLD",
        "collision_gate":"NOT_PRODUCTION_CERTIFIED"
    }
    var output := FileAccess.open(out.path_join("TC_FULL_VILLAGE_NATIVE_QA.json"), FileAccess.WRITE)
    if output == null:
        push_error("T-C Full QA write failed.")
        quit(1)
        return
    output.store_string(JSON.stringify(report,"\t"))
    output.close()
    print("FS_TC_FULL_NATIVE_QA: ",JSON.stringify(report))
    quit(0)
