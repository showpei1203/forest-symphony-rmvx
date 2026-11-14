extends SceneTree
## A42 real GPU: 12x Body/Weapon/FX = A41 source RGBA 0px diff. 
## Also prove one-clock F6 hit, 70ms hitstop, pause/cancel/speed2 and toggles.
var failed: Array[String] = []
var hits: Array[int] = []
var hit_frames: Array[int] = []
var stop_started: Array[int] = []
var stop_finished: Array[int] = []
var complete: Array[int] = []
var cancelled: Array[int] = []
var _actor: FSBattleActorAnimator

func gate(ok: bool, label: String) -> void:
    if ok:
        print("A42_PASS " + label)
    else:
        failed.append(label)
        push_error("A42_FAIL " + label)

func _hit(serial: int, _second: float) -> void:
    hits.append(serial)
    hit_frames.append(_actor.get_frame_index())
    print("A42_HIT serial=%d pose=%d" % [serial, _actor.get_frame_index()])

func _stop_start(serial: int, sec: float) -> void:
    stop_started.append(serial)
    gate(absf(sec-0.07)<0.001, "hitstop-duration-contract")

func _stop_end(serial: int) -> void:
    stop_finished.append(serial)

func _finished(serial: int) -> void:
    complete.append(serial)

func _cancel(serial: int) -> void:
    cancelled.append(serial)

func _interrupt_during_hit(_serial: int, _second: float) -> void:
    # A real combat receiver can switch state immediately during hit callback.
    _actor.play_motion(&"idle", &"idle_rig")

func _initialize() -> void:
    call_deferred("_run")

func _gpu_snapshot(cap: SubViewport) -> Image:
    await process_frame
    await RenderingServer.frame_post_draw
    var result: Image = cap.get_texture().get_image()
    result.convert(Image.FORMAT_RGBA8)
    return result

func _check_2d_equal(a: Image, atlas: Image, frame: int) -> int:
    var bad: int = 0
    for y in range(64):
        for x in range(64):
            if a.get_pixel(x,y) != atlas.get_pixel((frame%4)*64+x,int(frame/4)*64+y):
                bad += 1
    return bad

func _run() -> void:
    var project: PackedScene = load("res://scenes/battle_animation_preview.tscn")
    gate(project != null, "preview-scene-load")
    if project == null:
        quit(1)
        return
    var stage: Node = project.instantiate()
    root.add_child(stage)
    await process_frame
    _actor = stage.get_node("IdleActor")
    var runner: FSBattleActorAnimator = stage.get_node("RunActor")
    _actor.attack_hit.connect(_hit)
    _actor.hitstop_started.connect(_stop_start)
    _actor.hitstop_finished.connect(_stop_end)
    _actor.attack_finished.connect(_finished)
    _actor.attack_cancelled.connect(_cancel)
    gate(_actor.breath_rig.breath_player.has_animation("breathing"),"a39-breath-retained")
    gate(runner.actor_sprite.sprite_frames.get_frame_count("run_raw")==8,"a35-run-eight-retained")
    gate(_actor.actor_sprite.sprite_frames.has_animation("idle_calm"),"a38-idle-retained")
    gate(_actor.actor_sprite.sprite_frames.get_frame_count("attack_weighted")==12,"a42-body-twelve")
    gate(_actor.weapon_sprite.sprite_frames.get_frame_count("attack_weighted")==12,"a42-weapon-twelve")
    gate(_actor.fx_sprite.sprite_frames.get_frame_count("attack_weighted")==12,"a42-fx-twelve")
    var clock_animation: Animation = _actor.attack_clock.get_animation("attack_contact")
    gate(clock_animation.get_track_count()==4,"one-clock-three-frames-and-hit-method")
    gate(not _actor.play_motion(&"hurt"),"unsupported-hurt-not-faked")
    gate(_actor.play_motion(&"attack"),"start-attack")
    gate(_actor.weapon_sprite.visible and _actor.fx_sprite.visible,"three-layers-rendered")
    gate(not _actor.play_motion(&"attack"),"block-double-start")
    await create_timer(0.43).timeout
    gate(hits.is_empty(),"no-premature-hit")
    # Wait for the REAL engine event; fixed sleep near the 0.55s key is frame-jitter-prone.
    await _actor.hitstop_started
    gate(hits.size()==1 and hit_frames[0]==6,"contact-one-at-f6")
    gate(stop_started.size()==1,"hitstop-started-once")
    gate(_actor.attack_clock.speed_scale==0.0,"animation-clock-frozen")
    gate(_actor.get_frame_index()==6,"hitstop-freezes-contact-pose")
    await _actor.hitstop_finished
    gate(stop_finished.size()==1,"hitstop-released")
    gate(_actor.attack_clock.speed_scale>0.0,"clock-resumed-after-hitstop")
    await create_timer(0.52).timeout
    gate(complete.size()==1 and _actor.get_profile()==&"idle_rig","restore-idle")
    gate(not _actor.weapon_sprite.visible and not _actor.fx_sprite.visible,"layers-hidden-in-idle")
    gate(hits.size()==1,"no-repeated-hit")
    _actor.set_playback_multiplier(2.0)
    gate(_actor.play_motion(&"attack"),"start-speed2")
    await create_timer(0.18).timeout
    gate(hits.size()==1,"speed2-windup-no-hit")
    await create_timer(0.18).timeout
    gate(hits.size()==2 and hit_frames[1]==6,"speed2-hit-f6")
    await create_timer(0.34).timeout
    gate(complete.size()==2,"speed2-completed")
    _actor.set_playback_multiplier(1.0)
    gate(_actor.play_motion(&"attack"),"start-cancel")
    await create_timer(0.14).timeout
    gate(_actor.play_motion(&"idle",&"idle_rig"),"cancel-to-idle")
    await create_timer(0.62).timeout
    gate(hits.size()==2 and cancelled.size()==1,"no-ghost-hit-after-cancel")
    gate(_actor.play_motion(&"attack"),"start-pause")
    await create_timer(0.12).timeout
    _actor.attack_clock.pause()
    await create_timer(0.56).timeout
    gate(hits.size()==2,"manual-pause-no-hit")
    _actor.attack_clock.play()
    await create_timer(0.57).timeout
    gate(hits.size()==3 and hit_frames[2]==6,"resume-hit-f6")
    await create_timer(0.58).timeout
    gate(complete.size()==3,"resume-complete")
    gate(stop_started.size()==3 and stop_finished.size()==3,"one-hitstop-per-successful-strike")
    # Interrupt the actor FROM INSIDE the hit callback, not only before contact.
    var interrupt: Callable = Callable(self, "_interrupt_during_hit")
    _actor.attack_hit.connect(interrupt)
    gate(_actor.play_motion(&"attack"),"start-immediate-hit-interrupt")
    await _actor.attack_hit
    await process_frame
    gate(_actor.get_motion()==&"idle", "immediate-hit-interrupt-returns-to-idle")
    gate(not _actor.weapon_sprite.visible and not _actor.fx_sprite.visible, "interrupt-hides-layers")
    gate(stop_started.size()==3, "interrupt-does-not-freeze-idle")
    _actor.attack_hit.disconnect(interrupt)

    # Verify all three visible sprites produce exactly the approved A41 atlas
    # INSIDE native OpenGL SubViewport, not an external PIL approximation.
    var baseline: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/actor01_attack_weighted_sword_12frames.png"))
    baseline.convert(Image.FORMAT_RGBA8)
    var cap := SubViewport.new()
    cap.size=Vector2i(64,64)
    cap.transparent_bg=true
    cap.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(cap)
    var subject_scene: PackedScene=load("res://scenes/actor01.tscn")
    var subject: FSBattleActorAnimator=subject_scene.instantiate()
    subject.position=Vector2(32,32)
    cap.add_child(subject)
    await process_frame
    gate(subject.play_motion(&"attack"),"native-capture-attack")
    subject.attack_clock.stop()
    var folder: String=ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(folder)
    var unique: Dictionary={}
    var full_frame: Image
    var all_diffs: Array[int]=[]
    for i in range(12):
        subject.actor_sprite.frame=i
        subject.weapon_sprite.frame=i
        subject.fx_sprite.frame=i
        var render: Image=await _gpu_snapshot(cap)
        var changed: int=_check_2d_equal(render,baseline,i)
        all_diffs.append(changed)
        gate(changed==0,"gpu-three-layer-rgba-identical-f%d"%i)
        unique[hash(render.get_data())]=true
        var edges: int=0
        for x in range(64):
            if render.get_pixel(x,0).a8>0 or render.get_pixel(x,63).a8>0:
                edges+=1
        for y in range(64):
            if render.get_pixel(0,y).a8>0 or render.get_pixel(63,y).a8>0:
                edges+=1
        gate(edges==0,"no-gpu-crop-f%d"%i)
        gate(render.save_png(folder.path_join("A42_NATIVE_GPU_ALL_LAYERS_F%02d.png"%i))==OK,"gpu-save-frame-%d"%i)
        if i==6:
            full_frame=render.duplicate()
            subject.set_fx_enabled(false)
            var no_fx: Image=await _gpu_snapshot(cap)
            gate(no_fx.get_data()!=full_frame.get_data(),"fx-toggle-changes-pixels")
            gate(no_fx.save_png(folder.path_join("A42_GPU_NO_FX_F06.png"))==OK,"gpu-no-fx-saved")
            subject.set_weapon_enabled(false)
            var body_only: Image=await _gpu_snapshot(cap)
            gate(body_only.get_data()!=no_fx.get_data(),"weapon-toggle-changes-pixels")
            gate(body_only.save_png(folder.path_join("A42_GPU_BODY_ONLY_F06.png"))==OK,"gpu-body-only-saved")
            subject.set_weapon_enabled(true)
            subject.set_fx_enabled(true)
            var restored: Image=await _gpu_snapshot(cap)
            gate(restored.get_data()==full_frame.get_data(),"fx-weapon-toggle-roundtrip-exact")
    gate(unique.size()==11,"eleven-distinct-native-compositions")
    print("A42_GPU_RGBA_DIFFS="+JSON.stringify(all_diffs))
    print("A42_GPU_UNIQUE="+str(unique.size()))
    print("A42_GPU_RENDERER="+RenderingServer.get_video_adapter_name())
    gate(runner.get_motion()==&"run","original-run-still-live")
    # Actual 1024x720 in-battle frame, not python composite.
    gate(_actor.play_motion(&"attack"),"battle-scene-hit-preview-start")
    await create_timer(0.57).timeout
    await RenderingServer.frame_post_draw
    var view: Image=root.get_viewport().get_texture().get_image()
    gate(view.save_png(folder.path_join("A42_REAL_GPU_BATTLE_CONTACT.png"))==OK,"battle-scene-real-gpu-screenshot")
    if failed.is_empty():
        print("A42_REAL_GPU_RUNTIME_PASS")
        quit(0)
    else:
        print("A42_REAL_GPU_RUNTIME_FAIL "+JSON.stringify(failed))
        quit(1)