extends SceneTree

# Data-only, deterministic. Stock VX source rules verified against real FS
# Actors.rvdata/Classes.rvdata and Game_Actor#equippable? / change_equip.
# Final FS-specific RGSS2 later overrides remain a separate parity gate.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const STATE = preload("res://scripts/FSGameState.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("FS equipment VX smoke FAIL: "+detail)
        quit(1)
        return false
    return true

func _actor(id: int,weapon_id: int,offhand: int,two_swords: bool = false,
        fixed: bool = false) -> Dictionary:
    var data: Array = []
    for _level in range(100):
        data.append_array([120,60,12,10,5,6])
    return {
        "id":id,"name":"Synthetic #%d" % id,"initial_level":5,"class_id":1,
        "weapon_id":weapon_id,"armor1_id":offhand,
        "armor2_id":0,"armor3_id":0,"armor4_id":0,
        "two_swords_style":two_swords,"fix_equipment":fixed,
        "parameters":{"xsize":6,"ysize":100,"data_int16":data},
        "critical_bonus":true
    }

func _run() -> void:
    var db = DB.new()
    db.tables = {
        "actors":[null,_actor(1,1,1),_actor(2,3,4,true),_actor(3,1,0,false,true)],
        "classes":[null,{
            "id":1,"weapon_set":[1,2,3,4],"armor_set":[1,2],
            "learnings":[{"level":2,"skill_id":2},{"level":7,"skill_id":3}]
        }],
        "weapons":[null,
            {"id":1,"atk":8,"hit":93,"two_handed":false},
            {"id":2,"atk":15,"hit":80,"two_handed":true,"critical_bonus":true},
            {"id":3,"atk":5,"hit":91,"two_handed":false},
            {"id":4,"atk":6,"hit":88,"two_handed":false}],
        "armors":[null,
            {"id":1,"kind":0,"def":3,"eva":2},
            {"id":2,"kind":1,"def":5,"eva":3}],
        "skills":[null,{},{"id":2,"mp_cost":2},{"id":3,"mp_cost":4}],
        "enemies":[null,{"id":1,"name":"synthetic enemy","maxhp":20,
            "maxmp":0,"atk":4,"def":1,"spi":1,"agi":4,"hit":95,"eva":5}]
    }
    var warrior: Dictionary = db.actor_stats(1)
    if not _assert(db.learned_skills(1,5)==[2],"only skills learned through level"): return
    if not _assert(db.learned_skills(1,7)==[2,3],"level-up skills available"): return
    warrior = db.apply_equipment(warrior)
    if not _assert(warrior["atk"]==20 and warrior["def"]==13 and warrior["hit"]==93,
            "source parameter table + initial weapon/shield"): return
    if not _assert(warrior["eva"]==7 and warrior["cri"]==8,"evasion and crit from equipment/actor"): return
    if not _assert(not db.can_equip(warrior,2,1),"shield kind cannot enter helmet slot"): return
    if not _assert(db.can_equip(warrior,2,2),"helmet kind accepted"): return
    if not _assert(not db.can_equip(warrior,0,999),"class weapon_set rejects unknown item"): return

    var dual: Dictionary = db.apply_equipment(db.actor_stats(2))
    if not _assert(dual["two_swords_style"] and dual["atk"]==23 and dual["hit"]==88,
            "offhand weapon not treated as armor; dual hit uses weaker weapon"): return

    var fixed: Dictionary = db.actor_stats(3)
    if not _assert(not db.can_equip(fixed,0,2) and not db.can_equip(fixed,0,0),
            "fixed equipment actor rejects changes"): return

    var state = STATE.new()
    state.gain_item("weapon",2,1)
    state.gain_item("armor",2,1)
    var battle = BATTLE.new(db,state)
    if not _assert(battle.add_actor(1) and battle.add_actor(2),"create two real-style actors"): return
    if not _assert(battle.equip(0,0,2),"equip two-handed weapon"): return
    if not _assert(battle.party[0]["equipment"]==[2,0,0,0,0],
            "two handed auto-unequips shield"): return
    if not _assert(battle.party[0]["atk"]==27 and battle.party[0]["def"]==10,
            "stats recomputed exactly once"): return
    if not _assert(state.amount("armor",1)==1 and state.amount("weapon",2)==0 and
            state.amount("weapon",1)==1,"inventory atomically returns old gear"): return
    if not _assert(not battle.equip(0,1,2),"wrong armor kind rejected"): return
    if not _assert(battle.equip(0,2,2),"can equip helmet from inventory"): return
    if not _assert(battle.party[0]["def"]==15 and state.amount("armor",2)==0,
            "helmet applies defense and inventory consumed"): return
    var before: Dictionary = state.inventory.duplicate(true)
    if not _assert(battle.equip(0,2,2),"re-equipping same item should be harmless"): return
    if not _assert(state.inventory==before,"no-op equipment change preserves inventory"): return
    print("FS actor/classes/skills/equipment two-sword/two-hand/source Table smoke PASS")
    quit(0)
