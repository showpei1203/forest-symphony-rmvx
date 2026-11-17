extends SceneTree
## FS_01_MAZE R13 native Godot 4.7.2 gameplay/bridge QA.
## Do not infer PASS from script presence: execute through official Godot runtime.
const SCENE := "res://scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn"
const ORIGINAL_GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const ORIGINAL_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const ENTRANCE := Vector2i(39,55)
const EXIT := Vector2i(49,5)
var _exit_fired:bool=false
var _bridge_crossed:int=0
func _initialize()->void:call_deferred("_run")
func _fail(reason:String)->void:
    push_error("FS_01_MAZE R13 NATIVE FAIL: "+reason)
    quit(103)
func _on_exit(_destination:String,_spawn:String)->void:
    if _destination=="FS_01_VILLAGE" and _spawn=="maze_north_return":_exit_fired=true
func _on_crossed()->void:_bridge_crossed+=1
func _center(cell:Vector2i)->Vector2:return Vector2(cell.x*32+16,cell.y*32+16)
func _run()->void:
    if FileAccess.get_sha256(ORIGINAL_GROUND)!=ORIGINAL_SHA:
        _fail("Original private Ground SHA mismatch");return
    var resource:PackedScene=load(SCENE)
    if resource==null:
        _fail("Real R13 PackedScene missing");return
    var world:Node2D=resource.instantiate()
    root.add_child(world)
    var nav:Node2D=world.get_node("RoadNavigator")
    var topo:Node2D=world.get_node("MazeTopology")
    var river:Node2D=world.get_node("WaterSemanticHazards")
    var actor:CharacterBody2D=world.get_node("YSort/Player")
    for i in range(240):
        if topo.topology_ready or not topo.failure.is_empty():break
        await physics_frame
    if not topo.topology_ready or not topo.bridge_ready:
        _fail("R13 topology was not physically validated: "+str(topo.failure));return
    if not nav.paths_ready or nav.walkable_cells!=4129 or nav.blocked_cells!=511:
        _fail("Baseline R12 actual 4640-cell graph unexpectedly changed");return
    if river.water_count!=148 or world.get_node("YSort").get_child_count()!=327:
        _fail("148 water or 326 independent PAR regressed");return
    if actor.global_position.distance_to(_center(ENTRANCE))>0.01:
        _fail("Player not spawned at authored south gate");return
    if topo.get_node("Entrance").position!=_center(ENTRANCE) or topo.get_node("Exit").position!=_center(EXIT):
        _fail("Actual entrance/exit Marker2D nodes incorrectly placed");return
    topo.exit_requested.connect(_on_exit)
    topo.bridge_crossed.connect(_on_crossed)
    actor.speed_multiplier=6.0
    if not actor.plan_to_cell(EXIT):
        _fail("Gameplay player cannot request road-weighted north exit path");return
    var arrived:bool=false
    for step in range(1800):
        await physics_frame
        if not actor.last_route_error.is_empty():
            _fail("Actual CharacterBody2D blocked: "+str(actor.last_route_error));return
        if not actor.is_walking_route and actor.global_position.distance_to(_center(EXIT))<=1.0:
            arrived=true
            break
    if not arrived:
        _fail("CharacterBody2D failed to walk physically from south entrance to north exit");return
    Input.action_press("ui_accept")
    await physics_frame
    await physics_frame
    Input.action_release("ui_accept")
    if not _exit_fired:
        _fail("Actual north exit did not emit valid village destination+spawn contract");return
    # Reset actor position only in test, to isolate real foot movement across painted stone bridge.
    actor.cancel_route()
    actor.global_position=_center(Vector2i(14,29))
    await physics_frame
    var river_cell:=Vector2i(9,27)
    if not river.is_river_tile(river_cell) or not nav.graph.is_point_solid(river_cell):
        _fail("Real water collider was weakened to fake the bridge");return
    var bridge_cells:Array[Vector2i]=topo.get_bridge_route_cells(Vector2i(14,29),Vector2i(5,27))
    if bridge_cells.is_empty():
        _fail("Authored physical bridge route API returned empty");return
    for x in range(6,15):
        if not bridge_cells.has(Vector2i(x,29)):
            _fail("Bridge route omitted actual painted bridge tile "+str(x));return
    if not actor.plan_to_cell(Vector2i(5,27),true):
        _fail("Real player cannot start fixed bridge route");return
    var bridged:bool=false
    for step in range(300):
        await physics_frame
        if not actor.last_route_error.is_empty():
            _fail("Real Player collided mid-bridge: "+str(actor.last_route_error));return
        if not actor.is_walking_route and actor.global_position.distance_to(_center(Vector2i(5,27)))<=1.0:
            bridged=true
            break
    if not bridged or _bridge_crossed!=1:
        _fail("Bridge player did not physically cross both banks exactly once, count="+str(_bridge_crossed));return
    if world.get_node("YSort").get_child_count()!=327 or river.water_count!=148:
        _fail("Gameplay movement modified protected objects/water");return
    print("FS_01_MAZE R13 NATIVE PASS: official Godot 4.7.2 real map, 326 PAR, 148 colliders, 4640 foot cells, entrance->north exit physical walking, enter-trigger signal, bridge 9/9 cells / real body crossing, art immutable. ART HOLD; destination scene wiring HOLD")
    quit(0)
