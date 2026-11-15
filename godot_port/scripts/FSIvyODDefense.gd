extends RefCounted
class_name FSIvyODDefense

# Source-only ComboCore OD reduction ~211185-211355 and BattleV22 ~253525.
# Notes: equipment and live States plus learned passive Skill142, not the
# ActorProfile tag_text entry. One-battle Ivy original max OD is required.
# Original try_redirect ~248198 grants +6% OD BEFORE guard power recompute,
# hence pending_main_cover previews that increase before source mitigation.
# Production OFF until private post-Apply tables/505 final aliases certified.
# Exact FS_BATTLE_V22.PASSIVE_NAMES also recognizes the old 774..828
# skill IDs by name, even if the source skill lacks mechanic_passive.
const PASSIVE_NAMES:Dictionary={
    102:"共鳴感知",106:"和聲領袖",
    112:"溢光回路",116:"大地祝福",
    122:"靜電回收",126:"超頻神經",
    132:"毒理學",136:"病灶連鎖",
    142:"怒意不熄",146:"替身承擔",
    152:"鬥志打磨",156:"破城者",
    774:"共鳴感知",778:"和聲領袖",
    784:"溢光回路",788:"大地祝福",
    794:"靜電回收",798:"超頻神經",
    804:"毒理學",808:"病灶連鎖",
    814:"怒意不熄",818:"替身承擔",
    824:"鬥志打磨",828:"破城者"
}
var active: bool=false
var errors: Array[String]=[]
var events: Array[Dictionary]=[]

func _fail(why:String)->Dictionary:
    if not errors.has(why):
        errors.append(why)
    return {"ok":false,"reason":why}

func _passive_notes(battle,ivy:Dictionary)->Dictionary:
    var ids:Variant=ivy.get("skills",null)
    if not (ids is Array):
        return _fail("原版已學技能列表型別無法證明")
    var values:Array[String]=[]
    for skill_id in ids:
        var id:int=int(skill_id)
        if id<=0:
            return _fail("已學技能 ID 不合法")
        var skill:Dictionary=battle.db.record("skills",id)
        if skill.is_empty() or not (skill.get("note",null) is String):
            return _fail("已學 Skill%d 缺原版 post-Apply Note" % id)
        var name:String=str(skill.get("name",""))
        var note:String=str(skill["note"])
        if id in [142,814] and name!="怒意不熄":
            return _fail("艾薇減傷被動 Skill%d 名稱與 FS_BATTLE_V22 不符" % id)
        var passive:bool=note.to_lower().contains(
            "<mechanic_passive>") or bool(skill.get("passive",false)) or (
            str(PASSIVE_NAMES.get(id,""))==name and not name.is_empty())
        if id==142 and name=="怒意不熄":
            # The formal NEW Skill142 Source is exact. Legacy Skill814
            # has no guaranteed post-Apply Note mirror; only parse its
            # ACTUAL verified database Note without inventing tags.
            if not note.contains("<reduce_damage_if_od 50:12>") or not (
                    note.contains("<reduce_damage_per_od_percent:0.08>")):
                return _fail("原版 Skill142 OD 條件12%+累計0.08% Note 不符")
        if passive:
            values.append(note)
    return {"ok":true,"notes":values}

func _parse_notes(notes:Array[String])->Dictionary:
    var text_value:String="\n".join(notes)
    var conditional:=RegEx.new()
    var continuous:=RegEx.new()
    if conditional.compile("(?i)<\\s*reduce_damage_if_od\\s+([0-9]+(?:\\.[0-9]+)?)\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)\\s*>")!=OK or (
            continuous.compile("(?i)<\\s*reduce_damage_per_od_percent\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)\\s*>")!=OK):
        return _fail("原版 ComboCore OD 標籤解析器錯誤")
    var requirements:Array[Dictionary]=[]
    var per:Array[float]=[]
    for m in conditional.search_all(text_value):
        requirements.append({"need":float(m.get_string(1)),
            "reduce":float(m.get_string(2))})
        text_value=text_value.replace(m.get_string(0),"")
    for m in continuous.search_all(text_value):
        per.append(float(m.get_string(1)))
        text_value=text_value.replace(m.get_string(0),"")
    var leftover:String=text_value.to_lower()
    if leftover.contains("<reduce_damage_if_od") or leftover.contains(
            "<reduce_damage_per_od_percent"):
        return _fail("存在格式不合法、未移植的 OD 減傷 Note")
    return {"ok":true,"conditional":requirements,"continuous":per}

func quote(battle,target:Dictionary,positive_hp:int,
        pending_main_cover:bool=false)->Dictionary:
    if not active or int(target.get("id",0))!=5 or not bool(
            target.get("actor",false)) or positive_hp<=0:
        return {"ok":true,"applicable":false,"hp":positive_hp}
    if not bool(target.get("fs_ivy_od_source_verified",false)) or not bool(
            target.get("fs_ivy_pain_notes_verified",false)) or not (
            target.get("fs_ivy_effective_notes",null) is Array):
        return _fail("艾薇 OD/角色有效裝備與 State Note 來源未證明")
    var effective:Array=target["fs_ivy_effective_notes"]
    if effective.is_empty() or not (effective[0] is String):
        return _fail("Actor Profile.tag_text 來源尚未驗證")
    # ComboCore reads equipment + States + passive Note, NOT ActorProfile.
    var notes:Array[String]=[]
    for index in range(1,effective.size()):
        if not (effective[index] is String):
            return _fail("艾薇裝備/狀態有效 Notes 含非字串")
        notes.append(effective[index])
    var passives:Dictionary=_passive_notes(battle,target)
    if not bool(passives.get("ok",false)):
        return passives
    if bool(target.get("fs_ivy_effective_notes_have_passives",false)):
        # A refreshed final CharacterCore provider already appended ALL
        # passive skill Notes. Do not add Skill142 a SECOND TIME; that
        # would turn the actual OD50 16% reduction into a false32%.
        for note in passives["notes"]:
            var found:bool=false
            for source_note in effective:
                if str(source_note).begins_with(str(note)):
                    found=true
                    break
            if not found:
                return _fail("Skill142 被動 Note 已變更，需刷新 CharacterCore 來源")
    else:
        # Backward-compatible standalone source fixtures keep their
        # manual equipment/State notes plus separately verified passives.
        for note in passives["notes"]:
            notes.append(str(note))
    var parsed:Dictionary=_parse_notes(notes)
    if not bool(parsed.get("ok",false)):
        return parsed
    if not target.has("max_od") or not target.has("od"):
        return _fail("原版艾薇 OD 與最大 OD 權威缺失")
    var max_od:int=int(target["max_od"])
    var od:int=int(target["od"])
    if max_od<=0 or od<0 or od>max_od:
        return _fail("艾薇 OD/max_od 比率超出原版安全來源範圍")
    var pending_gain:int=0
    if pending_main_cover:
        pending_gain=roundi(float(max_od)*0.06)
        od=mini(max_od,od+pending_gain)
    var od_rate:float=float(od)*100.0/float(max_od)
    var reduction:float=0.0
    for entry in parsed["conditional"]:
        if od_rate>=float(entry["need"]):
            reduction+=float(entry["reduce"])
    for per in parsed["continuous"]:
        reduction+=od_rate*float(per)
    reduction=clampf(reduction,0.0,90.0)
    # Original Ruby .to_i truncates positive fractional damage.
    var adjusted:int=int(float(positive_hp)*(100.0-reduction)/100.0)
    return {"ok":true,"applicable":true,"hp":adjusted,
        "raw":positive_hp,"od_rate":od_rate,"reduction":reduction,
        "pending_cover_bonus":pending_gain}

func record(quote_data:Dictionary)->void:
    if not bool(quote_data.get("applicable",false)):
        return
    events.append({"raw":int(quote_data["raw"]),
        "hp":int(quote_data["hp"]),
        "rate":float(quote_data["od_rate"]),
        "reduce":float(quote_data["reduction"]),
        "pending_cover":int(quote_data["pending_cover_bonus"])})
