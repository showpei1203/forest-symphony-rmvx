extends SceneTree
## PUBLIC source-only test: proves scene contract and unchanged Ground-first metadata.
## Does NOT require private PNGs or grant any aesthetic/gameplay approval.
const SCENE_NEW="res://scenes/a35_independent_tree_family_scene.tscn"
const SCENE_OLD="res://scenes/a34_groundfirst_full_houses_scene.tscn"
const MANIFEST="res://data/a35_independent_tree_family_manifest.json"
var checks:int=0
var failures:int=0
func ok(v:bool,reason:String)->bool:
    if v:checks+=1
    else:
        failures+=1
        push_error("A35 PUBLIC FAIL "+reason)
    return v
func _initialize()->void:call_deferred("_run")
func _run()->void:
    var txt=FileAccess.get_file_as_string(MANIFEST)
    if not ok(not txt.is_empty(),"manifest in source repo"):quit(1);return
    var m:Dictionary=JSON.parse_string(txt)
    if not ok(m["schema"]=="fs-a35-artist-owned-complete-tree-family/v1","new A35 semantic schema"):quit(2);return
    if not ok(m["policy"]=="FS_ACTIVE_MASTER_V1.3","Ground-first official policy"):quit(3);return
    if not ok(m["objects"].size()==146 and m["assets"].size()==31,"146 placed source owners/31 asset families"):quit(4);return
    ok(m["ground"]["sha256"]=="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000","unchanged ground SHA declaration")
    var old_scene=load(SCENE_OLD) as PackedScene
    var new_scene=load(SCENE_NEW) as PackedScene
    if not ok(old_scene!=null and new_scene!=null,"Godot 4.7.2 PackedScene parses"):quit(5);return
    var before=old_scene.instantiate() as Node2D
    var after=new_scene.instantiate() as Node2D
    var layer1=before.get_node("YSort") as Node2D
    var layer2=after.get_node("YSort") as Node2D
    ok(layer1.y_sort_enabled and layer2.y_sort_enabled,"actual native YSort layers")
    ok(layer2.get_child_count()==147,"146 user-selectable object nodes + player")
    var changed:int=0
    var unchanged:int=0
    for obj in m["objects"]:
        var id:String=obj["id"]
        var a=layer1.get_node_or_null(id) as Node2D
        var b=layer2.get_node_or_null(id) as Node2D
        if not ok(a!=null and b!=null,"actual independent Godot node "+id):quit(6);return
        if not ok(a.position==b.position,"footpoint stays put "+id):quit(7);return
        if not ok(b.source_sha256==obj["source_sha256"],"serialized native source hash "+id):quit(8);return
        if not ok(b.source_file=="res://"+m["assets"][obj["asset_id"]]["file"],"serialized independent file path "+id):quit(9);return
        if String(obj["asset_id"]).begins_with("a35_"):
            changed+=1
            if not ok(a.source_sha256!=b.source_sha256,"genuine full tree replacement "+id):quit(10);return
            ok(m["assets"][obj["asset_id"]]["full_independent_art"],"art sheet source is independently authored complete tree "+id)
        else:
            unchanged+=1
            if not ok(a.source_sha256==b.source_sha256,"138 unchanged unrelated objects "+id):quit(11);return
    ok(changed==8 and unchanged==138,"8 new full tree instances, 138 retained objects")
    ok(m["a35_tree_gate"]["art_status"]=="HOLD","do not claim ART PASS")
    var biome=JSON.parse_string(FileAccess.get_file_as_string("res://data/fs_six_biomes_world_catalog.json")) as Dictionary
    if not ok(biome.get("schema")=="fs-six-biomes-maze-village-world-art/v1","6-biome source spec present"):quit(12);return
    var biomes:Array=biome["biomes"]
    ok(biomes.size()==6,"six distinct terrain families")
    var ids:Dictionary={}
    for b in biomes:
        var bid:String=b["id"]
        ok(not ids.has(bid),"unique biome id "+bid)
        ids[bid]=true
        ok(b["village"]["ground_materials"].size()>=3,"village ground material set "+bid)
        ok(b["maze"]["ground_materials"].size()>=3,"maze ground material set "+bid)
        ok(b["village"]["par_families"].size()>=3,"village independent PAR family set "+bid)
        ok(b["maze"]["par_families"].size()>=3,"maze independent PAR family set "+bid)
        ok(b["village"]["scene_id"]!=b["maze"]["scene_id"],"two scenes per biome "+bid)
    var cgrid:Array=biome["large_map_technical_pilot"]["logical_grid"]
    ok(cgrid.size()==2 and int(cgrid[0])==80 and int(cgrid[1])==58,"80x58 large map contract")
    var cimage:Array=biome["large_map_technical_pilot"]["image_pixels"]
    ok(cimage.size()==2 and int(cimage[0])==2560 and int(cimage[1])==1856,"2560x1856 map dimension contract")
    if failures==0:print("A35 GODOT PUBLIC TREE+6-BIOME CONTRACT PASS: ",checks," checks; source-only, actual A35 PackedScene, four new independent art families, six future maze-village pairs")
    else:print("A35 GODOT PUBLIC CONTRACT FAIL: ",failures," assertions failed")
    before.free()
    after.free()
    quit(0 if failures==0 else 25)
