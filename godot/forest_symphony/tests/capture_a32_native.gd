extends SceneTree
## Actual Godot framebuffer screenshot. No Pillow or generated mock can impersonate this source.
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    vp.disable_3d=true
    vp.transparent_bg=false
    root.add_child(vp)
    var scene:Node2D=load("res://scenes/a32_groundfirst_scene.tscn").instantiate()
    vp.add_child(scene)
    var player:=scene.get_node("YSort/Player") as CharacterBody2D
    player.hide()
    player.get_node("Camera2D").enabled=false
    for i in range(4):await process_frame
    await RenderingServer.frame_post_draw
    var img:=vp.get_texture().get_image()
    if img==null or img.is_empty():push_error("A32 native framebuffer empty");quit(7);return
    if img.get_size()!=Vector2i(1280,928):push_error("A32 wrong viewport size");quit(8);return
    var path: String="res://qa/a32_godot_472_native_groundfirst_full.png"
    var err=img.save_png(path)
    if err!=OK:push_error("A32 native capture failure");quit(9);return
    print("A32 GODOT NATIVE RENDER PASS: ",path)
    quit(0)
