extends SceneTree
## Full 1:1 original GPU frames from PRIVATE A36B source and A36C R7 reconciled scene.
const BASE := "res://scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
const NEXT := "res://scenes/fs_01_maze_r8_water_collision_80x58.tscn"
const SIZE := Vector2i(2560,1856)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var vp := SubViewport.new()
    vp.size=SIZE
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    for cfg in [
        {"path":BASE,"suffix":"FS_01_MAZE_R7_BASE"},
        {"path":NEXT,"suffix":"FS_01_MAZE_R8_WATER"}
    ]:
        var world: Node2D=load(str(cfg["path"])).instantiate()
        vp.add_child(world)
        var actor: CharacterBody2D=world.get_node("YSort/Player")
        actor.get_node("Camera2D").enabled=false
        actor.visible=false
        world.get_node("EditorGrid").visible=false
        for i in range(12):
            await process_frame
        await RenderingServer.frame_post_draw
        var frame: Image=vp.get_texture().get_image()
        if frame==null or frame.is_empty() or frame.get_size()!=SIZE:
            push_error("Forest Dungeon GPU original 2560x1856 frame invalid");quit(71);return
        var path: String="res://qa_a36c/FS_FOREST_DUNGEON_WATER_%s_NATIVE_1X.png" % str(cfg["suffix"])
        if frame.save_png(path)!=OK:
            push_error("Forest Dungeon Godot original GPU PNG save failure");quit(72);return
        print("FS FOREST DUNGEON REAL GODOT GPU: "+path)
        world.queue_free()
        await process_frame
    print("FS FOREST DUNGEON FS_01_MAZE R7 vs FS_01_MAZE R8 WATER OFF/ON two FULL 2560x1856 original native GPU captures PASS 2/2; ART HOLD")
    quit(0)
