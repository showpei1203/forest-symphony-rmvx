extends SceneTree
## FS_01_MAZE R7: source-art-safe merge of A36B R2 and A36C R6.
const PREV := "res://scenes/a36b_large_forest_tree_ecology_80x58.tscn"
const NEW := "res://scenes/fs_01_maze_a36c_r7_reconciled_80x58.tscn"
const MAN := "res://data/fs_01_maze_a36c_r7_reconciled_manifest.json"
const GROUND := "res://private_assets/a36_ground_only_2560x1856.png"
const SHADOW := "res://private_assets/a36b_contact_shadows_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const SHADOW_SHA := "752c252b0ac48961a164943749b421172ad775d2fe0e1329faa748219ff63ffa"
func _initialize() -> void:
    call_deferred("_run")
func _fail(reason:String,code:int) -> void:
    push_error("FS_01_MAZE native merge test FAIL: "+reason)
    quit(code)
func _run() -> void:
    if FileAccess.get_sha256(GROUND)!=GROUND_SHA or FileAccess.get_sha256(SHADOW)!=SHADOW_SHA:
        _fail("Ground/SHADOW bytes changed",61);return
    var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(MAN))
    if typeof(parsed)!=TYPE_DICTIONARY:
        _fail("manifest invalid JSON",62);return
    var m:Dictionary=parsed
    var info:Dictionary=m.get("merge_contract",{})
    if info.get("incoming_changed_positions",-1)!=56 or info.get("reverted_A36C_asset_swaps_not_accepted",-1)!=40:
        _fail("must preserve A36B 40 tree asset differences while taking 56 shifts",63);return
    var a:Node2D=load(PREV).instantiate()
    var b:Node2D=load(NEW).instantiate()
    root.add_child(a)
    root.add_child(b)
    await process_frame
    var la:Node2D=a.get_node("YSort")
    var lb:Node2D=b.get_node("YSort")
    if la.get_child_count()!=327 or lb.get_child_count()!=327:
        _fail("326 source owner PAR missing",64);return
    var moved:=0
    var trees:=0
    var owners:=0
    for before in la.get_children():
        if before is CharacterBody2D:continue
        var after:Node2D=lb.get_node_or_null(NodePath(str(before.name)))
        if after==null:
            _fail("owner missing "+str(before.name),65);return
        if before.source_file!=after.source_file or before.source_sha256!=after.source_sha256:
            _fail("old source art was overwritten "+str(before.name),66);return
        var old_collision:CollisionShape2D=before.get_node("Body/Collision")
        var new_collision:CollisionShape2D=after.get_node("Body/Collision")
        if (old_collision.shape==null)!=(new_collision.shape==null) or old_collision.disabled!=new_collision.disabled:
            _fail("changed collider presence "+str(before.name),67);return
        if old_collision.shape!=null and old_collision.shape.get_rect()!=new_collision.shape.get_rect():
            _fail("changed collider dimensions "+str(before.name),68);return
        if before.position!=after.position:
            moved+=1
        if before.source_semantic=="tree":
            trees+=1
        owners+=1
    if owners!=326 or trees!=310 or moved!=56:
        _fail("expected 326 owners, 310 trees and 56 moves, got "+str([owners,trees,moved]),69);return
    if a.get_node("FullGround").texture==null or b.get_node("FullGround").texture==null:
        _fail("original private full Ground not loaded",70);return
    if a.get_node("ContactShadows").texture==null or b.get_node("ContactShadows").texture==null:
        _fail("original private contact shadows not loaded",71);return
    for id in info["position_changed_ids"]:
        var node:Node2D=lb.get_node_or_null(NodePath(str(id)))
        if node==null:
            _fail("declared moved owner missing "+str(id),72);return
    print("FS_01_MAZE R7 GODOT NATIVE PASS: full 2560x1856 private Ground+Shadow SHA, 326 individual PAR, 310 trees, 56 grove positions, original A36B tree art/physics unmodified; ART HOLD, WATER/ROUTES HOLD")
    quit(0)
