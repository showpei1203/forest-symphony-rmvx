extends RefCounted
class_name FSOriginalBattleInfo381

# Real ORIGINAL FS Scripts.rvdata #381 AlbertBattleStateHUD.extra_info_rows
# lines 686..896, original order: ManaShield/ATBResist/IvyStoredCover/
# Break/DynamicStateResist/RobotProtocol/TargetPriority.
# Only quote values from a *verified* Godot battle provider, or from
# source RPG::State / Enemy.note + live source state stacks.
# Missing provider means NO ROW, never a fabricated game statistic.
const SOURCE_SCRIPT:int=381
const BREAK_PROGRESS_STATE_ID:int=50 # original #376 ALBERT_CHARACTER_CORE
const SOURCE_MAX_ROWS:int=6
const SOURCE_ATB_RATES:Array[int]=[100,70,45,25,10]
const BOSS_SHIELD_ID:int=77

static func _num(value:Variant)->bool:
    return value is int or value is float

static func _note_number(note:String,tag:String)->Dictionary:
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*"+tag+"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)\\s*>")!=OK:
        return {}
    var m:RegExMatch=rx.search(note)
    if m==null:return {}
    return {"value":float(m.get_string(1))}

static func _note_has(note:String,tag:String)->bool:
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*"+tag+"\\s*>")!=OK:return false
    return rx.search(note)!=null

static func _live_state(battler:Dictionary,id:int)->bool:
    return battler.get("states",null) is Array and (
        battler["states"].has(id))

static func _source_mana_shield(battler:Dictionary,db:FSDatabase)->Array:
    var out:Array=[]
    if not battler.has("fs_boss_shield_remaining") or (
            not _num(battler["fs_boss_shield_remaining"])) or int(
            battler["fs_boss_shield_remaining"])<=0:
        return out
    # #381 requires state.albert_mana_shield_data and active State.
    if not _live_state(battler,BOSS_SHIELD_ID):
        return out
    var state:Dictionary=db.record("states",BOSS_SHIELD_ID)
    if not str(state.get("note","")).to_lower().contains("<mana_shield "):
        return out
    var name:String=str(state.get("name","Mana Shield"))
    var meta:Dictionary=FSBattleSourceStateHUD381.source_metadata(state)
    if not meta.is_empty() and not str(meta.get("name","")).is_empty():
        name=str(meta["name"])
    out.append({"label":name,"value":"剩餘%d" % int(
        battler["fs_boss_shield_remaining"]),"source":"#381 ManaShield"})
    return out

static func _atb_resist(battler:Dictionary)->Array:
    var out:Array=[]
    if bool(battler.get("actor",false)) or not bool(
            battler.get("atb_resist_enabled",false)):
        return out
    if not _note_has(str(battler.get("note","")),"atb_dynamic_resist"):
        return out
    for key in ["atb_resist_level","atb_resist_max","atb_resist_floor"]:
        if not battler.has(key) or not _num(battler[key]):
            return out
    var level:int=int(battler["atb_resist_level"])
    var maximum:int=int(battler["atb_resist_max"])
    var floor_percent:int=int(battler["atb_resist_floor"])
    if maximum<0 or maximum>4 or level<0 or level>maximum or (
            floor_percent<0 or floor_percent>100):
        return out
    out.append({"label":"ATB延遲抗性","value":"Lv%d/%d　承受%d%%　下限%d%%" % [
        level,maximum,SOURCE_ATB_RATES[level],floor_percent],
        "source":"#377/#381 live ATBResistance"})
    return out

static func _ivy_stored_cover(battler:Dictionary)->Array:
    var out:Array=[]
    # Original Ruby #381 needs albert_cc_ivy? and
    # albert_mx_stored_cover_damage. This is NOT fs_ivy_stored_pain.
    if not bool(battler.get("actor",false)) or int(
            battler.get("id",0))!=5 or not bool(battler.get(
            "fs_ivy_cover_store_source_verified",false)) or (
            not _num(battler.get("fs_ivy_stored_cover_damage",null))):
        return out
    var stored:int=int(battler["fs_ivy_stored_cover_damage"])
    if stored<0:return out
    var text:String=str(stored)
    if _num(battler.get("fs_ivy_cover_store_cap_percent",null)) and (
            _num(battler.get("maxhp",null))):
        var cap:float=float(battler["fs_ivy_cover_store_cap_percent"])
        if cap>0.0 and cap<=100.0:
            text+=" / "+str(int(float(battler["maxhp"])*cap/100.0))
    out.append({"label":"蓄痛","value":text,
        "source":"#381 Ivy stored COVER (verified-only)"})
    return out

static func _break(battler:Dictionary,db:FSDatabase)->Array:
    var out:Array=[]
    if bool(battler.get("actor",false)) or int(
            battler.get("id",0))<=0:return out
    var note:String=str(battler.get("note",""))
    var threshold:Dictionary=_note_number(note,"break_threshold")
    var resist:Dictionary=_note_number(note,"break_resist")
    var immune:bool=_note_has(note,"break_immune")
    var recover:int=0
    if _num(battler.get("fs_break_recover_amount",null)):
        recover=maxi(0,int(battler["fs_break_recover_amount"]))
    var current:int=0
    if _live_state(battler,BREAK_PROGRESS_STATE_ID):
        var record:Dictionary=db.record("states",BREAK_PROGRESS_STATE_ID)
        if int(record.get("id",0))==BREAK_PROGRESS_STATE_ID:
            current=FSBattleSourceStateHUD381.source_stack(battler,record)
    # Source #381 line 774/776: never quote a 0/threshold progress as
    # an actual underway Break; self-contained immunity may be shown.
    if current<=0 and threshold.is_empty():return out if not immune and (
        resist.is_empty() and recover<=0) else _break_only_immunity(immune,resist,recover)
    if current<=0 and not threshold.is_empty():return out
    var parts:Array[String]=[]
    if not threshold.is_empty():
        parts.append("進度%d/%d" % [current,int(threshold["value"])])
    elif current>0:
        parts.append("進度%d" % current)
    if immune:
        parts.append("免疫")
    elif not resist.is_empty():
        parts.append("抗性%d%%" % int(resist["value"]))
    if recover>0:parts.append("行動後-%d" % recover)
    if not parts.is_empty():
        out.append({"label":"破勢","value":"　".join(PackedStringArray(parts)),
            "source":"#376/#381 State50 + Enemy.note"})
    return out

static func _break_only_immunity(immune:bool,resist:Dictionary,
        recover:int)->Array:
    var parts:Array[String]=[]
    if immune:parts.append("免疫")
    elif not resist.is_empty():parts.append("抗性%d%%" % int(resist["value"]))
    if recover>0:parts.append("行動後-%d" % recover)
    if parts.is_empty():return []
    return [{"label":"破勢","value":"　".join(PackedStringArray(parts)),
        "source":"#381 Enemy.note, no progress fabricated"}]

static func _dynamic_state_resist(battler:Dictionary,db:FSDatabase)->Array:
    if bool(battler.get("actor",false)) or not bool(battler.get(
            "fs_state_resist_source_verified",false)):return []
    var levels:Variant=battler.get("fs_state_resist_levels",null)
    var rates:Variant=battler.get("fs_state_resist_rates",null)
    if not (levels is Dictionary and rates is Dictionary):return []
    var sorted_ids:Array=levels.keys()
    sorted_ids.sort()
    var parts:Array[String]=[]
    for key in sorted_ids:
        if not str(key).is_valid_int() or not _num(levels[key]):return []
        var state_id:int=int(str(key))
        if int(levels[key])<=0:continue
        var state:Dictionary=db.record("states",state_id)
        if int(state.get("id",0))!=state_id:return []
        var rate:Variant=rates.get(state_id,rates.get(str(state_id),null))
        if not _num(rate) or int(rate)<0 or int(rate)>100:return []
        parts.append("%s%d%%" % [str(state.get("name","")),int(rate)])
    if parts.is_empty():return []
    return [{"label":"異常抗性","value":"　".join(PackedStringArray(parts)),
        "source":"#381 verified dynamic state resist provider"}]

static func _robot_protocol(battler:Dictionary,db:FSDatabase)->Array:
    if not bool(battler.get("actor",false)) or not bool(battler.get(
            "fs_robot_protocol_source_verified",false)):
        return []
    var data:Variant=battler.get("fs_robot_protocol_data",null)
    var count:Variant=battler.get("fs_robot_protocol_count",null)
    if not (data is Array) or data.size()<3 or not _num(count):
        return []
    var skill_id:int=int(data[0])
    var interval:int=maxi(1,int(data[1]))
    var conditionals:Variant=data[2]
    if not (conditionals is Array):return []
    var phase:int=maxi(0,int(count))%interval
    var remain:int=interval if phase==0 else interval-phase
    var parts:Array[String]=["%d次行動後" % remain]
    if skill_id>0:
        var skill:Dictionary=db.record("skills",skill_id)
        if int(skill.get("id",0))!=skill_id:return []
        parts.append(str(skill.get("name","")))
    if not conditionals.is_empty():
        parts.append("條件%d組" % conditionals.size())
    return [{"label":"協議","value":"　".join(PackedStringArray(parts)),
        "source":"#381 verified Robot Protocol"}]

static func _target_priority(battler:Dictionary,db:FSDatabase)->Array:
    if bool(battler.get("actor",false)):return []
    var verified:Dictionary=FSTargetPriority._enemy_priority(battler,db)
    if not bool(verified.get("ok",false)):return []
    var priority:int=int(verified.get("priority",0))
    if priority<=0:return []
    return [{"label":"目標優先","value":str(priority),
        "source":"#372/#381 source target priority"}]

static func extra_info_rows(battler:Dictionary,db:FSDatabase)->Dictionary:
    if db==null or not (battler.get("states",null) is Array):
        return {"ok":false,"rows":[],"reason":"Original battler State IDs missing"}
    var states:Array=battler["states"]
    for state_id in states:
        if not (state_id is int or state_id is float):return {
            "ok":false,"rows":[],"reason":"Non-numeric original State ID"}
        if db.record("states",int(state_id)).is_empty():return {
            "ok":false,"rows":[],"reason":"Unknown original State ID"}
    var rows:Array[Dictionary]=[]
    # Preserve exact Ruby #381 line 869..875 order; never present
    # an unsupported subsystem as if its original source values exist.
    rows.append_array(_source_mana_shield(battler,db))
    rows.append_array(_atb_resist(battler))
    rows.append_array(_ivy_stored_cover(battler))
    rows.append_array(_break(battler,db))
    rows.append_array(_dynamic_state_resist(battler,db))
    rows.append_array(_robot_protocol(battler,db))
    rows.append_array(_target_priority(battler,db))
    return {"ok":true,"rows":rows,"reason":""}
