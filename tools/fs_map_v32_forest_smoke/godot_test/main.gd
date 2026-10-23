extends Node2D

var manifest: Dictionary = {}
var player: CharacterBody2D
var occluders: Array[Dictionary] = []
var smoke: bool = false

func _add_sprite(texture_path: String, layer: int, pos: Vector2 = Vector2.ZERO) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.texture = load(texture_path)
    assert(sprite.texture != null)
    sprite.centered = false
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.z_index = layer
    sprite.position = pos
    add_child(sprite)
    return sprite

func _ready() -> void:
    var text_file := FileAccess.get_file_as_string("res://scene_manifest.json")
    manifest = JSON.parse_string(text_file)
    assert(manifest != null)
    _add_sprite("res://FS_FOREST_V32_Ground.png", 0)
    _add_sprite("res://FS_FOREST_V32_Par_BASE.png", 1)
    for entry in manifest["instances"]:
        var spec: Dictionary = manifest["asset_specs"][entry["asset_id"]]
        var x: float = float(entry["x"])
        var y: float = float(entry["y"])
        var box: Array = spec["collision_local"]
        var body := StaticBody2D.new()
        body.name = entry["instance_id"]
        var shape := RectangleShape2D.new()
        shape.size = Vector2(float(box[2]-box[0]),float(box[3]-box[1]))
        var collision := CollisionShape2D.new()
        collision.shape = shape
        collision.position = Vector2(x + float(box[0]+box[2])/2.0,y+float(box[1]+box[3])/2.0)
        add_child(body)
        body.add_child(collision)
        if int(spec["canopy_y_lt"]) > 0:
            var texture_path: String = "res://semantic_masks/"+entry["instance_id"]+"_occlusion_rgba.png"
            var overlay := _add_sprite(texture_path,20,Vector2(x,y))
            occluders.append({"instance":entry["instance_id"],"sprite":overlay,"foot":y+float(box[3])})
    player = CharacterBody2D.new()
    player.name = "PlayerCollisionActor"
    player.position = Vector2(float(manifest["spawn"]["x"]),float(manifest["spawn"]["y"]))
    var char_shape := CircleShape2D.new()
    char_shape.radius = 9.0
    var char_collision := CollisionShape2D.new()
    char_collision.shape = char_shape
    player.add_child(char_collision)
    add_child(player)
    var actor := Sprite2D.new()
    actor.texture = load("res://TEST_ONLY_ACTOR.png")
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.centered = false
    actor.position = Vector2(-10,-28)
    actor.z_index = 10
    # Children inherit z relative to parent. Keep draw order deterministic.
    player.z_index = 10
    actor.z_index = 0
    player.add_child(actor)
    _update_occlusion()
    smoke = DisplayServer.get_name() == "headless"
    if smoke:
        await get_tree().physics_frame
        await get_tree().physics_frame
        _run_smoke()

func _physics_process(delta: float) -> void:
    if smoke or player == null:
        return
    var axis := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    player.velocity = axis * 100.0
    player.move_and_slide()
    _update_occlusion()

func _update_occlusion() -> void:
    if player == null:
        return
    for item in occluders:
        var sprite: Sprite2D = item["sprite"]
        sprite.z_index = 20 if player.position.y <= float(item["foot"]) else 1

func _run_smoke() -> void:
    assert(occluders.size()==3,"Expected three tree overlays")
    var tree = manifest["instances"][0]
    player.position=Vector2(float(tree["x"])+32.0,float(tree["y"])+25.0)
    _update_occlusion()
    var behind := int(occluders[0]["sprite"].z_index)==20
    player.position=Vector2(float(tree["x"])+32.0,float(tree["y"])+75.0)
    _update_occlusion()
    var front := int(occluders[0]["sprite"].z_index)==1
    player.position=Vector2(88,125)
    var wall_hit := player.move_and_collide(Vector2(40,0)) != null
    player.position=Vector2(float(manifest["spawn"]["x"]),float(manifest["spawn"]["y"]))
    var path_clear := true
    for n in range(10):
        if player.move_and_collide(Vector2(0,-26)) != null:
            path_clear=false
            break
    var size_ok: bool = load("res://FS_FOREST_V32_Ground.png").get_size()==Vector2(544,416)
    print("GODOT_FOREST_SMOKE_TEST behind=",behind," front=",front," collision=",wall_hit," route=",path_clear," size=",size_ok)
    var ok: bool = behind and front and wall_hit and path_clear and size_ok
    print("GODOT_GATE_F_LOGIC_PASS" if ok else "GODOT_GATE_F_LOGIC_FAIL")
    get_tree().quit(0 if ok else 2)
