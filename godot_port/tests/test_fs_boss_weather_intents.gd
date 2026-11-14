extends SceneTree

# #401 Boss548-550 weather phase threshold55%, and #404 global
# weather source semantics. Field/elemental effects are NOT implemented:
# only ID + source snapshot, never per-actor actual States.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const PHASE = preload("res://scripts/FSBossPhaseRuntime.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    if not ok:
        push_error("FS source Boss Weather phase intents FAIL: "+reason)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    for id in [122,123,124,125,126,127,153,154,155,156,157,158]:
        states[id] = {"id":id,"name":"Synthetic Weather State%d" % id,"note":""}
    var enemies: Array = []
    enemies.resize(561)
    for id in [548,549,550,558,559,560]:
        enemies[id] = {"id":id,"name":"Enemy%d" % id,
            "maxhp":1000,"maxmp":100,"atk":20,"def":10,
            "spi":10,"agi":15,"note":"<fs_fixed_enemy_stats>",
            "actions":[{"kind":0,"basic":0,"skill_id":0,"rating":8,
                "condition_type":0,"condition_param1":0,"condition_param2":0}]}
    db.tables={"states":states,"enemies":enemies,"skills":[null],
        "weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase,boss_ids: Array[int],
        activate_runtime: bool = false) -> FSBattle:
    var battle = BATTLE.new(db)
    battle.party.append({"id":1,"actor":true,"name":"Hero",
        "hp":500,"maxhp":500,"mp":100,"maxmp":100,
        "agi":20,"atk":10,"odds":4,"states":[],"note":"",
        "equipment":[0,0,0,0,0],"two_swords_style":false})
    for id in boss_ids:
        battle.add_enemy(id)
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0,
        "enemy:1":0,"enemy:2":0,"enemy:3":0,"enemy:4":0,
        "enemy:5":0,"enemy:6":0,"enemy:7":0}
    battle.boss_runtime.active = activate_runtime
    return battle

func _run() -> void:
    var db = _db()
    var battle = _battle(db,[548],true)
    if not _check(battle.start(),"weather Boss548 battle begins"): return
    battle.advance_atb(1.0/60.0)
    var boss: Dictionary = battle.enemies[0]
    var phase = battle.boss_runtime.phase_runtime
    if not _check(phase.weather_request.get("field_id",0)==153 and
            phase.weather_request.get("source_boss_id",0)==548 and
            boss["fs_phase_state_intents"]==[122] and
            boss.get("states",[]).is_empty() and
            boss["fs_boss_weather_effects_pending"],
            "Boss548 above55% plans State122 & global Field153, never battler state"): return
    var count: int = phase.transitions.size()
    battle.advance_atb(1.0/60.0)
    if not _check(phase.transitions.size()==count,
            "unchanged weather source request does not spam transition records"): return
    boss["hp"] = 551
    battle.advance_atb(1.0/60.0)
    if not _check(phase.weather_request["field_id"]==153 and
            boss["fs_phase_state_intents"]==[122],
            "HP55.1% remains early weather"): return
    boss["hp"] = 550
    battle.advance_atb(1.0/60.0)
    if not _check(phase.weather_request["field_id"]==156 and
            boss["fs_phase_state_intents"]==[125] and
            phase.weather_request["stage"]=="intent_only",
            "HP exactly55% switches 122→125 and Field153→156"): return
    boss["hp"] = 700
    battle.advance_atb(1.0/60.0)
    if not _check(phase.weather_request["field_id"]==153 and
            boss["fs_phase_state_intents"]==[125],
            "source phase State125 stays on healing; forced weather ID reverts to153"): return
    boss["hp"] = 0
    battle.advance_atb(1.0/60.0)
    # Source #404 update_source clears field when original boss dies.
    # Boss runtime tick isn't called after only enemy dies (battle.active
    # could become false). Call only phase snapshot explicitly.
    phase.tick(battle,battle.boss_runtime.flags)
    if not _check(phase.weather_request.is_empty() and
            phase.transitions[-1]["op"]=="request_clear_field",
            "dead weather source requests global field clear, no fake damage"): return

    var multi = _battle(db,[548,549,550])
    multi.start()
    var weather = PHASE.new()
    weather.tick(multi,{})
    if not _check(weather.weather_request["field_id"]==155 and
            weather.weather_request["source_boss_id"]==550,
            "source #401 ordered 548→549→550, final living boss550 weather155 wins"): return
    multi.enemies[2]["hp"] = 550
    weather.tick(multi,{})
    if not _check(weather.weather_request["field_id"]==158 and
            multi.enemies[2]["fs_phase_state_intents"]==[127],
            "Boss550 exact55% selects State127 / Field158"): return
    multi.enemies[2]["hp"] = 0
    weather.tick(multi,{})
    if not _check(weather.weather_request["field_id"]==154 and
            weather.weather_request["source_boss_id"]==549,
            "dead Boss550 no longer forces Field; living Boss549 owns Field154"): return

    var incomplete = _db()
    incomplete.tables["states"][158] = null
    var denied = _battle(incomplete,[550])
    denied.start()
    denied.enemies[0]["hp"] = 550
    var denied_phase = PHASE.new()
    denied_phase.tick(denied,{})
    if not _check(denied_phase.weather_request.is_empty() and
            denied.enemies[0].get("fs_phase_state_intents",[]).is_empty() and
            not denied_phase.failures.is_empty(),
            "missing actual Field158 data refuses phase/weather change atomically"): return

    print("FS #401/#404 Weather 548-550 55%, force ordering, dead source, global-only intents PASS")
    quit(0)
