extends SceneTree
const DEFAULT_PATH := "res://assets/monsters/tb/PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png"
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var atlas := OS.get_environment("TB_PRIVATE_ATLAS")
    if atlas == "": atlas = DEFAULT_PATH
    var player = preload("res://tb_attack_timeline.gd").new()
    player.texture_path = atlas
    get_root().add_child(player)
    player.set_process(false)
    await process_frame
    if player.sprite == null:
        push_error("PRIVATE_ATLAS_NOT_IMPORTED: " + atlas)
        quit(21)
        return
    if player.sprite.sprite_frames.get_frame_count("attack") != 11:
        push_error("BAD_FRAME_COUNT")
        quit(22)
        return
    var ev: Array[String] = []
    player.rush_started.connect(func(i: int): ev.append("R%d" % i))
    player.hit_requested.connect(func(i: int, _loc: Vector2): ev.append("H%d" % i))
    player.return_started.connect(func(i: int): ev.append("T%d" % i))
    player.attack_completed.connect(func(): ev.append("DONE"))
    player.play_attack()
    player.advance_seconds(1.0)
    if ev != ["R2", "H5", "T7", "DONE"] or player.frame_index != 10:
        push_error("TIMELINE_EVENT_FAIL: %s" % ev)
        quit(23)
        return
    player.play_attack()
    player.advance_seconds(5.0 / 60.0)
    player.cancel_attack()
    ev.clear()
    player.advance_seconds(0.5)
    if not ev.is_empty() or player.frame_index != 0:
        push_error("CANCEL_BROKEN")
        quit(24)
        return
    print("TB_V6_REAL_GODOT_472_NATIVE_SCRIPT_PASS 11F R2/H5/T7 exact-once cancel; TECH_ONLY")
    quit(0)
