extends SceneTree

# Native Godot test of the conservative stock VX recovery subset.
# Actual FS runtime MasterSetup and all 505 aliases remain a later parity gate.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const RULES = preload("res://scripts/FSItemRules.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS item recovery FAIL: " + label)
        quit(1)
        return false
    return true

func _item(id: int, name: String) -> Dictionary:
    return {"id":id,"name":name,"scope":7,"occasion":0,
        "consumable":true,"note":"","base_damage":0,"atk_f":0,"spi_f":0,
        "element_set":[],"plus_state_set":[],"minus_state_set":[],
        "common_event_id":0,"parameter_type":0,"parameter_points":0,
        "damage_to_mp":false,"physical_attack":false,"absorb_damage":false,
        "variance":0,"hp_recovery_rate":0,"hp_recovery":0,
        "mp_recovery_rate":0,"mp_recovery":0}

func _run() -> void:
    var hp: Dictionary = _item(1,"Potion")
    hp["hp_recovery"] = 300
    var mp: Dictionary = _item(2,"Ether")
    mp["mp_recovery"] = 10
    mp["mp_recovery_rate"] = 20
    var reusable: Dictionary = _item(3,"Recovery Ring")
    reusable["hp_recovery"] = 80
    reusable["consumable"] = false
    var custom: Dictionary = _item(4,"Soul Special")
    custom["hp_recovery"] = 250
    custom["note"] = "<FS_RULE: custom>"
    var state_item: Dictionary = _item(5,"State Potion")
    state_item["hp_recovery"] = 100
    state_item["plus_state_set"] = [3]
    var combat_only: Dictionary = _item(6,"Battle Potion")
    combat_only["hp_recovery"] = 80
    combat_only["occasion"] = 1
    var event_item: Dictionary = _item(7,"Story Potion")
    event_item["hp_recovery"] = 80
    event_item["common_event_id"] = 1
    var db = DB.new()
    db.tables = {"items":[null,hp,mp,reusable,custom,state_item,combat_only,event_item]}
    var world = WORLD.new()
    for i in range(1,8):
        world.gain_item("item",i,2)
    var battle = BATTLE.new(db,world)
    var actor: Dictionary = {"id":1,"actor":true,"name":"Hero",
        "maxhp":1000,"hp":650,"maxmp":100,"mp":20,"pharmacology":false}
    var hero: Dictionary = {"id":2,"actor":true,"name":"Doctor",
        "maxhp":1000,"hp":350,"maxmp":100,"mp":30,"pharmacology":true}
    var foe: Dictionary = {"id":1,"actor":false,"maxhp":300,"hp":10,
        "maxmp":100,"mp":10}
    if not _check(battle.inventory is Dictionary and battle.inventory==world.inventory,
            "shared world inventory"): return
    if not _check(battle.use_item(actor,1,hero,false),"potion from MENU"): return
    if not _check(actor["hp"]==950 and world.amount("item",1)==1,
            "300 HP recovery and consumed one"): return
    if not _check(battle.use_item(actor,1,hero,true),"potion from battle"): return
    if not _check(actor["hp"]==1000 and world.amount("item",1)==0,
            "HP capped at max and consumed final potion"): return
    if not _check(not battle.use_item(actor,1,hero,false) and world.amount("item",1)==0,
            "empty bag refuses action"): return
    if not _check(battle.use_item(actor,2,actor,false),"ether restores MP"): return
    if not _check(actor["mp"]==50 and world.amount("item",2)==1,
            "source formula maxMP*20% + 10"): return
    if not _check(battle.use_item(hero,3,hero,false),"reusable item valid"): return
    if not _check(hero["hp"]==510 and world.amount("item",3)==2,
            "pharmacology doubles 80 and nonconsumable stays"): return
    if not _check(not battle.use_item(actor,4,hero,false) and world.amount("item",4)==2,
            "unknown FS note fails closed without consumption"): return
    if not _check(not battle.use_item(actor,5,hero,true) and world.amount("item",5)==2,
            "state-adding item protected"): return
    if not _check(not battle.use_item(actor,6,hero,false) and
            battle.use_item(actor,6,hero,true) and world.amount("item",6)==1,
            "battle-only occasion rejected in MENU, allowed in battle"): return
    if not _check(not battle.use_item(actor,7,hero,false) and world.amount("item",7)==2,
            "common event item protected"): return
    if not _check(not battle.use_item(foe,3,hero,true) and world.amount("item",3)==2,
            "enemy target rejected for ally item"): return
    var unsupported: Dictionary = _item(8,"Multi-target")
    unsupported["scope"] = 8
    unsupported["hp_recovery"] = 100
    if not _check(not bool(RULES.preview(unsupported,hero,actor,false).get("ok",false)),
            "unsupported scope is not approximated as single-target"): return
    print("FS stock VX conservative item HP/MP recovery/pharmacology/occasion/atomic inventory PASS")
    quit(0)
