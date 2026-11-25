extends SceneTree
# This fixture toggles a synthetic boot-final Boolean solely to exercise the
# bridge's conjunction. It is NOT a real post-Apply authority certificate.
const DB=preload("res://scripts/FSDatabase.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
const E=preload("res://scripts/FSVXEventInterpreter.gd")
const B=preload("res://scripts/FSVXBattleBridge.gd")
var checks:int=0
var failures:int=0
func _initialize()->void:
    call_deferred("_run")
func _check(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failures+=1
        push_error("CRAFT_BRIDGE_FAIL "+label)
func _cmd(code:int,indent:int,params:Array=[])->Dictionary:
    return {"code":code,"indent":indent,"parameters":params}
func _page(subject:int=0)->Dictionary:
    return {"span":0,"condition":{"turn_ending":false,"turn_valid":false,
        "enemy_valid":true,"actor_valid":false,"switch_valid":false,
        "enemy_index":0,"enemy_hp":100},
        "list":[_cmd(339,0,[1,subject,0,1,0]),_cmd(0,0)]}
func _fixture(pages:Array,synthetic_verified:bool,approval:String)->Dictionary:
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
        "enemies":[null,{"id":1,"name":"B","maxhp":12,"maxmp":5,"atk":2,"def":2,"spi":2,"agi":2}],
        "weapons":[null],"armors":[null],"states":[null],
        "troops":[null,null,{"id":2,"members":[{"enemy_id":1,"hidden":false}],"pages":pages}]}
    db.boot_final_verified=synthetic_verified
    var state=WORLD.new()
    state.party_actor_ids.append(1)
    var runner=E.new()
    root.add_child(runner)
    runner.setup(state)
    var bridge=B.new()
    root.add_child(bridge)
    bridge.bind(runner,db,state)
    if not approval.is_empty():
        bridge.approved_source_force_page_hashes[2]=approval
    var combats:Array=[]
    var rejects:Array=[]
    bridge.combat_ready.connect(func(combat,tid)->void: combats.append(combat))
    bridge.battle_bridge_failed.connect(func(reason)->void: rejects.append(reason))
    runner.start_event([_cmd(301,0,[0,2,true,true]),_cmd(601,0),
        _cmd(121,1,[10,10,0]),_cmd(602,0),_cmd(121,1,[11,11,0]),
        _cmd(603,0),_cmd(121,1,[12,12,0]),_cmd(604,0),_cmd(0,0)],1,1)
    return {"runner":runner,"bridge":bridge,"state":state,"combats":combats,"rejects":rejects}
func _no_story(f:Dictionary)->bool:
    return not f["state"].switch_on(10) and not f["state"].switch_on(11) and not f["state"].switch_on(12)
func _rejected(f:Dictionary,label:String)->void:
    _check(f["combats"].is_empty() and f["rejects"].size()==1 and not f["runner"].active and _no_story(f),label)
func _run()->void:
    var pages:Array=[_page()]
    var digest:String=B.source_force_page_digest(pages)
    _rejected(_fixture(pages,false,digest),"raw data rejected despite matching page digest")
    _rejected(_fixture(pages,true,""),"default approval map empty")
    _rejected(_fixture(pages,true,"0".repeat(64)),"wrong page digest rejected")
    var changed:Array=pages.duplicate(true)
    changed[0]["condition"]["enemy_hp"]=99
    _rejected(_fixture(changed,true,digest),"changed page invalidates approval")
    var unsupported:Array=pages.duplicate(true)
    unsupported[0]["list"][0]["code"]=355
    _rejected(_fixture(unsupported,true,B.source_force_page_digest(unsupported)),
        "matching digest cannot authorize unsupported Ruby command")
    var f=_fixture(pages,true,digest)
    _check(f["combats"].size()==1 and f["runner"].waiting and f["rejects"].is_empty(),"approved synthetic candidate starts through 301")
    if f["combats"].size()==1:
        var combat=f["combats"][0]
        _check(combat.force_actions.enabled and combat.troop_force_pages.enabled,"bridge configures force pages")
        combat.source_atb_wait=true
        combat.advance_atb(1.0/60.0)
        _check(combat.troop_force_pages.pending_page==0 and not f["bridge"].request_escape() and
            f["runner"].waiting and _no_story(f),"cannot escape pending event command")
        combat.source_atb_wait=false
        combat.advance_atb(1.0/60.0)
        _check(combat.troop_force_pages.fired.has(0) and combat.force_actions.completed.size()==1 and
            bool(combat.party[0]["guarding"]),"native 301 -> troop -> 339 -> guard settlement")
        _check(f["runner"].waiting and _no_story(f),"page settlement is not battle victory")
        _check(f["bridge"].request_escape(),"verified external escape continuation")
        _check(f["state"].switch_on(11) and not f["state"].switch_on(10) and not f["state"].switch_on(12),"correct event escape branch")
    var bad:Array=[_page(9)]
    var h=_fixture(bad,true,B.source_force_page_digest(bad))
    _check(h["combats"].size()==1 and h["runner"].waiting,"structurally valid missing actor fixture")
    if h["combats"].size()==1:
        var combat=h["combats"][0]
        combat.advance_atb(1.0/60.0)
        _check(not combat.active and not h["runner"].active and h["rejects"].size()==1 and _no_story(h),
            "runtime hold aborts map interpreter without success branch")
        _check(not h["bridge"].request_escape(),"cannot escape an aborted event")
    print("CRAFT_FORCE_BRIDGE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; SyntheticAuthority=True; OriginalVXRuntime=False")
    quit(0 if failures==0 else 1)
