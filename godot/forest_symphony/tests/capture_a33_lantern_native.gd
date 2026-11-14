extends SceneTree
## Actual native Godot OpenGL framebuffer from private user-owned Ground and independent PNG objects.
const NEW_SCENE = "res://scenes/a33_groundfirst_lantern_scene.tscn"
const OLD_SCENE = "res://scenes/a32_groundfirst_scene.tscn"
func _initialize() -> void:call_deferred("_capture")
func _capture() -> void:
    var sub:SubViewport=SubViewport.new()
    sub.size=Vector2i(1280,928)
    sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    sub.disable_3d=true
    root.add_child(sub)
    for sample in [
       {"scene":OLD_SCENE,"name":"A33_BASELINE_A32_NATIVE_1280x928.png","show_actor":false},
       {"scene":NEW_SCENE,"name":"A33_NEW_LAMPS_NATIVE_1280x928.png","show_actor":false},
       {"scene":NEW_SCENE,"name":"A33_NEW_LAMP_ACTOR_BEHIND_NATIVE.png","show_actor":true,"foot":Vector2(496,445)},
       {"scene":NEW_SCENE,"name":"A33_NEW_LAMP_ACTOR_FRONT_NATIVE.png","show_actor":true,"foot":Vector2(496,503)}
    ]:
        var world:Node2D=load(sample["scene"]).instantiate()
        sub.add_child(world)
        var player:CharacterBody2D=world.get_node("YSort/Player")
        player.get_node("Camera2D").enabled=false
        player.visible=bool(sample["show_actor"])
        if sample["show_actor"]:player.position=sample["foot"]
        for i in range(5):await process_frame
        await RenderingServer.frame_post_draw
        var img:Image=sub.get_texture().get_image()
        if img==null or img.is_empty() or img.get_size()!=Vector2i(1280,928):
            push_error("A33 native framebuffer is not a real full-size image");quit(13);return
        var path="res://qa_a33/"+String(sample["name"])
        if img.save_png(path)!=OK:
            push_error("A33 Godot failed to write native framebuffer "+path);quit(14);return
        print("A33 GODOT NATIVE CAPTURE PASS: "+path)
        world.queue_free()
        await process_frame
    quit(0)
