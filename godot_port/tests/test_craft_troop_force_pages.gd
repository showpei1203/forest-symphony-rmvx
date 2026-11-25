extends SceneTree
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const PAGES = preload("res://scripts/FSTroopForcePages.gd")
var checks: int = 0
var failures: int = 0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool,label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("CRAFT_PAGE_FAIL "+label)
func _page(use_switch: bool,side: int,index: int = 0) -> Dictionary:
    return {"span":0,"condition":{"turn_ending":false,"turn_valid":false,
        "enemy_valid":true,"actor_valid":false,"switch_valid":use_switch,
        "enemy_index":0,"enemy_hp":50,"switch_id":7},
        "list":[{"code":339,"indent":0,"parameters":[side,index,0,1,0]},
        {"code":0,"indent":0,"parameters":[]}]}
func _fixture():
    var db=DB.new()
    db.tables={"weapons":[null],"armors":[null],"states":[null]}
    var world=WORLD.new()
    var b=BATTLE.new(db,world)
    b.party.append({"id":1,"actor":true,"name":"A","hp":500,"maxhp":500,
        "mp":100,"maxmp":100,"agi":20,"atk":20,"def":4,"spi":5,"states":[],
        "guarding":false,"equipment":[0,0,0,0,0],"two_swords_style":false})
    b.enemies.append({"id":551,"actor":false,"name":"B","hp":100,"maxhp":100,
        "mp":0,"maxmp":0,"agi":10,"atk":10,"def":2,"spi":3,"states":[],"guarding":false})
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    _check(b.start(),"start")
    for subject in [b.party[0],b.enemies[0]]:
        subject["source_atb_gain_per_frame"]=0
        subject["source_atb_count"]=0
        subject["source_at_active"]=false
        subject["source_atb_count_up"]=true
        subject["source_act_active"]=false
    return b
func _run() -> void:
    var args=OS.get_cmdline_user_args()
    if args.size()!=1:
        quit(2)
        return
    var oracle=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
    if not oracle is Dictionary or oracle.get("page_steps",[]).size()!=4:
        quit(2)
        return
    var b=_fixture()
    var p0=_page(true,1)
    var p1=_page(false,0)
    _check(not b.configure_source_force_pages([p0,p1]),"disabled by default")
    b.force_actions.enabled=true
    _check(b.configure_source_force_pages([p0,p1]),"bounded pages configure")
    _check(not b.configure_source_force_pages([p0]),"cannot reset event flags during battle")
    # Real frame dispatch compared to actual original Ruby page selection.
    for step: Dictionary in oracle["page_steps"]:
        b.enemies[0]["hp"]=int(step["hp"])
        b.world.set_switch(7,bool(step["switch"]))
        var before: int=b.troop_force_pages.fired.size()
        var complete_before: int=b.force_actions.completed.size()
        b.advance_atb(1.0/60.0)
        var selected: int=int(step["selected"])
        if selected<0:
            _check(b.troop_force_pages.fired.size()==before and b.force_actions.completed.size()==complete_before,"source no selection")
        else:
            _check(b.troop_force_pages.fired.size()==before+1 and b.troop_force_pages.fired.has(selected),"source selected page %d"%selected)
            _check(b.force_actions.completed.size()==complete_before+1 and bool(b.force_actions.completed[-1]["actor"])==(selected==0),"actual page action executes on correct side")
    _check(bool(b.party[0]["guarding"]) and bool(b.enemies[0]["guarding"]),"both source pages executed")
    _check(b.troop_force_pages.fired.size()==2 and b.force_actions.completed.size()==2,"once per battle")
    # Validate unsupported data before any page is installed.
    var invalid: Array[Dictionary]=[]
    var p=_page(false,1)
    p["span"]=1
    invalid.append(p)
    p=_page(false,1)
    p["condition"]["turn_valid"]=true
    invalid.append(p)
    p=_page(false,1)
    p["condition"]["actor_valid"]=true
    invalid.append(p)
    p=_page(false,1)
    p["condition"]["enemy_valid"]=false
    invalid.append(p)
    p=_page(false,1)
    p["list"][0]["code"]=355
    invalid.append(p)
    p=_page(false,1)
    p["list"][0]["parameters"][2]=1
    invalid.append(p)
    p=_page(false,1)
    p["list"][0]["parameters"][4]=-1
    invalid.append(p)
    p=_page(false,1)
    p["list"][0]["parameters"][1]=-1
    invalid.append(p)
    p=_page(false,1)
    p["condition"]["enemy_hp"]="50"
    invalid.append(p)
    p=_page(false,1)
    p["list"][0]["indent"]=1
    invalid.append(p)
    for item in invalid:
        var candidate=PAGES.new()
        _check(not candidate.configure([p0,item]) and not candidate.enabled and candidate.pages.is_empty(),"invalid page rejects entire configuration")
    # Unknown subject at execution is a reported hold, not a silent no-op.
    var h=_fixture()
    h.force_actions.enabled=true
    _check(h.configure_source_force_pages([_page(false,1,9)]),"structurally valid but unavailable actor")
    h.enemies[0]["hp"]=40
    h.advance_atb(1.0/60.0)
    _check(not h.troop_force_pages.blocked_reason.is_empty() and h.troop_force_pages.fired.is_empty() and h.force_actions.completed.is_empty(),"unavailable actor produces explicit HOLD")
    h.advance_atb(1.0/60.0)
    _check(h.force_actions.completed.is_empty(),"HOLD does not silently resume")
    print("CRAFT_TROOP_PAGE_NATIVE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; ProductionBridgeWired=False; OriginalVXRuntime=False")
    quit(0 if failures==0 else 1)
