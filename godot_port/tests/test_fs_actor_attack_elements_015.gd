extends SceneTree

# Source #015 Game_Actor#element_set, #013 Game_Battler#element_set,
# and source #404 global field damage after equipment changes.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const WORLD = preload("res://scripts/FSGameState.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool,label: String) -> bool:
    if not ok:
        push_error("FS source actor element_set/equipment FAIL: "+label)
        quit(1)
        return false
    return true

func _actor(id: int,main_weapon: int,offhand: int = 0,
        dual: bool = false) -> Dictionary:
    var data: Array[int] = []
    for level in range(100):
        data.append_array([120,60,12,10,5,20])
    return {"id":id,"name":"Actor%d" % id,"initial_level":5,
        "class_id":1,"weapon_id":main_weapon,"armor1_id":offhand,
        "armor2_id":0,"armor3_id":0,"armor4_id":0,
        "two_swords_style":dual,"parameters":{
            "xsize":6,"ysize":100,"data_int16":data
        }}

func _run() -> void:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    states[153] = {"id":153,"note":
        "<field_priority:10>\n<field_damage 1:-20>\n" +
        "<field_damage 13:+50>\n<field_damage 15:-30>"}
    db.tables = {
        "actors":[null,_actor(1,0),_actor(2,1,2,true),_actor(3,3)],
        "classes":[null,{"id":1,"weapon_set":[1,2,3],
            "armor_set":[1],"learnings":[],"position":1}],
        "weapons":[null,
            {"id":1,"atk":4,"hit":93,"two_handed":false,
             "element_set":[13,14,13]},
            {"id":2,"atk":5,"hit":95,"two_handed":false,
             "element_set":[14,15]},
            {"id":3,"atk":3,"hit":92,"two_handed":false}],
        "armors":[null,{"id":1,"kind":0,"def":3,"eva":2}],
        "enemies":[null,{"id":1,"name":"Dummy","maxhp":1000,
            "maxmp":0,"atk":10,"def":10,"spi":3,"agi":10}],
        "states":states
    }
    var bare: Dictionary = db.apply_equipment(db.actor_stats(1))
    var dual: Dictionary = db.apply_equipment(db.actor_stats(2))
    var unknown: Dictionary = db.apply_equipment(db.actor_stats(3))
    if not _assert(bare["element_set"]==[1] and
            bare["fs_attack_elements_verified"],
            "#015 empty weapons => fighting element [1]"): return
    if not _assert(dual["element_set"]==[13,14,15] and
            dual["fs_attack_elements_verified"],
            "#015 two-sword union preserves order and deduplicates weapon element IDs"): return
    if not _assert(unknown["element_set"].is_empty() and not (
            unknown["fs_attack_elements_verified"]),
            "missing weapon element_set cannot masquerade as verified empty attribute"): return
    if not _assert(db.enemy_stats(1)["element_set"].is_empty(),
            "#013 unmodified enemy Game_Battler attack has empty element_set"): return

    var world = WORLD.new()
    world.gain_item("weapon",1,1)
    world.gain_item("weapon",2,1)
    var battle = BATTLE.new(db,world)
    if not _assert(battle.add_actor(1) and battle.add_actor(2) and
            battle.add_actor(3) and battle.add_enemy(1),
            "synthetic source party and monster load"): return
    battle.field_weather.active = true
    if not _assert(battle.start() and battle.field_weather.set_field(
            db,153,{"id":554,"hp":100}),
            "source global weather enabled for verified synthetic combat"): return

    var enemy: Dictionary = battle.enemies[0]
    var bare_actor: Dictionary = battle.party[0]
    var dual_actor: Dictionary = battle.party[1]
    var missing_actor: Dictionary = battle.party[2]
    if not _assert(battle.attack(bare_actor,enemy)==22,
            "fists use element1 -20%, preliminary raw28 => source weather rounded22"): return
    if not _assert(battle.attack(dual_actor,enemy)==68,
            "dual sword [13,14,15] weather mixed +50/0/-30 => delta+7 on raw64, damage68"): return
    var hp_before: int = int(enemy["hp"])
    if not _assert(not battle.attack_preflight(missing_actor,enemy) and
            battle.attack(missing_actor,enemy)==0 and enemy["hp"]==hp_before,
            "weapon with unknown element_set cannot attack under active weather"): return

    if not _assert(battle.equip(0,0,1) and
            bare_actor["element_set"]==[13,14] and
            bare_actor["fs_attack_elements_verified"],
            "equipping weapon1 recomputes real-source element union"): return
    if not _assert(battle.attack(bare_actor,enemy)==66,
            "new equipped element13 +50 weather applied, raw44=>66"): return
    if not _assert(battle.equip(0,0,2) and
            bare_actor["element_set"]==[14,15] and
            bare_actor["fs_attack_elements_verified"],
            "weapon2 changes element set without carrying old weapon1 elements"): return
    if not _assert(battle.attack(bare_actor,enemy)==34,
            "new element15 -30% weather, raw48 =>34, no stale weather bonus"): return

    print("FS VX #015 actor unarmed/dual element_set and #404 live equipment-weather damage PASS")
    quit(0)
