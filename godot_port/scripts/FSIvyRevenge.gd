extends RefCounted
class_name FSIvyRevenge

# Original FS ALBERT_MECHANIC_EXPANSION ~220475-220505 and
# Scene_Battle#execute_action_skill ~222005-222098:
# Skill147 actor5 snapshots stored_cover at ACTION START (not selected
# command time), adds trunc(snapshot * <revenge_from_cover:50>/100)
# to calculated positive HP damage and clears stored value ONCE
# only when skill_effect was successful (not missed/evaded/skipped
# and actual nonzero HP/MP/State result). Source full Skill147 also has
# unported JP/charge/recharge/levels, therefore source-limited subset
# is explicitly gated; .active=false by default.
const IVY_ID: int=5
const REVENGE_SKILL_ID: int=147
var active: bool=false
var errors: Array[String]=[]
var events: Array[Dictionary]=[]

func _fail(reason: String)->Dictionary:
    if not errors.has(reason):
        errors.append(reason)
    return {"ok":false,"reason":reason}

func preview(user: Dictionary,skill: Dictionary)->Dictionary:
    if not active:
        return {"ok":true,"applicable":false}
    if int(skill.get("id",0))!=REVENGE_SKILL_ID:
        return {"ok":true,"applicable":false}
    if not bool(user.get("actor",false)) or int(user.get("id",0))!=IVY_ID:
        return _fail("復仇重擊只可由原版艾薇 Actor5 執行")
    if not (REVENGE_SKILL_ID in user.get("skills",[])):
        return _fail("艾薇未學會原始復仇重擊 Skill147")
    if not bool(skill.get("fs_ivy_revenge_source_verified",false)):
        return _fail("Skill147 復仇 50% 及消耗來源尚未驗證")
    if int(skill.get("scope",0))!=1 or int(
            skill.get("base_damage",0))<=0 or bool(
            skill.get("damage_to_mp",false)) or bool(
            skill.get("absorb_damage",false)) or not skill.get(
            "plus_state_set",[]).is_empty() or not skill.get(
            "minus_state_set",[]).is_empty():
        return _fail("原版 Skill147 尚有未實裝的範圍/狀態/MP 效果")
    # A clean synthetic fixture must contain ONLY these exact
    # two mechanic tags. Full original JP/charge/recharge Notes
    # must be refused by the other skill cost/charge gates too.
    var note: String=str(skill.get("note",""))
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*revenge_from_cover\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)\\s*>")!=OK:
        return _fail("復仇倍率標籤解析器錯誤")
    var matches: Array=rx.search_all(note)
    if matches.size()!=1 or absf(float(
            matches[0].get_string(1))-50.0)>0.0001:
        return _fail("原版 Skill147 必須明確 <revenge_from_cover:50>")
    var consume:=RegEx.new()
    if consume.compile("(?i)<\\s*consume_stored_cover\\s*>")!=OK:
        return _fail("蓄痛消耗標籤解析器錯誤")
    var consumes: Array=consume.search_all(note)
    if consumes.size()!=1:
        return _fail("原版 Skill147 必須具有唯一蓄痛消耗標記")
    var remaining: String=note.replace(matches[0].get_string(0),"").replace(
        consumes[0].get_string(0),"").strip_edges()
    if not remaining.is_empty():
        return _fail("Skill147 存在 JP/charge/升級等其他未實裝 Note")
    if not user.has("fs_ivy_stored_pain") or not bool(
            user.get("fs_ivy_pain_notes_verified",false)) or not (
            user.get("fs_ivy_effective_notes",null) is Array):
        return _fail("原版艾薇蓄痛儲量/有效 Note 不完整")
    var stored: int=int(user["fs_ivy_stored_pain"])
    if stored<0:
        return _fail("原版蓄痛不可為負數")
    # Original Ruby .to_i truncation.
    var extra: int=int(float(stored)*0.50)
    return {"ok":true,"applicable":true,"snapshot":stored,
        "extra":extra,"skill_id":REVENGE_SKILL_ID}

func after_action(user: Dictionary,snapshot: Dictionary,
        successful: bool)->Dictionary:
    if not bool(snapshot.get("ok",false)):
        return _fail("復仇來源 Quote 不合法")
    if not bool(snapshot.get("applicable",false)):
        return {"ok":true,"cleared":false}
    # Original Scene_Battle wrapper checks albert_mx_action_success,
    # not whether a command was merely queued or MP was paid.
    if not successful:
        events.append({"skill":REVENGE_SKILL_ID,"success":false,
            "snapshot":int(snapshot["snapshot"]),"cleared":false})
        return {"ok":true,"cleared":false}
    # Exact source if the current stored value changed during ACT:
    # consume_stored_cover clears the WHOLE current reservoir once,
    # while damage calculation used the action-start snapshot.
    var prior: int=maxi(0,int(user.get("fs_ivy_stored_pain",0)))
    user["fs_ivy_stored_pain"]=0
    events.append({"skill":REVENGE_SKILL_ID,"success":true,
        "snapshot":int(snapshot["snapshot"]),"extra":int(
        snapshot["extra"]),"consumed":prior,"cleared":true})
    return {"ok":true,"cleared":true,"consumed":prior}
