extends SceneTree

# #401 Boss thresholds 520=70%->557x1, 547=60%->558x2,
# source 8-member cap, verified growth-level gate and missing-table safety.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const SUMMON = preload("res://scripts/FSBossSummonRuntime.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,label: String) -> bool:
    if not ok:
        push_error("FS Boss thresholds/growth FAIL: "+label)
        quit(1)
        return false
    return true

func _row(id: int,note: String = "<fs_fixed_enemy_stats>",
        hp: int = 1000) -> Dictionary:
    return {"id":id,"name":"Enemy%d" % id,"note":note,
        "maxhp":hp,"maxmp":100,"atk":40,"def":30,"spi":20,
        "agi":10,"exp":10,"gold":10,"actions":[{"kind":0,"basic":0,
        "skill_id":0,"rating":8,"condition_type":0,
        "condition_param1":0,"condition_param2":0}]}

func _db() -> FSDatabase:
    var db = DB.new()
    var rows: Array = []
    rows.resize(746)
    for id in [500,520,547,557,558,600]:
        rows[id] = _row(id)
    rows[600] = _row(600,"",150)
    db.tables={"enemies":rows,"skills":[null],
        "weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase) -> FSBattle:
    var b = BATTLE.new(db)
    b.party.append({"id":1,"actor":true,"name":"Hero",
        "hp":500,"maxhp":500,"mp":100,"maxmp":100,
        "agi":15,"atk":20,"equipment":[0,0,0,0,0],
        "two_swords_style":false,"note":"","states":[],"odds":4})
    b.boss_runtime.active = true
    b.source_atb_rolls_for_test = {
        "actor:0":0,"enemy:0":0,"enemy:1":0,
        "enemy:2":0,"enemy:3":0,"enemy:4":0,
        "enemy:5":0,"enemy:6":0,"enemy:7":0
    }
    return b

func _run() -> void:
    var db = _db()
    var b = _battle(db)
    if not _check(b.add_enemy(520) and b.start(),"Boss520 source battle"): return
    var boss: Dictionary = b.enemies[0]
    boss["hp"] = 701
    b.advance_atb(1.0/60.0)
    if not _check(b.enemies.size()==1 and
            not b.boss_runtime.flags.has("threshold:520"),
            "HP 701/1000 above threshold70% must NOT summon"): return
    boss["hp"] = 700
    b.advance_atb(1.0/60.0)
    if not _check(b.enemies.size()==2 and
            int(b.enemies[1]["id"])==557 and
            b.boss_runtime.flags.has("threshold:520"),
            "exact 70% HP triggers Boss520 one Core557"): return
    b.advance_atb(1.0)
    if not _check(b.enemies.size()==2,
            "threshold flag makes Boss520 summon once only"): return

    var c = _battle(db)
    c.add_enemy(547)
    c.start()
    c.enemies[0]["hp"] = 600
    c.advance_atb(1.0/60.0)
    if not _check(c.enemies.size()==3 and
            SUMMON._count(c.enemies,558)==2 and
            c.boss_runtime.flags.has("threshold:547"),
            "Boss547 HP exactly60% summons Core558 x2"): return

    var growth = _battle(db)
    growth.add_enemy(500)
    growth.start()
    growth.advance_atb(1.0/60.0)
    if not _check(growth.enemies.size()==1 and
            not growth.boss_runtime.flags.has("start:500") and
            not growth.boss_runtime.failures.is_empty(),
            "Pokemon600 without Game_Enemy.level witness refuses and never flags summon"): return
    db.tables["enemies"][600]["fs_runtime_level_verified"] = true
    db.tables["enemies"][600]["fs_runtime_level"] = 10
    growth.advance_atb(1.0/60.0)
    if not _check(growth.enemies.size()==3 and
            SUMMON._count(growth.enemies,600)==2 and
            growth.boss_runtime.flags.has("start:500"),
            "Pokemon600 with explicit runtime-level witness can be spawned x2"): return
    var pokemon: Dictionary = growth.enemies[1]
    var basehp: int = int((((2.0*150.0+31.0)*10.0/100.0)+10.0+10.0)*6.5)
    var basemp: int = int(((((2.0*100.0+31.0)*10.0/100.0)+10.0+10.0))*2.2)
    if not _check(int(pokemon["maxhp"])==basehp and
            int(pokemon["maxmp"])==basemp and
            int(pokemon["level"])==10 and
            pokemon["fs_boss_stat_mode"]=="growth",
            "source #401 growth HP/MP formula applied at verified runtime level10"): return

    # A missing second enemy table must fail before even the first in the
    # batch is appended. Never produce a partially drawn pair.
    var missing = _battle(_db())
    missing.add_enemy(547)
    missing.start()
    missing.enemies[0]["hp"] = 600
    missing.db.tables["enemies"][558] = null
    missing.advance_atb(1.0/60.0)
    if not _check(missing.enemies.size()==1 and
            not missing.boss_runtime.flags.has("threshold:547"),
            "missing source enemy blocks entire batch and no flag is set"): return

    var cap = _battle(db)
    cap.add_enemy(547)
    for i in range(6):
        cap.add_enemy(557)
    cap.start()
    cap.enemies[0]["hp"] = 600
    cap.advance_atb(1.0/60.0)
    if not _check(cap.enemies.size()==8 and
            SUMMON._count(cap.enemies,558)==1 and
            cap.boss_runtime.flags.has("threshold:547"),
            "source cap8 allows only 1 missing Core558 when troop has7"): return

    print("FS Boss threshold 70/60%, growth witness and stat formulas, missing batch, 8-cap PASS")
    quit(0)
