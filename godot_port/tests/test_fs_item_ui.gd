extends SceneTree

# Real MENU/BATTLE controls click owned items and target the correct party actor.
const SCREEN = preload("res://scripts/FSScreen.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const MENU = preload("res://scripts/FSMenuModel.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("FS item MENU/BATTLE integration FAIL: "+detail)
        quit(1)
        return false
    return true

func _button(root: Node, match: String) -> Button:
    for child in root.get_children():
        if child is Button and match in child.text:
            return child
    return null

func _actor() -> Dictionary:
    var values: Array = []
    for i in range(100):
        values.append_array([500,100,14,8,4,8])
    return {"id":1,"name":"Hero","initial_level":5,"class_id":1,
        "weapon_id":0,"armor1_id":0,"armor2_id":0,"armor3_id":0,
        "armor4_id":0,"parameters":{"xsize":6,"ysize":100,"data_int16":values}}

func _run() -> void:
    var db = DB.new()
    db.tables = {
        "actors":[null,_actor()],
        "classes":[null,{"id":1,"learnings":[],"weapon_set":[],"armor_set":[]}],
        "items":[null,{"id":1,"name":"Potion","scope":7,"occasion":0,
            "consumable":true,"base_damage":0,"hp_recovery":300,"hp_recovery_rate":0,
            "mp_recovery":0,"mp_recovery_rate":0,"note":"","variance":0,
            "element_set":[],"plus_state_set":[],"minus_state_set":[]}],
        "weapons":[null],"armors":[null],"skills":[null],
        "enemies":[null,{"id":1,"name":"Slime","maxhp":300,"maxmp":0,
            "atk":4,"def":2,"spi":1,"agi":5}],
        "troops":[null,{"id":1,"members":[{"enemy_id":1,"hidden":false}]}],
        "system":{"test_troop_id":1}
    }
    var world = WORLD.new()
    world.gain_item("item",1,3)
    world.party_actor_ids.append(1)
    var battle = BATTLE.new(db,world)
    battle.add_actor(1)
    var screen = SCREEN.new()
    root.add_child(screen) # Real project loader fails closed until private DB import.
    screen.db = db
    screen.battle = battle
    screen.world = world
    screen.menu_model = MENU.new(db,battle)
    battle.party[0]["hp"] = 100
    screen._show_items()
    var item_button: Button = _button(screen.body,"Potion")
    if not _check(item_button != null,"MENU lists owned potion"): return
    item_button.pressed.emit()
    if not _check("物品指定目標" in screen.title_label.text,
            "MENU item opens target UI"): return
    var target: Button = _button(screen.body,"Hero")
    if not _check(target != null,"MENU target is correct actor"): return
    target.pressed.emit()
    if not _check(battle.party[0]["hp"]==400 and world.amount("item",1)==2,
            "MENU actually heals and consumes exactly one"): return

    screen._show_battle()
    if not _check(battle.active,"battle started with real-style troop"): return
    screen._process(2.0) # Source ATB, actor ready for the next item command.
    screen._item_action()
    item_button = _button(screen.body,"Potion")
    if not _check(item_button != null,"battle shows owned potion"): return
    item_button.pressed.emit()
    target = _button(screen.body,"Hero")
    if not _check(target != null,"battle item target shown"): return
    target.pressed.emit()
    if not _check(battle.party[0]["hp"]==400 and world.amount("item",1)==2 and
            battle.has_actor_pending_action(0),
            "battle item queued without premature healing/consumption"): return
    screen._process(0.4) # Source Item1 charge is 20%, needs 20 frames.
    if not _check(battle.party[0]["hp"]==500 and world.amount("item",1)==1,
            "battle item heals at ACT resolution, shared inventory"): return
    screen._show_items()
    item_button = _button(screen.body,"Potion")
    item_button.pressed.emit()
    target = _button(screen.body,"Hero")
    target.pressed.emit()
    if not _check(battle.party[0]["hp"]==500 and world.amount("item",1)==1,
            "full HP refuses item and does not consume"): return
    print("FS real MENU/BATTLE item buttons target/heal/inventory shared PASS")
    quit(0)
