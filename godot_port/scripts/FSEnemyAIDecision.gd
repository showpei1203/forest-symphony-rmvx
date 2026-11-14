extends RefCounted
class_name FSEnemyAIDecision

# Source-anchored, FAIL-CLOSED enemy AI candidate:
# #016 Game_Enemy conditions; #211 EnemyActionPattern (roulette=true)
# #406 EnemyActionDistribution (enemy 600..745); #210 RNG.
# #401 Boss runtime dynamic context, State action replacement, Skill83
# appended conditions, advanced target threat/priority, multi-action &
# troop turn status remain UNVERIFIED. Do not silently skip such actions.
#
# Candidate actions come from boot-final data ONLY; never fabricate
# arbitrary enemy attacks when no legal original action is available.

const DUMMY_ADDITIONAL_CONDITION_SKILL: int = 83
const DISTRIBUTION_MIN_ID: int = 600
const DISTRIBUTION_MAX_ID: int = 745

static func _fail(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}

static func _note_int(note: String,tag: String) -> Dictionary:
    var re := RegEx.new()
    if re.compile("(?i)<\\s*%s\\s*:\\s*([+-]?[0-9]+)\\s*>" % tag) != OK:
        return {}
    var m: RegExMatch = re.search(note)
    return {"found":true,"value":int(m.get_string(1))} if m != null else {}

static func attack_rate(enemy: Dictionary,party_count: int,
        enemy_count: int) -> int:
    # Exact #406 source structure, ONLY for eligible 600..745.
    var note: String = str(enemy.get("note",""))
    var fixed: Dictionary = _note_int(note,"enemy_attack_rate")
    if not fixed.is_empty():
        return clampi(int(fixed["value"]),15,90)
    var baseline: int = 35
    match party_count:
        1: baseline = 70
        2: baseline = 55
        3: baseline = 45
    var threshold: Dictionary = _note_int(note,"break_threshold")
    var break_value: int = int(threshold.get("value",6))
    var break_add: int = 10 if break_value <= 3 else (
        5 if break_value <= 5 else (
        0 if break_value <= 7 else (-5 if break_value <= 9 else -10)))
    var extra: int = maxi(0,enemy_count-party_count)
    var outnumber_add: int = mini(15,extra*5)
    var last_bonus: int = 20 if bool(
        enemy.get("fs_ead_last_damage_skill",false)) else 0
    var tagged: Dictionary = _note_int(note,"enemy_attack_rate_add")
    return clampi(baseline+break_add+outnumber_add+last_bonus+
        int(tagged.get("value",0)),15,90)

static func _eligible_distribution(enemy: Dictionary) -> bool:
    var eid: int = int(enemy.get("id",0))
    var note: String = str(enemy.get("note","")).to_lower()
    return eid >= DISTRIBUTION_MIN_ID and eid <= DISTRIBUTION_MAX_ID and (
        not note.contains("<enemy_action_dist_off>")) and (
        not bool(enemy.get("friendly",false)))

static func _condition(enemy: Dictionary,action: Dictionary,battle) -> int:
    # Returns 1 passed, 0 known false, -1 requires untranslated runtime.
    var typ: int = int(action.get("condition_type",0))
    var a: int = int(action.get("condition_param1",0))
    var b: int = int(action.get("condition_param2",0))
    match typ:
        0: return 1
        1: return -1 # Source turns use Game_Troop.increase_turn, not frame count.
        2:
            var maxhp: int = int(enemy.get("maxhp",0))
            if maxhp <= 0: return -1
            var percent: float = float(enemy.get("hp",0))*100.0/float(maxhp)
            return 1 if percent >= a and percent <= b else 0
        3:
            var maxmp: int = int(enemy.get("maxmp",0))
            if maxmp <= 0: return -1
            var percent: float = float(enemy.get("mp",0))*100.0/float(maxmp)
            return 1 if percent >= a and percent <= b else 0
        4:
            var states: Array = enemy.get("states",[])
            return 1 if states.has(a) else 0
        5:
            var max_level: int = 0
            for actor in battle.party:
                max_level = maxi(max_level,int(actor.get("level",1)))
            return 1 if max_level >= a else 0
        6:
            # #211 Switch121..130 are DYNAMIC target/mobility conditions.
            if a >= 121 and a < 131:
                return -1
            if battle.world == null: return -1
            return 1 if battle.world.switch_on(a) else 0
    return -1

static func choose(battle,index: int,rng: FSAIRandom) -> Dictionary:
    if index < 0 or index >= battle.enemies.size():
        return _fail("enemy index invalid")
    var enemy: Dictionary = battle.enemies[index]
    if int(enemy.get("hp",0)) <= 0:
        return _fail("enemy defeated")
    if bool(enemy.get("fs_boss_phase_effects_pending",false)):
        # IDs are only SOURCE INTENTS; original State effects and alias
        # behavior are still missing, so don't execute invented Boss AI.
        return _fail("Boss phase State effects not yet applied/verified")
    if bool(enemy.get("fs_enemy_ai_context_pending",false)) or bool(
            enemy.get("fs_enemy_ai_state_pattern_pending",false)):
        return _fail("Boss/context/state AI runtime authority missing")
    var raw_actions: Variant = enemy.get("actions",[])
    # #401/#440 authority: when a recognized boss is present, this core
    # uses its Boss-specific context actions INSTEAD OF raw Enemy.actions.
    # Original provider checks ALL troop.members and sorts boss IDs.
    var context: Dictionary = FSBossContext.resolve(int(enemy.get("id",0)),battle.enemies)
    if bool(context.get("matched",false)):
        raw_actions = context["actions"]
    if not raw_actions is Array or raw_actions.is_empty():
        return _fail("no source Enemy.actions or matching Boss context")
    var actions: Array[Dictionary] = []
    var highest_so_far: int = 0
    var weight_total: int = 0
    for v in raw_actions:
        if not v is Dictionary:
            return _fail("unsupported Enemy.actions record")
        var action: Dictionary = v
        var kind: int = int(action.get("kind",0))
        var basic: int = int(action.get("basic",0))
        var sid: int = int(action.get("skill_id",0))
        if kind == 1 and sid == DUMMY_ADDITIONAL_CONDITION_SKILL:
            return _fail("EnemyActionPattern Skill83 multi-condition chain unported")
        var nested: Variant = action.get("conditions_arrays",[])
        if nested is Array and nested.size() > 1:
            return _fail("EnemyActionPattern extended condition array unported")
        var condition: int = _condition(enemy,action,battle)
        if condition < 0:
            return _fail("enemy condition requires effective troop/AI runtime")
        if condition == 0:
            continue
        if kind == 1:
            var skill: Dictionary = battle.db.record("skills",sid)
            if skill.is_empty():
                return _fail("candidate skill missing")
            var scope: int = int(skill.get("scope",0))
            if scope not in [1,7]:
                return _fail("candidate has unported skill target scope")
            if not skill.get("plus_state_set",[]).is_empty() or not (
                    skill.get("minus_state_set",[]).is_empty()):
                return _fail("candidate has unported status effect")
            var cost: Dictionary = FSSkillCostRules.preview(skill,enemy)
            if not bool(cost.get("ok",false)):
                return _fail("candidate skill cost not source-verified")
            if int(enemy.get("mp",0)) < int(cost.get("mp",0)):
                continue  # RGSS2 skips candidate when skill_can_use? false.
            if int(skill.get("base_damage",0)) < 0 and (
                    int(skill.get("atk_f",0)) != 0 or int(skill.get("spi_f",0)) != 0):
                return _fail("candidate recovery formula unsupported")
            if bool(skill.get("damage_to_mp",false)) or bool(
                    skill.get("absorb_damage",false)):
                return _fail("candidate special attack unsupported")
        elif kind == 0:
            if basic not in [0,1]:
                return _fail("enemy basic escape/wait/force unsupported")
        else:
            return _fail("enemy action kind unported")
        var weight: int = int(action.get("rating",0))
        # #211 CONDITION_ROULETTE=true: skip if current rating lower
        # than previously observed high; otherwise append rating times.
        if weight < highest_so_far:
            continue
        highest_so_far = weight
        if weight <= 0:
            continue
        actions.append({"kind":kind,"basic":basic,"skill_id":sid,
            "weight":weight})
        weight_total += weight
    if actions.is_empty() or weight_total <= 0:
        return _fail("no eligible source AI actions")
    var draw: int = rng.roll(weight_total,"enemy_action_roulette")
    var chosen: Dictionary = {}
    for action in actions:
        var weight: int = int(action["weight"])
        if draw < weight:
            chosen = action
            break
        draw -= weight
    if chosen.is_empty():
        return _fail("roulette inconsistency")

    var kind_text: String = "skill" if int(chosen["kind"]) == 1 else (
        "guard" if int(chosen["basic"]) == 1 else "attack")
    var sid: int = int(chosen["skill_id"]) if kind_text == "skill" else 0
    if kind_text == "skill" and _eligible_distribution(enemy):
        var skill: Dictionary = battle.db.record("skills",sid)
        # #406 protects heals, dead-friend, and state-removing skills.
        var urgent: bool = int(skill.get("base_damage",0)) < 0 or not (
            skill.get("minus_state_set",[]).is_empty()) or (
            int(skill.get("scope",0)) in [9,10])
        if not urgent:
            var count_party: int = battle.party.filter(
                func(x: Dictionary) -> bool: return int(x.get("hp",0)) > 0).size()
            var count_enemy: int = battle.enemies.filter(
                func(x: Dictionary) -> bool: return int(x.get("hp",0)) > 0).size()
            var attack_draw: int = rng.roll(100,"enemy_attack_distribution")
            if attack_draw < attack_rate(enemy,count_party,count_enemy):
                kind_text = "attack"
                sid = 0
    # #406 always records the FINAL selected damaging skill,
    # irrespective of whether Skill later hits or misses.
    var final_damage_skill: bool = kind_text == "skill" and int(
        battle.db.record("skills",sid).get("base_damage",0)) > 0

    var side: String = "enemy" if kind_text == "skill" and int(
        battle.db.record("skills",sid).get("scope",0)) == 7 else "actor"
    if kind_text == "guard":
        enemy["fs_ead_last_damage_skill"] = false
        return {"ok":true,"kind":kind_text,"object_id":0,
            "target_side":"none","target_index":-1}
    var target_index: int = FSTargetPriority.random_target(battle,side,rng)
    if target_index < 0:
        return _fail("source random target priorities/states unresolved or none")
    if kind_text == "attack":
        var selected: Dictionary = battle.party[target_index] if side == "actor" else battle.enemies[target_index]
        if not battle.attack_preflight(enemy,selected):
            return _fail("source #404 attack elements unavailable for global weather")
    enemy["fs_ead_last_damage_skill"] = final_damage_skill
    return {"ok":true,"kind":kind_text,"object_id":sid,
        "target_side":side,"target_index":target_index}
