extends SceneTree
## Godot 4.7.2 real owner-only A34 R4 independent houses + unchanged A33 baseline.
const SCENE_NEW := "res://scenes/a34_r4_house_pair_scene.tscn"
const SCENE_OLD := "res://scenes/a33_groundfirst_lantern_scene.tscn"
const MANIFEST := "res://data/a34_r4_house_pair_manifest.json"
var checks:int=0
func ensure(condition:bool, label:String) -> bool:
    if condition:
        checks+=1
        return true
    push_error("A34 R4 FAIL: " + label)
    return false
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
    var file:=FileAccess.open(MANIFEST,FileAccess.READ)
    if not ensure(file!=null,"manifest exists"):quit(10);return
    var d:Dictionary=JSON.parse_string(file.get_as_text())
    file.close()
    if not ensure(d.get("schema")=="fs-a34-r4-house-pair-independent-par/v1","schema"):quit(11);return
    if not ensure(FileAccess.get_sha256("res://private_assets/ground_only.png")==d["ground"]["sha256"],"Ground SHA unchanged"):quit(12);return
    if not ensure(d["objects"].size()==146,"all 146 independent PAR owners"):quit(13);return
    var baseline:PackedScene=load(SCENE_OLD)
    var revision:PackedScene=load(SCENE_NEW)
    if not ensure(baseline!=null and revision!=null,"A33 and A34 scenes open"):quit(14);return
    var old:Node2D=baseline.instantiate()
    var world:Node2D=revision.instantiate()
    root.add_child(old);root.add_child(world)
    await process_frame
    await physics_frame
    if not ensure(world.get_node("FullGround").texture!=null,"Ground real native load"):quit(15);return
    if not ensure(world.get_node("YSort").y_sort_enabled,"Y-sort active"):quit(16);return
    if not ensure(world.get_node("YSort").get_child_count()==147,"146 PAR + actor"):quit(17);return
    for obj in d["objects"]:
        var instance:Node2D=world.get_node_or_null("YSort/" + str(obj["id"]))
        if not ensure(instance!=null,"owner node "+str(obj["id"])):quit(18);return
        var sp:Sprite2D=instance.get_node("Sprite")
        if not ensure(sp.texture!=null,"independent texture "+str(obj["id"])):quit(19);return
        var asset:Dictionary=d["assets"][obj["asset_id"]]
        if not ensure(FileAccess.get_sha256("res://" + str(asset["file"]))==obj["source_sha256"],"source SHA "+str(obj["id"])):quit(20);return
        if not ensure(sp.texture.get_width()==int(asset["size"][0]) and sp.texture.get_height()==int(asset["size"][1]),"full RGBA dimensions "+str(obj["id"])):quit(21);return
        if obj["root_collision"]:
            var body:CollisionShape2D=instance.get_node("Body/Collision")
            if not ensure(body.shape!=null,"root collision real shape "+str(obj["id"])):quit(22);return
    var pair: Array = ["obj_001_a36f_elf_cottage_a","obj_002_a36f_elf_cottage_b"]
    for name in pair:
        var n:Node2D=world.get_node("YSort/"+name)
        var hit:CollisionShape2D=n.get_node("Body/Collision")
        if not ensure(n.source_semantic=="house","house semantic: "+name):quit(23);return
        if not ensure(n.footprint_width_px>100 and n.footprint_height_px==34,"house limited footprint: "+name):quit(24);return
        if not ensure(hit.shape is RectangleShape2D,"house physical RectangleShape2D: "+name):quit(25);return
    print("A34 R4 NATIVE REAL PASS: " + str(checks) + "/" + str(checks) + " checks; two PAR houses; 146 objects; Ground unchanged")
    old.queue_free();world.queue_free();await process_frame
    quit(0)
