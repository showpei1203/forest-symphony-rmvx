extends SceneTree

# Regression: #404 global Weather may change while #231 Tankentai ACT
# charges. Recheck field PRIORITY and SOURCE at actual effect commit;
# never debit MP or damage under a stale preflight snapshot.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("FS #404 weather ACT race FAIL: " + detail)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(157)
    states[153] = {"id":153,"note":
        "<field_weather>\n<field_priority:10>\n<field_damage 13:+25>"}
    states[155] = {"id":155,"note":
        "<field_weather>\n<field_priority:30>\n<field_damage 13:-50>"}
    states[156] = {"id":156,"note":
        "<field_weather>\n<field_priority:20>\n<field_damage 13:+50>"}
    var enemies: Array = []
    enemies.resize(601)
    enemies[600] = {"id":600,"name":"Weather Dummy",
        "maxhp":1000,"maxmp":50,"atk":10,"def":5,
        "spi":3,"agi":10,"note":"","actions":[]}
    db.tables = {"states":states,"enemies":enemies,
        "skills":[null,null,{"id":2,"name":"Replace Weather",
            "scope":1,"occasion":0,"base_damage":100,"atk_f":0,
            "spi_f":0,"mp_cost":10,"note":"<field effect: 156>",
            "element_set":[13],"ignore_defense":false,
            "plus_state_set":[],"minus_state_set":[],
            "damage_to_mp":false,"absorb_damage":false}],
        "weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase) -> FSBattle:
    var battle = BATTLE.new(db)
    battle.party.append({"id":1,"name":"Hero","actor":true,
        "hp":500,"maxhp":500,"mp":100,"maxmp":100,"agi":20,
        "atk":20,"def":5,"spi":3,"odds":4,"skills":[2],
        "states":[],"note":"","element_set":[13],
        "equipment":[0,0,0,0,0],"two_swords_style":false})
    battle.add_enemy(600)
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    battle.field_weather.active = true
    return battle

func _run() -> void:
    var db: FSDatabase = _db()
    var battle: FSBattle = _battle(db)
    if not _check(battle.start(),"ACT race battle starts"): return
    var source: Dictionary = {"id":554,"hp":100}
    if not _check(battle.field_weather.set_field(db,153,source),
            "initial Field153 established"): return
    battle.advance_atb(40.0/60.0)
    if not _check(battle.queue_actor_action(0,"skill",0,2),
            "Field156 skill passes selection-time preflight under Field153"): return
    battle.advance_atb(5.0/60.0)
    var actor: Dictionary = battle.party[0]
    var enemy: Dictionary = battle.enemies[0]
    if not _check(int(actor["mp"])==100 and int(enemy["hp"])==1000 and
            battle.has_actor_pending_action(0),
            "five of ten ACT frames no early MP/damage/field change"): return
    # Boss/other source forces higher priority while player charges.
    if not _check(battle.field_weather.set_field(db,155,source,true),
            "forced Field155 priority30 overrides Field153 during ACT"): return
    battle.advance_atb(5.0/60.0)
    if not _check(int(actor["mp"])==100 and int(enemy["hp"])==1000 and
            battle.field_weather.current_id==155 and
            not battle.has_actor_pending_action(0) and
            not bool(battle.action_queue.completed[-1]["success"]),
            "ACT completion revalidates changed weather priority, no MP or effect"): return

    var after_death: FSBattle = _battle(db)
    if not _check(after_death.start(),"source-death battle starts"): return
    var dying_source: Dictionary = {"id":554,"hp":100}
    if not _check(after_death.field_weather.set_field(db,153,dying_source),
            "second battle starts under Field153"): return
    after_death.advance_atb(40.0/60.0)
    if not _check(after_death.queue_actor_action(0,"skill",0,2),
            "second ACT command queued with source alive"): return
    after_death.advance_atb(5.0/60.0)
    dying_source["hp"] = 0
    after_death.advance_atb(1.0/60.0)
    if not _check(after_death.field_weather.current_id==0 and
            int(after_death.party[0]["mp"])==100,
            "dead field owner clears the ONE global field before ACT, not after"): return
    after_death.advance_atb(4.0/60.0)
    if not _check(int(after_death.party[0]["mp"])==90 and
            int(after_death.enemies[0]["hp"])==900 and
            after_death.field_weather.current_id==156 and
            bool(after_death.action_queue.completed[-1]["success"]),
            "ACT resolves neutral100 damage after field cleared, then creates Field156 once"): return

    print("FS #404 weather ACT race, priority recheck, dead source clearing and single payment PASS")
    quit(0)
