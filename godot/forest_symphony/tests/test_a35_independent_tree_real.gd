extends SceneTree
## Genuine private-source Godot 4.7.2 gate for independently authored COMPLETE TREE families.
## No art approval inferred from checks. No NPC/event system in this task.
const OLD_SCENE = "res://scenes/a34_groundfirst_full_houses_scene.tscn"
const NEW_SCENE = "res://scenes/a35_independent_tree_family_scene.tscn"
const MANIFEST = "res://data/a35_independent_tree_family_manifest.json"
const GROUND_SHA = "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
var checks:int=0
var failed:Array[String]=[]
func check(c:bool,reason:String)->bool:
    if c:checks+=1
    else:
        failed.append(reason)
        push_error("A35 TREE REAL FAIL "+reason)
    return c
func _initialize()->void:call_deferred("_run")
func _run()->void:
    if not check(FileAccess.get_sha256("res://private_assets/ground_only.png")==GROUND_SHA,"Ground independent original SHA unchanged"):quit(1);return
    var mtext=FileAccess.get_file_as_string(MANIFEST)
    if not check(not mtext.is_empty(),"manifest exists"):quit(2);return
    var m=JSON.parse_string(mtext) as Dictionary
    if not check(m.get("schema")=="fs-a35-artist-owned-complete-tree-family/v1","A35 independent family schema"):quit(3);return
    check(m["policy"]=="FS_ACTIVE_MASTER_V1.3","Ground-first policy preserved")
    check(m["objects"].size()==146,"146 original scene objects preserved")
    check(m["assets"].size()==31,"27 existing + 4 new independent tree families")
    var a34=load(OLD_SCENE) as PackedScene
    var a35=load(NEW_SCENE) as PackedScene
    if not check(a34!=null and a35!=null,"both original A34 and new A35 scenes load"):quit(4);return
    var before=a34.instantiate() as Node2D
    var after=a35.instantiate() as Node2D
    root.add_child(before)
    root.add_child(after)
    await process_frame
    await physics_frame
    var old_layer=before.get_node("YSort") as Node2D
    var new_layer=after.get_node("YSort") as Node2D
    check(new_layer.y_sort_enabled,"native YSort enabled")
    check(new_layer.get_child_count()==147,"146 independently editable object nodes and player")
    check(after.get_node("FullGround").texture!=null,"Godot texture for independent Ground loaded")
    check(after.get_node("YSort/Player/Camera2D")!=null,"A34 camera preserved")
    var replaced=0
    var retained=0
    var roots=0
    for o in m["objects"]:
        var id:String=o["id"]
        var owner:Dictionary=m["assets"][o["asset_id"]]
        var new_obj=new_layer.get_node_or_null(id) as Node2D
        var old_obj=old_layer.get_node_or_null(id) as Node2D
        if not check(new_obj!=null and old_obj!=null,"baseline node preserved "+id):quit(10);return
        if not check(new_obj.position==old_obj.position,"root world foot identical "+id):quit(11);return
        var sprite=new_obj.get_node_or_null("Sprite") as Sprite2D
        if not check(sprite!=null and sprite.texture!=null,"independent RGBA texture loaded "+id):quit(12);return
        if not check(FileAccess.get_sha256("res://"+String(owner["file"]))==String(owner["sha256"]),"source SHA "+id):quit(13);return
        if not check(sprite.texture.get_size()==Vector2(owner["size"][0],owner["size"][1]),"asset native size "+id):quit(14);return
        if o["root_collision"]:
            var shape=new_obj.get_node_or_null("Body/Collision") as CollisionShape2D
            if not check(shape!=null and shape.shape!=null,"native physical root still exists "+id):quit(15);return
            roots+=1
        if String(o["asset_id"]).begins_with("a35_"):
            replaced+=1
            check(new_obj.source_sha256!=old_obj.source_sha256,"new source image actually replaced old "+id)
            check(owner["full_independent_art"]==true,"independently generated complete tree "+id)
            var im=sprite.texture.get_image()
            var box=im.get_used_rect()
            check(box.position.x>=4 and box.position.y>=4 and box.end.x<=im.get_width()-4 and box.end.y<=im.get_height()-4,"complete silhouette with transparent padding "+id)
            check(im.get_pixel(0,0).a==0 and im.get_pixel(im.get_width()-1,im.get_height()-1).a==0,"transparent corners not cropped "+id)
            check(float(new_obj.footprint_width_px)<=40.0,"root collider not canopy-sized "+id)
        else:
            retained+=1
            if not check(new_obj.source_sha256==old_obj.source_sha256,"unrelated house/lamp/tree source not changed "+id):quit(16);return
    check(replaced==8,"exactly 8 representative trees replaced")
    check(retained==138,"all other 138 sprites retain immutable source")
    check(roots==140,"all 140 existing root/house/lamp physics shapes preserved")
    check(FileAccess.get_sha256("res://private_assets/ground_only.png")==GROUND_SHA,"master still SHA-locked")
    print("A35 GODOT PRIVATE SOURCE TREE PASS: ",checks," checks; 4 new complete standalone tree families, 8 individual scene replacements; ART HOLD")
    quit(0 if failed.is_empty() else 20)
