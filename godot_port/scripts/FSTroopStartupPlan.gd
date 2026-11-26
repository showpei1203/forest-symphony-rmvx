extends RefCounted
class_name FSTroopStartupPlan

# Bounded turn-zero candidate for source #21 and command 122/117.
# No Ruby, recursive common events, arbitrary expressions or battle effects.
# A prevalidated child list is mandatory; the real common-event DB is
# separate from the eleven-table boot-final contract. A source-shaped actor
# conditional branch is a second explicit opt-in, not production approval.
var enabled: bool=false
var done: bool=false
var busy: bool=false
var blocked_reason: String=""
var plans: Array[Dictionary]=[]
var receipts: Array[Dictionary]=[]
var inert_pages: Array[int]=[] # explicit source #21 no-condition nonempty pages
var actor_common_mode:bool=false
var offparty_actor_snapshots:Dictionary={}

static func _int(v:Variant,lo:int,hi:int)->bool:
    return FSTroopForcePages._integer(v,lo,hi)

static func _command(c:Variant,code:int)->bool:
    return c is Dictionary and _int(c.get("code",null),code,code) and (
        _int(c.get("indent",null),0,0)) and c.get("parameters",null) is Array

static func _end(c:Variant)->bool:
    return _command(c,0) and c["parameters"].is_empty()

static func _write(c:Variant)->Dictionary:
    if _command(c,122):
        var a:Array=c["parameters"]
        if a.size()!=5 or not _int(a[0],1,999999) or not _int(a[1],int(a[0]),int(a[0])) or (
                not _int(a[2],0,0)) or not _int(a[3],0,0) or not _int(a[4],-99999999,99999999):
            return {}
        return {"kind":"variable","id":int(a[0]),"value":int(a[4])}
    if _command(c,121):
        var a:Array=c["parameters"]
        if a.size()!=3 or not _int(a[0],1,999999) or not _int(a[1],int(a[0]),int(a[0])) or not _int(a[2],0,1):
            return {}
        return {"kind":"switch","id":int(a[0]),"value":int(a[2])==0}
    return {}

func configure(raw:Array,verified_common_lists:Dictionary,allow_actor_common:bool=false,offparty_snapshots:Dictionary={})->bool:
    if enabled or raw.is_empty() or raw.size()>32:
        return false
    var staged:Array[Dictionary]=[]
    var inert:Array[int]=[]
    for i in range(raw.size()):
        var p:Variant=raw[i]
        if not p is Dictionary or not _int(p.get("span",null),0,0) or not (
                p.get("condition",null) is Dictionary) or not p.get("list",null) is Array:
            return false
        var c:Dictionary=p["condition"]
        for key in ["turn_ending","turn_valid","enemy_valid","actor_valid","switch_valid"]:
            if typeof(c.get(key,null))!=TYPE_BOOL:
                return false
        var commands:Array=p["list"]
        if commands.size()==1 and _end(commands[0]):
            continue
        # The actual #21 conditions_met? returns false when every flag
        # is false. For this exact reviewed 122/117 shape, retain the
        # page index as inert rather than inventing a common event call.
        var is_inert:bool=not c["turn_valid"] and not c["turn_ending"] and not c["enemy_valid"] and not c["actor_valid"] and not c["switch_valid"]
        if not is_inert and (not c["turn_valid"] or c["turn_ending"] or c["enemy_valid"] or c["actor_valid"] or c["switch_valid"] or
                not _int(c.get("turn_a",null),0,0) or not _int(c.get("turn_b",null),0,0)):
            return false
        if commands.size()!=3 or not _command(commands[0],122) or not _command(commands[1],117) or not _end(commands[2]):
            return false
        var first:Dictionary=_write(commands[0])
        var args:Array=commands[1]["parameters"]
        if first.is_empty() or args.size()!=1 or not _int(args[0],1,999999):
            return false
        var common_id:int=int(args[0])
        if is_inert:
            inert.append(i)
            continue
        var child:Variant=verified_common_lists.get(common_id,null)
        if not child is Array or child.is_empty() or not _end(child[-1]):
            return false
        var writes:Array[Dictionary]=[first]
        if allow_actor_common:
            var actor_plan:=FSCommonEventPlan.new()
            if not actor_plan.compile(child):
                return false
            staged.append({"page":i,"common_id":common_id,"writes":writes,"actor_plan":actor_plan})
        else:
            if child.size()>64:
                return false
            for j in range(child.size()-1):
                var write:Dictionary=_write(child[j])
                if write.is_empty():
                    return false
                writes.append(write)
            staged.append({"page":i,"common_id":common_id,"writes":writes})
    if staged.is_empty() and inert.is_empty():
        return false
    if allow_actor_common and staged.size()!=1:
        return false # only one actual turn-zero parent; no guessed sequencing
    plans=staged
    inert_pages=inert
    actor_common_mode=allow_actor_common
    offparty_actor_snapshots=offparty_snapshots.duplicate(true) if allow_actor_common else {}
    enabled=true
    return true

# Snapshot from real live battle equipment, not cached actor data or weapon
# IDs. An off-party actor requires a separately provided authoritative
# snapshot; its absence is not treated as an empty equipment list.
func _actor_context(battle,plan:FSCommonEventPlan)->Dictionary:
    var live:Dictionary={}
    var roster:Array[int]=[]
    for actor in battle.party:
        var id:Variant=actor.get("id",null)
        if not _int(id,1,999999) or int(id) in roster or typeof(actor.get("actor",null))!=TYPE_BOOL or not actor["actor"]:
            return {"ok":false}
        roster.append(int(id))
        live[str(int(id))]=actor
    var snapshots:Dictionary={}
    for id in plan.required_actor_ids():
        var key:String=str(id)
        if not live.has(key):
            var absent:Variant=offparty_actor_snapshots.get(key,null)
            if not absent is Dictionary:
                return {"ok":false}
            snapshots[key]=absent
            continue
        var battler:Dictionary=live[key]
        var equipment:Variant=battler.get("equipment",null)
        if not equipment is Array or equipment.size()!=5 or typeof(battler.get("two_swords_style",null))!=TYPE_BOOL:
            return {"ok":false}
        var armor_ids:Array[int]=[]
        for slot in range(5):
            if not _int(equipment[slot],0,999999):
                return {"ok":false}
            var item_id:int=int(equipment[slot])
            if item_id==0 or battle.db.equip_kind(battler,slot)!="armors":
                continue
            var row:Dictionary=battle.db.record("armors",item_id)
            if row.is_empty() or not _int(row.get("id",null),item_id,item_id):
                return {"ok":false}
            armor_ids.append(item_id)
        # #330 YEM adds extra armor slots to #15 Game_Actor#armors.
        # A stock five-slot Godot actor alone is NOT source-complete.
        # This explicitly supplied candidate snapshot represents all extra
        # slots at this boundary (null/0 are empty); no implicit [] fallback.
        var extra:Variant=battler.get("fs_source_extra_armor_slots",null)
        if not extra is Array or extra.size()>32:
            return {"ok":false}
        for value in extra:
            if value==null:
                continue
            if not _int(value,0,999999):
                return {"ok":false}
            var extra_id:int=int(value)
            if extra_id==0:
                continue
            var extra_row:Dictionary=battle.db.record("armors",extra_id)
            if extra_row.is_empty() or not _int(extra_row.get("id",null),extra_id,extra_id):
                return {"ok":false}
            armor_ids.append(extra_id)
        snapshots[key]={"exists":true,"armors":armor_ids}
    return {"ok":true,"actors":snapshots,"party":roster}

func apply_before_first_frame(battle)->int:
    if not enabled or done:
        return 0
    if busy:
        return 0
    if not blocked_reason.is_empty():
        return -1
    if not battle.active or battle.world==null or not battle.action_queue.completed.is_empty() or (
            not battle.force_actions.completed.is_empty()):
        blocked_reason="Turn-zero common event missing world or startup already passed"
        return -1
    # Resolve all conditional intents from the live battle before writing.
    # Unknown effects HOLD the entire event and leave the ATB at frame zero.
    var resolved:Array[Dictionary]=[]
    for plan in plans:
        var writes:Array=plan["writes"].duplicate(true)
        if plan.has("actor_plan"):
            var actor_plan:FSCommonEventPlan=plan["actor_plan"]
            var context:Dictionary=_actor_context(battle,actor_plan)
            if not context["ok"]:
                blocked_reason="Common event actor/equipment snapshot authority missing"
                return -1
            var result:Dictionary=actor_plan.preview(context["actors"],context["party"])
            if not result["ok"]:
                blocked_reason="Common event actor condition: "+str(result["reason"])
                return -1
            for intent in result["intents"]:
                if intent["kind"]!="switch":
                    blocked_reason="Common event forced skill effect/suspension authority HOLD"
                    return -1
                writes.append(intent)
        resolved.append({"page":plan["page"],"common_id":plan["common_id"],"writes":writes})
    # All parent and child commands have been preflighted before any write.
    # Keep reentrant battle dispatch locked while synchronous signals fire.
    busy=true
    for plan in resolved:
        for w in plan["writes"]:
            if w["kind"]=="variable":
                battle.world.set_variable(w["id"],w["value"])
            else:
                battle.world.set_switch(w["id"],w["value"])
        receipts.append({"page":plan["page"],"common_id":plan["common_id"],"writes":plan["writes"].size()})
    done=true
    busy=false
    return 1
