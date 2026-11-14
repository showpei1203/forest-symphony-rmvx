extends SceneTree

# #210 deterministic AI RNG, #211 enhanced roulette (not stock VX),
# #406 final enemy attack-rate override, and fail-closed runtime conditions.
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const AI = preload("res://scripts/FSEnemyAIDecision.gd")
const RNG = preload("res://scripts/FSAIRandom.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, info: String) -> bool:
    if not ok:
        push_error("FS source enemy AI FAIL: "+info)
        quit(1)
        return false
    return true

func _row(kind: int,basic: int,skill_id: int,rating: int,
        cond: int = 0,a: int = 0,b: int = 0) -> Dictionary:
    return {"kind":kind,"basic":basic,"skill_id":skill_id,"rating":rating,
        "condition_type":cond,"condition_param1":a,"condition_param2":b}

func _skill(id: int,scope: int = 1,damage: int = 20) -> Dictionary:
    return {"id":id,"name":"Enemy Skill%d" % id,"scope":scope,
        "mp_cost":10,"note":"","base_damage":damage,"atk_f":0,"spi_f":0,
        "plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false}

func _run() -> void:
    var rng = RNG.new()
    rng.enable_test(12345)
    var randoms: Array[int] = []
    for maxval in [100,10,7,1000]:
        randoms.append(rng.roll(maxval,"source_test"))
    if not _check(randoms==[6,5,3,573] and rng.trace.size()==4,
            "identical LCG from #210 source selftest 12345"): return
    if not _check(rng.trace[0]["tag"]=="source_test",
            "deterministic decision trace captures source tag"): return

    var db = DB.new()
    db.tables = {"skills":[null,_skill(1),_skill(2),_skill(3,7,-20)]}
    var world = WORLD.new()
    var battle = BATTLE.new(db,world)
    battle.party.append({"id":1,"actor":true,"name":"Front","hp":400,
        "maxhp":500,"agi":20,"level":5,"odds":4,"states":[],"note":""})
    battle.enemies.append({"id":600,"actor":false,"name":"Hunt Beast",
        "hp":200,"maxhp":200,"mp":100,"maxmp":100,"agi":10,
        "states":[],"note":"","actions":[]})
    var enemy: Dictionary = battle.enemies[0]

    enemy["actions"] = [_row(0,0,0,4),_row(0,1,0,8)]
    rng.enable_test(1) # first roll(12)=6, chooses second guard action.
    var choice: Dictionary = AI.choose(battle,0,rng)
    if not _check(choice.get("ok",false) and choice["kind"]=="guard" and
            int(rng.trace[0]["maximum"])==12,
            "#211 true roulette weights [4,8], not stock VX rating-max-minus3"): return
    enemy["actions"] = [_row(0,0,0,8),_row(0,1,0,4)]
    rng.enable_test(1)
    choice = AI.choose(battle,0,rng)
    if not _check(choice.get("ok",false) and choice["kind"]=="attack" and
            int(rng.trace[0]["maximum"])==8,
            "#211 lower subsequent rating skipped after high_rating encountered"): return

    enemy["actions"] = [_row(1,0,1,8)]
    rng.enable_test(47) # roulette4, attack_distribution5 < base70
    choice = AI.choose(battle,0,rng)
    if not _check(choice.get("ok",false) and choice["kind"]=="attack" and
            rng.trace.size()==3 and
            rng.trace[1]["tag"]=="enemy_attack_distribution",
            "#406 converts skill to attack at source attack_rate70"): return
    if not _check(not bool(enemy.get("fs_ead_last_damage_skill",true)),
            "final source history is attack, not discarded damage skill"): return
    rng.enable_test(1) # roulette6, distribution75 >=70
    choice = AI.choose(battle,0,rng)
    if not _check(choice.get("ok",false) and choice["kind"]=="skill" and
            int(choice["object_id"])==1 and
            enemy.get("fs_ead_last_damage_skill",false),
            "#406 retains positive damage skill when attack distribution roll75"): return
    if not _check(AI.attack_rate(enemy,1,1)==90,
            "last positive skill bonus20 grows base70 to90"): return
    enemy["fs_ead_last_damage_skill"] = false
    enemy["note"] = "<enemy_attack_rate: 0>"
    if not _check(AI.attack_rate(enemy,1,1)==15,
            "#406 explicit fixed rate clamps to minimum15"): return
    enemy["note"] = "<break_threshold: 3>\n<enemy_attack_rate_add: -8>"
    if not _check(AI.attack_rate(enemy,2,4)==67,
            "#406 party2 55 + break10 + outnumber10 - note8 =67"): return
    enemy["note"] = "<enemy_action_dist_off>"
    rng.enable_test(47)
    choice = AI.choose(battle,0,rng)
    if not _check(choice["kind"]=="skill" and rng.trace.size()==2,
            "distribution off note prevents attack replacement & extra RNG"): return

    enemy["note"] = ""
    enemy["id"] = 50
    enemy["actions"] = [_row(0,0,0,8,2,0,40)]
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "HP above 40% blocks conditional action rather than attacks"): return
    enemy["hp"] = 60
    rng.enable_test(1)
    choice = AI.choose(battle,0,rng)
    if not _check(choice.get("ok",false) and choice["kind"]=="attack",
            "HP <=40 condition passes when enemy is at 30%"): return
    enemy["actions"] = [_row(0,0,0,8,1,2,2)]
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "turn-count conditional fails closed until VX troop turn witness"): return
    enemy["actions"] = [_row(0,0,0,8),_row(1,0,83,5)]
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "EnemyActionPattern skill83 chained conditional not approximated"): return
    enemy["actions"] = [_row(0,0,0,8),_row(1,0,99,5)]
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "unsupported candidate blocks entire roulette, not biasing odds"): return
    enemy["actions"] = [_row(0,0,0,8)]
    enemy["id"] = 551
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "Boss context action override 551 requires runtime provider"): return
    enemy["id"] = 50
    battle.party[0]["states"] = [14]
    if not _check(AI.choose(battle,0,rng).get("ok",false),
            "source #372 verified Provoke State14 accepted as random-target priority"): return
    battle.party[0]["states"] = [22]
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "unverified non-Provoke status still blocks random targeting"): return
    battle.party[0]["states"] = []
    world.set_switch(10,true)
    enemy["actions"] = [_row(0,0,0,8,6,10,0)]
    if not _check(AI.choose(battle,0,rng).get("ok",false),
            "source VX switch condition uses shared FSGameState"): return
    enemy["actions"] = [_row(0,0,0,8,6,121,0)]
    if not _check(not AI.choose(battle,0,rng).get("ok",false),
            "EnemyActionPattern switch121..130 unresolved targets blocked"): return

    print("FS Enemy AI #210/#211/#406 roulette, attack rate, conditions, and source guards PASS")
    quit(0)
