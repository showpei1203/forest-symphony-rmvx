extends SceneTree
## Real GPU/OpenGL framebuffer, no fabricated composite.
func _initialize()->void: call_deferred("_capture")
func _capture()->void:
    for version in ["A36","A36B"]:
        var vp:=SubViewport.new()
        vp.size=Vector2i(2560,1856)
        vp.disable_3d=true
        vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
        root.add_child(vp)
        var file= "res://scenes/a36_large_verdant_forest_80x58.tscn" if version=="A36" else "res://scenes/a36b_large_forest_tree_ecology_80x58.tscn"
        var p=load(file) as PackedScene
        if p==null:push_error("Missing "+file);quit(4);return
        var w=p.instantiate() as Node2D
        vp.add_child(w)
        var actor=w.get_node("YSort/Player") as CharacterBody2D
        actor.visible=false
        actor.get_node("Camera2D").enabled=false
        for i in range(8):await process_frame
        await RenderingServer.frame_post_draw
        var img=vp.get_texture().get_image()
        if img.is_empty() or img.get_size()!=Vector2i(2560,1856):push_error("bad native "+version);quit(5);return
        var output="res://qa_a36b/"+version+"_TRUE_GODOT_NATIVE_2560x1856.png"
        if img.save_png(output)!=OK:push_error("native PNG save failed");quit(6);return
        print("A36B TRUE GODOT NATIVE "+version+" FRAME="+output)
        vp.queue_free()
        await process_frame
    quit(0)
