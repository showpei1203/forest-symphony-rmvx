extends SceneTree
## FS_01_MAZE R9 / Godot native 80x58 walkability reconnaissance.
## Scan each 32px grid cell with ACTUAL player-foot collision shape against
## tree, house, water StaticBody2D. Output candidate route survey, not final
## approved dungeon graph or hand-painted visible path.
const SCENE := "res://scenes/fs_01_maze_r8_water_collision_80x58.tscn"
const WIDTH := 80
const HEIGHT := 58
const TILE := 32
const FOOT_SIZE := Vector2(13.0,9.0)
const OUTPUT := "res://qa_a36c/FS_01_MAZE_R9_ACTUAL_PHYSICS_ROUTE_SURVEY.json"

func _initialize() -> void:
    call_deferred("_run")

func _nearest_open(grid:AStarGrid2D, preferred:Vector2i, radius:int=8) -> Vector2i:
    for r in range(radius+1):
        for dy in range(-r,r+1):
            for dx in range(-r,r+1):
                if maxi(absi(dx),absi(dy))!=r:
                    continue
                var p:=preferred+Vector2i(dx,dy)
                if p.x>=0 and p.y>=0 and p.x<WIDTH and p.y<HEIGHT and not grid.is_point_solid(p):
                    return p
    return Vector2i(-1,-1)

func _run() -> void:
    var world:Node2D=load(SCENE).instantiate()
    root.add_child(world)
    var actor:CharacterBody2D=world.get_node("YSort/Player")
    # Exclude a standing player from blocking their own nav tile.
    actor.collision_layer=0
    actor.collision_mask=0
    await physics_frame
    await physics_frame
    var water=world.get_node("WaterSemanticHazards")
    if not water.valid or water.water_count!=148:
        push_error("R9 must survey actual 148 water collision rectangles");quit(61);return
    var shape:=RectangleShape2D.new()
    shape.size=FOOT_SIZE
    var query:=PhysicsShapeQueryParameters2D.new()
    query.shape=shape
    query.collision_mask=1
    query.collide_with_bodies=true
    var physics:=world.get_world_2d().direct_space_state
    var pathing:=AStarGrid2D.new()
    pathing.region=Rect2i(0,0,WIDTH,HEIGHT)
    pathing.cell_size=Vector2(TILE,TILE)
    pathing.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
    pathing.update()
    var occupied:=0
    var water_count:=0
    var blocked_rows:Array[String]=[]
    for y in range(HEIGHT):
        var row:=" "
        row=""
        for x in range(WIDTH):
            var p:=Vector2i(x,y)
            query.transform=Transform2D(0.0,Vector2(x*TILE+TILE*.5,y*TILE+TILE*.5))
            var hits:Array=physics.intersect_shape(query,32)
            var is_solid:bool=not hits.is_empty()
            if is_solid:
                pathing.set_point_solid(p,true)
                occupied+=1
            if water.is_river_tile(p):
                water_count+=1
                row+="~"
                if not is_solid:
                    push_error("R9 detected unblocked river grid center "+str(p));quit(62);return
            else:
                row+="#" if is_solid else "."
        blocked_rows.append(row)
    if water_count!=148:
        push_error("R9 survey water mask was not complete");quit(63);return
    # These are CANDIDATE landmarks chosen from the observed actual R8 Ground.
    # A maze designer must confirm entrances/bridges/road semantics at 1:1.
    var anchors:Dictionary={
      "south_approach":Vector2i(39,55),
      "central_fork":Vector2i(39,31),
      "west_cottage":Vector2i(27,23),
      "east_cottage":Vector2i(57,14),
      "east_clearing":Vector2i(67,35),
      "north_forest":Vector2i(49,5)
    }
    var resolved:Dictionary={}
    for label in anchors:
        var at:Vector2i=_nearest_open(pathing,anchors[label],8)
        resolved[label]=[at.x,at.y]
    var pairs:Array=[
      ["south_approach","central_fork"],
      ["central_fork","west_cottage"],
      ["central_fork","east_cottage"],
      ["central_fork","east_clearing"],
      ["south_approach","north_forest"]
    ]
    var routes:Array=[]
    var confirmed:=0
    for pair in pairs:
        var src:Array=resolved[pair[0]]
        var dst:Array=resolved[pair[1]]
        var result:Dictionary={
          "from":pair[0],"to":pair[1],
          "start_grid":src,"finish_grid":dst,"pass":false,"length_cells":0,"path":[]
        }
        if src[0]>=0 and dst[0]>=0:
            var list:Array[Vector2i]=pathing.get_id_path(Vector2i(src[0],src[1]),Vector2i(dst[0],dst[1]))
            result["length_cells"]=list.size()
            result["pass"]=list.size()>1
            if result["pass"]:confirmed+=1
            var trace:Array=[]
            for cell in list:
                trace.append([cell.x,cell.y])
            result["path"]=trace
        routes.append(result)
        print("FS_01_MAZE R9 ACTUAL FOOTPRINT ROUTE ",result["from"]," -> ",result["to"],
              ": ",("CONNECTED" if result["pass"] else "BLOCKED")," cells=",result["length_cells"])
    var result:Dictionary={
      "engine":"Godot 4.7.2 official 2D physics source, actual 13x9px foot rectangles",
      "map":"FS_01_MAZE 幽葉迴廊","scene":SCENE,
      "grid":[WIDTH,HEIGHT],"tile_px":TILE,"water_physics_tiles":water_count,
      "walkable_cell_centers":WIDTH*HEIGHT-occupied,
      "blocked_cell_centers":occupied,
      "candidate_anchors":resolved,
      "candidate_test_count":pairs.size(),
      "connected_candidate_routes":confirmed,
      "candidate_routes":routes,
      "obstacle_rows_water_tilde_other_collision_hash_clear_dot":blocked_rows,
      "status":"EXPLORATORY. This is true static-footprint connectivity, not final handcrafted maze paths, dynamic actor movement or crossing bridge QA.",
      "formal_nav_gate":"HOLD",
      "art_gate":"HOLD"
    }
    var file:=FileAccess.open(OUTPUT,FileAccess.WRITE)
    if file==null:
        push_error("R9 failed writing native route QA");quit(64);return
    file.store_string(JSON.stringify(result,"  ")+"\n")
    file.close()
    print("FS_01_MAZE R9 GODOT PHYSICS SURVEY PASS: "+str(WIDTH*HEIGHT)+" real 13x9 foot grid queries, water 148/148, "+str(confirmed)+"/"+str(pairs.size())+" landmark route candidates connected, formal maze NAV/ART HOLD")
    quit(0)
