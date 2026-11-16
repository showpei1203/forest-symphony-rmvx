extends SceneTree
## FS_01_MAZE R10: real Godot foot-sized collision + road-semantic weighted paths.
## NO new art. Retains FS_01_MAZE R8 148 river collision and 326 whole PAR.
## Native 5/5 road-preference improvement is a ROUTE CANDIDATE, not maze seal.
const SCENE := "res://scenes/fs_01_maze_r8_water_collision_80x58.tscn"
const ROAD := "res://data/fs_01_maze_r10_ground_road_confidence.json"
const PRIOR := "res://qa_a36c/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json"
const OUT := "res://qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json"
const GRID := Vector2i(80,58)
const TILE := 32
const GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"

func _initialize() -> void:
    call_deferred("_run")

func _fail(message:String,exit_code:int=71)->void:
    push_error("FS_01_MAZE R10 ROAD NAV FAIL: "+message)
    quit(exit_code)

func _mean_score(path:Array, confidence:Array)->float:
    if path.is_empty():return 0.0
    var total:float=0.0
    for step in path:
        var x:int=int(step[0])
        var y:int=int(step[1])
        total+=float(confidence[y][x])
    return total/float(path.size())

func _run()->void:
    if FileAccess.get_sha256(GROUND)!=GROUND_SHA:
        _fail("private Ground source image changed",72);return
    var meta_data:Variant=JSON.parse_string(FileAccess.get_file_as_string(ROAD))
    var old_data:Variant=JSON.parse_string(FileAccess.get_file_as_string(PRIOR))
    if typeof(meta_data)!=TYPE_DICTIONARY or typeof(old_data)!=TYPE_DICTIONARY:
        _fail("R10 road and R9 native path JSON missing",73);return
    var meta:Dictionary=meta_data
    var old:Dictionary=old_data
    var confidence:Array=meta.get("road_confidence",[])
    var dims:Array=meta.get("grid",[])
    if confidence.size()!=GRID.y or dims.size()!=2 or int(dims[0])!=80 or int(dims[1])!=58 or meta.get("full_Ground_only_original_sha256","")!=GROUND_SHA:
        _fail("R10 road confidence provenance/size mismatch",74);return
    for line in confidence:
        if typeof(line)!=TYPE_ARRAY or line.size()!=GRID.x:
            _fail("R10 score column count mismatch",75);return
    var old_routes:Array=old.get("candidate_routes",[])
    if old_routes.size()!=5:
        _fail("R9 native route control missing",76);return

    var world:Node2D=load(SCENE).instantiate()
    root.add_child(world)
    var river:Node2D=world.get_node("WaterSemanticHazards")
    if river.water_count!=148 or not river.valid:
        _fail("Real 148 river physics blockers missing",77);return
    var actor:CharacterBody2D=world.get_node("YSort/Player")
    actor.collision_layer=0
    actor.collision_mask=0
    await physics_frame
    await physics_frame

    var foot_shape:=RectangleShape2D.new()
    foot_shape.size=Vector2(13,9)
    var query:=PhysicsShapeQueryParameters2D.new()
    query.shape=foot_shape
    query.collide_with_bodies=true
    query.collision_mask=1
    var space:=world.get_world_2d().direct_space_state
    var grid:=AStarGrid2D.new()
    grid.region=Rect2i(0,0,GRID.x,GRID.y)
    grid.cell_size=Vector2(TILE,TILE)
    grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
    grid.update()
    var checked:=0
    var blocked:=0
    var annotated_roadwalk:=0
    for y in range(GRID.y):
        for x in range(GRID.x):
            var at:=Vector2i(x,y)
            query.transform=Transform2D(0.0,Vector2(float(x*TILE+16),float(y*TILE+16)))
            var hits:Array=space.intersect_shape(query,32)
            var solid:bool=not hits.is_empty()
            if solid:
                grid.set_point_solid(at,true)
                blocked+=1
            else:
                var score:float=clampf(float(confidence[y][x]),0.0,1.0)
                grid.set_point_weight_scale(at,1.0+8.0*maxf(0.0,0.55-score)/0.55)
                if score>=0.4:annotated_roadwalk+=1
            if river.is_river_tile(at) and not solid:
                _fail("Water cell clear when road semantic added "+str(at),78);return
            checked+=1

    var findings:Array=[]
    var successes:=0
    var improved:=0
    for old_route in old_routes:
        var start_cell:Array=old_route["start_grid"]
        var end_cell:Array=old_route["finish_grid"]
        var start:=Vector2i(int(start_cell[0]),int(start_cell[1]))
        var goal:=Vector2i(int(end_cell[0]),int(end_cell[1]))
        if grid.is_point_solid(start) or grid.is_point_solid(goal):
            _fail("Prior landmark endpoint now blocked, scene drift",79);return
        var path:Array[Vector2i]=grid.get_id_path(start,goal)
        var cells:Array=[]
        for at in path:
            if grid.is_point_solid(at):
                _fail("R10 path traverses real physical obstacle "+str(at),80);return
            cells.append([at.x,at.y])
        var old_path:Array=old_route["path"]
        var old_avg:float=_mean_score(old_path,confidence)
        var new_avg:float=_mean_score(cells,confidence)
        var length_ratio:float=float(path.size())/float(old_path.size())
        var gain:float=new_avg-old_avg
        var candidate_ok:bool=path.size()>1 and gain>=0.02 and length_ratio<=2.35
        if candidate_ok:successes+=1
        if gain>=0.05:improved+=1
        var record:Dictionary={
            "from":old_route["from"],"to":old_route["to"],
            "old_grid_cells":old_path.size(),"new_grid_cells":path.size(),
            "length_ratio":snappedf(length_ratio,0.001),
            "old_mean_ground_road_confidence":snappedf(old_avg,0.0001),
            "new_mean_ground_road_confidence":snappedf(new_avg,0.0001),
            "road_score_gain":snappedf(gain,0.0001),
            "connected":candidate_ok,"weighted_route_grid":cells
        }
        findings.append(record)
        print("FS_01_MAZE R10 NATIVE ROAD ",record["from"]," -> ",record["to"],
              " old=",record["old_grid_cells"]," new=",record["new_grid_cells"],
              " road gain=",record["road_score_gain"]," pass=",record["connected"])

    var output:Dictionary={
        "engine":"Godot 4.7.2 actual PhysicsDirectSpaceState2D foot-shaped 13x9 collision and weighted AStarGrid2D",
        "map_id":"FS_01_MAZE","scene":SCENE,"original_Ground_SHA":GROUND_SHA,
        "checked_grid_centers":checked,"physically_blocked_centers":blocked,
        "water_collision_tiles":river.water_count,
        "warm_ground_road_confidence_clear_cells_above_0_4":annotated_roadwalk,
        "candidate_route_count":old_routes.size(),
        "improved_road_candidate_count":improved,
        "route_candidate_pass_count":successes,
        "routes":findings,
        "visual_road_semantics":"Road confidence from original untouched Ground-only PNG; original Godot physics remains supreme",
        "formal_entrance_exit":"HOLD / not finalized",
        "moving_actor_sweep":"NOT RUN",
        "formal_maze_nav":"HOLD",
        "art":"HOLD"
    }
    var file:=FileAccess.open(OUT,FileAccess.WRITE)
    if file==null:
        _fail("Unable to save actual native weighted route report",81);return
    file.store_string(JSON.stringify(output,"  ")+"\n")
    file.close()
    if checked!=4640 or successes<5 or improved<4:
        _fail("Road affinity QA insufficient "+str([checked,successes,improved]),82);return
    print("FS_01_MAZE R10 GODOT NATIVE ROAD WEIGHT PASS: 4640 real physics foot checks, 148 water, 5/5 more road-aligned paths, >=4 genuine confidence improvements; formal NAV/ART HOLD")
    quit(0)
