extends RefCounted
class_name FSIvyFurnaceRuntime

# Source-restricted Game_Battler#add_state & remove_states_auto:
# RGSS2 ~3461-3530 and 3650-3670; Tankentai Sprite_ATB.atb ~131389.
# Original MasterSetup Skill145: self scope11, MP16, State85+State100.
# Original MasterSetup State85: hold4, release100, neutral stats,
# cover pain150%/cap300%; raw VX State100: blank/hold0/release0.
# The raw State100 is ALSO referred to by Aizhuo overload; do not
# invent what its post-Apply original runtime does. Only a clean,
# synthetic, explicitly verified Skill145 fixture may opt into this
# bounded ACT (real full JP/charge/recharge/pop Note stays refused).
# OFF by default; production requires real post-Apply 11-table data
# and separate Skill145/100 witness before activation.
const IVY_ID:int=5
const SKILL_ID:int=145
const FURNACE_ID:int=85
const SHARED_STATE_ID:int=100
const HOLD:int=4
var active:bool=false
var errors:Array[String]=[]
var events:Array[Dictionary]=[]

func _fail(message:String)->Dictionary:
    if not errors.has(message):
        errors.append(message)
    return {"ok":false,"reason":message}

func _verified_record(battle,id:int)->Dictionary:
    var s:Dictionary=battle.db.record("states",id)
    if int(s.get("id",0))!=id:
        return {}
    for field in ["hold_turn","auto_release_prob","atk_rate","def_rate",
            "spi_rate","agi_rate","restriction","release_by_damage",
            "battle_only","reduce_hit_ratio","slip_damage",
            "nonresistance","offset_by_opposite","state_set","note"]:
        if not s.has(field):
            return {}
    if int(s["restriction"])!=0 or bool(s["release_by_damage"]) or (
            not bool(s["battle_only"])) or bool(s["reduce_hit_ratio"]) or (
            bool(s["slip_damage"])) or not (s["state_set"] is Array) or (
            not s["state_set"].is_empty()):
        return {}
    for stat in ["atk","def","spi","agi"]:
        if int(s[stat+"_rate"])!=100:
            return {}
    if id==FURNACE_ID:
        if int(s["hold_turn"])!=HOLD or int(
                s["auto_release_prob"])!=100 or bool(
                s["nonresistance"]) or bool(s["offset_by_opposite"]):
            return {}
        var note:String=str(s["note"]).replace("\r","").strip_edges()
        var expected:String="<store_cover_damage:150>\n<cover_store_cap_percent:300>\n<hud_priority:290>\n<hud_detail>"
        if note!=expected:
            return {}
    elif id==SHARED_STATE_ID:
        # This is the ACTUAL RAW VX snapshot, not an assertion that
        # FS_DB_AUTOSET never changes State100 at title load.
        if int(s["hold_turn"])!=0 or int(
                s["auto_release_prob"])!=0 or not str(
                s["note"]).strip_edges().is_empty():
            return {}
    else:
        return {}
    return s

func preview(battle,user:Dictionary,skill:Dictionary)->Dictionary:
    if not active or int(skill.get("id",0))!=SKILL_ID:
        return {"ok":false,"reason":"原版145 State85/100 子集合尚未啟用"}
    if not battle.party.has(user) or not bool(
            user.get("actor",false)) or int(user.get("id",0))!=IVY_ID:
        return _fail("痛苦熔爐僅可由艾薇 Actor5 對自己使用")
    if not (SKILL_ID in user.get("skills",[])):
        return _fail("艾薇未習得原版145")
    if not bool(skill.get("fs_ivy_furnace_source_verified",false)) or (
            not bool(user.get("fs_ivy_furnace_source_verified",false))):
        return _fail("原版145 及 State85/100 有效來源未驗證")
    # Synthetic source-shape fixtures need an explicit fixture marker.
    # Merely having a bool "verified" MUST NOT unlock production.
    if not (battle.db.boot_final_verified and bool(
            skill.get("fs_furnace_private_runtime_verified",false))):
        if not (bool(skill.get("fs_furnace_fixture_only",false)) and (
                battle.ivy_pain_source.fixture_only)):
            return _fail("State100 未具 post-Apply runtime witness")
    # The entire real Skill145 Note has JP/charge/cooldown/pop tags.
    # A clean fixture may test only the source's MP/state subset;
    # no ignored tag can masquerade as successful full migration.
    if not str(skill.get("note","")).strip_edges().is_empty():
        return _fail("原版完整145 JP/charge/recharge 未實作，禁止跳過")
    if int(skill.get("scope",0))!=11 or int(
            skill.get("base_damage",-1))!=0 or int(
            skill.get("atk_f",-1))!=0 or int(
            skill.get("spi_f",-1))!=0 or int(
            skill.get("mp_cost",-1))!=16 or int(
            skill.get("hit",-1))!=100 or bool(
            skill.get("physical_attack",true)) or bool(
            skill.get("damage_to_mp",true)) or bool(
            skill.get("absorb_damage",true)) or bool(
            skill.get("ignore_defense",true)):
        return _fail("145 的原版自我施放、MP16及零傷害規格不一致")
    if skill.get("element_set",[])!=[13,7] or (
            skill.get("plus_state_set",[])!=[FURNACE_ID,SHARED_STATE_ID]) or (
            not skill.get("minus_state_set",[]).is_empty()):
        return _fail("145 必須同時附加 State85 與 State100")
    var furnace:Dictionary=_verified_record(battle,FURNACE_ID)
    var shared:Dictionary=_verified_record(battle,SHARED_STATE_ID)
    if furnace.is_empty() or shared.is_empty():
        return _fail("State85 正式值或原始100效果/期限不完整")
    if not user.get("states",[]) is Array or not (
            user.get("equipment",null) is Array):
        return _fail("艾薇目前 State/裝備來源缺失")
    for existing in user.get("states",[]):
        if int(existing) not in [FURNACE_ID,SHARED_STATE_ID]:
            return _fail("145 原版對其他並存狀態的優先權尚未驗證")
    if int(user.get("hp",0))<=0 or int(user.get("mp",0))<16:
        return _fail("145 使用者已死亡或 MP 不足")
    # Do not apply a state that cannot feed the live effective-Note
    # provider. This quote is pure: probe is a deep copy, not a mutating
    # temporary change to the real actor or global source.
    if not battle.ivy_pain_source.active:
        return _fail("145 的 ActorProfile/Equip/State 有效 Note 未啟用")
    var hypothetical:Dictionary=user.duplicate(true)
    var future:Array=hypothetical["states"].duplicate()
    if not future.has(FURNACE_ID):
        future.append(FURNACE_ID)
    if not future.has(SHARED_STATE_ID):
        future.append(SHARED_STATE_ID)
    hypothetical["states"]=future
    var source:Dictionary=battle.ivy_pain_source.build(battle.db,hypothetical)
    if not bool(source.get("ok",false)) or not bool(
            source.get("furnace_verified",false)):
        return _fail("新 State85/100 的來源 Notes 不可驗證")
    var timers:Variant=user.get("fs_ivy_furnace_state_turns",{})
    if not (timers is Dictionary):
        return _fail("原版狀態計數器無效")
    if future.has(FURNACE_ID) and user.get("states",[]).has(FURNACE_ID) and (
            not timers.has(str(FURNACE_ID))):
        return _fail("State85 已存在但原始 hold_turn 追蹤不明")
    return {"ok":true,"states":future,"cost":16,
        "furnace_turns":HOLD,"state100_turns":0,
        "notes":source["notes"].duplicate(true)}

func apply(battle,user:Dictionary,skill:Dictionary,quote_data:Dictionary)->Dictionary:
    if not bool(quote_data.get("ok",false)):
        return _fail("145 不能提交無效 ACT")
    # Revalidate immediately before MP payment and state commit.
    var ready:Dictionary=preview(battle,user,skill)
    if not bool(ready.get("ok",false)):
        return ready
    user["mp"]=int(user["mp"])-int(ready["cost"])
    var was:Array=user["states"].duplicate()
    user["states"]=ready["states"].duplicate()
    var timers:Dictionary=user.get("fs_ivy_furnace_state_turns",{}).duplicate()
    timers[str(FURNACE_ID)]=HOLD
    timers[str(SHARED_STATE_ID)]=0
    user["fs_ivy_furnace_state_turns"]=timers
    user["fs_ivy_effective_notes"]=ready["notes"].duplicate(true)
    user["fs_ivy_pain_notes_verified"]=true
    user["fs_ivy_furnace_state_verified"]=true
    user["fs_ivy_furnace_state_authority_pending"]=false
    events.append({"op":"apply_at_act","actor":IVY_ID,
        "from":was,"to":user["states"].duplicate(),"mp":16,
        "hold":HOLD,"state100":"raw_neutral_fixture"})
    return {"ok":true,"added_states":[FURNACE_ID,SHARED_STATE_ID],
        "spent_mp":16}

func on_atb_ready(battle)->int:
    if not active:
        return 0
    var removed:int=0
    for ivy in battle.party:
        if int(ivy.get("id",0))!=IVY_ID or not bool(
                ivy.get("actor",false)) or not bool(
                ivy.get("source_just_atb_ready",false)):
            continue
        # Atb-ready flags belong to the Tankentai source gauge edge.
        ivy.erase("source_just_atb_ready")
        var states:Array=ivy.get("states",[])
        var timers:Dictionary=ivy.get("fs_ivy_furnace_state_turns",{})
        if not states.has(FURNACE_ID):
            continue
        if not timers.has(str(FURNACE_ID)) or (
                _verified_record(battle,FURNACE_ID).is_empty()):
            ivy["fs_ivy_furnace_state_authority_pending"]=true
            _fail("State85 存活期間來源/ATB 計數器失效")
            continue
        var remaining:int=int(timers[str(FURNACE_ID)])
        if remaining>0:
            timers[str(FURNACE_ID)]=remaining-1
            ivy["fs_ivy_furnace_state_turns"]=timers
            events.append({"op":"count_atb_ready","from":remaining,
                "to":remaining-1,"state":FURNACE_ID})
            continue
        # Original state85 auto_release_prob=100; only AFTER reaching
        # 0 on an earlier ready edge does the NEXT edge erase it.
        var future:Array=states.duplicate()
        future.erase(FURNACE_ID)
        var hypothetical:Dictionary=ivy.duplicate(true)
        hypothetical["states"]=future
        if not battle.ivy_pain_source.active:
            ivy["fs_ivy_furnace_state_authority_pending"]=true
            _fail("State85 解除後必須刷新 CharacterCore source")
            continue
        var rebuilt:Dictionary=battle.ivy_pain_source.build(
            battle.db,hypothetical)
        if not bool(rebuilt.get("ok",false)):
            ivy["fs_ivy_furnace_state_authority_pending"]=true
            _fail("State85 解除後 State100/裝備 Note 不可驗證")
            continue
        ivy["states"]=future
        timers.erase(str(FURNACE_ID))
        ivy["fs_ivy_furnace_state_turns"]=timers
        ivy["fs_ivy_effective_notes"]=rebuilt["notes"].duplicate(true)
        ivy["fs_ivy_pain_notes_verified"]=true
        ivy["fs_ivy_furnace_state_verified"]=false
        ivy["fs_ivy_furnace_state_authority_pending"]=false
        removed+=1
        events.append({"op":"auto_release_atb_ready",
            "state":FURNACE_ID,"removed_after_ready":5,
            "remaining_states":future.duplicate()})
    return removed
