extends Node2D
## FS_01_MAZE R12: LIVE road-aware dungeon navigator, Godot 4.7.2.
## Integrated runtime component, not just a unit-test-only AStar script.
## Ground untouched. Original 326 PAR + 148 water physics are authoritative.
const SEMANTIC := "res://data/fs_01_maze_r10_ground_road_confidence.json"
const ORIGINAL_GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const ORIGINAL_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const GRID := Vector2i(80,58)
const TILE := 32
const PLAYER_FOOT := Vector2(13,9)

var paths_ready:bool=false
var build_failed:String=""
var blocked_cells:int=0
var walkable_cells:int=0
var river_cells:int=0
var graph:AStarGrid2D
var ground_confidence:Array=[]

func _ready()->void:
    call_deferred("_build_native_grid")

func _build_native_grid()->void:
    paths_ready=false
    if FileAccess.get_sha256(ORIGINAL_GROUND)!=ORIGINAL_SHA:
        build_failed="Original Ground SHA invalid"
        push_error(build_failed)
        return
    var data:Variant=JSON.parse_string(FileAccess.get_file_as_string(SEMANTIC))
    if typeof(data)!=TYPE_DICTIONARY:
        build_failed="Ground road semantic JSON missing"
        push_error(build_failed)
        return
    var dims:Array=data.get("grid",[])
    ground_confidence=data.get("road_confidence",[])
    if dims.size()!=2 or int(dims[0])!=80 or int(dims[1])!=58 or ground_confidence.size()!=58 or data.get("full_Ground_only_original_sha256","")!=ORIGINAL_SHA:
        build_failed="Road semantic size or Ground provenance incorrect"
        push_error(build_failed)
        return
    for line in ground_confidence:
        if typeof(line)!=TYPE_ARRAY or line.size()!=80:
            build_failed="Invalid road semantic row"
            push_error(build_failed)
            return
    var world:Node2D=get_parent()
    var water:Node2D=world.get_node_or_null("WaterSemanticHazards")
    var actor:CharacterBody2D=world.get_node_or_null("YSort/Player")
    if water==null or not water.valid or water.water_count!=148 or actor==null:
        build_failed="Original Godot forest/water/actor unavailable"
        push_error(build_failed)
        return
    river_cells=water.water_count
    var original_layer:int=actor.collision_layer
    actor.collision_layer=0
    await get_tree().physics_frame
    await get_tree().physics_frame
    var footprint:=RectangleShape2D.new()
    footprint.size=PLAYER_FOOT
    var query:=PhysicsShapeQueryParameters2D.new()
    query.shape=footprint
    query.collision_mask=1
    query.collide_with_bodies=true
    var physics:=world.get_world_2d().direct_space_state
    graph=AStarGrid2D.new()
    graph.region=Rect2i(0,0,GRID.x,GRID.y)
    graph.cell_size=Vector2(TILE,TILE)
    graph.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
    graph.update()
    blocked_cells=0
    walkable_cells=0
    for y in range(GRID.y):
        for x in range(GRID.x):
            var at:=Vector2i(x,y)
            query.transform=Transform2D(0.0,Vector2(float(x*TILE+16),float(y*TILE+16)))
            var hit:bool=not physics.intersect_shape(query,32).is_empty()
            if water.is_river_tile(at) and not hit:
                build_failed="Unblocked water at "+str(at)
                break
            if hit:
                graph.set_point_solid(at,true)
                blocked_cells+=1
            else:
                var score:float=clampf(float(ground_confidence[y][x]),0.0,1.0)
                graph.set_point_weight_scale(at,1.0+8.0*maxf(0.0,0.55-score)/0.55)
                walkable_cells+=1
        if not build_failed.is_empty():
            break
    actor.collision_layer=original_layer
    paths_ready=build_failed.is_empty() and (blocked_cells+walkable_cells==80*58)
    if not paths_ready:
        if build_failed.is_empty():build_failed="Live road graph incomplete"
        push_error(build_failed)
        return
    print("FS_01_MAZE R12 LIVE ROAD NAVIGATOR READY: 4640 native physics foot tests, 148 river tiles, walkable=",walkable_cells," blocked=",blocked_cells," original art immutable")

func get_route_cells(start_cell:Vector2i,end_cell:Vector2i)->Array[Vector2i]:
    if not paths_ready or graph==null:
        return []
    if not _in_bounds(start_cell) or not _in_bounds(end_cell):
        return []
    if graph.is_point_solid(start_cell) or graph.is_point_solid(end_cell):
        return []
    return graph.get_id_path(start_cell,end_cell)

func get_world_route(start_pos:Vector2,end_pos:Vector2)->Array[Vector2]:
    var start_cell:=Vector2i(floori(start_pos.x/TILE),floori(start_pos.y/TILE))
    var end_cell:=Vector2i(floori(end_pos.x/TILE),floori(end_pos.y/TILE))
    var cells:Array[Vector2i]=get_route_cells(start_cell,end_cell)
    var result:Array[Vector2]=[]
    for cell in cells:
        result.append(Vector2(cell.x*TILE+16,cell.y*TILE+16))
    return result

func get_nearest_open(cell:Vector2i,radius:int=8)->Vector2i:
    if not paths_ready or graph==null:
        return Vector2i(-1,-1)
    for r in range(maxi(radius,0)+1):
        for dy in range(-r,r+1):
            for dx in range(-r,r+1):
                if maxi(absi(dx),absi(dy))!=r:continue
                var at:=cell+Vector2i(dx,dy)
                if _in_bounds(at) and not graph.is_point_solid(at):
                    return at
    return Vector2i(-1,-1)

func _in_bounds(at:Vector2i)->bool:
    return at.x>=0 and at.y>=0 and at.x<GRID.x and at.y<GRID.y
