extends SceneTree
## Runs the actual PRIVATE PMD0001 V5 384x288 sprite under official Godot 4.7.2.
## Tests event semantics and texture import. Never equate this with Art PASS.
const ATLAS := "res://assets/monsters/tb/PMD0001_ATTACK_V5_11F_384x288.png"
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var player = preload("res://tb_attack_timeline.gd").new()
    player.texture_path = ATLAS
    get_root().add_child(player)
    player.set_process(false)
    await process_frame
    if player.sprite == null:
        push_error("private V5 sprite missing")
        quit(11)
        return
    if player.sprite.sprite_frames.get_frame_count("attack") != 11:
        push_error("real private frame count wrong")
        quit(12)
        return
    var ev: Array[String] = []
    player.rush_started.connect(func(i: int): ev.append("R%d" % i))
    player.hit_requested.connect(func(i: int, loc: Vector2): ev.append("H%d" % i))
    player.return_started.connect(func(i: int): ev.append("T%d" % i))
    player.attack_completed.connect(func(): ev.append("DONE"))
    player.play_attack()
    player.advance_seconds(1.0)
    if ev != ["R2","H5","T7","DONE"] or player.frame_index != 10:
        push_error("private V5 60fps skip incorrect %s" % ev)
        quit(13)
        return
    player.advance_seconds(5.0)
    if ev.size() != 4:
        push_error("private V5 emitted event twice")
        quit(14)
        return
    player.play_attack()
    player.advance_seconds(5.0/60.0)
    player.cancel_attack()
    ev.clear()
    player.advance_seconds(1.0)
    if not ev.is_empty() or player.frame_index != 0:
        push_error("cancel mutation %s" % ev)
        quit(15)
        return
    print("TB_V5_REAL_NATIVE_PASS 4.7.2 real atlas 384x288 11F R2/H5/T7 exact_once cancel")
    quit(0)
