extends RefCounted
class_name FSForceActionQueue

# Candidate #462 event FIFO + #231 single troop forcing slot.
# Opt-in only. Full forced skill/item validity, random/last target,
# animation-active and command-window cleanup remain outside scope.
var enabled: bool = false
var busy: bool = false
var staged: Array[Dictionary] = []
var ready: Array[Dictionary] = []
var troop_slot: Dictionary = {}
var completed: Array[Dictionary] = []

static func _index(members: Array[Dictionary], subject: Dictionary) -> int:
    for i in range(members.size()):
        if is_same(members[i],subject):
            return i
    return -1

static func _exists(subject: Dictionary) -> bool:
    return not subject.is_empty() and int(subject.get("hp",0)) > 0 and not bool(subject.get("hidden",false))

func _subject_index(battle, entry: Dictionary) -> int:
    var members: Array[Dictionary] = battle.party if entry["actor"] else battle.enemies
    return _index(members,entry["subject"])

func _target_index(battle, entry: Dictionary) -> int:
    var members: Array[Dictionary] = battle.enemies if entry["actor"] else battle.party
    return _index(members,entry["target"])

func _valid(battle,entry: Dictionary) -> bool:
    if not _exists(entry["subject"]) or _subject_index(battle,entry)<0:
        return false
    if not FSOriginalActionSeal.can_use(entry["subject"],battle.db,entry["kind"]):
        return false # Do not bypass the existing source authority gate.
    if entry["kind"]=="guard":
        return true
    return _exists(entry["target"]) and _target_index(battle,entry)>=0 and (
        not bool(entry["target"].get("fs_boss_phase_effects_pending",false)))

func _make(battle,side: int,index: int,kind: String,target_index: int) -> Dictionary:
    if not enabled or not battle.active or not battle.source_atb_initialized or side not in [0,1]:
        return {}
    if kind not in ["attack","guard"] or index<0 or target_index<0:
        return {}
    var members: Array[Dictionary] = battle.party if side==1 else battle.enemies
    var targets: Array[Dictionary] = battle.enemies if side==1 else battle.party
    if index>=members.size() or (kind=="attack" and target_index>=targets.size()):
        return {}
    var entry: Dictionary = {"actor":side==1,"subject":members[index],"kind":kind,
        "target":targets[target_index] if kind=="attack" else {}}
    return entry if _valid(battle,entry) else {}

func _find(entries: Array[Dictionary],subject: Dictionary) -> int:
    for i in range(entries.size()):
        if is_same(entries[i]["subject"],subject):
            return i
    return -1

func request_event(battle,side: int,index: int,kind: String,target_index: int) -> bool:
    var entry: Dictionary = _make(battle,side,index,kind,target_index)
    if entry.is_empty():
        return false
    # #462 setup_action overwrites the battler's one action object.
    # Keep the earliest event position, but the latest validated payload.
    var pos: int = _find(ready,entry["subject"])
    if pos>=0:
        ready[pos] = entry
        return true
    pos = _find(staged,entry["subject"])
    if pos>=0:
        staged[pos] = entry
    else:
        staged.append(entry)
    return true

func request_vx339(battle,params: Array) -> bool:
    # #28 command_339: [side, member index, kind, action id, target].
    # The original iterator supports all-members; deliberately HOLD it,
    # and random/last targeting, escape/wait, skill and item.
    if params.size()!=5:
        return false
    for value in params:
        if typeof(value) not in [TYPE_INT,TYPE_FLOAT] or (
                not is_finite(float(value))) or absf(float(value))>1000000.0 or (
                float(value)!=float(int(value))):
            return false
    if int(params[2])!=0 or int(params[3]) not in [0,1]:
        return false
    var entry: Dictionary = _make(battle,int(params[0]),int(params[1]),
        "attack" if int(params[3])==0 else "guard",int(params[4]))
    if entry.is_empty() or not troop_slot.is_empty():
        return false
    troop_slot = entry
    return true

func drain_event(battle) -> int:
    if not enabled or not battle.active:
        return 0
    var count: int = 0
    while not staged.is_empty():
        var entry: Dictionary = staged.pop_front()
        if _subject_index(battle,entry)<0 or not _exists(entry["subject"]):
            continue
        if _find(ready,entry["subject"])<0:
            ready.append(entry)
            count += 1
    return count

func prepare_troop(battle) -> bool:
    if not enabled or not battle.active or troop_slot.is_empty():
        return false
    var entry: Dictionary = troop_slot
    troop_slot = {}
    if not _valid(battle,entry):
        return false
    var pos: int = _find(ready,entry["subject"])
    if pos>=0:
        ready.remove_at(pos)
    ready.append(entry) # #231 removes prior occurrence and appends.
    return true

func resolve_one(battle,active_action_busy: bool = false) -> int:
    if not enabled or busy or active_action_busy or not battle.active or (
            battle.source_atb_wait):
        return 0
    # Godot actions are synchronous here, not a full VX animation lifecycle.
    # Mark busy before engine calls/signals to prevent reentrant resolution.
    while not ready.is_empty():
        var entry: Dictionary = ready.pop_front()
        if not _valid(battle,entry):
            completed.append({"kind":entry["kind"],"success":false,"reason":"target or subject no longer valid"})
            continue
        var subject: Dictionary = entry["subject"]
        var target: Dictionary = entry["target"]
        var kind: String = entry["kind"]
        var index: int = _subject_index(battle,entry)
        # Force priority does not silently cancel an open player command UI.
        if entry["actor"] and battle.pending_actor==index:
            ready.push_front(entry)
            return 0
        busy = true
        if kind=="attack" and not battle.attack_preflight(subject,target):
            completed.append({"kind":kind,"success":false,"reason":"source attack preflight"})
            busy = false
            continue
        # Only remove the superseded ordinary command, never other members.
        if entry["actor"]:
            battle.action_queue.pending.erase("actor:%d" % index)
        else:
            battle.action_queue.enemy_pending.erase("enemy:%d" % index)
            battle.action_queue.enemy_refusals.erase("enemy:%d" % index)
        var success: bool = false
        if kind=="guard":
            subject["guarding"] = true
            success = true
        else:
            subject["guarding"] = false
            battle.attack(subject,target)
            success = not battle.accuracy.active or str(
                target.get("fs_last_action_result","blocked")) in ["hit","miss","evade"]
        if success:
            subject["source_act_active"] = true
            battle.finish_source_atb_action(subject,kind,0)
        completed.append({"kind":kind,"actor":entry["actor"],"index":index,"success":success})
        busy = false
        return 1
    return 0
