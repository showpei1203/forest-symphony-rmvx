extends SceneTree

# Source Tankentai 1.2c ATB is not merely a headless model:
# Godot BATTLE Control must tick and report each actual party/enemy gauge.
const SCREEN = preload("res://scripts/FSScreen.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const MENU = preload("res://scripts/FSMenuModel.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS Tankentai ATB BATTLE UI FAIL: "+label)
        quit(1)
        return false
    return true

func _run() -> void:
    var db = DB.new()
    db.tables = {
        "weapons":[null,{"id":1,"name":"Sword","atb_base":0}],
        "armors":[null],"system":{"test_troop_id":0},
        "troops":[null]
    }
    var world = WORLD.new()
    var battle = BATTLE.new(db,world)
    battle.party = [{"id":1,"actor":true,"name":"Joey",
        "agi":40,"hp":100,"maxhp":100,"mp":50,"maxmp":50,
        "od":0,"equipment":[1,0,0,0,0],"two_swords_style":false}]
    battle.enemies = [{"id":1,"actor":false,"name":"Forest test enemy",
        "agi":50,"hp":80,"maxhp":80,"atb":0.0}]
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    var ui = SCREEN.new()
    root.add_child(ui)
    ui.db = db
    ui.battle = battle
    ui.world = world
    ui.menu_model = MENU.new(db,battle)
    ui._show_battle()
    if not _check(ui.view_name=="BATTLE" and battle.source_atb_initialized,
            "source gauge initialized on BATTLE screen"): return
    if not _check("ATB:30%" in ui.status_label.text and
            "ATB:10%" in ui.status_label.text,
            "initial exact real actor/enemy gauges visible"): return
    ui._process(0.5)
    if not _check(battle.party[0]["source_atb_count"]==540 and
            battle.enemies[0]["source_atb_count"]==400,
            "UI tick advances 30 frames using source AGI formula"): return
    if not _check("ATB:54%" in ui.status_label.text and
            "ATB:40%" in ui.status_label.text,
            "status text refreshes from actual battle state"): return
    ui._show_menu()
    if not _check(ui.view_name=="MENU","MENU selected"): return
    ui._process(0.5)
    if not _check(battle.party[0]["source_atb_count"]==540,
            "MENU screen does not secretly advance BATTLE gauge"): return
    ui._show_battle()
    ui._process(1.0)
    if not _check("ATB:就緒" in ui.status_label.text and
            battle.ready_actors()==[0] and battle.ready_enemies()==[0],
            "same live Control reflects source action readiness"): return
    print("FS Tankentai actual BATTLE UI 60fps gauge and MENU freeze PASS")
    quit(0)
