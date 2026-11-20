extends SceneTree
## Full 1280x928 style comparison with 2 REAL source-derived house bodies.
## Correct technical rendering/collision does not mean art acceptance.
const SCENE := preload("res://tc_factory/TCVillageStyleC5.tscn")
const SECOND_HOUSE := "TC_C5_WHOLE_TIMBER_COTTAGE_MIRRORED_VARIANT"

func _initialize() -> void:
    call_deferred("_run")

func _hit(world: World2D, pos: Vector2) -> int:
    var q := PhysicsPointQueryParameters2D.new()
    q.position = pos
    q.collision_mask = 1
    return world.direct_space_state.intersect_point(q).size()

func _run() -> void:
    var out := ProjectSettings.globalize_path("res://tc_factory/generated_style/")
    DirAccess.make_dir_recursive_absolute(out)
    var viewport := SubViewport.new()
    viewport.size = Vector2i(1280,928)
    viewport.disable_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var scene := SCENE.instantiate()
    viewport.add_child(scene)
    await process_frame
    await process_frame
    await process_frame
    await physics_frame

    if scene.floor_image.texture == null or scene.owners_loaded < 10:
        push_error("C5 full style source or independent occlusion owners missing.")
        quit(1)
        return
    if scene.house_colliders_loaded != 2:
        push_error("C5 needs BOTH complete house facade colliders from source contracts.")
        quit(1)
        return
    var h0 := _hit(viewport.world_2d,Vector2(500,425))
    var h1 := _hit(viewport.world_2d,Vector2(900,562))
    var open := _hit(viewport.world_2d,Vector2(1080,710))
    if h0 != 1 or h1 != 1 or open != 0:
        push_error("C5 physical block/open semantic native test failed: " + str([h0,h1,open]))
        quit(1)
        return

    # Actor behind its own new roof only if its foot is above the house anchor.
    scene.set_test_actor_foot(Vector2(890,505))
    await process_frame
    await process_frame
    var second: Sprite2D = scene.get_node_or_null(SECOND_HOUSE)
    if second == null or not second.visible:
        push_error("C5 new single-source roof did not occlude the actor.")
        quit(1)
        return
    var image := viewport.get_texture().get_image()
    if image.get_size() != Vector2i(1280,928):
        push_error("C5 1x framebuffer dimensions mismatch")
        quit(1)
        return
    var path := out.path_join("TC_C5_VILLAGE_GODOT472_NATIVE_BEHIND_1X.png")
    if image.save_png(path) != OK:
        push_error("C5 Godot native screenshot write failed")
        quit(1)
        return

    # Same-footpoint, no occlusion frame proves the overlay actually does work.
    second.visible = false
    await process_frame
    await process_frame
    var no_occlusion := viewport.get_texture().get_image()
    if no_occlusion.save_png(out.path_join("TC_C5_VILLAGE_GODOT472_NATIVE_UNCOVERED_1X.png")) != OK:
        push_error("C5 native control image write failed")
        quit(1)
        return
    var changed := 0
    for y in range(485,519):
        for x in range(876,904):
            if image.get_pixel(x,y) != no_occlusion.get_pixel(x,y):
                changed += 1
    if changed < 1:
        push_error("C5 source-derived roof actor ROI is identical to uncovered control")
        quit(1)
        return

    scene.set_test_actor_foot(Vector2(890,645))
    await process_frame
    if second.visible:
        push_error("C5 second house roof should not cover actor standing in front")
        quit(1)
        return
    var report := {
        "engine":Engine.get_version_info().get("string","unknown"),
        "renderer":RenderingServer.get_current_rendering_driver_name(),
        "scene":"res://tc_factory/TCVillageStyleC5.tscn",
        "real_framebuffer":[image.get_width(),image.get_height()],
        "source_floor":[scene.floor_image.texture.get_width(),scene.floor_image.texture.get_height()],
        "occlusion_owners":scene.owners_loaded,
        "independent_house_static_bodies":scene.house_colliders_loaded,
        "original_cottage_hit":h0,
        "new_harmonized_house_hit":h1,
        "road_open_hit":open,
        "roof_behind_actor_roi_changed_pixels":changed,
        "front_footpoint_clear":true,
        "native_art_capture":"PASS_1X",
        "full_art_approval":"HOLD_NOT_AUTOMATED"
    }
    var report_file := FileAccess.open(out.path_join("TC_C5_GODOT_NATIVE_QA.json"),FileAccess.WRITE)
    if report_file == null:
        push_error("C5 JSON QA write unavailable")
        quit(1)
        return
    report_file.store_string(JSON.stringify(report,"\t"))
    report_file.close()
    print("FS_TC_C5_NATIVE_QA:",JSON.stringify(report))
    quit(0)
