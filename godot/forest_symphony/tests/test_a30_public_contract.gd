extends SceneTree
## Public source-only Godot 4.7.2 CI; private A11/A62 PNGs are absent.
## Contract checks scene editability, actual tile physics shapes and 32px grid.
const MANIFEST := "res://data/collision_candidate.json"
const MASTER_LOCK := "091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530"
var checks := 0
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures.append(label)
        push_error("A30 PUBLIC FAIL: " + label)

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if not doc is Dictionary:
        push_error("A30 PUBLIC missing collision JSON")
        quit(1)
        return
    check(doc.get("ground_sha256","") == MASTER_LOCK, "locked real A11 Master; never borrow A10 collision map")
    check(doc.get("status","") == "CANDIDATE_NOT_USER_COLLISION_APPROVED", "not promoted to approved collision")
    check(int(doc["grid"][0]) == 40 and int(doc["grid"][1]) == 29 and int(doc["tile_px"]) == 32, "40x29 32px map geometry")
    var packed: PackedScene = load("res://scenes/elf_forest_map.tscn")
    check(packed != null, "Godot PackedScene public code imports")
    if packed == null:
        quit(1)
        return
    var root: Node2D = packed.instantiate() as Node2D
    check(root != null, "true scene instance")
    if root == null:
        quit(1)
        return
    var layer: TileMapLayer = root.get_node("CollisionPaint") as TileMapLayer
    check(layer != null, "Godot editable TileMapLayer present")
    check(layer.is_collision_enabled(), "physics enabled on tile layer")
    check(layer.tile_set != null, "editor-editable external TileSet resource")
    check(layer.tile_set.tile_size == Vector2i(32,32), "32px tileset")
    check(layer.tile_set.resource_path == "res://resources/fs_collision_32.tres", "no detached duplicate embedded tileset")
    check(layer.tile_set.get_physics_layers_count() == 1, "TileSet one physics layer")
    check(layer.tile_set.get_physics_layer_collision_layer(0) == 1, "environment collision bit 1")
    var atlas: TileSetAtlasSource = layer.tile_set.get_source(0) as TileSetAtlasSource
    check(atlas != null, "public procedural debug atlas")
    if atlas != null:
        var tiledata: TileData = atlas.get_tile_data(Vector2i.ZERO,0)
        check(tiledata.get_collision_polygons_count(0) == 1, "real Godot physics polygon, not visual-only marker")
        check(tiledata.get_collision_polygon_points(0,0).size() == 4, "32px blocking polygon four vertices")
    var blocked: Array = doc.get("blocked_tiles",[])
    check(blocked.size() == 180, "180 conservative visual collision candidates")
    check(layer.get_used_cells().size() == blocked.size(), "all JSON candidates exist in editor scene")
    var visited := {}
    for pair in blocked:
        var cell := Vector2i(int(pair[0]),int(pair[1]))
        check(cell.x>=0 and cell.x<40 and cell.y>=0 and cell.y<29, "candidate in map bounds")
        check(layer.get_cell_source_id(cell)==0, "candidate cell painted at expected world XY")
        visited[cell]=true
    var foots: Array = doc.get("safe_footpoints",[])
    check(foots.size()==4, "four A21 regression footpoint witnesses defined")
    for xy in foots:
        check(not visited.has(Vector2i(int(xy[0])/32,int(xy[1])/32)), "A21 footpoint tile not blocked")
    # Candidate free-cell connectivity is a design sanity check only. It does
    # not certify every unpainted tile walkable.
    var start := Vector2i(int(foots[0][0])/32,int(foots[0][1])/32)
    var open: Array[Vector2i] = [start]
    var seen := {start:true}
    var pos := 0
    while pos<open.size():
        var cell: Vector2i = open[pos]
        pos += 1
        for nxt in [cell+Vector2i.LEFT,cell+Vector2i.RIGHT,cell+Vector2i.UP,cell+Vector2i.DOWN]:
            if nxt.x<0 or nxt.x>=40 or nxt.y<0 or nxt.y>=29 or seen.has(nxt) or visited.has(nxt):continue
            seen[nxt]=true
            open.append(nxt)
    check(open.size() == 1160-blocked.size(), "all candidate free cells are 4-neighbor connected")
    for xy in foots:
        check(seen.has(Vector2i(int(xy[0])/32,int(xy[1])/32)), "A21 witness reachable in candidate graph")
    check(root.get_node_or_null("Characters/Player") != null, "Player and overlay hierarchy retained")
    check(root.get_node_or_null("Occluders/LeftTree") != null, "original-XY PAR objects retained")
    root.free()
    if not failures.is_empty():
        print("A30 PUBLIC GODOT FAIL: %s" % str(failures))
        quit(1)
    else:
        print("A30 GODOT PUBLIC CI PASS: %d checks | 180 collision CANDIDATES | 980 candidate free cells connected | original art PRIVATE" % checks)
        quit(0)
