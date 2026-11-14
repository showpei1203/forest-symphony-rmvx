extends RefCounted
class_name FSTargetPriority

# Source #372 FS_RandomTarget_Authority v1.2:
# - albert_player_target_candidates/highest_priority_members: player
#   single-target enemy selection uses max enemy/state note priority.
# - Game_Unit#random_target: Provoke first, otherwise legal targets,
#   weighted by target odds; all-disappear fallback; hard excludes apply
#   to ENEMIES only. This is a limited safe implementation.
#
# Unknown target-altering statuses, complex actor Notes, threat scripts and
# missing state rows FAIL CLOSED instead of selecting the wrong battler.
const PROVOKE_STATE: int = 14
const PROVOKE_PRIORITY: int = 1000

static func _priority(note: String) -> int:
    var pattern := RegEx.new()
    if pattern.compile("(?i)<\\s*target[ _-]*priority\\s*:\\s*(-?[0-9]+)\\s*>") == OK:
        var m: RegExMatch = pattern.search(note)
        if m != null:
            return int(m.get_string(1))
    var chinese := RegEx.new()
    if chinese.compile("<\\s*目標優先\\s*[:：]\\s*(-?[0-9]+)\\s*>") == OK:
        var c: RegExMatch = chinese.search(note)
        if c != null:
            return int(c.get_string(1))
    var naked := RegEx.new()
    naked.compile("(?i)<\\s*target[ _-]*priority\\s*>|<\\s*目標優先\\s*>")
    return 1 if naked.search(note) != null else 0

static func ignore_priority(obj: Dictionary) -> bool:
    var note: String = str(obj.get("note",""))
    var pattern := RegEx.new()
    pattern.compile("(?i)<\\s*ignore[ _-]*target[ _-]*priority\\s*>|<\\s*無視目標優先\\s*>")
    return pattern.search(note) != null

static func _enemy_priority(enemy: Dictionary,db: FSDatabase) -> Dictionary:
    var priority: int = _priority(str(enemy.get("note","")))
    if bool(enemy.get("fs_target_unverified",false)):
        return {"ok":false,"reason":"敵方目標狀態尚未驗證"}
    var states: Array = enemy.get("states",[])
    for state_id in states:
        var sid: int = int(state_id)
        if sid == PROVOKE_STATE:
            priority = maxi(priority,PROVOKE_PRIORITY)
            continue
        var state: Dictionary = db.record("states",sid)
        if state.is_empty():
            return {"ok":false,"reason":"敵方 State Note 未匯入"}
        var note: String = str(state.get("note",""))
        # We know the Note priority parser, not the full targetability
        # and Disappear semantics of arbitrary RGSS2 State scripts.
        if not (note.contains("target priority") or note.contains("target_priority")
                or note.contains("target-priority") or note.contains("目標優先")):
            return {"ok":false,"reason":"敵方 State 含未移植目標語意"}
        priority = maxi(priority,_priority(note))
    return {"ok":true,"priority":priority}

static func player_enemy_candidates(battle,skill_id: int = 0) -> Dictionary:
    var obj: Dictionary = battle.db.record("skills",skill_id) if skill_id > 0 else {}
    var bypass: bool = ignore_priority(obj)
    var candidates: Array[int] = []
    var candidate_priority: Array[int] = []
    var highest: int = -2147483648
    for i in range(battle.enemies.size()):
        var enemy: Dictionary = battle.enemies[i]
        if int(enemy.get("hp",0)) <= 0 or bool(enemy.get("friendly",false)):
            continue
        var parsed: Dictionary = _enemy_priority(enemy,battle.db)
        if not bool(parsed.get("ok",false)):
            return parsed
        var priority: int = int(parsed["priority"])
        highest = maxi(highest,priority)
        candidates.append(i)
        candidate_priority.append(priority)
    if candidates.is_empty():
        return {"ok":false,"reason":"沒有合法敵方可選擇"}
    if bypass:
        return {"ok":true,"indices":candidates,"source":"#372 ignore priority"}
    var result: Array[int] = []
    for j in range(candidates.size()):
        if candidate_priority[j] == highest:
            result.append(candidates[j])
    return {"ok":true,"indices":result,"priority":highest,"source":"#372 highest priority"}

static func random_target(battle,side: String,rng: FSAIRandom) -> int:
    var battlers: Array[Dictionary] = battle.party if side == "actor" else (
        battle.enemies)
    if side not in ["actor","enemy"]:
        return -1
    var live: Array[int] = []
    var provoke: Array[int] = []
    var normal: Array[int] = []
    var fallback: Array[int] = []
    for i in range(battlers.size()):
        var target: Dictionary = battlers[i]
        if int(target.get("hp",0)) <= 0:
            continue
        if bool(target.get("fs_target_unverified",false)):
            return -1
        var note: String = str(target.get("note",""))
        # For players, additional Note-based target weight/targetability
        # is still unported. For enemies, #372 knows these specific excludes.
        if side == "actor" and not note.is_empty():
            return -1
        var states: Array = target.get("states",[])
        for state_id in states:
            if int(state_id) != PROVOKE_STATE:
                return -1
        live.append(i)
        var hard_excluded: bool = side == "enemy" and (
            note.to_lower().contains("<no_random_target>") or
            note.contains("対象不可"))
        if hard_excluded:
            continue
        fallback.append(i)
        if states.has(PROVOKE_STATE):
            provoke.append(i)
        elif not bool(target.get("fs_disappear",false)):
            normal.append(i)
    if live.is_empty():
        return -1
    var eligible: Array[int] = provoke if not provoke.is_empty() else (
        normal if not normal.is_empty() else fallback)
    if eligible.is_empty():
        return -1
    var weight_total: int = 0
    var weights: Array[int] = []
    for i in eligible:
        var target: Dictionary = battlers[i]
        # Source #016 Game_Enemy#odds is 1; source #015 Game_Actor#odds
        # is (4 - class.position). More advanced TargetFix weighted
        # overrides remain a distinct runtime witness blocker.
        var chance: int = int(target.get("odds",4 if side=="actor" else 1))
        weights.append(maxi(0,chance))
        weight_total += maxi(0,chance)
    if weight_total <= 0:
        return eligible[rng.roll(eligible.size(),"random_target_fallback")]
    var draw: int = rng.roll(weight_total,"random_target_weight")
    for j in range(eligible.size()):
        if draw < weights[j]:
            return eligible[j]
        draw -= weights[j]
    return eligible.back()
