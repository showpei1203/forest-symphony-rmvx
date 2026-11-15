extends SceneTree

# Source bounded RPG::State rates + ComboCore <mana_shield 3000:60>.
# Source-only witness fixtures, NOT original post-Apply database authority.
# States 128/129 with hold_turn 4/2 and auto_release 100 are deliberately
# refused until native turn/end-action parity is implemented.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const EFFECT = preload("res://scripts/FSBossCombatStates.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool,why: String) -> bool:
    if not ok:
        push_error("FS Boss real State subset FAIL: "+why)
        quit(1)
        return false
    return true

func _state(id: int,atk: int = 100,def: int = 100,
        spi: int = 100,agi: int = 100,hold: int = 99,
        release: int = 0,note: String = "<hud_priority:500>") -> Dictionary:
    return {"id":id,"name":"FS source State%d" % id,
        "atk_rate":atk,"def_rate":def,"spi_rate":spi,"agi_rate":agi,
        "hold_turn":hold,"auto_release_prob":release,
        "restriction":0,"release_by_damage":false,"slip_damage":false,
        "battle_only":true,"nonresistance":false,
        "offset_by_opposite":false,"reduce_hit_ratio":false,
        "state_set":[],"note":note}

func _skill() -> Dictionary:
    return {"id":1,"name":"Hit100","scope":1,"occasion":0,
        "base_damage":100,"atk_f":0,"spi_f":0,"mp_cost":10,
        "note":"","element_set":[1],"ignore_defense":false,
        "plus_state_set":[],"minus_state_set":[],
        "damage_to_mp":false,"absorb_damage":false}

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(159)
    states[77] = _state(77,100,100,100,100,99,0,
        "<mana_shield 3000:60>\n<hud_priority:420>")
    for sid in [122,123,124,140,141,142,143,150,151]:
        states[sid] = _state(sid)
    states[125] = _state(125,110,115,100,105)
    states[126] = _state(126,100,110,110,105)
    states[127] = _state(127,105,100,105,115)
    states[152] = _state(152,115,100,115,115)
    states[128] = _state(128,120,90,120,115,4,100)
    states[129] = _state(129,100,70,70,100,2,100)
    var enemies: Array = []
    enemies.resize(566)
    var law_note: String = "<fs_fixed_enemy_stats>\n" + \
        "<law_cycle_states:140,141,142,143>\n" + \
        "<law_cycle_interval:3>\n<law_cycle_if_state:151>"
    for id in [524,530,531,561,562,563,564,565]:
        enemies[id] = {"id":id,"name":"Boss%d" % id,
            "maxhp":10000,"maxmp":5000,"atk":30,"def":20,
            "spi":40,"agi":60,"note":law_note if id==524 else
                "<fs_fixed_enemy_stats>",
            "actions":[{"kind":0,"basic":0,"skill_id":0,"rating":8,
                "condition_type":0,"condition_param1":0,
                "condition_param2":0}]}
    db.tables={"states":states,"enemies":enemies,"skills":[null,_skill()],
        "weapons":[null],"armors":[null]}
    return db

func _battle(db: FSDatabase,boss_id: int) -> FSBattle:
    var b = BATTLE.new(db)
    b.party.append({"id":1,"name":"Hero","actor":true,
        "hp":2000,"maxhp":2000,"mp":500,"maxmp":500,
        "agi":20,"atk":100,"def":10,"spi":25,"skills":[1],
        "element_set":[1],"states":[],"note":"","odds":4,
        "equipment":[0,0,0,0,0],"two_swords_style":false})
    b.add_enemy(boss_id)
    b.boss_runtime.active = true
    b.boss_state_effects.active = true # Synthetic authority, never auto-production.
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0,
        "enemy:1":0,"enemy:2":0,"enemy:3":0,"enemy:4":0}
    return b

func _run() -> void:
    var db = _db()
    var phase = _battle(db,524)
    if not _assert(phase.start(),"Boss524 battle starts"): return
    var boss: Dictionary = phase.enemies[0]
    phase.advance_atb(1.0/60.0)
    if not _assert(boss.get("states",[])==[150] and
            not bool(boss.get("fs_boss_phase_effects_pending",true)),
            "State150 truly applied as bounded RPG State, no pending flag"): return
    boss["hp"] = 7000
    phase.advance_atb(1.0/60.0)
    if not _assert(boss.get("states",[])==[151,140] and
            not bool(boss.get("fs_boss_phase_effects_pending",true)),
            "HP70% applies source-approved State151+Law140 to live battler"): return
    for k in range(3):
        phase.enemy_valid_action_completed(boss)
    phase.advance_atb(1.0/60.0)
    if not _assert(boss.get("states",[])==[151,141],
            "three real valid enemy actions propagate Law141 to battler States"): return
    boss["hp"] = 3500
    phase.advance_atb(1.0/60.0)
    if not _assert(boss.get("states",[])==[152] and
            phase.boss_state_effects.stat(boss,"atk")==34 and
            phase.boss_state_effects.stat(boss,"spi")==46 and
            phase.boss_state_effects.stat(boss,"agi")==69,
            "HP35% source State152 applies 115% atk/spi/agi rates"): return
    var hero: Dictionary = phase.party[0]
    var hero_before: int = int(hero["hp"])
    if not _assert(phase.attack(boss,hero)==116 and
            int(hero["hp"])==hero_before-116,
            "live Boss524 attack formula uses atk30x115%=34 and deals116"): return
    boss["hp"] = 6000
    phase.advance_atb(1.0/60.0)
    if not _assert(boss.get("states",[])==[152,151,140],
            "healed Boss re-adds State151+first law while retaining State152"): return

    var shield = _battle(db,530)
    if not _assert(shield.start(),"Boss530 shield battle starts"): return
    shield.advance_atb(1.0/60.0)
    var protected: Dictionary = shield.enemies[0]
    if not _assert(shield.enemies.size()==3 and
            protected.get("states",[])==[77] and
            int(protected.get("fs_boss_shield_remaining",0))==3000 and
            not bool(protected.get("fs_boss_phase_effects_pending",true)),
            "two cores summon and real Shield77 begins at capacity3000"): return
    var protected_hp: int = int(protected["hp"])
    var protected_mp: int = int(protected["mp"])
    var caster: Dictionary = shield.party[0]
    var caster_mp: int = int(caster["mp"])
    if not _assert(shield.use_skill(caster,protected,1) and
            int(caster["mp"])==caster_mp-10 and
            int(protected["hp"])==protected_hp-40 and
            int(protected["mp"])==protected_mp-60 and
            int(protected["fs_boss_shield_remaining"])==2940,
            "real skill100 pays caster MP10 once; shield60 MP and HP40"): return
    protected_hp = int(protected["hp"])
    protected_mp = int(protected["mp"])
    if not _assert(shield.attack(caster,protected)==144 and
            int(protected["hp"])==protected_hp-144 and
            int(protected["mp"])==protected_mp-216 and
            int(protected["fs_boss_shield_remaining"])==2724,
            "live attack360 is split HP144 and MP216 by source shield60pct"): return
    # Unsupported timed-state effects must refuse BEFORE any HP/MP mutation.
    protected["hp"] = 4500
    shield.advance_atb(1.0/60.0)
    if not _assert(protected.get("states",[])==[77] and
            bool(protected.get("fs_boss_phase_effects_pending",false)) and
            protected.get("fs_phase_state_intents",[]).has(128),
            "State128 hold4/auto100 remains pending, no false application"): return
    caster_mp = int(caster["mp"])
    protected_hp = int(protected["hp"])
    if not _assert(not shield.skill_preflight(caster,protected,1) and
            not shield.use_skill(caster,protected,1) and
            shield.attack(caster,protected)==0 and
            int(caster["mp"])==caster_mp and
            int(protected["hp"])==protected_hp,
            "unsupported timed Boss effect fail-closes direct attack and skill"): return
    for k in range(1,shield.enemies.size()):
        shield.enemies[k]["hp"] = 0
    shield.advance_atb(1.0/60.0)
    if not _assert(protected.get("fs_phase_state_intents",[]).has(129) and
            bool(protected.get("fs_boss_phase_effects_pending",false)),
            "core death exposure129 remains blocked pending real turn expiry"): return

    var bad = _db()
    bad.tables["states"][77]["note"] += "\n<unknown_damage_effect:99>"
    var denied = _battle(bad,530)
    denied.start()
    denied.advance_atb(1.0/60.0)
    if not _assert(denied.enemies[0].get("states",[]).is_empty() and
            bool(denied.enemies[0].get("fs_boss_phase_effects_pending",false)) and
            not denied.boss_state_effects.errors.is_empty(),
            "unknown State77 Note cannot silently enter a live combat state"): return

    print("FS Boss source State152 rates, Law140-143, ComboCore Shield77 damage, timed-state guards PASS")
    quit(0)
