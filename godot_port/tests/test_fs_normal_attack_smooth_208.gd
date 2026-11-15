extends SceneTree

# Source-shaped FS CustomDmgFormulaRD legacy attack -> smooth-rate
# postprocessor, integrated with real FSBattle, global Field404,
# ComboCore Shield77, ATB action queue and deterministic raw RNG.
# NO proprietary post-Apply 11-table witness is fabricated here.
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const CORE = preload("res://scripts/FSNormalAttackCore.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,why: String) -> bool:
    if not ok:
        push_error("FS original smooth normal attack FAIL: "+why)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    var states: Array = []
    states.resize(154)
    states[77] = {"id":77,"name":"Mana Shield","note":"<mana_shield 3000:60>",
        "reduce_hit_ratio":false,"restriction":0}
    states[152] = {"id":152,"name":"Loss of Harmony",
        "note":"<hud_priority:520>","reduce_hit_ratio":false,
        "restriction":0}
    states[153] = {"id":153,"name":"Global Field153",
        "note":"<field_damage 1: +50>"}
    var weapons: Array = [null,
        {"id":1,"name":"120% Saber","note":
            "<normal_atk_rate:120>\n<pen_rate:25>",
            "element_set":[1]}]
    db.tables={
        "states":states,
        "weapons":weapons,
        "armors":[null],
        "enemies":[null,{"id":1,"name":"Smooth Dummy",
            "maxhp":10000,"maxmp":1000,"atk":50,"def":10,"spi":10,
            "agi":20,"hit":95,"eva":5,"has_critical":false,
            "note":"","actions":[]}]
    }
    return db

func _battle() -> FSBattle:
    var b = BATTLE.new(_db())
    var actor: Dictionary = {"id":1,"name":"Hero","actor":true,
        "hp":4000,"maxhp":4000,"mp":100,"maxmp":100,"level":1,
        "atk":50,"def":10,"spi":10,"agi":20,"hit":95,"eva":5,"cri":10,
        "element_set":[1],"equipment":[0,0,0,0,0],
        "states":[],"note":"","two_swords_style":false,
        "fs_normal_source_verified":true,
        "fs_normal_equipment_verified":true,
        "fs_normal_element_neutral_verified":true}
    b.party.append(actor)
    if not b.add_enemy(1):
        return b
    var enemy: Dictionary = b.enemies[0]
    enemy["fs_normal_source_verified"] = true
    enemy["fs_normal_enemy_note_verified"] = true
    enemy["fs_normal_element_neutral_verified"] = true
    b.accuracy.active = true
    b.normal_core.active = true
    b.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    return b

func _run() -> void:
    var b: FSBattle = _battle()
    if not _check(b.start(),"source normal-attack battle begins"): return
    var actor: Dictionary = b.party[0]
    var target: Dictionary = b.enemies[0]
    var q: Dictionary = b.normal_core.quote(b,actor,target)
    if not _check(q.get("ok",false) and int(q["legacy"])==14 and
            is_equal_approx(float(q["smooth"]),110.7692307692) and
            int(q["attack_rate"])==100 and int(q["penetration"])==0,
            "actual source level1 attack50 defense10 legacy14 smooth110.769"): return

    # Pure preflight: no power roll or HIT/EVA/CRI roll before ACT.
    b.accuracy.scripted_rolls = [0,99,0,99,99,0,0]
    var hp_before: int = int(target["hp"])
    if not _check(b.attack_preflight(actor,target) and
            b.accuracy.draws.is_empty() and
            b.accuracy.scripted_rolls.size()==7,
            "source quote does not consume RNG before final resolution"): return
    if not _check(b.attack(actor,target)==87 and
            int(target["hp"])==hp_before-87 and
            b.accuracy.scripted_rolls.is_empty() and
            b.accuracy.draws.size()==7 and
            int(b.normal_core.events[-1]["rolled_factor"])==85 and
            int(b.normal_core.events[-1]["damage"])==87,
            "source level/core: 14*85pct=11, 5pct variance0, round(11*110.769/14)=87"): return
    var actual_draw_order: Array = b.accuracy.draws.map(
        func(row: Dictionary): return str(row["kind"]))
    if not _check(actual_draw_order==[
            "hit","eva","legacy_attack_power",
            "legacy_critical_provisional","critical_final",
            "variance_a","variance_b"],
            "original critical takes TWO RNG rolls before Yanfly variance"): return

    # First crit d100=99, later final source common_critical d100=0.
    # Legacy14 *170pct=>23, amp1 draws0+1-1 =>23, round(23*ratio)=182.
    b.accuracy.draws.clear()
    b.accuracy.scripted_rolls = [0,99,15,99,0,0,1]
    hp_before = int(target["hp"])
    if not _check(b.attack(actor,target)==182 and
            int(target["hp"])==hp_before-182 and
            bool(target.get("fs_last_action_critical",false)) and
            b.accuracy.scripted_rolls.is_empty(),
            "final critical overrides provisional and smooth ratio applies after variance"): return

    # Source FS_BALANCE.normal_atk_rate: source Note wins power legacy;
    # <pen_rate> subtracts effective target DEF before smooth.
    actor["equipment"] = [1,0,0,0,0]
    var rate: Dictionary = b.normal_core.quote(b,actor,target)
    if not _check(rate.get("ok",false) and
            int(rate["attack_rate"])==120 and
            int(rate["penetration"])==25 and
            is_equal_approx(float(rate["smooth"]),131.76470588235),
            "source weapon120 and penetration25 yield raw140 / DEF7.5"): return
    b.accuracy.scripted_rolls = [0,99,15,99,99,0,0]
    hp_before = int(target["hp"])
    if not _check(b.attack(actor,target)==132 and
            int(target["hp"])==hp_before-132,
            "source weapon120 percent with legacy14 power and smooth132"): return
    actor["equipment"] = [0,0,0,0,0]

    # Source <normal_power> compatibility, including old fixed values.
    var compat: Dictionary = CORE.LEGACY_RATES
    if not _check(CORE._legacy_rate(300)==120 and
            CORE._legacy_rate(55)==110 and
            CORE._legacy_rate(70)==140 and
            CORE._legacy_rate(420)==150 and
            int(compat[380])==140,
            "historical normal_power values retain source clamp and mapping"): return

    # Source Guard ordering precedes smooth ratio. With crit14→23, 
    # variance [0,1] =>23, Guard half=11, smooth=round(87).
    target["guarding"] = true
    b.accuracy.scripted_rolls = [0,99,15,99,0,0,1]
    if not _check(b.attack(actor,target)==87 and
            int(b.normal_core.events[-1]["before_ratio"])==11,
            "source guard halves 23 to11 BEFORE smooth ratio"): return
    target["guarding"] = false

    # Global Field404 + ComboCore Shield77 are downstream of smooth.
    b.field_weather.active = true
    if not _check(b.field_weather.set_field(b.db,153,actor,true),
            "global Field153 starts"): return
    b.boss_state_effects.active = true
    target["states"] = [77]
    target["fs_applied_boss_states"] = [77]
    target["fs_boss_stat_rates"] = {"def":100.0}
    target["fs_boss_shield_remaining"] = 3000
    target["fs_boss_shield_rate"] = 60
    b.accuracy.scripted_rolls = [0,99,0,99,99,0,0]
    hp_before = int(target["hp"])
    var mp_before: int = int(target["mp"])
    var received: int = b.attack(actor,target)
    if not _check(received==53 and int(target["hp"])==hp_before-53 and
            int(target["mp"])==mp_before-78 and
            int(target["fs_boss_shield_remaining"])==2922 and
            int(b.normal_core.events[-1]["damage"])==87,
            "source smooth87 -> Field404+50pct=>131 -> Shield77 HP53/MP78"): return

    # Guard against unsupported weapon/elements: no RNG consumed or HP
    # mutation. Source alias parity is never silently inferred.
    target["states"] = []
    target.erase("fs_applied_boss_states")
    b.field_weather.clear_field(b.db,true)
    actor["fs_normal_equipment_verified"] = false
    b.accuracy.scripted_rolls = [0,99,0,99,99,0,0]
    hp_before = int(target["hp"])
    if not _check(not b.attack_preflight(actor,target) and
            b.attack(actor,target)==0 and
            int(target["hp"])==hp_before and
            b.accuracy.scripted_rolls.size()==7,
            "missing equipment alias evidence refuses BEFORE any RNG and HP mutation"): return
    actor["fs_normal_equipment_verified"] = true
    target["fs_normal_element_neutral_verified"] = false
    if not _check(not b.attack_preflight(actor,target) and
            b.accuracy.scripted_rolls.size()==7,
            "unverified element type cannot masquerade as neutral"): return

    # Boss State152 affects the SMOOTH source formula through actual
    # source stat promotion. Do not reduce the new core to raw ATK*4.
    target["states"] = [152]
    target["fs_applied_boss_states"] = [152]
    target["fs_boss_stat_rates"] = {"atk":115.0,"def":100.0}
    var boss_quote: Dictionary = b.normal_core.quote(b,target,actor)
    if not _check(boss_quote.get("ok",false) and
            int(boss_quote["attack"])==57 and
            int(boss_quote["legacy"])==15 and
            is_equal_approx(float(boss_quote["smooth"]),123.6923076923),
            "Boss State152 true ATK+15% drives smooth core 20+57x2 vs heroDEF10"): return
    b.accuracy.scripted_rolls = [0,99,0,99,99,0,0]
    var hero_hp: int = int(actor["hp"])
    var boss_hit: int = b.attack(target,actor)
    if not _check(boss_hit==99 and int(actor["hp"])==hero_hp-99 and
            b.accuracy.scripted_rolls.is_empty(),
            "Boss State152 effective ATK57 live source attack deals smooth99"): return

    print("FS normal legacy->smooth actual battle, 2x CRIT, 5pct RNG, guard, weapon, Field404, Shield77, fail-closed PASS")
    quit(0)
