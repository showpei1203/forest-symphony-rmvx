extends SceneTree
## Godot real renderer captures A34 old forest and A35 new complete tree visual A/B.
func _initialize()->void:call_deferred("_capture")
func _capture()->void:
    var vp=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    for item in [
      {"scene":"res://scenes/a34_groundfirst_full_houses_scene.tscn","file":"A35_NATIVE_BASELINE_A34_1280x928.png"},
      {"scene":"res://scenes/a35_independent_tree_family_scene.tscn","file":"A35_NATIVE_4FAMILY_8TREES_1280x928.png"}
    ]:
        var p=load(item["scene"]) as PackedScene
        if p==null:push_error("missing native scene");quit(4);return
        var world=p.instantiate() as Node2D
        vp.add_child(world)
        var player=world.get_node("YSort/Player") as CharacterBody2D
        player.get_node("Camera2D").enabled=false
        player.visible=false
        for i in range(5):await process_frame
        await RenderingServer.frame_post_draw
        var img=vp.get_texture().get_image()
        if img==null or img.is_empty() or img.get_size()!=Vector2i(1280,928):push_error("Godot framebuffer empty");quit(5);return
        var out="res://qa_a35/"+String(item["file"])
        if img.save_png(out)!=OK:push_error("Could not write Godot screenshot");quit(6);return
        print("A35 TRUE GODOT OPENGL FRAMEBUFFER: "+out)
        world.queue_free()
        await process_frame
    quit(0)
