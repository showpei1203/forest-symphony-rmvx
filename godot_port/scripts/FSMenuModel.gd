extends RefCounted
class_name FSMenuModel

# Functional MENU adapter for migrated source DB, shared FSBattle+FSGameState.
# It does not invent combat item effects, EXP rules, or source image assets.
var db: FSDatabase
var battle: FSBattle

const SLOT_NAMES: Array[String] = ["主手", "副手／盾牌", "頭部", "身體", "飾品"]

func _init(database: FSDatabase, combat: FSBattle) -> void:
    db = database
    battle = combat

func party() -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    for actor in battle.party:
        rows.append({
            "id":int(actor.get("id",0)),"name":str(actor.get("name","?")),
            "level":int(actor.get("level",1)),"hp":int(actor.get("hp",0)),
            "maxhp":int(actor.get("maxhp",0)),"mp":int(actor.get("mp",0)),
            "maxmp":int(actor.get("maxmp",0)),"atk":int(actor.get("atk",0)),
            "def":int(actor.get("def",0)),"spi":int(actor.get("spi",0)),
            "agi":int(actor.get("agi",0)),"hit":int(actor.get("hit",0)),
            "eva":int(actor.get("eva",0)),"cri":int(actor.get("cri",0))
        })
    return rows

func known_skills(actor_index: int) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if actor_index < 0 or actor_index >= battle.party.size():
        return result
    var actor: Dictionary = battle.party[actor_index]
    for skill_id in actor.get("skills",[]):
        var row: Dictionary = db.record("skills",int(skill_id))
        if row.is_empty():
            continue
        var quote: Dictionary = FSSkillCostRules.preview(row,actor)
        result.append({
            "id":int(skill_id),"name":str(row.get("name","")),
            "mp_cost":int(quote.get("mp",0)) if bool(quote.get("ok",false)) else -1,
            "cost_verified":bool(quote.get("ok",false)),
            "cost_warning":str(quote.get("reason","")),
            "scope":int(row.get("scope",0)),
            "occasion":int(row.get("occasion",0)),
            "icon_index":int(row.get("icon_index",0)),
            "description":str(row.get("description",""))
        })
    return result

func inventory_rows(kind: String = "item") -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if not kind in ["item","weapon","armor"]:
        return result
    var db_kind: String = {"item":"items","weapon":"weapons","armor":"armors"}[kind]
    var keys: Array[int] = []
    for key in battle.inventory:
        var parts: PackedStringArray = str(key).split(":")
        if parts.size() != 2 or parts[0] != kind:
            continue
        var id: int = int(parts[1])
        if int(battle.inventory[key]) > 0:
            keys.append(id)
    keys.sort()
    for id in keys:
        var source: Dictionary = db.record(db_kind,id)
        if source.is_empty():
            continue
        result.append({
            "id":id,"name":str(source.get("name","")),
            "count":int(battle.inventory["%s:%d" % [kind,id]]),
            "description":str(source.get("description","")),
            "icon_index":int(source.get("icon_index",0))
        })
    return result

func equipment_rows(actor_index: int) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if actor_index < 0 or actor_index >= battle.party.size():
        return result
    var actor: Dictionary = battle.party[actor_index]
    var slots: Array = actor.get("equipment",[])
    for index in range(slots.size()):
        var kind: String = db.equip_kind(actor,index)
        var id: int = int(slots[index])
        var name: String = "（未裝備）"
        if id > 0:
            name = str(db.record(kind,id).get("name","未知裝備"))
        result.append({
            "slot":index,"label":SLOT_NAMES[index],
            "kind":kind,"id":id,"name":name,
            "locked":bool(actor.get("fix_equipment",false))
        })
    return result

func available_equipment(actor_index: int, slot: int) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if actor_index < 0 or actor_index >= battle.party.size():
        return result
    var actor: Dictionary = battle.party[actor_index]
    if not db.can_equip(actor,slot,0):
        return result
    result.append({"id":0,"name":"（卸下）"})
    var kind: String = db.equip_kind(actor,slot)
    var db_kind: String = "weapon" if kind == "weapons" else "armor"
    for entry in inventory_rows(db_kind):
        var id: int = int(entry["id"])
        if db.can_equip(actor,slot,id):
            result.append({
                "id":id,"name":str(entry["name"]),
                "count":int(entry["count"])
            })
    return result

func change_equipment(actor_index: int, slot: int, item_id: int) -> bool:
    return battle.equip(actor_index,slot,item_id)

func switch_formation(a: int, b: int) -> bool:
    if a < 0 or b < 0 or a >= battle.party.size() or b >= battle.party.size():
        return false
    if a == b:
        return true
    var first: Dictionary = battle.party[a]
    battle.party[a] = battle.party[b]
    battle.party[b] = first
    if battle.world != null:
        battle.world.party_actor_ids.clear()
        for actor in battle.party:
            battle.world.party_actor_ids.append(int(actor.get("id",0)))
    return true
