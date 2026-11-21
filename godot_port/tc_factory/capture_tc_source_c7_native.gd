extends SceneTree
## C7 final verification: exact Godot 4.7.2 1280x928 GPU image, original
## A36G R4 complete independent trees, lamp alpha front/back, actual physics.
const SCENE := preload("res://tc_factory/TCVillageSourceC7.tscn")
const WAYMARKER := "TC_C7_SOURCE_WAYMARKER"

func _initialize() -> void:
    call_deferred("_run")

func _hits(world: World2D,position: Vector2) -> int:
    var q := PhysicsPointQueryParameters2D.new()
    q.position=position
    q.collision_mask=1
    return world.direct_space_state.intersect_point(q).size()

func _run() -> void:
    var out := ProjectSettings.globalize_path("res://tc_factory/generated_source/")
    DirAccess.make_dir_recursive_absolute(out)
    var vp := SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var scene := SCENE.instantiate()
    vp.add_child(scene)
    await process_frame
    await process_frame
    await process_frame
    await physics_frame
    if scene.floor_image.texture==null:
        push_error("C7 native runtime full master source failed")
        quit(1);return
    if scene.floor_image.texture.get_size()!=Vector2(1280,928):
        push_error("C7 native source image must be exactly 1280x928")
        quit(1);return
    if scene.house_colliders_loaded!=2 or scene.c7_tree_roots_loaded!=2:
        push_error("C7 manifest expects 2 original house physics + 2 sourced blocking tree roots")
        quit(1);return
    if scene.owners_loaded!=17:
        push_error("C7 old 14 genuine owners plus 3 new original source owners expected")
        quit(1);return
    var hits={
        "C5_house_original":_hits(vp.world_2d,Vector2(500,425)),
        "C5_house_two":_hits(vp.world_2d,Vector2(900,562)),
        "C7_broadleaf_source_root":_hits(vp.world_2d,Vector2(678,330)),
        "C7_conifer_source_root":_hits(vp.world_2d,Vector2(816,328)),
        "C7_lamp_nonblocking":_hits(vp.world_2d,Vector2(744,320)),
        "C7_rock_nonblocking":_hits(vp.world_2d,Vector2(683,361)),
        "C6_existing_road_open":_hits(vp.world_2d,Vector2(861,350))
    }
    if hits.values()!=[1,1,1,1,0,0,0]:
        push_error("C7 native source blocking semantics mismatch: "+JSON.stringify(hits))
        quit(1);return

    scene.set_test_actor_foot(Vector2(744,285))
    await process_frame
    await process_frame
    var marker: Sprite2D=scene.get_node_or_null(WAYMARKER)
    if marker==null or not marker.visible:
        push_error("C7 original sourced waymarker must cover actor behind it")
        quit(1);return
    var behind := vp.get_texture().get_image()
    if behind.get_size()!=Vector2i(1280,928):
        push_error("C7 1x native framebuffer missing")
        quit(1);return
    if behind.save_png(out.path_join("TC_C7_GODOT472_NATIVE_FULL_1X.png"))!=OK:
        push_error("C7 native full real GPU screenshot save failed")
        quit(1);return
    marker.visible=false
    await process_frame
    await process_frame
    var uncovered := vp.get_texture().get_image()
    if uncovered.save_png(out.path_join("TC_C7_GODOT472_NATIVE_UNCOVERED_1X.png"))!=OK:
        push_error("C7 native actor-uncovered control save failed")
        quit(1);return
    var changed := 0
    for y in range(261,291):
        for x in range(735,753):
            if behind.get_pixel(x,y)!=uncovered.get_pixel(x,y):
                changed += 1
    if changed < 10:
        push_error("C7 source Alpha produced <10 real actor ROI occlusion differences: "+str(changed))
        quit(1);return

    scene.set_test_actor_foot(Vector2(744,345))
    await process_frame
    if marker.visible:
        push_error("C7 original waymarker should NOT cover actor in front")
        quit(1);return

    var report={
        "engine":Engine.get_version_info().get("string","unknown"),
        "renderer":RenderingServer.get_current_rendering_driver_name(),
        "scene":"res://tc_factory/TCVillageSourceC7.tscn",
        "actual_framebuffer":[behind.get_width(),behind.get_height()],
        "source_region_px":[640,160,896,416],
        "source_region_tiles":[8,8],
        "semantic_independent_owners":scene.owners_loaded,
        "existing_C5_house_physics":scene.house_colliders_loaded,
        "new_original_source_tree_root_physics":scene.c7_tree_roots_loaded,
        "point_query_hits":hits,
        "original_lamp_occlusion_changed_actor_roi_px":changed,
        "front_actor_visible":true,
        "gate":"SOURCE_FS_GODOT472_NATIVE_GPU_1X_OCCLUSION_PHYSICS_PASS",
        "art_gate":"ART_HOLD_PENDING_WHOLE_REGION_VISUAL_INSPECTION",
        "MAZE_and_full_Nav_collision":"NOT_TESTED"
    }
    var qa:=FileAccess.open(out.path_join("TC_C7_NATIVE_QA.json"),FileAccess.WRITE)
    if qa==null:
        push_error("C7 original source native report inaccessible")
        quit(1);return
    qa.store_string(JSON.stringify(report,"\t"))
    qa.close()
    print("FS_TC_C7_NATIVE_QA:",JSON.stringify(report))
    quit(0)
