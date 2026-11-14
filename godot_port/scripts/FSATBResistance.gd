extends RefCounted
class_name FSATBResistance

# Port of the isolated FS_ATB_DynamicResistance v1.0.0 source #377.
# Only intercepts a DIRECT negative ComboCore <atb_shift:-x> on a live
# enemy with <atb_dynamic_resist> and no State argument.
# All other Tankentai ATB mechanics and the main ATB gain formula remain
# UNPORTED; don't claim full combat ATB parity from this partial rule.
#
# Source reference: #377 lines 155..205, 259..335, 349..615, 653..772.

const MAX_ATB: int = 1000
const RATES: Array[int] = [100,70,45,25,10]
const DEFAULT_START: int = 0
const DEFAULT_MAX: int = 4
const DEFAULT_FLOOR: int = 10
const DEFAULT_RECOVER: int = 1
const MIN_ACTUAL_REDUCTION_FOR_GAIN: int = 10

static func setup(enemy: Dictionary) -> void:
    var note: String = str(enemy.get("note",""))
    var rx := RegEx.new()
    rx.compile("(?i)<\\s*atb_dynamic_resist\\s*>")
    var enabled: bool = rx.search(note) != null
    enemy["atb_resist_enabled"] = enabled
    if not enabled:
        return
    var max_level: int = clampi(_note_number(note,"atb_resist_max",DEFAULT_MAX),0,4)
    var initial: int = clampi(_note_number(note,"atb_resist_start",DEFAULT_START),0,max_level)
    enemy["atb_resist_max"] = max_level
    enemy["atb_resist_level"] = initial
    enemy["atb_resist_floor"] = clampi(_note_number(note,"atb_resist_floor",DEFAULT_FLOOR),0,100)
    enemy["atb_resist_recover"] = clampi(_note_number(note,"atb_resist_recover",DEFAULT_RECOVER),0,max_level)

static func _note_number(note: String,tag: String,fallback: int) -> int:
    var pattern := RegEx.new()
    var ok: Error = pattern.compile("(?i)<\\s*%s\\s*:\\s*(-?[0-9]+)\\s*>" % tag)
    if ok != OK:
        return fallback
    var m: RegExMatch = pattern.search(note)
    return int(m.get_string(1)) if m != null else fallback

static func rate(enemy: Dictionary) -> int:
    if not bool(enemy.get("atb_resist_enabled",false)):
        return 100
    return RATES[clampi(int(enemy.get("atb_resist_level",0)),0,4)]

static func apply_direct_shift(enemy: Dictionary,delta: int,
        state_id: int = 0, attacker: Dictionary = {}) -> Dictionary:
    # Call ONLY when a source action explicitly uses ComboCore ATB shifting.
    # state_id != 0 means native State ATB handling, bypass this interception.
    if not enemy.has("atb"):
        return {"ok":false,"reason":"Battler 尚無 ATB 狀態"}
    var before: int = clampi(roundi(float(enemy["atb"]) * MAX_ATB),0,MAX_ATB)
    var effective_delta: int = delta
    var affected: bool = bool(enemy.get("atb_resist_enabled",false)) and (
        not bool(enemy.get("actor",false))) and delta < 0 and state_id == 0
    if affected:
        var current_rate: float = float(rate(enemy))
        var pierce: float = clampf(float(attacker.get("aizhuo_overload_pierce_percent",0.0)),0.0,100.0)
        current_rate = minf(100.0,current_rate+(100.0-current_rate)*pierce/100.0)
        var resisted_amount: int = int(abs(delta)*current_rate/100.0)
        var floor_value: int = int(MAX_ATB*int(enemy.get("atb_resist_floor",DEFAULT_FLOOR))/100.0)
        var max_reducible: int = maxi(0,before-floor_value)
        effective_delta = -mini(resisted_amount,max_reducible)
    var after: int = clampi(before+effective_delta,0,MAX_ATB)
    enemy["atb"] = float(after)/MAX_ATB
    var actual_reduction: int = maxi(0,before-after)
    var level_before: int = int(enemy.get("atb_resist_level",0))
    if affected and actual_reduction >= MIN_ACTUAL_REDUCTION_FOR_GAIN:
        # Theoretical amount is BEFORE resistance & floor, not actual damage.
        var theoretical_percent: float = float(abs(delta))/10.0
        var gain: int = 0 if theoretical_percent <= 15.0 else (1 if theoretical_percent <= 30.0 else 2)
        enemy["atb_resist_level"] = clampi(level_before+gain,0,int(enemy.get("atb_resist_max",4)))
    return {
        "ok":true,"before":before,"after":after,
        "effective_delta":effective_delta,"actual_reduction":actual_reduction,
        "resistance_applied":affected,
        "level_before":level_before,
        "level_after":int(enemy.get("atb_resist_level",level_before)),
        "source":"FS #377 direct ComboCore ATB shift only"
    }

static func after_valid_enemy_action(enemy: Dictionary) -> int:
    if not bool(enemy.get("atb_resist_enabled",false)) or bool(enemy.get("actor",false)):
        return 0
    var before: int = int(enemy.get("atb_resist_level",0))
    var recovery: int = int(enemy.get("atb_resist_recover",DEFAULT_RECOVER))
    var after: int = clampi(before-recovery,0,int(enemy.get("atb_resist_max",4)))
    enemy["atb_resist_level"] = after
    return before-after
