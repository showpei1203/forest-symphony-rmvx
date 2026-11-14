extends SceneTree
## Materialize validated 32px Godot TileMapLayer data from an explicit
## A11-bound source annotation; visual candidate, NOT user collision approval.
const SOURCE := "res://data/collision_candidate.json"
const TARGET := "res://scenes/elf_forest_map.tscn"
const TILESET := "res://resources/fs_collision_32.tres"
const MASTER_LOCK := "091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530"

func _initialize() -> void:
    call_deferred("build")

func fail(reason: String) -> void:
    push_error("A30 collision scene builder FAIL: " + reason)
    quit(2)

func build() -> void:
    if not FileAccess.file_exists(SOURCE):
        fail("no collision manifest")
        return
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOURCE))
    if not raw is Dictionary:
        fail("collision manifest not an object")
        return
    var data: Dictionary = raw
    var grid: Array = data.get("grid", [])
    if data.get("ground_sha256", "") != MASTER_LOCK or grid.size() != 2 or int(grid[0]) != 40 or int(grid[1]) != 29 or data.get("status", "") != "CANDIDATE_NOT_USER_COLLISION_APPROVED":
        fail("manifest does not lock exact A11 map / candidate status")
        return
    if FileAccess.get_sha256("res://private_assets/full_ground.png") != MASTER_LOCK:
        fail("current Master SHA differs from collision proposal")
        return
    var atlas_tex: Texture2D = load("res://assets/collision_debug_tile.png") as Texture2D
    if atlas_tex == null:
        fail("public debug atlas failed to import")
        return
    var tileset := TileSet.new()
    tileset.tile_size = Vector2i(32, 32)
    var source := TileSetAtlasSource.new()
    source.texture = atlas_tex
    source.texture_region_size = Vector2i(32, 32)
    tileset.add_source(source, 0)
    source.create_tile(Vector2i.ZERO)
    tileset.add_physics_layer()
    tileset.set_physics_layer_collision_layer(0, 1)
    tileset.set_physics_layer_collision_mask(0, 2)
    var tiledata: TileData = source.get_tile_data(Vector2i.ZERO, 0)
    tiledata.set_collision_polygons_count(0, 1)
    tiledata.set_collision_polygon_points(0, 0, PackedVector2Array([
        Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
    ]))
    if tiledata.get_collision_polygons_count(0) != 1:
        fail("Atlas did not receive physics layer / collision polygon")
        return
    if ResourceSaver.save(tileset, TILESET) != OK:
        fail("could not save TileSet resource")
        return
    tileset.take_over_path(TILESET)  # keep a single editable atlas resource, not duplicated embedded copies
    var original: PackedScene = load(TARGET)
    if original == null:
        fail("original scene missing")
        return
    var root: Node = original.instantiate()
    var layer: TileMapLayer = root.get_node("CollisionPaint") as TileMapLayer
    if layer == null:
        fail("CollisionPaint absent")
        return
    layer.tile_set = tileset
    layer.clear()
    layer.collision_enabled = true
    var count := 0
    for cell in data.get("blocked_tiles", []):
        if not cell is Array or cell.size() != 2:
            fail("invalid cell geometry")
            return
        var point := Vector2i(int(cell[0]), int(cell[1]))
        if point.x < 0 or point.x >= 40 or point.y < 0 or point.y >= 29:
            fail("out-of-bounds cell")
            return
        layer.set_cell(point, 0, Vector2i.ZERO, 0)
        count += 1
    for foot in data.get("safe_footpoints", []):
        var p := Vector2i(int(foot[0])/32, int(foot[1])/32)
        if layer.get_cell_source_id(p) != -1:
            fail("blocked A21 four-foot regression case")
            return
    var packed := PackedScene.new()
    if packed.pack(root) != OK or ResourceSaver.save(packed, TARGET) != OK:
        fail("could not pack or save editable TileMapLayer scene")
        return
    print("A30 GODOT TILEMAP CANDIDATE BUILT: %d painted / 1160 tiles, 4/4 clear A21 footpoint cells" % count)
    root.free()
    quit(0)
