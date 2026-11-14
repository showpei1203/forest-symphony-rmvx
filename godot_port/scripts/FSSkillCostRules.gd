extends RefCounted
class_name FSSkillCostRules

# Focused FS_SkillCost_Authority v2.0.0 (#411) MP subset.
# Source: lines 324..496 (note parsing), 586..594 (half_mp_cost),
# 1291..1315 (MP formula), 1653..1705 (cost gate).
# This is NOT the boot-final effective cost of every FS skill:
# YEZ.apply_level_cost, OD/HP/Gold/Variable/Item/State, and later wrappers
# require separate runtime witnesses. Fail CLOSED whenever seen.
#
# This module cannot modify the source RPG::Skill in place; it computes a
# quote for the current actor, keeping MENU labels and BATTLE payment in sync.

const ALLOWED_MP_TAGS: Array[String] = ["costo mp"]
const DANGEROUS_COST_NAMES: Array[String] = [
    "costo hp", "costo oro", "costo var",
    "costo angry", "costo state", "usa oggetto"
]
const MAX_COST: int = 999999

static func preview(skill: Dictionary, user: Dictionary) -> Dictionary:
    if skill.is_empty():
        return _fail("技能不存在")
    var raw_note: String = str(skill.get("note",""))
    # Recognize exactly FS_SKILL_COST_ALLFIX.parse_number's formats, rather
    # than treating all angle-bracket tags as interchangeable modifiers.
    var rx := RegEx.new()
    var err: Error = rx.compile("(?i)<\\s*(costo\\s+(?:hp|mp|oro|var|angry|state)|usa\\s+oggetto)\\s*:\\s*([0-9]+)\\s*([%％]?)\\s*>")
    if err != OK:
        return _fail("技能成本標記解析器設定錯誤")
    var found: Array = rx.search_all(raw_note)
    var leftover: String = raw_note
    var mp_fixed: int = -1
    var mp_percent: int = 0
    var seen_tags: Dictionary = {}
    for match_result in found:
        var m: RegExMatch = match_result
        var key: String = m.get_string(1).to_lower().strip_edges().replace("  "," ")
        var value_string: String = m.get_string(2)
        var percent: bool = not m.get_string(3).is_empty()
        if not value_string.is_valid_int():
            return _fail("技能成本數字無法轉成整數")
        # Limit values before multiplying maxMP to avoid pathological costs.
        var value: int = int(value_string)
        if value > MAX_COST:
            return _fail("成本標記數值超出安全上限")
        var identity: String = key + ("%" if percent else "")
        if seen_tags.has(identity):
            return _fail("同類技能成本重複標記，需先核對來源")
        seen_tags[identity] = true
        leftover = leftover.replace(m.get_string(0),"")
        if key == "costo mp":
            if percent:
                mp_percent = value
            else:
                mp_fixed = value
        elif key in DANGEROUS_COST_NAMES:
            if value > 0:
                return _fail("技能包含尚未移植的 %s 成本" % key)
            # zero costs are harmless, but anything else in the note still
            # fails closed. Do not silently discard unknown FS gameplay tags.
        else:
            return _fail("未知的技能成本語意")
    if not leftover.strip_edges().is_empty():
        return _fail("包含不明的技能 Note／其他系統標記，不可按原始 mp_cost 支付")
    if bool(skill.get("fs_cost_level_modifier_pending",false)) or bool(
            user.get("fs_cost_level_modifier_pending",false)):
        return _fail("YEZ Job Skill Levels 的成本修正尚未套用")
    if bool(user.get("unknown_skill_cost_modifiers",false)):
        return _fail("角色存在尚未解析的技能成本裝備／狀態修正")
    if not skill.has("mp_cost"):
        return _fail("原技能缺少 MP 成本欄位")
    var raw_mp: int = int(skill["mp_cost"])
    if raw_mp < 0 or raw_mp > MAX_COST:
        return _fail("原 MP 成本超出可驗證範圍")
    var max_mp: int = int(user.get("maxmp",0))
    if max_mp < 0:
        return _fail("角色最大 MP 無效")
    # FS #411: fixed tag overwrites RPG::Skill.mp_cost; percentage is ADDITIVE.
    # Ruby integer truncation on non-negative amounts matches GDScript int().
    var base: int = raw_mp if mp_fixed < 0 else mp_fixed
    base += int((max_mp * mp_percent) / 100.0)
    if bool(user.get("half_mp_cost",false)):
        base = int(base / 2.0)
    base = clampi(base,0,MAX_COST)
    return {"ok":true,"mp":base,"note_fixed_mp":mp_fixed,
        "note_mp_percent":mp_percent,"half_mp_cost":bool(user.get("half_mp_cost",false)),
        "cost_source":"FS #411 MP-only subset; YEZ/OD/runtime aliases NOT proven"}

static func _fail(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}
