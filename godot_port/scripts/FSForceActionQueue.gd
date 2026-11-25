extends RefCounted
class_name FSForceActionQueue

# Candidate #462 event FIFO + #231 single troop forcing slot.
# Opt-in only. Resource-checked skill/item subset; optional bounded random target, full forced validity and last target,
# animation-active and command-window cleanup remain outside scope.
var enabled: bool = false
# Explicit second opt-in until true source event inventory is available.
var random_targets_enabled: bool = false
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
    var members: Array[Dictionary] = battle.party if entry["target_actor"] else battle.enemies
    return _index(members,entry["target"])

func _valid(battle,entry: Dictionary) -> bool:
    if not _exists(entry["subject"]) or _subject_index(battle,entry)<0:
        return false
    if not FSOriginalActionSeal.can_use(entry["subject"],battle.db,entry["kind"]):
        return false # Do not bypass the existing source authority gate.
    if entry["kind"]=="guard":
        return true
    if not _exists(entry["target"]) or _target_index(battle,entry)<0 or bool(entry["target"].get("fs_boss_phase_effects_pending",false)):
        return false
    var obj: int = int(entry["object_id"])
    if entry["kind"]=="skill":
        var skill: Dictionary = battle.db.record("skills",obj)
        var scope: int = int(skill.get("scope",0))
        if skill.is_empty() or scope not in [1,7] or (
                bool(entry["target_actor"]) != (bool(entry["actor"]) if scope==7 else not bool(entry["actor"]))):
            return false
        if entry["actor"] and obj not in entry["subject"].get("skills",[]):
            return false
        var quote: Dictionary = FSSkillCostRules.preview(skill,entry["subject"])
        return bool(quote.get("ok",false)) and int(entry["subject"].get("mp",0))>=int(quote.get("mp",0))
    if entry["kind"]=="item":
        return bool(entry["actor"]) and bool(entry["target_actor"]) and (
            int(battle.inventory.get("item:%d"%obj,0))>0) and bool(
            FSItemRules.preview(battle.db.record("items",obj),entry["subject"],entry["target"],true).get("ok",false))
    return true

func _make(battle,side: int,index: int,kind: String,target_index: int,object_id: int = 0) -> Dictionary:
    if not enabled or not battle.active or not battle.source_atb_initialized or side not in [0,1]:
        return {}
    if kind not in ["attack","guard","skill","item"] or index<0 or (kind in ["skill","item"] and object_id<=0):
        return {}
    if target_index<0 and (target_index!=-1 or not random_targets_enabled or kind not in ["attack","skill"]):
        return {}
    var members: Array[Dictionary] = battle.party if side==1 else battle.enemies
    var target_actor: bool = side==0
    if kind=="skill":
        var skill: Dictionary = battle.db.record("skills",object_id)
        if int(skill.get("scope",0)) not in [1,7]:
            return {}
        target_actor = side==1 if int(skill["scope"])==7 else side==0
    elif kind=="item":
        if side!=1:
            return {}
        target_actor = true
    var targets: Array[Dictionary] = battle.party if target_actor else battle.enemies
    if index>=members.size() or (kind!="guard" and target_index>=targets.size()):
        return {}
    var selected: int=target_index
    if target_index==-1:
        if not _exists(members[index]) or not FSOriginalActionSeal.can_use(members[index],battle.db,kind):
            return {}
        if kind=="skill":
            var obj: Dictionary=battle.db.record("skills",object_id)
            var cost: Dictionary=FSSkillCostRules.preview(obj,members[index])
            if not bool(cost.get("ok",false)) or int(members[index].get("mp",0))<int(cost.get("mp",0)) or (
                    side==1 and object_id not in members[index].get("skills",[])):
                return {}
        # #372 selects relative to the action scope. Friendly monsters and
        # unported target-authority overrides are deliberately not guessed.
        for candidate in targets:
            if _exists(candidate) and bool(candidate.get("friendly",false)):
                return {}
        selected=FSTargetPriority.random_target(battle,"actor" if target_actor else "enemy",battle.action_queue.ai_rng)
        if selected<0 or selected>=targets.size():
            return {}
    var entry: Dictionary = {"actor":side==1,"subject":members[index],"kind":kind,
        "target_actor":target_actor,"object_id":object_id,
        "target":targets[selected] if kind!="guard" else {},"target_mode":"random" if target_index==-1 else "fixed"}
    return entry if _valid(battle,entry) else {}

func _find(entries: Array[Dictionary],subject: Dictionary) -> int:
    for i in range(entries.size()):
        if is_same(entries[i]["subject"],subject):
            return i
    return -1

func request_event(battle,side: int,index: int,kind: String,target_index: int,object_id: int = 0) -> bool:
    var entry: Dictionary = _make(battle,side,index,kind,target_index,object_id)
    if entry.is_empty():
        return false
    # #462 setup_action overwrites the battler's one action object.
    # Keep the earliest event position, but the latest validated payload.
    var pos: int = _find(ready,entry["subject"])
    if pos>=0:
        if ready[pos].has("page_ticket"):
            return false # Pending interpreter command owns this action until settlement.
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
    # last targeting, escape/wait. Random single-target is a second opt-in.
    # #28 supports skills, not items.
    if params.size()!=5:
        return false
    for value in params:
        if typeof(value) not in [TYPE_INT,TYPE_FLOAT] or (
                not is_finite(float(value))) or absf(float(value))>1000000.0 or (
                float(value)!=float(int(value))):
            return false
    var action_type: int = int(params[2])
    var action_id: int = int(params[3])
    if action_type not in [0,1] or (action_type==0 and action_id not in [0,1]) or (action_type==1 and action_id<=0):
        return false
    var kind: String = "skill" if action_type==1 else ("attack" if action_id==0 else "guard")
    var entry: Dictionary = _make(battle,int(params[0]),int(params[1]),kind,int(params[4]),
        action_id if action_type==1 else 0)
    if entry.is_empty() or not troop_slot.is_empty():
        return false
    var pos: int = _find(ready,entry["subject"])
    if pos>=0 and ready[pos].has("page_ticket"):
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
        _record(entry,false,-1,"troop slot no longer valid")
        return false
    var pos: int = _find(ready,entry["subject"])
    if pos>=0:
        ready.remove_at(pos)
    ready.append(entry) # #231 removes prior occurrence and appends.
    battle.cancel_source_command_for_troop(entry["subject"])
    return true

func resolve_one(battle,active_action_busy: bool = false) -> int:
    if not enabled or busy or active_action_busy or battle.action_queue.resolving or (battle.troop_startup_plan.enabled and not battle.troop_startup_plan.done) or not battle.active or (
            battle.source_atb_wait):
        return 0
    # Godot actions are synchronous here, not a full VX animation lifecycle.
    # Mark busy before engine calls/signals to prevent reentrant resolution.
    while not ready.is_empty():
        var entry: Dictionary = ready.pop_front()
        if not _valid(battle,entry):
            _record(entry,false,-1,"target or subject no longer valid")
            if entry.has("page_ticket"):
                return 0 # Page HOLD takes precedence over unrelated queued actions.
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
        var object_id: int = int(entry["object_id"])
        if (kind=="attack" and not battle.attack_preflight(subject,target)) or (kind=="skill" and not battle.skill_preflight(subject,target,object_id)):
            _record(entry,false,index,"source action preflight")
            busy = false
            if entry.has("page_ticket"):
                return 0
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
        elif kind=="skill":
            success = battle.use_skill(subject,target,object_id)
        elif kind=="item":
            success = battle.use_item(target,object_id,subject,true)
        else:
            subject["guarding"] = false
            battle.attack(subject,target)
            success = not battle.accuracy.active or str(
                target.get("fs_last_action_result","blocked")) in ["hit","miss","evade"]
        if success:
            subject["source_act_active"] = true
            battle.finish_source_atb_action(subject,kind,object_id)
        _record(entry,success,index,"" if success else "execution refused")
        busy = false
        return 1
    return 0

func _record(entry: Dictionary,success: bool,index: int,reason: String) -> void:
    var receipt: Dictionary={"kind":entry["kind"],"actor":entry["actor"],"index":index,
        "object_id":entry["object_id"],"success":success,"reason":reason}
    receipt["target_mode"]=str(entry.get("target_mode","fixed"))
    if entry.has("page_ticket"):
        receipt["page_ticket"]=int(entry["page_ticket"])
    completed.append(receipt)
