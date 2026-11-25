extends SceneTree
const PLAN=preload("res://scripts/FSCommonEventPlan.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
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
    for row in input["cases"]:
        var plan=PLAN.new()
        var world=WORLD.new()
        _check(plan.compile(commands),"compile source shape")
        var result:Dictionary=plan.preview(row["actors"],row["party"])
        _check(result["ok"] and result["intents"]==row["expected"],"exact Ruby branch/write/force intent trace")
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
    print("CRAFT_COMMON_EVENT_NATIVE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; Cases="+str(input["cases"].size())+"; SwitchOnly="+str(switch_only)+"; ForcedHold="+str(held)+"; FullVXRuntime=False")
    quit(0 if failures==0 else 1)
