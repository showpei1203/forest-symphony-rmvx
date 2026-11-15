extends SceneTree

# Synthetic native ORIGINAL CustomDmgFormulaRD positive SKILL subset.
# Exact source phases: 197335 YEM RD integer terms -> crit/variance/guard
# -> 205460 smooth/legacy ratio (Integer.to_i, NOT round).
# FSBattle then applies global Field404 and ComboCore Shield77, and
# FSActionQueue charges MP at ACT resolution only.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    if not ok:
        push_error("FS original skill smooth integration FAIL: "+reason)
        quit(1)
        return false
    return true

func _skill(id: int,atk_f: int,spi_f: int,
        note: String = "",crit: bool = false,
        ignore_defense: bool = false) -> Dictionary:
    return {"id":id,"name":"FS Source Spell%d" % id,
        "scope":1,"occasion":0,"hit":95,"physical_attack":false,
        "base_damage":100,"atk_f":atk_f,"spi_f":spi_f,
        "has_critical":crit,"cri":0,"variance":0,
        "ignore_defense":ignore_defense,"mp_cost":10,"note":note,
        "element_set":[1],"plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false,
        "fs_smooth_source_verified":true}

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(154)
    states[77] = {"id":77,"name":"Mana Shield",
        "note":"<mana_shield 3000:60>",
        "reduce_hit_ratio":false,"restriction":0}
    states[153] = {"id":153,"name":"Global Field153",
        "note":"<field_damage 1: +50>"}
    db.tables={"states":states,"weapons":[null],"armors":[null],
        "skills":[null,_skill(1,100,0),_skill(2,0,100),
            _skill(3,50,50),_skill(4,100,0,"",true),
            _skill(5,100,0,"<pen_rate:50>"),
            _skill(6,100,0,"",false,true),
            _skill(7,100,0,"<unsupported_custom:7>")],
        "enemies":[null,{"id":1,"name":"Skill Armor",
            "maxhp":10000,"maxmp":1000,"atk":50,"def":10,
            "spi":10,"agi":20,"hit":95,"eva":5,
            "has_critical":false,"note":"","actions":[]}]}
    return db

func _battle() -> FSBattle:
    var b = BATTLE.new(_db())
    b.party.append({"id":1,"name":"Source Mage","actor":true,
        "hp":2500,"maxhp":2500,"mp":100,"maxmp":100,
        "atk":50,"def":10,"spi":20,"agi":20,
        "hit":95,"eva":5,"cri":10,
        "skills":[1,2,3,4,5,6,7],"equipment":[0,0,0,0,0],
        "states":[],"element_set":[1],"note":"",
        "fs_smooth_battler_verified":true})
    b.add_enemy(1)
    b.enemies[0]["fs_smooth_battler_verified"] = true
    b.enemies[0]["fs_smooth_element_neutral_verified"] = true
    b.accuracy.active = true
    b.skill_core.active = true
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    return b

func _run() -> void:
    var b: FSBattle = _battle()
    if not _check(b.start(),"skill source-shaped battle starts"): return
    var hero: Dictionary = b.party[0]
    var target: Dictionary = b.enemies[0]
    var q: Dictionary = b.skill_core.quote(b,hero,target,
        b.db.record("skills",1))
    if not _check(q.get("ok",false) and int(q["legacy"])==190 and
            int(q["raw"])==200 and int(q["def_penalty"])==10 and
            is_equal_approx(float(q["smooth"]),184.61538461538),
            "YEM RD: base100+ATK50*2=200-DEF10=>190; smooth184.615"): return
    var before_hp: int = int(target["hp"])
    var before_mp: int = int(hero["mp"])
    b.accuracy.scripted_rolls = [0,99]
    if not _check(b.skill_preflight(hero,target,1) and
            b.accuracy.scripted_rolls==[0,99] and
            b.use_skill(hero,target,1) and
            int(target["hp"])==before_hp-184 and
            int(hero["mp"])==before_mp-10 and
            int(b.skill_core.events[-1]["damage"])==184,
            "real source skill executes 190 * smooth_ratio => Integer184 and MP10 once"): return

    q = b.skill_core.quote(b,hero,target,b.db.record("skills",2))
    if not _check(int(q["legacy"])==130 and
            is_equal_approx(float(q["smooth"]),129.23076923077),
            "SPI-only coefficient uses user SPI20x2 and target SPI10"): return
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    if not _check(b.use_skill(hero,target,2) and
            int(target["hp"])==before_hp-129,
            "SPI-sourced RD skill deals truncated smooth129"): return

    q = b.skill_core.quote(b,hero,target,b.db.record("skills",3))
    if not _check(int(q["legacy"])==160 and
            is_equal_approx(float(q["smooth"]),156.92307692308),
            "mixed ATK50/SPI50 weighted target defense source ratio"): return
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    if not _check(b.use_skill(hero,target,3) and
            int(target["hp"])==before_hp-156,
            "mixed source skill truncates smooth156"): return

    q = b.skill_core.quote(b,hero,target,b.db.record("skills",5))
    if not _check(int(q["pen"])==50 and
            is_equal_approx(float(q["smooth"]),192.0),
            "FS skill Note pen_rate50 halves DEF to5, smooth192"): return
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    if not _check(b.use_skill(hero,target,5) and
            int(target["hp"])==before_hp-192,
            "Note defense penetration changes real skill HP delta"): return

    q = b.skill_core.quote(b,hero,target,b.db.record("skills",6))
    if not _check(float(q["ratio"])==1.0 and int(q["legacy"])==200,
            "ignore_defense bypasses smoothing rather than double-penetrating"): return
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    if not _check(b.use_skill(hero,target,6) and
            int(target["hp"])==before_hp-200,
            "ignore_defense source skill keeps raw200"): return

    # This final source Skill CRIT uses YEM RD CRIT_MOD=200%, not
    # the ordinary attack's CRITICAL_RATE=170%.
    hero["mp"] = 100
    b.accuracy.scripted_rolls = [0,99,0]
    before_hp = int(target["hp"])
    if not _check(b.use_skill(hero,target,4) and
            int(target["hp"])==before_hp-369 and
            bool(target.get("fs_last_action_critical",false)) and
            b.accuracy.scripted_rolls.is_empty(),
            "skill CRIT190*2 then trunc smooth ratio =369"): return

    # Source Guard occurs BEFORE smooth-ratio postprocessing. 190/2=95,
    # ratio184.615/190 => truncated92, not round93 or guard184/2.
    target["guarding"] = true
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    if not _check(b.use_skill(hero,target,1) and
            int(target["hp"])==before_hp-92,
            "source skill Guard halves legacy190 before ratio =>92"): return
    target["guarding"] = false

    # Real Field404 + ComboCore77: smooth184 -> weather+50%=276,
    # ManaShield60%=165 MP, HP damage111 and caster MP10 exactly.
    hero["mp"] = 100
    b.field_weather.active = true
    if not _check(b.field_weather.set_field(b.db,153,hero,true),
            "global source Field153 starts for actual skill"): return
    b.boss_state_effects.active = true
    target["states"] = [77]
    target["fs_applied_boss_states"] = [77]
    target["fs_boss_stat_rates"] = {"def":100.0,"spi":100.0}
    target["fs_boss_shield_remaining"] = 3000
    target["fs_boss_shield_rate"] = 60
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    before_mp = int(target["mp"])
    if not _check(b.use_skill(hero,target,1) and
            int(target["hp"])==before_hp-111 and
            int(target["mp"])==before_mp-165 and
            int(target["fs_boss_shield_remaining"])==2835 and
            int(hero["mp"])==90,
            "real skill smooth184 -> global Field276 -> Shield77 HP111/MP165"): return

    # Source spell with unverified Note must fail BEFORE HIT/MP/HP.
    hero["mp"] = 100
    b.accuracy.scripted_rolls = [0,99]
    before_hp = int(target["hp"])
    before_mp = int(hero["mp"])
    if not _check(not b.skill_preflight(hero,target,7) and
            not b.use_skill(hero,target,7) and
            b.accuracy.scripted_rolls==[0,99] and
            int(hero["mp"])==before_mp and
            int(target["hp"])==before_hp,
            "unknown original Skill Note refuses cost and RNG, no fake smoothing"): return

    # Source skill miss costs MP at actual execution, but does not roll
    # damage/crit/variance, irrespective of the smooth ratio.
    b.field_weather.clear_field(b.db,true)
    target["states"] = []
    target.erase("fs_applied_boss_states")
    b.accuracy.scripted_rolls = [95]
    before_hp = int(target["hp"])
    before_mp = int(hero["mp"])
    if not _check(b.use_skill(hero,target,1) and
            int(hero["mp"])==before_mp-10 and
            int(target["hp"])==before_hp and
            b.accuracy.scripted_rolls.is_empty() and
            str(target.get("fs_last_action_result",""))=="miss",
            "single-target source skill miss pays MP without calculating damage"): return

    # Actual Tankentai actor command -> ACT charge -> source skill power
    # -> completed action/recharge. This goes through FSActionQueue, not
    # a direct one-shot battle.use_skill() call.
    var queued: FSBattle = _battle()
    if not _check(queued.start(),"native skill queue fixture starts"): return
    var q_actor: Dictionary = queued.party[0]
    var q_target: Dictionary = queued.enemies[0]
    q_actor["source_at_active"] = true
    q_actor["source_atb_count_up"] = false
    q_actor["source_atb_count"] = 1000
    queued.accuracy.scripted_rolls = [0,99]
    var q_hp: int = int(q_target["hp"])
    if not _check(queued.queue_actor_action(0,"skill",0,1) and
            queued.has_actor_pending_action(0) and
            int(q_actor["mp"])==100 and int(q_target["hp"])==q_hp and
            queued.accuracy.scripted_rolls==[0,99],
            "source skill command queues without early MP or RNG draw"): return
    queued.advance_atb(1.0/60.0)
    if not _check(not queued.has_actor_pending_action(0) and
            queued.action_queue.completed.size()==1 and
            bool(queued.action_queue.completed[0]["success"]) and
            int(q_actor["mp"])==90 and int(q_target["hp"])==q_hp-184 and
            bool(q_actor["source_atb_count_up"]),
            "native ACT skill1 source smooth184 pays MP10 once and recharges"): return
    # Skill MISS still pays MP and completes the queued ACT.
    q_actor["source_at_active"] = true
    q_actor["source_atb_count_up"] = false
    q_actor["source_atb_count"] = 1000
    queued.accuracy.scripted_rolls = [95]
    q_hp = int(q_target["hp"])
    if not _check(queued.queue_actor_action(0,"skill",0,1),
            "queued second skill enters ACT"): return
    queued.advance_atb(1.0/60.0)
    if not _check(queued.action_queue.completed.size()==2 and
            bool(queued.action_queue.completed[1]["success"]) and
            int(q_actor["mp"])==80 and int(q_target["hp"])==q_hp and
            str(q_target.get("fs_last_action_result",""))=="miss",
            "queued MISS consumes MP10 and ACT but no HP damage"): return

    # Unverified CRIT RNG fails at the end of charge WITHOUT paying MP.
    hero["mp"] = 100
    b.accuracy.scripted_rolls = [0,99,100]
    before_hp = int(target["hp"])
    before_mp = int(hero["mp"])
    if not _check(not b.use_skill(hero,target,4) and
            int(hero["mp"])==before_mp and
            int(target["hp"])==before_hp and
            not b.accuracy.failures.is_empty(),
            "invalid final critical RNG aborts source skill before MP payment"): return

    print("FS source YEM skill coefficients, smooth defense, CRIT200, Guard, Pen, Field404, Shield77, MP-on-MISS PASS")
    quit(0)
