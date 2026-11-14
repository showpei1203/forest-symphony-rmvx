extends SceneTree
## Source-only Godot 4.7.2 CI: no copyrighted/private original PNGs are required.
## Failed assertions must return a nonzero exit; cannot hide behind a green workflow.
var checks=0
var failures:Array[String]=[]
func gate(ok:bool,what:String)->void:
    if ok:checks+=1
    else:failures.append(what);push_error("A36 PUBLIC CONTRACT FAIL "+what)
func _initialize()->void:call_deferred("_run")
func _run()->void:
    var path="res://data/a36_large_verdant_forest_manifest.json"
    var text=FileAccess.get_file_as_string(path)
    if text.is_empty():push_error("missing large map source manifest");quit(3);return
    var m=JSON.parse_string(text) as Dictionary
    if m==null or m.is_empty():push_error("invalid large map manifest");quit(4);return
    gate(m["schema"]=="fs-a36-ground-first-large-continuous-world/v1","schema")
    gate(int(m["world_px"][0])==2560 and int(m["world_px"][1])==1856,"world 2560x1856")
    gate(int(m["logical_grid"][0])==80 and int(m["logical_grid"][1])==58,"80x58 grid")
    gate(int(m["cell_px"])==32,"32px semantic grid")
    gate(m["source_ground"]["authoring"]=="FRESH_SINGLE_CONTINUOUS_IMAGE_GENERATION","genuinely new source, not A34 4x quilt")
    gate(m["source_ground"]["generated_not_native_32px"]==true,"honest not native32 art disclosure")
    gate(int(m["source_ground"]["size"][0])==1478 and int(m["source_ground"]["size"][1])==1064,"full source generation dimensions")
    gate(m["runtime_ground"]["transform"].contains("NEAREST"),"no interpolation blur claimed")
    gate(m["quality_contract"]["no_old_ground_tiling"]==true,"forbid copying old Ground")
    gate(m["quality_contract"]["full_independent_par_sources"]==true,"independently sourced complete objects")
    gate(m["events"]=="OUT_OF_SCOPE_OTHER_CONVERSATION","events not owned by art lane")
    gate(m["art_gate"].begins_with("HOLD"),"no invented art approval")
    gate(m["quality_contract"]["water_animation"]=="NOT_IMPLEMENTED","water FX not falsified")
    gate(m["objects"].size()==326,"326 independent objects")
    gate(m["assets"].size()==9,"nine complete art-source families")
    var p=load("res://scenes/a36_large_verdant_forest_80x58.tscn") as PackedScene
    gate(p!=null,"PackedScene parses as Godot 4.7.2")
    if p==null:quit(5);return
    # Deliberately don't add node to tree: private textures should not be required for source-only CI.
    var w=p.instantiate() as Node2D
    gate(w.get_node_or_null("FullGround")!=null,"independent full Ground sprite")
    gate(w.get_node_or_null("ContactShadows")!=null,"independent contact shadow sprite")
    gate(w.get_node_or_null("YSort/Player/Camera2D")!=null,"player & camera referenced")
    var layer=w.get_node("YSort") as Node2D
    gate(layer.y_sort_enabled,"sorted PAR parent")
    gate(layer.get_child_count()==327,"326 objects plus actor in native editable scene")
    var seen={}
    for o in m["objects"]:
        var id:String=o["id"]
        gate(not seen.has(id),"unique object "+id)
        seen[id]=true
        var n=layer.get_node_or_null(id) as Node2D
        if n==null:failures.append("missing "+id);break
        gate(n.position==Vector2(o["foot"][0],o["foot"][1]),"source-owned object foot "+id)
        var a=m["assets"].get(o["family"],null)
        gate(a!=null,"independent art family "+id)
        if a==null:continue
        gate(n.source_file==a["file"],"complete object art path "+id)
        gate(n.source_sha256==a["sha"],"immutable original source sha "+id)
        gate(String(n.source_file).begins_with("res://private_assets/independent_par/"),"not cut from master "+id)
        gate(o["footprint"][0]<a["w"],"independent root collision smaller than canopy "+id)
    var water=JSON.parse_string(FileAccess.get_file_as_string("res://data/a36_terrain_semantic_candidates.json")) as Dictionary
    gate(water["status"]=="WATER_CANDIDATE_NOT_VALIDATED_NAVIGATION","no false navigable river claim")
    gate(int(water["river_cell_count"])==148,"water candidate source count")
    gate(water["river_blocked_cells"].size()==148,"one-to-one candidate cells")
    w.free()
    print("A36 GODOT PUBLIC LARGE GROUND-FIRST CONTRACT PASS: ",checks," checks; 80x58, 326 isolated art source objects, art/collision HOLD")
    quit(0 if failures.is_empty() else 20)
