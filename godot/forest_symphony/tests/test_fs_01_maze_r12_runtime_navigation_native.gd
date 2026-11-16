extends SceneTree
## R12 Native integration: instantiate actual new live Godot map, build real
## 80x58 road+physics grid, call runtime routing API, sweep the original player.
const SCENE := "res://scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn"
const R10 := "res://qa_a36c/FS_01_MAZE_R10_GODOT_ROAD_WEIGHTED_ROUTES.json"
const GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"

func _initialize()->void:call_deferred("_run")
func _fail(reason:String,code:int=81)->void:
    push_error("FS_01_MAZE R12 LIVE NAV FAIL: "+reason)
    quit(code)
func _center(cell:Vector2i)->Vector2:
    return Vector2(cell.x*32+16,cell.y*32+16)
func _run()->void:
    if FileAccess.get_sha256(GROUND)!=GROUND_SHA:
        _fail("Original private Ground SHA drift",82);return
    var route_data:Variant=JSON.parse_string(FileAccess.get_file_as_string(R10))
    if typeof(route_data)!=TYPE_DICTIONARY or route_data.get("route_candidate_pass_count",0)!=5:
        _fail("R10 original actual Godot route report missing",83);return
    var map_resource:PackedScene=load(SCENE)
    if map_resource==null:
        _fail("R12 true Godot scene missing",84);return
    var world:Node2D=map_resource.instantiate()
    root.add_child(world)
    var navigator:Node2D=world.get_node_or_null("RoadNavigator")
    var river:Node2D=world.get_node_or_null("WaterSemanticHazards")
    var actor:CharacterBody2D=world.get_node_or_null("YSort/Player")
    if navigator==null or river==null or actor==null:
        _fail("Missing actual live world nodes",85);return
    for i in range(12):
        await process_frame
        if navigator.paths_ready:break
    if not navigator.paths_ready:
        _fail("Runtime graph failed: "+str(navigator.build_failed),86);return
    if navigator.blocked_cells+navigator.walkable_cells!=4640 or river.water_count!=148:
        _fail("Physics graph or 148 river blockers missing",87);return
    if world.get_node("YSort").get_child_count()!=327:
        _fail("Original 326 whole PAR plus actor not retained",88);return
    var perfect:=0
    var sweep_count:=0
    var sweeps_blocked:=0
    for control in route_data["routes"]:
        var known:Array=control["weighted_route_grid"]
        var start:=Vector2i(int(known[0][0]),int(known[0][1]))
        var finish:=Vector2i(int(known[known.size()-1][0]),int(known[known.size()-1][1]))
        var cells:Array[Vector2i]=navigator.get_route_cells(start,finish)
        if cells.size()!=known.size():
            _fail("Runtime road path differs from R10 tested path length "+str(control["from"]),89);return
        var same_path:bool=true
        for j in range(cells.size()):
            if cells[j]!=Vector2i(int(known[j][0]),int(known[j][1])):
                same_path=false
                break
        if not same_path:
            _fail("Runtime path differs from actual Godot R10 original "+str(control["from"]),90);return
        var world_route:Array[Vector2]=navigator.get_world_route(_center(start),_center(finish))
        if world_route.size()!=cells.size():
            _fail("Gameplay public world API incomplete",91);return
        for j in range(1,cells.size()):
            var start_world:=_center(cells[j-1])
            var movement:=_center(cells[j])-start_world
            if actor.test_move(Transform2D(0.0,start_world),movement,null,0.01,false):
                sweeps_blocked+=1
            sweep_count+=1
        perfect+=1
        print("FS_01_MAZE R12 LIVE ROAD API MATCH ",control["from"]," -> ",control["to"],
             " grid_cells=",cells.size()," original Godot R10 route exact")
    if perfect!=5 or sweep_count!=231 or sweeps_blocked!=0:
        _fail("Real actor sweeps/road runtime not safe "+str([perfect,sweep_count,sweeps_blocked]),92);return
    if navigator.get_route_cells(Vector2i(-1,5),Vector2i(30,30)).size()!=0:
        _fail("Runtime bounds guard absent",93);return
    if navigator.get_route_cells(Vector2i(3,3),Vector2i(-1,-1)).size()!=0:
        _fail("Runtime invalid goal accepted",94);return
    print("FS_01_MAZE R12 NATIVE LIVE ROAD NAV PASS: real 80x58 Godot scene, 326 PAR, 148 physical water, 4640 weighted-foot cells, 5/5 exact R10 native paths, 231/231 actual Player sweeps, runtime API tested, GAMEPLAY SPAWNS/ART HOLD")
    quit(0)
