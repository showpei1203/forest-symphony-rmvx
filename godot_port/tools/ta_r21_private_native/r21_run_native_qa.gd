extends SceneTree
## Source-exact A62 three-provider-pose RUN loop, unarmed 12 playback slots.
## This verifies real Godot 4.7.2 pixels & cadence, not artistic run quality.
var failures: Array[String] = []
var changed: int = 0

func gate(ok: bool, description: String) -> void:
    if ok:
        print("R21_RUN_PASS " + description)
    else:
        failures.append(description)
        push_error("R21_RUN_FAIL " + description)

func _initialize() -> void:
    call_deferred("_run")

func _on_frame() -> void:
    changed += 1

func _run() -> void:
    var path := "res://assets/actor01_r21_run_body_12frames.png"
    var img := Image.load_from_file(ProjectSettings.globalize_path(path))
    gate(img != null, "run-body-loaded")
    if img == null:
        quit(1)
        return
    gate(img.get_size() == Vector2i(256,192), "12x64-atlas-256x192")
    var texture: Texture2D = load(path)
    gate(texture != null, "run-imported-texture")
    if texture == null:
        quit(1)
        return
    var frames := SpriteFrames.new()
    frames.add_animation("source_run")
    frames.set_animation_speed("source_run", 12.0)
    frames.set_animation_loop("source_run", true)
    var expected_seq: Array[int] = [0,1,0,2,0,1,0,2,0,1,0,2]
    var source_hashes := {}
    for i in range(12):
        var atlas := AtlasTexture.new()
        atlas.atlas = texture
        atlas.region = Rect2(64*(i%4),64*int(i/4),64,64)
        frames.add_frame("source_run",atlas)
        source_hashes[hash(img.get_region(Rect2i(int(atlas.region.position.x),int(atlas.region.position.y),64,64)).get_data())] = true
    gate(frames.get_frame_count("source_run") == 12,"twelve-playback-slots")
    gate(source_hashes.size() == 3,"three-unique-original-PixelLab-poses")
    for i in range(12):
        var a: Image = img.get_region(Rect2i(64*(i%4),64*int(i/4),64,64))
        var b: Image = img.get_region(Rect2i(64*([0,1,3][expected_seq[i]]),0,64,64))
        gate(a.get_data() == b.get_data(), "real-source-pose-index-%02d"%i)
    var viewport := SubViewport.new()
    viewport.size = Vector2i(64,64)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var sprite := AnimatedSprite2D.new()
    sprite.centered = false
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.sprite_frames = frames
    sprite.animation = "source_run"
    viewport.add_child(sprite)
    sprite.stop()
    var output: String=ProjectSettings.globalize_path("res://qa/output/r21_run")
    DirAccess.make_dir_recursive_absolute(output)
    var deltas: Array[int] = []
    for f in range(12):
        sprite.frame = f
        await process_frame
        await RenderingServer.frame_post_draw
        var render: Image=viewport.get_texture().get_image()
        render.convert(Image.FORMAT_RGBA8)
        var mismatch := 0
        var clipped := 0
        for y in range(64):
            for x in range(64):
                var expected=img.get_pixel((f%4)*64+x,int(f/4)*64+y)
                var got=render.get_pixel(x,y)
                if got != expected:
                    var alpha:int=expected.a8
                    if got.a8 != alpha or absi(got.r8-roundi(float(expected.r8)*alpha/255.0))>1 or absi(got.g8-roundi(float(expected.g8)*alpha/255.0))>1 or absi(got.b8-roundi(float(expected.b8)*alpha/255.0))>1:
                        mismatch += 1
                if (x==0 or y==0 or x==63 or y==63) and got.a8>0:
                    clipped += 1
        deltas.append(mismatch)
        gate(mismatch == 0,"native-run-f%02d-pixel-diff-%d"%[f,mismatch])
        gate(clipped == 0,"native-run-f%02d-no-edge-crop"%f)
        gate(render.save_png(output.path_join("R21_RUN_NATIVE_F%02d.png"%f)) == OK,"saved-run-f%02d"%f)
    sprite.frame_changed.connect(_on_frame)
    sprite.play("source_run")
    await create_timer(1.09).timeout
    sprite.stop()
    gate(changed >= 10,"real-1.09sec-twelve-slot-playback-signals-%d"%changed)
    gate(deltas.size()==12,"twelve-native-gpu-frames")
    print("R21_RUN_NATIVE_GPU_DIFFS "+str(deltas))
    print("R21_RUN_NATIVE_CADENCE_SIGNALS "+str(changed))
    print("R21_RUN_QA_RESULT "+("PASS" if failures.is_empty() else "FAIL"))
    quit(0 if failures.is_empty() else 1)
