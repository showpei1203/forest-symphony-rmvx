extends SceneTree
## Real GPU framebuffer for candidate vs sealed R4; pixel delta restricted to new tree ROI.
const OLD := "res://scenes/a35_r1_forest_groves_scene.tscn"
const NEW := "res://scenes/a35_r2_new_species_scene.tscn"
const MANIFEST := "res://data/a35_r2_new_species_manifest.json"
const W := 1280
const H := 928
var captures:Dictionary={}
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    var vp:=SubViewport.new()
    vp.size=Vector2i(W,H)
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    vp.disable_3d=true
    root.add_child(vp)
    var scenarios: Array[Dictionary] = [
        {"scene":OLD,"file":"A35_R2_A34_BASELINE_NATIVE.png","actor":false},
        {"scene":NEW,"file":"A35_R2_FOREST_GROVES_NATIVE.png","actor":false},
        {"scene":NEW,"file":"A35_R2_GROVE_ACTOR_BEHIND_NATIVE.png","actor":true,"foot":Vector2(1247,174)},
        {"scene":NEW,"file":"A35_R2_GROVE_ACTOR_FRONT_NATIVE.png","actor":true,"foot":Vector2(1247,263)},
    ]
    for item in scenarios:
        var scene:PackedScene=load(item["scene"])
        if scene==null:push_error("A35 scene load failed");quit(31);return
        var world:Node2D=scene.instantiate()
        vp.add_child(world)
        var player:CharacterBody2D=world.get_node("YSort/Player")
        player.get_node("Camera2D").enabled=false
        player.visible=bool(item["actor"])
        if bool(item["actor"]):player.position=item["foot"]
        for i in range(8):await process_frame
        await RenderingServer.frame_post_draw
        var im:Image=vp.get_texture().get_image()
        if im==null or im.is_empty() or im.get_size()!=Vector2i(W,H):
            push_error("A35 native frame missing");quit(32);return
        if im.save_png("res://qa_a35/"+item["file"])!=OK:
            push_error("A35 PNG save failed");quit(33);return
        captures[item["file"]]=im.duplicate()
        print("A35 R2 GODOT REAL GPU CAPTURE: "+item["file"])
        world.queue_free();await process_frame
    var f:=FileAccess.open(MANIFEST,FileAccess.READ)
    if f==null:push_error("A35 manifest missing");quit(34);return
    var d:Dictionary=JSON.parse_string(f.get_as_text());f.close()
    var roi:=PackedByteArray()
    roi.resize(W*H)
    for ob in d["objects"]:
        if not str(ob["id"]).begins_with("a35_grove_"):continue
        var x0:int=maxi(0,int(ob["x"])-2)
        var y0:int=maxi(0,int(ob["y"])-2)
        var x1:int=mini(W,int(ob["x"])+int(ob["w"])+3)
        var y1:int=mini(H,int(ob["y"])+int(ob["h"])+3)
        for y in range(y0,y1):
            for x in range(x0,x1):roi[y*W+x]=1
    # A35 R2 replaces variable-size tree silhouettes; union old AND new source footprints.
    # Using only new rectangles yields false leakage at 187 pixels in the first GPU run.
    var previous:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/a35_r1_forest_groves_manifest.json"))
    for ob in previous["objects"]:
        if not str(ob["id"]).begins_with("a35_grove_"):continue
        var px0:int=maxi(0,int(ob["x"])-2)
        var py0:int=maxi(0,int(ob["y"])-2)
        var px1:int=mini(W,int(ob["x"])+int(ob["w"])+3)
        var py1:int=mini(H,int(ob["y"])+int(ob["h"])+3)
        for iy in range(py0,py1):
            for ix in range(px0,px1):roi[iy*W+ix]=1
    var a:Image=captures["A35_R2_A34_BASELINE_NATIVE.png"]
    var b:Image=captures["A35_R2_FOREST_GROVES_NATIVE.png"]
    var inside:int=0;var outside:int=0
    for y in range(H):
        for x in range(W):
            if a.get_pixel(x,y)!=b.get_pixel(x,y):
                if roi[y*W+x]==1:inside+=1
                else:outside+=1
    print("A35 R2 GODOT REAL GPU ROI: changed_inside="+str(inside)+" changed_outside="+str(outside))
    if inside<2000 or outside!=0:
        push_error("A35 native ROI regression");quit(35);return
    print("A35 R2 NATIVE A/B GROVE ROI PASS: zero changed pixels outside new tree source rectangles")
    quit(0)