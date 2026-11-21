extends SceneTree
func _initialize()->void:call_deferred("capture")
func capture()->void:
    var scene=load("res://tb02_bat_showcase.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    scene.idle.stop()
    for i in 11:
        scene.attack.cancel_attack()
        scene.attack._show_frame(i)
        await process_frame
        var path="user://tb02_attack_native_F%02d.png" % i
        var ok=get_root().get_texture().get_image().save_png(path)
        assert(ok==OK,"Attack capture failed "+path)
    scene.attack._show_frame(0)
    for i in 8:
        scene.idle.stop()
        scene.idle.frame=i
        await process_frame
        var path="user://tb02_idle_native_F%02d.png"%i
        var ok=get_root().get_texture().get_image().save_png(path)
        assert(ok==OK,"Idle capture failed "+path)
    print("TB02_BAT_GODOT_472_REAL_NATIVE_CAPTURE_PASS IDLE=8 ATTACK=11")
    quit(0)
