extends SceneTree
## Isolated Godot 4.7.2 scene import + 1x real engine framebuffer evidence.
const SOURCE_SCENE := preload("res://tc_factory/TCVillagePilot.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var output := OS.get_environment("FS_TC_OUTPUT_DIR")
    if output.is_empty():
        output = ProjectSettings.globalize_path("res://tc_factory/generated/")
    DirAccess.make_dir_recursive_absolute(output)
    var viewport := SubViewport.new()
    viewport.size = Vector2i(544,416)
    viewport.disable_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var sample := SOURCE_SCENE.instantiate()
    viewport.add_child(sample)
    await process_frame
    await process_frame
    await process_frame
    await physics_frame
    if sample.house_colliders_loaded != 1:
        push_error("T-C actual source house StaticBody2D missing.")
        quit(1)
        return
    var blocked_q := PhysicsPointQueryParameters2D.new()
    blocked_q.position = Vector2(305,300)
    blocked_q.collision_mask = 1
    var road_q := PhysicsPointQueryParameters2D.new()
    road_q.position = Vector2(65,378)
    road_q.collision_mask = 1
    var blocked_count := viewport.world_2d.direct_space_state.intersect_point(blocked_q).size()
    var free_count := viewport.world_2d.direct_space_state.intersect_point(road_q).size()
    if blocked_count < 1 or free_count > 0:
        push_error("T-C native source cottage facade/root collision gate FAIL.")
        quit(1)
        return
    if sample.owners_loaded < 7 or sample.floor_image.texture == null:
        push_error("T-C native source/owner gate failed.")
        quit(1)
        return
    sample.set_test_actor_foot(Vector2(305,280))
    await process_frame
    await process_frame
    var behind_count: int = sample.visible_occlusion_owners()
    if behind_count < 1:
        push_error("T-C actor cannot enter any roof/canopy occlusion.")
        quit(1)
        return
    var behind := viewport.get_texture().get_image()
    if behind.get_width() != 544 or behind.get_height() != 416:
        push_error("T-C native preview was not 544x416.")
        quit(1)
        return
    var rc := behind.save_png(output.path_join("TC_NATIVE_BEHIND_1X.png"))
    if rc != OK:
        push_error("T-C failed to save behind preview.")
        quit(1)
        return
    # First verify foot-rule transition, then compare same actor pixel coordinates.
    sample.set_test_actor_foot(Vector2(305,390))
    await process_frame
    await process_frame
    var front_count: int = sample.visible_occlusion_owners()
    if front_count > behind_count:
        push_error("T-C footpoint front visibility regression.")
        quit(1)
        return
    sample.set_test_actor_foot(Vector2(305,280))
    for layer in sample.overlays:
        (layer["node"] as Sprite2D).visible = false
    await process_frame
    await process_frame
    var front := viewport.get_texture().get_image()
    rc = front.save_png(output.path_join("TC_NATIVE_FRONT_1X.png"))
    if rc != OK:
        push_error("T-C failed to save unoccluded same-pose preview.")
        quit(1)
        return
    var png_pixels_change := false
    for y in range(260,322,3):
        for x in range(287,323,3):
            if behind.get_pixel(x,y) != front.get_pixel(x,y):
                png_pixels_change = true
                break
        if png_pixels_change:
            break
    if not png_pixels_change:
        push_error("T-C native behind/front screenshots unexpectedly identical in actor ROI.")
        quit(1)
        return
    var report := {
        "engine": Engine.get_version_info().get("string", "unknown"),
        "scene":"res://tc_factory/TCVillagePilot.tscn",
        "native_scene_loaded":true,
        "framebuffer_px":[behind.get_width(),behind.get_height()],
        "owners_loaded":sample.owners_loaded,
        "behind_visible":behind_count,
        "front_visible":front_count,
        "actor_roi_changed":png_pixels_change,
        "native_qa":"TECH_GATE_PASS_NOT_ART_PASS",
        "house_collision_hits":blocked_count,"open_road_collision_hits":free_count,
        "house_native_physics":"PASS_ORIGINAL_MANIFEST_ONLY",
        "art_gate":"HOLD",
        "rendering_backend":RenderingServer.get_current_rendering_driver_name()
    }
    var path := output.path_join("TC_GODOT_NATIVE_QA.json")
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("T-C could not save native QA.")
        quit(1)
        return
    file.store_string(JSON.stringify(report, "\t"))
    file.close()
    print("FS_TC_GODOT_NATIVE_QA: ",JSON.stringify(report))
    quit(0)
