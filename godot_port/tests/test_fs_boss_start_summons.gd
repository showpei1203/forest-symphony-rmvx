extends SceneTree

# Original #401/#440 START_SUMMONS, no duplicates, source troop cap8,
# special Boss510/511, actor/summoned source ATB and Boss-context AI.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const SUMMON = preload("res://scripts/FSBossSummonRuntime.gd")
const AI = preload("res://scripts/FSEnemyAIDecision.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,detail: String) -> bool:
    if not ok:
        push_error("FS Boss initial summons FAIL: "+detail)
        quit(1)
        return false
    return true

func _enemy(id: int,hp: int = 100) -> Dictionary:
    return {"id":id,"name":"Enemy%d" % id,"note":"<fs_fixed_enemy_stats>",
        "maxhp":hp,"maxmp":100,"atk":20,"def":5,"spi":4,"agi":20,
        "exp":10,"gold":5,"actions":[{"kind":0,"basic":0,"skill_id":0,
            "rating":8,"condition_type":0,"condition_param1":0,
            "condition_param2":0}],"states":[]}

func _db() -> FSDatabase:
    var db = DB.new()
    var rows: Array = []
    rows.resize(746)
    for id in [500,501,503,507,510,511,540,551,554,555,556,600,659]:
        rows[id] = _enemy(id,100 if id!=551 else 240)
    # Test source Boss500 growth is checked separately (guard/missing level).
    var skill_rows: Array = []
    skill_rows.resize(318)
    for id in [316,317]:
        skill_rows[id] = {"id":id,"name":"Core spell%d" % id,
            "scope":1,"occasion":0,"mp_cost":10,"note":"",
            "base_damage":20,"atk_f":0,"spi_f":0,"ignore_defense":false,
            "plus_state_set":[],"minus_state_set":[],
            "damage_to_mp":false,"absorb_damage":false}
    db.tables={"enemies":rows,"skills":skill_rows,
        "weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase) -> FSBattle:
    var b = BATTLE.new(db)
    b.party.append({"id":1,"actor":true,"name":"Hero","hp":500,
        "maxhp":500,"mp":100,"maxmp":100,"agi":15,"atk":10,
        "equipment":[0,0,0,0,0],"two_swords_style":false,
        "states":[],"note":"","odds":4})
    b.boss_runtime.active = true
    b.source_atb_rolls_for_test = {
        "actor:0":0,"enemy:0":0,"enemy:1":0,"enemy:2":0,
        "enemy:3":0,"enemy:4":0,"enemy:5":0,
        "enemy:6":0,"enemy:7":0
    }
    return b

func _run() -> void:
    if not _check(SUMMON.START_SUMMONS.has(507) and
            SUMMON.CORE_GROUPS.get(540,[])==[551] and
            SUMMON.MAX_ENEMIES==8,
            "source #401/#440 authoritative start/group constants"): return

    var db = _db()
    var battle = _battle(db)
    if not _check(battle.add_enemy(507) and battle.add_enemy(551),
            "original Boss507 and preplaced one Core551"): return
    if not _check(battle.start(),"start source-shaped battle"): return
    var actor_start: int = int(battle.party[0]["source_atb_count"])
    var source_enemy_start: int = int(battle.enemies[0]["source_atb_count"])
    battle.advance_atb(1.0/60.0)
    if not _check(battle.enemies.size()==3 and
            SUMMON._count(battle.enemies,551)==2 and
            battle.boss_runtime.flags.has("start:507"),
            "Boss507 fills only ONE missing Core551, preplaced core not duplicated"): return
    if not _check(battle.enemies[2]["hp"]==240 and
            battle.enemies[2]["mp"]==100 and
            battle.enemies[2]["fs_boss_runtime_scale"]==100 and
            battle.enemies[2]["source_atb_count"]==100 and
            battle.enemies[2]["source_atb_gain_per_frame"]==10,
            "new core has correct verified 100% full HP/MP and source ATB init"): return
    if not _check(int(battle.party[0]["source_atb_count"])==actor_start+
            int(battle.party[0]["source_atb_gain_per_frame"]) and
            int(battle.enemies[0]["source_atb_count"])==source_enemy_start+10,
            "no existing actor/enemy ATB reset when summoning"): return
    battle.advance_atb(1.0/60.0)
    if not _check(battle.enemies.size()==3 and
            int(battle.enemies[2]["source_atb_count"])==110,
            "newly summoned core starts ticking NEXT source frame, no duplicates"): return
    var chosen: Dictionary = AI.choose(battle,2,battle.action_queue.ai_rng)
    if not _check(chosen.get("ok",false) and chosen["kind"]=="skill" and
            int(chosen["object_id"]) in [316,317],
            "summoned Core551 immediately sees original Boss507 context skills"): return

    var self_summon = _battle(db)
    self_summon.add_enemy(503)
    self_summon.start()
    self_summon.advance_atb(1.0/60.0)
    if not _check(self_summon.enemies.size()==2 and
            SUMMON._count(self_summon.enemies,503)==2,
            "Boss503 summons itself to desired count2, existing source counts as one"): return
    self_summon.advance_atb(1.0)
    if not _check(self_summon.enemies.size()==2,
            "Boss503 source start flag prevents repeated summons"): return

    var altar = _battle(db)
    altar.add_enemy(510)
    altar.boss_runtime.rng.enable_test(12345)
    altar.start()
    altar.advance_atb(1.0/60.0)
    if not _check(altar.enemies.size()==2 and
            int(altar.enemies[1]["id"]) in [554,555,556] and
            altar.boss_runtime.rng.trace[0]["tag"]=="boss_altar_pick" and
            altar.boss_runtime.flags.has("altar:510"),
            "Boss510 altar picks one of 554/555/556 once by FS_AI_RANDOM"): return
    altar.advance_atb(1.0)
    if not _check(altar.enemies.size()==2 and
            altar.boss_runtime.rng.trace.size()==1,
            "altar selection not rerolled on each source frame"): return

    var elite = _battle(db)
    # Preplaced 500 means source Boss511 must not add extra 500 if picked.
    for id in range(500,511):
        if db.record("enemies",id).is_empty():
            var patch: Dictionary = db.tables["enemies"][500].duplicate(true)
            patch["id"] = id
            patch["name"] = "Enemy%d" % id
            db.tables["enemies"][id] = patch
    elite.add_enemy(511)
    elite.boss_runtime.rng.enable_test(42)
    elite.start()
    elite.advance_atb(1.0/60.0)
    if not _check(elite.enemies.size()==3 and
            elite.boss_runtime.rng.trace.size()==2 and
            int(elite.enemies[1]["id"])!=int(elite.enemies[2]["id"]) and
            elite.enemies[1]["fs_boss_runtime_scale"]==72 and
            elite.enemies[2]["fs_boss_runtime_scale"]==72 and
            elite.enemies[1]["maxhp"]==72,
            "Boss511 chooses two distinct 500..510 elites and scales fixed HP to72%"): return

    var capped = _battle(db)
    capped.add_enemy(507)
    for i in range(6):
        capped.add_enemy(551)
    capped.start()
    capped.advance_atb(1.0/60.0)
    if not _check(capped.enemies.size()==7 and
            capped.boss_runtime.flags.has("start:507"),
            "count includes existing enemies so no duplicate when desired fulfilled"): return

    print("FS Boss #401 start summoned cores/503-self/510 RNG/511 pair scale, no duplicates, cap and ATB PASS")
    quit(0)
