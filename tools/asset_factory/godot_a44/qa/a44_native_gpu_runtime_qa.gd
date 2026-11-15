extends SceneTree
## FS A44 native Godot test: rendering verification of actual revised Body/Weapon/FX.
var failures: Array[String] = []
var hits: Array[int] = []
var ended: Array[int] = []
var stopped: Array[int] = []
var resumed: Array[int] = []
var frame_at_hit: int = -1
var actor: FSBattleActorAnimator

func gate(result: bool, msg: String) -> void:
    if result:
        print("A44_PASS " + msg)
    else:
        failures.append(msg)
        push_error("A44_FAIL " + msg)

func _on_hit(serial: int, at_second: float) -> void:
    hits.append(serial)
    frame_at_hit = actor.get_frame_index()
    gate(absf(at_second-0.55)<0.001, "f6-hit-timestamp")

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
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = vp.get_texture().get_image()
    img.convert(Image.FORMAT_RGBA8)
    return img

func _run() -> void:
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
    await process_frame
    var body_path: String = "res://assets/actor01_a44_body_12frames.png"
    var weapon_path: String = "res://assets/actor01_a44_weapon_12frames.png"
    var fx_path: String = "res://assets/actor01_a44_fx_12frames.png"
    var body: Image = Image.load_from_file(ProjectSettings.globalize_path(body_path))
    var weapon: Image = Image.load_from_file(ProjectSettings.globalize_path(weapon_path))
    var fx: Image = Image.load_from_file(ProjectSettings.globalize_path(fx_path))
    var gold: Image = Image.load_from_file(ProjectSettings.globalize_path("res://assets/actor01_a44_composite_reference.png"))
    gate(body != null and weapon != null and fx != null and gold != null,"all-a44-atlases-present")
    gate(actor.actor_sprite.sprite_frames.get_frame_count("attack_weighted") == 12, "body-12frames")
    gate(actor.weapon_sprite.sprite_frames.get_frame_count("attack_weighted") == 12,"weapon-12frames")
    gate(actor.fx_sprite.sprite_frames.get_frame_count("attack_weighted") == 12,"fx-12frames")
    gate(actor.play_motion(&"attack",&"attack_weighted"),"attack-start")
    actor.attack_clock.stop()
    var output: String = ProjectSettings.globalize_path("res://qa/output/a44")
    DirAccess.make_dir_recursive_absolute(output)
    var unique: Dictionary = {}
    var diffs: Array[int] = []
    for f in range(12):
        actor.actor_sprite.frame = f
        actor.weapon_sprite.frame = f
        actor.fx_sprite.frame = f
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
        gate(bad==0,"GPU-RGBA-premultiplied-a44-F%02d-diff-%d"%[f,bad])
        gate(boundary==0,"GPU-no-crop-F%02d"%f)
        var saved: Error=render.save_png(output.path_join("A44_NATIVE_F%02d.png"%f))
        gate(saved==OK,"native-screenshot-F%02d"%f)
    gate(unique.size()>=8,"at-least-8-unique-attack-poses")
    actor.play_motion(&"idle",&"idle_rig")
    actor.attack_hit.connect(_on_hit)
    actor.attack_finished.connect(_on_finished)
    actor.hitstop_started.connect(_on_stop)
    actor.hitstop_finished.connect(_on_resume)
    gate(actor.play_motion(&"attack",&"attack_weighted"),"runtime-attack-start")
    await create_timer(0.45).timeout
    gate(hits.is_empty(),"no-early-hit")
    await create_timer(0.35).timeout
    gate(hits.size()==1 and frame_at_hit==6,"one-hit-at-frame-6")
    gate(stopped.size()==1 and resumed.size()==1,"hitstop-start-resume")
    await create_timer(0.45).timeout
    gate(ended.size()==1 and actor.get_profile()==&"idle_rig","returns-to-a39-breathing")
    gate(not actor.weapon_sprite.visible and not actor.fx_sprite.visible,"weapons-hidden-after-attack")
    print("A44_GPU_PIXEL_DIFFS "+str(diffs))
    print("A44_GPU_UNIQUE_POSES "+str(unique.size()))
    print("A44_QA_RESULT "+("PASS" if failures.is_empty() else "FAIL"))
    quit(0 if failures.is_empty() else 1)
