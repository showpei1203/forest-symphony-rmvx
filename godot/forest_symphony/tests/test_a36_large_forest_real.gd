extends SceneTree
## A36 true private source runtime QA; no art approval inferred from a green test.
var checks=0
var errors:Array[String]=[]
func gate(ok:bool,why:String)->void:
    if ok: checks+=1
    else:errors.append(why);push_error("A36 REAL GATE FAIL "+why)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    var m=JSON.parse_string(FileAccess.get_file_as_string("res://data/a36_large_verdant_forest_manifest.json")) as Dictionary
    if m==null or m.is_empty():push_error("missing real scene manifest");quit(4);return
    gate(m.get("schema")=="fs-a36-ground-first-large-continuous-world/v1","schema")
    gate(int(m["world_px"][0])==2560 and int(m["world_px"][1])==1856,"world 2560x1856")
    gate(int(m["logical_grid"][0])==80 and int(m["logical_grid"][1])==58,"80x58 grid")
    gate(m["source_ground"]["generated_not_native_32px"]==true,"no false native32px claim")
    gate(m["quality_contract"]["no_old_ground_tiling"]==true,"no A34 tiled ground")
    gate(m["quality_contract"]["full_independent_par_sources"]==true,"not cropped master PAR")
    gate(FileAccess.get_sha256("res://private_assets/"+m["source_ground"]["file"])==m["source_ground"]["sha256"],"original authored ground SHA")
    gate(FileAccess.get_sha256("res://private_assets/"+m["runtime_ground"]["file"])==m["runtime_ground"]["sha256"],"runtime ground SHA")
    gate(FileAccess.get_sha256("res://private_assets/"+m["shadow"]["file"])==m["shadow"]["sha256"],"independent shadow SHA")
    gate(m["objects"].size()==326,"object count 326")
    var p=load("res://scenes/a36_large_verdant_forest_80x58.tscn") as PackedScene
    if p==null:push_error("A36 private scene failed to load");quit(5);return
    var scene=p.instantiate() as Node2D
    root.add_child(scene)
    await process_frame
    await physics_frame
    var owner=scene.get_node("YSort") as Node2D
    gate(owner.get_child_count()==327,"YSort contains 326 PAR and one actor")
    gate(owner.y_sort_enabled,"YSort enabled")
    gate(scene.get_node("FullGround").texture!=null,"real ground loaded")
    gate(scene.get_node("FullGround").texture.get_size()==Vector2(2560,1856),"native Ground texture size")
    gate(scene.get_node("ContactShadows").texture!=null,"independent shadow layer")
    gate(scene.get_node("YSort/Player/Camera2D")!=null,"camera")
    var unique={}
    var roots=0
    for o in m["objects"]:
        var name:String=o["id"]
        gate(not unique.has(name),"unique instance "+name)
        unique[name]=true
        var n=owner.get_node_or_null(name) as Node2D
        if n==null:errors.append("missing owner "+name);break
        gate(n.position==Vector2(o["foot"][0],o["foot"][1]),"world XY foot "+name)
        var a=m["assets"][o["family"]] as Dictionary
        gate(FileAccess.get_sha256(a["file"])==a["sha"],"authentic standalone PNG SHA "+name)
        var spr=n.get_node_or_null("Sprite") as Sprite2D
        gate(spr!=null and spr.texture!=null,"independent sprite texture "+name)
        if spr!=null and spr.texture!=null:gate(spr.texture.get_size()==Vector2(a["w"],a["h"]),"source size "+name)
        var col=n.get_node_or_null("Body/Collision") as CollisionShape2D
        gate(col!=null and col.shape!=null,"root collision "+name)
        if col!=null and col.shape!=null:roots+=1
        gate(n.footprint_width_px<float(a["w"]),"collision not whole canopy "+name)
    gate(roots==326,"326 native object footprint shapes")
    var water=JSON.parse_string(FileAccess.get_file_as_string("res://data/a36_terrain_semantic_candidates.json")) as Dictionary
    gate(water["status"]=="WATER_CANDIDATE_NOT_VALIDATED_NAVIGATION","water clearly candidate")
    gate(int(water["river_cell_count"])>60,"river semantic candidate cells")
    print("A36 REAL GODOT GROUND-FIRST SOURCE PASS ",checks," checks; ",roots," independent objects; ",water["river_cell_count"]," candidate water cells; ART HOLD")
    quit(0 if errors.is_empty() else 20)
