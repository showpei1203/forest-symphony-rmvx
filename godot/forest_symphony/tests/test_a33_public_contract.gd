extends SceneTree
## Explicit source-only CI: no private images available, tests every placed source and scene manifest node.
func _initialize()->void:call_deferred("_run")
func verify(condition:bool,desc:String)->bool:
    if not condition:
        push_error("A33 PUBLIC CONTRACT FAIL: "+desc)
        quit(21)
        return false
    return true
func _run()->void:
    var f=FileAccess.open("res://data/a33_groundfirst_lantern_manifest.json",FileAccess.READ)
    if not verify(f!=null,"line 12"):return
    var d:Dictionary=JSON.parse_string(f.get_as_text())
    f.close()
    if not verify(d.get("schema")=="fs-a33-ground-first-complete-independent-lantern/v1","line 15"):return
    if not verify(d.get("policy")=="FS_ACTIVE_MASTER_V1.3","line 16"):return
    if not verify(d["objects"].size()==146,"line 17"):return
    if not verify(d["assets"].size()==27,"line 18"):return
    if not verify(d["a33_gate"]["collider_count"]==140,"line 19"):return
    var old_feet:Array=d["a33_gate"]["old_footpoints"]
    var new_feet:Array=d["a33_gate"]["new_footpoints"]
    if not verify(int(old_feet[0][0])==496 and int(old_feet[0][1])==473 and int(new_feet[0][0])==438 and int(new_feet[0][1])==473,"A33 lamp relocated clear of well"):return
    for i in range(1,4):
        if not verify(int(old_feet[i][0])==int(new_feet[i][0]) and int(old_feet[i][1])==int(new_feet[i][1]),"remaining three lamp footpoints original"):return
    if not verify(int(d["a33_gate"]["old_size"][0])==32 and int(d["a33_gate"]["old_size"][1])==57,"line 21"):return
    if not verify(int(d["a33_gate"]["new_size"][0])==52 and int(d["a33_gate"]["new_size"][1])==124,"line 22"):return
    if not verify(d["a33_gate"]["new_asset_sha256"]=="6e0bed07a735cba3c908a5da4c81863222363cab01325aeeaaf1f821d63a6991","line 23"):return
    var packed:PackedScene=load("res://scenes/a33_groundfirst_lantern_scene.tscn")
    if not verify(packed!=null,"line 25"):return
    var old:PackedScene=load("res://scenes/a32_groundfirst_scene.tscn")
    if not verify(old!=null,"line 27"):return
    var rootnode:Node2D=packed.instantiate()
    if not verify(rootnode.get_node("YSort").y_sort_enabled,"line 29"):return
    if not verify(rootnode.get_node("YSort").get_child_count()==147,"line 30"):return
    var count=0
    for o in d["objects"]:
        var obj:Node2D=rootnode.get_node("YSort/"+o["id"])
        if not verify(obj!=null,"line 34"):return
        if not verify(obj.source_file=="res://"+d["assets"][o["asset_id"]]["file"],"line 35"):return
        if not verify(obj.source_sha256==o["source_sha256"],"line 36"):return
        if o["asset_id"]=="a33_ornate_lantern_complete":
            if not verify(obj.footprint_width_px==12.0,"line 38"):return
            if not verify(obj.footprint_height_px==8.0,"line 39"):return
            if not verify(obj.position==Vector2(o["foot"][0],o["foot"][1]),"line 40"):return
            count+=1
    if not verify(count==4,"line 42"):return
    print("A33 GODOT PUBLIC LAMP CONTRACT PASS: 146 source owners, 4 complete lamp replacements, original A32 retained, no private sources")
    rootnode.free()
    quit(0)
