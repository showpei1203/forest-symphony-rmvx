extends SceneTree
## FS_01_MAZE R8 source/physics QA for 148 independent water collision cells.
const OLD := "res://scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
const NEW := "res://scenes/fs_01_maze_r8_water_collision_80x58.tscn"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
func _initialize() -> void: call_deferred("_run")
func _failed(msg:String,code:int) -> void:
    push_error("FS_01_MAZE R8 water physics FAIL: "+msg)
    quit(code)
func _run() -> void:
    if FileAccess.get_sha256("res://private_assets/a36_ground_only_2560x1856.png")!=GROUND_SHA:
        _failed("Ground changed",40);return
    var old:Node2D=load(OLD).instantiate()
    var new:Node2D=load(NEW).instantiate()
    root.add_child(old);root.add_child(new)
    await process_frame
    var a:Node2D=old.get_node("YSort")
    var b:Node2D=new.get_node("YSort")
    if a.get_child_count()!=327 or b.get_child_count()!=327:
        _failed("326 independent existing PAR owners not preserved",41);return
    for it in a.get_children():
        if it is CharacterBody2D:continue
        var now:Node2D=b.get_node_or_null(NodePath(str(it.name)))
        if now==null or now.position!=it.position or now.source_file!=it.source_file or now.source_sha256!=it.source_sha256:
            _failed("R8 water mutated source PAR "+str(it.name),42);return
        var ca:CollisionShape2D=it.get_node("Body/Collision")
        var cb:CollisionShape2D=now.get_node("Body/Collision")
        if (ca.shape==null)!=(cb.shape==null) or ca.disabled!=cb.disabled:
            _failed("R8 changed PAR collider presence "+str(it.name),43);return
        if ca.shape!=null and ca.shape.get_rect()!=cb.shape.get_rect():
            _failed("R8 modified original collision geometry "+str(it.name),44);return
    var layer:Node2D=new.get_node_or_null("WaterSemanticHazards")
    if layer==null or not layer.valid or layer.water_count!=148:
        _failed("148 actual collision tiles not constructed",45);return
    if layer.water_body==null or layer.water_body.get_child_count()!=148 or layer.water_body.collision_layer!=1:
        _failed("water body not correct physics shape family",46);return
    var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string("res://data/a36_terrain_semantic_candidates.json"))
    if typeof(parsed)!=TYPE_DICTIONARY:
        _failed("water source JSON missing",47);return
    var cells:Array=parsed["river_blocked_cells"]
    var checked:=0
    await physics_frame
    await physics_frame
    var physics=new.get_world_2d().direct_space_state
    for pair in cells:
        var x:int=int(pair[0])
        var y:int=int(pair[1])
        if not layer.is_river_tile(Vector2i(x,y)):
            _failed("water cell missing "+str(pair),48);return
        var params:=PhysicsPointQueryParameters2D.new()
        params.position=Vector2(float(x*32+16),float(y*32+16))
        params.collision_mask=1
        params.collide_with_bodies=true
        var hits:Array=physics.intersect_point(params,64)
        var got:=false
        for hit in hits:
            if hit.get("collider")==layer.water_body:
                got=true
                break
        if not got:
            _failed("real Godot physics water point no hit at "+str(pair),49);return
        checked+=1
    if checked!=148:
        _failed("only some water cells tested",50);return
    print("FS_01_MAZE R8 GODOT WATER PHYSICS PASS: 148/148 distinct real StaticBody2D water collision cells hit by PhysicsDirectSpaceState2D, 326 PAR/Ground unchanged, maze path/bridge/river art still HOLD")
    quit(0)
