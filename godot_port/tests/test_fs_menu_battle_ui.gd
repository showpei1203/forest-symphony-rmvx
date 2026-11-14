extends SceneTree

# Actual FSScreen buttons/labels with synthetic source-shaped records.
# Does not require proprietary original FS textures or database.
const Screen = preload("res://scripts/FSScreen.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const State = preload("res://scripts/FSGameState.gd")
const Battle = preload("res://scripts/FSBattle.gd")
const Menu = preload("res://scripts/FSMenuModel.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS MENU/BATTLE native UI FAIL: "+label)
        quit(1)
        return false
    return true

func _actor(id: int) -> Dictionary:
    var data: Array = []
    for i in range(100):
        data.append_array([120,80,12,10,5,6])
    return {"id":id,"name":"Hero #%d" % id,"initial_level":5,"class_id":1,
        "weapon_id":1,"armor1_id":1,"armor2_id":0,"armor3_id":0,
        "armor4_id":0,"parameters":{"xsize":6,"ysize":100,"data_int16":data}}

func _text_of(root: Node) -> String:
    var parts: Array[String] = []
    for child in root.get_children():
        if child is Label:
            parts.append(child.text)
        if child is Button:
            parts.append(child.text)
    return " / ".join(PackedStringArray(parts))

func _button_with(root: Node, fragment: String) -> Button:
    for child in root.get_children():
        if child is Button and fragment in child.text:
            return child
    return null

func _run() -> void:
    var source_db = DB.new()
    source_db.tables = {
        "actors":[null,_actor(1),_actor(2)],
        "classes":[null,{"id":1,"weapon_set":[1,2],"armor_set":[1,2],
            "learnings":[{"level":1,"skill_id":3},{"level":10,"skill_id":4}]}],
        "skills":[null,null,null,{"id":3,"name":"Flash","description":"single",
            "base_damage":10,"atk_f":0,"spi_f":0,"scope":1,"occasion":0,"mp_cost":5,
            "plus_state_set":[],"minus_state_set":[],"note":""},
            {"id":4,"name":"Forbidden","scope":1,"mp_cost":0}],
        "items":[null,{"id":1,"name":"Potion","description":"heal"}],
        "weapons":[null,{"id":1,"name":"Wooden Sword","atk":2,"hit":95},
            {"id":2,"name":"Greatsword","atk":10,"hit":85,"two_handed":true}],
        "armors":[null,{"id":1,"name":"Shield","kind":0,"def":3,"eva":2},
            {"id":2,"name":"Helmet","kind":1,"def":4}],
        "enemies":[null,{"id":1,"name":"Test monster","maxhp":300,"maxmp":0,
            "atk":4,"def":1,"spi":1,"agi":4,"hit":95,"eva":0}],
        "troops":[null,{"id":1,"members":[{"enemy_id":1,"hidden":false}]}],
        "system":{"test_troop_id":1}
    }
    var world = State.new()
    world.party_actor_ids.append(1)
    world.party_actor_ids.append(2)
    world.gain_item("item",1,3)
    world.gain_item("weapon",2,1)
    var battle = Battle.new(source_db,world)
    battle.add_actor(1)
    battle.add_actor(2)

    var screen = Screen.new()
    root.add_child(screen) # Initial _ready correctly fails closed on missing private DB.
    screen.db = source_db
    screen.world = world
    screen.battle = battle
    screen.menu_model = Menu.new(source_db,battle)
    screen._show_menu()
    screen._open_story_sandbox()
    if not _check(screen.story_sandbox != null and
            screen.story_sandbox.markers.size()==2 and
            screen.story_sandbox.has_node("ReturnToFSMenu"),
            "boot UI opens playable Godot event map with return navigation"): return
    screen._close_story_sandbox()
    if not _check(screen.story_sandbox == null and "MENU" in screen.title_label.text,
            "map sandbox returns to actual FS menu"): return
    if not _check("MENU" in screen.title_label.text,"MENU first opens"): return
    screen._show_skills()
    var skill_rows: String = _text_of(screen.body)
    if not _check("Flash" in skill_rows and not "Forbidden" in skill_rows,
            "MENU only shows learned skills"): return
    screen._show_items()
    if not _check("Potion" in _text_of(screen.body) and "×3" in _text_of(screen.body),
            "MENU shows owned item names and counts"): return

    screen._show_equipment_candidates(0)
    var upgrade: Button = _button_with(screen.body,"Greatsword")
    if not _check(upgrade != null,"MENU shows class-legal inventory weapon"): return
    upgrade.pressed.emit()
    if not _check(battle.party[0]["equipment"][0]==2 and
            battle.party[0]["equipment"][1]==0,"UI actually equips two-handed weapon and unequips shield"): return
    if not _check(world.amount("weapon",2)==0 and world.amount("armor",1)==1,
            "MENU transaction shared with story inventory"): return

    screen._formation_clicked(0)
    screen._formation_clicked(1)
    if not _check(world.party_actor_ids==[2,1],"formation button updates team order"): return

    screen.actor_index = 0
    screen._show_troop_picker()
    if not _check(not battle.active and "Test monster" in _text_of(screen.body),
            "real source troop selector lists imported enemy names"): return
    var troop_button: Button = _button_with(screen.body,"Test monster")
    if not _check(troop_button != null,"source troop is selectable"): return
    troop_button.pressed.emit()
    if not _check(battle.active and battle.enemies.size()==1 and
            screen.selected_troop_id==1,
            "selected original troop membership starts actual battle"): return
    screen._player_attack()
    if not _check("角色 ATB 尚未就緒" in screen.log_label.text,
            "premature attack blocked in BATTLE UI"): return
    screen._process(2.0) # Source 60fps ATB, no premature attacks.
    screen._player_attack()
    if not _check(battle.source_atb_wait,
            "source Wait mode freezes gauges during enemy targeting"): return
    if not _check("選擇敵方目標" in screen.title_label.text,"attack opens target choice"): return
    var target: Button = _button_with(screen.body,"Test monster")
    if not _check(target != null,"enemy target from source Troops.rvdata"): return
    target.pressed.emit()
    if not _check(battle.enemies[0]["hp"] == 300 and
            battle.has_actor_pending_action(0),
            "queued attack does not damage enemy until ACT is charged"): return
    screen._process(1.0/60.0)
    if not _check(battle.enemies[0]["hp"] < 300,
            "attack actually applies to chosen target AFTER source ACT"): return

    screen._process(2.0) # Source attack recharge and ATB refill for skill command.
    var original_mp: int = int(battle.party[0]["mp"])
    screen._skill_action()
    if not _check(_button_with(screen.body,"Flash") != null and
            _button_with(screen.body,"Forbidden") == null,"battle skill only learned"): return
    screen._select_skill_target(3)
    target = _button_with(screen.body,"Test monster")
    if not _check(target != null,"skill scope selects enemy"): return
    target.pressed.emit()
    if not _check(int(battle.party[0]["mp"]) == original_mp and
            battle.has_actor_pending_action(0),
            "skill selection only queues ACT and does NOT prematurely charge MP"): return
    screen._process(0.2) # Skill3 source ACT=10% needs 10 frames.
    if not _check(int(battle.party[0]["mp"]) == original_mp - 5,
            "allowed skill decreases MP only after ACT resolves"): return
    if not _check(not battle.use_skill(battle.party[0],battle.enemies[0],4) and
            int(battle.party[0]["mp"]) == original_mp - 5,
            "unlearned skill blocked without MP cost"): return
    print("FS MENU/BATTLE native buttons actor/skills/items/equip/formation/troop/target PASS")
    quit(0)
