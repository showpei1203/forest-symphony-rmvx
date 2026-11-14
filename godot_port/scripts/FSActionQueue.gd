extends RefCounted
class_name FSActionQueue

# Bounded, source-shaped Tankentai command -> ACT -> execute -> recharge
# candidate, traced against script #231 lines 176-224, 1310-1382, 559-622.
# Commands are validated when selected, but NO MP/item is spent until ACT
# completes AND the target/cost is revalidated. Enemy AI is a LIMITED
# source-based roulette/weighted target candidate and not full Boss AI.
# Original final damage, OD, cover and forced/union actions are unresolved.

var pending: Dictionary = {}
var completed: Array[Dictionary] = []
var next_serial: int = 1
var enemy_pending: Dictionary = {}
var enemy_refusals: Dictionary = {}
var ai_rng: FSAIRandom = FSAIRandom.new()

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
    # Source phase IDs are pending, NOT actual status effects. A Boss
    # shield/phase awaiting effect parity cannot be damaged through this
    # provisional generic action queue.
    if not target.is_empty() and bool(
            target.get("fs_boss_phase_effects_pending",false)):
        return false
    if target_side == "enemy":
        var priority: Dictionary = FSTargetPriority.player_enemy_candidates(
            battle,object_id if kind=="skill" else 0)
        if not bool(priority.get("ok",false)) or not (
                target_index in priority.get("indices",[])):
            return false

    if kind == "attack" and not battle.attack_preflight(actor,target):
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
    for key in enemy_pending.keys():
        var e: Dictionary = enemy_pending[key]
        var idx: int = int(e["enemy_index"])
        if idx < 0 or idx >= battle.enemies.size():
            enemy_pending.erase(key)
            canceled += 1
            continue
        var enemy: Dictionary = battle.enemies[idx]
        if int(enemy.get("hp",0)) <= 0 or bool(enemy.get("source_atb_count_up",true)) or (
                bool(enemy.get("source_at_active",false))):
            enemy_pending.erase(key)
            canceled += 1
            battle.changed.emit("%s 的敵方 ACT 已被中斷，指令取消" %
                str(enemy.get("name","敵人")))
    return canceled

func _enemy_key(index: int) -> String:
    return "enemy:%d" % index

func schedule_enemy(battle) -> bool:
    if not battle.active or not battle.source_atb_initialized or battle.source_atb_wait:
        return false
    for index in range(battle.enemies.size()):
        var key: String = _enemy_key(index)
        if enemy_pending.has(key) or enemy_refusals.has(key):
            continue
        var enemy: Dictionary = battle.enemies[index]
        if int(enemy.get("hp",0)) <= 0 or not bool(enemy.get("source_at_active",false)):
            continue
        var choice: Dictionary = FSEnemyAIDecision.choose(battle,index,ai_rng)
        if not bool(choice.get("ok",false)):
            # Missing source rules means NO imaginary fallback attack. Keep the
            # enemy ready, report once, and leave the original DB untouched.
            enemy_refusals[key] = str(choice.get("reason","unverified source"))
            battle.changed.emit("%s 的原始 AI 尚無安全實作：%s" % [
                enemy.get("name","敵人"),enemy_refusals[key]])
            continue
        var kind: String = str(choice["kind"])
        var obj: int = int(choice.get("object_id",0))
        var side: String = str(choice.get("target_side","none"))
        var target_index: int = int(choice.get("target_index",-1))
        var target: Dictionary = {}
        if side == "actor" and target_index >= 0 and target_index < battle.party.size():
            target = battle.party[target_index]
        elif side == "enemy" and target_index >= 0 and target_index < battle.enemies.size():
            target = battle.enemies[target_index]
        if kind == "skill" and (target.is_empty() or not battle.skill_preflight(enemy,target,obj)):
            enemy_refusals[key] = "source skill preflight invalid"
            continue
        if not battle.begin_source_atb_charge(enemy,kind,obj):
            continue
        var serial: int = next_serial
        next_serial += 1
        enemy_pending[key] = {
            "serial":serial,"enemy_index":index,"kind":kind,
            "target_side":side,"target_index":target_index,"object_id":obj
        }
        battle.changed.emit("%s AI 已選擇 %s，進入 ACT（尚未結算）" % [
            enemy.get("name","敵人"),kind])
        return true
    return false

func _enemy_target(battle,entry: Dictionary) -> Dictionary:
    var target_index: int = int(entry.get("target_index",-1))
    var side: String = str(entry.get("target_side","none"))
    if side == "actor" and target_index >= 0 and target_index < battle.party.size():
        return battle.party[target_index]
    if side == "enemy" and target_index >= 0 and target_index < battle.enemies.size():
        return battle.enemies[target_index]
    return {}

func _resolve_enemy_ready(battle) -> int:
    for index in range(battle.enemies.size()):
        var key: String = _enemy_key(index)
        if not enemy_pending.has(key):
            continue
        var enemy: Dictionary = battle.enemies[index]
        if not battle.source_action_charged(enemy):
            continue
        var entry: Dictionary = enemy_pending[key]
        var kind: String = str(entry["kind"])
        var object_id: int = int(entry["object_id"])
        var target: Dictionary = _enemy_target(battle,entry)
        enemy_pending.erase(key) # Pop before any battle signals/reentrancy.
        var success: bool = false
        if kind == "guard":
            enemy["guarding"] = true
            success = true
        elif not target.is_empty() and int(target.get("hp",0)) > 0 and (
                not bool(target.get("fs_boss_phase_effects_pending",false))):
            if kind == "attack" and battle.party.has(target):
                if battle.attack_preflight(enemy,target):
                    enemy["guarding"] = false
                    battle.attack(enemy,target)
                    success = true
            elif kind == "skill":
                success = battle.use_skill(enemy,target,object_id)
        if success and battle.active:
            battle.finish_source_atb_action(enemy,kind,object_id)
        elif success:
            # A lethal final hit ends battle. Recharge is still bookkept, but
            # no more enemy commands are scheduled after the result.
            FSTankentaiATBCore.reset_after_action(enemy,kind,object_id,battle.db)
            battle.enemy_valid_action_completed(enemy)
        else:
            # Lost targets and unsupported conditions are NOT charged.
            # The precise enemy retry/turn end remains a VX trace blocker.
            FSTankentaiATBCore.reset_after_action(enemy,kind,object_id,battle.db)
            battle.changed.emit("%s 的敵方指令未能執行，無成本消耗" %
                enemy.get("name","敵人"))
        completed.append({"serial":int(entry["serial"]),"kind":kind,
            "side":"enemy","enemy_index":index,"success":success})
        return 1
    return 0

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
        # #372 target priority can CHANGE during ACT (new Provoke,
        # enemy defeated, state removed). Check at EXECUTION, not only UI
        # selection, otherwise an outdated cursor hits the wrong enemy.
        var legal_target: bool = true
        if side == "enemy" and kind in ["attack","skill"]:
            var allowed: Dictionary = FSTargetPriority.player_enemy_candidates(
                battle,obj if kind == "skill" else 0)
            legal_target = bool(allowed.get("ok",false)) and (
                int(entry.get("target_index",-1)) in allowed.get("indices",[]))
        # Pop before executing to prevent duplicate completion/reentrancy.
        pending.erase(key)
        var success: bool = false
        if kind == "guard":
            actor["guarding"] = true
            success = true
            battle.changed.emit("%s 防禦姿態成立" % actor.get("name","角色"))
        elif legal_target and not target.is_empty() and int(target.get("hp",0)) > 0 and (
                not bool(target.get("fs_boss_phase_effects_pending",false))):
            if kind == "attack" and side == "enemy":
                if battle.attack_preflight(actor,target):
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
    if resolved == 0:
        return _resolve_enemy_ready(battle)
    return resolved
