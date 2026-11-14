extends SceneTree

# Pure synthetic migration smoke, exercises source-shaped data without private full DB.
const DB = preload("res://scripts/FSDatabase.gd")
const STATE = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const MENU = preload("res://scripts/FSMenuModel.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool, message: String) -> bool:
    if not ok:
        push_error("FS MENU model migration smoke FAIL: "+message)
        quit(1)
        return false
    return true

func _actor(id: int) -> Dictionary:
    var data: Array = []
    for i in range(100):
        data.append_array([120,60,12,10,5,6])
    return {
        "id":id,"name":"Actor #%d" % id,"initial_level":5,"class_id":1,
        "weapon_id":1,"armor1_id":1,"armor2_id":0,"armor3_id":0,
        "armor4_id":0,"parameters":{"xsize":6,"ysize":100,"data_int16":data}
    }

func _run() -> void:
    var db = DB.new()
    db.tables = {
        "actors":[null,_actor(1),_actor(2)],
        "classes":[null,{"id":1,"weapon_set":[1,2],"armor_set":[1,2],
            "learnings":[{"level":1,"skill_id":3},{"level":10,"skill_id":4}]}],
        "skills":[null,null,null,{"id":3,"name":"Magic","mp_cost":5,
            "scope":1,"occasion":0,"description":"Spell"}],
        "weapons":[null,{"id":1,"name":"Wooden Sword","atk":2,"hit":95},
            {"id":2,"name":"Greatsword","atk":10,"hit":85,"two_handed":true}],
        "armors":[null,{"id":1,"name":"Shield","kind":0,"def":3,"eva":2},
            {"id":2,"name":"Helmet","kind":1,"def":4,"eva":1}],
        "items":[null,{"id":1,"name":"Potion","description":"Heal","icon_index":10}]
    }
    var state = STATE.new()
    state.party_actor_ids = [1,2]
    state.gain_item("item",1,3)
    state.gain_item("weapon",2,1)
    state.gain_item("armor",2,1)
    var battle = BATTLE.new(db,state)
    battle.add_actor(1)
    battle.add_actor(2)
    var menu = MENU.new(db,battle)
    if not _assert(menu.party().size()==2 and menu.party()[0]["atk"]==14,
            "actor list uses actual equipment stats"): return
    if not _assert(menu.known_skills(0).size()==1 and menu.known_skills(0)[0]["name"]=="Magic",
            "MENU shows learned class skills, not entire DB"): return
    var inv: Array = menu.inventory_rows()
    if not _assert(inv.size()==1 and inv[0]["count"]==3 and inv[0]["name"]=="Potion",
            "inventory rows resolve item names and owned counts"): return
    var eq: Array = menu.equipment_rows(0)
    if not _assert(eq.size()==5 and eq[0]["name"]=="Wooden Sword" and eq[1]["name"]=="Shield",
            "five original VX slots named by real weapon/armor rows"): return
    var options: Array = menu.available_equipment(0,0)
    if not _assert(options.size()==2 and options[1]["name"]=="Greatsword",
            "only owned, class-legal weapons shown"): return
    if not _assert(menu.available_equipment(0,2).size()==2,
            "helmet allowed only in correct slot"): return
    if not _assert(menu.change_equipment(0,0,2),
            "equip owned two-handed weapon through MENU"): return
    if not _assert(battle.party[0]["equipment"][1]==0 and state.amount("armor",1)==1,
            "shield auto unequipped and returned to inventory"): return
    if not _assert(menu.party()[0]["atk"]==22 and menu.party()[0]["def"]==10,
            "MENU immediately displays recomputed stats"): return
    if not _assert(menu.switch_formation(0,1),"formation swap"): return
    if not _assert(state.party_actor_ids==[2,1] and battle.party[0]["id"]==2,
            "MENU formation shares order with story/battle state"): return
    print("FS MENU party/learned skills/inventory/equip/formation source-shaped smoke PASS")
    quit(0)
