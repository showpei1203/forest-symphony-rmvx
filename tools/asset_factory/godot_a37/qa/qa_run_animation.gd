extends SceneTree
## GPU-backed A37 validation, not a headless dummy renderer.

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://scenes/battle_run_preview.tscn")
    if scene == null:
        push_error("A37 failed to load scene")
        quit(2)
        return
    var stage: Node = scene.instantiate()
    root.add_child(stage)
    await process_frame
    var actor: FSBattleActorAnimator = stage.get_node("Actor01")
    var sprite: AnimatedSprite2D = actor.actor_sprite
    assert(sprite.sprite_frames != null)
    assert(sprite.sprite_frames.get_frame_count("run_raw") == 8)
    assert(sprite.sprite_frames.get_frame_count("run_tuned") == 8)
    assert(sprite.sprite_frames.get_animation_speed("run_tuned") == 10.0)
    assert(sprite.sprite_frames.get_animation_speed("run_raw") == 8.0)
    assert(not actor.is_motion_supported(&"idle"))
    assert(not actor.play_motion(&"attack", &"run_tuned"))
    assert(actor.play_motion(&"run", &"run_tuned"))
    var progress: Array[int] = []
    sprite.frame_changed.connect(func() -> void: progress.append(sprite.frame))
    await create_timer(2.1).timeout
    assert(progress.size() >= 15)
    var wraps: int = 0
    for i in range(progress.size() - 1):
        var expected: int = (progress[i] + 1) % 8
        assert(progress[i + 1] == expected)
        if progress[i + 1] == 0:
            wraps += 1
    assert(wraps >= 2)
    assert(actor.play_motion(&"run", &"run_raw"))
    await create_timer(0.25).timeout
    assert(actor.get_profile() == &"run_raw")
    var outdir := ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(outdir)
    assert(actor.play_motion(&"run", &"run_tuned"))
    await RenderingServer.frame_post_draw
    var viewport_image: Image = root.get_viewport().get_texture().get_image()
    var snapshot_path := outdir.path_join("A37_GODOT_REAL_GPU_BATTLE_RUN.png")
    var saved: Error = viewport_image.save_png(snapshot_path)
    assert(saved == OK)
    assert(viewport_image.get_size().x >= 1024)
    assert(viewport_image.get_size().y >= 720)
    print("A37_RENDERER=" + RenderingServer.get_video_adapter_name())
    print("A37_SPRITE_SHEET_SIZE=" + str(actor.sprite_sheet.get_size()))
    print("A37_RUN_EVENT_COUNT=" + str(progress.size()))
    print("A37_RUN_WRAP_COUNT=" + str(wraps))
    print("A37_RUN_EVENTS=" + JSON.stringify(progress))
    print("A37_PROFILE_SWITCH_PASS=true")
    print("A37_MISSING_STATES_REJECTED=true")
    print("A37_GPU_SNAPSHOT=" + snapshot_path)
    print("A37_GODOT_RUNTIME_PASS")
    quit(0)
