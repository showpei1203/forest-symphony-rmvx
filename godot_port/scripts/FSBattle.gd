extends RefCounted
class_name FSBattle

# Candidate baseline only. For exact FS parity, trace RGSS2 last-wins aliases and tags.
signal changed(message: String)
signal finished(victory: bool)

var db: FSDatabase
var party: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var inventory: Dictionary = {}  # keys "item:<id>" / "weapon:<id>" / "armor:<id>"
var world: FSGameState
var active: bool = false
var pending_actor: int = -1
# Godot 60fps phase clock feeds original Tankentai 1.2c integer gauges.
# The timing/action queue as a whole is NOT yet source-final; source damage
# still needs effective 505 RGSS2 override witness.
var source_atb_initialized: bool = false
var source_atb_frame_fraction: float = 0.0
var source_atb_rolls_for_test: Dictionary = {}
var source_atb_advantage: String = ""
var source_atb_wait: bool = false
# ATB actor queue is active in BATTLE UI; final enemy AI/forced action/OD
# aliases are still outside the verified P1 source implementation.
var action_queue: FSActionQueue = FSActionQueue.new()

func _init(database: FSDatabase, shared_world: FSGameState = null) -> void:
    db = database
    world = shared_world
    if world != null:
        # One shared inventory is mandatory for event reward + MENU + BATTLE parity.
        inventory = world.inventory

func add_actor(actor_id: int) -> bool:
    var battler: Dictionary = db.apply_equipment(db.actor_stats(actor_id))
    if battler.is_empty():
        return false
    battler["hp"] = max(1, int(battler.get("maxhp", 1)))
    battler["mp"] = max(0, int(battler.get("maxmp", 0)))
    battler["od"] = 0
    battler["atb"] = 0.0
    battler["guarding"] = false
    party.append(battler)
    return true

func add_enemy(enemy_id: int) -> bool:
    var battler: Dictionary = db.enemy_stats(enemy_id)
    if battler.is_empty():
        return false
    battler["hp"] = max(1, int(battler.get("maxhp", 1)))
    battler["mp"] = max(0, int(battler.get("maxmp", 0)))
    battler["od"] = 0
    battler["atb"] = 0.0
    battler["guarding"] = false
    FSATBResistance.setup(battler)
    enemies.append(battler)
    return true

func start() -> bool:
    # Never revive a completed troop just because the UI was redrawn.
    var allies_alive: bool = party.any(func(x: Dictionary) -> bool: return int(x.get("hp",0)) > 0)
    var enemies_alive: bool = enemies.any(func(x: Dictionary) -> bool: return int(x.get("hp",0)) > 0)
    active = allies_alive and enemies_alive
    if active and not source_atb_initialized:
        FSTankentaiATBCore.prepare(party,enemies,db,
            source_atb_rolls_for_test,source_atb_advantage)
        source_atb_initialized = true
        source_atb_frame_fraction = 0.0
    changed.emit("進入戰鬥" if active else "未選擇存活隊伍／敵人")
    return active

func attack(attacker: Dictionary, target: Dictionary) -> int:
    # RPG Maker VX unmodified baseline: max(0, ATK*4 - DEF*2).
    # Element, variance, hit/evade, guard, critical, Cover and custom authority NOT PORTED.
    var raw_damage: int = maxi(0, int(attacker.get("atk", 0)) * 4 - int(target.get("def", 0)) * 2)
    var damage: int = raw_damage / 2 if bool(target.get("guarding", false)) else raw_damage
    target["hp"] = maxi(0, int(target.get("hp", 0)) - damage)
    changed.emit("%s 攻擊 %s：%d 傷害" % [attacker.get("name", "?"), target.get("name", "?"), damage])
    _check_end()
    return damage

func skill_preflight(user: Dictionary, target: Dictionary, skill_id: int) -> bool:
    # This is the same cost/effect/target verification invoked before ACT
    # starts AND immediately before skill payment at ACT completion.
    var skill := db.record("skills", skill_id)
    if skill.is_empty():
        changed.emit("找不到技能 ID %d" % skill_id)
        return false
    if bool(user.get("actor",false)) and not skill_id in user.get("skills",[]):
        changed.emit("角色未習得技能 ID %d" % skill_id)
        return false
    # This early migrated action supports ONLY one-target HP changes;
    # state/element/absorb/MP-damage/notes and multi-target effects must await
    # the effective 505-script RGSS2 override trace. No silent consumption.
    if int(skill.get("scope",0)) not in [1,7] or not skill.get("plus_state_set",[]).is_empty() or not skill.get("minus_state_set",[]).is_empty() or bool(skill.get("damage_to_mp",false)) or bool(skill.get("absorb_damage",false)):
        changed.emit("技能效果包含尚未移植的原版特殊規則，已阻擋且不消耗 MP")
        return false
    if int(skill.get("base_damage",0)) < 0 and (int(skill.get("atk_f",0)) != 0 or int(skill.get("spi_f",0)) != 0):
        changed.emit("治療技能的屬性加成尚未移植，已阻擋且不消耗 MP")
        return false
    # Source VX scope1 targets OPPONENTS and scope7 targets FRIENDS,
    # relative to the user. Enemy AI's party targets are the opposite of
    # actors' enemy targets, so absolute actor flags were incorrect.
    var same_side: bool = bool(user.get("actor",false)) == bool(
        target.get("actor",false))
    if int(skill.get("scope",0)) == 1 and same_side:
        changed.emit("單體敵方技能必須選擇施術者的敵對陣營")
        return false
    if int(skill.get("scope",0)) == 7 and not same_side:
        changed.emit("單體友方技能必須選擇施術者的同陣營")
        return false
    # Keep quote and payment synchronized: reading raw skill.mp_cost here
    # would bypass FS_SkillCost_Authority #411 fixed/percent tags.
    var quoted: Dictionary = FSSkillCostRules.preview(skill,user)
    if not bool(quoted.get("ok",false)):
        changed.emit("技能成本無法驗證，未扣 MP：" + str(quoted.get("reason","")))
        return false
    var mp_cost: int = int(quoted["mp"])
    if int(user.get("mp", 0)) < mp_cost:
        changed.emit("MP 不足")
        return false
    return true

func use_skill(user: Dictionary, target: Dictionary, skill_id: int) -> bool:
    if not skill_preflight(user,target,skill_id):
        return false
    var skill: Dictionary = db.record("skills",skill_id)
    # Exact quote has already been validated by skill_preflight.
    var mp_cost: int = int(FSSkillCostRules.preview(skill,user)["mp"])
    user["mp"] = int(user["mp"]) - mp_cost
    var val: int = int(skill.get("base_damage", 0))
    if val > 0:
        val += int(user.get("atk", 0)) * 4 * int(skill.get("atk_f", 0)) / 100
        val += int(user.get("spi", 0)) * 2 * int(skill.get("spi_f", 0)) / 100
        if not bool(skill.get("ignore_defense", false)):
            val -= int(target.get("def", 0)) * 2 * int(skill.get("atk_f", 0)) / 100
            val -= int(target.get("spi", 0)) * int(skill.get("spi_f", 0)) / 100
        val = maxi(0, val)
    target["hp"] = clampi(int(target.get("hp", 0)) - val, 0, maxi(1, int(target.get("maxhp", 1))))
    changed.emit("%s 使用 %s：HP 變化 %d" % [user.get("name", "?"), skill.get("name", "?"), -val])
    _check_end()
    return true

func use_item(target: Dictionary, item_id: int, user: Dictionary = {},
        in_battle: bool = true) -> bool:
    # Implement ONLY the verified stock VX simple recovery subset.
    # Final FS MasterSetup/runtime/skill-cost aliases still need real VX traces.
    # Unsupported tag/state/common-event/parameter/item never consumes inventory.
    var key: String = "item:%d" % item_id
    if int(inventory.get(key,0)) < 1:
        changed.emit("背包中沒有物品 #%d" % item_id)
        return false
    var item: Dictionary = db.record("items",item_id)
    if item.is_empty():
        changed.emit("原始物品資料不存在 #%d" % item_id)
        return false
    var effect: Dictionary = FSItemRules.preview(item,user,target,in_battle)
    if not bool(effect.get("ok",false)):
        changed.emit("已阻擋未驗證物品效果：" + str(effect.get("reason","")))
        return false
    # Source shared inventory is committed only once effect was validated.
    target["hp"] = int(effect["new_hp"])
    target["mp"] = int(effect["new_mp"])
    if bool(item.get("consumable",true)):
        inventory[key] = int(inventory.get(key,0)) - 1
    changed.emit("%s 使用 %s：HP %+d / MP %+d" % [
        user.get("name","角色"),item.get("name","物品"),
        int(effect["hp_gain"]),int(effect["mp_gain"])])
    return true

func equip(actor_index: int, slot: int, item_id: int) -> bool:
    # Source: Game_Actor.change_equip and equippable? (base authority).
    # Class weapon_set/armor_set, item.kind, dual-wield, and two_handed are
    # enforced; later FS custom slot overrides remain a separate parity gate.
    if actor_index < 0 or actor_index >= party.size():
        return false
    var actor: Dictionary = party[actor_index]
    if not db.can_equip(actor,slot,item_id):
        changed.emit("職業／裝備欄位限制，或角色裝備固定")
        return false
    var kind: String = db.equip_kind(actor,slot)
    var item: Dictionary = db.record(kind,item_id)
    var slots: Array = actor.get("equipment",[]).duplicate()
    if slots.size() != 5:
        return false
    var old_id: int = int(slots[slot])
    if item_id == old_id:
        return true

    var new_key: String = ("weapon:" if kind == "weapons" else "armor:") + str(item_id)
    if item_id > 0 and int(inventory.get(new_key,0)) < 1:
        changed.emit("背包中沒有指定裝備")
        return false
    # Compute a full atomic swap before changing ANY inventory or actor stat.
    var next_slots: Array = slots.duplicate()
    next_slots[slot] = item_id
    # Source Game_Actor.two_hands_legal?: if first hand is two-handed,
    # the second must be empty; if second weapon is two-handed, first empty.
    var main: Dictionary = db.record("weapons",int(next_slots[0]))
    var second: Dictionary = db.record(
        "weapons" if bool(actor.get("two_swords_style",false)) else "armors",
        int(next_slots[1]))
    if int(next_slots[0]) > 0 and bool(main.get("two_handed",false)) and int(next_slots[1]) > 0:
        next_slots[1 if slot == 0 else 0] = 0
    elif bool(actor.get("two_swords_style",false)) and int(next_slots[1]) > 0 and bool(second.get("two_handed",false)) and int(next_slots[0]) > 0:
        next_slots[0 if slot == 1 else 1] = 0

    var changes: Dictionary = {}
    for i in range(5):
        if int(slots[i]) == int(next_slots[i]):
            continue
        var slot_kind: String = db.equip_kind(actor,i)
        var key_old: String = ("weapon:" if slot_kind == "weapons" else "armor:") + str(slots[i])
        var key_new: String = ("weapon:" if slot_kind == "weapons" else "armor:") + str(next_slots[i])
        if int(slots[i]) > 0:
            changes[key_old] = int(changes.get(key_old,0)) + 1
        if int(next_slots[i]) > 0:
            changes[key_new] = int(changes.get(key_new,0)) - 1
    for key in changes:
        if int(inventory.get(key,0)) + int(changes[key]) < 0:
            changed.emit("裝備交換後背包數量不足：" + str(key))
            return false
    # All checks passed: perform the transaction in one step.
    for key in changes:
        inventory[key] = int(inventory.get(key,0)) + int(changes[key])
    actor["equipment"] = next_slots
    var restored: Dictionary = db.actor_stats(int(actor["id"]),int(actor["level"]))
    restored["equipment"] = next_slots.duplicate()
    restored = db.apply_equipment(restored)
    for stat in ["maxhp","maxmp","atk","def","spi","agi","hit","eva","cri"]:
        actor[stat] = restored[stat]
    actor["hp"] = mini(int(actor["hp"]),int(actor["maxhp"]))
    actor["mp"] = mini(int(actor["mp"]),int(actor["maxmp"]))
    changed.emit("%s 裝備欄位 %d 已更新" % [actor.get("name","?"),slot])
    return true

func advance_atb(delta: float) -> void:
    if not active or not source_atb_initialized or delta <= 0.0:
        return
    # Real Tankentai #231 gauge increments are PER SOURCE FRAME, not an
    # invented continuous float rate. Accumulate fractional 60fps frames.
    source_atb_frame_fraction += delta * float(FSTankentaiATBCore.FRAMES_PER_SECOND)
    var steps: int = int(floor(source_atb_frame_fraction+0.000001))
    if steps <= 0:
        return
    source_atb_frame_fraction -= float(steps)
    # Source #231 update_atb scans Party+Troop in their source order
    # EACH frame; processing a multi-frame delta in one lump lets enemies
    # skip their turn or delay the final attack until the next render frame.
    for frame in range(steps):
        FSTankentaiATBCore.advance_frames(party,enemies,1,source_atb_wait)
        if source_atb_wait or not active:
            continue
        action_queue.cancel_interrupted(self)
        action_queue.resolve_ready(self)
        if active:
            # Enemy actions are chosen after ATB readiness, then must earn
            # ACT charge in subsequent source frames, not in selection frame.
            action_queue.schedule_enemy(self)

func queue_actor_action(index: int,kind: String,target_index: int = -1,
        object_id: int = 0) -> bool:
    return action_queue.request(self,index,kind,target_index,object_id)

func has_actor_pending_action(index: int) -> bool:
    return action_queue.has_pending(index)

func begin_source_atb_charge(battler: Dictionary,kind: String = "attack",
        object_id: int = 0) -> bool:
    if not active or not source_atb_initialized:
        return false
    if not party.has(battler) and not enemies.has(battler):
        return false
    return FSTankentaiATBCore.begin_charge(battler,kind,object_id)

func source_action_charged(battler: Dictionary) -> bool:
    return source_atb_initialized and bool(battler.get("source_act_active",false))

func finish_source_atb_action(battler: Dictionary,kind: String = "attack",
        object_id: int = 0) -> bool:
    # Charge completion is distinct from battle result calculation.
    if not source_action_charged(battler):
        return false
    FSTankentaiATBCore.reset_after_action(battler,kind,object_id,db)
    if enemies.has(battler):
        enemy_valid_action_completed(battler)
    return true

func apply_combo_atb_shift(enemy: Dictionary,delta: int,
        attacker: Dictionary = {},state_id: int = 0) -> Dictionary:
    # This adapter is ONLY the direct ComboCore ATB shift <atb_shift:-x>.
    # Ordinary ATB accumulation (above) is still a placeholder.
    if not enemies.has(enemy):
        return {"ok":false,"reason":"目標不是戰鬥中的敵人"}
    var outcome: Dictionary = FSATBResistance.apply_direct_shift(
        enemy,delta,state_id,attacker)
    if bool(outcome.get("ok",false)):
        # Cancel enemy ACT pending immediately after ComboCore negative shift,
        # rather than leaving it alive until a later rendered frame.
        action_queue.cancel_interrupted(self)
        changed.emit("%s ATB %d→%d／抗性 Lv%d" % [
            enemy.get("name","敵人"),outcome.get("before",0),
            outcome.get("after",0),outcome.get("level_after",0)])
    return outcome

func apply_combo_atb_shift_to_actor(actor: Dictionary,delta: int,
        attacker: Dictionary = {},state_id: int = 0) -> Dictionary:
    # ComboCore #374 applies negative ATB shifts to ALL battlers, whereas
    # Boss-only resistance #377 is only enabled for tagged enemies.
    if not party.has(actor):
        return {"ok":false,"reason":"目標不是戰鬥中的我方角色"}
    var outcome: Dictionary = FSATBResistance.apply_direct_shift(
        actor,delta,state_id,attacker)
    if bool(outcome.get("ok",false)):
        action_queue.cancel_interrupted(self)
        changed.emit("%s ATB 受到直接位移 %d→%d" % [
            actor.get("name","我方"),outcome.get("before",0),
            outcome.get("after",0)])
    return outcome

func enemy_valid_action_completed(enemy: Dictionary) -> int:
    # Called after a VERIFIED valid enemy action, not from UI redraw or ATB tick.
    if not enemies.has(enemy):
        return 0
    return FSATBResistance.after_valid_enemy_action(enemy)

func ready_actors() -> Array[int]:
    if source_atb_initialized:
        return FSTankentaiATBCore.ready_actors(party)
    var out: Array[int] = []
    for i in range(party.size()):
        if int(party[i]["hp"]) > 0 and float(party[i].get("atb", 0.0)) >= 1.0:
            out.append(i)
    return out

func ready_enemies() -> Array[int]:
    if source_atb_initialized:
        return FSTankentaiATBCore.ready_enemies(enemies)
    var out: Array[int] = []
    for i in range(enemies.size()):
        if int(enemies[i]["hp"]) > 0 and float(enemies[i].get("atb", 0.0)) >= 1.0:
            out.append(i)
    return out

func _check_end() -> void:
    if not active:
        return
    var allies_alive: bool = party.any(func(x: Dictionary) -> bool: return int(x.get("hp", 0)) > 0)
    var enemies_alive: bool = enemies.any(func(x: Dictionary) -> bool: return int(x.get("hp", 0)) > 0)
    if not allies_alive or not enemies_alive:
        active = false
        finished.emit(enemies_alive == false)
