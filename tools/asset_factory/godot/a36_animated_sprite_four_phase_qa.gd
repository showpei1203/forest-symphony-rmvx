extends SceneTree

var frame_events: Array[int] = []
var actor: AnimatedSprite2D
var test_viewport: SubViewport

func _initialize() -> void:
    call_deferred("_run")

func _on_frame_changed() -> void:
    frame_events.append(actor.frame)

func _run() -> void:
    var path: String = ProjectSettings.globalize_path("res://A36_AI_FRAMES_EXPERIMENT_VX32_ART_HOLD/$actor01_1.png")
    var sheet: Image = Image.load_from_file(path)
    assert(sheet != null and sheet.get_size() == Vector2i(96, 128))
    var atlas: ImageTexture = ImageTexture.create_from_image(sheet)

    var anims := SpriteFrames.new()
    anims.add_animation("FSJ_MOVE")
    anims.set_animation_speed("FSJ_MOVE", 8.0)
    anims.set_animation_loop("FSJ_MOVE", true)
    # Exactly the FS 3-column, 4-phase loop: neutral -> left -> neutral -> right.
    var column_indices := [0, 1, 0, 2]
    for col in column_indices:
        var tile := AtlasTexture.new()
        tile.atlas = atlas
        tile.region = Rect2(col * 32, 2 * 32, 32, 32)
        anims.add_frame("FSJ_MOVE", tile)
    assert(anims.get_frame_count("FSJ_MOVE") == 4)

    test_viewport = SubViewport.new()
    test_viewport.size = Vector2i(448, 392)
    test_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(test_viewport)
    var bg := ColorRect.new()
    bg.color = Color(0.15, 0.19, 0.25, 1.0)
    bg.size = Vector2(448, 392)
    test_viewport.add_child(bg)
    actor = AnimatedSprite2D.new()
    actor.sprite_frames = anims
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.centered = true
    actor.scale = Vector2(7.0, 7.0)
    actor.position = Vector2(224, 205)
    test_viewport.add_child(actor)
    actor.frame_changed.connect(_on_frame_changed)
    actor.play("FSJ_MOVE")
    await create_timer(1.6).timeout
    assert(actor.is_playing())
    var expected := [1, 2, 3, 0]
    var match_sequence := false
    for i in range(max(0,frame_events.size() - 3)):
        if frame_events.slice(i,i+4) == expected:
            match_sequence = true
            break
    print("FSJ_MOVE_ACTUAL_EVENT_SEQUENCE=",str(frame_events))
    print("FSJ_MOVE_EXPECTED_SEQUENCE_1_2_3_0_FOUND=",match_sequence)
    await RenderingServer.frame_post_draw
    var capture: Image = test_viewport.get_texture().get_image()
    var res: Error = capture.save_png(ProjectSettings.globalize_path("res://A36_GODOT_ANIMATED_SPRITE_ACTUAL_GPU_FRAME.png"))
    if res != OK or not match_sequence or frame_events.size() < 8:
        push_error("AnimatedSprite2D native loop did not pass")
        quit(1)
        return
    print("GODOT_FSJ_MOVE_ANIMATEDSPRITE_4PHASE_PASS events=",frame_events.size())
    quit(0)
