extends Node2D

var m: Dictionary = {}
var player: CharacterBody2D
var camera: Camera2D
var placed: Array[Dictionary] = []
var ev_nodes: Dictionary = {}
var smoke: bool = false
var screenshot: String = "res://captures/RICH_GODOT_V2_NATIVE.png"

func _make_sprite(texture_path: String, pos: Vector2, order: int) -> Sprite2D:
    var s := Sprite2D.new()
    s.texture = load(texture_path)
    assert(s.texture != null, "Texture not found: " + texture_path)
    s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    s.centered = false
    s.position = pos
    s.z_index = order
    add_child(s)
    return s

func _ready() -> void:
    var data = JSON.parse_string(FileAccess.get_file_as_string("res://scene_manifest.json"))
    assert(data != null and data is Dictionary)
    m = data
    smoke = "--smoke" in OS.get_cmdline_user_args()
    _make_sprite("res://FS_ELF_RICH_Ground.png",Vector2.ZERO,-1000)
    for ob in m["instances"]:
        var xy := Vector2(float(ob["x"]),float(ob["y"]))
        var spr := _make_sprite("res://sprites/"+str(ob["asset_id"])+".png",xy,int(ob["draw_order"]))
        placed.append({"id":str(ob["id"]),"sprite":spr,"y":int(ob["draw_order"]),"role":str(ob["role"])})
        for rect in ob["collision_local"]:
            var shape := RectangleShape2D.new()
            shape.size = Vector2(float(rect[2]-rect[0]),float(rect[3]-rect[1]))
            var body := StaticBody2D.new()
            body.name = str(ob["id"]) + "_body"
            var col := CollisionShape2D.new()
            col.shape = shape
            col.position = xy + Vector2(float(rect[0]+rect[2])/2.0,float(rect[1]+rect[3])/2.0)
            body.add_child(col)
            add_child(body)
    player = CharacterBody2D.new()
    player.name = "IndependentTestActor"
    player.position = Vector2(float(m["spawn"]["x"]),float(m["spawn"]["y"]))
    var circle := CircleShape2D.new()
    circle.radius = 8.0
    var collision := CollisionShape2D.new()
    collision.shape = circle
    player.add_child(collision)
    add_child(player)
    var actor = Sprite2D.new()
    actor.texture = load("res://actor.png")
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.position = Vector2(-10,-28)
    actor.centered = false
    player.add_child(actor)
    camera = Camera2D.new()
    camera.position_smoothing_enabled = false
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = 864
    camera.limit_bottom = 640
    player.add_child(camera)
    camera.make_current()
    for e in m["interactions"]:
        ev_nodes[str(e["id"])]=Vector2(float(e["x"]),float(e["y"]))
    _update_depth()
    if smoke:
        await get_tree().physics_frame
        await get_tree().physics_frame
        await _run_smoke()
func _physics_process(delta: float) -> void:
    if smoke or player == null:
        return
    player.velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 95.0
    player.move_and_slide()
    _update_depth()
    if Input.is_action_just_pressed("ui_accept"):
        var found := _nearby_event()
        if found != "":
            print("RICH_INTERACT ", found)

func _update_depth() -> void:
    if player != null:
        player.z_index = int(player.position.y)

func _nearby_event() -> String:
    for event_id in ev_nodes:
        var pt: Vector2 = ev_nodes[event_id]
        if player.position.distance_to(pt) <= 48.0:
            return str(event_id)
    return ""

func _test_interaction(event_id: String) -> bool:
    var pt: Vector2 = ev_nodes[event_id]
    player.position = pt + Vector2(0,20)
    return _nearby_event()==event_id

func _run_smoke() -> void:
    var instance_count_ok := placed.size()==48
    var images := load("res://FS_ELF_RICH_Ground.png")
    var dimension_ok: bool = images.get_size()==Vector2(864,640)
    var all_interactions_ok := ev_nodes.size()==5
    var missing: Array[String] = []
    for event_id in ev_nodes:
        if not _test_interaction(str(event_id)):
            all_interactions_ok = false
            missing.append(str(event_id))
    var behind := false
    var front := false
    for o in m["instances"]:
        if str(o["id"])=="grove_tree_ne":
            player.position=Vector2(float(o["x"])+20,float(o["y"])+15)
            _update_depth()
            behind = player.z_index < int(o["draw_order"])
            player.position=Vector2(float(o["x"])+20,float(o["y"])+float(o["dimensions"][1])+20)
            _update_depth()
            front = player.z_index > int(o["draw_order"])
            break
    var building_collision := false
    for o in m["instances"]:
        if str(o["id"])=="house_wood_west":
            player.position=Vector2(float(o["x"])+50,float(o["y"])+float(o["dimensions"][1])+24)
            building_collision=player.move_and_collide(Vector2(0,-55))!=null
            break
    player.position=Vector2(float(m["spawn"]["x"]),float(m["spawn"]["y"]))
    var spawn_route_move := player.move_and_collide(Vector2(0,-12))==null
    _update_depth()
    var logic_ok: bool = instance_count_ok and dimension_ok and all_interactions_ok and behind and front and building_collision and spawn_route_move
    print("GODOT_RICH_GATE_LOGIC instances=",instance_count_ok," dimensions=",dimension_ok," interactions=",all_interactions_ok,
      " back=",behind," front=",front," building_collision=",building_collision," movement=",spawn_route_move," missing=",missing)
    print("GODOT_RICH_GATE_F_LOGIC_PASS" if logic_ok else "GODOT_RICH_GATE_F_LOGIC_FAIL")
    if not logic_ok:
        get_tree().quit(2)
        return
    for i in range(12):
        await get_tree().process_frame
    await RenderingServer.frame_post_draw
    var image = get_viewport().get_texture().get_image()
    var code := image.save_png(screenshot)
    print("GODOT_RICH_GPU_FRAME_RESULT ",code," dim=",image.get_size())
    get_tree().quit(0 if code==OK else 3)
