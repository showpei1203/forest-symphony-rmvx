extends SceneTree

# SOURCE #IvyClonePatch final V1.6.2 main-Ivy Cover bounded subset.
# Original All_Scripts_Export.txt ~244516/245166/245510/246106/
# 248116-248286. Actual Godot attack/preflight/Shield/OD test;
# no fake original post-Apply database or source-restricted gameplay flag.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(yes: bool,reason: String) -> bool:
    if not yes:
        push_error("FS native Ivy main Cover FAIL: "+reason)
        quit(1)
        return false
    return true

func _actor(id: int,name: String,defense: int) -> Dictionary:
    return {"id":id,"name":name,"actor":true,
        "hp":1000,"maxhp":1000,"mp":100,"maxmp":100,"level":1,
        "atk":50,"def":defense,"spi":10,"agi":20,
        "hit":95,"eva":5,"cri":10,"od":0,
        "element_set":[],"states":[],"skills":[],
        "equipment":[],"note":"",
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}

func _battle() -> FSBattle:
    var db=DB.new()
    db.tables={"enemies":[null,{"id":1,"name":"Original Source Enemy",
        "maxhp":9999,"maxmp":200,"atk":50,"def":10,"spi":10,
        "agi":20,"hit":95,"eva":5,"has_critical":false,
        "actions":[],"note":""}],"weapons":[null],
        "armors":[null],"states":[null]}
    var b=BATTLE.new(db)
    b.party.append(_actor(1,"Protected Ally",10))
    var ivy: Dictionary=_actor(5,"Ivy Main",20)
    ivy["max_od"]=1000
    ivy["fs_ivy_guard_source_verified"]=true
    b.party.append(ivy)
    b.add_enemy(1)
    b.enemies[0]["level"]=1
    b.enemies[0]["element_set"]=[]
    b.enemies[0]["fs_normal_source_verified"]=true
    b.enemies[0]["fs_normal_enemy_note_verified"]=true
    b.enemies[0]["fs_normal_element_neutral_verified"]=true
    b.accuracy.active=true
    b.normal_core.active=true
    b.ivy_cover.active=true
    b.source_atb_rolls_for_test={"actor:0":0,"actor:1":0,"enemy:0":0}
    return b

func _scripted_hit(b: FSBattle) -> void:
    b.accuracy.draws.clear()
    # TARGET HIT/EVA + old 85pct/2xCRI/2xvariance + independent guard
    # 85pct/2xCRI/2xvariance. No SECOND HIT/EVA on Ivy guard.
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0,
        0,99,99,0,0]

func _run() -> void:
    var b: FSBattle=_battle()
    if not _check(b.start(),"native Ivy guarded battle started"): return
    var ally: Dictionary=b.party[0]
    var ivy: Dictionary=b.party[1]
    var enemy: Dictionary=b.enemies[0]
    if not _check(int(ivy["od"])==100 and
            int(ivy["fs_ivy_guard_charges"])==0,
            "Ivy source start_battle awards exactly10% MaxOD and resets old guard"): return

    var note: Dictionary={"fs_ivy_guard_tag_verified":true,
        "note":"<ig:2,3,25>"}
    var activated: Dictionary=b.ivy_cover.activate_main_guard(b,ivy,note)
    if not _check(bool(activated.get("ok",false)) and
            int(ivy["fs_ivy_guard_charges"])==2 and
            int(ivy["fs_ivy_guard_actions_left"])==3 and
            int(ivy["fs_ivy_guard_reduce"])==25,
            "original <ig:2,3,25> charges actions reduction activated"): return

    var untouched_hp: int=int(ally["hp"])
    var before_ivy: int=int(ivy["hp"])
    _scripted_hit(b)
    if not _check(b.attack_preflight(enemy,ally) and
            b.accuracy.draws.is_empty() and
            b.accuracy.scripted_rolls.size()==12,
            "source guard preflight validates own defender no RNG"): return
    var dealt: int=b.attack(enemy,ally)
    if not _check(dealt==58 and int(ally["hp"])==untouched_hp and
            int(ivy["hp"])==before_ivy-58 and
            int(ivy["od"])==200 and
            int(ivy["fs_ivy_guard_charges"])==1 and
            int(ivy["fs_ivy_guard_actions_left"])==3 and
            b.accuracy.scripted_rolls.is_empty(),
            "real Cover re-roll: enemy hit ally87, Ivy own DEF20 old6 smooth77 then reduce25%=58; OD10+6+2+2"): return
    if not _check(b.accuracy.draws.map(
            func(x: Dictionary): return str(x["kind"]))==[
            "hit","eva","legacy_attack_power","legacy_critical_provisional",
            "critical_final","variance_a","variance_b",
            "legacy_attack_power","legacy_critical_provisional",
            "critical_final","variance_a","variance_b"] and
            b.ivy_cover.events.size()==1 and
            bool(b.ivy_cover.events[0]["first"]),
            "Cover recalculates guard power but does not re-roll HIT/EVA"): return

    # A MISS is legal completed ACT: Cover charges and OD remain
    # unchanged, original target HP unchanged.
    b.accuracy.scripted_rolls=[95]
    untouched_hp=int(ally["hp"])
    before_ivy=int(ivy["hp"])
    if not _check(b.attack(enemy,ally)==0 and
            int(ally["hp"])==untouched_hp and
            int(ivy["hp"])==before_ivy and
            int(ivy["fs_ivy_guard_charges"])==1 and
            int(ivy["od"])==200 and
            b.accuracy.scripted_rolls.is_empty(),
            "enemy HIT failure does not spend Cover charge or OD"): return

    _scripted_hit(b)
    dealt=b.attack(enemy,ally)
    if not _check(dealt==58 and
            int(ivy["fs_ivy_guard_charges"])==0 and
            int(ivy["fs_ivy_guard_actions_left"])==0 and
            int(ivy["fs_ivy_guard_reduce"])==0 and
            int(ivy["hp"])==before_ivy-58 and
            int(ivy["od"])==300 and
            b.ivy_cover.events.size()==2,
            "second active Cover consumes last charge, original source clear_guard and +10% MaxOD"): return

    # With no remaining Cover charge, enemy attacks the original ally.
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]
    untouched_hp=int(ally["hp"])
    before_ivy=int(ivy["hp"])
    dealt=b.attack(enemy,ally)
    if not _check(dealt==87 and int(ally["hp"])==untouched_hp-87 and
            int(ivy["hp"])==before_ivy and
            int(ivy["od"])==320,
            "no charges means direct hit and Ivy gets team-hit OD2% once"): return

    # Guard's own verified source damage source must be available BEFORE
    # HIT RNG: unknown elements/weapon notes never use a magic defense.
    b.ivy_cover.activate_main_guard(b,ivy,note)
    ivy["fs_normal_element_neutral_verified"]=false
    b.accuracy.scripted_rolls=[0,99,0,99,99,0,0]
    untouched_hp=int(ally["hp"])
    var denied: bool=not b.attack_preflight(enemy,ally)
    var aborted: int=b.attack(enemy,ally)
    if not _check(denied and aborted==0 and
            int(ally["hp"])==untouched_hp and
            b.accuracy.scripted_rolls==[0,99,0,99,99,0,0],
            "unverified guard element-rate source: denied=%s damage=%d HP=%d/%d rolls=%s cover=%s" % [
                str(denied),aborted,int(ally["hp"]),untouched_hp,
                str(b.accuracy.scripted_rolls),str(b.ivy_cover.errors)]): return
    ivy["fs_normal_element_neutral_verified"]=true

    # The original emergency Ivy clone activates below 50% HP even with
    # no main guard. This workflow is UNPORTED so must fail closed,
    # NOT ignore the clone and hit the ally.
    ivy["fs_ivy_guard_charges"]=0
    ivy["fs_ivy_guard_actions_left"]=0
    var clone: Dictionary=_actor(103,"Ivy Clone",10)
    clone["fs_clone_role"]="ivy"
    b.party.append(clone)
    ally["hp"]=400
    if not _check(not b.attack_preflight(enemy,ally) and
            b.accuracy.scripted_rolls==[0,99,0,99,99,0,0],
            "low-HP emergency clone is blocked until original clone cover port"): return

    # Source final select_guard v1.5: main Ivy who is casting may NOT
    # intercept. It must FALL THROUGH to the half-HP emergency clone
    # authority; the unported clone path must therefore refuse.
    ivy["fs_ivy_guard_charges"]=2
    ivy["fs_ivy_guard_actions_left"]=2
    ivy["casting"]=true
    if not _check(not b.attack_preflight(enemy,ally) and
            b.accuracy.scripted_rolls==[0,99,0,99,99,0,0],
            "casting main Ivy does not hide possible emergency clone branch"): return
    ivy["casting"]=false
    # Source passive Skill142 changes Ivy's effective damage according
    # to OD. Until this alias is ported, it must not silently take
    # a wrong guarded-damage amount.
    ivy["skills"]=[142]
    if not _check(not b.attack_preflight(enemy,ally) and
            b.accuracy.scripted_rolls==[0,99,0,99,99,0,0],
            "unverified Ivy passive142 cannot bypass source guard effect"): return
    ivy["skills"]=[]
    ivy["fs_ivy_taunt_reduce"]=15
    if not _check(not b.attack_preflight(enemy,ally) and
            b.accuracy.scripted_rolls==[0,99,0,99,99,0,0],
            "unverified Ivy taunt damage reduction cannot affect source guard"): return
    ivy.erase("fs_ivy_taunt_reduce")
    ivy["fs_ivy_guard_charges"]=0
    ivy["fs_ivy_guard_actions_left"]=0

    # Repeated battle start never grants additional OD or resets gauge.
    var old_od: int=int(ivy["od"])
    if not _check(b.start() and int(ivy["od"])==old_od,
            "redrawing/starting same battle cannot grant repeated start OD"): return

    # SOURCE-GATED Ivy Skill141 is a true SELF (scope11) command.
    # It must NOT grant guard at selection; only after the Tankentai ACT
    # resolves, and must pay MP8 ONCE. The original real Skill141 has
    # extra unported JP/charge/recharge/OD tags; synthetic clean Note
    # subset explicitly marked verified for this native test.
    var q: FSBattle=_battle()
    var skills: Array=[]
    skills.resize(142)
    skills[141]={"id":141,"name":"Ivy Cover (source-only subset)",
        "scope":11,"base_damage":0,"atk_f":0,"spi_f":0,
        "hit":100,"physical_attack":false,"variance":0,
        "mp_cost":8,"plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false,
        "element_set":[],"note":"<ig:2,2,20>",
        "fs_ivy_guard_tag_verified":true}
    q.db.tables["skills"]=skills
    var q_ivy: Dictionary=q.party[1]
    q_ivy["skills"]=[141]
    if not _check(q.start(),"source clean Ivy skill ACT battle starts"): return
    q_ivy["source_at_active"]=true
    q_ivy["source_atb_count_up"]=false
    q_ivy["source_atb_count"]=1000
    q.accuracy.scripted_rolls=[95]
    if not _check(not q.queue_actor_action(1,"skill",0,141) and
            int(q_ivy["mp"])==100,
            "scope11 Ivy guard cannot be cast onto another ally"): return
    if not _check(q.queue_actor_action(1,"skill",1,141) and
            q.has_actor_pending_action(1) and
            int(q_ivy["mp"])==100 and
            int(q_ivy["fs_ivy_guard_charges"])==0 and
            q.accuracy.scripted_rolls==[95],
            "Ivy self-buff COMMAND only queues, no charge/MP/RNG yet"): return
    # Tankentai original special fast Skill1 charges in ONE frame.
    # Source Skill141 uses the generic 10% skill ACT gauge: ATB_SPEED10
    # makes 100/1000 per frame, so payment happens after TEN frames.
    q.advance_atb(9.0/60.0)
    if not _check(q.has_actor_pending_action(1) and
            int(q_ivy["mp"])==100 and
            int(q_ivy["fs_ivy_guard_charges"])==0 and
            int(q_ivy["source_act_count"])==900,
            "Ivy source Skill141 ACT still charging at 9/10 frames, no MP/guard"): return
    q.advance_atb(1.0/60.0)
    if not _check(q.action_queue.completed.size()==1 and
            bool(q.action_queue.completed[0]["success"]) and
            int(q_ivy["mp"])==92 and
            int(q_ivy["fs_ivy_guard_charges"])==2 and
            int(q_ivy["fs_ivy_guard_actions_left"])==2 and
            int(q_ivy["od"])==100 and
            q.accuracy.scripted_rolls==[95] and
            not q.has_actor_pending_action(1),
            "valid Ivy ACT: completed=%s mp=%s charges=%s actions=%s od=%s rolls=%s pending=%s source=%s cover=%s" % [
                str(q.action_queue.completed),str(q_ivy.get("mp")),
                str(q_ivy.get("fs_ivy_guard_charges")),
                str(q_ivy.get("fs_ivy_guard_actions_left")),
                str(q_ivy.get("od")),str(q.accuracy.scripted_rolls),
                str(q.action_queue.pending),str(q_ivy.get("source_atb_count")),
                str(q.ivy_cover.errors)]): return

    # The original source includes independent target and guard power
    # calculations for incoming ENEMY SKILLS as well as ordinary attacks.
    var enemy_skill: Dictionary={
        "id":1,"name":"Synthetic Single Magic",
        "scope":1,"base_damage":100,"atk_f":100,"spi_f":0,
        "hit":95,"physical_attack":false,"variance":0,
        "mp_cost":10,"plus_state_set":[],"minus_state_set":[],
        "element_set":[],"note":"",
        "has_critical":false,"ignore_defense":false,
        "damage_to_mp":false,"absorb_damage":false,
        "fs_smooth_source_verified":true}
    q.db.tables["skills"][1]=enemy_skill
    q.skill_core.active=true
    q_ivy["fs_smooth_battler_verified"]=true
    q_ivy["fs_smooth_element_neutral_verified"]=true
    q.party[0]["fs_smooth_battler_verified"]=true
    q.party[0]["fs_smooth_element_neutral_verified"]=true
    q.enemies[0]["fs_smooth_battler_verified"]=true
    var q_enemy: Dictionary=q.enemies[0]
    var q_ally: Dictionary=q.party[0]
    q.accuracy.scripted_rolls=[0,99,99,99]
    var q_ivy_hp: int=int(q_ivy["hp"])
    var q_ally_hp: int=int(q_ally["hp"])
    var q_enemy_mp: int=int(q_enemy["mp"])
    if not _check(q.skill_preflight(q_enemy,q_ally,1) and
            q.accuracy.scripted_rolls==[0,99,99,99] and
            q.use_skill(q_enemy,q_ally,1) and
            int(q_ally["hp"])==q_ally_hp and
            int(q_ivy["hp"])==q_ivy_hp-137 and
            int(q_enemy["mp"])==q_enemy_mp-10 and
            int(q_ivy["od"])==200 and
            int(q_ivy["fs_ivy_guard_charges"])==1 and
            q.accuracy.scripted_rolls.is_empty(),
            "enemy skill source190->184 original, Ivy own DEF20 skill171 then guard20%=137, MP10 paid once"): return

    # A completed Ivy GUARD command advances actions_left once even
    # though no attack()/use_skill() method is involved.
    q_ivy["source_at_active"]=true
    q_ivy["source_atb_count_up"]=false
    q_ivy["source_atb_count"]=1000
    if not _check(q.queue_actor_action(1,"guard") and
            int(q_ivy["fs_ivy_guard_actions_left"])==2,
            "guard command does not tick Ivy duration at selection"): return
    q.advance_atb(1.0/60.0)
    if not _check(q.action_queue.completed.size()==2 and
            int(q_ivy["fs_ivy_guard_actions_left"])==1 and
            int(q_ivy["fs_ivy_guard_charges"])==1,
            "guard ACT counts one owner action, retaining one cover duration"): return
    q_ivy["source_at_active"]=true
    q_ivy["source_atb_count_up"]=false
    q_ivy["source_atb_count"]=1000
    if not _check(q.queue_actor_action(1,"guard"),
            "second owner GUARD ACT can start"): return
    q.advance_atb(1.0/60.0)
    if not _check(q.action_queue.completed.size()==3 and
            int(q_ivy["fs_ivy_guard_actions_left"])==0 and
            int(q_ivy["fs_ivy_guard_charges"])==0 and
            int(q_ivy["fs_ivy_guard_reduce"])==0,
            "second owner action expires Ivy guard, remaining charge cleared"): return

    # Original real Skill141 has further JP/charge/recharge/io/MPU/pop
    # authority. It must be refused, not stripped to an imaginary buff.
    q.db.tables["skills"][141]["note"]="<jp cost:400>\\n<ig:2,2,20>"
    q_ivy["source_at_active"]=true
    q_ivy["source_atb_count_up"]=false
    q_ivy["source_atb_count"]=1000
    q.accuracy.scripted_rolls=[95]
    var q_mp_before: int=int(q_ivy["mp"])
    if not _check(not q.queue_actor_action(1,"skill",1,141) and
            int(q_ivy["mp"])==q_mp_before and
            int(q_ivy["fs_ivy_guard_charges"])==0 and
            q.accuracy.scripted_rolls==[95],
            "real MasterSetup guard skill extra JP/charge Notes fail closed before ACT/MP"): return

    print("FS Ivy Main Cover V1.6.2 source guard selection, 2x independent power, charges, OD, MISS and clone fail-close PASS")
    quit(0)
