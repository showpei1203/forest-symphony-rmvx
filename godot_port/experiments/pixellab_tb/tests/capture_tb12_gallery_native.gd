extends SceneTree
func _initialize()->void:
    call_deferred("capture")
func capture()->void:
    root.size=Vector2i(1280,900)
    var scene=load("res://tb12_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    for action in ["guard","skill","locomotion"]:
        scene.show_action(action)
        for spr in scene.sprites:
            spr.stop()
            spr.set_frame_and_progress(min(3,spr.sprite_frames.get_frame_count("play")-1),0.0)
        await RenderingServer.frame_post_draw
        var img: Image=root.get_texture().get_image()
        var output: String="res://out/TB12_GODOT472_NATIVE_%s.png" % action.to_upper()
        var err=img.save_png(output)
        if err!=OK:
            push_error("Native art capture failed: "+str(err))
            quit(1)
            return
        print("FS_TB_R12_GODOT472_NATIVE_CAPTURE_PASS ",action," ",img.get_size())
    quit(0)
