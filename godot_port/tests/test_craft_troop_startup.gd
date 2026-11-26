extends SceneTree
# Synthetic common-event contents; actual owner CommonEvents remains HOLD.
const DB=preload("res://scripts/FSDatabase.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
const E=preload("res://scripts/FSVXEventInterpreter.gd")
const BRIDGE=preload("res://scripts/FSVXBattleBridge.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const PLAN=preload("res://scripts/FSTroopStartupPlan.gd")
var checks:int=0
var failures:int=0
func _initialize()->void:
    call_deferred("_run")
func _check(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failures+=1
        push_error("CRAFT_STARTUP_FAIL "+label)
func _cmd(code:int,params:Array=[])->Dictionary:
    return {"code":code,"indent":0,"parameters":params}
func _page(value:int=7,common_id:int=2)->Dictionary:
    return {"span":0,"condition":{"turn_ending":false,"turn_valid":true,"turn_a":0,"turn_b":0,
        "enemy_valid":false,"actor_valid":false,"switch_valid":false},
        "list":[_cmd(122,[11,11,0,0,value]),_cmd(117,[common_id]),_cmd(0)]}
func _child()->Array:
    return [_cmd(121,[15,15,0]),_cmd(122,[12,12,0,0,9]),_cmd(0)]
func _fixture(pages:Array,synthetic_verified:bool,page_hash:String,
        child:Array,child_hash:String)->Dictionary:
    var params:Array=[]
    params.resize(600)
    params.fill(0)
    for i in range(100):
        params[i*6]=120
        params[i*6+1]=30
        params[i*6+2]=20
        params[i*6+3]=7
        params[i*6+4]=10
        params[i*6+5]=8
    var db=DB.new()
    db.tables={"actors":[null,{"id":1,"name":"A","initial_level":5,"class_id":1,
        "parameters":{"xsize":6,"ysize":100,"data_int16":params}}],
        "enemies":[null,{"id":1,"name":"B","maxhp":100,"maxmp":5,"atk":2,"def":2,"spi":2,"agi":2}],
        "weapons":[null],"armors":[null],"states":[null],
        "troops":[null,null,{"id":2,"members":[{"enemy_id":1,"hidden":false}],"pages":pages}]}
    db.boot_final_verified=synthetic_verified
    var state=WORLD.new()
    state.party_actor_ids.append(1)
    var runner=E.new()
    root.add_child(runner)
    runner.setup(state)
    var bridge=BRIDGE.new()
    root.add_child(bridge)
    bridge.bind(runner,db,state)
    if not page_hash.is_empty():
        bridge.approved_source_force_page_hashes[2]=page_hash
    if not child.is_empty():
        bridge.source_common_event_lists[2]=child
    if not child_hash.is_empty():
        bridge.approved_source_common_event_hashes[2]=child_hash
    var combats:Array=[]
    var rejects:Array=[]
    bridge.combat_ready.connect(func(combat,tid)->void:combats.append(combat))
    bridge.battle_bridge_failed.connect(func(reason)->void:rejects.append(reason))
    runner.start_event([_cmd(301,[0,2,true,true]),_cmd(0)],1,1)
    return {"runner":runner,"bridge":bridge,"state":state,"combats":combats,"rejects":rejects}
func _unchanged(f:Dictionary)->bool:
    return f["state"].variable(11)==0 and f["state"].variable(12)==0 and not f["state"].switch_on(15)
func _rejected(f:Dictionary,label:String)->void:
    _check(f["combats"].is_empty() and f["rejects"].size()==1 and not f["runner"].active and _unchanged(f),label)
func _run()->void:
    var pages:Array=[_page()]
    var child:Array=_child()
    var ph:String=BRIDGE.source_force_page_digest(pages)
    var ch:String=BRIDGE.source_force_page_digest(child)
    _rejected(_fixture(pages,false,ph,child,ch),"raw bundle cannot authorize")
    _rejected(_fixture(pages,true,"",child,ch),"parent digest required")
    _rejected(_fixture(pages,true,ph,[],""),"missing common event stops before variable")
    _rejected(_fixture(pages,true,ph,child,""),"child approval required")
    _rejected(_fixture(pages,true,ph,child,"0".repeat(64)),"child digest mismatch")
    var changed:Array=child.duplicate(true)
    changed[1]["parameters"][4]=100
    _rejected(_fixture(pages,true,ph,changed,ch),"tampered child rejected")
    var unknown:Array=[_cmd(355,["not evaluated"]),_cmd(0)]
    _rejected(_fixture(pages,true,ph,unknown,BRIDGE.source_force_page_digest(unknown)),"approved bytes do not authorize Ruby")
    var recursion:Array=[_cmd(117,[2]),_cmd(0)]
    _rejected(_fixture(pages,true,ph,recursion,BRIDGE.source_force_page_digest(recursion)),"recursive child unsupported")
    var missing_second:Array=[_page(),_page(3,999)]
    _rejected(_fixture(missing_second,true,BRIDGE.source_force_page_digest(missing_second),child,ch),"all pages preflight before first write")
    var f=_fixture(pages,true,ph,child,ch)
    _check(f["combats"].size()==1 and f["runner"].waiting and _unchanged(f),"actual 301 candidate configured, no premature write")
    if f["combats"].size()==1:
        var b=f["combats"][0]
        _check(b.troop_startup_plan.enabled and not b.troop_startup_plan.done and not b.force_actions.enabled,"startup separate from force engine")
        _check(not f["bridge"].request_escape() and not b.begin_source_command(0),"no bypass before event")
        var order:Array=[]
        var reentry:Array=[]
        f["state"].variable_changed.connect(func(id:int,value:int)->void:
            order.append(["v",id,value])
            if b.troop_startup_plan.busy:
                reentry.append(b.action_queue.resolve_ready(b))
                b.advance_atb(1.0)
                reentry.append(b.source_atb_frame_count))
        f["state"].switch_changed.connect(func(id:int,value:bool)->void:order.append(["s",id,value]))
        b.advance_atb(1.0/60.0)
        _check(order==[["v",11,7],["s",15,true],["v",12,9]],"parent then child effects in exact order")
        _check(reentry==[0,0,0,0] and b.source_atb_frame_count==1,"no nested ACT or ATB frames during startup")
        _check(b.troop_startup_plan.done and b.troop_startup_plan.receipts.size()==1 and f["runner"].waiting,
            "startup receipt is not story victory")
        b.advance_atb(3.0/60.0)
        _check(order.size()==3 and b.troop_startup_plan.receipts.size()==1,"once per battle")
        _check(not b.configure_source_startup_pages(pages,{2:child}),"cannot configure after startup")
        _check(f["bridge"].request_escape(),"escape allowed after startup")
    var turn_later:Dictionary=_page()
    turn_later["condition"]["turn_a"]=2
    _check(not PLAN.new().configure([turn_later],{2:child}),"nonzero turn HOLD")
    var no_condition:Dictionary=_page()
    no_condition["condition"]["turn_valid"]=false
    var inert=PLAN.new()
    _check(inert.configure([no_condition],{}) and inert.plans.is_empty() and inert.inert_pages==[0],
        "original no-condition page explicitly inert, no missing child requirement")
    var inert_fixture=_fixture([no_condition],true,BRIDGE.source_force_page_digest([no_condition]),[],"")
    _check(inert_fixture["combats"].size()==1 and inert_fixture["runner"].waiting,"reviewed inert page starts without unused child")
    if inert_fixture["combats"].size()==1:
        var ib=inert_fixture["combats"][0]
        ib.advance_atb(1.0/60.0)
        _check(ib.troop_startup_plan.done and ib.troop_startup_plan.receipts.is_empty() and _unchanged(inert_fixture),
            "inert page has no effect")
    var inert_and_active:Array=[no_condition,_page()]
    _rejected(_fixture(inert_and_active,true,BRIDGE.source_force_page_digest(inert_and_active),[],""),
        "inert page cannot bypass active missing child")
    var inert_unknown:Dictionary=no_condition.duplicate(true)
    inert_unknown["list"]=[_cmd(355,["not evaluated"]),_cmd(0)]
    _check(not PLAN.new().configure([inert_unknown],{}),"unknown inactive command still outside subset")
    var malformed:Dictionary=_page()
    malformed["list"][0]["parameters"][1]=12
    _check(not PLAN.new().configure([malformed],{2:child}),"range assignment not in subset")
    malformed=_page()
    malformed["list"][0]["parameters"][3]=1
    _check(not PLAN.new().configure([malformed],{2:child}),"dynamic operand not in subset")
    var safe:Dictionary=_page()
    safe["list"]=[_cmd(0)]
    var p=PLAN.new()
    _check(p.configure([safe,_page()],{2:child}) and p.plans[0]["page"]==1,"empty page does not alter source page index")
    print("CRAFT_TROOP_STARTUP_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; SyntheticCommonEvent=True; OriginalVXRuntime=False")
    quit(0 if failures==0 else 1)
