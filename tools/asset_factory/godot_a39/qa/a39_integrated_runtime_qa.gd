extends SceneTree
## Real GPU Godot A39: verify RUN/AI-IDLE/native-rig animation-state changes.

func _initialize() -> void:
    call_deferred("_test")

func _test() -> void:
    var scene: PackedScene = load("res://scenes/battle_animation_preview.tscn")
    assert(scene != null)
    var stage: Node = scene.instantiate()
    root.add_child(stage)
    await process_frame
    var run: FSBattleActorAnimator = stage.get_node("RunActor")
    var idle: FSBattleActorAnimator = stage.get_node("IdleActor")
    assert(run.get_motion() == &"run")
    assert(idle.get_profile() == &"idle_rig")
    assert(not idle.actor_sprite.visible and idle.breath_rig.visible)
    assert(idle.breath_rig.breath_player.has_animation("breathing"))
    var initial: float = idle.breath_rig.get_breath()
    await create_timer(0.72).timeout
    var moving: float = idle.breath_rig.get_breath()
    assert(moving > initial)
    print("A39_BREATH_LIVE_START=" + str(initial) + " LIVE_AFTER_720MS=" + str(moving))
    assert(idle.play_motion(&"idle", &"idle_raw"))
    assert(idle.actor_sprite.visible and not idle.breath_rig.visible)
    assert(idle.actor_sprite.sprite_frames.get_frame_count("idle_raw") == 8)
    assert(idle.play_motion(&"idle", &"idle_calm"))
    assert(idle.get_profile() == &"idle_calm")
    assert(idle.play_motion(&"idle", &"idle_r2"))
    assert(idle.play_motion(&"run", &"run_raw"))
    assert(idle.get_motion() == &"run")
    assert(idle.actor_sprite.sprite_frames.get_frame_count("run_raw") == 8)
    assert(idle.play_motion(&"run", &"run_tuned"))
    assert(idle.play_motion(&"idle", &"idle_rig"))
    assert(not idle.play_motion(&"attack"))
    assert(idle.get_profile() == &"idle_rig")
    assert(not idle.actor_sprite.visible and idle.breath_rig.visible)
    idle.set_playback_multiplier(1.5)
    assert(absf(idle.breath_rig.breath_player.speed_scale - 1.5) < 0.001)
    idle.set_playback_multiplier(1.0)
    # Native rendering of the real battle preview, not a PIL composition.
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = root.get_viewport().get_texture().get_image()
    assert(img.get_size().x >= 1024)
    var outdir: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(outdir)
    var saved: String = outdir.path_join("A39_GODOT_REAL_GPU_RUN_AND_RIG_IDLE.png")
    assert(img.save_png(saved) == OK)
    print("A39_INTEGRATED_RENDERER=" + RenderingServer.get_video_adapter_name())
    print("A39_A38_FIVE_PROFILES_RETAINED=true")
    print("A39_IDLE_RIG_TO_RUN_AND_BACK_PASS=true")
    print("A39_UNSUPPORTED_ATTACK_REJECTED=true")
    print("A39_BATTLE_GPU_SCREENSHOT=" + saved)
    print("A39_GODOT_INTEGRATED_RUNTIME_PASS")
    quit(0)
