extends SceneTree
## A35 Godot 4.7.2 private real-asset verification. No VX dependency.
const OLD := "res://scenes/a34_r4_house_pair_scene.tscn"
const NEW := "res://scenes/a35_r1_forest_groves_scene.tscn"
const MANIFEST := "res://data/a35_r1_forest_groves_manifest.json"
var checks: int = 0
func check(cond: bool, label: String) -> bool:
    if cond:
        checks += 1
        return true
    push_error("A35 R1 CONTRACT FAIL: " + label)
    return false
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var f := FileAccess.open(MANIFEST,FileAccess.READ)
    if not check(f!=null,"manifest readable"):
        quit(10);return
    var d:Dictionary=JSON.parse_string(f.get_as_text())
    f.close()
    if not check(d.get("schema")=="fs-a35-r1-independent-forest-groves/v1","correct schema"):
        quit(11);return
    if not check(d["objects"].size()==187,"all 187 independent owners in manifest"):
        quit(12);return
    if not check(FileAccess.get_sha256("res://private_assets/ground_only.png")==d["ground"]["sha256"],"Ground SHA unchanged"):
        quit(13);return
    if not check(FileAccess.get_sha256(OLD)==d["a35_gate"]["immutable_a34_scene_sha256"],"A34 source scene immutable"):
        quit(14);return
    var baseline:PackedScene=load(OLD)
    var candidate:PackedScene=load(NEW)
    if not check(baseline!=null and candidate!=null,"native Godot scenes both parsed"):
        quit(15);return
    var old:Node2D=baseline.instantiate()
    var world:Node2D=candidate.instantiate()
    root.add_child(old);root.add_child(world)
    await process_frame
    await physics_frame
    if not check(world.get_node("FullGround").texture!=null,"real original ground texture loaded"):
        quit(16);return
    if not check(world.get_node("YSort").y_sort_enabled,"real YSort on"):
        quit(17);return
    if not check(old.get_node("YSort").get_child_count()==147,"sealed A34 owner count"):
        quit(18);return
    if not check(world.get_node("YSort").get_child_count()==188,"A35 owner count + player"):
        quit(19);return
    var appended:int=0
    for item in d["objects"]:
        var name:String=str(item["id"])
        var instance:Node2D=world.get_node_or_null("YSort/"+name)
        if not check(instance!=null,"owner exists: "+name):quit(20);return
        var sprite:Sprite2D=instance.get_node("Sprite")
        if not check(sprite.texture!=null,"source texture: "+name):quit(21);return
        if not check(instance.source_object_id==name,"owner identity: "+name):quit(22);return
        var asset:Dictionary=d["assets"][item["asset_id"]]
        if not check(FileAccess.get_sha256("res://"+str(asset["file"]))==str(item["source_sha256"]),"source bytes SHA: "+name):quit(23);return
        if not check(sprite.texture.get_width()==int(asset["size"][0]) and sprite.texture.get_height()==int(asset["size"][1]),"source full RGBA: "+name):quit(24);return
        if item["root_collision"]:
            var collision:CollisionShape2D=instance.get_node("Body/Collision")
            if not check(collision.shape is RectangleShape2D,"physical foot shape: "+name):quit(25);return
        if name.begins_with("a35_grove_"):
            appended+=1
            if not check(instance.source_semantic=="tree","new owner must be tree: "+name):quit(26);return
            if not check(instance.footprint_width_px==22 and instance.footprint_height_px==12,"new trunk footprint: "+name):quit(27);return
            var foot:Vector2=instance.position
            var trunk:=Rect2(foot.x-11,foot.y-12,22,12)
            for safe in d["a35_gate"]["protected_road_rectangles"]:
                var protection:=Rect2(float(safe[0]),float(safe[1]),float(safe[2]-safe[0]),float(safe[3]-safe[1]))
                if not check(not trunk.intersects(protection),"road trunk intrusion: "+name):quit(28);return
        else:
            var old_node:Node2D=old.get_node_or_null("YSort/"+name)
            if not check(old_node!=null and old_node.position==instance.position,"A34 stable node and foot: "+name):quit(29);return
    if not check(appended==41,"41 added independent trees"):
        quit(30);return
    print("A35 R1 NATIVE REAL PASS: "+str(checks)+"/"+str(checks)+" checks; new 41 groves, 187 owners; original A34 scene and Ground sealed")
    old.queue_free();world.queue_free();await process_frame
    quit(0)
