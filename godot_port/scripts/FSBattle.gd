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
# Source #401 Runtime Provider. Automatically opt-in only after the real
# boot-final DB witness gate; synthetic battle tests opt in intentionally.
var boss_runtime: FSBossSummonRuntime = FSBossSummonRuntime.new()
# #404 single global field, distinct from Boss Phase State intents. Enabled
# only with source boot-final witness; native tests must opt in themselves.
var field_weather: FSFieldWeather = FSFieldWeather.new()
# Strict Boss State subset: sourced stat rates and ComboCore mana shield.
# Synthetic unit tests must enable this explicitly; never treat an
# unverified Boss intent as an applied state.
var boss_state_effects: FSBossCombatStates = FSBossCombatStates.new()
# Source BattleFormula TargetFix / support rule HIT-EVA engine. The final
# weapon/passive/505-alias witness is separate from this safe subset.
var accuracy: FSBattleAccuracy = FSBattleAccuracy.new()
# FS final attack smoothing is a verified-source restricted subset.
# REMAINS OFF for normal gameplay until the 505-alias + runtime witness
# has been audited. Native synthetic integration fixtures may opt in.
var normal_core: FSNormalAttackCore = FSNormalAttackCore.new()
# Source-positive SKILL power: YEM CustomDmg RD -> smooth DEF ratio after
# source variance/guard. Off until original post-Apply + alias witness.
var skill_core: FSSkillSmoothCore = FSSkillSmoothCore.new()
# Source #52-24: final Phase28 element/type authority (18 Pokémon types,
# original Rank/State/Armor KGC, multielement multiplication). This remains
# disabled in normal gameplay until post-Apply effective 11 tables and all
# equipment/passive Note witnesses are verified. Synthetic QA opts in.
var element_rates: FSElementFinalAuthority = FSElementFinalAuthority.new()

func _init(database: FSDatabase, shared_world: FSGameState = null) -> void:
    db = database
    world = shared_world
    boss_runtime.active = db.boot_final_verified
    field_weather.active = db.boot_final_verified
    boss_state_effects.active = db.boot_final_verified
    accuracy.active = db.boot_final_verified
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
    # Source Game_Battler#initialize starts with @states=[] for both
    # Actor and Enemy. Missing source arrays must not be misclassified
    # as an unknown gameplay state by Phase28 FinalAuthority.
    if not (battler.get("states",null) is Array):
        battler["states"] = []
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
    if not (battler.get("states",null) is Array):
        battler["states"] = []
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
        if boss_runtime.active:
            # Source AntagonistCore Scene_Battle.start initial law hook.
            boss_runtime.phase_runtime.start_laws(self)
    changed.emit("進入戰鬥" if active else "未選擇存活隊伍／敵人")
    return active

func attack_preflight(attacker: Dictionary,target: Dictionary) -> bool:
    # Source stock attack_effect skips dead targets. Protect direct API
    # calls as well as queued ACT, without changing legacy test-only paths.
    if accuracy.active and (int(attacker.get("hp",0)) <= 0 or
            int(target.get("hp",0)) <= 0):
        changed.emit("已死亡的施術者／目標不允許命中判定或消耗亂數")
        return false
    if bool(target.get("fs_boss_phase_effects_pending",false)) or (
            bool(attacker.get("fs_boss_phase_effects_pending",false))):
        changed.emit("Boss 狀態實際效果未驗證，攻擊已阻擋")
        return false
    # The quote must be pure: ATB command selection must not consume a
    # HIT or EVA RNG roll before the actual source ACT resolves.
    if accuracy.active:
        var chance: Dictionary = accuracy.quote(self,attacker,target)
        if not bool(chance.get("ok",false)):
            changed.emit("攻擊命中來源未核對：" + str(chance.get("reason","")))
            return false
    # Exact source core MUST pass equipment, rate, neutral-element,
    # and unknown-alias guards before ACT or RNG.
    if normal_core.active:
        var power_quote: Dictionary = normal_core.quote(self,attacker,target)
        if not bool(power_quote.get("ok",false)):
            changed.emit("原版普攻核心來源未驗證：" + str(
                power_quote.get("reason","")))
            return false
    # #404 requires effective attacker.element_set for positive attacks.
    # With global weather active, do not pretend an unverified source has
    # zero element types. The unweathered basic attack remains a candidate.
    if not field_weather.active or field_weather.current_id <= 0:
        return true
    if attacker.has("fs_attack_elements_verified") and not bool(
            attacker.get("fs_attack_elements_verified",false)):
        changed.emit("武器元素資料尚未核對，不允許在天氣下攻擊")
        return false
    var sample: Dictionary = field_weather.preview_damage(
        db,target,attacker.get("element_set",null),1,0)
    if not bool(sample.get("ok",false)):
        changed.emit("天氣攻擊已阻擋：" + str(sample.get("reason","")))
        return false
    return true

func attack(attacker: Dictionary, target: Dictionary) -> int:
    # Damage power still uses the early port's stock formula: the final
    # FS_BATTLE_BALANCE smooth core, affinity and 505 alias chain are NOT
    # certified. HIT/EVA/CRIT/variance use the explicitly gated source subset.
    if accuracy.active:
        # Prevent stale critical/miss flags from a previous ACT.
        target.erase("fs_last_action_result")
        target.erase("fs_last_action_critical")
    if not attack_preflight(attacker,target):
        return 0
    var landed: Dictionary = accuracy.resolve(self,attacker,target)
    if not bool(landed.get("ok",false)):
        changed.emit("攻擊命中判定拒絕：" + str(landed.get("reason","")))
        return 0
    if str(landed.get("kind","hit")) != "hit":
        target["fs_last_action_result"] = str(landed["kind"])
        changed.emit("%s 攻擊 %s：%s" % [
            attacker.get("name","?"),target.get("name","?"),
            "落空" if landed["kind"]=="miss" else "被迴避"])
        return 0
    var damage: int = 0
    if normal_core.active:
        # Source Yanfly legacy power -> source critical/variance/guard ->
        # FS_BATTLE_BALANCE smooth-defense ratio, then Field404 -> Shield77.
        var power: Dictionary = normal_core.resolve(self,attacker,target,int(
            landed.get("crit_chance",0)))
        if not bool(power.get("ok",false)):
            changed.emit("原版普攻核心拒絕結算：" + str(power.get("reason","")))
            return 0
        damage = int(power["hp"])
        target["fs_last_action_critical"] = bool(power["critical"])
    else:
        # Legacy migration candidate retained for all previously verified
        # tests. Never confuse this with the final FS original damage core.
        var raw_damage: int = maxi(0, boss_state_effects.stat(attacker,"atk") * 4 -
            boss_state_effects.stat(target,"def") * 2)
        if accuracy.active and raw_damage > 0:
            var critical_result: Dictionary = accuracy.critical(int(
                landed.get("crit_chance",0)))
            if not bool(critical_result.get("ok",false)):
                changed.emit("暴擊來源未確認：" + str(
                    critical_result.get("reason","")))
                return 0
            if bool(critical_result.get("critical",false)):
                raw_damage = int(float(raw_damage)*1.7)
                target["fs_last_action_critical"] = true
            else:
                target["fs_last_action_critical"] = false
            # Original YE::BATTLE::NATK::VARYDMG = 5, not VX default20.
            var varied: Dictionary = accuracy.variance(raw_damage,5)
            if not bool(varied.get("ok",false)):
                changed.emit("普攻傷害浮動未確認：" + str(
                    varied.get("reason","")))
                return 0
            raw_damage = int(varied["damage"])
        damage = raw_damage / (4 if bool(target.get("super_guard",false)) else 2) if (
            bool(target.get("guarding",false))) else raw_damage
    if field_weather.active and field_weather.current_id > 0:
        # #404 source hook runs AFTER baseline damage is calculated.
        var field: Dictionary = field_weather.preview_damage(
            db,target,attacker.get("element_set",null),damage,0)
        if not bool(field.get("ok",false)):
            changed.emit("天氣傷害欄位無法核對，未造成傷害")
            return 0
        damage = int(field["hp"])
    var hit: Dictionary = boss_state_effects.preview_hit(target,damage)
    if not bool(hit.get("ok",false)):
        changed.emit("原版 Boss 護盾效果未驗證，攻擊未結算")
        return 0
    boss_state_effects.commit_hit(target,hit)
    if accuracy.active:
        target["fs_last_action_result"] = "hit"
    changed.emit("%s 攻擊 %s：HP %d／護盾吸收 MP %d" % [
        attacker.get("name","?"),target.get("name","?"),
        int(hit["hp"]),int(hit["mp"])])
    _check_end()
    return int(hit["hp"])

func skill_preflight(user: Dictionary, target: Dictionary, skill_id: int) -> bool:
    # Current migrated scope1/7 covers only living targets; VX revival
    # scopes are not implemented. Never consume HIT/EVA RNG on dead units.
    if accuracy.active and (int(user.get("hp",0)) <= 0 or
            int(target.get("hp",0)) <= 0):
        changed.emit("未驗證的死亡目標／施術者，技能不允許扣 MP")
        return false
    if bool(target.get("fs_boss_phase_effects_pending",false)) or (
            bool(user.get("fs_boss_phase_effects_pending",false))):
        changed.emit("Boss 的未驗證狀態效果不允許技能扣 MP 或結算")
        return false
    # This is the same cost/effect/target verification invoked before ACT
    # starts AND immediately before skill payment at ACT completion.
    var skill := db.record("skills", skill_id)
    if skill.is_empty():
        changed.emit("找不到技能 ID %d" % skill_id)
        return false
    if bool(user.get("actor",false)) and not skill_id in user.get("skills",[]):
        changed.emit("角色未習得技能 ID %d" % skill_id)
        return false
    # Original #271050 FS_SUPPORT_STATE_RULES has a second, Note-defined
    # state-chance roll. This subset has NOT ported that effect/authority.
    # A harmless-looking zero-base-damage skill must not silently consume MP.
    var source_note: String = str(skill.get("note","")).to_lower()
    if source_note.contains("<state_chance") or (
            source_note.contains("<ai_state>")) or (
            source_note.contains("<狀態技能>")) or (
            source_note.contains("<状态技能>")):
        changed.emit("狀態技能含原始 Note 命中／附加機制，未驗證且未扣 MP")
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
    # #404 weather source-object tags are cost-neutral, but they MUST
    # also pass global-field authorization before an ACT command begins.
    var field_action: Dictionary = field_weather.preflight_source_object(
        db,user,skill,enemies)
    if not bool(field_action.get("ok",false)):
        changed.emit("技能天氣尚未驗證，未扣 MP：" + str(field_action.get("reason","")))
        return false
    if accuracy.active:
        var chance: Dictionary = accuracy.quote(self,user,target,skill)
        if not bool(chance.get("ok",false)):
            changed.emit("技能命中來源未確認，未扣 MP：" + str(chance.get("reason","")))
            return false
    if skill_core.active:
        var power_quote: Dictionary = skill_core.quote(self,user,target,skill)
        if not bool(power_quote.get("ok",false)):
            changed.emit("FS 技能傷害來源未確認，未扣 MP：" + str(
                power_quote.get("reason","")))
            return false
    if field_weather.active and field_weather.current_id > 0 and int(
            skill.get("base_damage",0)) > 0:
        var sample: Dictionary = field_weather.preview_damage(
            db,target,skill.get("element_set",null),1,0,
            bool(skill.get("rate_damage",false)))
        if not bool(sample.get("ok",false)):
            changed.emit("技能元素／天氣未驗證：" + str(sample.get("reason","")))
            return false
    return true

func use_skill(user: Dictionary, target: Dictionary, skill_id: int) -> bool:
    if not skill_preflight(user,target,skill_id):
        return false
    var skill: Dictionary = db.record("skills",skill_id)
    # Exact quote has already been validated by skill_preflight.
    var mp_cost: int = int(FSSkillCostRules.preview(skill,user)["mp"])
    var val: int = int(skill.get("base_damage", 0))
    if not skill_core.active and val > 0:
        # Candidate stock-VX route is intentionally unchanged until
        # original full 505-script proof exists for all skills.
        val += boss_state_effects.stat(user,"atk") * 4 * int(skill.get("atk_f", 0)) / 100
        val += boss_state_effects.stat(user,"spi") * 2 * int(skill.get("spi_f", 0)) / 100
        if not bool(skill.get("ignore_defense", false)):
            val -= boss_state_effects.stat(target,"def") * 2 * int(skill.get("atk_f", 0)) / 100
            val -= boss_state_effects.stat(target,"spi") * int(skill.get("spi_f", 0)) / 100
        val = maxi(0, val)
    # Source #404 resolves the existing hit BEFORE a new weather skill can
    # set the next field. Verify the requested Field before paying.
    var planned: Dictionary = field_weather.preflight_source_object(
        db,user,skill,enemies)
    if not bool(planned.get("ok",false)):
        return false
    # Targeting/HIT/EVA is rolled exactly once at ACT resolution.
    # Source Scene_Battle pays MP for a valid issued skill even on miss.
    if accuracy.active:
        target.erase("fs_last_action_result")
        target.erase("fs_last_action_critical")
    var landed: Dictionary = accuracy.resolve(self,user,target,skill)
    if not bool(landed.get("ok",false)):
        changed.emit("技能命中資料尚未驗證，無成本消耗")
        return false
    if str(landed.get("kind","hit")) != "hit":
        user["mp"] = int(user["mp"])-mp_cost
        target["fs_last_action_result"] = str(landed["kind"])
        target["fs_last_action_critical"] = false
        # Source #404 skill_effect wrapper can change field after the
        # original effect returns, including an ordinary miss.
        if str(planned.get("kind","none")) != "none":
            field_weather.apply_source_object(db,user,skill,enemies)
        changed.emit("%s 使用 %s：%s／支付 MP %d" % [
            user.get("name","?"),skill.get("name","?"),
            "落空" if landed["kind"]=="miss" else "被迴避",mp_cost])
        return true
    if skill_core.active:
        # Original RD skill: positive source damage -> optional 200% CRIT
        # -> YEM variance -> Guard -> truncated smooth defense ratio.
        # Global Field404 and ComboCore Shield77 are downstream.
        var source_skill: Dictionary = skill_core.resolve(self,user,target,
            skill,int(landed.get("crit_chance",0)))
        if not bool(source_skill.get("ok",false)):
            changed.emit("原版技能核心拒絕執行，無成本消耗：" + str(
                source_skill.get("reason","")))
            return false
        val = int(source_skill["hp"])
        target["fs_last_action_critical"] = bool(source_skill["critical"])
    elif accuracy.active and val > 0:
        var crit: Dictionary = accuracy.critical(int(
            landed.get("crit_chance",0)))
        if not bool(crit.get("ok",false)):
            changed.emit("技能暴擊來源未確認，無成本消耗")
            return false
        if bool(crit.get("critical",false)):
            val = int(float(val)*1.7)
            target["fs_last_action_critical"] = true
        else:
            target["fs_last_action_critical"] = false
        var varied: Dictionary = accuracy.variance(
            val,int(skill.get("variance",0)))
        if not bool(varied.get("ok",false)):
            changed.emit("技能浮動來源未確認，無成本消耗")
            return false
        val = int(varied["damage"])
        if bool(target.get("guarding",false)):
            val = int(val / (4 if bool(target.get("super_guard",false)) else 2))
    if field_weather.active and field_weather.current_id > 0 and val > 0:
        # Actual source #404 is invoked after skill damage generation.
        # Applying weather before CRIT/variance alters rounding and parity.
        var field: Dictionary = field_weather.preview_damage(
            db,target,skill.get("element_set",null),val,0,
            bool(skill.get("rate_damage",false)))
        if not bool(field.get("ok",false)):
            changed.emit("天氣傷害無法核對，未扣 MP")
            return false
        val = int(field["hp"])
    # Preflight the confirmed ComboCore shield before any MP is spent.
    # Damage is modified by the OLD validated global field subset.
    var hit: Dictionary = boss_state_effects.preview_hit(target,val)
    if not bool(hit.get("ok",false)):
        changed.emit("Boss 狀態效果缺少來源證據，未消耗 MP")
        return false
    user["mp"] = int(user["mp"]) - mp_cost
    boss_state_effects.commit_hit(target,hit)
    if accuracy.active:
        target["fs_last_action_result"] = "hit"
    target["hp"] = mini(int(target["hp"]),maxi(1,int(target.get("maxhp",1))))
    if str(planned.get("kind","none")) != "none":
        var applied: Dictionary = field_weather.apply_source_object(
            db,user,skill,enemies)
        if not bool(applied.get("ok",false)):
            changed.emit("技能已結算，但天氣變更被原版場域優先權拒絕")
    changed.emit("%s 使用 %s：HP 變化 %d／護盾 MP 吸收 %d" % [
        user.get("name","?"),skill.get("name","?"),
        -int(hit["hp"]),int(hit["mp"])])
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
    for stat in ["maxhp","maxmp","atk","def","spi","agi","hit","eva","cri",
            "element_set","fs_attack_elements_verified"]:
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
        field_weather.update_source(db)
        FSTankentaiATBCore.advance_frames(party,enemies,1,source_atb_wait)
        # Tankentai calls remove_states_auto ON new ATB readiness, before
        # action selection. Timed Boss 128/129 use that exact edge, not ACT
        # completion and not the global FPS clock.
        boss_state_effects.on_atb_ready(self)
        if not active:
            break
        if not source_atb_wait:
            action_queue.cancel_interrupted(self)
            action_queue.resolve_ready(self)
            if active:
                # Enemy actions are chosen after ATB readiness, then must
                # earn ACT charge on later source frames.
                action_queue.schedule_enemy(self)
        # Original #401 Scene_Battle#update boss hook runs AFTER base update
        # even when #230 ATB_WAIT freezes gauges during target selection.
        # This is an encounter state update, NOT an ATB charge action.
        if active:
            boss_runtime.tick(self)
            boss_state_effects.sync(self)

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
    var resistance_level: int = FSATBResistance.after_valid_enemy_action(enemy)
    # Original AntagonistCore counts COMPLETED valid enemy actions, not
    # source 60Hz frames or AI choices. It never adds unverified States.
    if boss_runtime.active:
        boss_runtime.phase_runtime.after_valid_enemy_action(self,enemy)
    return resistance_level

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
