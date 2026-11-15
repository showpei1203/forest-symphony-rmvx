extends SceneTree
## A35 R4: actual Godot GPU A/B and actor depth, ambient effects disabled for pixel-stable ROI.
const OLD := "res://scenes/a35_r3_hd2d_layered_scene.tscn"
const NEW := "res://scenes/a35_r4_organic_groves_hd2d_scene.tscn"
const WIDTH := 1280
const HEIGHT := 928
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var vp := SubViewport.new()
    vp.size = Vector2i(WIDTH, HEIGHT)
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    vp.disable_3d = true
    root.add_child(vp)
    var cases := [
        {"scene": OLD,"file":"A35_R4_R3_BASELINE_NATIVE.png","actor":false},
        {"scene": NEW,"file":"A35_R4_ART_CANDIDATE_NATIVE.png","actor":false},
        {"scene": NEW,"file":"A35_R4_ACTOR_BEHIND_NATIVE.png","actor":true,"foot":Vector2(1247,174)},
        {"scene": NEW,"file":"A35_R4_ACTOR_FRONT_NATIVE.png","actor":true,"foot":Vector2(1247,440)}
    ]
    for item in cases:
        var world: Node2D = load(item["scene"]).instantiate()
        vp.add_child(world)
        var actor: CharacterBody2D = world.get_node("YSort/Player")
        actor.get_node("Camera2D").enabled = false
        actor.visible = item["actor"]
        if item["actor"]:
            actor.position = item["foot"]
        var atmosphere: Node2D = world.get_node("HD2DAtmosphere")
        atmosphere.set("animate",false)
        atmosphere.set("enabled",false)
        atmosphere.call("_update_phase")
        for n in range(8):
            await process_frame
        await RenderingServer.frame_post_draw
        var frame: Image = vp.get_texture().get_image()
        if frame == null or frame.is_empty() or frame.get_size()!=Vector2i(WIDTH,HEIGHT):
            push_error("A35 R4 native A/B GPU frame invalid")
            quit(51)
            return
        var file: String = "res://qa_a35/"+str(item["file"])
        if frame.save_png(file)!=OK:
            push_error("A35 R4 failed GPU save "+file)
            quit(52)
            return
        print("A35 R4 REAL GODOT GPU: "+file)
        world.queue_free()
        await process_frame
    print("A35 R4 4/4 stable GPU A/B + actor depth frame capture PASS")
    quit(0)
