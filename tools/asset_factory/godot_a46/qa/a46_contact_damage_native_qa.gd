extends SceneTree
## A46 real Godot isolated combat contact, one hit per attack serial at moving tip.
var failed: Array[String] = []
var damage_events: int = 0
var _completed: bool = false

func gate(ok: bool, label: String) -> void:
    if ok:
        print("A46_CONTACT_PASS "+label)
    else:
        failed.append(label)
        push_error("A46_CONTACT_FAIL "+label)

func _on_damaged(_serial: int, amount: int, _hp_after: int) -> void:
    damage_events += 1
    gate(amount==25,"damage-payload-25")

func _cancel_during_hit(_serial: int, _timestamp: float, actor: FSBattleActorAnimator) -> void:
    actor.play_motion(&"idle",&"idle_rig")

func _initialize() -> void:
    call_deferred("_run")
    call_deferred("_watchdog")

func _watchdog() -> void:
    await create_timer(25.0).timeout
    if not _completed:
        push_error("A46_CONTACT_WATCHDOG")
        quit(97)

func _snapshot(viewport: SubViewport) -> Image:
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = viewport.get_texture().get_image()
    image.convert(Image.FORMAT_RGBA8)
    return image

func _run() -> void:
    var vp := SubViewport.new()
    vp.size=Vector2i(800,620)
    vp.transparent_bg=false
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var stage: PackedScene = load("res://scenes/a44_contact_demo.tscn")
    gate(stage!=null,"demo-scene-load")
    if stage==null:
        _completed=true
        quit(1)
        return
    var demo: Node2D=stage.instantiate()
    vp.add_child(demo)
    await process_frame
    var actor: FSBattleActorAnimator=demo.get_node("Actor")
    var target: FSA44PracticeTarget=demo.get_node("Target")
    target.damaged.connect(_on_damaged)
    gate(target is Area2D and target.get_node("CollisionShape2D")!=null, "real-area2d-target")
    gate(actor.get_profile()==&"idle_rig","initial-a39-breathing")
    var clock: Animation=actor.attack_clock.get_animation("attack_contact")
    gate(clock.get_track_count()==5,"single-clock-body-weapon-fx-moving-marker-and-method")
    var anchors: Array[Vector2]=actor.get_attack_anchors()
    gate(anchors.size()==12,"12-weapon-tip-pose-anchors")
    var marker_track: int=-1
    for i in range(clock.get_track_count()):
        if str(clock.track_get_path(i))=="HitMarker:position":
            marker_track=i
    gate(marker_track>=0,"marker-on-real-animation-track")
    if marker_track>=0:
        for f in range(12):
            gate(clock.track_get_key_value(marker_track,f)==anchors[f],"frame-%d-sword-tip-track"%f)
    gate(demo.start_attack(),"first-attack-start")
    await actor.hitstop_started
    gate(target.health==75 and target.damage_count==1 and damage_events==1,"range-first-hit-real-hp-decrease")
    gate(demo.last_contact_local==Vector2(30,9),"F6-moving-hit-marker-(30,9)")
    gate(demo.last_contact_world.distance_to(actor.to_global(Vector2(30,9)))<0.01,"correct-local-to-global-with-scale")
    gate(not target.apply_blade_contact(demo.last_contact_serial,demo.last_contact_world,25),"prevent-double-hit-same-serial")
    var snap: Image=await _snapshot(vp)
    var folder: String=ProjectSettings.globalize_path("res://qa/output/a46")
    DirAccess.make_dir_recursive_absolute(folder)
    gate(snap.save_png(folder.path_join("A46_NATIVE_DAMAGE_CONTACT_SCENE.png"))==OK,"native-damage-scene-shot-saved")
    await create_timer(0.75).timeout
    gate(actor.get_profile()==&"idle_rig","return-to-idle-after-damage")
    target.position=Vector2(409,392)
    gate(demo.start_attack(),"second-attack-start")
    await actor.hitstop_started
    gate(target.health==50 and target.damage_count==2 and damage_events==2,"second-distinct-serial-damage")
    await create_timer(0.75).timeout
    target.position=Vector2(620,392)
    gate(demo.start_attack(),"out-of-range-attack-start")
    await actor.hitstop_started
    gate(target.health==50 and target.damage_count==2 and demo.misses==1,"range-miss-no-ghost-damage")
    await create_timer(0.75).timeout
    demo.reset_target()
    gate(demo.start_attack(),"cancel-case-attack-start")
    await create_timer(0.13).timeout
    gate(actor.play_motion(&"idle",&"idle_rig"),"cancel-before-contact")
    await create_timer(0.70).timeout
    gate(target.health==100 and target.damage_count==0,"cancel-no-ghost-damage")
    target.position=Vector2(409,392)
    actor.set_playback_multiplier(2.0)
    gate(demo.start_attack(),"double-speed-attack-start")
    await actor.hitstop_started
    gate(target.health==75 and target.damage_count==1,"double-speed-single-damage")
    gate(demo.last_contact_local==Vector2(30,9),"double-speed-f6-anchor")
    await create_timer(0.65).timeout
    gate(actor.get_profile()==&"idle_rig","double-speed-return-idle")
    # Regression: a first listener cancels DURING attack_hit before anchor signal.
    actor.set_playback_multiplier(1.0)
    demo.reset_target()
    var interrupter := Callable(self,"_cancel_during_hit").bind(actor)
    actor.attack_hit.connect(interrupter)
    gate(demo.start_attack(),"reentrant-cancel-attack-start")
    await create_timer(0.74).timeout
    gate(target.health==100 and target.damage_count==0,"cancel-within-hit-no-anchor-damage")
    gate(actor.get_profile()==&"idle_rig","interrupt-restores-idle")
    actor.attack_hit.disconnect(interrupter)
    print("A46_CONTACT_DAMAGE_EVENT_COUNT "+str(damage_events))
    print("A46_CONTACT_QA_RESULT "+("PASS" if failed.is_empty() else "FAIL"))
    _completed=true
    quit(0 if failed.is_empty() else 1)
