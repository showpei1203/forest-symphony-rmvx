extends SceneTree

# Source #411 lines 324-496 + 1291-1315, ONLY verified MP subset.
# Native Godot regression checks computed cost, MENU label and actual debit.
const COST = preload("res://scripts/FSSkillCostRules.gd")
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const MENU = preload("res://scripts/FSMenuModel.gd")
const SCREEN = preload("res://scripts/FSScreen.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, info: String) -> bool:
    if not ok:
        push_error("FS #411 skill cost authority FAIL: "+info)
        quit(1)
        return false
    return true

func _skill(id: int, tag: String = "") -> Dictionary:
    return {
        "id":id,"name":"Skill #%d" % id,
        "note":tag,"scope":1,"occasion":0,"mp_cost":10,
        "base_damage":10,"atk_f":0,"spi_f":0,"ignore_defense":false,
        "plus_state_set":[],"minus_state_set":[],"damage_to_mp":false,
        "absorb_damage":false
    }

func _actor() -> Dictionary:
    var values: Array = []
    for level in range(100):
        values.append_array([500,100,15,8,4,6])
    return {"id":1,"name":"Hero","initial_level":5,"class_id":1,
        "weapon_id":0,"armor1_id":0,"armor2_id":0,
        "armor3_id":0,"armor4_id":0,
        "parameters":{"xsize":6,"ysize":100,"data_int16":values}}

func _run() -> void:
    var user: Dictionary = {"maxmp":101,"mp":100,"half_mp_cost":false}
    if not _check(int(COST.preview(_skill(1),user).get("mp",-1))==10,
            "plain source MP 10"): return
    if not _check(int(COST.preview(_skill(2,"<costo mp: 25>"),user).get("mp",-1))==25,
            "fixed note OVERRIDES RPG::Skill.mp_cost"): return
    if not _check(int(COST.preview(_skill(3,"<costo mp: 7%>"),user).get("mp",-1))==17,
            "percent note ADDS maxMP*7% using integer truncation"): return
    if not _check(int(COST.preview(_skill(4,"<costo mp: 27>\n<costo mp: 7%>"),user).get("mp",-1))==34,
            "fixed and percentage combined"): return
    if not _check(int(COST.preview(_skill(5,"<costo mp: 0>"),user).get("mp",-1))==10,
            "FS fixed=0 does NOT override underlying mp_cost"): return
    user["half_mp_cost"] = true
    if not _check(int(COST.preview(_skill(6,"<costo mp: 7%>"),user).get("mp",-1))==8,
            "FS half_mp_cost halves base+percent (17/2 truncates)"): return
    user["half_mp_cost"] = false
    if not _check(not bool(COST.preview(_skill(7,"<costo hp: 30>"),user).get("ok",false)),
            "unsupported HP payment fails closed"): return
    if not _check(not bool(COST.preview(_skill(8,"<costo oro: 50>"),user).get("ok",false)),
            "Gold payment fails closed"): return
    if not _check(not bool(COST.preview(_skill(9,"<usa oggetto: 2>"),user).get("ok",false)),
            "Item payment fails closed"): return
    if not _check(not bool(COST.preview(_skill(10,"<costo angry: 40>"),user).get("ok",false)),
            "OD payment fails closed"): return
    if not _check(not bool(COST.preview(_skill(11,"<FS_CustomSkillEffect>"),user).get("ok",false)),
            "unknown effect Note fails closed"): return
    if not _check(not bool(COST.preview(_skill(12,"<costo mp: 12>\n<costo mp: 22>"),user).get("ok",false)),
            "duplicate MP tag fails closed"): return
    if not _check(int(COST.preview(_skill(13,"<ignore target priority>"),user).get("mp",-1))==10,
            "#372 exact target priority bypass Note is cost-neutral, not unknown cost"): return
    if not _check(not bool(COST.preview(_skill(14,"<ignore target priority>\n<unknown effect>"),user).get("ok",false)),
            "permitted #372 Note does not accidentally whitelist other gameplay effects"): return

    var db = DB.new()
    db.tables = {
        "actors":[null,_actor()],
        "classes":[null,{"id":1,"learnings":[{"level":1,"skill_id":1},
            {"level":1,"skill_id":2},{"level":1,"skill_id":3},
            {"level":1,"skill_id":4},{"level":1,"skill_id":5}],
            "weapon_set":[],"armor_set":[]}],
        "skills":[null,_skill(1),_skill(2,"<costo mp: 25>"),
            _skill(3,"<costo mp: 7%>"),_skill(4,"<costo hp: 1>"),
            _skill(5,"<costo mp: 5>\n<unknown movement>")],
        "weapons":[null],"armors":[null],
        "enemies":[null,{"id":1,"name":"dummy","maxhp":200,
            "maxmp":0,"atk":4,"def":2,"spi":2,"agi":4}]
    }
    var world = WORLD.new()
    world.party_actor_ids.append(1)
    var battle = BATTLE.new(db,world)
    if not _check(battle.add_actor(1) and battle.add_enemy(1),
            "source-shaped actor/target exist"): return
    battle.start()
    var menu = MENU.new(db,battle)
    var skills: Array[Dictionary] = menu.known_skills(0)
    if not _check(skills.size()==5,"all learned skills listed"): return
    if not _check(int(skills[1]["mp_cost"])==25 and skills[1]["cost_verified"],
            "MENU quotes fixed MP 25 instead of raw 10"): return
    if not _check(int(skills[2]["mp_cost"])==17,"MENU adds percentage with maxMP 100"): return
    if not _check(not bool(skills[3]["cost_verified"]) and int(skills[3]["mp_cost"])==-1,
            "MENU marks unsupported HP cost unknown"): return
    if not _check(not bool(skills[4]["cost_verified"]),
            "MENU marks custom unknown notes invalid"): return

    var hero: Dictionary = battle.party[0]
    var enemy: Dictionary = battle.enemies[0]
    var mp_before: int = int(hero["mp"])
    var hp_before: int = int(enemy["hp"])
    if not _check(battle.use_skill(hero,enemy,2),"fixed MP cost skill executes"): return
    if not _check(int(hero["mp"])==mp_before-25 and int(enemy["hp"])<hp_before,
            "BATTLE charges 25 not raw 10 after damage succeeds"): return
    var remain: int = int(hero["mp"])
    if not _check(not battle.use_skill(hero,enemy,4) and int(hero["mp"])==remain,
            "HP-priced ability rejected without MP debit"): return
    if not _check(not battle.use_skill(hero,enemy,5) and int(hero["mp"])==remain,
            "unparsed gameplay note rejected without MP debit"): return
    hero["mp"] = 12
    if not _check(not battle.use_skill(hero,enemy,3) and int(hero["mp"])==12,
            "insufficient MP rejected and not overdrawn"): return

    var screen = SCREEN.new()
    root.add_child(screen)
    screen.db = db
    screen.world = world
    screen.battle = battle
    screen.menu_model = menu
    screen.actor_index = 0
    screen._skill_action()
    var buttons: Array[String] = []
    var note_warnings: Array[String] = []
    for child in screen.body.get_children():
        if child is Button:
            buttons.append(child.text)
        if child is Label:
            note_warnings.append(child.text)
    if not _check(buttons.any(func(t: String)->bool: return "Skill #2 MP:25" in t),
            "BATTLE button shows source MP 25"): return
    if not _check(not buttons.any(func(t: String)->bool: return "Skill #4" in t),
            "unsupported HP skill not clickable"): return
    if not _check(note_warnings.any(func(t: String)->bool: return "未核對" in t),
            "unverified costs clearly labeled"): return
    print("FS #411 MP override/percentage/half/unsafe reject + actual MENU/BATTLE payment PASS")
    quit(0)
