extends RefCounted
class_name FSBattleAccuracy

# Bounded source-confirmed HIT/EVA/CRIT/variance adapter, NOT a substitute
# for final 505-RGSS2 alias or original post-Apply runtime witness.
#
# Provenance (read-only All_Scripts_Export):
# ~205017: TargetFix clamps HIT 10..97, EVA 0..60, CRI 0..60;
# ~205240: source base HIT + (user AGI - target AGI)*.15, then clamp;
# ~205278: no EVA for nonphysical skill, ignore_eva for bare attack;
# ~207904: safe evaluate_critical and conditional skill has_critical;
# ~207765: FS_BATTLE_BALANCE.CRITICAL_RATE = 170%;
# ~91382/~204077: integer damage variance (two independent rand(amp+1)).
# ~271214: recovery-skill HIT=100, EVA=0; beyond this state/chance
# effects remain unported and are refused by FSBattle.skill_preflight.
#
# Do NOT enable for unverified original-VX data. Synthetic native tests
# set active=true and inject exact raw integer draw values.

const MIN_HIT: int = 10
const MAX_HIT: int = 97
const MAX_EVA: int = 60
const MAX_CRIT: int = 60
const CRIT_MULT: int = 170

var active: bool = false
# Untyped Array is deliberate: native test fixtures assign ordinary GDScript
# literals [0,99], which cannot be assigned to Array[int] at runtime.
var scripted_rolls: Array = []
var draws: Array[Dictionary] = []
var results: Array[Dictionary] = []
var failures: Array[String] = []

func _fail(reason: String) -> Dictionary:
    if not failures.has(reason):
        failures.append(reason)
    return {"ok":false,"reason":reason}

func _rand(upper: int,kind: String) -> int:
    if upper <= 0:
        return -1
    var roll: int = randi_range(0,upper-1)
    if not scripted_rolls.is_empty():
        roll = scripted_rolls.pop_front()
        if roll < 0 or roll >= upper:
            failures.append("invalid raw RNG %s: %d not in 0..%d" % [
                kind,roll,upper-1])
            return -1
    draws.append({"kind":kind,"upper":upper,"roll":roll})
    return roll

static func _agi(battle,battler: Dictionary) -> int:
    return battle.boss_state_effects.stat(battler,"agi")

static func _restricted(battle,battler: Dictionary) -> Dictionary:
    if bool(battler.get("fs_boss_phase_effects_pending",false)):
        return {"ok":false,"reason":"Boss State 尚未經有效性核對"}
    if bool(battler.get("fs_accuracy_source_unverified",false)):
        return {"ok":false,"reason":"未驗證來源命中／迴避別名"}
    var reduce: bool = false
    var restriction: int = 0
    var ids: Variant = battler.get("states",[])
    if not (ids is Array):
        return {"ok":false,"reason":"狀態欄位不是陣列"}
    for value in ids:
        var id: int = int(value)
        var state: Dictionary = battle.db.record("states",id)
        if state.is_empty() or not state.has("reduce_hit_ratio") or not (
                state.has("restriction")):
            return {"ok":false,"reason":"State%d 命中與行動限制未驗證" % id}
        reduce = reduce or bool(state["reduce_hit_ratio"])
        restriction = maxi(restriction,int(state["restriction"]))
    return {"ok":true,"reduce_hit":reduce,"restriction":restriction}

func quote(battle,user: Dictionary,target: Dictionary,
        skill: Dictionary = {}) -> Dictionary:
    if not active:
        return {"ok":true,"enabled":false,"hit":100,"eva":0,"crit":0}
    # Exact final Source subset requires real actor/enemy rates and AGI,
    # not a default success/zero EVA for incomplete synthetic records.
    for field in ["hit","cri","agi"]:
        if not user.has(field) or not (user[field] is int or user[field] is float):
            return _fail("施術者缺少命中／暴擊／敏捷來源欄位："+field)
    for field in ["eva","agi"]:
        if not target.has(field) or not (
                target[field] is int or target[field] is float):
            return _fail("目標缺少迴避／敏捷來源欄位："+field)
    var src: Dictionary = _restricted(battle,user)
    var dst: Dictionary = _restricted(battle,target)
    if not bool(src.get("ok",false)):
        return _fail(str(src.get("reason","invalid attacker")))
    if not bool(dst.get("ok",false)):
        return _fail(str(dst.get("reason","invalid target")))
    var is_skill: bool = not skill.is_empty()
    if is_skill and (not skill.has("hit") or not skill.has("physical_attack")):
        return _fail("原始技能 HIT／physical_attack 未匯入")
    # The source #271214 recovery override explicitly bypasses both rolls.
    var heal: bool = is_skill and int(skill.get("scope",0)) == 7 and (
        int(skill.get("base_damage",0)) < 0 or
        str(skill.get("note","")).contains("<回復技能>"))
    if heal:
        return {"ok":true,"enabled":true,"hit":100,"eva":0,
            "crit":0,"recovery":true,"physical":false}
    var physical: bool = true if not is_skill else bool(
        skill["physical_attack"])
    var agi_delta: int = _agi(battle,user)-_agi(battle,target)
    var hit: int = int(user["hit"]) if not is_skill else (
        int(skill["hit"]) if int(skill["hit"]) > 0 else int(user["hit"]))
    if physical and bool(src["reduce_hit"]):
        hit = int(hit/4)
    # Custom hit_rate_change_value / skill level_hit aliases remain outside
    # this bounded implementation: opt in only for proven-zero modifiers.
    if bool(user.get("fs_hit_modifier_unverified",false)) or bool(
            target.get("fs_eva_modifier_unverified",false)):
        return _fail("自訂命中／迴避修正來源未驗證")
    hit += int(float(agi_delta)*0.15)
    hit = clampi(hit,MIN_HIT,MAX_HIT)
    var eva: int = int(target["eva"]) if physical else 0
    if not is_skill and bool(user.get("ignore_eva",false)):
        eva = 0
    if bool(target.get("hidden",false)) or int(dst["restriction"]) >= 5:
        eva = 0
    if eva > 0:
        eva += int(float(-agi_delta)*0.08)
    eva = clampi(eva,0,MAX_EVA)
    var crit: int = int(user["cri"])
    if is_skill:
        if bool(skill.get("has_critical",false)):
            crit += int(skill.get("cri",0))
        else:
            crit = 0
    if bool(target.get("prevent_critical",false)):
        crit = 0
    elif not is_skill or bool(skill.get("has_critical",false)):
        crit += maxi(0,int(float(agi_delta)*0.05))
        crit = clampi(crit,0,MAX_CRIT)
    return {"ok":true,"enabled":true,"hit":hit,"eva":eva,
        "crit":crit,"recovery":false,"physical":physical}

func resolve(battle,user: Dictionary,target: Dictionary,
        skill: Dictionary = {}) -> Dictionary:
    var q: Dictionary = quote(battle,user,target,skill)
    if not bool(q.get("ok",false)):
        return q
    if not active:
        return {"ok":true,"kind":"hit","critical":false,"enabled":false}
    # Source order: one HIT d100, then EVA d100 only if HIT succeeds.
    # Both must be consumed even at EVA=0 (source short-circuit does not
    # omit the rand(100) inside attack_effect / skill_effect).
    var hit_roll: int = _rand(100,"hit")
    if hit_roll < 0:
        return _fail("命中亂數來源越界")
    if hit_roll >= int(q["hit"]):
        var missed: Dictionary = {"ok":true,"kind":"miss",
            "hit_roll":hit_roll,"hit":int(q["hit"]),"critical":false}
        results.append(missed)
        return missed
    var eva_roll: int = _rand(100,"eva")
    if eva_roll < 0:
        return _fail("迴避亂數來源越界")
    if eva_roll < int(q["eva"]):
        var evaded: Dictionary = {"ok":true,"kind":"evade",
            "hit_roll":hit_roll,"eva_roll":eva_roll,
            "eva":int(q["eva"]),"critical":false}
        results.append(evaded)
        return evaded
    var crit: bool = false
    # Critical is separate from accuracy and rolled by the damage layer
    # only when this action is eligible, never on miss/evade.
    var landed: Dictionary = {"ok":true,"kind":"hit",
        "hit_roll":hit_roll,"eva_roll":eva_roll,
        "crit_chance":int(q["crit"]),"critical":false}
    results.append(landed)
    return landed

func critical(quote_chance: int) -> Dictionary:
    if not active or quote_chance <= 0:
        return {"ok":true,"critical":false}
    var r: int = _rand(100,"critical")
    if r < 0:
        return _fail("暴擊亂數來源越界")
    return {"ok":true,"critical":r < quote_chance,"roll":r}

func variance(damage: int,percent: int) -> Dictionary:
    if not active or damage == 0 or percent <= 0:
        return {"ok":true,"damage":damage}
    if percent > 100:
        return _fail("未核實的大於100%傷害浮動")
    var amp: int = maxi(0,int(float(abs(damage))*float(percent)/100.0))
    var a: int = _rand(amp+1,"variance_a")
    if a < 0:
        return _fail("傷害浮動亂數A越界")
    var b: int = _rand(amp+1,"variance_b")
    if b < 0:
        return _fail("傷害浮動亂數B越界")
    return {"ok":true,"damage":damage+(a+b-amp)*(1 if damage>0 else -1),
        "amplitude":amp}
