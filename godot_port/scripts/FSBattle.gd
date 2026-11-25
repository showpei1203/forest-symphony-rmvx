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
# Opt-in candidate; normal production/event entry remains disabled.
var force_actions: FSForceActionQueue = FSForceActionQueue.new()
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
# Derived from real Class/Enemy ranks, source Actor/Class/Enemy types,
# KGC equipped items, and STATE/passive Notes. Not a handwritten ACT flag.
var element_provider: FSElementSourceProvider = FSElementSourceProvider.new()
# Original main Ivy Actor#5 single-target Cover; requires source guard,
# MaxOD and independent damage re-roll. Disabled in production by default.
var ivy_cover: FSIvyCover = FSIvyCover.new()
# Separate source-only Ivy actual-HP-loss stored pain adapter.
# Original MechanicExpansion v1.1 #382, Phase46A/B2; disabled by default.
var ivy_pain: FSIvyPain = FSIvyPain.new()
# Original 147 action-start stored-pain snapshot, post-effect consume gate.
# Source 220475/222005; disabled until full private source testimony.
var ivy_revenge: FSIvyRevenge = FSIvyRevenge.new()
# Final source CharacterCore actor notes: private Profile.tag_text +
# all equipped items + live State Notes, never handwritten Actor.note.
var ivy_pain_source: FSIvyPainSourceProvider = FSIvyPainSourceProvider.new()
# ComboCore OD mitigation: learned passive142 + verified Equip/State Notes.
# Original main Cover grants +6% before recalculating guard defense.
var ivy_od_defense: FSIvyODDefense = FSIvyODDefense.new()
# Original Game_Battler/Tankentai Ivy145 State85+100 subset.
# Synthetic source-shape only until real post-Apply 11 tables, Skill145
# JP/charge/cooldown and shared State100 Aizhuo ownership are verified.
var ivy_furnace: FSIvyFurnaceRuntime = FSIvyFurnaceRuntime.new()

func enable_private_ivy_pain_notes(folder:String="res://data")->bool:
    ivy_pain.active=false
    ivy_revenge.active=false
    for actor in party:
        actor.erase("fs_ivy_effective_notes")
        actor.erase("fs_ivy_pain_notes_verified")
        actor.erase("fs_ivy_furnace_state_verified")
        actor.erase("fs_ivy_effective_notes_have_passives")
    var result:Dictionary=ivy_pain_source.configure_private(db,folder)
    if not bool(result.get("ok",false)):
        changed.emit("原版 Ivy Profile 有效 Note 尚未驗證："+str(
            result.get("reason","")))
        return false
    var staged:Array=[]
    for actor in party:
        var built:Dictionary=ivy_pain_source.build(db,actor)
        if not bool(built.get("ok",false)):
            ivy_pain_source.active=false
            changed.emit("Ivy Profile/裝備/State Source 交易被拒絕："+str(
                built.get("reason","")))
            return false
        staged.append({"actor":actor,"quote":built})
    for item in staged:
        var quote_data:Dictionary=item["quote"]
        if bool(quote_data.get("applicable",false)):
            var actor:Dictionary=item["actor"]
            actor["fs_ivy_effective_notes"]=quote_data["notes"].duplicate(true)
            actor["fs_ivy_effective_notes_have_passives"]=bool(quote_data.get(
                "passives_included",false))
            actor["fs_ivy_pain_notes_verified"]=true
            actor["fs_ivy_furnace_state_verified"]=bool(quote_data[
                "furnace_verified"])
    # Source installation DOES NOT automatically enable the unported
    # original Skill145, Skill147, OD/JP, or all 505 aliases.
    return true

func enable_private_ivy_od_defense() -> bool:
    # Source-only explicit opt-in. A synthetic boolean or ordinary
    # handwritten Note is NOT authority to enable passive142 gameplay.
    ivy_od_defense.active=false
    for member in party:
        member.erase("fs_ivy_od_source_verified")
    if not db.boot_final_verified or not ivy_pain_source.active or (
            ivy_pain_source.fixture_only):
        changed.emit("Ivy142 真實 OD 減傷缺少 post-Apply11表與私有來源見證")
        return false
    # Refresh every live Ivy State/Equip/Actor Profile before staging.
    # Do not leave a half-enabled OD engine on a bad passive Note.
    var eligible:Array[Dictionary]=[]
    for member in party:
        if int(member.get("id",0))!=5 or not bool(
                member.get("actor",false)):
            continue
        if not _refresh_ivy_pain_source(member):
            return false
        eligible.append(member)
    if eligible.is_empty():
        changed.emit("Ivy142 沒有來源已驗證的 Actor5")
        return false
    ivy_od_defense.active=true
    for member in eligible:
        member["fs_ivy_od_source_verified"]=true
        var quote_data:Dictionary=ivy_od_defense.quote(self,member,1)
        if not bool(quote_data.get("ok",false)):
            for another in eligible:
                another.erase("fs_ivy_od_source_verified")
            ivy_od_defense.active=false
            changed.emit("Ivy142 私有來源防禦未啟用："+str(
                quote_data.get("reason","")))
            return false
    return true

func _refresh_ivy_pain_source(battler:Dictionary)->bool:
    if not ivy_pain_source.active:
        return true
    var result:Dictionary=ivy_pain_source.refresh(db,battler)
    if not bool(result.get("ok",false)):
        changed.emit("原版艾薇 Profile/裝備/State Notes 更新失敗："+str(
            result.get("reason","")))
        return false
    return true


func enable_private_element_provider(folder: String = "res://data") -> bool:
    # Any reconfiguration invalidates the previous source witness; stale
    # Actor/Enemy element snapshots must not survive a failed new SHA.
    element_rates.active = false
    for unit in party+enemies:
        unit.erase("fs_element_authority")
    # Do NOT enable either legacy or source smooth damage engines just
    # because the provider snapshot has a valid SHA. This only enables
    # the final element authority after all private witnesses pass.
    var result: Dictionary = element_provider.configure_private(db,folder)
    if not bool(result.get("ok",false)):
        changed.emit("來源屬性資料無法驗證：" + str(result.get("reason","")))
        return false
    var pending: Array[Dictionary] = []
    for unit in party+enemies:
        var built: Dictionary = element_provider.build(db,unit)
        if not bool(built.get("ok",false)):
            changed.emit("來源屬性初始化阻擋：" + str(built.get("reason","")))
            element_provider.active = false
            return false
        pending.append({"unit":unit,"data":built})
    for item in pending:
        var authority: Dictionary = item["data"].duplicate(true)
        authority.erase("ok")
        item["unit"]["fs_element_authority"] = authority
    element_rates.active=true
    return true

func _refresh_element_source(battler: Dictionary) -> bool:
    if not element_provider.active:
        return true
    var updated: Dictionary = element_provider.refresh(db,battler)
    if not bool(updated.get("ok",false)):
        changed.emit("屬性來源更新失敗：" + str(updated.get("reason","")))
        return false
    return true


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
    if not _refresh_element_source(battler):
        return false
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
    if not _refresh_element_source(battler):
        return false
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
        if ivy_pain.active or ivy_revenge.active:
            # Original FS MechanicExpansion Scene_Battle.start clears
            # stored Cover damage once, independent of an Ivy guard action.
            ivy_pain.reset_battle(self)
        if ivy_cover.active:
            ivy_cover.start_battle(self)
        if boss_runtime.active:
            # Source AntagonistCore Scene_Battle.start initial law hook.
            boss_runtime.phase_runtime.start_laws(self)
    changed.emit("進入戰鬥" if active else "未選擇存活隊伍／敵人")
    return active

func attack_preflight(attacker: Dictionary,target: Dictionary) -> bool:
    # Real party/troop combatants always carry normalized source State IDs.
    # Some long-standing pure-formula tests use standalone data dictionaries
    # without battler states. Keep those legacy formula probes separate.
    if (attacker.has("states") or party.has(attacker) or enemies.has(attacker)) and (
            not FSOriginalActionSeal.can_use(attacker,db,"attack")):
        changed.emit("原版 #312 攻撃封印：攻擊無法結算")
        return false
    # A pure authority refresh is required for dynamic State/Equip changes
    # even if the original combat action was queued one ATB frame earlier.
    # Never draw RNG or mutate HP before the FINAL source quote validates.
    if not _refresh_element_source(attacker) or not (
            _refresh_element_source(target)) or not (
            _refresh_ivy_pain_source(attacker)) or not (
            _refresh_ivy_pain_source(target)):
        return false
    if bool(target.get("fs_ivy_furnace_state_authority_pending",false)) or bool(
            attacker.get("fs_ivy_furnace_state_authority_pending",false)):
        changed.emit("Ivy145 State85 ATB 狀態期限已失去來源，不消耗攻擊亂數")
        return false
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
    # Source ALBERT_IVY_CLONE v1.6.2 can redirect landed positive damage
    # to Actor#5 only when a verified main Ivy guard has active charges.
    # Check the guard's own independent defense quote BEFORE any HIT RNG.
    if ivy_cover.active:
        var coverage: Dictionary=ivy_cover.preview(
            self,attacker,target,"attack")
        if not bool(coverage.get("ok",false)):
            changed.emit("原版艾薇護衛來源未驗證：" + str(
                coverage.get("reason","")))
            return false
    if ivy_od_defense.active:
        var od_preflight:Dictionary=ivy_od_defense.quote(self,target,1)
        if not bool(od_preflight.get("ok",false)):
            changed.emit("原版 OD 減傷來源不完整：" + str(
                od_preflight.get("reason","")))
            return false
    if ivy_pain.active:
        var direct_pain: Dictionary=ivy_pain.quote(
            self,attacker,target,{"hp":1},false)
        if not bool(direct_pain.get("ok",false)):
            changed.emit("艾薇原版蓄痛來源缺失：" + str(
                direct_pain.get("reason","")))
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
    if ivy_cover.active:
        ivy_cover.begin_action()
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
    # Original ComboCore make_attack_damage_value modifies positive
    # source hit AFTER the baseline/guard, BEFORE Field404 and Shield77.
    var od_hit:Dictionary=ivy_od_defense.quote(self,target,damage)
    if not bool(od_hit.get("ok",false)):
        changed.emit("OD 減傷狀態於 ACT 失去來源，攻擊未提交")
        return 0
    damage=int(od_hit["hp"])
    if field_weather.active and field_weather.current_id > 0:
        # #404 source hook runs AFTER baseline damage is calculated.
        var field: Dictionary = field_weather.preview_damage(
            db,target,attacker.get("element_set",null),damage,0)
        if not bool(field.get("ok",false)):
            changed.emit("天氣傷害欄位無法核對，未造成傷害")
            return 0
        damage = int(field["hp"])
    if ivy_cover.active and damage>0:
        # Original make_attack_damage_value first calculates HP damage on
        # the selected actor. Main Ivy Cover then recalculates an entirely
        # separate attack against the REAL guard, WITHOUT rerolling HIT/EVA.
        var covered: Dictionary=ivy_cover.guard_damage(
            self,attacker,target,"attack",{},int(
                landed.get("crit_chance",0)))
        if not bool(covered.get("ok",false)):
            changed.emit("艾薇護衛重算被拒絕：" + str(covered.get("reason","")))
            return 0
        if bool(covered.get("covered",false)):
            var transferred: Dictionary=ivy_cover.commit(
                self,attacker,target,covered)
            if not bool(transferred.get("ok",false)):
                return 0
            changed.emit("%s 被艾薇護衛，實際承傷 %d／護盾 MP %d" % [
                target.get("name","隊友"),int(transferred["hp"]),
                int(transferred["mp"])])
            ivy_cover.end_action()
            _check_end()
            return int(transferred["hp"])
    var hit: Dictionary = boss_state_effects.preview_hit(target,damage)
    if not bool(hit.get("ok",false)):
        changed.emit("原版 Boss 護盾效果未驗證，攻擊未結算")
        return 0
    var pain_quote: Dictionary=ivy_pain.quote(
        self,attacker,target,hit,false)
    if not bool(pain_quote.get("ok",false)):
        changed.emit("艾薇蓄痛缺少實際 HP 損失來源，未結算")
        return 0
    boss_state_effects.commit_hit(target,hit)
    ivy_pain.commit(target,pain_quote)
    ivy_od_defense.record(od_hit)
    if accuracy.active:
        target["fs_last_action_result"] = "hit"
    if ivy_cover.active:
        ivy_cover.party_damage(self,attacker,target,int(hit["hp"]))
    changed.emit("%s 攻擊 %s：HP %d／護盾吸收 MP %d" % [
        attacker.get("name","?"),target.get("name","?"),
        int(hit["hp"]),int(hit["mp"])])
    if ivy_cover.active:
        ivy_cover.end_action()
    _check_end()
    return int(hit["hp"])

func skill_preflight(user: Dictionary, target: Dictionary, skill_id: int) -> bool:
    if (user.has("states") or party.has(user) or enemies.has(user)) and (
            not FSOriginalActionSeal.can_use(user,db,"skill")):
        changed.emit("原版 #312 スキル封印：不能使用技能或支付 MP")
        return false
    if not _refresh_element_source(user) or not (
            _refresh_element_source(target)) or not (
            _refresh_ivy_pain_source(user)) or not (
            _refresh_ivy_pain_source(target)):
        return false
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
    if bool(user.get("fs_ivy_furnace_state_authority_pending",false)) or bool(
            target.get("fs_ivy_furnace_state_authority_pending",false)):
        changed.emit("State85 的實際 ATB 期限來源缺失，禁止支付技能 MP")
        return false
    # A source-gated self-only Ivy145 ACT can attach the original 85+100
    # pair only with a PURE verified shape. Full MasterSetup note with
    # JP/charge/ricarica remains unsupported and must fail closed.
    if skill_id==145 and ivy_furnace.active and bool(
            skill.get("fs_ivy_furnace_source_verified",false)):
        if user!=target:
            changed.emit("145 必須向艾薇本人附加狀態")
            return false
        var furnace_plan:Dictionary=ivy_furnace.preview(self,user,skill)
        if not bool(furnace_plan.get("ok",false)):
            changed.emit("原版145 State85/100 效果不可驗證：" + str(
                furnace_plan.get("reason","")))
            return false
        return true
    # Pure source Skill147 quote must pass at COMMAND selection, before
    # paying MP, ATB ACT or drawing YEM HIT RNG.
    var revenge_quote: Dictionary=ivy_revenge.preview(user,skill)
    if not bool(revenge_quote.get("ok",false)):
        changed.emit("艾薇復仇重擊來源未完成：" + str(
            revenge_quote.get("reason","")))
        return false
    # Original Skill141 scope11 is SELF-targeting and activates Ivy <ig>
    # after successful ACT. Only a clean source-verified ig Note subset
    # is allowed; actual MasterSetup Skill141 has additional unported
    # JP/charge/recharge/OD/pop tags, so it remains correctly blocked.
    if ivy_cover.active and bool(
            skill.get("fs_ivy_guard_tag_verified",false)) and skill_id==141:
        if int(skill.get("scope",0))!=11 or user!=target or int(
                user.get("id",0))!=5 or not bool(user.get("actor",false)):
            changed.emit("Ivy 護衛技能只能由艾薇施放於自己")
            return false
        if int(skill.get("base_damage",1))!=0 or int(
                skill.get("atk_f",0))!=0 or int(
                skill.get("spi_f",0))!=0 or not skill.get(
                "plus_state_set",[]).is_empty() or not skill.get(
                "minus_state_set",[]).is_empty() or bool(
                skill.get("damage_to_mp",false)) or bool(
                skill.get("absorb_damage",false)):
            changed.emit("原版 Ivy Guard 含未移植額外效果，不扣 MP")
            return false
        var ivy_plan: Dictionary=ivy_cover.preview_main_guard(
            self,user,skill)
        if not bool(ivy_plan.get("ok",false)):
            changed.emit("Ivy Guard 來源無法核對：" + str(
                ivy_plan.get("reason","")))
            return false
        var ivy_cost: Dictionary=FSSkillCostRules.preview(skill,user)
        if not bool(ivy_cost.get("ok",false)) or int(
                user.get("mp",0))<int(ivy_cost.get("mp",999999)):
            changed.emit("Ivy Guard 額外技能 Note 或 MP 成本未驗證")
            return false
        return true
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
    if ivy_cover.active and int(skill.get("base_damage",0))>0:
        var coverage: Dictionary=ivy_cover.preview(
            self,user,target,"skill",skill)
        if not bool(coverage.get("ok",false)):
            changed.emit("艾薇護衛技能目標來源不完整，未扣 MP：" + str(
                coverage.get("reason","")))
            return false
    if ivy_od_defense.active:
        var od_preflight:Dictionary=ivy_od_defense.quote(self,target,1)
        if not bool(od_preflight.get("ok",false)):
            changed.emit("艾薇 OD 防禦有效 Note 不完整，技能未扣 MP")
            return false
    if ivy_pain.active:
        var direct_pain: Dictionary=ivy_pain.quote(
            self,user,target,{"hp":1},false)
        if not bool(direct_pain.get("ok",false)):
            changed.emit("原版艾薇蓄痛有效 Note 尚未核對，未扣 MP")
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
    if skill_id==145 and ivy_furnace.active and bool(
            skill.get("fs_ivy_furnace_source_verified",false)):
        var furnace_quote:Dictionary=ivy_furnace.preview(self,user,skill)
        if not bool(furnace_quote.get("ok",false)):
            return false
        var result:Dictionary=ivy_furnace.apply(
            self,user,skill,furnace_quote)
        if not bool(result.get("ok",false)):
            changed.emit("艾薇145 已拒絕不完整的狀態交易："+str(
                result.get("reason","")))
            return false
        user["fs_last_action_result"]="hit"
        changed.emit("艾薇145 ACT 完成：已扣 MP16，State85 4次 ATB READY 後待解除；State100 來源限定")
        return true
    var revenge_plan: Dictionary=ivy_revenge.preview(user,skill)
    if not bool(revenge_plan.get("ok",false)):
        return false
    # Clean synthetic source subset of original Ivy Skill141: selected
    # self at COMMAND time, pays MP and activates guard on completed ACT.
    # No HIT/EVA/CRIT RNG; original end_action activates <ig> even for
    # non-damaging self-buffs. No guard before this execution completes.
    if ivy_cover.active and skill_id==141 and bool(
            skill.get("fs_ivy_guard_tag_verified",false)):
        var ivy_plan: Dictionary=ivy_cover.preview_main_guard(
            self,user,skill)
        if not bool(ivy_plan.get("ok",false)):
            return false
        var ivy_cost: Dictionary=FSSkillCostRules.preview(skill,user)
        if not bool(ivy_cost.get("ok",false)) or int(
                user.get("mp",0))<int(ivy_cost.get("mp",999999)):
            return false
        ivy_cover.begin_action()
        var activated: Dictionary=ivy_cover.activate_main_guard(
            self,user,skill)
        if not bool(activated.get("ok",false)):
            return false
        user["mp"]=int(user["mp"])-int(ivy_cost["mp"])
        user["fs_last_action_result"]="hit"
        changed.emit("%s 完成 Ivy 主動護衛：次數 %d，持續 %d 次行動，支付 MP %d" % [
            str(user.get("name","Ivy")),int(activated["charges"]),
            int(activated["actions"]),int(ivy_cost["mp"])])
        ivy_cover.end_action()
        return true
    if ivy_cover.active:
        ivy_cover.begin_action()
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
        # Source wrapper drains pain only on an EFFECTFUL success. On
        # MISS/EVADE it still pays MP but preserves the action snapshot.
        ivy_revenge.after_action(user,revenge_plan,false)
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
    if bool(revenge_plan.get("applicable",false)):
        # ALBERT_MECHANIC_EXPANSION::make_obj_damage_value wraps the
        # previous smooth skill core and appends trunc(snapshot*50%).
        # This is AFTER YEM/crit/variance/Guard but BEFORE later Field404
        # and Boss shield. Explicitly gated, not a stock skill bonus.
        val+=int(revenge_plan["extra"])
    # Original ComboCore make_obj_damage_value adjusts positive SKILL
    # damage after prior YEM/Guard and source 147 revenge bonus but
    # before Field404, Cover and Shield77.
    var od_hit:Dictionary=ivy_od_defense.quote(self,target,val)
    if not bool(od_hit.get("ok",false)):
        changed.emit("OD 減傷來源於 ACT 改變，技能未扣 MP")
        return false
    val=int(od_hit["hp"])
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
    # Cover happens after a landed positive original-target skill result.
    # Guard recalculates its own source damage with independent YEM RNG.
    # Actual MP payment happens exactly once after the guard quote passes.
    if ivy_cover.active and val>0:
        var covered: Dictionary=ivy_cover.guard_damage(
            self,user,target,"skill",skill,int(landed.get("crit_chance",0)))
        if not bool(covered.get("ok",false)):
            changed.emit("原版技能護衛來源拒絕結算，無成本消耗：" + str(
                covered.get("reason","")))
            return false
        if bool(covered.get("covered",false)):
            var transferred: Dictionary=ivy_cover.commit(
                self,user,target,covered)
            if not bool(transferred.get("ok",false)):
                return false
            user["mp"]=int(user["mp"])-mp_cost
            target["fs_last_action_result"]="hit"
            if str(planned.get("kind","none"))!="none":
                field_weather.apply_source_object(db,user,skill,enemies)
            changed.emit("%s 的技能 %s 被艾薇護衛：承傷 %d／護盾 MP %d" % [
                user.get("name","敵人"),skill.get("name","技能"),
                int(transferred["hp"]),int(transferred["mp"])])
            ivy_cover.end_action()
            _check_end()
            return true
    # Preflight the confirmed ComboCore shield before any MP is spent.
    # Damage is modified by the OLD validated global field subset.
    var hit: Dictionary = boss_state_effects.preview_hit(target,val)
    if not bool(hit.get("ok",false)):
        changed.emit("Boss 狀態效果缺少來源證據，未消耗 MP")
        return false
    var pain_quote: Dictionary=ivy_pain.quote(
        self,user,target,hit,false)
    if not bool(pain_quote.get("ok",false)):
        changed.emit("艾薇蓄痛失去 post-Apply Note，技能未扣 MP")
        return false
    user["mp"] = int(user["mp"]) - mp_cost
    boss_state_effects.commit_hit(target,hit)
    ivy_pain.commit(target,pain_quote)
    ivy_od_defense.record(od_hit)
    # RPG VX skill_effect success: !miss/!evade/!skip AND an actual
    # HP/MP/State effect. Bounded 147 has no state effects or MP damage.
    # Thus a positive final HP effect consumes the stored snapshot once.
    ivy_revenge.after_action(user,revenge_plan,int(hit["hp"])!=0)
    if accuracy.active:
        target["fs_last_action_result"] = "hit"
    if ivy_cover.active:
        ivy_cover.party_damage(self,user,target,int(hit["hp"]))
    target["hp"] = mini(int(target["hp"]),maxi(1,int(target.get("maxhp",1))))
    if str(planned.get("kind","none")) != "none":
        var applied: Dictionary = field_weather.apply_source_object(
            db,user,skill,enemies)
        if not bool(applied.get("ok",false)):
            changed.emit("技能已結算，但天氣變更被原版場域優先權拒絕")
    changed.emit("%s 使用 %s：HP 變化 %d／護盾 MP 吸收 %d" % [
        user.get("name","?"),skill.get("name","?"),
        -int(hit["hp"]),int(hit["mp"])])
    if ivy_cover.active:
        ivy_cover.end_action()
    _check_end()
    return true

func use_item(target: Dictionary, item_id: int, user: Dictionary = {},
        in_battle: bool = true) -> bool:
    if in_battle and (user.has("states") or party.has(user) or (
            enemies.has(user))) and (
            not FSOriginalActionSeal.can_use(user,db,"item")):
        changed.emit("原版 #312 アイテム封印：禁止消耗物品")
        return false
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
    # In source-authorized mode, validate the NEW equipment list before
    # inventory/stat mutation. A missing KGC field must leave the original
    # weapon, bag counts and source element snapshot intact.
    var staged_authority: Dictionary = {}
    if element_provider.active:
        var planned_actor: Dictionary = actor.duplicate(true)
        planned_actor["equipment"] = next_slots.duplicate()
        staged_authority = element_provider.build(db,planned_actor)
        if not bool(staged_authority.get("ok",false)):
            changed.emit("裝備來源無法驗證，未變更背包：" + str(
                staged_authority.get("reason","")))
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
    if element_provider.active:
        staged_authority.erase("ok")
        actor["fs_element_authority"] = staged_authority
        element_provider.refresh_count += 1
    changed.emit("%s 裝備欄位 %d 已更新" % [actor.get("name","?"),slot])
    return true

func advance_atb(delta: float) -> void:
    if not active or not source_atb_initialized or delta <= 0.0 or force_actions.busy:
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
        ivy_furnace.on_atb_ready(self)
        boss_state_effects.on_atb_ready(self)
        if not active:
            break
        if force_actions.enabled:
            force_actions.drain_event(self)
            force_actions.prepare_troop(self)
        if not source_atb_wait:
            action_queue.cancel_interrupted(self)
            var forced_resolved: int = force_actions.resolve_one(self)
            if forced_resolved==0 and force_actions.ready.is_empty():
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

func queue_source_force_action(side: int,index: int,kind: String,target_index: int) -> bool:
    return force_actions.request_event(self,side,index,kind,target_index)

func queue_source_vx339(params: Array) -> bool:
    return force_actions.request_vx339(self,params)

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
    if ivy_cover.active and party.has(battler):
        # Guard / Item actions have no attack()/use_skill() call to open
        # a fresh source action serial. They STILL tick Ivy's duration.
        if kind in ["guard","item"]:
            ivy_cover.begin_action()
        ivy_cover.owner_action_finished(battler)
        ivy_cover.end_action()
    FSTankentaiATBCore.reset_after_action(battler,kind,object_id,db)
    if enemies.has(battler):
        enemy_valid_action_completed(battler)
    return true

func _state_atb_negative_authority(state_id: int) -> bool:
    # Typed State provider or exact #230/#234 State Note fallback.
    # Do not infer this from a skill note, truthy string or unknown ID.
    if state_id <= 0 or db == null:
        return false
    var authority: Dictionary = FSStateATBAuthority.resolve(db.record("states",state_id),state_id)
    return bool(authority.get("ok",false)) and bool(authority.get("allows_negative",false))

func apply_combo_atb_shift(enemy: Dictionary,delta: int,
        attacker: Dictionary = {},state_id: int = 0) -> Dictionary:
    # This adapter is ONLY the direct ComboCore ATB shift <atb_shift:-x>.
    # Ordinary ATB accumulation (above) is still a placeholder.
    if not enemies.has(enemy):
        return {"ok":false,"reason":"目標不是戰鬥中的敵人"}
    var outcome: Dictionary = FSATBResistance.apply_direct_shift(
        enemy,delta,state_id,attacker,_state_atb_negative_authority(state_id))
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
        actor,delta,state_id,attacker,_state_atb_negative_authority(state_id))
    if bool(outcome.get("ok",false)):
        action_queue.cancel_interrupted(self)
        changed.emit("%s ATB 受到直接位移 %d→%d" % [
            actor.get("name","我方"),outcome.get("before",0),
            outcome.get("after",0)])
    return outcome

# Source #231 L1844-1859 and #374 L2279-2311, bounded post-attach
# ATB-only effect. Caller must supply a verified attachment event and the
# ComboCore bonus calculated BEFORE attachment. This is not a generic
# State attachment, and is not automatically invoked by sync/UI.
func apply_source_state_atb_after_attach(battler: Dictionary,state_id: int,
        bonus_percent: float = 0.0) -> Dictionary:
    if not active or not source_atb_initialized or (
            not party.has(battler) and not enemies.has(battler)) or (
            not battler.has("source_atb_count")) or not battler.has("atb"):
        return {"ok":false,"reason":"State ATB target/runtime unavailable"}
    if not is_finite(bonus_percent) or absf(bonus_percent)>10000.0:
        return {"ok":false,"reason":"State ATB bonus outside scoped range"}
    var authority: Dictionary = FSStateATBAuthority.resolve(db.record("states",state_id),state_id)
    if not bool(authority.get("ok",false)) or not bool(authority.get("damage_known",false)):
        return {"ok":false,"reason":"State ATB source unavailable"}
    var base_delta: int = int(authority["damage_percent"])*10
    var extra_delta: int = int(float(base_delta)*bonus_percent/100.0)
    var before: int = int(battler["source_atb_count"])
    var allow_negative: bool = bool(authority["allows_negative"])
    if base_delta != 0:
        FSATBResistance.apply_direct_shift(battler,base_delta,state_id,{},allow_negative)
        if extra_delta != 0:
            FSATBResistance.apply_direct_shift(battler,extra_delta,state_id,{},allow_negative)
        action_queue.cancel_interrupted(self)
    return {"ok":true,"before":before,"after":int(battler["source_atb_count"]),
        "base_delta":base_delta,"extra_delta":extra_delta,
        "allows_negative":allow_negative,"source":"#231/#374 State ATB only"}

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
        # Original Scene_Battle#battle_end normal victory clears
        # party battle_only States (RPG::State battle_only). A defeat
        # that goes straight to Gameover bypasses that path, so this
        # bounded source cleanup is deliberately VICTORY-only.
        if not enemies_alive and ivy_furnace.active:
            ivy_furnace.end_battle(self)
        active = false
        finished.emit(enemies_alive == false)
