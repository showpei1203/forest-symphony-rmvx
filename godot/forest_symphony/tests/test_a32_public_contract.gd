extends SceneTree
## Public GitHub CI without any private images, source-only manifest and node structure.
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    var p=FileAccess.open("res://data/a32_groundfirst_manifest.json",FileAccess.READ)
    if p==null:push_error("A32 public manifest missing");quit(11);return
    var data=JSON.parse_string(p.get_as_text());p.close()
    assert(data["status"]=="CANDIDATE_ART_NOT_APPROVED")
    assert(int(data["canvas"][0])==1280 and int(data["canvas"][1])==928)
    assert(data["policy"]=="FS_ACTIVE_MASTER_V1.3")
    assert(data["objects"].size()==146)
    assert(data["assets"].size()==27)
    assert(data["ground"]["no_foreground_buildings_trees"])
    assert(data["objective"].contains("not cut from flattened scene"))
    var s=load("res://scenes/a32_groundfirst_scene.tscn") as PackedScene
    assert(s!=null)
    var rootnode=s.instantiate()
    assert(rootnode.get_node("YSort").y_sort_enabled)
    assert(rootnode.get_node("YSort").get_child_count()==147)
    var sources={}
    for o in data["objects"]:
        assert(o["source_sha256"]==data["assets"][o["asset_id"]]["sha256"])
        var node=rootnode.get_node_or_null("YSort/"+o["id"])
        assert(node!=null)
        assert(node.source_object_id==o["id"])
        assert(node.source_file=="res://"+data["assets"][o["asset_id"]]["file"])
        sources[o["asset_id"]]=true
    assert(sources.size()==27)
    print("A32 GODOT SOURCE-ONLY PUBLIC PASS: ",data["objects"].size()," truly independent placed PAR sprites, 27 families")
    rootnode.free()
    quit(0)
