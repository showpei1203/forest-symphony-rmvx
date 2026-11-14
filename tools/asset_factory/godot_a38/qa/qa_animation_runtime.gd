extends SceneTree
## GPU-backed, actual Godot 4.7 AnimatedSprite2D runtime QA.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var sc: PackedScene = load("res://scenes/battle_animation_preview.tscn")
    assert(sc != null)
    var stage: Node = sc.instantiate()
    root.add_child(stage)
    await process_frame
    var run: FSBattleActorAnimator = stage.get_node("RunActor")
    var idle: FSBattleActorAnimator = stage.get_node("IdleActor")
    assert(run != null and idle != null)
    assert(run.get_motion() == &"run" and idle.get_motion() == &"idle")
    for profile in ["run_raw", "run_tuned", "idle_raw", "idle_r2", "idle_calm"]:
        var bank: SpriteFrames = idle.actor_sprite.sprite_frames
        assert(bank.has_animation(profile))
        assert(bank.get_frame_count(profile) == 8)
        print("A38_ANIMATION_PRESENT " + profile + " FPS=" + str(bank.get_animation_speed(profile)))
    assert(idle.is_motion_supported(&"idle"))
    assert(idle.is_motion_supported(&"run"))
    assert(not idle.is_motion_supported(&"attack"))
    assert(not idle.play_motion(&"attack"))
    assert(not idle.play_motion(&"run", &"idle_raw"))
    assert(idle.get_motion() == &"idle")
    assert(idle.play_motion(&"idle", &"idle_calm"))
    var events: Array[int] = []
    idle.actor_sprite.frame_changed.connect(func() -> void: events.append(idle.actor_sprite.frame))
    await create_timer(5.3).timeout
    assert(events.size() >= 12)
    var wraps: int = 0
    for i in range(events.size() - 1):
        assert(events[i+1] == (events[i] + 1) % 8)
        if events[i+1] == 0:
            wraps += 1
    assert(wraps >= 1)
    assert(idle.play_motion(&"idle", &"idle_r2"))
    assert(idle.get_profile() == &"idle_r2")
    assert(idle.play_motion(&"idle", &"idle_raw"))
    assert(idle.get_profile() == &"idle_raw")
    assert(run.set_profile(&"run_raw"))
    assert(run.get_profile() == &"run_raw")
    assert(run.set_profile(&"run_tuned"))
    assert(idle.play_motion(&"idle", &"idle_calm"))
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_viewport().get_texture().get_image()
    var folder: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(folder)
    var out: String = folder.path_join("A38_GODOT_REAL_GPU_RUN_AND_IDLE.png")
    assert(image.save_png(out) == OK)
    assert(image.get_size().x >= 1024 and image.get_size().y >= 720)
    print("A38_RENDERER=" + RenderingServer.get_video_adapter_name())
    print("A38_IDLE_EVENT_COUNT=" + str(events.size()))
    print("A38_IDLE_LOOP_WRAPS=" + str(wraps))
    print("A38_IDLE_FRAME_EVENTS=" + JSON.stringify(events))
    print("A38_UNSUPPORTED_ATTACK_REJECTED=true")
    print("A38_FIVE_PROFILES_PRESENT=true")
    print("A38_PROFILE_SWITCH_PASS=true")
    print("A38_GPU_SNAPSHOT=" + out)
    print("A38_GODOT_RUNTIME_PASS")
    quit(0)
