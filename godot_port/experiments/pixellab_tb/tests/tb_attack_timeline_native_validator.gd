extends SceneTree
## Run: Godot 4.7.2 --headless --path . --script res://tests/tb_attack_timeline_native_validator.gd
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var player := preload("res://tb_attack_timeline.gd").new()
    get_root().add_child(player)
    await process_frame
    var events: Array[String] = []
    player.rush_started.connect(func(i: int): events.append("R%d" % i))
    player.hit_requested.connect(func(i: int, p: Vector2): events.append("H%d" % i))
    player.return_started.connect(func(i: int): events.append("T%d" % i))
    player.attack_completed.connect(func(): events.append("DONE"))
    if not player.play_attack():
        push_error("cannot start attack")
        quit(1)
        return
    player.advance_seconds(1.0) # frame drop: every marker must still emit once
    if events != ["R2", "H5", "T7", "DONE"]:
        push_error("event order/missed hit: %s" % events)
        quit(2)
        return
    if player.frame_index != 10 or player.active:
        push_error("final frame / one-shot end state incorrect")
        quit(3)
        return
    events.clear()
    player.play_attack()
    player.advance_seconds(0.09)
    player.cancel_attack()
    player.advance_seconds(1.0)
    if not events.is_empty():
        push_error("canceled attack emitted game event: %s" % events)
        quit(4)
        return
    events.clear()
    player.play_attack()
    for i in 30:
        player.advance_seconds(1.0/60.0)
    if events != ["R2", "H5", "T7", "DONE"]:
        push_error("normal playback event order incorrect: %s" % events)
        quit(5)
        return
    print("TB_TIMELINE_NATIVE_PASS 4.7.2 events=R2,H5,T7,DONE fast_forward=pass cancel=pass 60hz=pass")
    quit(0)
