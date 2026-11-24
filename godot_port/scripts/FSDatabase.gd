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
                # A SHA string in JSON is only a claim. Verify the actual
                # retained VX post-Apply runtime witness bytes as well.
                var witness_path: String = folder.path_join("fs_boot_final_runtime_witness.json")
                if not FileAccess.file_exists(witness_path):
                    errors.append("缺少實際 VX 啟動後執行證據：" + witness_path)
                else:
                    var witness_sha: String = FileAccess.get_sha256(witness_path).to_lower()
                    if witness_sha != str(manifest.get("vx_runtime_witness_sha256","")):
                        errors.append("VX 執行證據檔案 SHA256 不符合 manifest")
                    var witness_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(witness_path))
                    if not (witness_data is Dictionary):
                        errors.append("VX 執行證據不是合法 JSON 物件")
                    else:
                        for problem in validate_runtime_witness(witness_data):
                            errors.append(problem)
                        for problem in validate_witness_against_tables(witness_data,tables):
                            errors.append(problem)
                        # P538F: independent table semantics must pass even
                        # when an attacker re-hashes altered JSON and edits
                        # witness counts to match. Counts are not provenance.
                        for problem in validate_runtime_table_integrity(tables):
                            errors.append(problem)
    if not errors.is_empty():
        # Never accidentally allow partial raw data through load_all() after
        # source-consistency failure. In-memory synthetic test tables bypass this.
        tables.clear()
    boot_final_verified = errors.is_empty()
    return boot_final_verified

static func validate_runtime_witness(witness: Dictionary) -> PackedStringArray:
    var problems := PackedStringArray()
    if str(witness.get("stage","")) != "post_FS_DB_AUTOSET.apply_all":
        problems.append("VX 執行證據不是 FS_DB_AUTOSET.apply_all 之後的快照")
    if str(witness.get("engine","")) != "RPG Maker VX RGSS2":
        problems.append("VX 執行證據缺少原始 RGSS2 引擎身分")
    var roster: Variant = witness.get("party_actor_ids",null)
    if not (roster is Array) or roster.is_empty():
        problems.append("VX 執行證據缺少啟動後實際隊伍")
    var table_counts: Variant = witness.get("table_counts",null)
    if not (table_counts is Dictionary):
        problems.append("VX 執行證據缺少啟動後資料表計數")
    else:
        for name in NAMES:
            if name == "system":
                continue
            if int(table_counts.get(name,0)) <= 0:
                problems.append("VX 執行證據缺少資料表計數：" + name)
    return problems

static func validate_witness_against_tables(witness: Dictionary, loaded_tables: Dictionary) -> PackedStringArray:
    # An internally plausible witness is not enough: it must describe the
    # same actual post-Apply data that Godot is about to execute.
    var problems := PackedStringArray()
    var counts: Variant = witness.get("table_counts",{})
    if not (counts is Dictionary):
        problems.append("VX 執行證據缺少資料表計數")
        return problems
    for name in NAMES:
        if name == "system":
            continue
        var rows: Variant = loaded_tables.get(name,null)
        if not (rows is Array):
            problems.append("Godot 載入的資料表不是陣列：" + name)
            continue
        var actual_count: int = 0
        for row in rows:
            if row != null:
                actual_count += 1
        if int(counts.get(name,-1)) != actual_count:
            problems.append("VX/Godot 啟動後非空記錄數不一致：" + name)
    var sys: Variant = loaded_tables.get("system",null)
    if not (sys is Dictionary):
        problems.append("Godot System 資料不是物件")
    else:
        var source_roster: Variant = sys.get("party_members",null)
        var runtime_roster: Variant = witness.get("party_actor_ids",null)
        if not (source_roster is Array) or not (runtime_roster is Array):
            problems.append("VX/Godot 啟動後隊伍格式錯誤")
        elif source_roster != runtime_roster:
            # A runtime party may differ from the System starting roster if
            # the witness is captured after events. Require boot-time capture.
            problems.append("VX/Godot 初始隊伍不一致，需啟動後事件前 witness")
    return problems

# P538F: semantic integrity checks for the eleven post-Apply tables.
# A structurally valid witness and matching per-file SHA are necessary but
# cannot make broken references or corrupt RPG::Actor parameters executable.
# This never repairs missing source data and never sets boot_final_verified.
static func validate_runtime_table_integrity(loaded_tables:Dictionary)->PackedStringArray:
    var problems:=PackedStringArray()
    for name in NAMES:
        var data:Variant=loaded_tables.get(name,null)
        if name=="system":
            if not (data is Dictionary):
                problems.append("FS 正式 System 資料不是字典")
            continue
        if not (data is Array):
            problems.append("FS 正式資料表不是陣列："+name)
            continue
        var rows:Array=data
        if rows.is_empty() or rows[0]!=null:
            problems.append("VX 索引第 0 筆必須是 null："+name)
        for i in range(1,rows.size()):
            if rows[i]==null:
                continue
            if not (rows[i] is Dictionary) or int(rows[i].get("id",-1))!=i:
                problems.append("VX 記錄 id 與索引不一致：%s[%d]" % [name,i])
                break

    var actors:Variant=loaded_tables.get("actors",null)
    var classes:Variant=loaded_tables.get("classes",null)
    var enemies:Variant=loaded_tables.get("enemies",null)
    var troops:Variant=loaded_tables.get("troops",null)
    var skills:Variant=loaded_tables.get("skills",null)
    var sys:Variant=loaded_tables.get("system",null)
    if not (actors is Array) or not (classes is Array):
        return problems
    for actor in actors:
        if not (actor is Dictionary):
            continue
        var actor_id:int=int(actor.get("id",0))
        var class_id:int=int(actor.get("class_id",0))
        if class_id<=0 or class_id>=classes.size() or not (
                classes[class_id] is Dictionary):
            problems.append("FS Actor #%d 的來源職業不存在" % actor_id)
        var params:Variant=actor.get("parameters",null)
        if not (params is Dictionary):
            problems.append("FS Actor #%d 缺少來源六維成長 Table" % actor_id)
            continue
        var x:Variant=params.get("xsize",null)
        var y:Variant=params.get("ysize",null)
        var z:Variant=params.get("zsize",1)
        var raw:Variant=params.get("data_int16",null)
        if not (x is int) or x!=6 or not (y is int) or y<1 or not (
                z is int) or z!=1 or not (raw is Array):
            problems.append("FS Actor #%d 成長 Table 維度不合法" % actor_id)
            continue
        if raw.size()!=x*y*z:
            problems.append("FS Actor #%d 成長 Table 長度不符" % actor_id)
            continue
        for n in raw:
            if not (n is int) or n<-32768 or n>32767:
                problems.append("FS Actor #%d 成長 Table 含非法 int16" % actor_id)
                break
    if sys is Dictionary:
        var party:Variant=sys.get("party_members",null)
        if not (party is Array) or party.is_empty():
            problems.append("FS System 原始出場隊伍不存在")
        else:
            var used:Dictionary={}
            for member in party:
                if not (member is int) or member<=0 or member>=actors.size() or (
                        not actors[member] is Dictionary):
                    problems.append("FS System 初始隊伍包含不存在 Actor")
                elif used.has(member):
                    problems.append("FS System 初始隊伍重複 Actor")
                else:
                    used[member]=true
    if troops is Array and enemies is Array:
        for troop in troops:
            if not (troop is Dictionary):
                continue
            var members:Variant=troop.get("members",[])
            if not (members is Array):
                problems.append("FS Troop #%d members 格式錯誤" %
                    int(troop.get("id",0)))
                continue
            for member in members:
                if not (member is Dictionary):
                    problems.append("FS Troop 成員不是 Enemy 權威記錄")
                    break
                var enemy_id:int=int(member.get("enemy_id",0))
                if enemy_id<=0 or enemy_id>=enemies.size() or not (
                        enemies[enemy_id] is Dictionary):
                    problems.append("FS Troop #%d 引用了不存在 Enemy #%d" %
                        [int(troop.get("id",0)),enemy_id])
                    break
    if skills is Array:
        for klass in classes:
            if not (klass is Dictionary):
                continue
            var learnings:Variant=klass.get("learnings",[])
            if not (learnings is Array):
                problems.append("FS Class #%d learnings 格式錯誤" %
                    int(klass.get("id",0)))
                continue
            for learning in learnings:
                if not (learning is Dictionary):
                    problems.append("FS Class 的技能學習記錄格式錯誤")
                    break
                var skill_id:int=int(learning.get("skill_id",0))
                if skill_id<=0 or skill_id>=skills.size() or not (
                        skills[skill_id] is Dictionary):
                    problems.append("FS Class #%d 引用不存在 Skill #%d" %
                        [int(klass.get("id",0)),skill_id])
                    break
    return problems

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
    result["battler_hue"] = int(enemy.get("battler_hue",0))  # Original VX hue; unported shifts fail closed.
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
