extends SceneTree

# #372 final TargetPriority / Game_Unit random_target:
# Provoke State14 first, then legal weighted candidates; manual selected
# enemy constrained by highest enemy/state Note priority.
const TARGET = preload("res://scripts/FSTargetPriority.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const RNG = preload("res://scripts/FSAIRandom.gd")
const SCREEN = preload("res://scripts/FSScreen.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const MENU = preload("res://scripts/FSMenuModel.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool,label: String) -> bool:
    if not ok:
        push_error("FS Target Priority #372 FAIL: "+label)
        quit(1)
        return false
    return true

func _enemy(id: int,note: String = "") -> Dictionary:
    return {"id":id,"name":"Enemy%d" % id,"actor":false,"note":note,
        "hp":200,"maxhp":200,"agi":10,"atk":8,"def":3,"spi":2,
        "mp":10,"maxmp":10,"states":[],"actions":[]}

func _run() -> void:
    var db = DB.new()
    var state_rows: Array = []
    state_rows.resize(30)
    state_rows[22] = {"id":22,"note":"<target_priority: 12>"}
    db.tables = {"states":state_rows,"skills":[null,
        {"id":1,"note":"<ignore target priority>","scope":1}],
        "armors":[null],"weapons":[null]}
    var battle = BATTLE.new(db)
    battle.party.append({"id":1,"name":"Hero","actor":true,
        "hp":400,"maxhp":400,"agi":20,"atk":15,"mp":50,"maxmp":50,
        "equipment":[0,0,0,0,0],"two_swords_style":false,
        "odds":4,"states":[],"note":""})
    battle.enemies.append(_enemy(1,"<target priority: 2>"))
    battle.enemies.append(_enemy(2,"<target_priority: 5>"))
    if not _assert(battle.start(),"priority battle start"): return
    var allowed: Dictionary = TARGET.player_enemy_candidates(battle)
    if not _assert(allowed["ok"] and allowed["indices"]==[1] and
            allowed["priority"]==5,
            "highest Note priority 5 restricts manual selected enemy"): return
    allowed = TARGET.player_enemy_candidates(battle,1)
    if not _assert(allowed["ok"] and allowed["indices"]==[0,1],
            "source ignore priority Note exposes both enemies"): return
    if not _assert(TARGET._priority("<目標優先： 8>")==8 and
            TARGET._priority("<target-priority>")==1,
            "source Chinese and naked alias priority tags parsed"): return

    var ui = SCREEN.new()
    root.add_child(ui)
    ui.db = db
    ui.world = WORLD.new()
    ui.battle = battle
    ui.menu_model = MENU.new(db,battle)
    ui._select_enemy_target(Callable(self,"_noop"))
    var buttons: Array[String] = []
    for child in ui.body.get_children():
        if child is Button:
            buttons.append(child.text)
    if not _assert(buttons.any(func(t: String)->bool: return "Enemy2" in t) and
            not buttons.any(func(t: String)->bool: return "Enemy1" in t),
            "UI exposes only source legal highest-priority enemy"): return
    battle.party[0]["source_at_active"] = true
    battle.party[0]["source_atb_count_up"] = false
    if not _assert(not battle.queue_actor_action(0,"attack",0) and
            not battle.has_actor_pending_action(0),
            "direct queue API also rejects illegal lower-priority enemy"): return
    if not _assert(battle.queue_actor_action(0,"attack",1) and
            battle.has_actor_pending_action(0),
            "queue accepts highest-priority target when source ATB ready"): return

    battle.enemies[0]["states"] = [14]
    allowed = TARGET.player_enemy_candidates(battle)
    if not _assert(allowed["indices"]==[0] and
            allowed["priority"]==1000,
            "enemy State14 Provoke outranks Note5 in manual targeting"): return
    battle.enemies[0]["states"] = [22]
    allowed = TARGET.player_enemy_candidates(battle)
    if not _assert(allowed["indices"]==[0] and allowed["priority"]==12,
            "State Note priority 12 outranks enemy Note5"): return
    battle.enemies[0]["states"] = [27]
    allowed = TARGET.player_enemy_candidates(battle)
    if not _assert(not allowed["ok"],
            "untranslated Enemy State note fails closed"): return
    battle.enemies[0]["states"] = []
    battle.enemies[1]["friendly"] = true
    allowed = TARGET.player_enemy_candidates(battle)
    if not _assert(allowed["indices"]==[0],
            "source excludes friendly monsters from player manual target"): return

    var rng = RNG.new()
    rng.enable_test(12345)
    var battle2 = BATTLE.new(db)
    battle2.party.append({"id":1,"actor":true,"hp":400,
        "maxhp":400,"states":[],"note":"","odds":4})
    battle2.party.append({"id":2,"actor":true,"hp":300,
        "maxhp":300,"states":[14],"note":"","odds":1})
    if not _assert(TARGET.random_target(battle2,"actor",rng)==1,
            "enemy random attack picks Provoke actor even with lower odds"): return
    battle2.party[1]["states"] = []
    battle2.party[0]["hp"] = 0
    if not _assert(TARGET.random_target(battle2,"actor",rng)==1,
            "dead frontline actor excluded, backline actor selected"): return
    battle2.party[0]["hp"] = 400
    battle2.party[1]["states"] = [22]
    if not _assert(TARGET.random_target(battle2,"actor",rng)==-1,
            "unknown actor status cannot be silently treated as targetable"): return
    battle2.party[1]["states"] = []
    battle2.party[0]["note"] = "<unknown target override>"
    if not _assert(TARGET.random_target(battle2,"actor",rng)==-1,
            "unknown actor target note blocks source random selection"): return

    print("FS TargetPriority #372 Note/State/Provoke, UI/queue enforcement and target safety PASS")
    quit(0)

func _noop(_target: Dictionary) -> void:
    pass
