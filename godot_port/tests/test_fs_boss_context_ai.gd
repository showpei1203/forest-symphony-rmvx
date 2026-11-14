extends SceneTree

# Source #401 and MasterSetup #440 CONTEXT_ACTIONS are identical, with
# original boss-id ascending priority even when the boss died.
const CTX = preload("res://scripts/FSBossContext.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool,label: String) -> bool:
    if not ok:
        push_error("FS source Boss AI context FAIL: "+label)
        quit(1)
        return false
    return true

func _enemy(id: int,hp: int = 200) -> Dictionary:
    return {"id":id,"actor":false,"name":"Enemy%d" % id,
        "hp":hp,"maxhp":200,"mp":100,"maxmp":100,"agi":20,
        "atk":15,"def":4,"spi":3,"note":"","states":[],
        "actions":[{"kind":0,"basic":1,"skill_id":0,"rating":8,
          "condition_type":0,"condition_param1":0,"condition_param2":0}]}

func _skill(id: int) -> Dictionary:
    return {"id":id,"name":"Boss Source Skill%d" % id,
        "scope":1,"occasion":0,"base_damage":20,"atk_f":0,"spi_f":0,
        "mp_cost":10,"note":"","plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false}

func _run() -> void:
    if not _assert(CTX.CONTEXT_ACTIONS.size()==15,
            "MasterSetup 15 contains exactly 15 Boss core context IDs 551..565"): return
    for id in range(551,566):
        if not _assert(CTX.has_core(id),"core id present %d" % id): return

    var battlers: Array[Dictionary] = [
        _enemy(551),_enemy(540),_enemy(507,0)
    ]
    var matching: Dictionary = CTX.resolve(551,battlers)
    if not _assert(matching["matched"] and matching["boss_id"]==507 and
            matching["actions"].size()==2 and
            matching["actions"][0]["skill_id"]==316 and
            matching["actions"][1]["skill_id"]==317,
            "source sorted Boss507 overrides Boss540 even when Boss507 dead"): return
    battlers.remove_at(2)
    matching = CTX.resolve(551,battlers)
    if not _assert(matching["matched"] and matching["boss_id"]==540 and
            matching["actions"][0]["skill_id"]==300 and
            matching["actions"][1]["skill_id"]==302 and
            matching["actions"][1]["rating"]==8,
            "source Boss540 changes Core551 to Skill300/302"): return
    matching = CTX.resolve(551,[_enemy(551)])
    if not _assert(not matching["matched"],
            "unmatched Boss context must delegate to original Enemy.actions"): return
    matching = CTX.resolve(558,[_enemy(558),_enemy(548),_enemy(521)])
    if not _assert(matching["boss_id"]==521 and
            matching["actions"][0]["skill_id"]==333 and
            matching["actions"][1]["skill_id"]==334,
            "Core558 chooses lowest present BossID 521 ahead of 548"): return
    matching = CTX.resolve(565,[_enemy(565),_enemy(531)])
    if not _assert(matching["boss_id"]==531 and
            matching["actions"][0]["skill_id"]==308 and
            matching["actions"][1]["skill_id"]==352,
            "MasterSetup Boss531 Core565 exact action mapping"): return
    matching = CTX.resolve(553,[_enemy(553),_enemy(542)])
    if not _assert(matching["actions"][0]["kind"]==0 and
            matching["actions"][0]["basic"]==0 and
            matching["actions"][0]["rating"]==5 and
            matching["actions"][1]["skill_id"]==304,
            "source mixed basic attack + skill context preserved"): return

    var db = DB.new()
    var skill_rows: Array = []
    skill_rows.resize(353)
    for sid in [300,302,316,317,333,334,304,308,352]:
        skill_rows[sid] = _skill(sid)
    db.tables = {"skills":skill_rows,"armors":[null],"weapons":[null]}
    var battle = BATTLE.new(db)
    battle.party.append({"id":1,"actor":true,"name":"Hero",
        "hp":500,"maxhp":500,"mp":70,"maxmp":70,"agi":10,"odds":4,
        "equipment":[0,0,0,0,0],"two_swords_style":false,
        "note":"","states":[]})
    var core: Dictionary = _enemy(551)
    battle.enemies.append(core)
    battle.enemies.append(_enemy(540,0))
    battle.source_atb_rolls_for_test = {
        "actor:0":0,"enemy:0":0,"enemy:1":0
    }
    battle.action_queue.ai_rng.enable_test(42)
    if not _assert(battle.start(),"synthetic battle starts with living Core551"): return
    battle.advance_atb(90.0/60.0)
    if not _assert(battle.action_queue.enemy_pending.has("enemy:0"),
            "Core551 automatically queues Boss-specific choice at ATB ready"): return
    var queued: Dictionary = battle.action_queue.enemy_pending["enemy:0"]
    if not _assert(queued["kind"]=="skill" and
            int(queued["object_id"]) in [300,302] and
            core["mp"]==100 and battle.party[0]["hp"]==500,
            "Boss context overrides raw guard but does not spend MP before ACT"): return
    battle.advance_atb(10.0/60.0)
    if not _assert(core["mp"]==90 and battle.party[0]["hp"]==480 and
            battle.action_queue.enemy_pending.is_empty() and
            battle.action_queue.completed.size()==1,
            "Core551 context skill actually resolves after ACT, spends MP once"): return

    var no_boss = BATTLE.new(db)
    no_boss.party.append({"id":1,"actor":true,"name":"Hero",
        "hp":500,"maxhp":500,"agi":10,"odds":4,"states":[],"note":""})
    no_boss.enemies.append(_enemy(551))
    var raw_choice: Dictionary = FSEnemyAIDecision.choose(
        no_boss,0,battle.action_queue.ai_rng)
    if not _assert(raw_choice.get("ok",false) and raw_choice["kind"]=="guard",
            "without Boss, Core551 uses original Enemy.actions guard instead"): return
    print("FS Boss #401/#440 context mapping all cores, order/dead boss, real ACT/MP and fallback PASS")
    quit(0)
