extends SceneTree
## 4.7.2 native full framebuffer and *native* 1x source ROI gate.
const OLD := "res://scenes/a33_groundfirst_lantern_scene.tscn"
const NEW := "res://scenes/a34_r4_house_pair_scene.tscn"
var captured:Dictionary={}
func _initialize() -> void: call_deferred("_capture")
func _capture() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(1280,928)
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    vp.disable_3d=true
    root.add_child(vp)
    for scenario in [
        {"scene":OLD,"name":"A34_R4_BASELINE_A33_NATIVE.png","actor":false},
        {"scene":NEW,"name":"A34_R4_HOUSE_PAIR_NATIVE.png","actor":false},
        {"scene":NEW,"name":"A34_R4_ACTOR_BEHIND_LEFT_HOUSE_NATIVE.png","actor":true,"foot":Vector2(285,360)},
        {"scene":NEW,"name":"A34_R4_ACTOR_FRONT_LEFT_HOUSE_NATIVE.png","actor":true,"foot":Vector2(285,455)},
    ]:
        var world:Node2D=load(scenario["scene"]).instantiate()
        vp.add_child(world)
        var actor:CharacterBody2D=world.get_node("YSort/Player")
        actor.get_node("Camera2D").enabled=false
        actor.visible=bool(scenario["actor"])
        if scenario["actor"]: actor.position=scenario["foot"]
        for i in range(8):await process_frame
        await RenderingServer.frame_post_draw
        var im:Image=vp.get_texture().get_image()
        if im==null or im.is_empty() or im.get_size()!=Vector2i(1280,928):
            push_error("A34 real native viewport missing");quit(30);return
        if im.save_png("res://qa_a34/"+scenario["name"])!=OK:
            push_error("A34 native PNG save failed");quit(31);return
        captured[scenario["name"]]=im.duplicate()
        print("A34 GODOT 4.7.2 REAL NATIVE CAPTURE: " + scenario["name"])
        world.queue_free()
        await process_frame
    var left:Image=captured["A34_R4_BASELINE_A33_NATIVE.png"]
    var right:Image=captured["A34_R4_HOUSE_PAIR_NATIVE.png"]
    var outside:int=0
    var inside:int=0
    for y in range(928):
        for x in range(1280):
            if left.get_pixel(x,y)!=right.get_pixel(x,y):
                var at_left:bool=(x>=158 and x<412 and y>=155 and y<407)
                var at_right:bool=(x>=939 and x<1153 and y>=168 and y<420)
                if at_left or at_right:inside+=1
                else:outside+=1
    print("A34 GODOT 4.7.2 NATIVE PIXEL ROI: inside="+str(inside)+" outside="+str(outside))
    if outside!=0 or inside==0:
        push_error("A34 native source ROI mismatch or no house pixel delta");quit(32);return
    print("A34 R4 NATIVE A/B HOUSE ROI PASS, 0 changed pixels outside house rectangles")
    quit(0)
