extends SceneTree
## A36B real owner-only source test: no artistic approval claimed.
var checks := 0
var failures: Array[String] = []
func gate(ok:bool, description:String) -> void:
    if ok: checks += 1
    else:
        failures.append(description)
        push_error("A36B REAL FAIL " + description)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var m:Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/a36b_ecological_tree_manifest.json")) as Dictionary
    if m.is_empty(): push_error("A36B no manifest"); quit(4); return
    gate(m.get("schema")=="fs-a36b-ground-first-ecological-complete-tree-family/v1", "schema")
    gate(m["objects"].size()==326,"326 editable objects")
    gate(m["assets"].size()==11,"eleven independently created families")
    gate(m["ecological_tree_upgrade"]["replacements_total"]==62,"62 intentional tree replacements")
    gate(m["ecological_tree_upgrade"]["unchanged_object_owners"]==264,"264 unchanged objects")
    gate(FileAccess.get_sha256("res://private_assets/a36_ground_only_2560x1856.png")==m["runtime_ground"]["sha256"],"Ground source unchanged")
    gate(FileAccess.get_sha256("res://private_assets/a36b_contact_shadows_2560x1856.png")==m["shadow"]["sha256"],"independent shadow source")
    var p=load("res://scenes/a36b_large_forest_tree_ecology_80x58.tscn") as PackedScene
    gate(p!=null,"real A36B PackedScene")
    if p==null:quit(5);return
    var w=p.instantiate() as Node2D
    root.add_child(w)
    await process_frame
    await physics_frame
    gate(w.get_node("FullGround").texture!=null,"real Ground textured")
    gate(w.get_node("ContactShadows").texture!=null,"real Shadow textured")
    gate(w.get_node("YSort").get_child_count()==327,"YSort 326 owners + Player")
    var seen={}
    var pine=0
    var willow=0
    for o in m["objects"]:
        var id:String=o["id"]
        gate(not seen.has(id),"unique id "+id)
        seen[id]=true
        var n=w.get_node_or_null("YSort/"+id) as Node2D
        if n==null: failures.append("missing owner "+id); break
        gate(n.position==Vector2(o["foot"][0],o["foot"][1]),"foot unchanged "+id)
        var a:Dictionary=m["assets"][o["family"]]
        gate(n.source_file==a["file"],"complete PAR file "+id)
        gate(n.source_sha256==a["sha"],"PAR owner SHA "+id)
        gate(FileAccess.get_sha256(a["file"])==a["sha"],"real full PAR source "+id)
        var spr=n.get_node_or_null("Sprite") as Sprite2D
        gate(spr!=null and spr.texture!=null,"Sprite2D full asset "+id)
        if spr and spr.texture:gate(spr.texture.get_size()==Vector2(a["w"],a["h"]),"full asset scale "+id)
        var c=n.get_node_or_null("Body/Collision") as CollisionShape2D
        gate(c!=null and c.shape!=null,"physical root footprint "+id)
        if o["family"].begins_with("a36b_moss_pine_"):pine+=1
        if o["family"].begins_with("a36b_river_willow_"):willow+=1
    gate(pine==40,"forty highland pines")
    gate(willow==22,"twenty-two riverbank willows")
    print("A36B REAL GODOT SOURCE QA PASS: ",checks," checks, ",pine," pines, ",willow," willows; Ground SHA unchanged, ART HOLD")
    quit(0 if failures.is_empty() else 20)
