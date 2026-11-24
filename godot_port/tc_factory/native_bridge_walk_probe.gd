extends SceneTree
## Forest Symphony T-C D21: REAL private art, provisional hand-authored bridge rail physics.
## No extraction from Ground or CompletePAR. No claims of approved world collision.
## 1x native Godot 4.7.2 physics + view. Bridge guard geometry is QA-ONLY.
const WORLD := Vector2i(1280, 928)
const EXPECTED_GROUND := "2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e"
const EXPECTED_PAR := {
    "D18": "8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e",
    "D19": "cee5cafadd2f57f7da577bff1d4d4b9fb950fb9c5b0be3caaad73c5bec5369e1"
}
const BRIDGE_CENTERLINE_Y := 500.0
const BRIDGE_START := Vector2(810, 500)
const BRIDGE_END := Vector2(1108, 500)
const WALL_TOP := Rect2(788, 461, 363, 21)
const WALL_BOTTOM := Rect2(788, 518, 363, 25)
const CHARACTER_RADIUS := 7.0
var stage: Node2D
var viewport: SubViewport
var player: CharacterBody2D
var par_sprite: Sprite2D
var image_ground: Image
var image_par: Image
var qa: Dictionary = {}
var out_dir: String = ""
var version_label: String = ""

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("FS_TC_D21_FAIL: " + reason)
    quit(2)

func _read_args() -> Dictionary:
    var answer: Dictionary = {}
    for raw in OS.get_cmdline_user_args():
        var arg: String = str(raw)
        if arg.begins_with("--") and arg.contains("="):
            var t := arg.substr(2).split("=", false, 1)
            if t.size() == 2:
                answer[t[0]] = t[1]
    return answer

func _wall(parent: Node2D, name_text: String, bounds: Rect2) -> void:
    var node := StaticBody2D.new()
    node.name = name_text
    node.collision_layer = 1
    node.collision_mask = 0
    node.position = bounds.position + bounds.size * 0.5
    parent.add_child(node)
    var shape := CollisionShape2D.new()
    var box_shape := RectangleShape2D.new()
    box_shape.size = bounds.size
    shape.shape = box_shape
    node.add_child(shape)

func _set_player(p: Vector2, z: int) -> void:
    player.position = p
    player.velocity = Vector2.ZERO
    player.z_index = z

func _shot(filename: String) -> String:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image_data := viewport.get_texture().get_image()
    var path := out_dir.path_join(filename)
    if image_data.get_size() != WORLD or image_data.save_png(path) != OK:
        return ""
    return path

func _apply_dynamic_bridge_depth() -> void:
    # Authoring sources remain exactly Ground + one CompletePAR.
    # TEMPORARY runtime draw order ONLY inside the provisional bridge deck lane.
    var p: Vector2 = player.position
    var inside: bool = p.x >= 788.0 and p.x <= 1151.0 and p.y >= 485.0 and p.y <= 517.0
    player.z_index = 3 if inside else 1

func _travel(start: Vector2, dest: Vector2, speed: float, max_frames: int) -> Dictionary:
    _set_player(start, 3)
    _apply_dynamic_bridge_depth()
    await physics_frame
    var target := dest
    var collisions := 0
    var first_wall := ""
    var frames := 0
    while player.position.distance_to(target) > 2.0 and frames < max_frames:
        await physics_frame
        var step: Vector2 = (target - player.position).normalized() * minf(speed, player.position.distance_to(target))
        var hit: KinematicCollision2D = player.move_and_collide(step)
        _apply_dynamic_bridge_depth()
        if hit != null:
            collisions += 1
            if first_wall.is_empty():
                first_wall = hit.get_collider().name
            break
        frames += 1
    return {
        "start": [start.x, start.y], "target": [dest.x, dest.y],
        "end": [player.position.x, player.position.y],
        "frames": frames, "first_collider": first_wall,
        "collisions": collisions, "distance_to_target": player.position.distance_to(target),
        "reached": player.position.distance_to(target) < 2.01
    }

func _run() -> void:
    var a := _read_args()
    var g_path: String = str(a.get("ground", ""))
    var p_path: String = str(a.get("par", ""))
    out_dir = str(a.get("out", ""))
    version_label = str(a.get("variant", ""))
    if not EXPECTED_PAR.has(version_label) or g_path.is_empty() or p_path.is_empty() or out_dir.is_empty():
        _fail("Explicit correct --variant=D18|D19, --ground, --par and --out required")
        return
    if Engine.get_version_info().get("string", "").begins_with("4.7.2") == false:
        _fail("Require official Godot 4.7.2, not a substitute")
        return
    if g_path == p_path or FileAccess.get_sha256(g_path) != EXPECTED_GROUND:
        _fail("Wrong or altered locked D17 Ground")
        return
    if FileAccess.get_sha256(p_path) != EXPECTED_PAR[version_label]:
        _fail("Wrong or altered independently authored " + version_label + " PAR")
        return
    image_ground = Image.load_from_file(g_path)
    image_par = Image.load_from_file(p_path)
    if image_ground.is_empty() or image_par.is_empty() or image_ground.get_size() != WORLD or image_par.get_size() != WORLD:
        _fail("Both image sizes must be 1280x928")
        return
    if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
        _fail("Cannot write isolated QA output")
        return
    viewport = SubViewport.new()
    viewport.name = "D21_NATIVE_PRIVATE_PHYSICS_VIEW"
    viewport.size = WORLD
    viewport.transparent_bg = false
    viewport.disable_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    stage = Node2D.new()
    viewport.add_child(stage)
    var g := Sprite2D.new()
    g.name = "D17_FROZEN_GROUND"
    g.texture = ImageTexture.create_from_image(image_ground)
    g.centered = false
    g.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    g.z_index = 0
    stage.add_child(g)
    par_sprite = Sprite2D.new()
    par_sprite.name = "D18_OR_D19_INDEPENDENT_COMPLETE_PAR"
    par_sprite.texture = ImageTexture.create_from_image(image_par)
    par_sprite.centered = false
    par_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    par_sprite.z_index = 2
    stage.add_child(par_sprite)
    # A provisional, scoped physics corridor drawn by hand after inspecting the
    # actual bridge deck, not derived from alpha or approved as full collision map.
    _wall(stage, "QA_UPPER_BRIDGE_RAIL", WALL_TOP)
    _wall(stage, "QA_LOWER_BRIDGE_RAIL", WALL_BOTTOM)
    player = CharacterBody2D.new()
    player.name = "D21_TEST_ACTOR_NOT_CANONICAL_CHARACTER"
    player.collision_layer = 2
    player.collision_mask = 1
    stage.add_child(player)
    var circle := CircleShape2D.new()
    circle.radius = CHARACTER_RADIUS
    var shape := CollisionShape2D.new()
    shape.shape = circle
    player.add_child(shape)
    # Small surrogate marker only. Real ACTOR01 is NOT imported or validated.
    var actor_marker := Polygon2D.new()
    actor_marker.color = Color("#17e5fc")
    actor_marker.polygon = PackedVector2Array([
        Vector2(-6,-10),Vector2(6,-10),Vector2(9,-2),
        Vector2(6,5),Vector2(-6,5),Vector2(-9,-2)
    ])
    player.add_child(actor_marker)
    var anchor := Polygon2D.new()
    anchor.color = Color("#19171d")
    anchor.polygon = PackedVector2Array([Vector2(-2,0),Vector2(2,0),Vector2(2,4),Vector2(-2,4)])
    player.add_child(anchor)
    qa = {
        "scene":"FS_04_MAZE", "variant":version_label,
        "native_version":Engine.get_version_info().get("string",""),
        "source_ground_sha256":FileAccess.get_sha256(g_path),
        "source_par_sha256":FileAccess.get_sha256(p_path),
        "canvas":[WORLD.x,WORLD.y], "world_origin":[0,0],
        "nearest_sampling":true,
        "bridge_qa_corridor":{"top": [WALL_TOP.position.x,WALL_TOP.position.y,WALL_TOP.size.x,WALL_TOP.size.y],"bottom":[WALL_BOTTOM.position.x,WALL_BOTTOM.position.y,WALL_BOTTOM.size.x,WALL_BOTTOM.size.y],"source":"MANUALLY_PROVISIONAL_VISUAL_ONLY_NOT_CANONICAL_COLLISION"},
        "actor_type":"TEMPORARY_CHARACTERBODY2D_SURROGATE",
        "qa_status":"PROVISIONAL_PHYSICS_SMOKE_NOT_AUTHORED_WORLD_COLLISION",
        "gameplay_integration":"NOT_RUN", "user_ART":"HOLD", "formal_art_sealed":0
    }
    _set_player(Vector2(979,500), 3)
    player.visible = false
    var base_path: String = await _shot("BASE_NO_ACTOR.png")
    if base_path.is_empty():
        _fail("Failed baseline framebuffer")
        return
    player.visible = true
    _set_player(Vector2(979,500), 1)
    var hidden_path: String = await _shot("ACTOR_UNDER_ALL_PAR.png")
    _set_player(Vector2(979,500), 3)
    var raised_path: String = await _shot("ACTOR_ABOVE_PAR_ON_BRIDGE.png")
    if hidden_path.is_empty() or raised_path.is_empty():
        _fail("Occlusion screenshot failure")
        return
    qa["occlusion_evidence"] = {
        "normal_actor_z":1, "complete_par_z":2,"bridge_actor_z":3,
        "provisional_bridge_raise_required":true,
        "baseline_png_sha256":FileAccess.get_sha256(base_path),
        "under_png_sha256":FileAccess.get_sha256(hidden_path),
        "above_png_sha256":FileAccess.get_sha256(raised_path)
    }
    qa["cross_bridge"] = await _travel(BRIDGE_START,BRIDGE_END,4.0,130)
    var east_path: String = await _shot("ACTOR_REACHED_EAST_1X.png")
    qa["reverse_cross_bridge"] = await _travel(BRIDGE_END, BRIDGE_START, 4.0, 130)
    var west_path: String = await _shot("ACTOR_RETURNED_WEST_1X.png")
    qa["north_rail_block"] = await _travel(Vector2(986,500),Vector2(986,440),3.0,65)
    var north_path: String = await _shot("ACTOR_BLOCKED_NORTH_RAIL_1X.png")
    qa["south_rail_block"] = await _travel(Vector2(986,500),Vector2(986,590),3.0,65)
    var south_path: String = await _shot("ACTOR_BLOCKED_SOUTH_RAIL_1X.png")
    qa["visual_screenshots"] = [east_path.get_file(), west_path.get_file(), north_path.get_file(),south_path.get_file()]
    qa["bridge_pass"] = qa["cross_bridge"]["reached"] and qa["cross_bridge"]["collisions"] == 0 \
        and qa["reverse_cross_bridge"]["reached"] and qa["reverse_cross_bridge"]["collisions"] == 0
    qa["guards_pass"] = qa["north_rail_block"]["collisions"] > 0 and qa["south_rail_block"]["collisions"] > 0
    qa["physics_smoke_pass"] = qa["bridge_pass"] and qa["guards_pass"]
    var report_path: String = out_dir.path_join("D21_NATIVE_BRIDGE_QA.json")
    var f := FileAccess.open(report_path,FileAccess.WRITE)
    if f == null:
        _fail("Cannot open report")
        return
    f.store_string(JSON.stringify(qa,"\t"))
    f.close()
    print("FS_TC_D21_NATIVE_BRIDGE_QA_",version_label,"_", "PASS" if qa["physics_smoke_pass"] else "FAIL")
    print(JSON.stringify(qa))
    quit(0 if qa["physics_smoke_pass"] else 2)
