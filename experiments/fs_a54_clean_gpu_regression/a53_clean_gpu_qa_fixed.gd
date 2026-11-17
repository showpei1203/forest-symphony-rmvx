extends SceneTree
## FS A54 clean Godot GPU regression test: BODY/FIST/HIT 3-track with ICON equipment. Native run not yet verified.
var failures: Array[String] = []
var hits: Array[int] = []
var ended: Array[int] = []
var stopped: Array[int] = []
var resumed: Array[int] = []
var frame_at_hit: int = -1
var actor: FSBattleActorAnimator

func gate(result: bool, msg: String) -> void:
    if result:
        print("A53_PASS " + msg)
    else:
        failures.append(msg)
        push_error("A53_FAIL " + msg)

func _on_hit(serial: int, at_second: float) -> void:
    hits.append(serial)
    frame_at_hit = actor.get_frame_index()
    gate(absf(at_second-0.63)<0.001, "f7-hit-timestamp")

func _on_finished(serial: int) -> void:
    ended.append(serial)

func _on_stop(serial: int, seconds: float) -> void:
    stopped.append(serial)
    gate(absf(seconds-0.07)<0.001,"70ms-hitstop-contract")

func _on_resume(serial: int) -> void:
    resumed.append(serial)

func _initialize() -> void:
    call_deferred("_run")

func _snap(vp: SubViewport) -> Image:
    print("A54_GPU_STAGE snapshot-request")
    await process_frame
    await RenderingServer.frame_post_draw
    print("A54_GPU_STAGE snapshot-frame-post-draw")
    var img: Image = vp.get_texture().get_image()
    img.convert(Image.FORMAT_RGBA8)
    return img

func _run() -> void:
    print("A54_GPU_STAGE begin")
    var viewport := SubViewport.new()
    viewport.size = Vector2i(64,64)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var actor_scene: PackedScene = load("res://scenes/actor01.tscn")
    gate(actor_scene != null,"actor-scene-load")
    if actor_scene == null:
        quit(1)
        return
    actor = actor_scene.instantiate()
    actor.position = Vector2(32,32)
    viewport.add_child(actor)
    print("A54_GPU_STAGE actor-instanced-await-first-frame")
    await process_frame
    print("A54_GPU_STAGE first-frame-ready")
    var body_path: String = "res://assets/actor01_a53_body_12frames.png"
    var body: Image = Image.load_from_file(ProjectSettings.globalize_path(body_path))
    var gold: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/actor01_a53_body_only_composite_reference.png"))
    gate(body != null and gold != null,"canonical-A53-Body-and-reference-present")
    if body == null or gold == null:
        print("A54_CLEAN_GPU_FAIL missing canonical A53 assets")
        quit(1)
        return
    gate(actor.actor_sprite.sprite_frames.get_frame_count("attack_weighted") == 12, "body-12frames")
    gate(actor.play_motion(&"attack",&"attack_weighted"),"attack-start")
    var timing: Animation = actor.attack_clock.get_animation("attack_contact")
    gate(timing.get_track_count() == 3, "three-track-clean-Body-Fist-Hit-clock")
    var frame_track: int = -1
    for track_id in range(timing.get_track_count()):
        if str(timing.track_get_path(track_id)) == "AnimatedSprite2D:frame":
            frame_track = track_id
    gate(frame_track >= 0,"dynamic-cadence-body-track-present")
    if frame_track >= 0:
        gate(timing.track_get_key_count(frame_track) == 12,"twelve-timed-body-frames")
        var expected_seconds: Array[float] = [0.0,0.100,0.190,0.275,0.350,0.455,0.560,0.620,0.735,0.830,0.910,0.980]
        for frame_id in range(12):
            gate(absf(timing.track_get_key_time(frame_track,frame_id)-expected_seconds[frame_id]) < 0.002,
                "body-frame-%02d-true-nonlinear-time"%frame_id)
        gate(timing.track_get_key_time(frame_track,7)-timing.track_get_key_time(frame_track,6) <= 0.061,
            "sword-release-accelerates-f6-f7")
    actor.attack_clock.stop()
    var output: String = ProjectSettings.globalize_path("res://qa/output/a53")
    DirAccess.make_dir_recursive_absolute(output)
    var unique: Dictionary = {}
    var diffs: Array[int] = []
    for f in range(12):
        actor.actor_sprite.frame = f
        var render: Image = await _snap(viewport)
        var bad: int = 0
        var boundary: int = 0
        for y in range(64):
            for x in range(64):
                var expected: Color=gold.get_pixel((f % 4)*64+x,int(f/4)*64+y)
                var got: Color=render.get_pixel(x,y)
                if got != expected:
                    # OpenGL SubViewport gives premultiplied RGB for translucent
                    # pixels (e.g. RGB 251,201,113 A110 -> RGB 108,87,49 A110).
                    # Preserve exact alpha; allow max 1 rounding in RGB.
                    var a8: int=expected.a8
                    var er: int=roundi(float(expected.r8)*float(a8)/255.0)
                    var eg: int=roundi(float(expected.g8)*float(a8)/255.0)
                    var eb: int=roundi(float(expected.b8)*float(a8)/255.0)
                    if got.a8 != a8 or absi(got.r8-er)>1 or absi(got.g8-eg)>1 or absi(got.b8-eb)>1:
                        bad += 1
                if (x==0 or x==63 or y==0 or y==63) and render.get_pixel(x,y).a8>0:
                    boundary += 1
        diffs.append(bad)
        unique[hash(render.get_data())]=true
        gate(bad==0,"GPU-RGBA-premultiplied-A53-F%02d-diff-%d"%[f,bad])
        gate(boundary==0,"GPU-no-crop-F%02d"%f)
        var saved: Error=render.save_png(output.path_join("A53_NATIVE_F%02d.png"%f))
        gate(saved==OK,"native-screenshot-F%02d"%f)
    gate(unique.size()>=8,"at-least-8-unique-attack-poses")
    # A53 ICON system proof: identical character body, independently selected 24x24 icon
    # and a different rotation/offset/reach profile for sword, spear, axe, and staff.
    actor.actor_sprite.frame=7
    var snapshot_unarmed: Image=await _snap(viewport)
    gate(actor.get_equipped_weapon_icon()==-1 and not actor.weapon_icon_layer.icon_sprite.visible,"real-attack-default-barehand")
    gate(actor.equip_weapon_icon(1, "sword"),"equip-original-icon1-sword")
    actor.weapon_icon_layer.update_frame(7, actor._attack_hand_anchors[7])
    var snapshot_sword: Image=await _snap(viewport)
    gate(snapshot_sword.save_png(output.path_join("A53_ICON1_SWORD_F07.png"))==OK,"real-GPU-sword-icon")
    gate(actor.weapon_icon_layer.get_icon_texture_region()==Rect2(24,0,24,24),"sword-original-ICONSET-index1-region")
    var sword_contact: Vector2=actor.get_weapon_icon_hit_local()
    gate(sword_contact != actor.get_attack_anchors()[7],"sword-profile-uses-independent-tip")
    gate(actor.equip_weapon_icon(4, "spear"),"equip-original-icon4-spear")
    actor.weapon_icon_layer.update_frame(7, actor._attack_hand_anchors[7])
    var spear_contact: Vector2=actor.get_weapon_icon_hit_local()
    var snapshot_spear: Image=await _snap(viewport)
    gate(snapshot_spear.save_png(output.path_join("A53_ICON4_SPEAR_F07.png"))==OK,"real-GPU-spear-icon")
    gate(actor.weapon_icon_layer.get_icon_texture_region()==Rect2(96,0,24,24),"spear-original-ICONSET-index4-region")
    gate(spear_contact != sword_contact,"spear-reach-and-angle-independent-of-sword")
    gate(snapshot_spear.get_data() != snapshot_sword.get_data(),"sword-and-spear-GPU-render-different")
    gate(actor.equip_weapon_icon(6, "axe"),"equip-original-icon6-axe")
    actor.weapon_icon_layer.update_frame(7, actor._attack_hand_anchors[7])
    var snapshot_axe: Image=await _snap(viewport)
    gate(snapshot_axe.save_png(output.path_join("A53_ICON6_AXE_F07.png"))==OK,"real-GPU-axe-icon")
    gate(snapshot_axe.get_data() != snapshot_sword.get_data(),"sword-and-axe-GPU-render-different")
    gate(actor.equip_weapon_icon(20, "staff"),"equip-original-icon20-staff")
    actor.weapon_icon_layer.update_frame(7, actor._attack_hand_anchors[7])
    var snapshot_staff: Image=await _snap(viewport)
    gate(snapshot_staff.save_png(output.path_join("A53_ICON20_STAFF_F07.png"))==OK,"real-GPU-staff-icon")
    gate(snapshot_staff.get_data() != snapshot_axe.get_data(),"staff-and-axe-GPU-render-different")
    gate(actor.equip_weapon_icon(-1),"unequip-returns-barehand")
    actor.weapon_icon_layer.update_frame(7, actor._attack_hand_anchors[7])
    var unequipped: Image=await _snap(viewport)
    gate(unequipped.get_data()==snapshot_unarmed.get_data(),"unarmed-fully-recovered-identical-body-GPU")
    gate(actor.actor_sprite.frame==7,"equipping-ICON-does-not-change-character-body-frame")
    actor.play_motion(&"idle",&"idle_rig")
    actor.attack_hit.connect(_on_hit)
    actor.attack_finished.connect(_on_finished)
    actor.hitstop_started.connect(_on_stop)
    actor.hitstop_finished.connect(_on_resume)
    gate(actor.play_motion(&"attack",&"attack_weighted"),"runtime-attack-start")
    await create_timer(0.57).timeout
    gate(hits.is_empty(),"no-early-hit-at-previous-0.55-second-event")
    await create_timer(0.24).timeout
    gate(hits.size()==1 and frame_at_hit==7,"one-hit-at-frame-7")
    gate(stopped.size()==1 and resumed.size()==1,"hitstop-start-resume")
    await create_timer(0.45).timeout
    gate(ended.size()==1 and actor.get_profile()==&"idle_rig","returns-to-a39-breathing")
    gate(not actor.weapon_icon_layer.icon_sprite.visible,"no-icon-when-barehand-after-attack")
    print("A53_GPU_PIXEL_DIFFS "+str(diffs))
    print("A53_GPU_UNIQUE_POSES "+str(unique.size()))
    print("A53_QA_RESULT "+("PASS" if failures.is_empty() else "FAIL"))
    quit(0 if failures.is_empty() else 1)
