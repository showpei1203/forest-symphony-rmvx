extends RefCounted
## FS 12-map registry: metadata only. Scene loading is denied until an actual
## same-project Godot scene exists and native QA has passed. ART HOLD remains
## explicit even for runnable candidates.
const CATALOG_FILE := "res://data/fs_12_map_catalog.json"
var record: Dictionary = {}
var by_id: Dictionary = {}
var by_biome: Dictionary = {}

func _init() -> void:
    var file := FileAccess.open(CATALOG_FILE, FileAccess.READ)
    if file == null:
        push_error("FS 12 MAP CATALOG MISSING "+CATALOG_FILE)
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("FS world 12 catalog invalid JSON")
        return
    record = parsed
    for item in record.get("maps",[]):
        if typeof(item) != TYPE_DICTIONARY:
            continue
        by_id[str(item.get("id",""))] = item
        var biome: String = str(item.get("biome_id",""))
        if not by_biome.has(biome):
            by_biome[biome] = []
        by_biome[biome].append(item)

func get_map(id: String) -> Dictionary:
    return by_id.get(id, {})

func get_pair(biome_id: String) -> Array:
    return by_biome.get(biome_id, [])

func is_source_verified(id: String) -> bool:
    var info: Dictionary = get_map(id)
    return info.get("gates",{}).get("source","NOT_RUN") == "PASS"

func has_native_scene(id: String) -> bool:
    var info: Dictionary = get_map(id)
    var path: String = str(info.get("scene_path",""))
    return not path.is_empty() and path.begins_with("res://") and ResourceLoader.exists(path)

func is_candidate_runnable(id: String) -> bool:
    ## Runtime smoke for development ONLY. Never equate with final art approval.
    var info: Dictionary = get_map(id)
    return info.get("gates",{}).get("native_gpu","NOT_RUN") == "PASS" \
        and info.get("gates",{}).get("navigation","NOT_RUN") == "PASS" \
        and has_native_scene(id)

func is_production_ready(id: String) -> bool:
    var info: Dictionary = get_map(id)
    return is_candidate_runnable(id) and info.get("gates",{}).get("art","HOLD")=="PASS" \
        and info.get("gates",{}).get("final_seal",false)==true

func load_candidate(scene_tree: SceneTree, id: String) -> Error:
    ## Never switch to a blank placeholder or a source-only external scene.
    if not is_candidate_runnable(id):
        push_warning("FS 12-map blocked until native Godot QA: "+id)
        return ERR_UNAVAILABLE
    return scene_tree.change_scene_to_file(str(get_map(id)["scene_path"]))

func get_summary() -> Dictionary:
    var status_counts: Dictionary = {}
    for item in record.get("maps",[]):
        var state: String = str(item.get("status","UNKNOWN"))
        status_counts[state] = int(status_counts.get(state,0))+1
    return {
      "biomes":record.get("biome_count",0),
      "maps":record.get("world_map_count",0),
      "candidate_runnable":by_id.keys().filter(func(id):return is_candidate_runnable(id)).size(),
      "production_ready":by_id.keys().filter(func(id):return is_production_ready(id)).size(),
      "statuses":status_counts
    }
