extends RefCounted
class_name FSDatabase

const NAMES: Array[String] = ["actors", "classes", "skills", "items", "weapons", "armors", "enemies", "states", "troops", "system", "animations"]
const PARAMS: Array[String] = ["maxhp", "maxmp", "atk", "def", "spi", "agi"]
var tables: Dictionary = {}
var errors: Array[String] = []

func load_all(folder: String = "res://data") -> bool:
    tables.clear()
    errors.clear()
    for name in NAMES:
        var file_path: String = folder.path_join(name + ".json")
        if not FileAccess.file_exists(file_path):
            errors.append("缺少資料：" + file_path)
            continue
        var file := FileAccess.open(file_path, FileAccess.READ)
        if file == null:
            errors.append("無法讀取：" + file_path)
            continue
        var result: Variant = JSON.parse_string(file.get_as_text())
        if result == null:
            errors.append("JSON 無法解碼：" + file_path)
            continue
        tables[name] = result
    return errors.is_empty()

func record(kind: String, index: int) -> Dictionary:
    var data: Variant = tables.get(kind, [])
    if data is Array and index >= 0 and index < data.size() and data[index] is Dictionary:
        return data[index]
    return {}

func system() -> Dictionary:
    var data: Variant = tables.get("system", {})
    return data if data is Dictionary else {}

func actor_param(actor_id: int, level: int, name: String) -> int:
    var column: int = PARAMS.find(name)
    if column < 0:
        return 0
    # Verified actual FS source: RPG::Actor.parameters is a 6 × 100 Table.
    # X axis is stat: [maxhp, maxmp, atk, def, spi, agi]; Y axis is level.
    # RPG::Class has NO parameters table in this project's RVData.
    var actor := record("actors", actor_id)
    var table: Dictionary = actor.get("parameters", {})
    var width: int = int(table.get("xsize", 0))
    var height: int = int(table.get("ysize", 0))
    var values: Array = table.get("data_int16", [])
    if width <= column or level < 0 or level >= height:
        return 0
    var offset: int = level * width + column
    return int(values[offset]) if offset < values.size() else 0

func actor_stats(actor_id: int, level: int = -1) -> Dictionary:
    var actor := record("actors", actor_id)
    if actor.is_empty():
        return {}
    var resolved_level: int = int(actor.get("initial_level", 1)) if level < 0 else level
    var result: Dictionary = {"id": actor_id, "name": str(actor.get("name", "?")), "level": resolved_level,
        "class_id": int(actor.get("class_id", 0)), "actor": true}
    for name in PARAMS:
        result[name] = actor_param(actor_id, resolved_level, name)
    # VX starts with weapon + four armors; the full custom slot rules remain P1 TODO.
    var slots: Array = [int(actor.get("weapon_id", 0))]
    for i in range(1, 5):
        slots.append(int(actor.get("armor%d_id" % i, 0)))
    result["equipment"] = slots
    return result

func enemy_stats(enemy_id: int) -> Dictionary:
    var enemy := record("enemies", enemy_id)
    if enemy.is_empty():
        return {}
    var result: Dictionary = {"id": enemy_id, "name": str(enemy.get("name", "?")), "level": 1,
        "actor": false, "equipment": []}
    for name in PARAMS:
        result[name] = int(enemy.get(name, 0))
    return result

func apply_equipment(stats: Dictionary) -> Dictionary:
    var result: Dictionary = stats.duplicate(true)
    var slots: Array = stats.get("equipment", [])
    for i in range(slots.size()):
        var kind: String = "weapons" if i == 0 else "armors"
        var item := record(kind, int(slots[i]))
        for stat in ["atk", "def", "spi", "agi"]:
            result[stat] = int(result.get(stat, 0)) + int(item.get(stat, 0))
    return result
