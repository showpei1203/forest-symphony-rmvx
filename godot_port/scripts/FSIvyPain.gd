extends RefCounted
class_name FSIvyPain

# Source-specific subset of ALBERT_MECHANIC_EXPANSION Game_Battler
# execute_damage alias. Original RGSS2 219630-220260, Phase46A/B2:
# Actor#5 actual Cover HP loss * source highest rate (default100%)
# OR direct HP loss (default50%, State85=>100%), with cap200% MaxHP.
# Higher <store_cover_damage:N>, <store_direct_damage:N>,
# <cover_store_cap_percent:N> tags are read from a source-verified list.
# This is NOT an arbitrary revenge gauge and does NOT consume Skill147.
var active: bool=false
var errors: Array[String]=[]
var events: Array[Dictionary]=[]

func _fail(reason: String) -> Dictionary:
    if not errors.has(reason):
        errors.append(reason)
    return {"ok":false,"reason":reason}

func _source_rate(notes: Array,tag: String,default_rate: float) -> Dictionary:
    # Original source uses .scan over source_text then values.max.
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*"+tag+"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)\\s*>")!=OK:
        return _fail("艾薇蓄痛來源標籤解析器錯誤："+tag)
    var highest: float=default_rate
    for note in notes:
        if not (note is String):
            return _fail("來源 Notes 陣列含非字串項目")
        for result in rx.search_all(str(note)):
            var rate: float=float(result.get_string(1))
            if not is_finite(rate) or rate<0.0 or rate>10000.0:
                return _fail("原版蓄痛 Rate 超出可驗證範圍")
            highest=maxf(highest,rate)
    return {"ok":true,"rate":highest}

func quote(battle,attacker: Dictionary,target: Dictionary,
        proposed_hit: Dictionary,as_cover: bool=false) -> Dictionary:
    if not active or int(target.get("id",0))!=5 or not bool(
            target.get("actor",false)) or bool(attacker.get("actor",true)):
        return {"ok":true,"applicable":false}
    # Not a generic Note parser. The exact merged original source_text
    # must come from verified Profile + Actor + all Equipment + States.
    if not bool(target.get("fs_ivy_pain_notes_verified",false)) or not (
            target.get("fs_ivy_effective_notes",null) is Array):
        return _fail("艾薇痛苦蓄積缺少 post-Apply 有效 Profile/裝備/State Notes")
    var notes: Array=target["fs_ivy_effective_notes"]
    var maxhp: int=int(target.get("maxhp",0))
    if maxhp<=0:
        return _fail("原始 Ivy MaxHP 不可驗證")
    if 85 in target.get("states",[]) and not bool(
            target.get("fs_ivy_furnace_state_verified",false)):
        return _fail("State85 痛苦熔爐狀態來源未驗證")
    # For stored cover damage the source sees the ACTUAL HP difference
    # after Ivy's Fatal Cover rescue and after other shield reductions.
    var loss: int=mini(maxi(0,int(proposed_hit.get("hp",0))),
        maxi(0,int(target.get("hp",0))))
    var cap_value: Dictionary=_source_rate(notes,"cover_store_cap_percent",200.0)
    if not bool(cap_value.get("ok",false)):
        return cap_value
    # Source stores a maximum Note percentage, default cap200%.
    var cap: int=int(float(maxhp)*float(cap_value["rate"])/100.0)
    var rate_value: Dictionary={}
    if as_cover:
        rate_value=_source_rate(notes,"store_cover_damage",100.0)
    else:
        var base: float=100.0 if (85 in target.get("states",[])) else 50.0
        rate_value=_source_rate(notes,"store_direct_damage",base)
    if not bool(rate_value.get("ok",false)):
        return rate_value
    var old: int=maxi(0,int(target.get("fs_ivy_stored_pain",0)))
    if cap>0:
        old=mini(old,cap)
    var gain: int=int(float(loss)*float(rate_value["rate"])/100.0)
    var next: int=old+gain
    if cap>0:
        next=mini(next,cap)
    return {"ok":true,"applicable":true,"before_hp":int(
        target.get("hp",0)),"loss":loss,"old":old,"new":next,
        "gain":next-old,"cap":cap,"rate":float(rate_value["rate"]),
        "cover":as_cover}

func commit(target: Dictionary,quote_data: Dictionary) -> Dictionary:
    if not bool(quote_data.get("ok",false)):
        return _fail("無效的蓄痛 Quote 不可提交")
    if not bool(quote_data.get("applicable",false)):
        return {"ok":true,"applicable":false}
    var observed_loss: int=maxi(0,int(quote_data["before_hp"])-
        int(target.get("hp",0)))
    if observed_loss!=int(quote_data["loss"]):
        return _fail("蓄痛 Quote 與實際受傷 HP 差值不一致")
    target["fs_ivy_stored_pain"]=int(quote_data["new"])
    events.append({"actual_loss":observed_loss,
        "cover":bool(quote_data["cover"]),
        "stored":int(quote_data["new"]),"gain":int(quote_data["gain"]),
        "rate":float(quote_data["rate"]),"cap":int(quote_data["cap"])})
    return {"ok":true,"stored":int(quote_data["new"]),
        "gain":int(quote_data["gain"])}
