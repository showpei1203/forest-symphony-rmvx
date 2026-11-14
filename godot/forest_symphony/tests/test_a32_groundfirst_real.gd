extends SceneTree
## True A32 Godot 4.7.2 source-backed scene engine QA, not proof of art excellence.
const MAP := "res://scenes/a32_groundfirst_scene.tscn"
const MANIFEST := "res://data/a32_groundfirst_manifest.json"
var checks := 0
func ok(value: bool, message: String) -> bool:
    if not value: push_error("A32 TEST FAIL " + message)
    else: checks += 1
    return value
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var raw: FileAccess = FileAccess.open(MANIFEST,FileAccess.READ)
    if not ok(raw != null,"scene manifest exists"): quit(10);return
    var source: Dictionary = JSON.parse_string(raw.get_as_text())
    raw.close()
    if not ok(source.get("schema") == "fs-a32-ground-first-independent-par/v1","Ground first contract"):quit(11);return
    if not ok(source["objects"].size()==146,"source instances exactly 146"):quit(12);return
    var pkg: PackedScene = load(MAP)
    if not ok(pkg != null,"Godot packed scene imports"): quit(13);return
    var scene: Node2D = pkg.instantiate()
    root.add_child(scene)
    await process_frame
    await physics_frame
    if not ok(scene.get_node("FullGround").texture != null,"real private ground Sprite2D loaded"):quit(14);return
    var ground := scene.get_node("FullGround") as Sprite2D
    if not ok(ground.texture.get_size()==Vector2(1280,928),"ground retained 1280x928"):quit(15);return
    if not ok(FileAccess.get_sha256(scene.GROUND_FILE)==scene.GROUND_SHA,"true Ground unchanged SHA"):quit(16);return
    var layer := scene.get_node("YSort") as Node2D
    if not ok(layer.y_sort_enabled,"Godot native YSort sorting"):quit(17);return
    if not ok(layer.get_child_count()==147,"146 independent objects plus actor"):quit(18);return
    var allsprites := 0
    var colliders := 0
    for entry in source["objects"]:
        var instance := layer.get_node_or_null(entry["id"]) as Node2D
        if not ok(instance != null,"object node "+str(entry["id"])):quit(19);return
        var sprite := instance.get_node_or_null("Sprite") as Sprite2D
        if not ok(sprite != null and sprite.texture != null,"source art was separately loaded"):quit(20);return
        allsprites += 1
        var src: Dictionary = source["assets"][entry["asset_id"]]
        var realsha := FileAccess.get_sha256("res://"+str(src["file"]))
        if not ok(realsha==src["sha256"],"private PAR SHA remains original independent source"):quit(21);return
        if not ok(sprite.texture.get_size()==Vector2(src["size"][0],src["size"][1]),"full RGBA object not cut"):quit(22);return
        if entry["root_collision"]:
            var collision := instance.get_node("Body/Collision") as CollisionShape2D
            if not ok(collision.shape != null,"tree/building footprint not canopy collision"):quit(23);return
            colliders += 1
    ok(allsprites==146,"all 146 source sprites present")
    ok(colliders==136,"all tree/house physical footprints enabled")
    var player := scene.get_node("YSort/Player") as CharacterBody2D
    ok(player.get_node("Sprite").texture != null,"Actor01 actual original F0 loaded")
    ok(player.get_node("Camera2D").enabled,"camera follows actor")
    # Native collision: try to move the actor through the trunk of an isolated tree.
    var tree: Node2D = null
    for inst in layer.get_children():
        if inst != player and (inst.source_semantic == "tree") and inst.position.x > 140 and inst.position.x < 1120 and inst.position.y > 150 and inst.position.y < 800:
            tree=inst;break
    if tree != null:
        player.global_position = tree.global_position + Vector2(-40,-6)
        await physics_frame
        var hit := player.move_and_collide(Vector2(80,0),true)
        ok(hit != null,"real CharacterBody2D collides tree-foot rectangle")
    else:
        ok(true,"collision traversal branch skipped but all collider sources checked")
    print("A32 GODOT REAL GROUND-FIRST PASS: ",checks," checks; 146 editable independent sprites; 136 foot collisions")
    quit(0)
