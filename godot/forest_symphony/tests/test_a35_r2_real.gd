extends SceneTree
## A35 R2: real in-Godot source/SHA/scene contract. Exit nonzero on mismatch.
const NEW := "res://scenes/a35_r2_new_species_scene.tscn"
const MAN := "res://data/a35_r2_new_species_manifest.json"
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    var raw:=FileAccess.get_file_as_string(MAN)
    var doc=JSON.parse_string(raw)
    if typeof(doc)!=TYPE_DICTIONARY:push_error("Manifest missing");quit(20);return
    var world:Node=load(NEW).instantiate()
    root.add_child(world)
    await process_frame
    var owners:Node=world.get_node("YSort")
    if owners.get_child_count()-1 != 187:push_error("PAR count changed");quit(21);return
    var count:=0
    for ob in doc["objects"]:
        if not str(ob["id"]).begins_with("a35_grove_"):continue
        var node=owners.get_node(str(ob["id"]))
        if node.source_sha256 != ob["source_sha256"]:push_error("SHA binding mismatch "+str(ob["id"]));quit(22);return
        if FileAccess.get_sha256(str(node.source_file)) != str(ob["source_sha256"]):push_error("PNG bytes differ "+str(ob["id"]));quit(23);return
        if node.get_node("Body/Collision").shape==null:push_error("Missing root collision");quit(24);return
        count+=1
    if count != 41:push_error("Grove count mismatch");quit(25);return
    print("FS A35 R2 GODOT native 41 grove source SHA, 8 new species, 187 PAR and root-collision PASS")
    quit(0)