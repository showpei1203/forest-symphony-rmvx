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
    # VX: slot 1 is SECOND WEAPON for two_swords_style actors; shield otherwise.
    # Keep raw original IDs and VX actor identity fields for animation, MENU, BATTLE.
    var slots: Array = [int(actor.get("weapon_id", 0))]
    for i in range(1, 5):
        slots.append(int(actor.get("armor%d_id" % i, 0)))
    result["equipment"] = slots
    result["two_swords_style"] = bool(actor.get("two_swords_style",false))
    result["fix_equipment"] = bool(actor.get("fix_equipment",false))
    result["auto_battle"] = bool(actor.get("auto_battle",false))
    result["critical_bonus"] = bool(actor.get("critical_bonus",false))
    result["pharmacology"] = bool(actor.get("pharmacology",false))
    result["super_guard"] = bool(actor.get("super_guard",false))
    result["character_name"] = str(actor.get("character_name",""))
    result["character_index"] = int(actor.get("character_index",0))
    result["face_name"] = str(actor.get("face_name",""))
    result["face_index"] = int(actor.get("face_index",0))
    result["skills"] = learned_skills(actor_id,resolved_level)
    return result

func learned_skills(actor_id: int, level: int) -> Array[int]:
    # Verified stock VX Game_Actor#setup: learn each RPG::Class::Learning
    # with learning.level <= actor.level; custom skills remain P1 extension.
    var actor: Dictionary = record("actors",actor_id)
    var klass: Dictionary = record("classes",int(actor.get("class_id",0)))
    var found: Array[int] = []
    for row in klass.get("learnings",[]):
        if row is Dictionary and int(row.get("level",9999)) <= level:
            var skill_id: int = int(row.get("skill_id",0))
            if skill_id > 0 and not skill_id in found:
                found.append(skill_id)
    return found

func equip_kind(stats: Dictionary, slot: int) -> String:
    if slot < 0 or slot >= 5:
        return ""
    return "weapons" if slot == 0 or (slot == 1 and bool(stats.get("two_swords_style",false))) else "armors"

func can_equip(stats: Dictionary, slot: int, item_id: int) -> bool:
    if slot < 0 or slot >= 5:
        return false
    if bool(stats.get("fix_equipment",false)):
        return false
    if item_id == 0:
        return true
    var kind: String = equip_kind(stats,slot)
    var item: Dictionary = record(kind,item_id)
    if item.is_empty():
        return false
    var klass: Dictionary = record("classes",int(stats.get("class_id",0)))
    var set_name: String = "weapon_set" if kind == "weapons" else "armor_set"
    if not item_id in klass.get(set_name,[]):
        return false
    # RPG::Armor.kind: 0 shield, 1 head, 2 body, 3 accessory.
    # Slot 1 is a weapon for dual-wielders, otherwise armor kind 0.
    if kind == "armors" and int(item.get("kind",-1)) != slot-1:
        return false
    return true

func enemy_stats(enemy_id: int) -> Dictionary:
    var enemy := record("enemies", enemy_id)
    if enemy.is_empty():
        return {}
    var result: Dictionary = {"id": enemy_id, "name": str(enemy.get("name", "?")), "level": 1,
        "actor": false, "equipment": []}
    for name in PARAMS:
        result[name] = int(enemy.get(name, 0))
    result["hit"] = int(enemy.get("hit",95))
    result["eva"] = int(enemy.get("eva",5))
    result["cri"] = 10 if bool(enemy.get("has_critical",false)) else 0
    result["exp"] = int(enemy.get("exp",0))
    result["gold"] = int(enemy.get("gold",0))
    result["actions"] = enemy.get("actions",[])
    result["battler_name"] = str(enemy.get("battler_name",""))
    return result

func apply_equipment(stats: Dictionary) -> Dictionary:
    var result: Dictionary = stats.duplicate(true)
    var slots: Array = stats.get("equipment",[])
    var two_swords: bool = bool(stats.get("two_swords_style",false))
    var hit_one: int = 95
    var hit_two: int = 95
    var armor_eva: int = 5
    var bonus_cri: int = 4 if bool(stats.get("critical_bonus",false)) else 0
    # Source: VX Game_Actor#base_atk/def/spi/agi sums equips once;
    # Game_Actor#hit/eva/cri includes equipment features.
    for i in range(slots.size()):
        var kind: String = equip_kind(stats,i)
        var item: Dictionary = record(kind,int(slots[i]))
        if item.is_empty():
            continue
        for stat in ["atk","def","spi","agi"]:
            result[stat] = int(result.get(stat,0)) + int(item.get(stat,0))
        if kind == "weapons":
            bonus_cri += 4 if bool(item.get("critical_bonus",false)) else 0
            if i == 0:
                hit_one = int(item.get("hit",95))
            elif i == 1:
                hit_two = int(item.get("hit",95))
        elif kind == "armors":
            armor_eva += int(item.get("eva",0))
    result["hit"] = mini(hit_one,hit_two) if two_swords else hit_one
    result["eva"] = armor_eva
    result["cri"] = 4 + bonus_cri
    return result
