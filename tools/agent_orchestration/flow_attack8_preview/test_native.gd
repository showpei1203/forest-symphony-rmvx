extends SceneTree
const Body = preload("res://FlowAttackBody.gd")
var actor: Body
var finished := false
var sequence: Array[int] = []
func _initialize() -> void:
    call_deferred("run")
func fail(reason: String) -> void:
    printerr(reason)
    quit(1)
func fixture() -> Image:
    var im := Image.create_empty(256, 128, false, Image.FORMAT_RGBA8)
    im.fill(Color.TRANSPARENT)
    for i in range(8):
        im.fill_rect(Rect2i(i % 4 * 64 + 20 + i, floori(i / 4.0) * 64 + 30, 12, 20), Color(0.2, 0.4, 0.8, 1.0))
    return im
func run() -> void:
    actor = Body.new()
    root.add_child(actor)
    var is_private := FileAccess.file_exists("res://asset/ATTACK8_atlas.png")
    if actor.configure(Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)) or actor.configure(Image.create_empty(256, 128, false, Image.FORMAT_RGBA8)):
        fail("NEGATIVE_FORMAT"); return
    var duplicate := fixture()
    duplicate.blit_rect(duplicate.get_region(Rect2i(0, 0, 64, 64)), Rect2i(0, 0, 64, 64), Vector2i(64, 0))
    if actor.configure(duplicate):
        fail("NEGATIVE_DUPLICATE"); return
    var wrong_foot := fixture()
    wrong_foot.set_pixel(20, 50, Color.WHITE)
    if actor.configure(wrong_foot):
        fail("NEGATIVE_ANCHOR"); return
    var source := fixture()
    if is_private:
        if not actor.load_candidate():
            fail("PRIVATE_HASH_OR_FORMAT"); return
        source = Image.load_from_file("res://asset/ATTACK8_atlas.png")
        source.convert(Image.FORMAT_RGBA8)
        for i in range(8):
            var frame := Image.load_from_file("res://asset/F%02d.png" % (i + 1))
            if frame == null:
                fail("PRIVATE_FRAME_MISSING"); return
            frame.convert(Image.FORMAT_RGBA8)
            if source.get_region(Rect2i(i % 4 * 64, floori(i / 4.0) * 64, 64, 64)).get_data() != frame.get_data():
                fail("PRIVATE_PARITY"); return
    elif not actor.configure(source):
        fail("FIXTURE_CONFIG"); return
    if actor.offset != Vector2(-32, -50) or actor.sprite_frames.get_animation_loop(&"attack_body") or actor.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
        fail("PRESENTATION_CONTRACT"); return
    for i in range(8):
        if not is_equal_approx(actor.sprite_frames.get_frame_duration(&"attack_body", i), Body.MS[i] / 1000.0):
            fail("DURATION"); return
        var at := actor.sprite_frames.get_frame_texture(&"attack_body", i) as AtlasTexture
        if at.region != Rect2(i % 4 * 64, floori(i / 4.0) * 64, 64, 64):
            fail("ATLAS_REGION"); return
    actor.frame_changed.connect(func(): sequence.append(actor.frame))
    actor.animation_finished.connect(func(): finished = true)
    if not actor.replay():
        fail("START"); return
    var ticks := 0
    while not finished and ticks < 300:
        await process_frame
        ticks += 1
    if ticks < 235 or ticks > 245:
        fail("TIMING_TICKS %d" % ticks); return
    if not finished or actor.is_playing() or actor.frame != 7 or sequence != [1,2,3,4,5,6,7]:
        fail("PLAYBACK %s" % [sequence]); return
    if not actor.replay() or actor.frame != 0:
        fail("REPLAY"); return
    print("FLOW_ATTACK8_NATIVE_PASS scope=%s frames=8 transitions=7 body_only=true ticks=%d" % [("PRIVATE" if is_private else "SYNTHETIC"), ticks])
    quit(0)
