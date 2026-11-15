extends SceneTree
## No private PNG required; source-only editable scene contract, fail closed.
var checks:=0
var failures:Array[String]=[]
func gate(ok:bool,n:String)->void:
    if ok:checks+=1
    else:failures.append(n);push_error("A36B PUBLIC FAIL "+n)
func _initialize()->void:call_deferred("_test")
func _test()->void:
    var m:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/a36b_ecological_tree_manifest.json")) as Dictionary
    if m.is_empty():push_error("missing A36B manifest");quit(4);return
    gate(m["schema"]=="fs-a36b-ground-first-ecological-complete-tree-family/v1","schema")
    gate(int(m["world_px"][0])==2560 and int(m["world_px"][1])==1856,"size")
    gate(m["source_ground"]["generated_not_native_32px"]==true,"ground pixel source caveat")
    gate(m["art_gate"].begins_with("HOLD"),"ART not passed")
    gate(m["objects"].size()==326,"326 owners")
    gate(m["assets"].size()==11,"11 families")
    gate(m["ecological_tree_upgrade"]["replacements_total"]==62,"62 tree replacements")
    gate(m["ecological_tree_upgrade"]["all_footpoints_identical"],"footpoints preserved")
    gate(m["ecological_tree_upgrade"]["other_two_bottom_sheet_candidates"]=="REJECTED_OVERLAP_ALPHA_EDGE","reject bad sprite crops")
    gate(m["quality_contract"]["water_animation"]=="NOT_IMPLEMENTED","no imaginary water")
    gate(m["events"]=="OUT_OF_SCOPE_OTHER_CONVERSATION","no event implementation")
    var p=load("res://scenes/a36b_large_forest_tree_ecology_80x58.tscn") as PackedScene
    gate(p!=null,"PackedScene parses")
    if p==null:quit(5);return
    var w=p.instantiate() as Node2D
    gate(w.get_node_or_null("FullGround")!=null,"ground layer")
    gate(w.get_node_or_null("ContactShadows")!=null,"shadow layer")
    var layer=w.get_node("YSort") as Node2D
    gate(layer.get_child_count()==327,"326 owners plus player")
    var pine:=0
    var willow:=0
    var ids={}
    for o in m["objects"]:
        var id:String=o["id"]
        gate(not ids.has(id),"unique owner "+id)
        ids[id]=true
        var n=layer.get_node_or_null(id) as Node2D
        if n==null:failures.append("missing PAR owner "+id);break
        var a:Dictionary=m["assets"][o["family"]]
        gate(n.position==Vector2(o["foot"][0],o["foot"][1]),"precise foot "+id)
        gate(n.source_file==a["file"],"independent RGBA asset "+id)
        gate(n.source_sha256==a["sha"],"original asset SHA "+id)
        gate(n.footprint_width_px<float(a["w"]),"narrow root "+id)
        gate(n.get_node_or_null("Body/Collision")!=null,"native collision node "+id)
        if o["family"].begins_with("a36b_moss_pine_"): pine+=1
        if o["family"].begins_with("a36b_river_willow_"): willow+=1
    gate(pine==40,"pine ecology")
    gate(willow==22,"willow ecology")
    w.free()
    print("A36B PUBLIC GODOT SOURCE CONTRACT PASS: ",checks," checks; 2 NEW independently generated tree families, 62 affected, 264 unchanged; ART HOLD")
    quit(0 if failures.is_empty() else 20)
