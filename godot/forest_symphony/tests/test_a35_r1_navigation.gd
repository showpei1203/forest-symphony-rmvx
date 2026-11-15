extends SceneTree
## A35 R1 independent physical navigation regression on actual Godot CollisionShape2D.
const A34 := "res://scenes/a34_r4_house_pair_scene.tscn"
const A35 := "res://scenes/a35_r1_forest_groves_scene.tscn"
const COLS := 80
const ROWS := 58
const CELL := 16
var nchecks: int = 0

func assert_gate(condition: bool, message: String) -> bool:
    if condition:
        nchecks += 1
        return true
    push_error("A35 NAV FAIL: "+message)
    return false

func _initialize() -> void:call_deferred("_run")

func sample(scene_path: String) -> PackedByteArray:
    var world: Node2D=load(scene_path).instantiate()
    root.add_child(world)
    world.get_node("YSort/Player/BodyCollision").disabled=true
    await process_frame
    await physics_frame
    var occ:=PackedByteArray()
    occ.resize(COLS*ROWS)
    var foot:=RectangleShape2D.new()
    foot.size=Vector2(13,9)
    var q:=PhysicsShapeQueryParameters2D.new()
    q.shape=foot
    q.collision_mask=1
    q.collide_with_bodies=true
    var space:PhysicsDirectSpaceState2D=world.get_world_2d().direct_space_state
    for cy in range(ROWS):
        for cx in range(COLS):
            q.transform=Transform2D(0.0,Vector2(cx*CELL+CELL/2,cy*CELL+CELL/2))
            if not space.intersect_shape(q,1).is_empty():
                occ[cy*COLS+cx]=1
    world.queue_free()
    await process_frame
    await physics_frame
    return occ

func route(occ: PackedByteArray,start:Vector2i,goal:Vector2i) -> bool:
    if start.x<0 or start.x>=COLS or start.y<0 or start.y>=ROWS:return false
    if goal.x<0 or goal.x>=COLS or goal.y<0 or goal.y>=ROWS:return false
    var st:int=start.y*COLS+start.x
    var en:int=goal.y*COLS+goal.x
    if occ[st]!=0 or occ[en]!=0:return false
    var visited:=PackedByteArray()
    visited.resize(COLS*ROWS)
    var frontier:Array[int]=[st]
    visited[st]=1
    var head:int=0
    while head<frontier.size():
        var at:int=frontier[head]
        head+=1
        if at==en:return true
        var x:int=at%COLS
        var y:int=at/COLS
        for step in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
            var xx:int=x+step.x
            var yy:int=y+step.y
            if xx<0 or xx>=COLS or yy<0 or yy>=ROWS:continue
            var j:int=yy*COLS+xx
            if occ[j]==0 and visited[j]==0:
                visited[j]=1
                frontier.append(j)
    return false

func _run() -> void:
    var baseline:PackedByteArray=await sample(A34)
    var candidate:PackedByteArray=await sample(A35)
    if not assert_gate(baseline.size()==COLS*ROWS and candidate.size()==COLS*ROWS,"native sample grid exists"):
        quit(30);return
    var f:=FileAccess.open("res://data/a35_r1_forest_groves_manifest.json",FileAccess.READ)
    if not assert_gate(f!=null,"manifest"):quit(31);return
    var d:Dictionary=JSON.parse_string(f.get_as_text())
    f.close()
    var new_blocked_on_roads:int=0
    var newly_blocked_total:int=0
    for cy in range(ROWS):
        for cx in range(COLS):
            var k:int=cy*COLS+cx
            if baseline[k]==0 and candidate[k]!=0:
                newly_blocked_total+=1
                var wx:float=cx*CELL+CELL/2.0
                var wy:float=cy*CELL+CELL/2.0
                for safe in d["a35_gate"]["protected_road_rectangles"]:
                    if wx>=float(safe[0]) and wx<float(safe[2]) and wy>=float(safe[1]) and wy<float(safe[3]):
                        new_blocked_on_roads+=1
    if not assert_gate(new_blocked_on_roads==0,"no road grid cells gained physical obstruction"):
        quit(32);return
    var paths=[
        {"name":"north_to_south","a":Vector2i(40,6),"b":Vector2i(40,54)},
        {"name":"west_to_east","a":Vector2i(3,32),"b":Vector2i(75,34)},
        {"name":"central_to_house_west","a":Vector2i(40,32),"b":Vector2i(18,28)},
        {"name":"central_to_house_east","a":Vector2i(40,32),"b":Vector2i(65,28)},
    ]
    var baselines:int=0
    var new_routes:int=0
    for entry in paths:
        var old_ok:bool=route(baseline,entry["a"],entry["b"])
        var new_ok:bool=route(candidate,entry["a"],entry["b"])
        if old_ok:baselines+=1
        if new_ok:new_routes+=1
        if not assert_gate(not old_ok or new_ok,"no regression to established path "+entry["name"]):
            quit(33);return
        print("A35 NAV ROUTE "+entry["name"]+": baseline="+str(old_ok)+" candidate="+str(new_ok))
    if not assert_gate(baselines>=2 and new_routes>=2,"at least two physically navigable routes"):
        quit(34);return
    print("A35 R1 NATIVE PHYSICAL NAV PASS "+str(nchecks)+"/"+str(nchecks)+" gates; new_blocked_total="+str(newly_blocked_total)+" newly_blocked_protected_roads="+str(new_blocked_on_roads)+"; routes="+str(new_routes)+"/"+str(paths.size()))
    quit(0)

