extends SceneTree

# FOREST SYMPHONY Phase530: source-limited Godot Ivy145 skill self ACT,
# original two State IDs (85+100), MP16 and source 85 auto expiry.
# RGSS2 Game_Battler.add_state/rem_states_auto ~3450/3659; Tankentai
# Sprite_ATB.atb ~131390: READY 4->3->2->1->0, 5th READY removes.
# Original full Skill145 JP/charge/ricarica remains FAIL CLOSED.
# Raw State100 is shared with Aizhuo overload, NOT private runtime proof.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,why:String)->bool:
    if not ok:
        push_error("FS Ivy145 State85/100 Phase530 native FAIL: "+why)
        quit(1)
        return false
    return true

func _state(id:int)->Dictionary:
    var furnace:bool=id==85
    return {"id":id,"name":"痛苦熔爐" if furnace else "",
        "priority":290 if furnace else 5,
        "hold_turn":4 if furnace else 0,
        "auto_release_prob":100 if furnace else 0,
        "restriction":0,"release_by_damage":false,"battle_only":true,
        "atk_rate":100,"def_rate":100,"spi_rate":100,"agi_rate":100,
        "nonresistance":false,"offset_by_opposite":false,
        "reduce_hit_ratio":false,"slip_damage":false,"state_set":[],
        "note":"<store_cover_damage:150>\n<cover_store_cap_percent:300>\n<hud_priority:290>\n<hud_detail>" if furnace else ""}

func _skill()->Dictionary:
    return {"id":145,"name":"痛苦熔爐｜來源限定",
        "scope":11,"occasion":1,"base_damage":0,"variance":0,
        "atk_f":0,"spi_f":0,"mp_cost":16,"hit":100,
        "physical_attack":false,"damage_to_mp":false,
        "absorb_damage":false,"ignore_defense":false,
        "element_set":[13,7],"plus_state_set":[85,100],
        "minus_state_set":[],"note":"",
        "fs_ivy_furnace_source_verified":true,
        "fs_furnace_fixture_only":true}

func _actor(id:int,name:String,defense:int)->Dictionary:
    return {"id":id,"name":name,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,
        "atk":50,"def":defense,"spi":10,"agi":20,"hit":95,
        "eva":5,"cri":10,"od":0,"skills":[145] if id==5 else [],
        "states":[],"equipment":[0,0,0,0,0],
        "element_set":[],"note":"",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true,
        "fs_ivy_furnace_source_verified":id==5}

func _battle()->FSBattle:
    var db=DB.new()
    var states:Array=[]
    states.resize(101)
    states[85]=_state(85)
    states[100]=_state(100)
    var skills:Array=[]
    skills.resize(146)
    skills[145]=_skill()
    db.tables={"states":states,"skills":skills,
        "weapons":[null],"armors":[null],
        "enemies":[null,{"id":1,"name":"Source Enemy",
            "maxhp":9000,"maxmp":100,"atk":50,"def":10,
            "spi":10,"agi":20,"hit":95,"eva":5,
            "has_critical":false,"actions":[],"note":""}]}
    var b=BATTLE.new(db)
    b.party.append(_actor(5,"Ivy",20))
    b.party.append(_actor(1,"Friend",10))
    b.add_enemy(1)
    var foe:Dictionary=b.enemies[0]
    foe["level"]=1
    foe["element_set"]=[]
    foe["fs_normal_source_verified"]=true
    foe["fs_normal_enemy_note_verified"]=true
    foe["fs_normal_element_neutral_verified"]=true
    b.normal_core.active=true
    b.accuracy.active=true
    b.ivy_pain.active=true
    b.ivy_furnace.active=true
    var src:Dictionary=b.ivy_pain_source.configure_fixture({
        "source":"ALBERT_CHARACTER_CORE_TAG_TEXT_v1",
        "actor_profile_tag_text":{"5":""}})
    if not bool(src.get("ok",false)):
        push_error("Ivy145 source profile fixture unavailable")
    b.source_atb_rolls_for_test={
        "actor:0":0,"actor:1":0,"enemy:0":0}
    return b

func _enemy_hit(b:FSBattle)->void:
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]

func _ready(b:FSBattle,ivy:Dictionary)->bool:
    ivy["source_atb_count"]=999
    ivy["source_atb_count_up"]=true
    ivy["source_at_active"]=false
    ivy["source_act_active"]=false
    b.advance_atb(1.0/60.0)
    return bool(ivy.get("source_at_active",false))

func _run()->void:
    var b:FSBattle=_battle()
    if not _check(b.start(),"real Godot start with original source states"):return
    var ivy:Dictionary=b.party[0]
    var ally:Dictionary=b.party[1]
    var enemy:Dictionary=b.enemies[0]
    ivy["source_atb_count"]=1000
    ivy["source_at_active"]=true
    ivy["source_atb_count_up"]=false
    b.accuracy.scripted_rolls=[0,99,0,99]
    if not _check(b.skill_preflight(ivy,ivy,145) and int(
            ivy["mp"])==100 and ivy["states"].is_empty() and
            b.accuracy.scripted_rolls==[0,99,0,99],
            "clean 145 preflight pure before MP/RNG/State"):return
    if not _check(not b.skill_preflight(ivy,ally,145) and
            not b.queue_actor_action(0,"skill",1,145),
            "self-only 145 rejects selecting teammate"):return
    if not _check(b.queue_actor_action(0,"skill",0,145) and int(
            ivy["mp"])==100 and ivy["states"].is_empty(),
            "queued original Tankentai ACT145 has no premature effect"):return
    b.advance_atb(9.0/60.0)
    if not _check(b.has_actor_pending_action(0) and
            int(ivy["source_act_count"])==900 and int(
            ivy["mp"])==100 and ivy["states"].is_empty(),
            "Ivy145 first9 ACT frames keep state/MP unchanged"):return
    b.advance_atb(1.0/60.0)
    if not _check(b.action_queue.completed.size()==1 and bool(
            b.action_queue.completed[0]["success"]) and
            int(ivy["mp"])==84 and ivy["states"]==[85,100] and
            int(ivy["fs_ivy_furnace_state_turns"]["85"])==4 and
            int(ivy["source_atb_count"])==100 and
            bool(ivy["fs_ivy_furnace_state_verified"]) and
            ivy["fs_ivy_effective_notes"].size()==3,
            "ACT10 commits both State85+100, MP16 and source recharge10%"):return

    var screen=SCREEN.new()
    root.add_child(screen)
    screen.db=b.db
    screen.battle=b
    screen._refresh_battle_status()
    if not _check("痛苦熔爐：State85｜倒數 4" in screen.status_label.text,
            "Godot native battle HUD shows exact live State85 timer4"):return

    # Source direct pain: State85 raises default direct50% to100%,
    # while source State100 is neutral but deliberately still applied.
    _enemy_hit(b)
    var damage:int=b.attack(enemy,ivy)
    if not _check(damage==77 and int(ivy["hp"])==923 and
            int(ivy["fs_ivy_stored_pain"])==77 and
            b.ivy_pain.events.size()==1 and
            int(b.ivy_pain.events[-1]["cap"])==3000,
            "State85 source direct HP77 stores77 cap300%, real enemy hit"):return

    # No random expiry while command selection is frozen (ATB WAIT)
    # and never during arbitrary ACT charging or duplicate READY HUD.
    ivy["source_atb_count"]=999
    ivy["source_atb_count_up"]=true
    ivy["source_at_active"]=false
    b.source_atb_wait=true
    b.advance_atb(10.0/60.0)
    if not _check(int(ivy["source_atb_count"])==999 and
            int(ivy["fs_ivy_furnace_state_turns"]["85"])==4,
            "ATB WAIT does NOT age State85"):return
    b.source_atb_wait=false
    for tick in range(4):
        if not _check(_ready(b,ivy) and 85 in ivy["states"] and
                100 in ivy["states"] and int(
                ivy["fs_ivy_furnace_state_turns"]["85"])==3-tick,
                "State85 duration source READY decrements4->3->2->1->0"):return
        var unchanged:int=int(ivy["fs_ivy_furnace_state_turns"]["85"])
        b.advance_atb(1.0/60.0)
        if not _check(int(ivy["fs_ivy_furnace_state_turns"]["85"])==unchanged,
                "no duplicate State85 age on same READY gauge"):return
    if not _check(85 in ivy["states"] and
            int(ivy["fs_ivy_furnace_state_turns"]["85"])==0,
            "fourth READY leaves State85 attached with counter0"):return
    if not _check(_ready(b,ivy) and not (85 in ivy["states"]) and
            100 in ivy["states"] and not bool(
            ivy["fs_ivy_furnace_state_verified"]) and
            ivy["fs_ivy_effective_notes"].size()==2 and
            not ivy["fs_ivy_furnace_state_turns"].has("85") and
            not bool(ivy.get("fs_ivy_furnace_state_authority_pending",true)),
            "fifth READY removes ONLY State85, keeps shared State100"):return
    screen._refresh_battle_status()
    if not _check("痛苦熔爐：State85 已解除" in screen.status_label.text,
            "Godot HUD reflects fifth-ready expiry and shared State100"):return

    _enemy_hit(b)
    damage=b.attack(enemy,ivy)
    if not _check(damage==77 and int(ivy["hp"])==846 and
            int(ivy["fs_ivy_stored_pain"])==115 and int(
            b.ivy_pain.events[-1]["gain"])==38 and int(
            b.ivy_pain.events[-1]["cap"])==2000,
            "post-expiry direct77 stores only38 (50%) and cap200%"):return

    # Reapplying SOURCE pair while State100 already exists is allowed
    # and resets State85 duration to exactly four ATB READY edges.
    ivy["mp"]=100
    if not _check(b.skill_preflight(ivy,ivy,145) and b.use_skill(
            ivy,ivy,145) and ivy["states"]==[100,85] and int(
            ivy["fs_ivy_furnace_state_turns"]["85"])==4 and int(
            ivy["mp"])==84,
            "source repeated 145 adds State85 once, refreshes hold4, pays once"):return

    # Full actual original Skill145 includes JP/charge/recharge/pop:
    # never pretend those were supported simply because State85+100
    # synthetic source check passes.
    var other:FSBattle=_battle()
    if not _check(other.start(),"negative source battle started"):return
    var actor:Dictionary=other.party[0]
    other.db.tables["skills"][145]["note"]="<jp cost:2800>\n<charge: 4, 10%, 0>\n<recharge:10%>\n<ricarica turni:2>"
    var before_mp:int=int(actor["mp"])
    var before_states:Array=actor["states"].duplicate()
    other.accuracy.scripted_rolls=[0,99,0]
    if not _check(not other.skill_preflight(actor,actor,145) and
            not other.use_skill(actor,actor,145) and int(
            actor["mp"])==before_mp and actor["states"]==before_states and
            other.accuracy.scripted_rolls==[0,99,0],
            "real Skill145 unported JP/charge/turn cooldown refuses before effects"):return
    other.db.tables["skills"][145]=_skill()
    other.db.tables["states"][100]["note"]="<aizhuo_overload>"
    if not _check(not other.skill_preflight(actor,actor,145) and
            int(actor["mp"])==before_mp and actor["states"]==before_states,
            "unknown shared State100 gameplay Note blocks source shape"):return
    other.db.tables["states"][100]=_state(100)
    other.db.tables["skills"][145]["fs_furnace_fixture_only"]=false
    if not _check(not other.skill_preflight(actor,actor,145) and
            int(actor["mp"])==before_mp,
            "fake verified flags without real post-Apply authority cannot enable145"):return
    print("FS Phase530 real Godot Ivy145 source-only ACT MP16 State85+100, ATB READY 4->0 then fifth expires, Pain100->50, strict full145 and State100 fail-close PASS")
    quit(0)
