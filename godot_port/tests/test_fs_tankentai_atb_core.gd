extends SceneTree

# Deterministic source #230/#231 checks with synthetic battlers.
# Gauge is per-frame integer; candidate action damage/parity remains separate.
const CORE = preload("res://scripts/FSTankentaiATBCore.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS Tankentai 1.2c ATB core FAIL: "+label)
        quit(1)
        return false
    return true

func _party() -> Array[Dictionary]:
    var result: Array[Dictionary] = [
        {"id":1,"actor":true,"name":"Hero1","agi":40,"hp":100,
         "equipment":[1,0,0,0,0],"two_swords_style":false},
        {"id":2,"actor":true,"name":"Hero2","agi":20,"hp":100,
         "equipment":[0,0,0,0,0],"two_swords_style":false}
    ]
    return result

func _enemies() -> Array[Dictionary]:
    var result: Array[Dictionary] = [
        {"id":1,"actor":false,"name":"Fast","agi":50,"hp":80,"atb":0.0}
    ]
    return result

func _run() -> void:
    var db = DB.new()
    db.tables = {"weapons":[null,{"id":1,"name":"Starter","atb_base":0,"recharge":20}],
        "armors":[null]}
    var rolls: Dictionary = {"actor:0":0,"actor:1":0,"enemy:0":0}
    var party: Array[Dictionary] = _party()
    var enemies: Array[Dictionary] = _enemies()
    CORE.prepare(party,enemies,db,rolls)
    if not _check(party[0]["source_atb_count"]==300,
            "Actor01 source-specific 30% start with a weapon"): return
    if not _check(party[1]["source_atb_count"]==200,
            "unarmed actor source doubles initial ATB due missing weapon fallbacks"): return
    if not _check(enemies[0]["source_atb_count"]==100,
            "enemy starts source 10 percent without roll"): return
    if not _check(party[0]["source_atb_gain_per_frame"]==8 and
            party[1]["source_atb_gain_per_frame"]==4 and
            enemies[0]["source_atb_gain_per_frame"]==10,
            "each source frame gains floor(ATB_SPEED*AGI/max AGI)"): return
    CORE.advance_frames(party,enemies,88)
    if not _check(party[0]["source_atb_count"]==1004 and
            party[0]["source_at_active"],"Actor01 becomes ready on frame88"): return
    if not _check(not enemies[0]["source_at_active"] and
            enemies[0]["source_atb_count"]==980,
            "enemy still not ready until frame90"): return
    if not _check(CORE.ready_actors(party)==[0],"ready party queue reflects ATB flags"): return
    CORE.advance_frames(party,enemies,2)
    if not _check(CORE.ready_enemies(enemies)==[0] and
            enemies[0]["source_atb_count"]==1000,"enemy ready on frame90"): return
    if not _check(party[0]["source_atb_count"]==1004,
            "ready actor no longer accumulates ATB"): return
    if not _check(CORE.begin_charge(party[0],"skill",1),
            "source ready actor may begin Skill1 ACT charge"): return
    if not _check(not party[0]["source_at_active"] and
            party[0]["source_act_gain_per_frame"]==1000,
            "source Skill1 percent=1 and base=10 => ACT 1000/frame"): return
    CORE.advance_frames(party,enemies,1)
    if not _check(party[0]["source_act_active"] and
            party[0]["source_act_count"]==1000,
            "ACT ready after one frame, distinct from ATB ready"): return
    CORE.reset_after_action(party[0],"skill",1,db)
    if not _check(party[0]["source_atb_count"]==300 and
            party[0]["source_atb_count_up"] and not party[0]["source_act_active"],
            "source Skill1 recharge 30% after action"): return
    # No state should move while global WAIT flags are active.
    var before: int = int(party[0]["source_atb_count"])
    CORE.advance_frames(party,enemies,5,true)
    if not _check(party[0]["source_atb_count"]==before,
            "WAIT mode freezes gauge exactly"): return
    CORE.advance_frames(party,enemies,5,false)
    if not _check(party[0]["source_atb_count"]==before+5*8,
            "unpaused gauge resumes at source frame increments"): return
    CORE.reset_after_action(party[0],"attack",0,db)
    if not _check(party[0]["source_atb_count"]==200,
            "weapon1 normal attack resets gauge at 20%"): return
    CORE.reset_after_action(party[1],"guard",0,db)
    if not _check(party[1]["source_atb_count"]==0,
            "guard reset defaults 0%"): return

    var pre: Array[Dictionary] = _party()
    var epre: Array[Dictionary] = _enemies()
    CORE.prepare(pre,epre,db,rolls,"preemptive")
    if not _check(pre[0]["source_atb_count"]==1000 and
            epre[0]["source_atb_count"]==-500,
            "source preemptive ally100%, enemy -50%"): return
    var surprise: Array[Dictionary] = _party()
    var esurprise: Array[Dictionary] = _enemies()
    CORE.prepare(surprise,esurprise,db,rolls,"surprise")
    if not _check(surprise[0]["source_atb_count"]==-500 and
            esurprise[0]["source_atb_count"]==1000,
            "source surprise enemy100%, ally -50%"): return

    # Integration: no fixed float placeholder; 0.5s uses 30 integer frames.
    var battle = BATTLE.new(db)
    battle.party = _party()
    battle.enemies = _enemies()
    battle.source_atb_rolls_for_test = rolls
    if not _check(battle.start(),"battle starts with synthetic roster"): return
    if not _check(battle.party[0]["source_atb_count"]==300,
            "FSBattle.start initializes Tankentai source gauges"): return
    battle.advance_atb(0.5)
    if not _check(battle.party[0]["source_atb_count"]==540 and
            battle.enemies[0]["source_atb_count"]==400,
            "FSBattle.advance_atb 0.5s == 30 source 60fps frames"): return
    battle.source_atb_wait = true
    battle.advance_atb(1.0)
    if not _check(battle.party[0]["source_atb_count"]==540,
            "FSBattle source WAIT flag pauses all gauges"): return
    battle.source_atb_wait = false
    battle.advance_atb(58.0/60.0)
    if not _check(battle.ready_actors()==[0] and
            battle.ready_enemies()==[0],
            "FSBattle reports both source-ready actors/enemies after frame progress"): return
    if not _check(battle.begin_source_atb_charge(battle.party[0],"skill",1),
            "FSBattle can start ACT phase from ready party actor"): return
    if not _check(not battle.source_action_charged(battle.party[0]),
            "ACT not immediately ready on command before frame tick"): return
    battle.advance_atb(1.0/60.0)
    if not _check(battle.source_action_charged(battle.party[0]),
            "ACT ready after source frame"): return
    if not _check(battle.finish_source_atb_action(battle.party[0],"skill",1) and
            battle.party[0]["source_atb_count"]==300,
            "FSBattle action end resets source gauge to Skill1 30%"): return
    if not _check(not battle.finish_source_atb_action(battle.party[0],"skill",1),
            "cannot finish same action twice"): return
    print("FS Tankentai #230/#231 integer 60fps ATB + ACT charge/init/WAIT/recharge/preemptive smoke PASS")
    quit(0)
