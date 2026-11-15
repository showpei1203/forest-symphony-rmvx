extends RefCounted
class_name FSIvyCover

# SOURCE RESTRICTED Ivy (Actor#5) Cover adapter.
# Original All_Scripts_Export.txt lines 244516-248300
# ALBERT_IVY_CLONE V1.6.2 final try_redirect and last-wins select_guard.
# Implements main Ivy and source-verified emergency Ivy clone on enemy
# landed single-target HP damage, with independent guard damage calculation.
# Original source #397 / #402 and Phase46 test fixtures.
# Stored pain, fatal OD, sprite movement and post-Cover state-transfer are
# separately guarded; source subsets OFF by default, never fake full FS.
const IVY_ID: int = 5
const ACTIVE_COVER_OD_PERCENT: int = 6
const FATAL_COVER_SKILL_ID: int = 146
const FATAL_COVER_OD_COST: int = 300
var active: bool = false
var errors: Array[String] = []
var events: Array[Dictionary] = []
var action_serial: int = 0
var direct_serial: int = 0
var last_action_serial: int = 0
var session: Dictionary = {}

func _fail(reason: String) -> Dictionary:
    if not errors.has(reason):
        errors.append(reason)
    return {"ok":false,"reason":reason}

func begin_action(serial: int=0) -> void:
    direct_serial += 1
    action_serial = serial if serial>0 else direct_serial
    last_action_serial=action_serial
    session.clear()

func end_action() -> void:
    session.clear()
    action_serial = 0

func start_battle(battle) -> bool:
    # ALBERT_IVY_CLONE.start_battle resets active cover and grants Actor5
    # exactly 10% of its MAX OD. Does not infer that 1000 is universal.
    action_serial=0
    direct_serial=0
    last_action_serial=0
    session.clear()
    for ally in battle.party:
        if str(ally.get("fs_clone_role",""))=="ivy":
            ally["fs_ivy_clone_guard_used"]=false
            ally["fs_ivy_clone_guarded"]=false
        if int(ally.get("id",0))!=IVY_ID or not bool(
                ally.get("actor",false)) or int(ally.get("hp",0))<=0:
            continue
        ally["fs_ivy_guard_charges"]=0
        ally["fs_ivy_guard_actions_left"]=0
        ally["fs_ivy_guard_reduce"]=0
        ally["fs_ivy_team_hit_serial"]=-1
        ally["fs_ivy_self_hit_serial"]=-1
        # Source reset_battler sets one-battle fatal Cover rescue to unused.
        ally["fs_ivy_fatal_used"]=false
        if not bool(ally.get("fs_ivy_guard_source_verified",false)):
            continue
        if not ally.has("max_od") or int(ally["max_od"])<=0 or not ally.has("od"):
            _fail("艾薇原版最大 OD 不存在，不能正確初始化")
            return false
        ally["od"]=clampi(int(ally["od"])+roundi(float(
            ally["max_od"])*0.10),0,int(ally["max_od"]))
    return true

func preview_main_guard(battle,ivy: Dictionary,skill: Dictionary) -> Dictionary:
    # Pure skill-source quote, used at ATB COMMAND selection AND ACT end.
    # Unknown source Note or missing MaxOD cannot spend MP.
    if not active or not battle.party.has(ivy) or int(
            ivy.get("id",0))!=IVY_ID or not bool(
            ivy.get("actor",false)) or not bool(
            ivy.get("fs_ivy_guard_source_verified",false)):
        return _fail("無原版艾薇已驗證的護衛來源")
    if not ivy.has("max_od") or int(ivy["max_od"])<=0 or not ivy.has("od"):
        return _fail("艾薇最大 OD 權威尚未驗證")
    if not bool(skill.get("fs_ivy_guard_tag_verified",false)):
        return _fail("艾薇護衛技能 Note 來源未驗證")
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*(?:ig|ivy_guard)\\s*:\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*>")!=OK:
        return _fail("艾薇原版護衛 Note 解析器錯誤")
    var match_result: RegExMatch=rx.search(str(skill.get("note","")))
    if match_result==null:
        return _fail("原版護衛技能沒有 ig/ivy_guard 設定")
    return {"ok":true,"charges":int(match_result.get_string(1)),
        "actions":int(match_result.get_string(2)),
        "reduce":clampi(int(match_result.get_string(3)),0,95)}

func activate_main_guard(battle,ivy: Dictionary,skill: Dictionary) -> Dictionary:
    # Original ALBERT_IVY_CLONE.end_action applies source <ig> only AFTER
    # a successful ACT, never at command selection or during charge.
    var plan: Dictionary=preview_main_guard(battle,ivy,skill)
    if not bool(plan.get("ok",false)):
        return plan
    ivy["fs_ivy_guard_charges"]=int(plan["charges"])
    ivy["fs_ivy_guard_actions_left"]=int(plan["actions"])
    ivy["fs_ivy_guard_reduce"]=int(plan["reduce"])
    ivy["fs_ivy_guard_activated_serial"]=action_serial
    return plan

func owner_action_finished(ivy: Dictionary) -> void:
    # Original tick_owner_action resets clone's once-per-owner-action
    # emergency guard usage, independent of main Ivy active guard duration.
    if not active:
        return
    if str(ivy.get("fs_clone_role",""))=="ivy":
        ivy["fs_ivy_clone_guard_used"]=false
        ivy["fs_ivy_clone_guarded"]=false
    # Original tick_owner_action must skip the SAME action that first
    # activated <ig> (source @albert_ic_guard_activated_serial).
    if int(ivy.get("id",0))!=IVY_ID or not bool(
            ivy.get("fs_ivy_guard_source_verified",false)) or int(
            ivy.get("fs_ivy_guard_actions_left",0))<=0:
        return
    if int(ivy.get("fs_ivy_guard_activated_serial",-1))==last_action_serial:
        return
    ivy["fs_ivy_guard_actions_left"]=maxi(0,int(
        ivy["fs_ivy_guard_actions_left"])-1)
    if int(ivy["fs_ivy_guard_actions_left"])<=0:
        ivy["fs_ivy_guard_charges"]=0
        ivy["fs_ivy_guard_reduce"]=0

func _gain_percent(ivy: Dictionary,percent: int) -> bool:
    if not ivy.has("max_od") or int(ivy["max_od"])<=0 or not ivy.has("od"):
        return false
    ivy["od"]=clampi(int(ivy["od"])+roundi(float(
        ivy["max_od"])*float(percent)/100.0),0,int(ivy["max_od"]))
    return true

func party_damage(battle,attacker: Dictionary,victim: Dictionary,
        damage: int) -> void:
    # Original source process_party_damage checks enemy->actor and
    # positive HP damage, then pays +2% team and +2% self only ONCE
    # for each source action serial. Does not stack per multi-hit.
    if not active or damage<=0 or bool(attacker.get("actor",true)) or not bool(
            victim.get("actor",false)):
        return
    for ally in battle.party:
        if int(ally.get("id",0))!=IVY_ID or int(ally.get("hp",0))<=0 or not bool(
                ally.get("fs_ivy_guard_source_verified",false)):
            continue
        if int(ally.get("fs_ivy_team_hit_serial",-1))!=action_serial:
            ally["fs_ivy_team_hit_serial"]=action_serial
            _gain_percent(ally,2)
        if ally==victim and int(ally.get("fs_ivy_self_hit_serial",-1))!=action_serial:
            ally["fs_ivy_self_hit_serial"]=action_serial
            _gain_percent(ally,2)
        break

func _fatal_authority(battle,guard: Dictionary) -> Dictionary:
    # Phase46B2 actual RGSS2 Ivy fixture proves:
    # only actor5, learned skill146, OD>=300, pending lethal cover,
    # once per battle. This exact passive Note remains private until
    # post-Apply FS_DB_AUTOSET source witness is available.
    if int(guard.get("id",0))!=IVY_ID or not bool(
            guard.get("actor",false)) or not (
            FATAL_COVER_SKILL_ID in guard.get("skills",[])):
        return {"ok":true,"eligible":false}
    if not bool(guard.get("fs_ivy_fatal_source_verified",false)):
        return _fail("艾薇原版 Skill146 被動資格與 OD 成本未驗證")
    var passive: Dictionary=battle.db.record("skills",FATAL_COVER_SKILL_ID)
    var note: String=str(passive.get("note","")).to_lower()
    if int(passive.get("id",0))!=FATAL_COVER_SKILL_ID or (
            int(passive.get("scope",-1))!=0) or not (
            note.contains("<mechanic_passive>")) or not (
            note.contains("<cover_store_cap_percent:400>")):
        return _fail("艾薇被動 Skill146 必須符合原版 post-Apply 來源")
    if not guard.has("max_od") or int(guard["max_od"])<=0 or not guard.has("od"):
        return _fail("艾薇致死 Cover 無法驗證原版 OD 欄位")
    return {"ok":true,"eligible":true}

func _guard(battle,target: Dictionary) -> Dictionary:
    # Source original select_guard: active main Ivy FIRST, then optional
    # clone Ivy when target HP is below 50%. Do not pretend that this
    # broader clause has been ported if an emergency clone is present.
    if bool(target.get("actor",false))==false:
        return {"ok":true,"covered":false}
    var ivy: Dictionary = {}
    for ally in battle.party:
        if int(ally.get("id",0))==IVY_ID and ally!=target and (
                int(ally.get("hp",0))>0):
            ivy=ally
            break
    if not ivy.is_empty() and (int(ivy.get("fs_ivy_guard_charges",0))>0 and
            int(ivy.get("fs_ivy_guard_actions_left",0))>0):
        if not bool(ivy.get("fs_ivy_guard_source_verified",false)):
            return _fail("艾薇已啟動的主動護衛缺少原版技能/次數權威")
        if not (bool(ivy.get("casting",false)) or not bool(
                ivy.get("movable",true)) or bool(
                ivy.get("fs_ivy_cover_motion_busy",false))):
            if not ivy.has("max_od") or int(ivy["max_od"])<=0 or not ivy.has("od"):
                return _fail("原版艾薇 MaxOD 尚未驗證，不能贈送護衛 OD")
            if 142 in ivy.get("skills",[]) or 814 in ivy.get("skills",[]):
                # Both source passive142 and legacy skill814 carry Ivy
                # defense meaning in FS_BATTLE_V22.PASSIVE_NAMES.
                # Previous source guard correctly refused unported 142.
                # It may now proceed ONLY when the actual ComboCore OD
                # reduction adapter is live and independently verified;
                # a lone legacy boolean must never bypass damage math.
                if not battle.ivy_od_defense.active:
                    return _fail("原版艾薇被動142 仍未啟用實際 OD 減傷")
                var shield_quote:Dictionary=battle.ivy_od_defense.quote(
                    battle,ivy,1,true)
                if not bool(shield_quote.get("ok",false)):
                    return _fail("艾薇被動142 護衛來源不完整：" + str(
                        shield_quote.get("reason","")))
            if int(ivy.get("fs_ivy_taunt_reduce",0))>0 and not bool(
                    ivy.get("fs_ivy_taunt_source_verified",false)):
                return _fail("艾薇挑釁造成的護衛追加減傷來源未驗證")
            return {"ok":true,"covered":true,"guard":ivy,
                "guard_type":"main","reduce":clampi(int(
                    ivy.get("fs_ivy_guard_reduce",0)),0,95)}
        # Source select_guard falls through to half-HP Ivy Clone when
        # active main guard is casting/unmovable/busy. Do not skip it.
    if int(target.get("maxhp",0))>0 and int(
            target.get("hp",0))*100<int(target.get("maxhp",1))*50:
        for ally in battle.party:
            if ally==target or int(ally.get("hp",0))<=0:
                continue
            if str(ally.get("fs_clone_role",""))!="ivy":
                continue
            # Original clone_role is derived from ALBERT_ACTOR_PROFILE,
            # summoned actor Notes and <human_clone:ivy>. Require an
            # explicitly verified origin before making gameplay decisions.
            if not bool(ally.get("fs_clone_role_source_verified",false)):
                return _fail("映體艾薇角色來源 Note/Profile 尚未核對")
            if bool(ally.get("fs_ivy_clone_guard_used",false)):
                continue
            if bool(ally.get("casting",false)) or not bool(
                    ally.get("movable",true)) or bool(
                    ally.get("fs_ivy_cover_motion_busy",false)):
                continue
            if bool(ally.get("fs_boss_phase_effects_pending",false)):
                return _fail("映體護衛者的未知 Boss 狀態未驗證")
            # Source v1.5 select_guard returns FIRST eligible clone.
            # No main-Ivy +6% OD charge on clone emergency cover.
            return {"ok":true,"covered":true,"guard":ally,
                "guard_type":"clone","reduce":15}
    return {"ok":true,"covered":false}

func preview(battle,attacker: Dictionary,target: Dictionary,
        kind: String,skill: Dictionary={},positive_hp: int=1) -> Dictionary:
    if not active:
        return {"ok":true,"covered":false}
    if bool(attacker.get("actor",true)) or not bool(
            target.get("actor",false)) or positive_hp<=0:
        return {"ok":true,"covered":false}
    if kind not in ["attack","skill"]:
        return {"ok":true,"covered":false}
    if kind=="skill" and int(skill.get("scope",0))!=1:
        return {"ok":true,"covered":false}
    if not session.is_empty() and int(session.get("serial",-1))==action_serial:
        if session.get("original",{}) != target:
            return {"ok":true,"covered":false}
        return {"ok":true,"covered":true,"guard":session["guard"],
            "guard_type":str(session.get("guard_type","main")),
            "reduce":int(session["reduce"]),"same_session":true}
    var picked: Dictionary=_guard(battle,target)
    if not bool(picked.get("ok",false)) or not bool(
            picked.get("covered",false)):
        return picked
    var guard: Dictionary=picked["guard"]
    # Original last-wins MechanicExpansion.source_text includes ACTUAL
    # guard equipment and live State notes. Source provider refreshes
    # the guard even though only the protected target was quoted by
    # the caller's attack_preflight.
    if not battle._refresh_ivy_pain_source(guard):
        return _fail("護衛者最新裝備/State 蓄痛來源未驗證")
    var fatal: Dictionary=_fatal_authority(battle,guard)
    if not bool(fatal.get("ok",false)):
        return fatal
    # In source try_redirect, the MAIN Cover bonus OD +6% is granted
    # BEFORE guard.make_attack_damage_value, so actor142 at OD49%
    # can cross the OD50 threshold when the action actually executes.
    var preview_od:Dictionary=battle.ivy_od_defense.quote(
        battle,guard,1,str(picked.get("guard_type","main"))=="main" and not (
        bool(picked.get("same_session",false))))
    if not bool(preview_od.get("ok",false)):
        return _fail("護衛者被動142 OD 減傷權威缺失：" + str(
            preview_od.get("reason","")))
    # Source read-only pain-provider preflight BEFORE original HIT RNG.
    # It needs effective merged Note provenance for Actor#5 only.
    var pain_check: Dictionary=battle.ivy_pain.quote(
        battle,attacker,guard,{"hp":1},true)
    if not bool(pain_check.get("ok",false)):
        return _fail("蓄痛來源未驗證："+str(pain_check.get("reason","")))
    if bool(guard.get("fs_boss_phase_effects_pending",false)):
        return _fail("護衛者具有原版未知狀態效果")
    # Recalculate damage on the ACTUAL guard like source
    # perform_guard_damage. It must not recycle the protected target's
    # HP damage or re-roll the original HIT/EVA.
    if kind=="attack":
        if not battle.normal_core.active:
            return _fail("主動護衛需要已驗證的原版普攻來源公式")
        var q: Dictionary=battle.normal_core.quote(battle,attacker,guard)
        if not bool(q.get("ok",false)):
            return _fail("護衛者普攻傷害來源缺失："+str(q.get("reason","")))
    else:
        if not battle.skill_core.active:
            return _fail("主動護衛需要已驗證的原版單體技能來源公式")
        var q: Dictionary=battle.skill_core.quote(
            battle,attacker,guard,skill)
        if not bool(q.get("ok",false)):
            return _fail("護衛者技能傷害來源缺失："+str(q.get("reason","")))
    # Source Field404 and TargetFix last-wins placement across
    # internal guard re-entry remains untraced. Prevent double Field.
    if battle.field_weather.active and battle.field_weather.current_id>0:
        return _fail("全域天氣下 Cover 二次來源傷害覆寫順序未驗證")
    return picked

func guard_damage(battle,attacker: Dictionary,target: Dictionary,
        kind: String,skill: Dictionary,critical_chance: int) -> Dictionary:
    var result: Dictionary=preview(battle,attacker,target,kind,skill)
    if not bool(result.get("ok",false)) or not bool(
            result.get("covered",false)):
        return result
    var guard: Dictionary=result["guard"]
    # Source guard.make_attack_damage_value / make_obj_damage_value
    # re-evaluates effective CRITICAL chance for guard's own AGI, State
    # and prevent_critical. The originally-selected actor's CRIT chance
    # is NOT reused; only original HIT/EVA are already resolved.
    var guard_chance: Dictionary=battle.accuracy.quote(
        battle,attacker,guard,skill if kind=="skill" else {})
    if not bool(guard_chance.get("ok",false)):
        return _fail("護衛者獨立暴擊來源未驗證："+str(
            guard_chance.get("reason","")))
    var guard_crit: int=int(guard_chance.get("crit",critical_chance))
    var power: Dictionary={}
    if kind=="attack":
        power=battle.normal_core.resolve(
            battle,attacker,guard,guard_crit)
    else:
        power=battle.skill_core.resolve(
            battle,attacker,guard,skill,guard_crit)
    if not bool(power.get("ok",false)):
        return _fail("護衛重算原版傷害失敗："+str(power.get("reason","")))
    var od_plan:Dictionary=battle.ivy_od_defense.quote(
        battle,guard,int(power["hp"]),str(result.get("guard_type","main"))=="main" and not (
        bool(result.get("same_session",false))))
    if not bool(od_plan.get("ok",false)):
        return _fail("護衛承傷 OD 倍率來源無效：" + str(
            od_plan.get("reason","")))
    var raw:int=int(od_plan["hp"])
    var reduce: int=maxi(int(result["reduce"]),
        int(guard.get("fs_ivy_taunt_reduce",0)))
    # Source perform_guard_damage rounds AGAIN after independent
    # guard damage. Preserve min1 for raw positive damage.
    var adjusted: int=roundi(float(raw)*float(100-reduce)/100.0)
    if raw>0:
        adjusted=maxi(1,adjusted)
    if bool(guard.get("fs_ivy_guard_internal_pending",false)):
        return _fail("護衛遞迴傷害循環未驗證")
    var hit: Dictionary=battle.boss_state_effects.preview_hit(guard,adjusted)
    if not bool(hit.get("ok",false)):
        return _fail("護衛者原版 MP 護盾計算尚未驗證")
    # Source ~246106 & Phase46B2: fatal guard rescue sees damage
    # AFTER guard's independent damage and reduction; +6% MaxOD main
    # Cover income is awarded BEFORE execute_damage and may qualify.
    # OD300 is paid BEFORE HP commit, and exactly HP-1 is dealt.
    var fatal_save: bool=false
    var fatal: Dictionary=_fatal_authority(battle,guard)
    if not bool(fatal.get("ok",false)):
        return fatal
    var lethal: bool=int(guard.get("hp",0))>0 and int(
            hit.get("hp",0))>=int(guard.get("hp",0))
    if lethal and bool(fatal.get("eligible",false)) and not bool(
            guard.get("fs_ivy_fatal_used",false)):
        var additional_od: int=0
        if str(result.get("guard_type","main"))=="main" and not bool(
                result.get("same_session",false)):
            additional_od=roundi(float(guard.get("max_od",0))*0.06)
        var available_od: int=mini(int(guard.get("max_od",0)),
            int(guard.get("od",0))+additional_od)
        if available_od>=FATAL_COVER_OD_COST:
            fatal_save=true
            hit=hit.duplicate(true)
            hit["hp"]=maxi(0,int(guard["hp"])-1)
    var pain_plan: Dictionary=battle.ivy_pain.quote(
        battle,attacker,guard,hit,true)
    if not bool(pain_plan.get("ok",false)):
        return _fail("艾薇實際承傷蓄痛來源缺失："+str(
            pain_plan.get("reason","")))
    return {"ok":true,"covered":true,"guard":guard,
        "od_plan":od_plan,"pain_plan":pain_plan,"fatal_save":fatal_save,
        "guard_type":str(result.get("guard_type","main")),
        "hit":hit,"damage":int(hit["hp"]),"reduce":reduce,
        "critical":bool(power.get("critical",false)),
        "raw":raw,"same_session":bool(result.get("same_session",false))}

func commit(battle,attacker: Dictionary,original: Dictionary,
        resolved: Dictionary) -> Dictionary:
    if not bool(resolved.get("ok",false)) or not bool(
            resolved.get("covered",false)):
        return _fail("無效 Cover 交易不得提交")
    var guard: Dictionary=resolved["guard"]
    var first: bool=not bool(resolved.get("same_session",false))
    # Commit is one transaction after ALL power/Shield quote checks.
    var role: String=str(resolved.get("guard_type","main"))
    if first:
        session={"serial":action_serial,"original":original,
            "guard":guard,"reduce":int(resolved["reduce"]),
            "guard_type":role}
        if role=="clone":
            # Source v1.5 marks clone.used exactly ONCE, reset only
            # when the clone completes ITS OWN action.
            guard["fs_ivy_clone_guard_used"]=true
            guard["fs_ivy_clone_guarded"]=true
        else:
            guard["fs_ivy_guard_charges"]=maxi(0,int(
                guard["fs_ivy_guard_charges"])-1)
            var gained: int=roundi(float(guard["max_od"])*
                float(ACTIVE_COVER_OD_PERCENT)/100.0)
            guard["od"]=clampi(int(guard["od"])+gained,0,int(guard["max_od"]))
            if int(guard["fs_ivy_guard_charges"])<=0:
                guard["fs_ivy_guard_actions_left"]=0
                guard["fs_ivy_guard_reduce"]=0
    if bool(resolved.get("fatal_save",false)):
        # This executes after first-session main +6% OD, which matches
        # source try_redirect -> execute_damage wrapper ordering.
        guard["od"]=int(guard["od"])-FATAL_COVER_OD_COST
        guard["fs_ivy_fatal_used"]=true
    battle.boss_state_effects.commit_hit(guard,resolved["hit"])
    battle.ivy_od_defense.record(resolved.get("od_plan",{"applicable":false}))
    var pain: Dictionary=battle.ivy_pain.commit(guard,resolved.get(
        "pain_plan",{"ok":true,"applicable":false}))
    if not bool(pain.get("ok",false)):
        return pain
    party_damage(battle,attacker,guard,int(resolved["hit"]["hp"]))
    original["fs_last_action_result"]="hit"
    original["fs_cover_redirected_serial"]=action_serial
    guard["fs_last_action_result"]="hit"
    guard["fs_last_action_critical"]=bool(resolved.get("critical",false))
    events.append({"serial":action_serial,"from":int(original.get("id",0)),
        "to":int(guard.get("id",0)),"guard_type":role,
        "hp":int(resolved["hit"]["hp"]),
        "mp":int(resolved["hit"]["mp"]),"first":first,
        "charges":int(guard.get("fs_ivy_guard_charges",0)),
        "clone_used":bool(guard.get("fs_ivy_clone_guard_used",false)),
        "fatal_save":bool(resolved.get("fatal_save",false)),
        "stored_pain":int(guard.get("fs_ivy_stored_pain",0)),
        "od":int(guard.get("od",0))})
    return {"ok":true,"covered":true,"guard":guard,
        "hp":int(resolved["hit"]["hp"]),
        "mp":int(resolved["hit"]["mp"]),"first":first,
        "fatal_save":bool(resolved.get("fatal_save",false))}
