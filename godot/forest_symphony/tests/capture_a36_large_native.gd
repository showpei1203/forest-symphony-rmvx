extends SceneTree
func _initialize()->void:call_deferred("_capture")
func _capture()->void:
    var vp=SubViewport.new()
    vp.size=Vector2i(2560,1856)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var p=load("res://scenes/a36_large_verdant_forest_80x58.tscn") as PackedScene
    if p==null:push_error("A36 PackedScene missing");quit(4);return
    var world=p.instantiate() as Node2D
    vp.add_child(world)
    var actor=world.get_node("YSort/Player") as CharacterBody2D
    actor.visible=false
    actor.get_node("Camera2D").enabled=false
    for i in range(5):await process_frame
    await RenderingServer.frame_post_draw
    var img=vp.get_texture().get_image()
    if img.is_empty() or img.get_size()!=Vector2i(2560,1856):push_error("native framebuffer invalid");quit(5);return
    var out="res://qa_a36/A36_NATIVE_LARGE_FOREST_FULL_2560x1856.png"
    if img.save_png(out)!=OK:push_error("capture save fail");quit(6);return
    print("A36 TRUE GODOT 4.7.2 NATIVE FRAME: "+out)
    quit(0)
