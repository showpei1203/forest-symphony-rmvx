extends SceneTree

# Source: original RGSS2 BattleFormula TargetFix (~205017/205240),
# SupportStateRules (~271214), YEM VARYDMG=5 (~196832), and final
# CRITICAL_RATE=170 (~207765). Synthetic fixture only; not the real
# post-FS_DB_AUTOSET runtime or full 505 alias order witness.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool,why: String) -> bool:
    if not condition:
        push_error("FS native hit/eva/critical/variance FAIL: "+why)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    var enemies: Array = [
        null,{"id":1,"name":"AccuracyDummy",
            "maxhp":10000,"maxmp":1000,"atk":20,"def":10,
            "spi":10,"agi":15,"eva":5,"hit":95,"has_critical":false,
            "note":"","actions":[]}]
    var skills: Array = [
        null,{"id":1,"name":"Arc Bolt","scope":1,"base_damage":100,
            "variance":0,"hit":50,"physical_attack":false,
            "atk_f":0,"spi_f":0,"mp_cost":10,"ignore_defense":false,
            "plus_state_set":[],"minus_state_set":[],"element_set":[],
            "note":"","damage_to_mp":false,"absorb_damage":false,
            "has_critical":false},
        {"id":2,"name":"Physical Strike","scope":1,"base_damage":70,
            "variance":0,"hit":90,"physical_attack":true,
            "atk_f":0,"spi_f":0,"mp_cost":12,"ignore_defense":false,
            "plus_state_set":[],"minus_state_set":[],"element_set":[],
            "note":"","damage_to_mp":false,"absorb_damage":false,
            "has_critical":false},
        {"id":3,"name":"Heal","scope":7,"base_damage":-60,
            "variance":0,"hit":5,"physical_attack":false,
            "atk_f":0,"spi_f":0,"mp_cost":9,"ignore_defense":false,
            "plus_state_set":[],"minus_state_set":[],"element_set":[],
            "note":"","damage_to_mp":false,"absorb_damage":false,
            "has_critical":false}]
    db.tables={"enemies":enemies,"skills":skills,"states":[null],
        "weapons":[null],"armors":[null]}
    return db

func _battle() -> FSBattle:
    var b = BATTLE.new(_db())
    b.party.append({"id":1,"name":"Hero","actor":true,
        "hp":2000,"maxhp":2000,"mp":100,"maxmp":100,
        "atk":50,"def":10,"spi":20,"agi":20,
        "hit":95,"eva":5,"cri":10,"element_set":[1],
        "skills":[1,2,3],"states":[],"note":"",
        "equipment":[0,0,0,0,0],"two_swords_style":false})
    b.add_enemy(1)
    # Real data gate is still closed. A source-shaped fixture explicitly
    # opts in without changing the live boot verification policy.
    b.accuracy.active = true
    return b

func _run() -> void:
    var b = _battle()
    if not _check(b.start(),"battle begins"): return
    var hero: Dictionary = b.party[0]
    var enemy: Dictionary = b.enemies[0]
    var q: Dictionary = b.accuracy.quote(b,hero,enemy)
    if not _check(q.get("ok",false) and int(q["hit"])==95 and
            int(q["eva"])==5 and int(q["crit"])==10,
            "FS TargetFix 95/5/10 with AGI20 vs15"): return

    # ATB selection invokes pure preflight; only ACT completion consumes RNG.
    b.accuracy.scripted_rolls = [95]
    if not _check(b.attack_preflight(hero,enemy) and
            b.accuracy.draws.is_empty() and
            b.accuracy.scripted_rolls==[95],
            "attack command preflight must NOT consume hit RNG"): return
    var hp_before: int = int(enemy["hp"])
    if not _check(b.attack(hero,enemy)==0 and
            int(enemy["hp"])==hp_before and
            enemy["fs_last_action_result"]=="miss" and
            b.accuracy.draws.size()==1,
            "d100=95 misses 95pct; no EVA/CRI/variance or HP/MP mutation"): return

    b.accuracy.draws.clear()
    b.accuracy.scripted_rolls = [0,0]
    if not _check(b.attack(hero,enemy)==0 and
            int(enemy["hp"])==hp_before and
            enemy["fs_last_action_result"]=="evade" and
            b.accuracy.draws.size()==2,
            "HIT 0 succeeds and EVA 0 evades; no CRI/variance RNG"): return

    # Source YEM NATK.VARYDMG 5, so baseline180 has amp9.
    b.accuracy.draws.clear()
    b.accuracy.scripted_rolls = [0,99,99,0,9]
    if not _check(b.attack(hero,enemy)==180 and
            int(enemy["hp"])==hp_before-180 and
            not bool(enemy.get("fs_last_action_critical",true)) and
            b.accuracy.draws.size()==5 and
            b.accuracy.scripted_rolls.is_empty(),
            "noncritical HIT: 180 + 0 + 9 - 9 = 180, five exact RNG draws"): return

    hp_before = int(enemy["hp"])
    # 10% crit with d100=0: 180*1.7=306, amp15, draw0+9-15 =>300.
    b.accuracy.scripted_rolls = [0,99,0,0,9]
    if not _check(b.attack(hero,enemy)==300 and
            int(enemy["hp"])==hp_before-300 and
            bool(enemy.get("fs_last_action_critical",false)),
            "critical170% occurs before integer variance5% on stock candidate"): return

    enemy["agi"] = 80
    q = b.accuracy.quote(b,hero,enemy)
    if not _check(int(q["hit"])==86 and int(q["eva"])==9,
            "negative AGI delta60 lowers HIT by9, raises EVA by4"): return
    hero["ignore_eva"] = true
    q = b.accuracy.quote(b,hero,enemy)
    if not _check(int(q["eva"])==0,
            "KGC ignore_eva bypasses attack evasion despite high target AGI"): return
    hero.erase("ignore_eva")
    enemy["agi"] = 15

    # Never let a missing original State silently become zero EVA.
    enemy["states"] = [2]
    hp_before = int(enemy["hp"])
    b.accuracy.scripted_rolls = [0,99,99,0,9]
    if not _check(not b.attack_preflight(hero,enemy) and
            b.attack(hero,enemy)==0 and
            int(enemy["hp"])==hp_before and
            b.accuracy.scripted_rolls.size()==5,
            "State2 without source record fail-closes BEFORE RNG and HP mutation"): return
    enemy["states"] = []
    b.accuracy.scripted_rolls.clear()

    # Skill: source physical=false means EVA is zero regardless of
    # target.eva; a MISS is still a completed, MP-paid action.
    q = b.accuracy.quote(b,hero,enemy,b.db.record("skills",1))
    if not _check(int(q["hit"])==50 and int(q["eva"])==0,
            "magic skill HIT50, no physical EVA"): return
    b.accuracy.draws.clear()
    b.accuracy.scripted_rolls = [50]
    var mp_before: int = int(hero["mp"])
    hp_before = int(enemy["hp"])
    if not _check(b.skill_preflight(hero,enemy,1) and
            b.accuracy.scripted_rolls==[50] and
            b.use_skill(hero,enemy,1) and
            int(hero["mp"])==mp_before-10 and
            int(enemy["hp"])==hp_before and
            enemy["fs_last_action_result"]=="miss" and
            b.accuracy.draws.size()==1,
            "skill MISS pays MP10 but changes no target HP; no EVA roll"): return

    b.accuracy.scripted_rolls = [49,0]
    mp_before = int(hero["mp"])
    hp_before = int(enemy["hp"])
    if not _check(b.use_skill(hero,enemy,1) and
            int(hero["mp"])==mp_before-10 and
            int(enemy["hp"])==hp_before-100 and
            enemy["fs_last_action_result"]=="hit" and
            b.accuracy.scripted_rolls.is_empty(),
            "magic skill HIT49 and EVA d100 consumed even though EVA=0"): return

    b.accuracy.scripted_rolls = [0,0]
    mp_before = int(hero["mp"])
    hp_before = int(enemy["hp"])
    if not _check(b.use_skill(hero,enemy,2) and
            int(hero["mp"])==mp_before-12 and
            int(enemy["hp"])==hp_before and
            enemy["fs_last_action_result"]=="evade",
            "physical skill EVA=0 roll evades when target EVA5 and charges MP12"): return

    # SupportStateRules: friendly negative-base recovery skill has forced
    # 100% HIT and 0 EVA even when database hit=5.
    hero["hp"] = 1200
    b.accuracy.scripted_rolls = [99,0]
    q = b.accuracy.quote(b,hero,hero,b.db.record("skills",3))
    mp_before = int(hero["mp"])
    if not _check(int(q["hit"])==100 and int(q["eva"])==0 and
            b.use_skill(hero,hero,3) and
            int(hero["hp"])==1260 and int(hero["mp"])==mp_before-9,
            "native recovery scope7 always hits (99) and heals 60"): return

    # The raw roll injection enforces exact rand bounds and fails closed.
    b.accuracy.scripted_rolls = [100]
    hp_before = int(enemy["hp"])
    if not _check(b.attack(hero,enemy)==0 and
            int(enemy["hp"])==hp_before and
            not b.accuracy.failures.is_empty(),
            "invalid d100=100 does not silently cause a hit"): return

    print("FS BattleFormula HIT-EVA, CRIT170, VARYDMG5, MP-on-MISS, recovery and RNG guard PASS")
    quit(0)
