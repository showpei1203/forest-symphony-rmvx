extends "res://scripts/a36_player.gd"
## R13 real playable CharacterBody2D. Left-click follows R12 painted-road A*;
## keyboard still uses native move_and_slide. R12 Player script remains untouched.

signal destination_reached(cell:Vector2i)
signal route_blocked(reason:String)

var waypoints:Array[Vector2]=[]
var destination_cell:Vector2i=Vector2i(-1,-1)
var route_index:int=0
var speed_multiplier:float=1.0
var is_walking_route:bool=false
var last_route_error:String=""

func plan_to_cell(goal:Vector2i,use_bridge:bool=false)->bool:
    var world:Node=get_parent().get_parent()
    var nav:Node2D=world.get_node("RoadNavigator")
    var topo:Node2D=world.get_node("MazeTopology")
    if not nav.paths_ready or (use_bridge and not topo.topology_ready):return false
    var start:=Vector2i(floori(global_position.x/32.0),floori(global_position.y/32.0))
    var cells:Array[Vector2i]
    if use_bridge:
        cells=topo.get_bridge_route_cells(start,goal)
    else:
        cells=nav.get_route_cells(start,goal)
    if cells.is_empty():return false
    waypoints.clear()
    for i in range(cells.size()):
        var at:Vector2=Vector2(cells[i].x*32+16,cells[i].y*32+16)
        if i==0 and global_position.distance_to(at)<1.0:continue
        waypoints.append(at)
    destination_cell=goal
    route_index=0
    last_route_error=""
    is_walking_route=true
    return true

func cancel_route()->void:
    waypoints.clear()
    route_index=0
    is_walking_route=false
    velocity=Vector2.ZERO

func _unhandled_input(event:InputEvent)->void:
    if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
        var target:=get_global_mouse_position()
        if target.x<0 or target.y<0 or target.x>=2560 or target.y>=1856:return
        var destination:=Vector2i(floori(target.x/32),floori(target.y/32))
        var start:=Vector2i(floori(global_position.x/32),floori(global_position.y/32))
        var bridge_route:bool=(start.x>=14 and destination.x<=6) or (start.x<=6 and destination.x>=14)
        plan_to_cell(destination,bridge_route)
    elif event.is_action_pressed("ui_cancel"):
        cancel_route()

func _physics_process(delta:float)->void:
    var move_axis:=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    if move_axis.length_squared()>0:
        if is_walking_route:cancel_route()
        velocity=move_axis*speed*speed_multiplier
        move_and_slide()
    elif is_walking_route:
        _advance_waypoint(delta)
    else:
        velocity=Vector2.ZERO
    global_position.x=clampf(global_position.x,7,2553)
    global_position.y=clampf(global_position.y,7,1849)

func _advance_waypoint(delta:float)->void:
    if route_index>=waypoints.size():
        is_walking_route=false
        velocity=Vector2.ZERO
        destination_reached.emit(destination_cell)
        return
    var difference:Vector2=waypoints[route_index]-global_position
    if difference.length()<=0.65:
        global_position=waypoints[route_index]
        route_index+=1
        if route_index>=waypoints.size():
            is_walking_route=false
            velocity=Vector2.ZERO
            destination_reached.emit(destination_cell)
        return
    if delta<=0.0:return
    var prior:=global_position
    velocity=difference.normalized()*minf(speed*speed_multiplier,difference.length()/delta)
    move_and_slide()
    if global_position.distance_to(prior)<0.05:
        last_route_error="Actor blocked on R13 path at waypoint "+str(route_index)
        cancel_route()
        route_blocked.emit(last_route_error)
