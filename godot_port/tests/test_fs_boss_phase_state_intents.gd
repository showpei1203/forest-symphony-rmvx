extends SceneTree

# Source #401 Boss524 150/151/152, Law 140..143 pending, Boss530/531
# Core shield77 / awakening128 / once-only exposure129.
# Deliberately NO real RPG::State effects: phase IDs are intent-only.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const AI = preload("res://scripts/FSEnemyAIDecision.gd")
const PHASE = preload("res://scripts/FSBossPhaseRuntime.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    if not ok:
        push_error("FS Boss phase source intents FAIL: "+reason)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    for i in [77,128,129,140,141,142,143,150,151,152,
            122,123,124,125,126,127,153,154,155,156,157,158]:
        states[i] = {"id":i,"name":"Synthetic State%d" % i,"note":""}
    var enemies: Array = []
    enemies.resize(566)
    for id in [524,530,531,561,562,563,564,565]:
        enemies[id] = {"id":id,"name":"Enemy%d" % id,
            "maxhp":1000,"maxmp":100,"atk":20,"def":10,
            "spi":10,"agi":10,"note":"<fs_fixed_enemy_stats>",
            "actions":[{"kind":0,"basic":0,"skill_id":0,"rating":8,
                "condition_type":0,"condition_param1":0,"condition_param2":0}]}
    db.tables={"states":states,"enemies":enemies,
        "skills":[null],"weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase,boss_id: int) -> FSBattle:
    var battle = BATTLE.new(db)
    battle.party.append({"id":1,"name":"Hero","actor":true,
        "hp":500,"maxhp":500,"mp":100,"maxmp":100,"agi":20,
        "atk":20,"def":10,"spi":10,"states":[],"note":"",
        "equipment":[0,0,0,0,0],"two_swords_style":false,"odds":4})
    battle.add_enemy(boss_id)
    battle.boss_runtime.active = true
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0,
        "enemy:1":0,"enemy:2":0,"enemy:3":0,"enemy:4":0}
    return battle

func _run() -> void:
    var db = _db()
    var battle = _battle(db,524)
    if not _check(battle.start(),"Boss524 battle starts"): return
    var boss: Dictionary = battle.enemies[0]
    battle.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[150] and
            boss.get("states",[]).is_empty() and
            boss["fs_boss_phase_effects_pending"],
            "100% HP: source State150 ID planned, NOT applied as actual State"): return
    var count: int = battle.boss_runtime.phase_runtime.transitions.size()
    battle.advance_atb(1.0/60.0)
    if not _check(battle.boss_runtime.phase_runtime.transitions.size()==count,
            "no duplicate State150 event each 60Hz frame"): return
    boss["hp"] = 701
    battle.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[150],
            "HP 70.1% does not trigger second phase"): return
    boss["hp"] = 700
    var gauge_before_wait: int = int(boss["source_atb_count"])
    battle.source_atb_wait = true
    battle.advance_atb(1.0/60.0)
    if not _check(int(boss["source_atb_count"])==gauge_before_wait,
            "target-selection WAIT freezes ATB gauge, not Boss phase update"): return
    battle.source_atb_wait = false
    if not _check(boss["fs_phase_state_intents"]==[151] and
            boss["fs_law_cycle_authority_pending"] and
            not boss.get("fs_phase_state_intents",[]).has(140),
            "exact 70%: remove150 add151; Law140-143 not fabricated"): return
    boss["fs_phase_state_intents"] = [151,140,142]
    boss["hp"] = 351
    battle.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[151,140,142],
            "35.1% remains second phase and retains any law intents"): return
    boss["hp"] = 350
    battle.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[152] and
            not bool(boss.get("fs_law_cycle_authority_pending",true)),
            "exact 35%: remove151 and all Law140-143, add152"): return
    boss["hp"] = 1000
    battle.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[152],
            "source does NOT reverse State152 just because Boss524 heals"): return
    boss["hp"] = 600
    battle.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[152,151],
            "source can re-add151 beside152 after healing to middle band"): return

    # AI and provisional battle commands must not behave as if pending
    # shield/phase IDs had already applied their original RPG State effects.
    battle.party[0]["source_at_active"] = true
    battle.party[0]["source_atb_count_up"] = false
    if not _check(not battle.queue_actor_action(0,"attack",0) and
            not battle.has_actor_pending_action(0),
            "player queue refuses damage to Boss with unapplied State effects"): return
    if not _check(not AI.choose(battle,0,battle.action_queue.ai_rng).get("ok",false),
            "Boss AI fails closed while its actual Phase effects unverified"): return

    var missing_db = _db()
    missing_db.tables["states"][151] = null
    var no_state = _battle(missing_db,524)
    no_state.start()
    no_state.advance_atb(1.0/60.0)
    no_state.enemies[0]["hp"] = 700
    no_state.advance_atb(1.0/60.0)
    if not _check(no_state.enemies[0]["fs_phase_state_intents"]==[150] and
            not no_state.boss_runtime.phase_runtime.failures.is_empty(),
            "missing State151 rejects entire middle-phase transition"): return

    var shield = _battle(db,530)
    shield.start()
    shield.advance_atb(1.0/60.0)
    if not _check(shield.enemies.size()==3 and
            shield.boss_runtime.flags.has("start:530") and
            shield.enemies[0]["fs_phase_state_intents"]==[77],
            "Boss530 summons Core561x2, then requests Shield77 in same source update"): return
    shield.enemies[0]["hp"] = 450
    shield.advance_atb(1.0/60.0)
    if not _check(shield.enemies[0]["fs_phase_state_intents"]==[77,128],
            "Boss530 HP exactly45% adds awakening State128 while cores alive"): return
    shield.enemies[1]["hp"] = 0
    shield.advance_atb(1.0/60.0)
    if not _check(shield.enemies[0]["fs_phase_state_intents"]==[77,128] and
            not shield.boss_runtime.flags.has("exposed:530"),
            "one surviving Core561 still protects Boss530"): return
    shield.enemies[2]["hp"] = 0
    shield.advance_atb(1.0/60.0)
    if not _check(shield.enemies[0]["fs_phase_state_intents"]==[128,129] and
            shield.boss_runtime.flags.has("exposed:530"),
            "all core561 dead: remove shield77 and expose129 once"): return
    count = shield.boss_runtime.phase_runtime.transitions.size()
    shield.advance_atb(1.0)
    if not _check(shield.boss_runtime.phase_runtime.transitions.size()==count and
            shield.enemies.size()==3,
            "shield/exposure once-only and dead core members count for summons"): return

    var shield531 = _battle(db,531)
    shield531.start()
    shield531.advance_atb(1.0/60.0)
    if not _check(shield531.enemies.size()==5 and
            shield531.enemies[0]["fs_phase_state_intents"]==[77],
            "Boss531 summons four distinct Core562-565 then shield77"): return
    for i in range(1,shield531.enemies.size()):
        shield531.enemies[i]["hp"] = 0
    shield531.advance_atb(1.0/60.0)
    if not _check(shield531.enemies[0]["fs_phase_state_intents"]==[129] and
            shield531.boss_runtime.flags.has("exposed:531"),
            "Boss531 exposure requires all four cores defeated"): return

    var no_flag = _battle(db,530)
    no_flag.start()
    # Direct Phase-only path before its source initial summon event.
    var phase = PHASE.new()
    phase.tick(no_flag,{})
    if not _check(not no_flag.enemies[0].get("fs_phase_state_intents",[]).has(129),
            "exposure129 is never granted without source start/threshold flag"): return
    print("FS #401 Boss524 phases/Law guard and Boss530/531 shield/exposure intents PASS")
    quit(0)
