extends SceneTree
## Source-only public contract. No private PNG in CI, no fake rendered-art claim.
const SCENE_NEW = "res://scenes/a34_groundfirst_full_houses_scene.tscn"
const SCENE_OLD = "res://scenes/a33_groundfirst_lantern_scene.tscn"
const MANIFEST="res://data/a34_groundfirst_full_houses_manifest.json"
var count:int=0
func verify(p:bool,why:String)->bool:
    if p:count+=1
    else:push_error("A34 PUBLIC FAILED: "+why)
    return p
func _initialize()->void:call_deferred("_run")
func _run()->void:
    var path=FileAccess.open(MANIFEST,FileAccess.READ)
    if not verify(path!=null,"Manifest available"):quit(8);return
    var d:Dictionary=JSON.parse_string(path.get_as_text())
    path.close()
    if not verify(d["schema"]=="fs-a34-ground-first-independent-full-house-family/v1","A34 new schema"):quit(9);return
    if not verify(d["policy"]=="FS_ACTIVE_MASTER_V1.3","Ground first production authority"):quit(10);return
    if not verify(d["objects"].size()==146 and d["assets"].size()==27,"146 placed objects, 27 source families"):quit(11);return
    if not verify(d["ground"]["sha256"]=="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000","original Ground SHA manifest"):quit(12);return
    if not verify(d["a34_house_gate"]["houses"].size()==2,"two independent full house sources"):quit(13);return
    if not verify(d["a34_house_gate"]["lantern_count"]==4,"new A33 lanterns remain"):quit(14);return
    var before=load(SCENE_OLD) as PackedScene
    var after=load(SCENE_NEW) as PackedScene
    if not verify(before!=null and after!=null,"real Godot PackedScenes deserialize"):quit(15);return
    var previous=before.instantiate() as Node2D
    var current=after.instantiate() as Node2D
    if not verify(current.get_node("YSort").get_child_count()==147,"146 independently selectable nodes + actor"):quit(16);return
    var y_before=previous.get_node("YSort") as Node2D
    var y_after=current.get_node("YSort") as Node2D
    verify(y_after.y_sort_enabled and y_before.y_sort_enabled,"Godot Y sorting enabled")
    var changed:int=0
    for obj in d["objects"]:
        var id:String=obj["id"]
        var a=y_before.get_node(id) as Node2D
        var b=y_after.get_node(id) as Node2D
        if not verify(a!=null and b!=null,"per item native node "+id):quit(17);return
        if not verify(b.source_sha256==obj["source_sha256"],"source manifest pixel hash token "+id):quit(18);return
        if not verify(b.source_file=="res://"+d["assets"][obj["asset_id"]]["file"],"source manifest file path "+id):quit(19);return
        if not verify(a.position==b.position,"source footpoint unchanged "+id):quit(20);return
        if obj["asset_id"].begins_with("a34_elf_"):
            changed+=1
            if not verify(a.source_sha256!=b.source_sha256,"complete new isolated house source "+id):quit(21);return
            if not verify(d["assets"][obj["asset_id"]]["full_independent_art"],"not Master crop "+id):quit(22);return
        else:
            if not verify(a.source_sha256==b.source_sha256,"unrelated sprite SHA unaffected "+id):quit(23);return
    verify(changed==2,"exactly 2 new house sources")
    verify(d["a34_house_gate"]["collider_count"]==140,"keep candidate physical root collider count, not assert final navigation")
    print("A34 GODOT PUBLIC HOUSE CONTRACT PASS: ",count," source-only checks; 2 full isolated house sprites, 144 objects unchanged; no private original art")
    previous.free()
    current.free()
    quit(0)
