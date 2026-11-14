extends SceneTree
## FS A40 genuine GPU/runtime QA. Attack method-track event, 8 frames, speed, cancel,
## recovery, preservation of A39 RUN/IDLE and real Godot framebuffer screenshots.
var hits: Array[int] = []
var hit_seconds: Array[float] = []
var completes: Array[int] = []
var cancels: Array[int] = []
var failed: bool = false

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, message: String) -> bool:
    if ok:
        print("A40_PASS " + message)
    else:
        failed = true
        push_error("A40_FAIL " + message)
    return ok

func _hit(serial: int, second: float) -> void:
    hits.append(serial)
    hit_seconds.append(second)
    print("A40_HIT_SIGNAL serial=%d hit_sec=%.2f" % [serial,second])

func _finish(serial: int) -> void:
    completes.append(serial)
    print("A40_FINISH_SIGNAL serial=" + str(serial))

func _cancel(serial: int) -> void:
    cancels.append(serial)
    print("A40_CANCEL_SIGNAL serial=" + str(serial))

func _run() -> void:
    var scene: PackedScene = load("res://scenes/battle_animation_preview.tscn")
    if not check(scene != null, "scene-load"):
        quit(1)
        return
    var stage: Node = scene.instantiate()
    root.add_child(stage)
    await process_frame
    var actor: FSBattleActorAnimator = stage.get_node("IdleActor")
    var run: FSBattleActorAnimator = stage.get_node("RunActor")
    actor.attack_hit.connect(_hit)
    actor.attack_finished.connect(_finish)
    actor.attack_cancelled.connect(_cancel)
    check(actor.actor_sprite.sprite_frames.has_animation("attack_slash"), "attack-profile-exists")
    check(actor.actor_sprite.sprite_frames.get_frame_count("attack_slash")==8, "eight-real-attack-frames")
    check(not actor.actor_sprite.sprite_frames.get_animation_loop("attack_slash"), "attack-nonloop")
    check(actor.actor_sprite.sprite_frames.get_frame_count("run_raw")==8, "a35-run-preserved")
    check(actor.actor_sprite.sprite_frames.has_animation("idle_calm"), "a38-idle-preserved")
    check(actor.breath_rig.breath_player.has_animation("breathing"), "a39-native-breath-preserved")
    check(actor.is_motion_supported(&"attack"), "attack-registered")
    check(not actor.is_motion_supported(&"cast"), "cast-remains-unimplemented")
    check(not actor.play_motion(&"cast"), "unsupported-cast-rejected")
    check(actor.play_motion(&"attack", &"attack_slash"), "start-attack")
    check(not actor.play_motion(&"attack", &"attack_slash"), "repeat-attack-blocked")
    check(actor.attack_clock.has_animation("attack_contact"), "method-track-installed")
    check(actor.attack_clock.get_animation("attack_contact").get_track_count()==1, "one-event-track")
    await create_timer(0.24).timeout
    check(hits.size()==0, "no-early-hit-at-240ms")
    await create_timer(0.28).timeout
    check(hits.size()==1, "exactly-one-contact-by-520ms")
    check(actor.get_motion()==&"attack", "contact-before-recovery")
    check(hit_seconds.size()==1 and absf(hit_seconds[0]-0.44)<0.001, "contact-key-at-440ms")
    await create_timer(0.45).timeout
    check(completes.size()==1, "attack-completed-once")
    check(hits.size()==1, "attack-not-looped")
    check(actor.get_motion()==&"idle" and actor.get_profile()==&"idle_rig", "return-to-a39-rig")
    # Speed multiplier must scale SpriteFrames AND AnimationPlayer timing.
    actor.set_playback_multiplier(2.0)
    check(actor.play_motion(&"attack", &"attack_slash"), "start-speed2")
    await create_timer(0.12).timeout
    check(hits.size()==1, "speed2-no-early-hit")
    await create_timer(0.19).timeout
    check(hits.size()==2, "speed2-hit-reached")
    await create_timer(0.20).timeout
    check(completes.size()==2, "speed2-completes")
    check(actor.get_motion()==&"idle", "speed2-return-idle")
    actor.set_playback_multiplier(1.0)
    # A cancelled windup must never cause a delayed phantom hit.
    check(actor.play_motion(&"attack",&"attack_slash"), "start-to-cancel")
    await create_timer(0.10).timeout
    check(actor.play_motion(&"idle",&"idle_rig"), "cancel-to-idle")
    await create_timer(0.55).timeout
    check(hits.size()==2, "cancel-prevents-phantom-hit")
    check(cancels.size()==1, "cancel-signal-once")
    # Paused clock must pause hit logic with the character pose.
    check(actor.play_motion(&"attack",&"attack_slash"), "start-to-pause")
    await create_timer(0.10).timeout
    actor.actor_sprite.pause()
    actor.attack_clock.pause()
    await create_timer(0.50).timeout
    check(hits.size()==2, "paused-attack-has-no-hit")
    actor.actor_sprite.play()
    actor.attack_clock.play()
    await create_timer(0.50).timeout
    check(hits.size()==3, "resumed-attack-hits-once")
    await create_timer(0.32).timeout
    check(completes.size()==3, "resumed-attack-completes")
    # Real GPU capture: every atlas pose is rendered in a Godot SubViewport.
    var outdir: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(outdir)
    var cap := SubViewport.new()
    cap.size = Vector2i(64,64)
    cap.transparent_bg = true
    cap.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(cap)
    var copy_scene: PackedScene = load("res://scenes/actor01.tscn")
    var pose: FSBattleActorAnimator = copy_scene.instantiate()
    pose.initial_motion = &"attack"
    pose.initial_profile = &"attack_slash"
    pose.position = Vector2(32,32)
    cap.add_child(pose)
    await process_frame
    pose.attack_clock.stop()
    pose.actor_sprite.pause()
    var distinct: Dictionary = {}
    for i in range(8):
        pose.actor_sprite.frame = i
        await process_frame
        await RenderingServer.frame_post_draw
        var rendered: Image = cap.get_texture().get_image()
        check(rendered.get_size()==Vector2i(64,64), "frame-size-%d" % i)
        rendered.convert(Image.FORMAT_RGBA8)
        distinct[hash(rendered.get_data())] = true
        check(rendered.save_png(outdir.path_join("A40_NATIVE_GPU_ATTACK_F%02d.png" % i))==OK, "gpu-frame-written-%d" % i)
    check(distinct.size()>=6, "at-least-six-distinct-gpu-poses")
    print("A40_GPU_DISTINCT=" + str(distinct.size()))
    print("A40_RENDERER=" + RenderingServer.get_video_adapter_name())
    # Render full preview as actual GPU scene (not PIL art).
    await process_frame
    await RenderingServer.frame_post_draw
    var full: Image = root.get_viewport().get_texture().get_image()
    check(full.save_png(outdir.path_join("A40_BATTLE_NATIVE_GPU_PREVIEW.png"))==OK, "full-native-gpu-preview")
    check(run.actor_sprite.sprite_frames.get_frame_count("run_raw")==8, "run-unchanged-after-attack")
    if failed:
        print("A40_GODOT_GPU_QA_FAIL")
        quit(1)
    else:
        print("A40_GODOT_GPU_QA_PASS")
        quit(0)