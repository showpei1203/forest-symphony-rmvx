extends SceneTree
## Full 1:1 original GPU frames from PRIVATE A36B source and A36C R6 scene.
const BASE := "res://scenes/a36b_large_forest_tree_ecology_80x58.tscn"
const NEXT := "res://scenes/a36c_r6_forest_groves_80x58.tscn"
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
        {"path":BASE,"suffix":"A36B_BASE"},
        {"path":NEXT,"suffix":"A36C_R6_FOREST"}
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
        var path: String="res://qa_a36c/FS_FOREST_DUNGEON_%s_NATIVE_1X.png" % str(cfg["suffix"])
        if frame.save_png(path)!=OK:
            push_error("Forest Dungeon Godot original GPU PNG save failure");quit(72);return
        print("FS FOREST DUNGEON REAL GODOT GPU: "+path)
        world.queue_free()
        await process_frame
    print("FS FOREST DUNGEON A36B vs A36C R6 two FULL 2560x1856 original native GPU captures PASS 2/2; ART HOLD")
    quit(0)
