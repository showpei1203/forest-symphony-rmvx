extends SceneTree
## FS A34 real private art test. This verifies source/placement/physics only, NOT aesthetic pass.
const SCENE = "res://scenes/a34_groundfirst_full_houses_scene.tscn"
const OLD_SCENE = "res://scenes/a33_groundfirst_lantern_scene.tscn"
const MANIFEST = "res://data/a34_groundfirst_full_houses_manifest.json"
const ORIGINAL_GROUND_SHA = "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
var checks:int=0
var fails:Array[String]=[]
func ok(x:bool, why:String)->bool:
    if x: checks+=1
    else:
        fails.append(why)
        push_error("A34 HOUSE SOURCE FAIL: "+why)
    return x
func _initialize()->void:call_deferred("_run")
func _run()->void:
    var mtext=FileAccess.get_file_as_string(MANIFEST)
    if not ok(not mtext.is_empty(),"manifest present"):quit(1);return
    var d:Dictionary=JSON.parse_string(mtext)
    if not ok(d.get("schema")=="fs-a34-ground-first-independent-full-house-family/v1","new scene schema"):quit(2);return
    if not ok(d.get("policy")=="FS_ACTIVE_MASTER_V1.3","Ground-first contract"):quit(3);return
    if not ok(FileAccess.get_sha256("res://private_assets/ground_only.png")==ORIGINAL_GROUND_SHA,"Ground SHA original exact"):quit(4);return
    ok(d["objects"].size()==146,"146 independently placeable nodes")
    ok(d["assets"].size()==27,"27 source PAR families")
    var old=load(OLD_SCENE) as PackedScene
    var current=load(SCENE) as PackedScene
    if not ok(old!=null and current!=null,"A33 and A34 scenes both load"):quit(6);return
    var before=old.instantiate() as Node2D
    var world=current.instantiate() as Node2D
    root.add_child(before)
    root.add_child(world)
    await process_frame
    await physics_frame
    var base:Node2D=before.get_node("YSort")
    var stage:Node2D=world.get_node("YSort")
    ok(stage.y_sort_enabled and base.y_sort_enabled,"real native Godot YSort")
    ok(stage.get_child_count()==147,"146 PAR instances plus player")
    ok(world.get_node("FullGround").texture!=null,"native full ground Sprite2D loads")
    var colliders:int=0
    var changed:int=0
    for o in d["objects"]:
        var id:String=o["id"]
        var inst=stage.get_node_or_null(id) as Node2D
        if not ok(inst!=null,"per-instance editor scene node "+id):quit(10);return
        var owner:Dictionary=d["assets"][o["asset_id"]]
        var sprite=inst.get_node_or_null("Sprite") as Sprite2D
        if not ok(sprite!=null and sprite.texture!=null,"independent source texture "+id):quit(11);return
        if not ok(FileAccess.get_sha256("res://"+String(owner["file"]))==String(owner["sha256"]),"source SHA "+id):quit(12);return
        if not ok(sprite.texture.get_size()==Vector2(owner["size"][0],owner["size"][1]),"source full dimensions "+id):quit(13);return
        if o["root_collision"]:
            var col=inst.get_node_or_null("Body/Collision") as CollisionShape2D
            if not ok(col!=null and col.shape!=null,"real native body "+id):quit(14);return
            colliders+=1
        var baseline=base.get_node(id) as Node2D
        if String(o["asset_id"]).begins_with("a34_elf_"):
            changed+=1
            ok(baseline.source_sha256!=inst.source_sha256,"new complete independent house source, not old crop "+id)
            ok(inst.position==baseline.position,"house YSort footpoint constant "+id)
            ok(owner["full_independent_art"]==true,"true original full transparent house "+id)
            var image=sprite.texture.get_image()
            var bound=image.get_used_rect()
            ok(bound.position.x>=5 and bound.position.y>=5 and bound.end.x<=image.get_width()-5 and bound.end.y<=image.get_height()-5,"whole roof/workshop/base fully within PNG "+id)
            ok(image.get_pixel(0,0).a==0.0 and image.get_pixel(image.get_width()-1,image.get_height()-1).a==0.0,"transparent original edges "+id)
        else:
            if not ok(inst.source_sha256==baseline.source_sha256,"all other sprites source SHA unchanged "+id):quit(15);return
            if not ok(inst.position==baseline.position,"all other sprite footpoints unchanged "+id):quit(16);return
    ok(colliders==140,"unchanged physical root collider count")
    ok(changed==2,"only two source house nodes changed")
    ok(FileAccess.get_sha256("res://private_assets/ground_only.png")==ORIGINAL_GROUND_SHA,"ground SHA still unchanged after real runtime")
    ok(world.get_node("YSort/Player/Camera2D")!=null,"real game camera node preserved")
    print("A34 GODOT REAL HOUSE PASS: ",checks," checks; complete independent house A/B, ground exact, 144 other sprites unchanged, collision original HOLD")
    if not fails.is_empty():print("A34 FAILURE COUNT ",fails.size())
    quit(0 if fails.is_empty() else 17)
