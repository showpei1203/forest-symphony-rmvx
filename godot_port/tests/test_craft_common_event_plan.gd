extends SceneTree
const PLAN=preload("res://scripts/FSCommonEventPlan.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
var checks:int=0
var failures:int=0

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failures+=1
        push_error("COMMON_EVENT_FAIL "+label)

func _cmd(code:int,indent:int,params:Array=[])->Dictionary:
    return {"code":code,"indent":indent,"parameters":params}

func _parent(id:int=1)->Dictionary:
    return {"span":0,"condition":{"turn_ending":false,"turn_valid":true,"turn_a":0,"turn_b":0,
        "enemy_valid":false,"actor_valid":false,"switch_valid":false},
        "list":[_cmd(122,0,[29,29,0,0,3]),_cmd(117,0,[id]),_cmd(0,0)]}

# JSON numbers are floats on import, whereas native IDs are ints.
# Compare typed semantic fields explicitly rather than Array[Dictionary]
# identity/equality (which also differs for typed and untyped arrays).
func _trace_equal(actual:Variant,expected:Variant)->bool:
    if not actual is Array or not expected is Array or actual.size()!=expected.size():
        return false
    for i in range(actual.size()):
        var a:Dictionary=actual[i]
        var e:Dictionary=expected[i]
        if a.get("kind","")!=e.get("kind",""):
            return false
        if a["kind"]=="switch":
            if int(a["id"])!=int(e["id"]) or typeof(a["value"])!=TYPE_BOOL or a["value"]!=e["value"]:
                return false
        elif a["kind"]=="force":
            if a["params"].size()!=e["params"].size():
                return false
            for k in range(a["params"].size()):
                if int(a["params"][k])!=int(e["params"][k]):
                    return false
        else:
            return false
    return true

func _battle_fixture(row:Dictionary):
    var world=WORLD.new()
    var db=DB.new()
    var armors:Array=[null]
    var b=BATTLE.new(db,world)
    for id in row["party"]:
        var actor:Dictionary=row["actors"].get(str(int(id)),{"exists":true,"armors":[]})
        var equipment:Array=[0,0,0,0,0]
        var pos:int=1
        for armor in actor.get("armors",[]):
            if pos>=5:
                return null
            var aid:int=int(armor)
            if armors.size()<=aid:
                armors.resize(aid+1)
            armors[aid]={"id":aid}
            equipment[pos]=aid
            pos+=1
        b.party.append({"id":int(id),"actor":true,"name":"Probe","hp":100,"maxhp":100,"mp":100,"maxmp":100,
            "agi":10,"atk":10,"def":5,"spi":5,"states":[],"guarding":false,"equipment":equipment,"two_swords_style":false})
        world.party_actor_ids.append(int(id))
    db.tables={"armors":armors,"weapons":[null],"states":[null]}
    b.enemies.append({"id":1,"actor":false,"name":"Probe enemy","hp":100,"maxhp":100,"mp":100,"maxmp":100,
        "agi":10,"atk":5,"def":5,"spi":5,"states":[],"guarding":false})
    if not b.start():
        return null
    return b

func _run()->void:
    var args:=OS.get_cmdline_user_args()
    if args.size()!=1:
        quit(2)
        return
    var input:Variant=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
    if not input is Dictionary or not input.get("cases",null) is Array:
        quit(2)
        return
    var commands:Array=input["commands"]
    var parent:Dictionary=input.get("parent",_parent())
    var id:int=int(input.get("common_id",1))
    var switch_only:int=0
    var held:int=0
    var battle_cases:int=0
    var battle_switch:int=0
    var battle_hold:int=0
    for row in input["cases"]:
        var plan=PLAN.new()
        var world=WORLD.new()
        _check(plan.compile(commands),"compile source shape")
        var result:Dictionary=plan.preview(row["actors"],row["party"])
        _check(result["ok"] and _trace_equal(result["intents"],row["expected"]),"exact Ruby branch/write/force intent trace")
        var has_force:bool=false
        for intent in row["expected"]:
            if intent["kind"]=="force":
                has_force=true
        var applied:Dictionary=plan.apply_startup_switch_only(world,parent,id,row["actors"],row["party"])
        if has_force:
            held+=1
            _check(not applied["ok"] and world.switches.is_empty() and world.variables.is_empty(),"forced-effect HOLD before any writes")
        else:
            switch_only+=1
            var expected:Dictionary={}
            for intent in row["expected"]:
                expected[int(intent["id"])]=intent["value"]
            var p:Array=parent["list"][0]["parameters"]
            _check(applied["ok"] and world.switches==expected and world.variable(int(p[0]))==int(p[4]),"actual FSGameState writes from exact parent/child")
            _check(not plan.apply_startup_switch_only(world,parent,id,row["actors"],row["party"])["ok"],"one execution only")
        if not row["party"].is_empty():
            battle_cases+=1
            var b=_battle_fixture(row)
            _check(b!=null,"native battle fixture")
            if b==null:
                continue
            var offparty:Dictionary=row["actors"].duplicate(true)
            for aid in row["party"]:
                offparty.erase(str(int(aid)))
            _check(b.configure_source_startup_pages([parent],{id:commands},true,offparty),"actual battle startup configure")
            _check(b.world.switches.is_empty() and b.world.variables.is_empty() and not b.begin_source_command(0),"startup not bypassed")
            b.advance_atb(1.0/60.0)
            if has_force:
                battle_hold+=1
                _check(not b.troop_startup_plan.done and not b.troop_startup_plan.blocked_reason.is_empty() and
                    b.source_atb_frame_count==0 and b.world.switches.is_empty() and b.world.variables.is_empty(),"actual battle holds force path before first frame or write")
            else:
                battle_switch+=1
                _check(b.troop_startup_plan.done and b.source_atb_frame_count==1 and
                    b.world.switches==world.switches and b.world.variables==world.variables and b.troop_startup_plan.receipts.size()==1,
                    "actual first-frame native switch path matches original intent")
                b.advance_atb(2.0/60.0)
                _check(b.troop_startup_plan.receipts.size()==1,"actual startup never replays")
    # Structural and authority negative controls independent of private ids.
    var invalid:Array=[
        [_cmd(111,0,[12,"unsafe script"]),_cmd(0,1),_cmd(412,0),_cmd(0,0)],
        [_cmd(111,0,[4,8,0]),_cmd(121,1,[7,7,0]),_cmd(0,0)],
        [_cmd(411,0),_cmd(0,0)],
        [_cmd(121,0,[1,2,0]),_cmd(0,0)],
        [_cmd(339,0,[0,0,1,8,-1]),_cmd(0,0)],
        [_cmd(355,0,["unsafe"]),_cmd(0,0)],
        [_cmd(0,0),_cmd(0,0)],
        [_cmd(408,0,["orphan"]),_cmd(0,0)]
    ]
    for cs in invalid:
        var rejected=PLAN.new()
        _check(not rejected.compile(cs) and not rejected.compiled and rejected.program.is_empty(),"whole program fail closed")
    var probe=PLAN.new()
    _check(probe.compile([_cmd(111,0,[4,8,4,2]),_cmd(0,1),_cmd(412,0),_cmd(0,0)]),"armor probe compile")
    _check(not probe.preview({},[])["ok"],"missing off-party actor is not assumed unequipped")
    _check(not probe.preview({"8":{"exists":false}},[8])["ok"],"inconsistent party snapshot")
    _check(not probe.preview({"8":{"exists":true,"armors":["2"]}},[])["ok"],"typed armor identity")
    # A non-party actor's missing authority and late equipment change must
    # be visible at actual first frame, not silently treated as unequipped.
    var actor_commands:Array=[_cmd(111,0,[4,8,4,2]),_cmd(121,1,[7,7,0]),_cmd(0,1),_cmd(412,0),_cmd(0,0)]
    var off=_battle_fixture({"party":[9],"actors":{}})
    _check(off.configure_source_startup_pages([_parent()],{1:actor_commands},true,{}),"missing off-party source config")
    off.advance_atb(1.0/60.0)
    _check(off.source_atb_frame_count==0 and not off.troop_startup_plan.blocked_reason.is_empty() and off.world.variables.is_empty(),"off-party missing authority holds")
    var live=_battle_fixture({"party":[8],"actors":{"8":{"exists":true,"armors":[]}}})
    _check(live.configure_source_startup_pages([_parent()],{1:actor_commands},true,{}),"live source config")
    live.db.tables["armors"]=[null,null,{"id":2}]
    live.party[0]["equipment"][1]=2
    live.advance_atb(1.0/60.0)
    _check(live.troop_startup_plan.done and live.world.switch_on(7),"late live armor, not cached snapshot")
    var dual=_battle_fixture({"party":[8],"actors":{"8":{"exists":true,"armors":[2]}}})
    dual.party[0]["two_swords_style"]=true # slot1 is second weapon, not armor
    _check(dual.configure_source_startup_pages([_parent()],{1:actor_commands},true,{}),"dual wield source config")
    dual.advance_atb(1.0/60.0)
    _check(dual.troop_startup_plan.done and not dual.world.switch_on(7),"second weapon cannot satisfy armor condition")
    var invalid_armor=_battle_fixture({"party":[8],"actors":{"8":{"exists":true,"armors":[]}}})
    invalid_armor.party[0]["equipment"][1]=2
    _check(invalid_armor.configure_source_startup_pages([_parent()],{1:actor_commands},true,{}),"invalid equipment config")
    invalid_armor.advance_atb(1.0/60.0)
    _check(invalid_armor.source_atb_frame_count==0 and invalid_armor.world.variables.is_empty(),"missing armor DB cannot masquerade as valid equipment")
    print("CRAFT_COMMON_EVENT_BATTLE_SUMMARY; Cases="+str(battle_cases)+"; SwitchOnly="+str(battle_switch)+"; ForcedHold="+str(battle_hold)+"; ProductionBridge=False")
    print("CRAFT_COMMON_EVENT_NATIVE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; Cases="+str(input["cases"].size())+"; SwitchOnly="+str(switch_only)+"; ForcedHold="+str(held)+"; FullVXRuntime=False")
    quit(0 if failures==0 else 1)
