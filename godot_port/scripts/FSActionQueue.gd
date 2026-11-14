extends RefCounted
class_name FSActionQueue

# Bounded, source-shaped Tankentai command -> ACT -> execute -> recharge
# candidate, traced against script #231 lines 176-224, 1310-1382, 559-622.
# Commands are validated when selected, but NO MP/item is spent until ACT
# completes AND the target/cost is revalidated. Original damage, OD, cover,
# enemy AI and forced/union actions are outside this explicit scope.
#
# This component deliberately does NOT allow more than one command per actor
# and does NOT auto-execute arbitrary enemy AI.

var pending: Dictionary = {}
var completed: Array[Dictionary] = []
var next_serial: int = 1

func _key(index: int) -> String:
    return "actor:%d" % index

func has_pending(index: int) -> bool:
    return pending.has(_key(index))

func request(battle, index: int, kind: String, target_index: int = -1,
        object_id: int = 0) -> bool:
    if not battle.active or not battle.source_atb_initialized:
        return false
    if index < 0 or index >= battle.party.size():
        return false
    if kind not in ["attack","guard","skill","item"]:
        return false
    var key: String = _key(index)
    var actor: Dictionary = battle.party[index]
    if pending.has(key) or int(actor.get("hp",0)) <= 0 or not bool(
            actor.get("source_at_active",false)):
        return false

    var target_side: String = "none"
    var target: Dictionary = {}
    if kind == "attack":
        target_side = "enemy"
    elif kind == "skill":
        var skill: Dictionary = battle.db.record("skills",object_id)
        if skill.is_empty():
            return false
        if int(skill.get("scope",0)) == 1:
            target_side = "enemy"
        elif int(skill.get("scope",0)) == 7:
            target_side = "actor"
        else:
            return false
    elif kind == "item":
        target_side = "actor"
    if target_side == "enemy":
        if target_index < 0 or target_index >= battle.enemies.size():
            return false
        target = battle.enemies[target_index]
    elif target_side == "actor":
        if target_index < 0 or target_index >= battle.party.size():
            return false
        target = battle.party[target_index]
    if target_side != "none" and int(target.get("hp",0)) <= 0:
        return false

    if kind == "skill" and not battle.skill_preflight(actor,target,object_id):
        return false
    if kind == "item":
        if int(battle.inventory.get("item:%d" % object_id,0)) <= 0:
            return false
        var item: Dictionary = battle.db.record("items",object_id)
        var effect: Dictionary = FSItemRules.preview(item,actor,target,true)
        if not bool(effect.get("ok",false)):
            return false

    if not battle.begin_source_atb_charge(actor,kind,object_id):
        return false
    var token: int = next_serial
    next_serial += 1
    pending[key] = {
        "serial":token,"actor_index":index,"kind":kind,
        "target_side":target_side,"target_index":target_index,
        "object_id":object_id
    }
    battle.changed.emit("%s 指令已確認，ACT 蓄力中（尚未支付成本）" %
        str(actor.get("name","角色")))
    return true

func _target(battle, entry: Dictionary) -> Dictionary:
    var side: String = str(entry.get("target_side","none"))
    var index: int = int(entry.get("target_index",-1))
    if side == "enemy":
        if index >= 0 and index < battle.enemies.size():
            return battle.enemies[index]
    elif side == "actor":
        if index >= 0 and index < battle.party.size():
            return battle.party[index]
    return {}

func cancel_interrupted(battle) -> int:
    var canceled: int = 0
    for key in pending.keys():
        var entry: Dictionary = pending[key]
        var index: int = int(entry["actor_index"])
        if index >= battle.party.size():
            pending.erase(key)
            canceled += 1
            continue
        var actor: Dictionary = battle.party[index]
        # Source #374 ComboCore negative shift re-arms atb_count_up.
        # Death/forced stop/charge canceled must never leave a queued action
        # that executes after the gauge fills again.
        if int(actor.get("hp",0)) <= 0 or bool(actor.get("source_atb_count_up",true)) or (
                bool(actor.get("source_at_active",false))):
            pending.erase(key)
            canceled += 1
            battle.changed.emit("%s ACT 蓄力中斷，待執行指令已取消" %
                str(actor.get("name","角色")))
    return canceled

func resolve_ready(battle) -> int:
    if not battle.active or battle.source_atb_wait:
        return 0
    cancel_interrupted(battle)
    var resolved: int = 0
    # Original #231 scans party array before troop array, one action
    # enqueue at a time. This candidate resolves one ready actor per call.
    for index in range(battle.party.size()):
        var key: String = _key(index)
        if not pending.has(key):
            continue
        var actor: Dictionary = battle.party[index]
        if not battle.source_action_charged(actor):
            continue
        var entry: Dictionary = pending[key]
        var kind: String = str(entry["kind"])
        var obj: int = int(entry["object_id"])
        var target: Dictionary = _target(battle,entry)
        var side: String = str(entry["target_side"])
        # Pop before executing to prevent duplicate completion/reentrancy.
        pending.erase(key)
        var success: bool = false
        if kind == "guard":
            actor["guarding"] = true
            success = true
            battle.changed.emit("%s 防禦姿態成立" % actor.get("name","角色"))
        elif not target.is_empty() and int(target.get("hp",0)) > 0:
            if kind == "attack" and side == "enemy":
                actor["guarding"] = false
                battle.attack(actor,target)
                success = true
            elif kind == "skill":
                success = battle.use_skill(actor,target,obj)
            elif kind == "item":
                success = battle.use_item(target,obj,actor,true)
        if success:
            battle.finish_source_atb_action(actor,kind,obj)
            completed.append({"serial":int(entry["serial"]),"kind":kind,
                "actor_index":index,"success":true})
        else:
            # Target changed, unsupported skill note or no MP/item at
            # execution time: no resource is spent. Use canceled-turn reset
            # (source parity for failed actions still needs VX witness).
            FSTankentaiATBCore.reset_after_action(actor,kind,obj,battle.db)
            completed.append({"serial":int(entry["serial"]),"kind":kind,
                "actor_index":index,"success":false})
            battle.changed.emit("%s 指令無法結算，未支付成本" %
                str(actor.get("name","角色")))
        resolved += 1
        break
    return resolved
