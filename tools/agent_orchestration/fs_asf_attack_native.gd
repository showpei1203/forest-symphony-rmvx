extends SceneTree
func _initialize():
    call_deferred("run")
func fail(reason: String):
    printerr(reason)
    quit(1)
func run():
    var q = JSON.parse_string(FileAccess.get_file_as_string("res://qa.json"))
    var atlas := Image.load_from_file("res://body.png")
    if atlas == null or atlas.get_size() != Vector2i(256,192):
        fail("ATLAS_SIZE"); return
    atlas.convert(Image.FORMAT_RGBA8)
    var tex := ImageTexture.create_from_image(atlas)
    var sf := SpriteFrames.new()
    sf.add_animation(&"attack")
    sf.set_animation_speed(&"attack", 1.0)
    sf.set_animation_loop(&"attack", false)
    for i in range(12):
        var region := Rect2i(i % 4 * 64, floori(i / 4.0) * 64, 64, 64)
        var frame := Image.load_from_file("res://F%02d.png" % i)
        frame.convert(Image.FORMAT_RGBA8)
        if atlas.get_region(region).get_data() != frame.get_data():
            fail("ATLAS_PIXEL_PARITY"); return
        var cell := AtlasTexture.new()
        cell.atlas = tex
        cell.region = Rect2(region)
        cell.filter_clip = true
        sf.add_frame(&"attack", cell, float(q.durations_ms[i])/1000.0)
        if absf(sf.get_frame_duration(&"attack",i)*1000.0-float(q.durations_ms[i])) > 0.01:
            fail("FRAME_DURATION"); return
    var actor := AnimatedSprite2D.new()
    actor.sprite_frames = sf
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.centered = false
    actor.offset = -Vector2(32,50)
    root.add_child(actor)
    var seen := []
    actor.frame_changed.connect(func(): seen.append(actor.frame))
    actor.play(&"attack")
    await actor.animation_finished
    var expected := []
    for i in range(1,12): expected.append(i)
    if actor.frame != 11 or actor.is_playing() or seen != expected or actor.offset != Vector2(-32,-50):
        fail("PLAYBACK_SEQUENCE %s" % [seen]); return
    print("FS_ATTACK_ATLAS_NATIVE_PASS frames=12 events=11 one_shot=true")
    actor.queue_free()
    quit(0)
