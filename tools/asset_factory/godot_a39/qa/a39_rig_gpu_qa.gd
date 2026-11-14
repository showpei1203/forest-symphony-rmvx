extends SceneTree
## Repro: Godot 4.7.2 GPU (--rendering-method gl_compatibility), not headless dummy renderer.

const PHASES: Array[float] = [0.0, 0.27, 0.55, 0.87, 1.0, 0.55, 0.27, 0.0]
const MASKS: Array[Rect2i] = [Rect2i(32,36,8,6), Rect2i(25,34,6,3), Rect2i(39,34,4,3)]
var _failure: String = ""

func _initialize() -> void:
    call_deferred("_validate")

func allowed(p: Vector2i) -> bool:
    for rect in MASKS:
        if rect.has_point(p):
            return true
    return false

func _validate() -> void:
    var packed: PackedScene = load("res://scenes/actor01_breath_rig.tscn")
    assert(packed != null)
    var viewport := SubViewport.new()
    viewport.size = Vector2i(64,64)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var rig: FSActorBreathRig = packed.instantiate()
    rig.position = Vector2(32, 32)
    viewport.add_child(rig)
    await process_frame
    assert(rig.breath_player.has_animation("breathing"))
    assert(rig.pixel_sprite.texture.get_size() == Vector2(64,64))
    # Test actual native AnimationPlayer at two different times (before freezing for deterministic snapshots).
    rig.start_breathing()
    await create_timer(0.65).timeout
    var animated_phase: float = rig.get_breath()
    assert(animated_phase > 0.1)
    print("A39_ANIMATIONPLAYER_LIVE_PHASE=" + str(animated_phase))
    rig.breath_player.stop()
    var frames: Array[Image] = []
    var folder: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(folder)
    for i in range(PHASES.size()):
        rig.set_breath(PHASES[i])
        await process_frame
        await RenderingServer.frame_post_draw
        var result: Image = viewport.get_texture().get_image()
        assert(result != null and result.get_size() == Vector2i(64,64))
        result.convert(Image.FORMAT_RGBA8)
        frames.append(result)
        var err: Error = result.save_png(folder.path_join("A39_GPU_BREATH_F%02d.png" % i))
        assert(err == OK)
    var base: Image = frames[0]
    var diffs: Array[int] = []
    var invalid: Array[int] = []
    var alpha_changed: Array[int] = []
    var distinct: Dictionary = {}
    for i in range(frames.size()):
        var f: Image = frames[i]
        var changed: int = 0
        var out_mask: int = 0
        var changed_alpha: int = 0
        for y in range(64):
            for x in range(64):
                var pp := Vector2i(x,y)
                var b: Color = base.get_pixel(x,y)
                var a: Color = f.get_pixel(x,y)
                if b.a8 != a.a8:
                    changed_alpha += 1
                if b != a:
                    changed += 1
                    if not allowed(pp):
                        out_mask += 1
        diffs.append(changed)
        invalid.append(out_mask)
        alpha_changed.append(changed_alpha)
        distinct[hash(f.get_data())] = true
    print("A39_GPU_FRAME_DIFFS=" + JSON.stringify(diffs))
    print("A39_GPU_OUTSIDE_MASK_CHANGED=" + JSON.stringify(invalid))
    print("A39_GPU_ALPHA_CHANGED=" + JSON.stringify(alpha_changed))
    print("A39_GPU_DISTINCT_SOURCE_POSES=" + str(distinct.size()))
    print("A39_GPU_RENDERER=" + RenderingServer.get_video_adapter_name())
    assert(invalid.max() == 0)
    assert(alpha_changed.max() == 0)
    assert(distinct.size() >= 2)
    assert(diffs.max() > 0 and diffs.max() <= 100)
    assert(diffs[0] == 0 and diffs[7] == 0)
    assert(diffs[2] > 0 and diffs[4] > 0)
    print("A39_GPU_LOCAL_BREATH_PASS")
    quit(0)
