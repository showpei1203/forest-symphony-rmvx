extends SceneTree
## Native Godot 4.7.2 OpenGL framebuffer, not a staged/AI composite.
const PRIOR="res://scenes/a33_groundfirst_lantern_scene.tscn"
const CURRENT="res://scenes/a34_groundfirst_full_houses_scene.tscn"
func _initialize()->void:call_deferred("_capture")
func _capture()->void:
    var viewport=SubViewport.new()
    viewport.size=Vector2i(1280,928)
    viewport.disable_3d=true
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var samples=[
      {"scene":PRIOR,"file":"A34_NATIVE_A33_HOUSE_BASELINE_1280x928.png","actor":false},
      {"scene":CURRENT,"file":"A34_NATIVE_NEW_HOUSES_1280x928.png","actor":false},
      {"scene":CURRENT,"file":"A34_NATIVE_LEFT_HOUSE_ACTOR_AT_DOOR.png","actor":true,"foot":Vector2(332,419)},
      {"scene":CURRENT,"file":"A34_NATIVE_RIGHT_HOUSE_ACTOR_AT_DOOR.png","actor":true,"foot":Vector2(1046,430)}
    ]
    for sample in samples:
        var world:Node2D=load(sample["scene"]).instantiate()
        viewport.add_child(world)
        var actor=world.get_node("YSort/Player") as CharacterBody2D
        actor.get_node("Camera2D").enabled=false
        actor.visible=sample["actor"]
        if sample["actor"]:actor.position=sample["foot"]
        for i in range(5):await process_frame
        await RenderingServer.frame_post_draw
        var screenshot=viewport.get_texture().get_image()
        if screenshot==null or screenshot.is_empty() or screenshot.get_size()!=Vector2i(1280,928):
            push_error("A34 native Godot framebuffer empty");quit(20);return
        var filename="res://qa_a34/"+sample["file"]
        if screenshot.save_png(filename)!=OK:
            push_error("A34 native render write failed "+filename);quit(21);return
        print("A34 GODOT NATIVE FRAMEBUFFER: "+filename)
        world.queue_free()
        await process_frame
    quit(0)
