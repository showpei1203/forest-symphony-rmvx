extends Node2D
## R13 authored entrance, exit and physical stone-bridge contract.
## Original R12 Ground/PAR/water collision remain immutable.
## Bridge is the existing painted earthen span at row 29, not a new fake overlay.
signal exit_requested(destination_scene_id:String, destination_spawn:String)
signal bridge_crossed()

const TILE := 32
const GRID := Vector2i(80,58)
const ENTRANCE := Vector2i(39,55)
const EXIT := Vector2i(49,5)
const EAST_BRIDGE := Vector2i(14,29)
const WEST_BRIDGE := Vector2i(6,29)
const DESTINATION_SCENE_ID := "FS_01_VILLAGE"
const DESTINATION_SPAWN := "maze_north_return"

var bridge_ready:bool=false
var topology_ready:bool=false
var failure:String=""
var _bridge_enter_bank:String=""
var _last_bridge_cell:Vector2i=Vector2i(-1,-1)

@onready var navigator:Node2D=$"../RoadNavigator"
@onready var player:CharacterBody2D=$"../YSort/Player"
@onready var water:Node2D=$"../WaterSemanticHazards"

func _ready()->void:
    call_deferred("_validate_topology")

func _validate_topology()->void:
    for i in range(180):
        if navigator.paths_ready or not navigator.build_failed.is_empty():break
        await get_tree().physics_frame
    if not navigator.paths_ready:
        failure="R12 physics navigator did not initialize: "+str(navigator.build_failed)
        push_error(failure)
        return
    if water.water_count!=148 or not water.valid:
        failure="Canonical 148 real water colliders missing"
        push_error(failure)
        return
    if not _is_open(ENTRANCE) or not _is_open(EXIT):
        failure="Authored entrance or exit is physically blocked"
        push_error(failure)
        return
    if navigator.get_route_cells(ENTRANCE,EXIT).is_empty():
        failure="No playable entrance to north exit"
        push_error(failure)
        return
    for x in range(WEST_BRIDGE.x,EAST_BRIDGE.x+1):
        var cell:=Vector2i(x,29)
        if water.is_river_tile(cell) or not _is_open(cell):
            failure="Painted bridge corridor is obstructed at "+str(cell)
            push_error(failure)
            return
        if x>WEST_BRIDGE.x:
            var before:=_center(Vector2i(x-1,29))
            var movement:=Vector2(TILE,0)
            if player.test_move(Transform2D(0.0,before),movement,null,0.01,false):
                failure="Real player foot sweep collides on painted bridge at x="+str(x)
                push_error(failure)
                return
    var leg_to_east:Array[Vector2i]=navigator.get_route_cells(ENTRANCE,EAST_BRIDGE)
    var leg_from_west:Array[Vector2i]=navigator.get_route_cells(WEST_BRIDGE,Vector2i(5,27))
    if leg_to_east.is_empty() or leg_from_west.is_empty():
        failure="Existing bridge has no connected east or west bank path"
        push_error(failure)
        return
    bridge_ready=true
    topology_ready=true
    print("FS_01_MAZE R13 TOPOLOGY READY: south entrance ",ENTRANCE," to north exit ",EXIT,
        "; original painted bridge 9/9 open native Player sweeps, 148 water colliders retained")

func get_bridge_route_cells(start_cell:Vector2i,finish_cell:Vector2i)->Array[Vector2i]:
    var empty:Array[Vector2i]=[]
    if not topology_ready:return empty
    var east_to_west:bool=start_cell.x>=EAST_BRIDGE.x and finish_cell.x<=WEST_BRIDGE.x
    var west_to_east:bool=start_cell.x<=WEST_BRIDGE.x and finish_cell.x>=EAST_BRIDGE.x
    if not east_to_west and not west_to_east:return empty
    var near_side:Vector2i=EAST_BRIDGE if east_to_west else WEST_BRIDGE
    var far_side:Vector2i=WEST_BRIDGE if east_to_west else EAST_BRIDGE
    var first:Array[Vector2i]=navigator.get_route_cells(start_cell,near_side)
    var last:Array[Vector2i]=navigator.get_route_cells(far_side,finish_cell)
    if first.is_empty() or last.is_empty():return empty
    var all_cells:Array[Vector2i]=first.duplicate()
    var step:int=-1 if east_to_west else 1
    for x in range(near_side.x+step,far_side.x+step,step):
        all_cells.append(Vector2i(x,29))
    for j in range(1,last.size()):all_cells.append(last[j])
    return all_cells

func _physics_process(_delta:float)->void:
    if not topology_ready:return
    var cell:=Vector2i(floori(player.global_position.x/TILE),floori(player.global_position.y/TILE))
    var is_bridge:bool=cell.y==29 and cell.x>=7 and cell.x<=13
    var was_bridge:bool=_last_bridge_cell.y==29 and _last_bridge_cell.x>=7 and _last_bridge_cell.x<=13
    if is_bridge and not was_bridge:
        if _last_bridge_cell.y==29 and _last_bridge_cell.x>=14:_bridge_enter_bank="east"
        elif _last_bridge_cell.y==29 and _last_bridge_cell.x<=6:_bridge_enter_bank="west"
        else:_bridge_enter_bank=""
    if was_bridge and not is_bridge:
        if (_bridge_enter_bank=="east" and cell.y==29 and cell.x<=6) or (_bridge_enter_bank=="west" and cell.y==29 and cell.x>=14):
            bridge_crossed.emit()
        _bridge_enter_bank=""
    _last_bridge_cell=cell
    # Exit is an interaction signal. Do not silently teleport into a missing/ART-HOLD scene.
    if player.global_position.distance_to(_center(EXIT))<=20.0 and Input.is_action_just_pressed("ui_accept"):
        exit_requested.emit(DESTINATION_SCENE_ID,DESTINATION_SPAWN)

func _is_open(cell:Vector2i)->bool:
    return cell.x>=0 and cell.x<GRID.x and cell.y>=0 and cell.y<GRID.y and not navigator.graph.is_point_solid(cell)

func _center(cell:Vector2i)->Vector2:
    return Vector2(cell.x*TILE+16,cell.y*TILE+16)
