extends SceneTree
## FS_01_MAZE R11: test real CharacterBody2D 13x9 foot collision sweeps.
## Unlike cell-center A*, this uses the actual actor CharacterBody2D.test_move
## across every cell-to-cell segment of the five Godot R10 road-weighted paths.
## Dry-run only: does not alter originals or claim gameplay events/nav seal.
const SCENE := "res://scenes/fs_01_maze_r8_water_collision_80x58.tscn"
const ROUTES := "res://qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json"
const OUT := "res://qa_a36c/FS_01_MAZE_R11_ACTUAL_GODOT_ACTOR_SWEEP.json"
const GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const TILE := 32

func _initialize()->void:
    call_deferred("_run")

func _fail(message:String,code:int)->void:
    push_error("FS_01_MAZE R11 ACTOR SWEEP FAIL: "+message)
    quit(code)

func _point(pair:Array)->Vector2:
    return Vector2(float(int(pair[0])*TILE+16),float(int(pair[1])*TILE+16))

func _run()->void:
    if FileAccess.get_sha256(GROUND)!=GROUND_SHA:
        _fail("Original Ground source modified",91);return
    var payload:Variant=JSON.parse_string(FileAccess.get_file_as_string(ROUTES))
    if typeof(payload)!=TYPE_DICTIONARY:
        _fail("R10 verified Godot weighted route report absent",92);return
    var control:Dictionary=payload
    if int(control.get("route_candidate_pass_count",-1))!=5 or int(control.get("water_collision_tiles",-1))!=148:
        _fail("R10 native source acceptance missing",93);return
    var world:Node2D=load(SCENE).instantiate()
    root.add_child(world)
    var water:Node2D=world.get_node("WaterSemanticHazards")
    var actor:CharacterBody2D=world.get_node("YSort/Player")
    actor.visible=false
    actor.collision_layer=0
    actor.collision_mask=1
    if not water.valid or water.water_count!=148:
        _fail("Water collision was lost",94);return
    await physics_frame
    await physics_frame
    var findings:Array=[]
    var checked_segments:=0
    var collided_segments:=0
    var true_routes:=0
    var sample_failures:Array=[]
    for route in control["routes"]:
        var path:Array=route["weighted_route_grid"]
        var failures:=0
        for i in range(1,path.size()):
            var from:Vector2=_point(path[i-1])
            var to:Vector2=_point(path[i])
            var motion:Vector2=to-from
            if not is_equal_approx(motion.length(),32.0):
                _fail("R10 path contains diagonal/teleport movement on "+str(route["from"]),95);return
            # Actual live player's collision shape at the supplied global
            # transform, testing entire continuous cell-to-cell motion.
            var pose:=Transform2D(0.0,from)
            var hit:bool=actor.test_move(pose,motion,null,0.01,false)
            checked_segments+=1
            if hit:
                failures+=1
                collided_segments+=1
                if sample_failures.size()<24:
                    sample_failures.append({
                      "route":route["from"]+"__"+route["to"],
                      "at_step":i,
                      "from":[int(path[i-1][0]),int(path[i-1][1])],
                      "to":[int(path[i][0]),int(path[i][1])]
                    })
        var route_pass:bool=failures==0
        if route_pass:true_routes+=1
        findings.append({
          "from":route["from"],"to":route["to"],
          "sweep_segments":path.size()-1,
          "physical_sweep_collision_count":failures,
          "continuous_foot_actor_sweep_pass":route_pass
        })
        print("FS_01_MAZE R11 ACTUAL PLAYER TEST_MOVE ",
          route["from"]," -> ",route["to"],
          " segments=",path.size()-1," collisions=",failures,
          " pass=",route_pass)
    var report:Dictionary={
      "engine":"Godot 4.7.2 native CharacterBody2D.test_move for actual Player BodyCollision 13x9 shape",
      "map_id":"FS_01_MAZE",
      "scene":SCENE,
      "original_Ground_SHA":GROUND_SHA,
      "R10_road_weighted_routes":5,
      "water_physical_blockers":water.water_count,
      "segments_checked":checked_segments,
      "colliding_segments":collided_segments,
      "fully_clear_continuous_sweep_routes":true_routes,
      "route_details":findings,
      "first_failures":sample_failures,
      "formal_maze_nav":"HOLD: selected artistic start/exit, bridge crossing, actual animated movement and NPC/event integration still missing",
      "art":"HOLD",
      "status":"Real Godot player continuous body sweep; no private sprites or Ground changed"
    }
    var f:=FileAccess.open(OUT,FileAccess.WRITE)
    if f==null:
        _fail("Unable to save actual body movement sweep report",96);return
    f.store_string(JSON.stringify(report,"  ")+"\n")
    f.close()
    if checked_segments<180 or collided_segments>0:
        _fail("Detected "+str(collided_segments)+" real actor movement collisions over "+str(checked_segments)+" segments",97);return
    print("FS_01_MAZE R11 GODOT ACTUAL PLAYER SWEEP PASS: ",
      checked_segments," complete 32px continuous CharacterBody2D movements, ",
      true_routes,"/5 R10 forest roads, 148 river blockers retained; FORMAL GAMEPLAY NAV/ART HOLD")
    quit(0)
