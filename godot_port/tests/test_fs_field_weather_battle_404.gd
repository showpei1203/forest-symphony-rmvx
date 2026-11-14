extends SceneTree

# #404 actual positive HP/MP candidate damage application AFTER preliminary
# battle formula, no early MP and no invented Boss State effects.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const COST = preload("res://scripts/FSSkillCostRules.gd")
const SCREEN = preload("res://scripts/FSScreen.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,label: String) -> bool:
    if not ok:
        push_error("FS #404 weather BATTLE integration FAIL: "+label)
        quit(1)
        return false

func _skill(id: int,note: String = "") -> Dictionary:
    return {"id":id,"name":"Skill%d" % id,"scope":1,"occasion":0,
        "base_damage":100,"atk_f":0,"spi_f":0,"mp_cost":10,
        "note":note,"element_set":[13],"ignore_defense":false,
        "plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false}

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    states[122] = {"id":122,"note":""}
    states[153] = {"id":153,"note":
        "<field_weather>\n<field_priority:10>\n<field_damage 13:+25>"}
    states[156] = {"id":156,"note":
        "<field_weather>\n<field_priority:20>\n<field_damage 13:-25>"}
    var enemies: Array = []
    enemies.resize(601)
    enemies[548] = {"id":548,"name":"Weather Boss",
        "maxhp":1000,"maxmp":50,"atk":20,"def":10,"spi":3,
        "agi":10,"note":"<fs_fixed_enemy_stats>","actions":[]}
    enemies[600] = {"id":600,"name":"Test target",
        "maxhp":1000,"maxmp":50,"atk":10,"def":5,
        "spi":3,"agi":10,"note":"","actions":[]}
    db.tables={"states":states,"enemies":enemies,
        "skills":[null,_skill(1),_skill(2,"<field effect: 156>"),
        _skill(3,"<unknown gameplay effect>")],
        "weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase) -> FSBattle:
    var b = BATTLE.new(db,WORLD.new())
    b.party.append({"id":1,"actor":true,"name":"Hero",
        "hp":500,"maxhp":500,"mp":100,"maxmp":100,
        "atk":20,"def":10,"spi":3,"agi":20,"skills":[1,2,3],
        "element_set":[13],"equipment":[0,0,0,0,0],
        "two_swords_style":false,"states":[],"note":"","odds":4})
    b.add_enemy(600)
    b.field_weather.active = true
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    return b

func _run() -> void:
    var db = _db()
    var battle = _battle(db)
    var hero: Dictionary = battle.party[0]
    var enemy: Dictionary = battle.enemies[0]
    if not _check(battle.start(),"source shaped battle starts"): return
    var weather_source: Dictionary = {"id":554,"hp":100}
    if not _check(battle.field_weather.set_field(db,153,weather_source),
            "test explicitly enables real #404 global field"): return
    var mp_old: int = int(hero["mp"])
    var hp_old: int = int(enemy["hp"])
    if not _check(battle.use_skill(hero,enemy,1),
            "single-element source skill used under global weather"): return
    if not _check(hero["mp"]==mp_old-10 and enemy["hp"]==hp_old-125,
            "base100 and element13 +25%=125 HP damage, MP charged once"): return
    hp_old = int(enemy["hp"])
    if not _check(battle.attack(hero,enemy)==88 and
            enemy["hp"]==hp_old-88,
            "basic source candidate70 damage becomes rounded88 after +25%"): return

    var bad_actor: Dictionary = hero.duplicate(true)
    bad_actor.erase("element_set")
    if not _check(not battle.attack_preflight(bad_actor,enemy),
            "global weather denies attack with unavailable source element_set"): return
    hp_old = int(enemy["hp"])
    if not _check(battle.attack(bad_actor,enemy)==0 and enemy["hp"]==hp_old,
            "primitive attack also fail-closes on unknown element tags"): return

    var quote: Dictionary = COST.preview(db.record("skills",2),hero)
    if not _check(quote["ok"] and quote["mp"]==10,
            "field effect note is MP-cost neutral under #411"): return
    if not _check(battle.skill_preflight(hero,enemy,2),
            "new higher-priority field skill is legal before ACT"): return
    if not _check(battle.use_skill(hero,enemy,2) and
            int(battle.field_weather.current_id)==156 and
            enemy["hp"]==hp_old-125,
            "source field-changing skill deals damage under OLD 153 weather, then changes to156"): return
    hp_old = int(enemy["hp"])
    if not _check(battle.use_skill(hero,enemy,1) and
            enemy["hp"]==hp_old-75,
            "subsequent skill uses NEW 156 weather -25% damage"): return
    mp_old = int(hero["mp"])
    if not _check(not battle.skill_preflight(hero,enemy,2) and
            not battle.use_skill(hero,enemy,2) and hero["mp"]==mp_old,
            "#404 same weather skill cannot cast again or pay MP"): return
    if not _check(not battle.use_skill(hero,enemy,3) and
            hero["mp"]==mp_old,
            "unknown Notes remain blocked despite weather Note whitelist"): return

    # Field damage only changes after ACT, not merely scheduling an action.
    var queued = _battle(db)
    queued.start()
    var qactor: Dictionary = queued.party[0]
    var qenemy: Dictionary = queued.enemies[0]
    queued.field_weather.set_field(db,153,{"id":554,"hp":100})
    queued.advance_atb(40.0/60.0)
    if not _check(queued.ready_actors()==[0],"source actor ATB ready"): return
    var qmp: int = int(qactor["mp"])
    var qhp: int = int(qenemy["hp"])
    if not _check(queued.queue_actor_action(0,"skill",0,2) and
            queued.field_weather.current_id==153 and
            qactor["mp"]==qmp and qenemy["hp"]==qhp,
            "queue stage never applies field or MP before ACT"): return
    queued.advance_atb(1.0/60.0)
    if not _check(queued.field_weather.current_id==156 and
            qactor["mp"]==qmp-10 and
            qenemy["hp"]==qhp-125,
            "Skill2 source ACT 1 frame changes weather after original hit"): return

    # Boss548 HP phase status still remains a non-applied INTENT, while
    # source #404 global field runtime can have its OWN validated state.
    var boss_battle = BATTLE.new(db)
    boss_battle.party.append(hero.duplicate(true))
    boss_battle.add_enemy(548)
    boss_battle.add_enemy(600)
    boss_battle.boss_runtime.active = true
    boss_battle.field_weather.active = true
    boss_battle.source_atb_rolls_for_test = {
        "actor:0":0,"enemy:0":0,"enemy:1":0}
    boss_battle.start()
    boss_battle.advance_atb(1.0/60.0)
    if not _check(boss_battle.field_weather.current_id==153 and
            boss_battle.enemies[0]["fs_phase_state_intents"]==[122] and
            boss_battle.enemies[0].get("states",[]).is_empty(),
            "Boss548 forces real global weather while Phase State122 remains unapplied"): return
    var synthetic: Dictionary = boss_battle.enemies[1]
    var damage_before: int = int(synthetic["hp"])
    if not _check(boss_battle.attack(hero,synthetic)>0 and
            int(synthetic["hp"])<damage_before,
            "normal unshielded troop enemy receives active global weather damage"): return
    var ui = SCREEN.new()
    root.add_child(ui)
    ui.battle = boss_battle
    ui.db = db
    ui._refresh_battle_status()
    if not _check("State意圖" in ui.status_label.text,
            "unverified Boss State remains explicitly pending on battle screen"): return

    print("FS #404 weather real positive damage, late cost/field switching, queue, Boss global integration PASS")
    quit(0)
