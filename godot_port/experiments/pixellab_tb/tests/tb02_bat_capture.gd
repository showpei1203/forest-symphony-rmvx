extends SceneTree
func _initialize()->void:call_deferred("snap")
func snap()->void:
    root.add_child(load("res://tb02_bat_showcase.tscn").instantiate())
    await process_frame
    await process_frame
    var r=get_root().get_texture().get_image().save_png("user://tb02_leafbat_native_preview.png")
    assert(r==OK)
    print("TB_SECOND_BAT_NATIVE_RENDER_472_PASS")
    quit(0)
