extends SceneTree

# Real source: AntagonistCore RGSS2 law_cycle_states, interval precedence,
# conditional State151, execute_action.valid? post-completion hook, and
# BossRuntime #401 HP70/35 transitions. Synthetic ID-only verification:
# this does NOT certify actual RPG::State buffs or enemy attack outcomes.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const LAW = preload("res://scripts/FSBossLawCycle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,why: String) -> bool:
    if not ok:
        push_error("FS AntagonistCore law-cycle FAIL: "+why)
        quit(1)
        return false
    return true

func _db(note: String) -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    for sid in [140,141,142,143,150,151,152]:
        states[sid] = {"id":sid,"name":"Source shaped State%d" % sid}
    var enemies: Array = []
    enemies.resize(525)
    enemies[524] = {"id":524,"name":"Law Boss",
        "maxhp":1000,"maxmp":100,"atk":30,"def":20,
        "spi":10,"agi":10,"note":note,
        "actions":[{"kind":0,"basic":0,"skill_id":0,"rating":8,
            "condition_type":0,"condition_param1":0,"condition_param2":0}]}
    db.tables={"states":states,"enemies":enemies,
        "skills":[null],"weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase) -> FSBattle:
    var b = BATTLE.new(db)
    b.party.append({"id":1,"name":"Hero","actor":true,
        "hp":500,"maxhp":500,"mp":100,"maxmp":100,"agi":20,
        "atk":20,"def":10,"spi":10,"states":[],"note":"",
        "equipment":[0,0,0,0,0],"two_swords_style":false,"odds":4})
    b.add_enemy(524)
    b.boss_runtime.active = true
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    return b

func _run() -> void:
    var note: String = "<law_cycle_states:140,141,142,143>\n" +         "<law_cycle_interval:3>\n<law_cycle_actions:1>\n<law_cycle_if_state:151>"
    var db = _db(note)
    var b = _battle(db)
    if not _check(b.start(),"Boss battle starts"): return
    var boss: Dictionary = b.enemies[0]
    if not _check(boss.get("fs_phase_state_intents",[]).is_empty(),
            "condition State151 not present at battle start"): return
    b.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[150] and
            not bool(boss.get("fs_law_active",false)),
            "HP100% means State150 without a law cycle"): return
    boss["hp"] = 700
    b.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[151,140] and
            bool(boss.get("fs_law_active",false)) and
            int(boss.get("fs_law_action_count",-1))==0 and
            boss.get("states",[]).is_empty(),
            "HP70% starts Note-driven first Law140 INTENT, no fake RPG State"): return
    b.advance_atb(8.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[151,140] and
            int(boss["fs_law_action_count"])==0,
            "60fps encounter updates never count as completed enemy actions"): return
    for k in range(2):
        b.enemy_valid_action_completed(boss)
    if not _check(boss["fs_phase_state_intents"]==[151,140] and
            int(boss["fs_law_action_count"])==2,
            "two valid actions hold Law140; current interval3 wins legacy actions1"): return
    b.enemy_valid_action_completed(boss)
    if not _check(boss["fs_phase_state_intents"]==[151,141] and
            int(boss["fs_law_action_count"])==0,
            "third completed action rotates Law140 to Law141 exactly once"): return
    for k in range(9):
        b.enemy_valid_action_completed(boss)
    if not _check(boss["fs_phase_state_intents"]==[151,140],
            "Law141 -> 142 -> 143 -> 140 wraps after nine more actions"): return
    boss["hp"] = 350
    b.source_atb_wait = true
    b.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[152] and
            not bool(boss.get("fs_law_active",true)) and
            int(boss.get("fs_law_action_count",-1))==0,
            "HP35% removes State151 and laws during ATB WAIT, resets counter"): return
    b.enemy_valid_action_completed(boss)
    if not _check(boss["fs_phase_state_intents"]==[152],
            "invalid law condition does not rotate after third phase"): return
    boss["hp"] = 600
    b.advance_atb(1.0/60.0)
    if not _check(boss["fs_phase_state_intents"]==[152,151,140] and
            int(boss["fs_law_action_count"])==0,
            "source healing to middle HP re-adds State151 and starts first Law"): return

    var legacy: String = "<law_cycle_states:140,141>\n" +         "<law_cycle_actions:2>\n<law_cycle_if_state:151>"
    var old = _battle(_db(legacy))
    if not _check(old.start(),"legacy alias fixture starts"): return
    old.enemies[0]["hp"] = 700
    old.advance_atb(1.0/60.0)
    old.enemy_valid_action_completed(old.enemies[0])
    if not _check(old.enemies[0]["fs_phase_state_intents"]==[151,140],
            "one valid action does not rotate legacy actions2"): return
    old.enemy_valid_action_completed(old.enemies[0])
    if not _check(old.enemies[0]["fs_phase_state_intents"]==[151,141],
            "legacy law_cycle_actions2 rotates on second action"): return

    var missing = _db(note)
    missing.tables["states"][141] = null
    var denied = _battle(missing)
    denied.start()
    denied.enemies[0]["hp"] = 700
    denied.advance_atb(1.0/60.0)
    if not _check(denied.enemies[0]["fs_phase_state_intents"]==[151] and
            not bool(denied.enemies[0].get("fs_law_active",false)) and
            bool(denied.enemies[0].get("fs_law_cycle_authority_pending",false)),
            "missing any law State rejects whole start, no partial add"): return
    var none = _battle(_db(""))
    none.start()
    none.enemies[0]["hp"] = 700
    none.advance_atb(1.0/60.0)
    if not _check(none.enemies[0]["fs_phase_state_intents"]==[151] and
            bool(none.enemies[0].get("fs_law_cycle_authority_pending",false)),
            "missing source Note never invents Law140"): return

    var unconditional = _battle(_db(
        "<law_cycle_states:140,141>\n<law_cycle_interval:2>"))
    unconditional.start()
    if not _check(unconditional.enemies[0]["fs_phase_state_intents"]==[140] and
            bool(unconditional.enemies[0].get("fs_law_active",false)),
            "unconditional law source starts on battle start, before HP phase"): return
    print("FS AntagonistCore law-cycle source Notes, HP70/35, ACT count, alias, fail-closed PASS")
    quit(0)
