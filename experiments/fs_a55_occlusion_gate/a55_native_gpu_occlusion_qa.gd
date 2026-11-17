extends SceneTree
## A55: actual Godot SubViewport GPU pixels, synthetic sprite components only.
## This does not use, or claim acceptance of, a licensed FS sprite/monster.

var problems: Array[String] = []

func check(ok: bool, label: String) -> void:
    if ok:
        print("A55_GPU_PASS " + label)
    else:
        problems.append(label)
        push_error("A55_GPU_FAIL " + label)

func _initialize() -> void:
    call_deferred("_run")

func _rgba_layer(rects: Array, color: Color) -> Texture2D:
    var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    for rect in rects:
        image.fill_rect(rect, color)
    return ImageTexture.create_from_image(image)

func _set_texture(sprite: Sprite2D, rects: Array, color: Color) -> void:
    sprite.texture = _rgba_layer(rects, color)
    sprite.centered = false
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _count_orange(image: Image) -> int:
    var found := 0
    for y in range(64):
        for x in range(64):
            var c: Color = image.get_pixel(x, y)
            if c.a8 >= 128 and c.r8 >= 205 and c.g8 >= 90 and c.g8 <= 155 and c.b8 <= 95:
                found += 1
    return found

func _count_silver_tip(image: Image) -> int:
    var found := 0
    for y in range(64):
        for x in range(5, 24):
            var c: Color = image.get_pixel(x, y)
            if c.a8 >= 128 and c.r8 >= 170 and c.g8 >= 190 and c.b8 >= 198:
                found += 1
    return found

func _grab(vp: SubViewport) -> Image:
    await process_frame
    await RenderingServer.frame_post_draw
    var picture: Image = vp.get_texture().get_image()
    picture.convert(Image.FORMAT_RGBA8)
    return picture

func _run() -> void:
    var viewport := SubViewport.new()
    viewport.name = "A55SyntheticGPU"
    viewport.size = Vector2i(64, 64)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var controller: Script = load("res://fs_a55_occlusion_controller.gd")
    check(controller != null, "controller-load-GPU")
    if controller == null:
        quit(1)
        return
    var rig: Node2D = controller.new()
    rig.preview_mode = true
    rig.visibility_file = "res://a55_visibility_manifest_reference.json"
    rig.body_path = NodePath("Body")
    rig.shield_path = NodePath("Shield")
    rig.weapon_path = NodePath("Weapon")
    rig.weapon_tip_path = NodePath("WeaponTip")
    for label in ["Body", "Shield", "Weapon", "WeaponTip"]:
        var sprite := Sprite2D.new()
        sprite.name = label
        rig.add_child(sprite)
    viewport.add_child(rig)
    await process_frame
    var body: Sprite2D = rig.get_node("Body")
    var shield: Sprite2D = rig.get_node("Shield")
    var weapon: Sprite2D = rig.get_node("Weapon")
    var tip: Sprite2D = rig.get_node("WeaponTip")
    _set_texture(body, [Rect2i(31, 15, 8, 34), Rect2i(28, 49, 5, 8), Rect2i(39, 49, 5, 8)], Color(0.60, 0.65, 0.71, 1))
    var output := ProjectSettings.globalize_path("res://qa_output")
    check(DirAccess.make_dir_recursive_absolute(output) == OK, "create-synthetic-output")
    for frame in [5, 6]:
        var shift: int = frame - 5
        _set_texture(shield, [Rect2i(25, 20+shift, 22, 24)], Color(0.39, 0.28, 0.19, 1))
        _set_texture(weapon, [Rect2i(41, 29+shift, 12, 7)], Color(0.90, 0.48, 0.23, 1))
        _set_texture(tip, [Rect2i(9, 28+shift, 13, 4)], Color(0.73, 0.83, 0.89, 1))
        shield.z_index = 2
        weapon.z_index = 1
        tip.z_index = 3
        weapon.visible = true
        tip.visible = false
        var before: Image = await _grab(viewport)
        var orange_before: int = _count_orange(before)
        check(orange_before > 5, "real-GPU-negative-control-reveals-ghost-hand-F%d" % frame)
        check(before.save_png(output.path_join("A55_GPU_F%d_BEFORE.png" % frame)) == OK,
              "save-before-F%d" % frame)
        check(rig.apply_frame("NW", "attack", frame), "apply-occlusion-on-GPU-F%d" % frame)
        var after: Image = await _grab(viewport)
        var orange_after: int = _count_orange(after)
        var tip_count: int = _count_silver_tip(after)
        check(orange_after == 0, "real-GPU-no-ghost-hand-F%d" % frame)
        check(tip_count >= 25, "real-GPU-visible-blade-tip-F%d" % frame)
        check(after.get_pixel(28, 25+shift).a8 >= 128,
              "real-GPU-shield-front-opaque-F%d" % frame)
        check(after.save_png(output.path_join("A55_GPU_F%d_AFTER.png" % frame)) == OK,
              "save-after-F%d" % frame)
        print("A55_GPU_MEASUREMENT F%d old_hand_px=%d new_hand_px=%d visible_tip_px=%d" %
              [frame, orange_before, orange_after, tip_count])
    print("A55_GPU_QA_RESULT " + ("PASS" if problems.is_empty() else "FAIL"))
    quit(0 if problems.is_empty() else 1)
