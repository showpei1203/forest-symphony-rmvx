extends SceneTree
## A35 R8 R3 D1: six REAL Godot GPU frames, all three atmosphere phases.
## This is a separate test against the already sealed R8 R3 scene.
const SCENE := "res://scenes/a35_r8_r3_grove_balance_scene.tscn"
const RESOLUTION := Vector2i(1280,928)
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var viewport:=SubViewport.new()
    viewport.size=RESOLUTION
    viewport.disable_3d=true
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    for phase in range(3):
        for enabled in [false,true]:
            var world:Node2D=load(SCENE).instantiate()
            viewport.add_child(world)
            var actor=world.get_node("YSort/Player")
            actor.get_node("Camera2D").enabled=false
            actor.visible=false
            var atmosphere=world.get_node("HD2DAtmosphere")
            atmosphere.animate=false
            atmosphere.phase=phase
            atmosphere.raining=false
            atmosphere._update_phase()
            var light=world.get_node("ForestLightStudy")
            light.set_study_enabled(true)
            light.set_shadows_enabled(true)
            light.set_canopy_enabled(true)
            light.set_fill_fraction(0.24)
            light.set_multi_light_enabled(enabled)
            for frame in range(18):
                await process_frame
            await RenderingServer.frame_post_draw
            var im:Image=viewport.get_texture().get_image()
            if im==null or im.is_empty() or im.get_size()!=RESOLUTION:
                push_error("A35 R8 R3 D1 invalid GPU image");quit(61);return
            var phase_name:String=["DAY","DUSK","NIGHT"][phase]
            var setting:String="GROVE_ON" if enabled else "GROVE_OFF"
            var filename:String="res://qa_a35/A35_R8_R3_D1_%s_%s_NATIVE.png" % [phase_name,setting]
            if im.save_png(filename)!=OK:
                push_error("A35 R8 R3 D1 GPU file write fail");quit(62);return
            print("A35 R8 R3 D1 ACTUAL GODOT GPU: "+filename)
            world.queue_free()
            await process_frame
    print("A35 R8 R3 D1 all 6 original Godot day/dusk/night OFF/ON GPU frames PASS")
    quit(0)
