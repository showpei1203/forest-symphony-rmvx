extends RefCounted
class_name FSCommonEventPlan

# Read-only compiler for the verified opcode shape of a source common event.
# Explicit actor snapshot, not assumed current state of off-party actors.
# Forced actions are INTENTS only until their real post-Apply effects and
# interpreter suspension/settlement have separate authority.
var program:Array[Dictionary]=[]
var compiled:bool=false
var busy:bool=false
var applied:bool=false

static func _int(v:Variant,lo:int=0,hi:int=999999)->bool:
    return FSTroopForcePages._integer(v,lo,hi)

static func _condition(p:Array)->bool:
    return p.size()>=3 and _int(p[0],4,4) and _int(p[1],1,999999) and (
        (p.size()==3 and _int(p[2],0,0)) or
        (p.size()==4 and _int(p[2],4,4) and _int(p[3],1,999999)))

static func _switch(p:Array)->bool:
    return p.size()==3 and _int(p[0],1,999999) and _int(p[1],int(p[0]),int(p[0])) and _int(p[2],0,1)

static func _force(p:Array)->bool:
    if p.size()!=5 or not _int(p[0],0,1) or not _int(p[1],0,9999) or not _int(p[2],0,1) or not _int(p[4],0,9999):
        return false
    return _int(p[3],0,1) if int(p[2])==0 else _int(p[3],1,999999)

func compile(commands:Array)->bool:
    if compiled or commands.is_empty() or commands.size()>1024:
        return false
    var next_program:Array[Dictionary]=[]
    var stack:Array[Dictionary]=[]
    for i in range(commands.size()):
        var c:Variant=commands[i]
        if not c is Dictionary or not _int(c.get("code",null),0,9999) or not _int(c.get("indent",null),0,16) or not c.get("parameters",null) is Array:
            return false
        var op:int=int(c["code"])
        var indent:int=int(c["indent"])
        var p:Array=c["parameters"]
        if indent!=stack.size()-(1 if op in [411,412] else 0):
            return false
        if i==commands.size()-1 and (op!=0 or indent!=0):
            return false
        var node:Dictionary={"code":op,"params":p.duplicate(true)}
        match op:
            111:
                if not _condition(p):
                    return false
                stack.append({"if_index":i,"else_index":-1})
            411,412:
                if stack.is_empty() or not p.is_empty() or i==0 or int(next_program[-1]["code"])!=0:
                    return false
                var frame:Dictionary=stack[-1]
                if op==411:
                    if int(frame["else_index"])!=-1:
                        return false
                    frame["else_index"]=i
                    next_program[int(frame["if_index"])]["jump"]=i+1
                else:
                    stack.pop_back()
                    if int(frame["else_index"])>=0:
                        next_program[int(frame["else_index"])]["jump"]=i+1
                    else:
                        next_program[int(frame["if_index"])]["jump"]=i+1
            0:
                if not p.is_empty():
                    return false
                if indent==0 and i!=commands.size()-1:
                    return false
                if indent>0:
                    if i+1>=commands.size() or not commands[i+1] is Dictionary or not _int(commands[i+1].get("code",null),0,9999) or int(commands[i+1]["code"]) not in [411,412]:
                        return false
            108,408:
                if p.size()!=1 or not p[0] is String or p[0].length()>10000:
                    return false
                if op==408 and (i==0 or int(next_program[-1]["code"]) not in [108,408]):
                    return false
            121:
                if not _switch(p):
                    return false
            339:
                if not _force(p):
                    return false
            _:
                return false
        next_program.append(node)
    if not stack.is_empty():
        return false
    program=next_program
    compiled=true
    return true

static func _error(reason:String)->Dictionary:
    return {"ok":false,"reason":reason,"intents":[]}

func preview(actors:Dictionary,party_ids:Array)->Dictionary:
    if not compiled:
        return _error("uncompiled event")
    var roster:Array[int]=[]
    for id in party_ids:
        if not _int(id,1,999999) or int(id) in roster:
            return _error("invalid party identity")
        roster.append(int(id))
    var intents:Array[Dictionary]=[]
    var pc:int=0
    while pc<program.size():
        var node:Dictionary=program[pc]
        var p:Array=node["params"]
        match int(node["code"]):
            111:
                var actor_id:int=int(p[1])
                var actor:Variant=actors.get(str(actor_id),null)
                if not actor is Dictionary or typeof(actor.get("exists",null))!=TYPE_BOOL:
                    return _error("missing actor snapshot")
                if not actor["exists"] and actor_id in roster:
                    return _error("inconsistent party snapshot")
                var result:bool=false
                if int(p[2])==0:
                    result=actor["exists"] and actor_id in roster
                elif actor["exists"]:
                    if not actor.get("armors",null) is Array:
                        return _error("missing armor snapshot")
                    var armor_ids:Array[int]=[]
                    for id in actor["armors"]:
                        if not _int(id,1,999999):
                            return _error("invalid armor snapshot")
                        armor_ids.append(int(id))
                    result=int(p[3]) in armor_ids
                if not result:
                    pc=int(node["jump"])
                    continue
            411:
                pc=int(node["jump"])
                continue
            121:
                intents.append({"kind":"switch","id":int(p[0]),"value":int(p[2])==0})
            339:
                var args:Array[int]=[]
                for v in p:
                    args.append(int(v))
                intents.append({"kind":"force","params":args})
        pc+=1
    return {"ok":true,"intents":intents}

# One real source-shaped startup parent, explicit caller-owned snapshot.
# Any force intent prevents ALL parent/child writes; no simulated success.
# Not wired into production bridge; external signal rollback is not claimed.
func apply_startup_switch_only(world:FSGameState,parent:Dictionary,common_id:int,actors:Dictionary,party_ids:Array)->Dictionary:
    if busy or applied or world==null or not _int(common_id,1,999999):
        return _error("startup already applied or missing world")
    var c:Variant=parent.get("condition",null)
    var cs:Variant=parent.get("list",null)
    if not c is Dictionary or not cs is Array or not _int(parent.get("span",null),0,0) or cs.size()!=3:
        return _error("unsupported parent")
    for key in ["turn_ending","turn_valid","enemy_valid","actor_valid","switch_valid"]:
        if typeof(c.get(key,null))!=TYPE_BOOL or bool(c[key])!=(key=="turn_valid"):
            return _error("not an exact turn-zero parent")
    if not _int(c.get("turn_a",null),0,0) or not _int(c.get("turn_b",null),0,0):
        return _error("not turn zero")
    var w:Dictionary=FSTroopStartupPlan._write(cs[0])
    if w.get("kind","")!="variable" or not FSTroopStartupPlan._command(cs[1],117) or not FSTroopStartupPlan._end(cs[2]):
        return _error("unsupported parent commands")
    var args:Array=cs[1]["parameters"]
    if args.size()!=1 or not _int(args[0],common_id,common_id):
        return _error("common id mismatch")
    var result:Dictionary=preview(actors,party_ids)
    if not result["ok"]:
        return result
    for intent in result["intents"]:
        if intent["kind"]!="switch":
            return _error("force skill effect and suspension authority HOLD")
    busy=true
    world.set_variable(w["id"],w["value"])
    for intent in result["intents"]:
        world.set_switch(intent["id"],intent["value"])
    applied=true
    busy=false
    return {"ok":true,"intents":result["intents"],"writes":result["intents"].size()+1}
