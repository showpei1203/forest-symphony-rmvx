extends RefCounted
class_name FSTroopStartupPlan

# Bounded turn-zero candidate for source #21 and command 122/117.
# No Ruby, recursive common events, arbitrary expressions or battle effects.
# A prevalidated child list is mandatory; the real common-event DB is
# separate from the eleven-table boot-final contract and is still HOLD.
var enabled: bool=false
var done: bool=false
var busy: bool=false
var blocked_reason: String=""
var plans: Array[Dictionary]=[]
var receipts: Array[Dictionary]=[]

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

func configure(raw:Array,verified_common_lists:Dictionary)->bool:
    if enabled or raw.is_empty() or raw.size()>32:
        return false
    var staged:Array[Dictionary]=[]
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
        # Exact once-per-battle turn zero shape only. No claim of full
        # turn-clock parity or inactive nonempty page handling.
        if not c["turn_valid"] or c["turn_ending"] or c["enemy_valid"] or c["actor_valid"] or c["switch_valid"] or (
                not _int(c.get("turn_a",null),0,0)) or not _int(c.get("turn_b",null),0,0):
            return false
        if commands.size()!=3 or not _command(commands[0],122) or not _command(commands[1],117) or not _end(commands[2]):
            return false
        var first:Dictionary=_write(commands[0])
        var args:Array=commands[1]["parameters"]
        if first.is_empty() or args.size()!=1 or not _int(args[0],1,999999):
            return false
        var common_id:int=int(args[0])
        var child:Variant=verified_common_lists.get(common_id,null)
        if not child is Array or child.is_empty() or child.size()>64 or not _end(child[-1]):
            return false
        var writes:Array[Dictionary]=[first]
        for j in range(child.size()-1):
            var write:Dictionary=_write(child[j])
            if write.is_empty():
                return false
            writes.append(write)
        staged.append({"page":i,"common_id":common_id,"writes":writes})
    if staged.is_empty():
        return false
    plans=staged
    enabled=true
    return true

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
    # All parent and child commands have been preflighted before any write.
    # Keep reentrant battle dispatch locked while synchronous signals fire.
    busy=true
    for plan in plans:
        for w in plan["writes"]:
            if w["kind"]=="variable":
                battle.world.set_variable(w["id"],w["value"])
            else:
                battle.world.set_switch(w["id"],w["value"])
        receipts.append({"page":plan["page"],"common_id":plan["common_id"],"writes":plan["writes"].size()})
    done=true
    busy=false
    return 1
