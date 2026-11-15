extends SceneTree
## Forest Symphony "幽葉迴廊" A36C R6 forest dungeon source/native provenance QA.
## Source-only biology scene. Not a game dungeon completion or WATER/ART seal.
const BASE := "res://scenes/a36b_large_forest_tree_ecology_80x58.tscn"
const NEXT := "res://scenes/a36c_r6_forest_groves_80x58.tscn"
const MAN := "res://data/a36c_r6_forest_groves_manifest.json"
const GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const SHADOW := "res://private_assets/a36b_contact_shadows_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const SHADOW_SHA := "752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa"
func _initialize() -> void:
    call_deferred("_test")
func _fail(message:String,code:int) -> void:
    push_error("FS A36C NATIVE FOREST FAIL: "+message)
    quit(code)

func _test() -> void:
    if FileAccess.get_sha256(GROUND)!=GROUND_SHA or FileAccess.get_sha256(SHADOW)!=SHADOW_SHA:
        _fail("original private Ground/Shadow SHA mismatch",40);return
    var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(MAN))
    if typeof(data)!=TYPE_DICTIONARY:
        _fail("A36C manifest parse failed",41);return
    var size: Array=data.get("logical_grid",[])
    if data["objects"].size()!=326 or size.size()!=2 or int(size[0])!=80 or int(size[1])!=58 or int(data["cell_px"])!=32:
        _fail("wrong A36C data objects="+str(data["objects"].size())+" grid="+str(size)+" cell="+str(data["cell_px"]),42);return
    if data["a36c_r6"]["changes"].size()!=39:
        _fail("R6 must contain exactly 39 movement records",43);return
    var base: Node2D=load(BASE).instantiate()
    var current: Node2D=load(NEXT).instantiate()
    root.add_child(base)
    root.add_child(current)
    await process_frame
    var la: Node2D=base.get_node("YSort")
    var lb: Node2D=current.get_node("YSort")
    if la.get_child_count()!=327 or lb.get_child_count()!=327:
        _fail("326 independently editable PAR + player count missing",44);return
    if base.get_node("FullGround").texture==null or current.get_node("FullGround").texture==null:
        _fail("private Ground actual texture missing",45);return
    if base.get_node("ContactShadows").texture==null or current.get_node("ContactShadows").texture==null:
        _fail("private Shadow actual texture missing",46);return
    var trees:=0
    var owners:=0
    var moved:=0
    for item in la.get_children():
        if item is CharacterBody2D:
            continue
        var other: Node2D=lb.get_node_or_null(NodePath(str(item.name)))
        if other==null:
            _fail("missing owner "+str(item.name),47);return
        if item.source_file!=other.source_file or item.source_sha256!=other.source_sha256:
            _fail("A36C falsely changed original whole-object PAR "+str(item.name),48);return
        if item.footprint_width_px!=other.footprint_width_px or item.footprint_height_px!=other.footprint_height_px:
            _fail("A36C altered body footprint "+str(item.name),49);return
        var ca: CollisionShape2D=item.get_node("Body/Collision")
        var cb: CollisionShape2D=other.get_node("Body/Collision")
        if (ca.shape==null)!=(cb.shape==null) or ca.disabled!=cb.disabled:
            _fail("A36C collision presence drift "+str(item.name),50);return
        if ca.shape!=null and ca.shape.get_rect()!=cb.shape.get_rect():
            _fail("A36C collision geometry drift "+str(item.name),51);return
        if item.position!=other.position:
            moved+=1
        if item.source_semantic=="tree":
            trees+=1
        owners+=1
    if owners!=326 or trees!=310:
        _fail("expected 326 owners and 310 tree family instances",52);return
    if moved<30 or moved>70:
        _fail("A36C moved owners unexpected "+str(moved),53);return
    for movement in data["a36c_r6"]["changes"]:
        var object_id: String=str(movement["id"])
        var node: Node2D=lb.get_node_or_null(NodePath(object_id))
        if node==null:
            _fail("R6 movement ID not in actual Godot scene "+object_id,54);return
        var final: Array=movement["to"]
        if node.position!=Vector2(float(final[0]),float(final[1])):
            _fail("R6 declared moved position != real Godot node "+object_id,55);return
    print("FS FOREST DUNGEON A36C R6 GODOT NATIVE SOURCE PASS: original private Ground/Shadow SHA, 326 whole PAR, 310 trees, 39 R6 declared positions, actually moved nodes="+str(moved)+", collision shapes unchanged; ART / RIVER / ROUTE HOLD")
    quit(0)
