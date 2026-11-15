extends SceneTree
## Real native Godot 4.7.2 source-backed A33. Separate A32 retained as immutable baseline.
const SCENE_NEW = "res://scenes/a33_groundfirst_lantern_scene.tscn"
const SCENE_OLD = "res://scenes/a32_groundfirst_scene.tscn"
const MANIFEST = "res://data/a33_groundfirst_lantern_manifest.json"
const MASTER = "res://private_assets/ground_only.png"
const ORIGINAL_GROUND_SHA = "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
const NEW_LAMP = "res://private_assets/independent_par/a33_ornate_lantern_complete_52x124.png"
const OLD_LAMP = "res://private_assets/independent_par/fsobj_post_lantern.png"
const NEW_SHA = "6e0bed07a735cba3c908a5da4c81863222363cab01325aeeaaf1f821d63a6991"
const OLD_SHA = "488eba161a7069f045d42449ddde02f47fbfabce889007eb6e827202f7b44a0d"
var checks = 0
func check(ok:bool, what:String) -> bool:
    if ok:checks+=1
    else: push_error("A33 FAIL: "+what)
    return ok
func _initialize() -> void:call_deferred("_run")
func _run() -> void:
    var mf=FileAccess.open(MANIFEST,FileAccess.READ)
    if not check(mf!=null,"manifest exists"):quit(10);return
    var d:Dictionary=JSON.parse_string(mf.get_as_text())
    mf.close()
    if not check(d.get("schema")=="fs-a33-ground-first-complete-independent-lantern/v1","new production schema"):quit(11);return
    if not check(d["policy"]=="FS_ACTIVE_MASTER_V1.3","Ground-first art contract kept"):quit(12);return
    if not check(d["objects"].size()==146 and d["assets"].size()==27,"146 instances and 27 unique source families"):quit(13);return
    if not check(FileAccess.get_sha256(MASTER)==ORIGINAL_GROUND_SHA,"Ground exact source bytes unchanged"):quit(14);return
    if not check(FileAccess.get_sha256(NEW_LAMP)==NEW_SHA,"new isolated lamp source SHA"):quit(15);return
    if not check(FileAccess.get_sha256(OLD_LAMP)==OLD_SHA,"old lamp source left intact"):quit(16);return
    var tex:Texture2D=load(NEW_LAMP)
    if not check(tex!=null and tex.get_size()==Vector2(52,124),"complete 52x124 lamp texture"):quit(17);return
    var original:Texture2D=load(OLD_LAMP)
    if not check(original!=null and original.get_size()==Vector2(32,57),"old 32x57 source retained"):quit(18);return
    var a:Image=tex.get_image()
    var ar:Rect2i=a.get_used_rect()
    if not check(ar.position.y<15 and ar.end.y>108,"entire finial and full base visible"):quit(19);return
    if not check(a.get_pixel(0,0).a<0.01 and a.get_pixel(51,123).a<0.01,"transparent sprite edges"):quit(20);return
    var old_scene:PackedScene=load(SCENE_OLD)
    var new_scene:PackedScene=load(SCENE_NEW)
    if not check(old_scene!=null and new_scene!=null,"both A32 and A33 scenes open independently"):quit(21);return
    var prev:Node2D=old_scene.instantiate()
    var world:Node2D=new_scene.instantiate()
    root.add_child(prev)
    root.add_child(world)
    await process_frame
    await physics_frame
    var p:Node2D=prev.get_node("YSort")
    var n:Node2D=world.get_node("YSort")
    check(n.y_sort_enabled,"original Godot Y-sort retained")
    check(n.get_child_count()==147,"146 owner objects + 1 actor")
    check(world.get_node("FullGround").texture!=null,"new scene ground loads")
    check(prev.get_node("FullGround").texture!=null,"old scene ground loads")
    var num_lamps=0
    var total_colliders=0
    for object in d["objects"]:
        var id:String=object["id"]
        var instance:Node2D=n.get_node_or_null(id)
        if not check(instance!=null,"Godot independent object ID: "+id):quit(23);return
        var sprite:Sprite2D=instance.get_node_or_null("Sprite") as Sprite2D
        if not check(sprite!=null and sprite.texture!=null,"real independent source: "+id):quit(24);return
        var source:Dictionary=d["assets"][object["asset_id"]]
        if not check(FileAccess.get_sha256("res://"+source["file"])==object["source_sha256"],"object source SHA "+id):quit(25);return
        if not check(sprite.texture.get_size()==Vector2(source["size"][0],source["size"][1]),"full source dimension "+id):quit(26);return
        if object["root_collision"]:
            var col:CollisionShape2D=instance.get_node_or_null("Body/Collision")
            if not check(col!=null and col.shape!=null,"real collision body: "+id):quit(27);return
            total_colliders+=1
        if object["asset_id"]=="a33_ornate_lantern_complete":
            num_lamps+=1
            var baseline:Node2D=p.get_node(id)
            if id == "obj_138_fsobj_post_lantern":
                check(instance.position==Vector2(438,473) and baseline.position==Vector2(496,473),"first lamp moved 58px left after actual framebuffer showed well overlap")
            else:
                check(instance.position==baseline.position,"3 other lamp feet remain unchanged: "+id)
            check(sprite.position.y < -110,"full tall lamp uses footpoint-relative top: "+id)
            check(instance.source_sha256==NEW_SHA,"Godot node references A33 source: "+id)
            var shape:CollisionShape2D=instance.get_node("Body/Collision")
            check(shape.shape.size==Vector2(12,8),"new lamp small base collision only: "+id)
    check(num_lamps==4,"four lamps replaced")
    check(total_colliders==140,"140 physical bases, never whole canopies")
    check(FileAccess.get_sha256(MASTER)==ORIGINAL_GROUND_SHA,"Ground still unmodified after Godot scene load")
    var player:CharacterBody2D=world.get_node("YSort/Player")
    var hit_any_lamp=false
    for lamp_id in ["obj_139_fsobj_post_lantern","obj_141_fsobj_post_lantern","obj_140_fsobj_post_lantern"]:
        var lamp:Node2D=world.get_node("YSort/"+lamp_id)
        player.global_position=lamp.global_position + Vector2(-35,0)
        await physics_frame
        var hit:KinematicCollision2D=player.move_and_collide(Vector2(70,0),true)
        if hit!=null and hit.get_collider()==lamp.get_node("Body"):
            hit_any_lamp=true
            break
    check(hit_any_lamp,"native CharacterBody2D hits the added lantern 12x8 base collider")
    print("A33 GODOT REAL LAMP PASS: ",checks," native checks; 4 independent complete ornate lamps; source Ground SHA unchanged; A32 baseline retained")
    quit(0)
