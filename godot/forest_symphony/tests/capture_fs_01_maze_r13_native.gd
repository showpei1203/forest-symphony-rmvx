extends SceneTree
## R13 original 1x Godot framebuffer, never a composited/generated preview.
const R12 := "res://scenes/fs_01_maze_r12_live_road_navigation_80x58.tscn"
const R13 := "res://scenes/fs_01_maze_r13_playable_entrance_bridge_exit_80x58.tscn"
const SIZE := Vector2i(2560,1856)
func _initialize()->void:call_deferred("_run")
func _fail(reason:String)->void:
    push_error("R13 NATIVE ORIGINAL GPU FAILURE: "+reason)
    quit(112)
func _capture(vp:SubViewport,path:String)->Image:
    for i in range(14):await process_frame
    await RenderingServer.frame_post_draw
    var frame:Image=vp.get_texture().get_image()
    if frame==null or frame.is_empty() or frame.get_size()!=SIZE:
        _fail("Invalid original GPU full native size for "+path);return null
    if frame.save_png(path)!=OK:
        _fail("Original full GPU frame failed to save "+path);return null
    print("R13 true Godot 4.7.2 full-frame source saved: ",path)
    return frame
func _run()->void:
    var vp:=SubViewport.new()
    vp.size=SIZE
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var base:Node2D=load(R12).instantiate()
    vp.add_child(base)
    base.get_node("YSort/Player/Camera2D").enabled=false
    base.get_node("YSort/Player").visible=false
    base.get_node("EditorGrid").visible=false
    var old:Image=await _capture(vp,"res://qa_a36c/FS_01_MAZE_R13_CONTROL_R12_ORIGINAL_GPU_1X.png")
    if old==null:return
    base.queue_free()
    await process_frame
    var next:Node2D=load(R13).instantiate()
    vp.add_child(next)
    next.get_node("YSort/Player/Camera2D").enabled=false
    next.get_node("YSort/Player").visible=false
    next.get_node("EditorGrid").visible=false
    var modern:Image=await _capture(vp,"res://qa_a36c/FS_01_MAZE_R13_NEW_SCENE_ORIGINAL_GPU_1X.png")
    if modern==null:return
    if old.get_format()!=modern.get_format() or old.get_data()!=modern.get_data():
        _fail("Original art RGB changed between R12 and R13 actor-hidden scene");return
    print("FS R13 ORIGINAL GPU PIXEL MATCH: 4,751,360 identical pixels; actual Ground/PAR not repainted")
    var actor:CharacterBody2D=next.get_node("YSort/Player")
    actor.visible=true
    actor.global_position=Vector2(10*32+16,29*32+16)
    if await _capture(vp,"res://qa_a36c/FS_01_MAZE_R13_BRIDGE_PLAYER_ORIGINAL_GPU_1X.png")==null:return
    actor.global_position=Vector2(49*32+16,5*32+16)
    if await _capture(vp,"res://qa_a36c/FS_01_MAZE_R13_EXIT_PLAYER_ORIGINAL_GPU_1X.png")==null:return
    print("FS_01_MAZE R13 NATIVE GPU PASS: R12 vs R13 image pixel-exact at 1x, original GPU bridge actor, original GPU north-exit actor, 4 original frames. ART HOLD")
    quit(0)
