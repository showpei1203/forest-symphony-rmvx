extends SceneTree
func _initialize()->void:call_deferred("snap")
func snap()->void:
    var scene=load("res://family_showcase.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    await process_frame
    var result=get_root().get_texture().get_image().save_png("user://tb_family_r7_preview.png")
    assert(result==OK,"Screenshot save failed")
    print("TB_FIRST_FAMILY_NATIVE_472_CAPTURE_PASS user://tb_family_r7_preview.png")
    quit(0)
