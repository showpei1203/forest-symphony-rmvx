extends SceneTree
## 544x416 native Godot 4.7.2 actor/front/behind demonstration with independent source tree.
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new();vp.size=Vector2i(544,416)
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    vp.disable_3d=true;root.add_child(vp)
    var scene: Node2D=load("res://scenes/a32_groundfirst_scene.tscn").instantiate()
    vp.add_child(scene)
    var player: CharacterBody2D=scene.get_node("YSort/Player")
    player.set_physics_process(false)
    player.get_node("Camera2D").enabled=false
    var fixed_camera:=Camera2D.new()
    fixed_camera.position=Vector2(230,686)
    fixed_camera.zoom=Vector2(1.35,1.35)
    scene.add_child(fixed_camera);fixed_camera.enabled=true
    var tree=scene.get_node("YSort/obj_058_a36f_dense_tree_02")
    var foot:Vector2=tree.global_position
    for case in ["BEHIND","FRONT"]:
        player.global_position=foot+Vector2(0,-42 if case=="BEHIND" else 42)
        for f in range(4):await process_frame
        await RenderingServer.frame_post_draw
        var img=vp.get_texture().get_image()
        if img.get_size()!=Vector2i(544,416):push_error("wrong native screenshot size");quit(10);return
        var target="res://qa/a32_godot_472_tree_"+case.to_lower()+"_native.png"
        if img.save_png(target)!=OK:push_error("could not save screenshot");quit(11);return
        print("A32 TREE native frame ",case," at ",player.global_position," saved ",target)
    quit(0)
