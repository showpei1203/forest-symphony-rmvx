extends SceneTree
## Actual Godot 4.7.2 validation of 6 biomes × dungeon + village.
const Registry := preload("res://scripts/fs_world_map_registry.gd")
func _initialize() -> void:
    call_deferred("_run")

func _fail(reason:String,code:int=73) -> void:
    push_error("FS 12 MAP NATIVE FAIL "+reason)
    quit(code)

func _run() -> void:
    var registry=Registry.new()
    var all: Array=registry.record.get("maps",[])
    var biomes: Array=registry.record.get("biomes",[])
    if all.size()!=12 or biomes.size()!=6:
        _fail("must have exactly 12 map slots and 6 biome families");return
    var seen: Dictionary={}
    var roles_by_biome: Dictionary={}
    for entry in all:
        var id: String=str(entry.get("id",""))
        var biome: String=str(entry.get("biome_id",""))
        var role: String=str(entry.get("role",""))
        if id.is_empty() or seen.has(id):
            _fail("duplicate/missing map id "+id);return
        seen[id]=true
        if role!="dungeon" and role!="village":
            _fail("unexpected role "+role);return
        if not roles_by_biome.has(biome):
            roles_by_biome[biome]=[]
        roles_by_biome[biome].append(role)
        if int(entry.get("grid_px",-1))!=32:
            _fail("32px grid drift "+id);return
        if entry.get("gates",{}).get("final_seal",false):
            _fail("catalog must not mark unapproved art as sealed "+id);return
        if registry.is_production_ready(id):
            _fail("unapproved art falsely released "+id);return
    for family in biomes:
        var key: String=str(family.get("id",""))
        if roles_by_biome.get(key,[]).size()!=2:
            _fail("missing biome pair "+key);return
        if not roles_by_biome[key].has("dungeon") or not roles_by_biome[key].has("village"):
            _fail("each biome needs both village+dungeon "+key);return
    var village: Dictionary=registry.get_map("elf_village")
    if village.get("status","")!="ENGINE_PASS_ART_HOLD":
        _fail("source of elven village must remain ART HOLD");return
    if not registry.has_native_scene("elf_village"):
        _fail("existing R8 R3 Godot village scene missing");return
    if not registry.is_candidate_runnable("elf_village"):
        _fail("R8 R3 verified runtime should be loadable as DEV candidate");return
    var packed: PackedScene=load(str(village["scene_path"]))
    if packed==null:
        _fail("R8 R3 candidate load failed");return
    var live: Node=packed.instantiate()
    root.add_child(live)
    await process_frame
    if live.get_node_or_null("YSort")==null or live.get_node_or_null("ForestLightStudy")==null:
        _fail("R8 R3 scene is not genuine map+shadow");return
    if int(live.get_node("ForestLightStudy").canopy_caster_count)!=175:
        _fail("R8 R3 Godot did not create 175 canopy casters");return
    live.queue_free()
    await process_frame
    var dungeon: Dictionary=registry.get_map("forest_dungeon")
    if dungeon.get("status","")!="SOURCE_QA_ONLY" or registry.has_native_scene("forest_dungeon"):
        _fail("A36C Forest Dungeon not allowed to pretend native-ready");return
    if registry.is_candidate_runnable("forest_dungeon"):
        _fail("A36C unverified source must be locked");return
    var summary: Dictionary=registry.get_summary()
    if int(summary.get("candidate_runnable",-1))!=1 or int(summary.get("production_ready",-1))!=0:
        _fail("expected one DEV map and ZERO formally sealed maps");return
    print("FS 12-MAP GODOT NATIVE PASS: biomes=6, slots=12, paired dungeons/villages=6, candidate village=1, forest source-only=1, production seals=0; actual R8 R3 175-canopy scene instantiated")
    quit(0)
