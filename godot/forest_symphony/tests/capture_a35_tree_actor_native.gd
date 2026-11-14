extends SceneTree
## Real Godot OpenGL actor view across a new complete PAR tree. Gameplay collision not yet approved.
func _initialize()->void:call_deferred("_capture")
func _capture()->void:
    var vp=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    for item in [
      {"foot":Vector2(144,708),"out":"A35_TREE_ACTOR_BEHIND_NATIVE_1280x928.png"},
      {"foot":Vector2(144,755),"out":"A35_TREE_ACTOR_FRONT_NATIVE_1280x928.png"}
    ]:
        var w=(load("res://scenes/a35_independent_tree_family_scene.tscn") as PackedScene).instantiate() as Node2D
        vp.add_child(w)
        var actor=w.get_node("YSort/Player") as CharacterBody2D
        actor.get_node("Camera2D").enabled=false
        actor.position=item["foot"]
        actor.visible=true
        for i in range(6):await process_frame
        await RenderingServer.frame_post_draw
        var pic=vp.get_texture().get_image()
        if pic==null or pic.is_empty():push_error("empty Godot native actor frame");quit(7);return
        var target="res://qa_a35/"+String(item["out"])
        if pic.save_png(target)!=OK:push_error("actor Godot screenshot write failed");quit(8);return
        print("A35 GODOT NATIVE ACTOR TREE: "+target)
        w.queue_free()
        await process_frame
    quit(0)
