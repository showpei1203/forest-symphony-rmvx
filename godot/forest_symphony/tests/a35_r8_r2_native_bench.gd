extends SceneTree
## A35 R8 R2 real Godot frame-wall timing smoke test, NOT isolated GPU timing.
const SCENE := "res://scenes/a35_r8_r2_light_balance_scene.tscn"
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var viewport:=SubViewport.new()
    viewport.size=Vector2i(1280,928)
    viewport.disable_3d=true
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var scene:Node2D=load(SCENE).instantiate()
    viewport.add_child(scene)
    var player=scene.get_node("YSort/Player")
    player.get_node("Camera2D").enabled=false
    player.visible=false
    var fx=scene.get_node("HD2DAtmosphere")
    fx.animate=false
    fx.phase=2
    fx.raining=false
    fx._update_phase()
    var study=scene.get_node("ForestLightStudy")
    study.set_canopy_enabled(true)
    study.set_shadows_enabled(true)
    study.set_study_enabled(true)
    var report:Dictionary={
        "engine":"Godot 4.7.2 AMD RX 6700 XT OpenGL compatibility",
        "method":"6*50 scene wall-frame intervals; likely vsync-limited, NOT isolated GPU timings",
        "frames_per_sample":50,
        "samples":[],
        "tree_trunks":study.caster_count,
        "tree_canopies":study.canopy_caster_count
    }
    var modes:Array[Dictionary]=[
        {"name":"hard","fill":0.0,"second":false},
        {"name":"fill","fill":0.24,"second":false},
        {"name":"dual","fill":0.24,"second":true},
        {"name":"dual","fill":0.24,"second":true},
        {"name":"fill","fill":0.24,"second":false},
        {"name":"hard","fill":0.0,"second":false}
    ]
    for mode in modes:
        study.set_fill_fraction(float(mode["fill"]))
        study.set_multi_light_enabled(bool(mode["second"]))
        for i in range(10):
            await RenderingServer.frame_post_draw
        var before=Time.get_ticks_usec()
        for j in range(50):
            await RenderingServer.frame_post_draw
        var ms=float(Time.get_ticks_usec()-before)/50000.0
        report["samples"].append({"mode":mode["name"],"wall_ms":snapped(ms,0.001)})
        print("A35 R8 R2 native wall-frame "+str(mode["name"])+" 50 frames: "+str(snapped(ms,0.001))+" ms")
    var means:Dictionary={}
    for item in report["samples"]:
        var key:String=str(item["mode"])
        if not means.has(key):
            means[key]=[]
        means[key].append(float(item["wall_ms"]))
    for key in means:
        var sum_ms:=0.0
        for value in means[key]:
            sum_ms+=value
        report[key+"_mean_wall_ms"]=snapped(sum_ms/means[key].size(),0.001)
    var file=FileAccess.open("res://qa_a35/A35_R8_R2_GODOT_WALL_BENCH.json",FileAccess.WRITE)
    if file==null:
        push_error("R8 R2 cannot write wall-frame benchmark");quit(64);return
    file.store_string(JSON.stringify(report,"  "))
    file.close()
    print("A35 R8 R2 real Godot wall-frame benchmark PASS "+JSON.stringify(report))
    quit(0)
