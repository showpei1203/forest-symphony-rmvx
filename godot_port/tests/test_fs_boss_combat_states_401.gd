extends SceneTree

# Source bounded RPG::State rates + ComboCore <mana_shield 3000:60>.
# Source-only witness fixtures, NOT original post-Apply database authority.
# Source128/129 hold_turn 4/2 with auto_release 100 are checked
# at Tankentai ATB READY, not per rendered frame or ACT completion.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const EFFECT = preload("res://scripts/FSBossCombatStates.gd")
const ATB = preload("res://scripts/FSTankentaiATBCore.gd")
const SCREEN = preload("res://scripts/FSScreen.gd")

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
    states[153] = {"id":153,"note":"<field_weather>"}
    states[156] = {"id":156,"note":"<field_weather>"}
    var enemies: Array = []
    enemies.resize(566)
    var law_note: String = "<fs_fixed_enemy_stats>\n" + \
        "<law_cycle_states:140,141,142,143>\n" + \
        "<law_cycle_interval:3>\n<law_cycle_if_state:151>"
    for id in [524,530,531,548,558,561,562,563,564,565]:
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

func _force_ready(b: FSBattle,enemy: Dictionary) -> void:
    # Isolate the real Tankentai gauge crossing and source phase refresh
    # without scheduling a fake enemy AI action to accelerate a test.
    enemy["source_atb_count"] = 999
    enemy["source_atb_count_up"] = true
    enemy["source_at_active"] = false
    enemy["source_act_active"] = false
    ATB.advance_frames(b.party,b.enemies,1,false)
    b.boss_state_effects.on_atb_ready(b)
    b.boss_runtime.tick(b)
    b.boss_state_effects.sync(b)

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

    # Boss548 low-HP Source State125 is a *real* stat buff, separate
    # from the 153/156 global weather. All native buffs are applied after
    # the verified source #401 55%-HP transition.
    var weather_phase = _battle(db,548)
    if not _assert(weather_phase.start(),"Boss548 battle starts"): return
    weather_phase.advance_atb(1.0/60.0)
    var source548: Dictionary = weather_phase.enemies[0]
    if not _assert(source548.get("states",[])==[122] and
            weather_phase.boss_state_effects.stat(source548,"def")==20,
            "Boss548 initial State122 is an actual neutral-rate battler State"): return
    source548["hp"] = 5500
    weather_phase.advance_atb(1.0/60.0)
    if not _assert(source548.get("states",[])==[125] and
            weather_phase.boss_state_effects.stat(source548,"atk")==33 and
            weather_phase.boss_state_effects.stat(source548,"def")==23 and
            weather_phase.boss_state_effects.stat(source548,"agi")==63,
            "Boss548 exact55% changes actual State125 stats atk110 def115 agi105"): return
    var weather_hero_hp: int = int(weather_phase.party[0]["hp"])
    if not _assert(weather_phase.attack(source548,weather_phase.party[0])==112 and
            int(weather_phase.party[0]["hp"])==weather_hero_hp-112,
            "Boss548 State125 real attack uses atk33 damage112"): return

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
    # ComboCore removes State77 when capacity reaches zero. Source Boss
    # phase hook reinstates the shield on its next update if cores survive.
    caster["atk"] = 1260
    protected_hp = int(protected["hp"])
    protected_mp = int(protected["mp"])
    if not _assert(shield.attack(caster,protected)==2276 and
            int(protected["hp"])==protected_hp-2276 and
            int(protected["mp"])==protected_mp-2724 and
            int(protected["fs_boss_shield_remaining"])==0 and
            not protected.get("states",[]).has(77),
            "shield capacity depletes at2724, removes State77 and splits hit5000"): return
    shield.advance_atb(1.0/60.0)
    if not _assert(protected.get("states",[]).has(77) and
            int(protected.get("fs_boss_shield_remaining",0))==3000,
            "Boss530 source re-adds State77 next frame while its cores survive"): return
    caster["atk"] = 100
    var ui = SCREEN.new()
    root.add_child(ui)
    ui.db = db
    ui.battle = shield
    ui._refresh_battle_status()
    if not _assert("已生效Boss State:[77]" in ui.status_label.text and
            "MP護盾剩餘:3000" in ui.status_label.text,
            "actual Godot BATTLE shows applied State77 and replenished shield capacity"): return
    # Source 128 is a true +20% ATK/SPI, -10% DEF, +15% AGI
    # timed State, automatically renewed by source Boss530 at HP<=45%.
    protected["hp"] = 4500
    shield.advance_atb(1.0/60.0)
    if not _assert(protected.get("states",[])==[77,128] and
            not bool(protected.get("fs_boss_phase_effects_pending",true)) and
            shield.boss_state_effects.stat(protected,"atk")==36 and
            shield.boss_state_effects.stat(protected,"def")==18 and
            int(protected.get("fs_boss_state_turns",{}).get("128",-1))==4,
            "State128 applies actual overheat rate and starts hold_turn4"): return
    caster_mp = int(caster["mp"])
    protected_hp = int(protected["hp"])
    if not _assert(shield.use_skill(caster,protected,1) and
            int(caster["mp"])==caster_mp-10 and
            int(protected["hp"])==protected_hp-40,
            "overheat phase can take a real skill while Shield77 absorbs MP"): return
    for k in range(1,shield.enemies.size()):
        shield.enemies[k]["hp"] = 0
    shield.advance_atb(1.0/60.0)
    if not _assert(protected.get("states",[])==[128,129] and
            not bool(protected.get("fs_boss_phase_effects_pending",true)) and
            shield.boss_state_effects.stat(protected,"def")==12 and
            int(protected.get("fs_boss_state_turns",{}).get("129",-1))==2,
            "core death removes Shield77 and applies Exposure129 -30% DEF/SPI"): return
    # Source Boss530 keeps its Overheat128 but Exposure129 is once-only.
    var before_wait: int = int(protected["fs_boss_state_turns"]["129"])
    shield.source_atb_wait = true
    shield.advance_atb(12.0/60.0)
    shield.source_atb_wait = false
    if not _assert(int(protected["fs_boss_state_turns"]["129"])==before_wait,
            "ATB WAIT/visual frames never expire a timed RPG State"): return
    _force_ready(shield,protected)
    if not _assert(int(protected["fs_boss_state_turns"]["129"])==1 and
            protected.get("states",[]).has(129),
            "first READY subtracts State129 turn2->1"): return
    _force_ready(shield,protected)
    if not _assert(int(protected["fs_boss_state_turns"]["129"])==0 and
            protected.get("states",[]).has(129),
            "second READY subtracts State129 turn1->0 without releasing"): return
    _force_ready(shield,protected)
    if not _assert(not protected.get("states",[]).has(129) and
            protected.get("states",[]).has(128) and
            shield.boss_runtime.flags.has("exposed:530") and
            shield.boss_state_effects.stat(protected,"def")==18,
            "third READY guarantees Exposure129 release and recomputes DEF"): return
    _force_ready(shield,protected)
    _force_ready(shield,protected)
    if not _assert(protected.get("states",[]).has(128) and
            not protected.get("states",[]).has(129) and
            int(protected.get("fs_boss_state_turns",{}).get("128",-1))==4,
            "fifth READY expires Overheat128 then source Boss530 renews it"): return
    var auto_release_count: int = 0
    for event in shield.boss_state_effects.transitions:
        if str(event.get("op",""))=="auto_release_atb_ready":
            auto_release_count += 1
    if not _assert(auto_release_count==2,
            "two exact auto-release events: Exposure129 once, Overheat128 once"): return

    var bad = _db()
    bad.tables["states"][77]["note"] += "\n<unknown_damage_effect:99>"
    var denied = _battle(bad,530)
    denied.start()
    denied.advance_atb(1.0/60.0)
    if not _assert(denied.enemies[0].get("states",[]).is_empty() and
            bool(denied.enemies[0].get("fs_boss_phase_effects_pending",false)) and
            not denied.boss_state_effects.errors.is_empty(),
            "unknown State77 Note cannot silently enter a live combat state"): return

    # Corrupted timer authority must still fail closed, never advance
    # or randomly release a State without source witnesses.
    var corrupt = _db()
    corrupt.tables["states"][128]["auto_release_prob"] = 75
    var corrupt_battle = _battle(corrupt,530)
    corrupt_battle.start()
    corrupt_battle.advance_atb(1.0/60.0)
    corrupt_battle.enemies[0]["hp"] = 4500
    corrupt_battle.advance_atb(1.0/60.0)
    if not _assert(corrupt_battle.enemies[0].get("states",[])==[77] and
            bool(corrupt_battle.enemies[0].get("fs_boss_phase_effects_pending",false)),
            "non-source auto-release chance refuses actual State128"): return

    print("FS Boss actual State rates, Shield77, 128/129 Tankentai READY expiry, native UI PASS")
    quit(0)
