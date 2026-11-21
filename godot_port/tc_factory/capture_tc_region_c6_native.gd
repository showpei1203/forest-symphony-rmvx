extends SceneTree
## C6 complete 8x8 authored seam in true Godot 4.7.2 1280x928 1x.
## True physics query on new stone and sapling roots, unchanged C5 house tests,
## actor behind-vs-uncovered at the SAME footpoint. No gameplay or NAV rewrite.
const SCENE := preload("res://tc_factory/TCVillageRegionC6.tscn")
const FEATURE_ID := "TC_C6_ANCIENT_WAYSTONE"

func _initialize() -> void:
    call_deferred("_run")

func _hits(world: World2D,pos: Vector2) -> int:
    var q := PhysicsPointQueryParameters2D.new()
    q.position = pos
    q.collision_mask = 1
    return world.direct_space_state.intersect_point(q).size()

func _run() -> void:
    var out := ProjectSettings.globalize_path("res://tc_factory/generated_region/")
    DirAccess.make_dir_recursive_absolute(out)
    var view := SubViewport.new()
    view.size = Vector2i(1280,928)
    view.disable_3d = true
    view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    var scene := SCENE.instantiate()
    view.add_child(scene)
    await process_frame
    await process_frame
    await process_frame
    await physics_frame
    if scene.floor_image.texture == null:
        push_error("C6 full native 1x source texture missing")
        quit(1); return
    if scene.floor_image.texture.get_size() != Vector2(1280,928):
        push_error("C6 source pixels were scaled or clipped")
        quit(1); return
    if scene.house_colliders_loaded!=2 or scene.c6_root_colliders_loaded!=3:
        push_error("C6 must preserve TWO real houses and append THREE new prop roots: "+
            str([scene.house_colliders_loaded,scene.c6_root_colliders_loaded]))
        quit(1); return
    if scene.owners_loaded < 16:
        push_error("C6 independent canopy/stone owners were not imported")
        quit(1); return

    var old_house := _hits(view.world_2d,Vector2(500,425))
    var new_house := _hits(view.world_2d,Vector2(900,562))
    var standing_stone := _hits(view.world_2d,Vector2(745,325))
    var sapling_a := _hits(view.world_2d,Vector2(668,332))
    var sapling_b := _hits(view.world_2d,Vector2(818,329))
    var road := _hits(view.world_2d,Vector2(861,350))
    if [old_house,new_house,standing_stone,sapling_a,sapling_b,road] != [1,1,1,1,1,0]:
        push_error("C6 native original house / new root / open-road QA mismatch: "+
           str([old_house,new_house,standing_stone,sapling_a,sapling_b,road]))
        quit(1); return

    scene.set_test_actor_foot(Vector2(743,313))
    await process_frame
    await process_frame
    var owner: Sprite2D = scene.get_node_or_null(FEATURE_ID)
    if owner == null or not owner.visible:
        push_error("C6 source-derived independent waystone is NOT covering back actor")
        quit(1); return
    var behind := view.get_texture().get_image()
    if behind.get_size() != Vector2i(1280,928):
        push_error("C6 native actual framebuffer is not 1x")
        quit(1); return
    if behind.save_png(out.path_join("TC_C6_GODOT472_NATIVE_FULL_1X.png")) != OK:
        push_error("C6 native full frame could not be saved")
        quit(1); return

    owner.visible = false
    await process_frame
    await process_frame
    var uncovered := view.get_texture().get_image()
    if uncovered.save_png(out.path_join("TC_C6_GODOT472_NATIVE_UNCOVERED_1X.png")) != OK:
        push_error("C6 control GPU screenshot unavailable")
        quit(1); return
    var changed := 0
    for y in range(285,320):
        for x in range(735,753):
            if behind.get_pixel(x,y) != uncovered.get_pixel(x,y):
                changed += 1
    if changed < 20:
        push_error("C6 authored standing-stone scene A/B changed too few actor pixels: "+str(changed))
        quit(1); return
    scene.set_test_actor_foot(Vector2(743,350))
    await process_frame
    if owner.visible:
        push_error("C6 actor standing in front still covered by stone")
        quit(1); return

    var report := {
        "engine":Engine.get_version_info().get("string","unknown"),
        "renderer":RenderingServer.get_current_rendering_driver_name(),
        "scene":"res://tc_factory/TCVillageRegionC6.tscn",
        "full_framebuffer_px":[behind.get_width(),behind.get_height()],
        "region_px":[640,160,896,416],
        "region_32px_tile_origin":[20,5],
        "region_tiles":[8,8],
        "complete_source_occlusion_owners":scene.owners_loaded,
        "C5_houses_real_StaticBody2D":scene.house_colliders_loaded,
        "C6_new_source_authored_root_StaticBody2D":scene.c6_root_colliders_loaded,
        "C5_original_house_hit":old_house,
        "C5_second_house_hit":new_house,
        "C6_waystone_hit":standing_stone,
        "C6_alder_root_hit":sapling_a,
        "C6_rowan_root_hit":sapling_b,
        "open_existing_road_hit":road,
        "native_same_footpoint_actor_waystone_changed_pixels":changed,
        "actor_front_of_waystone_clear":true,
        "gate":"GODOT472_NATIVE_GPU_1X_LAYER_AND_PROP_PHYSICS_PASS",
        "art_gate":"ART_HOLD_NEEDS_HUMAN_REGION_VISUAL_REVIEW",
        "not_full_tree_root_or_NAV_test":true
    }
    var qa := FileAccess.open(out.path_join("TC_C6_GODOT_NATIVE_QA.json"),FileAccess.WRITE)
    if qa == null:
        push_error("C6 native JSON report inaccessible")
        quit(1); return
    qa.store_string(JSON.stringify(report,"\t"))
    qa.close()
    print("FS_TC_C6_NATIVE_QA:",JSON.stringify(report))
    quit(0)
