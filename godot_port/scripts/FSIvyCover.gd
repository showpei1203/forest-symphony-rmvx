extends RefCounted
class_name FSIvyCover

# SOURCE RESTRICTED Ivy (Actor#5) Cover adapter.
# Original All_Scripts_Export.txt lines 244516-248300
# ALBERT_IVY_CLONE V1.6.2 final try_redirect and last-wins select_guard.
# Implements only actively-charged MAIN IVY guard on enemy single-target
# landed positive HP damage, with original independent guard damage roll.
# Clone emergency cover, sprite motion, stored pain, fatal OD save and
# post-Cover State effects still require RGSS2 runtime testimony. OFF by
# default. Unsupported relevant source effects FAIL CLOSED before RNG.
const IVY_ID: int = 5
const ACTIVE_COVER_OD_PERCENT: int = 6
var active: bool = false
var errors: Array[String] = []
var events: Array[Dictionary] = []
var action_serial: int = 0
var direct_serial: int = 0
var session: Dictionary = {}

func _fail(reason: String) -> Dictionary:
    if not errors.has(reason):
        errors.append(reason)
    return {"ok":false,"reason":reason}

func begin_action(serial: int=0) -> void:
    direct_serial += 1
    action_serial = serial if serial>0 else direct_serial
    session.clear()

func end_action() -> void:
    session.clear()
    action_serial = 0

func start_battle(battle) -> bool:
    # ALBERT_IVY_CLONE.start_battle resets active cover and grants Actor5
    # exactly 10% of its MAX OD. Does not infer that 1000 is universal.
    action_serial=0
    direct_serial=0
    session.clear()
    for ally in battle.party:
        if int(ally.get("id",0))!=IVY_ID or not bool(
                ally.get("actor",false)) or int(ally.get("hp",0))<=0:
            continue
        ally["fs_ivy_guard_charges"]=0
        ally["fs_ivy_guard_actions_left"]=0
        ally["fs_ivy_guard_reduce"]=0
        ally["fs_ivy_team_hit_serial"]=-1
        ally["fs_ivy_self_hit_serial"]=-1
        if not bool(ally.get("fs_ivy_guard_source_verified",false)):
            continue
        if not ally.has("max_od") or int(ally["max_od"])<=0 or not ally.has("od"):
            _fail("艾薇原版最大 OD 不存在，不能正確初始化")
            return false
        ally["od"]=clampi(int(ally["od"])+roundi(float(
            ally["max_od"])*0.10),0,int(ally["max_od"]))
    return true

func activate_main_guard(battle,ivy: Dictionary,skill: Dictionary) -> Dictionary:
    # This is an explicit source ACTION-END hook, not a free status flag.
    # Skill <ig:charges,actions,reduce> is used by source
    # ALBERT_IVY_CLONE.apply_action_skill_tags after valid ACT.
    if not active or not battle.party.has(ivy) or int(
            ivy.get("id",0))!=IVY_ID or not bool(
            ivy.get("fs_ivy_guard_source_verified",false)):
        return _fail("無原版艾薇已驗證的護衛來源")
    if not bool(skill.get("fs_ivy_guard_tag_verified",false)):
        return _fail("艾薇護衛技能 Note 來源未驗證")
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*(?:ig|ivy_guard)\\s*:\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*>")!=OK:
        return _fail("艾薇原版護衛 Note 解析器錯誤")
    var match_result: RegExMatch=rx.search(str(skill.get("note","")))
    if match_result==null:
        return _fail("原版護衛技能沒有 ig/ivy_guard 設定")
    var charges: int=int(match_result.get_string(1))
    var actions: int=int(match_result.get_string(2))
    var reduce: int=clampi(int(match_result.get_string(3)),0,95)
    ivy["fs_ivy_guard_charges"]=maxi(0,charges)
    ivy["fs_ivy_guard_actions_left"]=maxi(0,actions)
    ivy["fs_ivy_guard_reduce"]=reduce
    ivy["fs_ivy_guard_activated_serial"]=action_serial
    return {"ok":true,"charges":charges,"actions":actions,
        "reduce":reduce}

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
        if bool(ivy.get("casting",false)) or not bool(
                ivy.get("movable",true)) or bool(
                ivy.get("fs_ivy_cover_motion_busy",false)):
            return {"ok":true,"covered":false}
        if not ivy.has("max_od") or int(ivy["max_od"])<=0 or not ivy.has("od"):
            return _fail("原版艾薇 MaxOD 尚未驗證，不能贈送護衛 OD")
        return {"ok":true,"covered":true,"guard":ivy,
            "guard_type":"main","reduce":clampi(int(
                ivy.get("fs_ivy_guard_reduce",0)),0,95)}
    if int(target.get("maxhp",0))>0 and int(
            target.get("hp",0))*100<int(target.get("maxhp",1))*50:
        for ally in battle.party:
            if ally==target or int(ally.get("hp",0))<=0:
                continue
            if str(ally.get("fs_clone_role",""))=="ivy":
                return _fail("半血以下映體艾薇緊急護衛尚未移植，拒絕錯誤攻擊")
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
            "reduce":int(session["reduce"]),"same_session":true}
    var picked: Dictionary=_guard(battle,target)
    if not bool(picked.get("ok",false)) or not bool(
            picked.get("covered",false)):
        return picked
    var guard: Dictionary=picked["guard"]
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
    var power: Dictionary={}
    if kind=="attack":
        power=battle.normal_core.resolve(
            battle,attacker,guard,critical_chance)
    else:
        power=battle.skill_core.resolve(
            battle,attacker,guard,skill,critical_chance)
    if not bool(power.get("ok",false)):
        return _fail("護衛重算原版傷害失敗："+str(power.get("reason","")))
    var raw: int=int(power["hp"])
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
    # Fatal-cover OD rescue and stored pain have separate source hooks.
    if int(hit.get("hp",0))>=int(guard.get("hp",0)) and (
            146 in guard.get("skills",[]) and int(
            guard.get("od",0))>=300):
        return _fail("艾薇替身承擔致死 Cover 的 OD 救援未實裝")
    return {"ok":true,"covered":true,"guard":guard,
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
    if first:
        session={"serial":action_serial,"original":original,
            "guard":guard,"reduce":int(resolved["reduce"])}
        guard["fs_ivy_guard_charges"]=maxi(0,int(
            guard["fs_ivy_guard_charges"])-1)
        var gained: int=roundi(float(guard["max_od"])*
            float(ACTIVE_COVER_OD_PERCENT)/100.0)
        guard["od"]=clampi(int(guard["od"])+gained,0,int(guard["max_od"]))
        if int(guard["fs_ivy_guard_charges"])<=0:
            guard["fs_ivy_guard_actions_left"]=0
            guard["fs_ivy_guard_reduce"]=0
    battle.boss_state_effects.commit_hit(guard,resolved["hit"])
    party_damage(battle,attacker,guard,int(resolved["hit"]["hp"]))
    original["fs_last_action_result"]="hit"
    original["fs_cover_redirected_serial"]=action_serial
    guard["fs_last_action_result"]="hit"
    guard["fs_last_action_critical"]=bool(resolved.get("critical",false))
    events.append({"serial":action_serial,"from":int(original.get("id",0)),
        "to":int(guard.get("id",0)),"hp":int(resolved["hit"]["hp"]),
        "mp":int(resolved["hit"]["mp"]),"first":first,
        "charges":int(guard.get("fs_ivy_guard_charges",0)),
        "od":int(guard.get("od",0))})
    return {"ok":true,"covered":true,"guard":guard,
        "hp":int(resolved["hit"]["hp"]),
        "mp":int(resolved["hit"]["mp"]),"first":first}
