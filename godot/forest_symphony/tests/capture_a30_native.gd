extends SceneTree
## Native real-source Godot 4.7.2 screenshots, no raster mock.
var checks := 0
func _initialize() -> void:
    call_deferred("capture")

func screenshot(path: String) -> void:
    await process_frame
    await process_frame
    var shot: Image = get_root().get_texture().get_image()
    if shot.get_size() != Vector2i(544,416) or shot.save_png(path) != OK:
        push_error("A30 screenshot invalid: "+path)
        quit(1)
        return
    checks += 1
    print("A30 NATIVE GL SCREENSHOT ",path," SIZE ",shot.get_size())

func capture() -> void:
    var packed: PackedScene = load("res://scenes/elf_forest_map.tscn")
    var scene: Node2D = packed.instantiate()
    get_root().add_child(scene)
    var player = scene.get_node("Characters/Player")
    var collision: TileMapLayer = scene.get_node("CollisionPaint")
    scene.get_node("HUD").visible = false
    var dest := OS.get_environment("FS_A30_CAPTURE_DIR")
    if dest.is_empty():dest = "/mnt/data/fs_godot_a30/qa"
    DirAccess.make_dir_recursive_absolute(dest)
    await process_frame
    await process_frame
    # Freeze physics ONLY for controlled stills, so A62 frame selection remains visible.
    player.set_physics_process(false)
    player.position = Vector2(232,556)
    player._set_visual(1)
    player.refresh_occlusion()
    await screenshot(dest.path_join("GODOT_472_A30_A62_RUN2_TREE_BEHIND.png"))
    player.position = Vector2(735,670)
    player._set_visual(2)
    player.refresh_occlusion()
    await screenshot(dest.path_join("GODOT_472_A30_A62_RUN3_BRIDGE_FRONT.png"))
    player._set_visual(-1)
    player.position = Vector2(304,656)
    collision.modulate = Color.WHITE
    player.refresh_occlusion()
    await screenshot(dest.path_join("GODOT_472_A30_PAINTED_COLLISION_1X.png"))
    collision.modulate = Color(1,1,1,0)
    player.position = Vector2(565,490)
    player.refresh_occlusion()
    await screenshot(dest.path_join("GODOT_472_A30_FULL_MAP_CENTER_PATH_1X.png"))
    player.position = Vector2(735,670)
    for i in range(12):
        player._set_visual([0,1,0,2][i%4])
        player.refresh_occlusion()
        await screenshot(dest.path_join("A30_NATIVE_LOOP_%02d.png" % i))
    print("A30 native screenshot PASS %d frames" % checks)
    quit(0)
