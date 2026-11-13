extends SceneTree
## Real Godot 4.7.2 native A11 Master + A62 motion + TileMapLayer collision.
## Hard fail on source mismatch or A27 pixel-parity drift. Art and collision are HOLD.
const CollisionJson := "res://data/collision_candidate.json"
const Overlay := preload("res://scripts/fs_occlusion.gd")
var checks := 0
var errors: Array[String] = []

func verify(ok: bool, caption: String) -> void:
    checks += 1
    if not ok:
        errors.append(caption)
        push_error("A30 NATIVE TEST FAIL: "+ caption)

func _initialize() -> void:
    call_deferred("execute")

func execute() -> void:
    var scene: PackedScene = load("res://scenes/elf_forest_map.tscn")
    verify(scene != null, "Godot PackedScene loaded")
    if scene == null:
        quit(1)
        return
    var tree: Node2D = scene.instantiate() as Node2D
    get_root().add_child(tree)
    for i in 3:
        await physics_frame
    var collision: TileMapLayer = tree.get_node("CollisionPaint")
    var actor = tree.get_node("Characters/Player")
    verify(collision.tile_set != null, "TileSet assigned")
    verify(collision.tile_set.get_physics_layers_count() == 1, "TileSet physics 1 layer")
    verify(collision.tile_set.get_physics_layer_collision_layer(0) == 1, "environment collision layer bit1")
    verify(collision.tile_set.get_physics_layer_collision_mask(0) == 2, "environment collision mask bit2")
    verify(collision.tile_set.get_source(0).get_tile_data(Vector2i.ZERO,0).get_collision_polygons_count(0) == 1, "collision atlas polygon exists")
    verify(collision.get_used_cells().size() == 180, "180 candidate tiles actually painted")
    verify(collision.is_collision_enabled(), "physical collision enabled independent of rendering")
    verify(collision.modulate.a < 0.001, "collision markers hidden during actual play")
    var cjson: Variant = JSON.parse_string(FileAccess.get_file_as_string(CollisionJson))
    verify(cjson is Dictionary and cjson['ground_sha256'] == FileAccess.get_sha256("res://private_assets/full_ground.png"), "collision data locks exact A11 Master SHA")
    verify(cjson['status'] == 'CANDIDATE_NOT_USER_COLLISION_APPROVED', "collision not mislabeled as approved")
    verify(collision.get_used_cells().size() == cjson['blocked_tiles'].size(), "candidate JSON matches painted scene count")
    for item in cjson['blocked_tiles']:
        verify(collision.get_cell_source_id(Vector2i(int(item[0]),int(item[1]))) == 0, "painted tile x=%s y=%s" % [item[0],item[1]])
    var cases := [
        [Vector2i(232,556),197],
        [Vector2i(232,596),0],
        [Vector2i(735,621),29],
        [Vector2i(735,670),0],
    ]
    for item in cases:
        var f: Vector2i = item[0]
        verify(collision.get_cell_source_id(Vector2i(int(f.x/32),int(f.y/32))) == -1, "A21 witness unblocked %s" % str(f))
        actor.position = Vector2(f.x,f.y)
        actor._set_visual(-1)
        actor.refresh_occlusion()
        verify(Overlay.opaque_count(actor.last_overlay_cpu) == item[1], "A27 original SAME-XY PAR for %s" % str(f))
    verify(actor.run_frames.size()==3, "A62 exact 3 approved battle frame PNGs imported")
    verify(actor.run_frames[0].get_size() == Vector2i(48,48), "native 48px A62 frame size")
    actor.position = Vector2(232,556)
    var signatures: Array[String] = []
    for frame_index in [-1,1,2]:
        actor._set_visual(frame_index)
        actor.refresh_occlusion()
        signatures.append(actor.last_overlay_cpu.save_png_to_buffer().hex_encode())
    verify(signatures[0] != signatures[1] or signatures[0] != signatures[2], "frame-changed actor alpha forces actual PAR cache refresh")
    actor._set_visual(-1)
    actor.refresh_occlusion()
    var space: PhysicsDirectSpaceState2D = tree.get_world_2d().direct_space_state
    var query := PhysicsPointQueryParameters2D.new()
    query.collision_mask = 1
    query.collide_with_bodies = true
    for tile in [[8,23],[10,20],[28,7],[39,6]]:
        var v := Vector2i(tile[0],tile[1])
        verify(collision.get_cell_source_id(v) == 0, "water/house candidate selected %s" % str(v))
        query.position = collision.map_to_local(v)
        verify(not space.intersect_point(query,8).is_empty(), "PhysicsServer real obstacle %s" % str(v))
    for witness in [Vector2(232,556),Vector2(232,596),Vector2(735,621),Vector2(735,670)]:
        query.position = witness
        verify(space.intersect_point(query,8).is_empty(), "physics leaves verified A21 witness unblocked %s" % str(witness))
    # Actual native CharacterBody2D sweep into TileMapLayer candidate bank.
    actor.position = Vector2(304,656) # tile 9,20 clear; (10,20) candidate blocked
    actor.velocity = Vector2.ZERO
    await physics_frame
    var hit = actor.move_and_collide(Vector2(80,0))
    verify(hit != null, "CharacterBody2D collides with candidate pond tile")
    verify(actor.position.x < 320.0, "CharacterBody2D cannot pass tiled water collision core")
    # Restore legal central path before animation tests.
    actor.position = Vector2(232,596)
    actor._set_visual(-1)
    actor.refresh_occlusion()
    var visited := {}
    Input.action_press("fs_move_right")
    for step in 47:
        await physics_frame
        if actor.display_id >= 0:
            visited[actor.display_id] = true
    Input.action_release("fs_move_right")
    await physics_frame
    verify(visited.has(0) and visited.has(1) and visited.has(2), "A62 3 actual frames played by native movement")
    verify(actor.display_id == -1, "idle returns to approved F0 after movement")
    verify(actor.get_node("Camera2D").is_current(), "native camera still follows")
    verify(actor.last_foot.x > 232, "updated overlay tracks actor position and animation")
    if not errors.is_empty():
        print("A30 GODOT NATIVE FAIL %d/%d: %s" % [errors.size(),checks,str(errors)])
        quit(1)
    else:
        print("A30 GODOT NATIVE PASS %d checks | 180 collision CANDIDATES | 4/4 original PAR parity | A62 3-frame actual motion | ART HOLD" % checks)
        quit(0)
