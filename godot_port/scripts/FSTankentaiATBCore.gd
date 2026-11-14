extends RefCounted
class_name FSTankentaiATBCore

# Source-anchored migration of Tankentai ATB 1.2c core:
# #230 ATB_Configurations: 159-205, 208-213, 307-324, 347-369, 488-580
# #231 ATB Runtime: 68-83, 1863-1885, 1997-2011, 2057-2109, 2163-2167,
# 2227-2263, 606-622.
# Strict boundary: this is the ATB + ACT gauge MATH, not the full
# action queue/event waits/state restrictions/Tankentai effects.

const GAUGE_MAX: int = 1000
const FRAMES_PER_SECOND: int = 60
const ATB_SPEED: int = 10
const START_ACTOR: int = 10
const START_ENEMY: int = 10
const RANDOM_START_SLOTS: int = 5  # rand(5) gives 0..4, ten ticks each.
const SURPRISE_PENALTY: int = 500
const RESET_ATTACK: int = 20
const RESET_GUARD: int = 0
const RESET_SKILL: int = 0
const RESET_ITEM: int = 0

static func _all_battlers(party: Array[Dictionary],enemies: Array[Dictionary]) -> Array[Dictionary]:
    var all: Array[Dictionary] = []
    all.append_array(party)
    all.append_array(enemies)
    return all

static func _agi_extremes(party: Array[Dictionary],enemies: Array[Dictionary]) -> Dictionary:
    # RGSS2 atb_base_speed_refresh sorts ALL battle members including dead,
    # not just those that are movable.
    var fastest: int = 0
    var slowest: int = 0
    var found: bool = false
    for battler in _all_battlers(party,enemies):
        var agility: int = int(battler.get("agi",0))
        if not found:
            fastest = agility
            slowest = agility
            found = true
        else:
            fastest = maxi(fastest,agility)
            slowest = mini(slowest,agility)
    return {"highest":fastest,"lowest":slowest}

static func source_base_frame_gain(agi: int,highest_agi: int,
        speed: int = ATB_SPEED) -> int:
    # N02::ATB_BASE_SPEED = 1 => Integer: @at_speed * agi / max AGI.
    # Source #231 change_atb first guards highest AGI == 0, else >=1.
    if highest_agi <= 0:
        return speed * agi
    return maxi(1,int(speed * agi / highest_agi))

static func _actor_initial_raw(actor: Dictionary,db: FSDatabase,roll: int) -> int:
    var raw: int = (30 if int(actor.get("id",0)) == 1 else START_ACTOR)*10 + roll*10
    var slots: Array = actor.get("equipment",[])
    var first: Dictionary = db.record("weapons",int(slots[0])) if slots.size() > 0 else {}
    var second: Dictionary = db.record("weapons",int(slots[1])) if (
        slots.size() > 1 and bool(actor.get("two_swords_style",false))) else {}
    # Source #231 line 2000..2004 has an odd but important fallback:
    # if BOTH weapons absent, atb1 = atb2 = starting raw count (doubles it).
    var a: int = raw if first.is_empty() else int(first.get("atb_base",0))*10
    var b: int = a if second.is_empty() else int(second.get("atb_base",0))*10
    raw += int((a+b)/2)
    for slot in range(1,mini(5,slots.size())):
        if slot == 1 and bool(actor.get("two_swords_style",false)):
            continue
        var armor: Dictionary = db.record("armors",int(slots[slot]))
        if not armor.is_empty():
            raw += int(armor.get("atb_base",0))*10
    return raw

static func prepare(party: Array[Dictionary],enemies: Array[Dictionary],
        db: FSDatabase,rolls: Dictionary = {},
        advantage: String = "") -> void:
    var extremes: Dictionary = _agi_extremes(party,enemies)
    var all: Array[Dictionary] = _all_battlers(party,enemies)
    for i in range(all.size()):
        var battler: Dictionary = all[i]
        var is_actor: bool = i < party.size()
        var key: String = ("actor:" if is_actor else "enemy:") + str(
            i if is_actor else i-party.size())
        # Deterministic synthetic tests inject rolls; production uses original
        # rand(5) distribution. Never fake the original RNG sequence.
        var roll: int = clampi(int(rolls[key]) if rolls.has(key) else randi_range(0,4),0,4)
        var raw: int = _actor_initial_raw(battler,db,roll) if is_actor else (
            (START_ENEMY*10)+roll*10)
        var gain: int = source_base_frame_gain(int(battler.get("agi",0)),
            int(extremes["highest"]))
        battler["source_atb_gain_per_frame"] = gain
        battler["source_atb_speed"] = ATB_SPEED
        battler["source_atb_count"] = raw
        battler["source_act_count"] = 0
        battler["source_act_gain_per_frame"] = 0
        battler["source_atb_count_up"] = true
        battler["source_at_active"] = false
        battler["source_act_active"] = false
        battler["source_atb_mode"] = "tankentai_1_2c_baseline"
        # Preemptive/surprise are applied *after* battle initialization
        # (source #231 Scene_Battle#preemptive/#surprise).
        if advantage == "preemptive":
            raw = GAUGE_MAX if is_actor else -SURPRISE_PENALTY
        elif advantage == "surprise":
            raw = -SURPRISE_PENALTY if is_actor else GAUGE_MAX
        battler["source_atb_count"] = raw
        battler["atb"] = float(raw)/GAUGE_MAX

static func advance_frames(party: Array[Dictionary],enemies: Array[Dictionary],
        frame_count: int,wait_for_input: bool = false) -> void:
    if frame_count <= 0 or wait_for_input:
        return
    for frame in range(frame_count):
        for battler in _all_battlers(party,enemies):
            if int(battler.get("hp",0)) <= 0 or not bool(battler.get("source_movable",true)):
                continue
            if bool(battler.get("source_act_active",false)):
                continue
            if bool(battler.get("source_atb_count_up",true)):
                var count: int = int(battler.get("source_atb_count",0))
                # Source #231 increments even on exactly 1000, then marks
                # at_active and freezes when >=1000.
                if count <= GAUGE_MAX:
                    count += int(battler.get("source_atb_gain_per_frame",1))
                battler["source_atb_count"] = count
                battler["atb"] = float(count)/GAUGE_MAX
                if count >= GAUGE_MAX:
                    battler["source_atb_count_up"] = false
                    battler["source_at_active"] = true
            elif not bool(battler.get("source_at_active",false)):
                var charge: int = int(battler.get("source_act_count",0))
                if charge <= GAUGE_MAX:
                    charge += int(battler.get("source_act_gain_per_frame",0))
                battler["source_act_count"] = charge
                if charge >= GAUGE_MAX:
                    battler["source_act_active"] = true

static func begin_charge(battler: Dictionary,kind: String = "attack",
        source_id: int = 0) -> bool:
    # Source normally receives command selection only at at_active.
    if not bool(battler.get("source_at_active",false)):
        return false
    # Source defaults from #230 Skill#charge, Item#charge, actor/weapon#charge.
    # No charge customization outside this narrow whitelist. Skill 1 special.
    var charge_percent: int = 0
    if kind == "skill":
        charge_percent = 1 if source_id == 1 else 10
    elif kind == "item":
        # Original #230 Item#charge: item 1 has [4,20,0,""],
        # otherwise [4,0,0,""].
        charge_percent = 20 if source_id == 1 else 0
    elif kind not in ["attack","guard"]:
        return false
    var base: int = int(battler.get("source_atb_speed",ATB_SPEED)) # act_type[0] == 4
    var charge_gain: int = GAUGE_MAX if charge_percent <= 0 else int(
        base * 100 / charge_percent)
    battler["source_atb_count"] = 0
    battler["atb"] = 0.0
    battler["source_atb_count_up"] = false
    battler["source_at_active"] = false
    battler["source_act_count"] = 0
    battler["source_act_active"] = false
    battler["source_act_gain_per_frame"] = maxi(1,charge_gain)
    battler["source_charge_kind"] = kind
    return true

static func reset_after_action(battler: Dictionary,kind: String = "attack",
        source_id: int = 0, db: FSDatabase = null) -> void:
    # Source #231 recharge_action: raw 0..100 percent -> *10 ATB count.
    var reset_percent: int = RESET_ATTACK
    if kind == "guard":
        reset_percent = RESET_GUARD
    elif kind == "skill":
        reset_percent = 30 if source_id == 1 else RESET_SKILL
    elif kind == "item":
        reset_percent = RESET_ITEM
    elif kind == "attack":
        if db != null:
            var equipment: Array = battler.get("equipment",[])
            if equipment.size() > 0 and int(equipment[0]) > 0:
                var main: Dictionary = db.record("weapons",int(equipment[0]))
                if not main.is_empty():
                    reset_percent = int(main.get("recharge",20 if int(equipment[0])==1 else RESET_ATTACK))
            if bool(battler.get("two_swords_style",false)) and equipment.size() > 1 and int(equipment[1]) > 0:
                var offhand: Dictionary = db.record("weapons",int(equipment[1]))
                if not offhand.is_empty():
                    reset_percent = int((reset_percent+int(offhand.get("recharge",RESET_ATTACK)))/2)
    battler["source_atb_count"] = reset_percent*10
    battler["atb"] = float(battler["source_atb_count"])/GAUGE_MAX
    battler["source_act_count"] = 0
    battler["source_act_active"] = false
    battler["source_at_active"] = false
    battler["source_atb_count_up"] = true

static func ready_actors(party: Array[Dictionary]) -> Array[int]:
    var result: Array[int] = []
    for i in range(party.size()):
        if int(party[i].get("hp",0)) > 0 and bool(party[i].get("source_at_active",false)):
            result.append(i)
    return result

static func ready_enemies(enemies: Array[Dictionary]) -> Array[int]:
    var result: Array[int] = []
    for i in range(enemies.size()):
        if int(enemies[i].get("hp",0)) > 0 and bool(enemies[i].get("source_at_active",false)):
            result.append(i)
    return result
