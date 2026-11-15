extends SceneTree
## A35 R8 original Godot runtime wall-frame probe, not a GPU profiler.
const SCENE := "res://scenes/a35_r8_canopy_shadow_scene.tscn"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.disable_3d=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var world:Node2D=load(SCENE).instantiate()
    vp.add_child(world)
    var actor=world.get_node("YSort/Player")
    actor.get_node("Camera2D").enabled=false
    actor.visible=false
    var ambience=world.get_node("HD2DAtmosphere")
    ambience.animate=false
    ambience.phase=2
    ambience.raining=false
    ambience._update_phase()
    var shadow=world.get_node("ForestLightStudy")
    shadow.set_study_enabled(true)
    shadow.set_shadows_enabled(true)
    var data:Dictionary={"mode":"Godot 4.7.2 wall-frame measurement (NOT GPU-only duration)",
        "frames_per_sample":50,"samples":[],"tree_canopy_nodes":shadow.canopy_caster_count,
        "tree_trunk_nodes":shadow.caster_count}
    for mode in [false,true,true,false,false,true]:
        shadow.set_canopy_enabled(mode)
        for i in range(12):
            await RenderingServer.frame_post_draw
        var started:=Time.get_ticks_usec()
        for i in range(50):
            await RenderingServer.frame_post_draw
        var elapsed:=Time.get_ticks_usec()-started
        var ms:=float(elapsed)/50000.0
        data["samples"].append({"canopy_enabled":mode,"average_wall_ms":snapped(ms,.001)})
        print("A35 R8 benchmark canopy=",mode," 50 frames avg wall ms=",snapped(ms,.001))
    var counts:Dictionary={"off":[],"on":[]}
    for sample in data["samples"]:
        var key="on" if sample["canopy_enabled"] else "off"
        counts[key].append(sample["average_wall_ms"])
    for key in counts:
        var values:Array=counts[key]
        var sum_ms:=0.0
        for value in values:
            sum_ms+=float(value)
        data[key+"_average_wall_ms"]=snapped(sum_ms/values.size(),.001)
    data["interpretation"]="indicative real scene scheduling/frame-wall duration including rendering and engine; not isolated GPU time, not a 60fps guarantee"
    var out=FileAccess.open("res://qa_a35/A35_R8_GODOT_WALL_FRAME_BENCH.json",FileAccess.WRITE)
    if out==null:
        push_error("R8 benchmark result write failed");quit(70);return
    out.store_string(JSON.stringify(data,"  "))
    out.close()
    print("A35 R8 native wall-frame probe PASS ",JSON.stringify(data))
    quit(0)
