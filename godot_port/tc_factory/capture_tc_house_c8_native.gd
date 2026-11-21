extends SceneTree
## FS T-C C8 authentic separate whole right cottage with source-true footprint
## tested in the actual 4.7.2 native scene, not a static PNG/alpha preview.
const SCENE := preload("res://tc_factory/TCVillageIndependentHouseC8.tscn")
const INDEPENDENT_ID := "TC_C8_INDEPENDENT_R5_SINGLE_GABLE_WOOD_COTTAGE"

func _initialize() -> void:
    call_deferred("_run")

func _hit(world: World2D,where: Vector2) -> int:
    var q := PhysicsPointQueryParameters2D.new()
    q.position=where
    q.collision_mask=1
    return world.direct_space_state.intersect_point(q).size()

func _run() -> void:
    var out := ProjectSettings.globalize_path("res://tc_factory/generated_house/")
    DirAccess.make_dir_recursive_absolute(out)
    var v := SubViewport.new()
    v.size=Vector2i(1280,928)
    v.disable_3d=true
    v.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(v)
    var scene := SCENE.instantiate()
    v.add_child(scene)
    await process_frame
    await process_frame
    await process_frame
    await physics_frame
    if scene.floor_image.texture==null or scene.floor_image.texture.get_size()!=Vector2(1280,928):
        push_error("C8 full 1280x928 independent right cottage source invisible")
        quit(1);return
    if scene.house_colliders_loaded!=2 or scene.c7_tree_roots_loaded!=2:
        push_error("C8 must preserve two separate author house footblocks and two C7 tree roots")
        quit(1);return
    if scene.owners_loaded!=17:
        push_error("C8 must replace the old C5 mirror owner, not add duplicate roofs")
        quit(1);return

    var collisions={
        "left_original_complete_house":_hit(v.world_2d,Vector2(500,425)),
        "right_independent_complete_house":_hit(v.world_2d,Vector2(900,562)),
        "C7_broadleaf_root":_hit(v.world_2d,Vector2(678,330)),
        "C7_conifer_root":_hit(v.world_2d,Vector2(816,328)),
        "C7_lamp_not_blocking":_hit(v.world_2d,Vector2(744,320)),
        "original_road_not_blocked":_hit(v.world_2d,Vector2(861,350)),
        "new_cottage_front_not_blocked":_hit(v.world_2d,Vector2(905,611))
    }
    if collisions.values()!=[1,1,1,1,0,0,0]:
        push_error("C8 authentic source 2 houses + C7 root collision wrong: "+JSON.stringify(collisions))
        quit(1);return
    var newroof: Sprite2D=scene.get_node_or_null(INDEPENDENT_ID)
    if newroof==null:
        push_error("C8 real complete right-house original roof owner missing")
        quit(1);return
    # Real A/B same source actor foot. Wrong pixel colors / mask alignment
    # cause a failure, not an automatic green badge.
    scene.set_test_actor_foot(Vector2(905,493))
    await process_frame
    await process_frame
    if not newroof.visible:
        push_error("C8 independent cottage roof must cover actor behind it")
        quit(1);return
    var behind := v.get_texture().get_image()
    if behind.get_size()!=Vector2i(1280,928):
        push_error("C8 real native screenshot not 1x")
        quit(1);return
    if behind.save_png(out.path_join("TC_C8_GODOT472_NATIVE_FULL_1X.png"))!=OK:
        push_error("C8 real native 1x framebuffer save failed")
        quit(1);return
    newroof.visible=false
    await process_frame
    await process_frame
    var uncovered := v.get_texture().get_image()
    if uncovered.save_png(out.path_join("TC_C8_GODOT472_NATIVE_UNCOVERED_1X.png"))!=OK:
        push_error("C8 native actor A/B screenshot failed")
        quit(1);return
    var changed:=0
    for y in range(471,498):
        for x in range(899,912):
            if behind.get_pixel(x,y)!=uncovered.get_pixel(x,y):
                changed+=1
    if changed<15:
        push_error("C8 actual complete original roof did not cover actor ROI: "+str(changed))
        quit(1);return

    scene.set_test_actor_foot(Vector2(905,646))
    await process_frame
    if newroof.visible:
        push_error("C8 actor standing in front remains erroneously hidden")
        quit(1);return
    var result={
        "engine":Engine.get_version_info().get("string","unknown"),
        "renderer":RenderingServer.get_current_rendering_driver_name(),
        "scene":"res://tc_factory/TCVillageIndependentHouseC8.tscn",
        "real_native_framebuffer":[behind.get_width(),behind.get_height()],
        "independent_source_occlusion_owners":scene.owners_loaded,
        "separate_full_house_StaticBody2D":scene.house_colliders_loaded,
        "C7_tree_source_root_bodies":scene.c7_tree_roots_loaded,
        "semantic_collision_hits":collisions,
        "independent_right_roof_actor_native_A_B_roi_pixels":changed,
        "actor_front_uncovered":true,
        "engine_gate":"GODOT472_NATIVE_TWO_INDEPENDENT_HOUSE_SOURCES_PASS",
        "art_gate":"HOLD_LEGACY_FS_STYLE_BASELINE_NOT_FULLY_RECONCILED",
        "historical_R5_failed_layer_semantics":"NOT_IMPORTED",
        "Maze_NAV_and_full_forest_collision":"NOT_TESTED"
    }
    var qa:=FileAccess.open(out.path_join("TC_C8_GODOT_NATIVE_QA.json"),FileAccess.WRITE)
    if qa==null:
        push_error("C8 native result JSON not writable")
        quit(1);return
    qa.store_string(JSON.stringify(result,"\t"))
    qa.close()
    print("FS_TC_C8_NATIVE_QA:",JSON.stringify(result))
    quit(0)
