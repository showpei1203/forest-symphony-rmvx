extends SceneTree

# Real FSBattle source-provider integration, using SYNTHETIC authoritative
# mappings (not exported user private FS data). Original provenance:
# Actor ID->Class fallback ~252561, Enemy table ~202954,
# Class/Enemy source RPG element_ranks ~270639,
# KGC all-equipment resistance ~171488, passive Notes ~253525.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const PROVIDER = preload("res://scripts/FSElementSourceProvider.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    if not ok:
        push_error("FS automatic original element data provider FAIL: "+reason)
        quit(1)
        return false
    return true

func _ranks() -> Array:
    var result: Array=[]
    result.resize(22)
    result.fill(3) # source RPG 1-D Table indices 4..21
    return result

func _actor(id: int,cls: int,weapon: int=0,armor: int=0) -> Dictionary:
    var stats: Array=[]
    stats.resize(12)
    stats.fill(0)
    var defaults: Array=[1000,100,50,10,20,20]
    for i in range(6):
        stats[6+i]=defaults[i]
    return {"id":id,"name":"Synthetic Actor%d" % id,"class_id":cls,
        "initial_level":1,"weapon_id":weapon,"armor1_id":armor,
        "armor2_id":0,"armor3_id":0,"armor4_id":0,
        "parameters":{"xsize":6,"ysize":2,"data_int16":stats}}

func _weapon(id: int,valid: bool=true) -> Dictionary:
    var item: Dictionary = {"id":id,"name":"Synthetic Weak Blade",
        "atk":0,"hit":95,"element_set":[15],"note":"",
        "invalid_element_set":[],"guard_element_set":[],
        "weak_element_set":[14],"absorb_element_set":[]}
    if valid:
        item["element_resistance"]={"14":100}
    return item

func _armor(id: int,valid: bool=true) -> Dictionary:
    var item: Dictionary = {"id":id,"name":"Synthetic Guard Coat",
        "kind":0,"def":0,"eva":0,"note":"<ele_res 14:25>",
        "element_set":[14],"invalid_element_set":[],
        "guard_element_set":[14],"weak_element_set":[],
        "absorb_element_set":[]}
    if valid:
        item["element_resistance"]={"14":150}
    return item

func _db() -> FSDatabase:
    var db = DB.new()
    db.tables={
        "actors":[null,_actor(1,2,1,1),_actor(2,3)],
        "classes":[null,null,{"id":2,"position":0,
            "element_ranks":{"data_int16":_ranks()},
            "weapon_set":[1],"armor_set":[1,2],"learnings":[]},
            {"id":3,"position":0,"element_ranks":_ranks(),
            "weapon_set":[],"armor_set":[],"learnings":[]}],
        "enemies":[null,{"id":1,"name":"Synthetic Water Ground",
            "maxhp":3000,"maxmp":100,"atk":50,"def":10,
            "spi":10,"agi":20,"hit":95,"eva":5,"has_critical":false,
            "note":"<ele_res 13:10>","actions":[],
            "element_ranks":_ranks()}],
        "weapons":[null,_weapon(1)],
        "armors":[null,_armor(1),_armor(2,false)],
        "states":[null,{"id":1,"name":"Element State",
            "note":"<ele_weak[14]:30>","element_set":[14],
            "reduce_hit_ratio":false,"restriction":0}],
        "skills":[null]
    }
    return db

func _map() -> Dictionary:
    # Proves actor-id override is higher priority than class-id fallback.
    # No real user's proprietary Pokémon type mapping is copied here.
    return {"source":"FS_ElementalSettings_Phase28",
        "actors":{"1":["fire",null]},
        "classes":{"2":["grass","poison"]},
        "enemies":{"1":["water","ground"]},
        "actor_passive_notes":{"1":["<ele_weak 14:15>"],"2":[]},
        "enemy_passive_notes":{"1":[]},
        "growth_use_enemy_element_rate":false}

func _run() -> void:
    var db: FSDatabase=_db()
    var battle: FSBattle=BATTLE.new(db)
    if not _check(not battle.enable_private_element_provider() and
            not battle.element_provider.active and
            not battle.element_rates.active,
            "no real post-Apply 11 table witness cannot enable production"): return
    if not _check(battle.element_provider.configure_fixture(_map()).get(
            "ok",false),"source-shaped injected synthetic map accepted"): return
    battle.element_rates.active=true
    if not _check(battle.add_actor(1) and battle.add_actor(2) and
            battle.add_enemy(1),"real FSDatabase actors/enemies are created"): return
    var actor: Dictionary=battle.party[0]
    var fallback: Dictionary=battle.party[1]
    var enemy: Dictionary=battle.enemies[0]
    var a: Dictionary=actor.get("fs_element_authority",{})
    var e: Dictionary=enemy.get("fs_element_authority",{})
    var f: Dictionary=fallback.get("fs_element_authority",{})
    if not _check(str(a.get("primary",""))=="fire" and
            str(a.get("secondary",""))=="" and
            str(e.get("primary",""))=="water" and
            str(e.get("secondary",""))=="ground" and
            str(f.get("primary",""))=="normal" and
            int(a.get("ranks",{}).get("14",-1))==3,
            "Actor override, Class fallback, Enemy Type and true Class ranks"): return
    var r: Dictionary=battle.element_rates.max_rate_for(db,enemy,[15])
    if not _check(r.get("ok",false) and int(r["rate"])==250,
            "Grass 4x Water/Ground clamps250 from real enemy record"): return
    r=battle.element_rates.max_rate_for(db,actor,[14])
    # Actor fire Water200% -> armor rank-half gives100; KGC resist150,
    # weapon Weak14 multiplies 3/2=>225, armor Guard14 halves to112.
    # Armor Note Res14:-25 + passive Weak14:+15 => 102.
    if not _check(r.get("ok",false) and int(r["rate"])==102 and
            a.get("provenance","")=="fixture",
            "actual KGC equipped weapon+armor, Rank and passive Notes =>102"): return

    battle.accuracy.active=true
    actor["cri"]=10
    enemy["cri"]=0
    if not _check(battle.start(),"real source-derived roster starts"): return
    # Every preflight refreshes the derived target, no handwritten
    # target.fs_element_authority assignment required.
    actor["states"]=[1]
    if not _check(battle.attack_preflight(enemy,actor),
            "incoming action automatically updates source State notes"): return
    r=battle.element_rates.max_rate_for(db,actor,[14])
    # State halves result before KGC options: native armor rank50;
    # State50 -> type200*25%=50; resistance150 =>75;
    # weapon Weak*3/2 =>112; armor Guard/2=>56;
    # passive15 + armor Res-25 + State Weak30 =>76.
    if not _check(int(r.get("rate",-1))==76 and
            battle.element_provider.refresh_count>=4,
            "State1 weak Note+30 and state element half recalculated to76"): return
    actor["states"]=[]

    # Actual battle attack damage uses the SOURCE-built enemy type, no
    # handwritten Type/rank snapshot on the enemy.
    actor["fs_normal_source_verified"]=true
    actor["fs_normal_equipment_verified"]=true
    enemy["fs_normal_source_verified"]=true
    enemy["fs_normal_enemy_note_verified"]=true
    battle.normal_core.active=true
    battle.accuracy.scripted_rolls=[0,99,0,99,99,0,1]
    var hp_before: int=int(enemy["hp"])
    if not _check(battle.attack(actor,enemy)==214 and
            int(enemy["hp"])==hp_before-214 and
            int(battle.normal_core.events[-1]["element_rate"])==250,
            "native source-derived ACT Grass250%, old11->27, smooth214"): return

    # The SOURCE provider can reject an invalid proposed equipment
    # transaction BEFORE changing the actor, bag or live source snapshot.
    battle.inventory["armor:2"]=1
    var current_rate: int=int(battle.element_rates.max_rate_for(
        db,actor,[14])["rate"])
    var current_equips: Array=actor["equipment"].duplicate()
    if not _check(not battle.equip(0,1,2) and
            actor["equipment"]==current_equips and
            int(battle.inventory["armor:2"])==1 and
            int(battle.element_rates.max_rate_for(db,actor,[14])["rate"])==
                current_rate,
            "invalid KGC armor rejected atomically with no inventory loss"): return

    # Legitimate removal/re-equipment changes the derived KGC options.
    if not _check(battle.equip(0,1,0) and
            int(battle.inventory.get("armor:1",0))==1 and
            int(battle.element_rates.max_rate_for(db,actor,[14])["rate"])==250,
            "removing Armor recalculates rank/guard/Note, capped250"): return
    if not _check(battle.equip(0,1,1) and
            int(battle.inventory.get("armor:1",0))==0 and
            int(battle.element_rates.max_rate_for(db,actor,[14])["rate"])==102,
            "equipping verified Armor restores source KGC and inventory"): return

    # Missing passive sources must NEVER silently mean no effects.
    var snapshot: Dictionary=battle.element_provider.source_map
    snapshot["actor_passive_notes"].erase("1")
    hp_before=int(enemy["hp"])
    battle.accuracy.scripted_rolls=[0,99,0,99,99,0,1]
    if not _check(not battle.attack_preflight(actor,enemy) and
            int(enemy["hp"])==hp_before and
            battle.accuracy.scripted_rolls==[0,99,0,99,99,0,1] and
            not actor.has("fs_element_authority"),
            "unknown source passive must block before RNG and clear stale authority"): return

    print("FS Phase28 source provider Actor/Class/Enemy real table ranks, weapon/armor KGC, passive/state, atomic equip, ACT and SHA gate PASS")
    quit(0)
