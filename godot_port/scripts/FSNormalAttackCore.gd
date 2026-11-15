extends RefCounted
class_name FSNormalAttackCore

# Original FS bounded attack formula candidate, NEVER final 505-alias parity.
# Source All_Scripts_Export.txt: #CustomDmgFormulaRD (~197255),
# FS_BATTLE_BALANCE (~207740-208155), 2026 effective Yanfly constant
# YE::BATTLE::SKILL::ATK_F=2 (~196850), source critical 170% (~207765).
# Reads REAL original attack sequence, not VX ATK*4 - DEF*2 shortcut:
# (1) legacy level/atk/def core, (2) rand(85..100) /100,
# (3) critical two-stage aliases, (4) YEM VARYDMG=5, (5) guard,
# (6) smooth_core/legacy_core scaling using Ruby round.
# Source global Field404 and ComboCore ManaShield77 are applied separately
# AFTER this module by FSBattle in the verified order.
#
# The 505 RGSS2 aliases have extra equipment, element, state, drain and
# Cover effects; production MUST stay DISABLED until source witnesses prove
# the entire caller-specific chain. Synthetic tests explicitly opt in and
# set fs_normal_..._verified flags on attacker and target.
var active: bool = false
var failures: Array[String] = []
var events: Array[Dictionary] = []

const NORMAL_BASE: float = 20.0
const ATK_MULT: float = 2.0
const DEF_CONST: float = 120.0
const DEFAULT_RATE: int = 100
const LEGACY_RATES: Dictionary = {
    55:110,260:110,300:120,340:130,380:140,420:150
}

func _fail(reason: String) -> Dictionary:
    if not failures.has(reason):
        failures.append(reason)
    return {"ok":false,"reason":reason}

static func _note_number(note: String,key: String) -> int:
    var rx := RegEx.new()
    var pattern: String = "(?i)<"+key+"\\s*:\\s*(-?[0-9]+)>"
    if rx.compile(pattern) != OK:
        return 0
    var m: RegExMatch = rx.search(note)
    return int(m.get_string(1)) if m != null else 0

static func _legacy_rate(value: int) -> int:
    if LEGACY_RATES.has(value):
        return clampi(int(LEGACY_RATES[value]),50,200)
    if value > 0 and value <= 100:
        return clampi(value*2,50,200)
    if value >= 240:
        return clampi(roundi(45.0+float(value)/4.0),50,200)
    return clampi(value,50,200)

func quote(battle,attacker: Dictionary,target: Dictionary) -> Dictionary:
    if not active:
        return {"ok":true,"enabled":false}
    if not battle.accuracy.active:
        return _fail("原版平滑傷害啟用時必須有命中／暴擊權威")
    if not bool(attacker.get("fs_normal_source_verified",false)) or not bool(
            target.get("fs_normal_source_verified",false)):
        return _fail("普攻來源尚無完整裝備／元素／別名權威")
    if bool(attacker.get("fs_normal_extra_effects_pending",false)) or bool(
            target.get("fs_normal_extra_effects_pending",false)):
        return _fail("來源有未移植的裝備／被動／Cover 特殊傷害效果")
    for stat in ["atk","level"]:
        if not attacker.has(stat):
            return _fail("攻擊者缺少原始 "+stat)
    if not target.has("def"):
        return _fail("目標缺少原始 DEF")
    # Source FS_ElementRate_FinalAuthority is a separate last-wins module.
    # Neutral 100% has an independently validated subset; no arbitrary
    # nonneutral rates are invented by this approximation.
    if not bool(target.get("fs_normal_element_neutral_verified",false)):
        return _fail("無法驗證原版元素倍率；不允許假設100%")
    if not (attacker.get("element_set",null) is Array):
        return _fail("武器元素集合未驗證")
    var raw_equips: Variant = attacker.get("equipment",[])
    if not (raw_equips is Array):
        return _fail("原始裝備資料型別不合法")
    var equips: Array = raw_equips
    var rates: Array[int] = []
    var pen: int = 0
    var seen_weapon: bool = false
    if bool(attacker.get("actor",false)):
        # All equipment effects beyond explicit source rates are blocked
        # unless the retained test fixture/source witness has certified
        # their absence. Merely finding the weapon record isn't enough.
        if not bool(attacker.get("fs_normal_equipment_verified",false)):
            return _fail("角色武器/被動裝備額外效果權威缺失")
        for index in range(equips.size()):
            var kind: String = battle.db.equip_kind(attacker,index)
            var id: int = int(equips[index])
            if id <= 0:
                continue
            var record: Dictionary = battle.db.record(kind,id)
            if record.is_empty() or not record.has("note"):
                return _fail("原版裝備 #%d 缺少 Note" % id)
            var note: String = str(record["note"])
            pen += _note_number(note,"pen_rate")
            if kind == "weapons":
                seen_weapon = true
                var direct: int = _note_number(note,"normal_atk_rate")
                if direct > 0:
                    rates.append(clampi(direct,50,200))
                else:
                    var legacy: int = _note_number(note,"normal_power")
                    if legacy > 0:
                        rates.append(_legacy_rate(legacy))
    else:
        if not bool(attacker.get("fs_normal_enemy_note_verified",false)):
            return _fail("敵人 Note/等級修正別名尚未驗證")
    # Original albert_notes_for_user = equip + State Notes for actors,
    # enemy Note + State Notes for enemies. Keep those separate.
    if not bool(attacker.get("actor",false)):
        pen += _note_number(str(attacker.get("note","")),"pen_rate")
    for state_id in attacker.get("states",[]):
        var source_state: Dictionary = battle.db.record("states",int(state_id))
        if not source_state.has("note"):
            return _fail("來源狀態 Note 不存在 #%d" % int(state_id))
        pen += _note_number(str(source_state["note"]),"pen_rate")
    pen = clampi(pen,0,80)
    var attack_rate: int = DEFAULT_RATE
    if not rates.is_empty():
        var sum: int = 0
        for n in rates:
            sum += n
        attack_rate = int(sum/rates.size()) # RGSS2 integer division
    var attack: int = battle.boss_state_effects.stat(attacker,"atk")
    var defense: int = battle.boss_state_effects.stat(target,"def")
    var level: int = maxi(1,int(attacker["level"]))
    var safe_def: float = maxf(1.0,float(defense))
    # Original legacy formula: ((((2*Lv/5.0)+2)*50*(ATK/DEF))/50+2).to_i
    var legacy: int = maxi(1,int(((2.0*float(level)/5.0+2.0) *
        50.0*(float(attack)/safe_def))/50.0+2.0))
    var raw: float = NORMAL_BASE+float(attack)*ATK_MULT*float(
        attack_rate)/100.0
    var effective_def: float = maxf(0.0,float(defense)*float(100-pen)/100.0)
    var smooth: float = maxf(1.0,raw*DEF_CONST/(DEF_CONST+effective_def))
    return {"ok":true,"enabled":true,"legacy":legacy,"smooth":smooth,
        "ratio":smooth/float(legacy),"attack_rate":attack_rate,
        "penetration":pen,"attack":attack,"defense":defense}

func resolve(battle,attacker: Dictionary,target: Dictionary,
        critical_chance: int) -> Dictionary:
    var q: Dictionary = quote(battle,attacker,target)
    if not bool(q.get("ok",false)):
        return q
    if not active:
        return _fail("source core not enabled")
    # CustomDmgFormula: rand(85..100), inclusive. Engine-specific random
    # distribution is not a VX RNG witness; raw scripted values are tested.
    var roll: int = battle.accuracy._rand(16,"legacy_attack_power")
    if roll < 0:
        return _fail("來源 85..100 普攻亂數越界")
    var damage: int = int(float(int(q["legacy"]))*float(85+roll)/100.0)
    var critical: bool = false
    if damage > 0:
        # Original Yanfly code takes a provisional crit roll BEFORE the
        # final FS_BattleFormula safe common_critical() overrides it.
        var provisional: int = battle.accuracy._rand(100,
            "legacy_critical_provisional")
        if provisional < 0:
            return _fail("舊暴擊亂數越界")
        if not bool(target.get("prevent_critical",false)):
            var final: int = battle.accuracy._rand(100,
                "critical_final")
            if final < 0:
                return _fail("有效暴擊亂數越界")
            critical = final < critical_chance
        if critical:
            damage = int(float(damage)*1.7)
    var varied: Dictionary = battle.accuracy.variance(damage,5)
    if not bool(varied.get("ok",false)):
        return varied
    damage = int(varied["damage"])
    # Exact Source applies guard before the smooth-defense ratio, not
    # after it. Min1 only if the damage was already strictly positive.
    if damage > 0 and bool(target.get("guarding",false)):
        damage = int(damage/(4 if bool(target.get("super_guard",false)) else 2))
    var final_damage: int = damage
    if damage > 0:
        final_damage = maxi(1,roundi(float(damage)*float(q["ratio"])))
    events.append({"legacy":int(q["legacy"]),
        "smooth":float(q["smooth"]),"ratio":float(q["ratio"]),
        "rolled_factor":85+roll,"critical":critical,
        "before_ratio":damage,"damage":final_damage})
    return {"ok":true,"hp":final_damage,"critical":critical,
        "legacy":int(q["legacy"]),"smooth":float(q["smooth"]),
        "ratio":float(q["ratio"]),"rolled_factor":85+roll,
        "attack_rate":int(q["attack_rate"]),"penetration":int(q["penetration"])}
