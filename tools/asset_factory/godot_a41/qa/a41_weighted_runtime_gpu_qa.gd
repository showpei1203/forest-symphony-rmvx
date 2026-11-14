extends SceneTree
## FS A41: actual Godot 4.7.2 OpenGL GPU verification of 12-keypose attack,
## exact source palette/alpha, hit contract at contact frame, cancel/pause/resume,
## actor-relative hit anchor, and old RUN/IDLE/rig preservation.
var failures: Array[String] = []
var hit_times: Array[float] = []
var hit_frames: Array[int] = []
var hit_serials: Array[int] = []
var anchors: Array[Vector2] = []
var complete_serials: Array[int] = []
var cancelled_serials: Array[int] = []
var dummy_hits: int = 0
var _actor: FSBattleActorAnimator
var _target: Vector2

func _initialize() -> void:
    call_deferred("_run")

func gate(ok: bool, label: String) -> void:
    if ok:
        print("A41_PASS " + label)
    else:
        failures.append(label)
        push_error("A41_FAIL " + label)

func _hit(serial: int, when: float) -> void:
    hit_times.append(when)
    hit_frames.append(_actor.get_frame_index())
    hit_serials.append(serial)
    print("A41_HIT serial=%d t=%.2f actor_frame=%d" % [serial, when, _actor.get_frame_index()])

func _anchor(serial: int, local: Vector2, world: Vector2) -> void:
    anchors.append(local)
    if world.distance_to(_target) <= 0.01:
        # Only a stand-in hit receiver to prove anchor, NOT migrated FS damage.
        dummy_hits += 1
    gate(local == Vector2(28,11), "contact-local-anchor-" + str(serial))
    gate(world.distance_to(_actor.to_global(local)) <= 0.01, "contact-world-transform-" + str(serial))

func _finish(serial: int) -> void:
    complete_serials.append(serial)

func _cancel(serial: int) -> void:
    cancelled_serials.append(serial)

func _run() -> void:
    var packed: PackedScene = load("res://scenes/battle_animation_preview.tscn")
    gate(packed != null, "preview-scene-load")
    if packed == null:
        quit(1)
        return
    var stage: Node = packed.instantiate()
    root.add_child(stage)
    await process_frame
    _actor = stage.get_node("IdleActor")
    var runner: FSBattleActorAnimator = stage.get_node("RunActor")
    _target = _actor.to_global(_actor.attack_marker.position)
    _actor.attack_hit.connect(_hit)
    _actor.attack_contact_anchor.connect(_anchor)
    _actor.attack_finished.connect(_finish)
    _actor.attack_cancelled.connect(_cancel)
    gate(_actor.get_motion()==&"idle", "a39-idle-initial")
    gate(_actor.breath_rig.breath_player.has_animation("breathing"), "a39-native-rig")
    gate(_actor.actor_sprite.sprite_frames.get_frame_count("run_raw")==8, "a35-run-eight-kept")
    gate(_actor.actor_sprite.sprite_frames.has_animation("idle_calm"), "a38-idle-kept")
    gate(_actor.actor_sprite.sprite_frames.get_frame_count("attack_weighted")==12, "a41-twelve-frames")
    gate(not _actor.actor_sprite.sprite_frames.get_animation_loop("attack_weighted"), "attack-nonloop")
    gate(_actor.actor_sprite.sprite_frames.get_animation_speed("attack_weighted")==12.0, "attack-12fps")
    gate(_actor.is_motion_supported(&"attack"), "attack-available")
    gate(not _actor.play_motion(&"hurt"), "hurt-not-faked")
    gate(_actor.play_motion(&"attack", &"attack_weighted"), "first-attack-start")
    gate(not _actor.play_motion(&"attack"), "no-double-attack")
    gate(absf(_actor.attack_clock.get_animation("attack_contact").length-1.0)<0.001, "clock-duration-1.0")
    await create_timer(0.40).timeout
    gate(hit_serials.size()==0, "windup-not-hit")
    await create_timer(0.35).timeout
    gate(hit_serials.size()==1, "first-hit-exactly-once")
    gate(hit_frames.size()==1 and hit_frames[0] in [6,7], "hit-at-visible-impact-frame")
    gate(hit_times.size()==1 and absf(hit_times[0]-0.55)<0.001, "method-track-550ms")
    gate(dummy_hits==1, "one-dummy-contact")
    await create_timer(0.39).timeout
    gate(complete_serials.size()==1, "attack-completed")
    gate(_actor.get_profile()==&"idle_rig", "auto-a39-idle")
    gate(hit_serials.size()==1, "no-retrigger-on-recovery")
    _actor.set_playback_multiplier(2.0)
    gate(_actor.play_motion(&"attack"), "speed2-start")
    await create_timer(0.17).timeout
    gate(hit_serials.size()==1, "speed2-no-early-hit")
    await create_timer(0.17).timeout
    gate(hit_serials.size()==2, "speed2-hit")
    await create_timer(0.27).timeout
    gate(complete_serials.size()==2, "speed2-finish")
    _actor.set_playback_multiplier(1.0)
    gate(_actor.play_motion(&"attack"), "start-cancel")
    await create_timer(0.12).timeout
    gate(_actor.play_motion(&"idle",&"idle_rig"), "cancel-back-to-idle")
    await create_timer(0.60).timeout
    gate(hit_serials.size()==2, "no-phantom-hit-after-cancel")
    gate(cancelled_serials.size()==1, "one-cancel-event")
    gate(_actor.play_motion(&"attack"), "pause-attack-start")
    await create_timer(0.12).timeout
    _actor.actor_sprite.pause()
    _actor.attack_clock.pause()
    await create_timer(0.60).timeout
    gate(hit_serials.size()==2, "pause-prevents-hit")
    _actor.actor_sprite.stop()
    _actor.attack_clock.play()
    await create_timer(0.54).timeout
    gate(hit_serials.size()==3, "resume-reaches-hit")
    await create_timer(0.38).timeout
    gate(complete_serials.size()==3, "resume-finishes")
    gate(dummy_hits==3, "dummy-three-real-contact-events")
    # Isolated GPU SubViewport for exact 64x64 texture readback.
    var atlas_tex: Texture2D = load("res://assets/actor01_attack_weighted_sword_12frames.png")
    gate(atlas_tex != null, "atlas-texture-loaded")
    # Decode original lossless PNG, not imported GPU texture (which can be reformatted).
    var atlas: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/actor01_attack_weighted_sword_12frames.png"))
    atlas.convert(Image.FORMAT_RGBA8)
    var cap := SubViewport.new()
    cap.size = Vector2i(64,64)
    cap.transparent_bg = true
    cap.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(cap)
    var actor_packed: PackedScene = load("res://scenes/actor01.tscn")
    var specimen: FSBattleActorAnimator = actor_packed.instantiate()
    specimen.initial_motion=&"attack"
    specimen.initial_profile=&"attack_weighted"
    specimen.position=Vector2(32,32)
    cap.add_child(specimen)
    await process_frame
    specimen.attack_clock.stop()
    specimen.actor_sprite.pause()
    var distinct: Dictionary = {}
    var directory: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(directory)
    for i in range(12):
        specimen.actor_sprite.frame=i
        await process_frame
        await RenderingServer.frame_post_draw
        var actual: Image = cap.get_texture().get_image()
        actual.convert(Image.FORMAT_RGBA8)
        gate(actual.get_size()==Vector2i(64,64),"gpu-size-f%d"%i)
        var errors: int=0
        var edge: int=0
        for y in range(64):
            for x in range(64):
                if actual.get_pixel(x,y)!=atlas.get_pixel((i%4)*64+x,int(i/4)*64+y):
                    errors+=1
                if (x==0 or x==63 or y==0 or y==63) and actual.get_pixel(x,y).a8!=0:
                    edge+=1
        gate(errors==0,"gpu-identical-to-atlas-f%d"%i)
        gate(edge==0,"no-edge-crop-f%d"%i)
        distinct[hash(actual.get_data())]=true
        gate(actual.save_png(directory.path_join("A41_REAL_GPU_ATTACK_F%02d.png"%i))==OK,"saved-gpu-f%d"%i)
    gate(distinct.size()==11,"eleven-distinct-gpu-poses")
    print("A41_GPU_DISTINCT="+str(distinct.size()))
    print("A41_GPU_RENDERER="+RenderingServer.get_video_adapter_name())
    # Capture main preview WHILE the actor is still swinging, not only at idle.
    gate(_actor.play_motion(&"attack"),"full-preview-attack-start")
    await create_timer(0.57).timeout
    await RenderingServer.frame_post_draw
    var scene_img:Image=root.get_viewport().get_texture().get_image()
    gate(scene_img.save_png(directory.path_join("A41_NATIVE_GPU_BATTLE_CONTACT.png"))==OK,"battle-contact-gpu-image")
    gate(runner.get_motion()==&"run", "a35-run-remains-live")
    if failures.is_empty():
        print("A41_GODOT_GPU_QA_PASS")
        quit(0)
    else:
        print("A41_GODOT_GPU_QA_FAIL " + JSON.stringify(failures))
        quit(1)