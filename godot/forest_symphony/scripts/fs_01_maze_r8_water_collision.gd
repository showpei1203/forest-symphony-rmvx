extends Node2D
## FS_01_MAZE R8: 148 candidate water cells become native Godot collision.
## This is an isolated prototype on top of the R7 reconciled forest. It does
## not modify Ground pixels, house/tree PAR, YSort, or the original source scene.
## Full river-route art and player crossing still require separate QA.
const FILE := "res://data/a36_terrain_semantic_candidates.json"
const GROUND_FILE := "res://private_assets/a36_ground_only_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const TILE := 32
const GRID := Vector2i(80,58)
const EXPECTED := 148
var water_count: int = 0
var valid: bool = false
var water_body: StaticBody2D
var water_cells: Dictionary = {}

func _ready() -> void:
    _install_water()

func _install_water() -> void:
    water_count=0
    valid=false
    if FileAccess.get_sha256(GROUND_FILE)!=GROUND_SHA:
        push_error("FS_01_MAZE R8 original continuous Ground changed")
        return
    var data:Variant=JSON.parse_string(FileAccess.get_file_as_string(FILE))
    if typeof(data)!=TYPE_DICTIONARY:
        push_error("FS_01_MAZE R8 water semantic data invalid")
        return
    if int(data.get("tile_px",-1))!=TILE or int(data.get("river_cell_count",-1))!=EXPECTED:
        push_error("FS_01_MAZE R8 32px/148 water contract mismatch")
        return
    var coords:Array=data.get("river_blocked_cells",[])
    if coords.size()!=EXPECTED:
        push_error("FS_01_MAZE R8 missing water candidate entries")
        return
    water_body=StaticBody2D.new()
    water_body.name="FS01WaterStaticBody"
    water_body.collision_layer=1
    water_body.collision_mask=0
    water_body.add_to_group("fs01_water_collision")
    add_child(water_body)
    for pair in coords:
        if typeof(pair)!=TYPE_ARRAY or pair.size()!=2:
            push_error("FS_01_MAZE R8 malformed water coordinate")
            return
        var x:int=int(pair[0])
        var y:int=int(pair[1])
        if x<0 or y<0 or x>=GRID.x or y>=GRID.y:
            push_error("FS_01_MAZE R8 out-of-bounds river coordinate")
            return
        var key:Vector2i=Vector2i(x,y)
        if water_cells.has(key):
            push_error("FS_01_MAZE R8 duplicate water coordinate")
            return
        water_cells[key]=true
        var c:=CollisionShape2D.new()
        c.name="WaterTile_%02d_%02d" % [x,y]
        var box:=RectangleShape2D.new()
        box.size=Vector2(TILE,TILE)
        c.shape=box
        c.position=Vector2(float(x*TILE)+TILE*.5,float(y*TILE)+TILE*.5)
        water_body.add_child(c)
        water_count+=1
    valid=water_count==EXPECTED and water_body.get_child_count()==EXPECTED
    if not valid:
        push_error("FS_01_MAZE R8 incomplete water blocker registration")
        return
    print("FS_01_MAZE R8 GODOT WATER CANDIDATE: native 148 StaticBody2D collision rectangles, 32px each, Ground unchanged, RIVER ROUTE/ART HOLD")

func is_river_tile(cell:Vector2i) -> bool:
    return water_cells.has(cell)
