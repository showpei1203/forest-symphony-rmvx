extends SceneTree
func _initialize() -> void:
    call_deferred("capture")
func capture() -> void:
    root.size=Vector2i(1280,768)
    var scene = load("res://tb11_frog_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    scene.show_action("attack")
    for spr in scene.sprites:
        spr.stop()
        spr.set_frame_and_progress(5,0.0)
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    var out="res://out/TB11_FROG_THREE_STAGE_GODOT472_ATTACK_F5_NATIVE.png"
    var error=image.save_png(out)
    if error!=OK:
        push_error("Native capture failed: "+str(error))
        quit(1)
        return
    print("FS_TB_R11_FROG_NATIVE_CAPTURE_PASS ", image.get_size())
    quit(0)
