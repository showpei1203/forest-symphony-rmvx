extends RefCounted
class_name FSElementSourceProvider

# Phase28 runtime DATA provider, not a second element rate authority.
# Original RGSS2 202940/202954 + 252561:
# Actor ID -> CLASS_ELEMENT_TABLE -> normal; Enemy ID -> normal.
# Source ranks: Game_Actor#class.element_ranks / Enemy#element_ranks,
# ALBERT_ACTOR_ENEMY_GROWTH::USE_ENEMY_ELEMENT_RATE=false (~205740).
# Original KGC::AddEquipmentOptions element_resistance: 100 plus
# (equip.element_resistance[id] - 100) for EACH equipped item (~171488).
# Target notes: actor armors + states + FS_BATTLE_V22 passive notes;
# enemy Note + states + FS_BATTLE_V22 passive notes (~253525).
#
# A private source map must be SHA-bound to the real post-Apply database
# witness. Synthetic tests may configure a test map explicitly, but this
# cannot accidentally enable production element damage.
var active: bool = false
var fixture_only: bool = false
var source_map: Dictionary = {}
var failures: Array[String] = []
var refresh_count: int = 0

func _fail(reason: String) -> Dictionary:
    if not failures.has(reason):
        failures.append(reason)
    return {"ok":false,"reason":reason}

static func _type_pair(raw: Variant) -> Dictionary:
    if not (raw is Array) or raw.size()!=2:
        return {"ok":false}
    var primary: String = str(raw[0]).to_lower()
    var secondary: String = "" if raw[1]==null else str(raw[1]).to_lower()
    if not FSElementFinalAuthority.CHART.has(primary):
        return {"ok":false}
    if not secondary.is_empty() and not FSElementFinalAuthority.CHART.has(secondary):
        return {"ok":false}
    return {"ok":true,"primary":primary,"secondary":secondary}

static func _map_type(mapping: Variant,index: int) -> Variant:
    if not (mapping is Dictionary):
        return null
    var key: String = str(index)
    if mapping.has(key):
        return mapping[key]
    if mapping.has(index):
        return mapping[index]
    return null

func configure_fixture(verified_map: Dictionary) -> Dictionary:
    # This entrypoint is limited to in-memory synthetic Godot CI tests.
    # It does not make db.boot_final_verified=true, and must not be used by
    # actual data loaders; production uses the SHA-checked file path.
    if str(verified_map.get("source",""))!="FS_ElementalSettings_Phase28":
        return _fail("合成型別表缺少明確原始來源識別")
    for key in ["actors","classes","enemies",
            "actor_passive_notes","enemy_passive_notes"]:
        if not (verified_map.get(key,null) is Dictionary):
            return _fail("合成來源對照表缺少："+key)
    if verified_map.get("growth_use_enemy_element_rate",null)!=false:
        return _fail("ActorEnemyGrowth 元素 Rank 來源必須明確為 false")
    if str(verified_map.get("passive_source_mode",""))=="skills" and not (
            verified_map.get("passive_names",null) is Dictionary):
        return _fail("原版 Passive 名稱與 ID 映射未驗證")
    source_map=verified_map.duplicate(true)
    active=true
    fixture_only=true
    return {"ok":true}

func configure_private(db: FSDatabase,folder: String="res://data") -> Dictionary:
    # A user-placed private JSON is insufficient by itself; both the
    # original post-Apply 11-table witness and manifest-bound SHA must pass.
    active=false
    fixture_only=false
    source_map.clear()
    if not db.boot_final_verified:
        return _fail("Post-Apply 11 表及 VX Runtime Witness 尚未通過")
    var manifest_path: String=folder.path_join("fs_boot_final_authority.json")
    var map_path: String=folder.path_join("fs_element_type_provider.json")
    if not FileAccess.file_exists(manifest_path) or not FileAccess.file_exists(map_path):
        return _fail("缺少私有元素對照或原版啟動 manifest")
    var manifest: Variant=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
    var snapshot: Variant=JSON.parse_string(FileAccess.get_file_as_string(map_path))
    if not (manifest is Dictionary) or not (snapshot is Dictionary):
        return _fail("私有來源檔必須是有效 JSON 物件")
    var declared_sha: String=str(manifest.get("fs_element_provider_sha256","")).to_lower()
    if declared_sha.length()!=64 or declared_sha!=FileAccess.get_sha256(map_path).to_lower():
        return _fail("私有元素來源 SHA256 未被 post-Apply manifest 授權")
    if str(snapshot.get("source",""))!="FS_ElementalSettings_Phase28":
        return _fail("私有元素來源識別不符合 Phase28")
    for key in ["actors","classes","enemies",
            "actor_passive_notes","enemy_passive_notes"]:
        if not (snapshot.get(key,null) is Dictionary):
            return _fail("私有元素來源缺少："+key)
    if snapshot.get("growth_use_enemy_element_rate",null)!=false:
        return _fail("來源 ActorEnemyGrowth 與原始腳本設定不同")
    # Production cannot rely on handwritten per-actor effective Note strings;
    # the passive skill status is reconstructed from the verified post-Apply
    # SKILL table plus source PASSIVE_NAMES and skill.passive/Note markers.
    if str(snapshot.get("passive_source_mode",""))!="skills" or not (
            snapshot.get("passive_names",null) is Dictionary):
        return _fail("正式被動來源必須可從技能表自動重建，不接受手填 Note")
    source_map=snapshot.duplicate(true)
    active=true
    return {"ok":true,"sha256":declared_sha}

func _ranks(raw: Variant) -> Dictionary:
    var result: Dictionary={}
    var values: Variant=raw
    if raw is Dictionary and raw.has("data_int16"):
        values=raw["data_int16"]
    if not (values is Dictionary or values is Array):
        return _fail("原始 Class／Enemy 的 element_ranks Table 缺失")
    for id in FSElementFinalAuthority.ID_TO_TYPE.keys():
        var rank: Variant=null
        if values is Array:
            if int(id)>=values.size():
                return _fail("element_ranks 原始 Table 長度不足 ID%d" % int(id))
            rank=values[int(id)]
        else:
            var k: String=str(id)
            if values.has(k):
                rank=values[k]
            elif values.has(id):
                rank=values[id]
            else:
                return _fail("element_ranks 缺失 ID%d" % int(id))
        if not (rank is int or rank is float):
            return _fail("element_ranks ID%d 不是來源整數" % int(id))
        var n: int=int(rank)
        if n<0 or n>=FSElementFinalAuthority.RANK_RATES.size():
            return _fail("element_ranks ID%d 無效等級%d" % [int(id),n])
        result[str(id)]=n
    return {"ok":true,"ranks":result}

func _passive_notes(db: FSDatabase,battler: Dictionary) -> Dictionary:
    var actor: bool=bool(battler.get("actor",false))
    var family: String="actor_passive_notes" if actor else "enemy_passive_notes"
    var key: String=str(int(battler.get("id",0)))
    if actor and str(source_map.get("passive_source_mode",""))=="skills":
        var known_names: Variant=source_map.get("passive_names",null)
        var current_skills: Variant=battler.get("skills",null)
        if not (known_names is Dictionary) or not (
                current_skills is Array):
            return _fail("原版目前已學被動 Skill ID 集合或名稱表缺失")
        var texts: Array=[]
        for raw_skill in current_skills:
            var skill_id: int=int(raw_skill)
            if skill_id<1:
                return _fail("角色 Skill ID 不是有效正整數")
            var skill: Dictionary=db.record("skills",skill_id)
            if skill.is_empty() or not skill.has("name") or not (
                    skill.get("note",null) is String):
                return _fail("目前技能%d 缺少 post-Apply Note／名稱" % skill_id)
            var note: String=str(skill["note"])
            var name_match: Variant=_map_type(known_names,skill_id)
            var named: bool=name_match!=null and str(skill["name"])==str(name_match)
            var passive: bool=bool(skill.get("passive",false)) or (
                note.to_lower().contains("<mechanic_passive>")) or named
            if passive:
                # Original FS_BATTLE_V22.note_with_defaults adds 3 passive
                # fallback effects (cc_od, bonus_if_od and state_chance),
                # NONE of which are elemental ele_weak/ele_res tags. The
                # Phase28 element subset reads only exact source Skill Note.
                texts.append(note)
        return {"ok":true,"notes":texts}
    # Enemies have no authoritative Game_Enemy#skills list in the
    # current source bridge. Their effective passive Notes require an
    # explicit private post-Apply witness, never an assumed empty set.
    var notes: Variant=_map_type(source_map.get(family,{}),int(key))
    if not (notes is Array):
        return _fail("原版被動技能有效 Note 清單未證明："+family+" #"+key)
    var result: Array=[]
    for n in notes:
        if not (n is String):
            return _fail("被動技能 Note 項目不是原始來源字串")
        result.append(n)
    return {"ok":true,"notes":result}

func build(db: FSDatabase,battler: Dictionary) -> Dictionary:
    if not active:
        return _fail("FS Element 來源 Provider 尚未啟用")
    if not fixture_only and not db.boot_final_verified:
        return _fail("正式遊戲必須先完成 post-Apply VX 來源驗證")
    var actor: bool=bool(battler.get("actor",false))
    var id: int=int(battler.get("id",0))
    var record: Dictionary=db.record("actors" if actor else "enemies",id)
    if record.is_empty():
        return _fail("原始 Actor／Enemy 資料表缺少 ID%d" % id)
    var type_raw: Variant=null
    if actor:
        var klass_id: int=int(battler.get("class_id",-1))
        if klass_id<1:
            return _fail("角色 Class ID 不可驗證")
        type_raw=_map_type(source_map.get("actors",{}),id)
        if type_raw==null:
            type_raw=_map_type(source_map.get("classes",{}),klass_id)
    else:
        type_raw=_map_type(source_map.get("enemies",{}),id)
    # Original ElementalSettings fallback is :normal,nil, allowed only
    # after the full original type map itself is source-authorized.
    if type_raw==null:
        type_raw=["normal",null]
    var type_pair: Dictionary=_type_pair(type_raw)
    if not bool(type_pair.get("ok",false)):
        return _fail("原始 Actor／Class／Enemy 元素對照不合法")
    var rank_record: Dictionary=db.record("classes",int(
        battler.get("class_id",0))) if actor else record
    if rank_record.is_empty() or not rank_record.has("element_ranks"):
        return _fail("原版 Class／Enemy element_ranks 不存在")
    var rank_quote: Dictionary=_ranks(rank_record["element_ranks"])
    if not bool(rank_quote.get("ok",false)):
        return rank_quote
    var passive: Dictionary=_passive_notes(db,battler)
    if not bool(passive.get("ok",false)):
        return passive
    var notes: Array=[]
    if not actor:
        if not record.has("note") or not (record["note"] is String):
            return _fail("敵人原始 Note 文字缺失")
        notes.append(record["note"])
    var state_ids: Variant=battler.get("states",null)
    if not (state_ids is Array):
        return _fail("角色狀態陣列未初始化")
    for value in state_ids:
        var state: Dictionary=db.record("states",int(value))
        if state.is_empty() or not state.has("note") or not (
                state.has("element_set")) or not (
                state["element_set"] is Array):
            return _fail("State%d 缺少來源 Note／Element Set" % int(value))
        notes.append(str(state["note"]))
    var resistance: Dictionary={}
    for e in FSElementFinalAuthority.ID_TO_TYPE.keys():
        resistance[str(e)]=100
    if actor:
        var equipment: Variant=battler.get("equipment",null)
        if not (equipment is Array):
            return _fail("角色裝備集合未驗證")
        for slot in range(equipment.size()):
            var item_id: int=int(equipment[slot])
            if item_id<=0:
                continue
            var kind: String=db.equip_kind(battler,slot)
            if kind!="weapons" and kind!="armors":
                return _fail("未知裝備欄位")
            var item: Dictionary=db.record(kind,item_id)
            if item.is_empty() or not item.has("note") or not (
                    item["note"] is String):
                return _fail("裝備%d Note 資料缺失" % item_id)
            for key in ["element_resistance","invalid_element_set",
                    "guard_element_set","weak_element_set",
                    "absorb_element_set"]:
                if not item.has(key):
                    return _fail("KGC 裝備%d 缺少已解碼的 %s" % [item_id,key])
            if not (item["element_resistance"] is Dictionary):
                return _fail("KGC 裝備元素抗性並非字典")
            for key in ["invalid_element_set","guard_element_set",
                    "weak_element_set","absorb_element_set"]:
                if not (item[key] is Array):
                    return _fail("KGC 裝備 %s 不是 Element Set" % key)
            if kind=="armors":
                if not item.has("element_set") or not (
                        item["element_set"] is Array):
                    return _fail("Armor 原生元素守備集合缺失")
                notes.append(item["note"])
            for element_id in FSElementFinalAuthority.ID_TO_TYPE.keys():
                var k: String=str(element_id)
                var overrides: Dictionary=item["element_resistance"]
                var v: Variant=overrides.get(k,overrides.get(element_id,null))
                if v!=null:
                    resistance[k]=int(resistance[k])+int(v)-100
    for text in passive["notes"]:
        notes.append(text)
    return {"ok":true,"verified":true,"primary":type_pair["primary"],
        "secondary":type_pair["secondary"],"ranks":rank_quote["ranks"],
        "extra_notes_verified":true,"extra_notes":notes,
        "equipment_verified":true if actor else false,
        "element_resistance":resistance,
        "provenance":"fixture" if fixture_only else "private_post_Apply"}

func refresh(db: FSDatabase,battler: Dictionary) -> Dictionary:
    var result: Dictionary=build(db,battler)
    if not bool(result.get("ok",false)):
        battler.erase("fs_element_authority")
        return result
    # No random number or action resource is consumed; refresh is pure
    # apart from replacing the derived source snapshot on the battler.
    var attached: Dictionary=result.duplicate(true)
    attached.erase("ok")
    battler["fs_element_authority"]=attached
    refresh_count+=1
    return result
