extends SceneTree
## Real Godot 544x416 viewport: actor and entire isolated oak pixel source, no fake pre-compositing.
const TREE := Vector2(1475,1016)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    var vp=SubViewport.new()
    vp.size=Vector2i(544,416)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    for test in [{"id":"behind","p":Vector2(1475,985)},{"id":"front","p":Vector2(1475,1048)}]:
        var scene=load("res://scenes/a36_large_verdant_forest_80x58.tscn") as PackedScene
        var world=scene.instantiate() as Node2D
        vp.add_child(world)
        var player=world.get_node("YSort/Player") as CharacterBody2D
        player.get_node("Camera2D").enabled=false
        player.set_physics_process(false)
        player.position=test["p"]
        world.position=Vector2(272,208)-TREE
        for i in range(4):await process_frame
        await RenderingServer.frame_post_draw
        var shot=vp.get_texture().get_image()
        if shot.is_empty() or shot.get_size()!=Vector2i(544,416):push_error("A36 actor viewport failure");quit(5);return
        var out="res://qa_a36/A36_TRUE_GODOT_ACTOR_TREE_"+test["id"]+"_544x416.png"
        if shot.save_png(out)!=OK:push_error("failed native tree screenshot");quit(6);return
        print("A36 TREE ACTOR NATIVE: "+out)
        world.queue_free()
        await process_frame
    quit(0)
