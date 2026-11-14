extends RefCounted
class_name FSDatabase

const NAMES: Array[String] = ["actors", "classes", "skills", "items", "weapons", "armors", "enemies", "states", "troops", "system", "animations"]
const PARAMS: Array[String] = ["maxhp", "maxmp", "atk", "def", "spi", "agi"]
var tables: Dictionary = {}
var errors: Array[String] = []
# True only after load_all passes the post-Apply witness guard.
# In-memory synthetic unit-test tables must explicitly opt-in to Boss runtime.
var boot_final_verified: bool = false

func load_all(folder: String = "res://data") -> bool:
    tables.clear()
    errors.clear()
    boot_final_verified = false
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
    if errors.is_empty():
        # Raw RVData dumps are NOT FS gameplay DB: FS_MasterSetup 18 replaces
        # AutoSetup placeholders and FS_DB_AUTOSET.apply_all mutates $data_*.
        # A real post-Apply VX witness and per-table SHA are mandatory.
        var manifest_path: String = folder.path_join("fs_boot_final_authority.json")
        if not FileAccess.file_exists(manifest_path):
            errors.append("缺少 FS 啟動後權威資料證明 fs_boot_final_authority.json；只匯入原始 RVData 不可進入正式遊戲")
        else:
            var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
            if not manifest is Dictionary:
                errors.append("FS 啟動後權威資料證明 JSON 格式錯誤")
            else:
                var hashes: Dictionary = {}
                for name in NAMES:
                    hashes[name] = FileAccess.get_sha256(folder.path_join(name + ".json")).to_lower()
                for problem in validate_boot_manifest(manifest,hashes):
                    errors.append(problem)
    if not errors.is_empty():
        # Never accidentally allow partial raw data through load_all() after
        # source-consistency failure. In-memory synthetic test tables bypass this.
        tables.clear()
    boot_final_verified = errors.is_empty()
    return boot_final_verified

static func validate_boot_manifest(manifest: Dictionary, actual_hashes: Dictionary) -> PackedStringArray:
    # This is a reproducibility gate, NOT cryptographic proof of the witness
    # issuer. Human QA still needs the actual verified VX runtime trace.
    var problems := PackedStringArray()
    if str(manifest.get("schema","")) != "fs-boot-final-authority-v1":
        problems.append("啟動後權威資料格式版本不正確")
    if str(manifest.get("stage","")) != "post_FS_DB_AUTOSET.apply_all":
        problems.append("資料尚未確認是 FS_DB_AUTOSET.apply_all 之後的結果")
    if int(manifest.get("rgss2_script_sections",0)) != 505:
        problems.append("原始 RGSS2 載入順序尚未核對 505 段")
    if int(manifest.get("master_setup_pages",0)) != 22:
        problems.append("MasterSetup 22 段配置尚未核對")
    if not bool(manifest.get("vx_runtime_trace_verified",false)):
        problems.append("尚未完成 VX Runtime 來源數值比對")
    var witness: String = str(manifest.get("vx_runtime_witness_sha256",""))
    if not _looks_sha256(witness):
        problems.append("缺少合法的原 VX 執行痕跡 SHA256")
    var database_hashes: Variant = manifest.get("database_sha256",{})
    if not database_hashes is Dictionary:
        problems.append("權威資料庫各表 SHA256 格式無效")
    else:
        for name in NAMES:
            var expected: String = str(database_hashes.get(name,""))
            var actual: String = str(actual_hashes.get(name,""))
            if not _looks_sha256(expected) or actual != expected:
                problems.append("啟動後資料不一致或缺少 SHA256：" + name)
    return problems

static func _looks_sha256(value: String) -> bool:
    if value.length() != 64:
        return false
    for character in value:
        if "0123456789abcdef".find(character) == -1:
            return false
    return true

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
    # Game_Actor#odds (stock VX) = 4 - actor class.position.
    # Needed by source #372 final weighted random_target, never equal
    # odds for front/mid/back positions unless class data says so.
    var klass: Dictionary = record("classes",int(actor.get("class_id",0)))
    result["odds"] = maxi(0,4-int(klass.get("position",0)))
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
    result["note"] = str(enemy.get("note",""))
    # #013 Game_Battler#element_set returns []; #016 Game_Enemy does not
    # override it. Later dynamic RGSS2 aliases still need original VX
    # witness. This is the verified stock-source baseline only.
    result["element_set"] = []
    result["fs_attack_elements_verified"] = true
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
    # #015 Game_Actor#element_set: no weapons => [1] bare-hands
    # fighting element; otherwise ordered union of equipped weapons'
    # element_set, regardless of armor slots. Weapon-source data missing
    # must NOT masquerade as a valid no-element weapon attack.
    var attack_elements: Array[int] = []
    var found_weapon: bool = false
    var weapon_elements_verified: bool = true
    for slot in range(slots.size()):
        if equip_kind(stats,slot) != "weapons":
            continue
        var weapon_id: int = int(slots[slot])
        if weapon_id <= 0:
            continue
        var weapon: Dictionary = record("weapons",weapon_id)
        if weapon.is_empty() or not weapon.has("element_set") or not (
                weapon.get("element_set") is Array):
            weapon_elements_verified = false
            continue
        found_weapon = true
        for element in weapon.get("element_set",[]):
            var id: int = int(element)
            if not attack_elements.has(id):
                attack_elements.append(id)
    if not found_weapon and weapon_elements_verified:
        attack_elements = [1]
    result["element_set"] = attack_elements
    result["fs_attack_elements_verified"] = weapon_elements_verified
    return result
