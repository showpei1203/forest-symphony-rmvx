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
    p["list"][0]["parameters"][2]=2
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
    # A real fixed-target skill page, with a pending receipt and a second
    # unrelated queued action. The second action must not be mistaken for
    # the page acknowledgment or be required to settle it.
    var s=_fixture()
    s.db.tables["skills"]=[null,{"id":1,"name":"Probe","scope":1,"occasion":0,
        "mp_cost":10,"note":"<costo mp:25>","base_damage":10,"atk_f":0,"spi_f":0,
        "plus_state_set":[],"minus_state_set":[],"damage_to_mp":false,"absorb_damage":false}]
    s.party[0]["skills"]=[1]
    s.force_actions.enabled=true
    var skill_page=_page(false,1)
    skill_page["list"][0]["parameters"]=[1,0,1,1,0]
    _check(s.configure_source_force_pages([skill_page]),"339 fixed skill page accepted")
    s.enemies[0]["hp"]=40
    s.source_atb_wait=true
    s.advance_atb(1.0/60.0)
    _check(s.troop_force_pages.pending_page==0 and s.troop_force_pages.fired.is_empty() and
        int(s.party[0]["mp"])==100 and s.force_actions.completed.is_empty(),"page pending not falsely completed")
    _check(not s.queue_source_force_action(1,0,"guard",0),"pending page cannot be overwritten")
    _check(s.queue_source_force_action(0,0,"guard",0),"unrelated event can queue")
    s.source_atb_wait=false
    s.advance_atb(1.0/60.0)
    _check(s.troop_force_pages.fired.has(0) and s.troop_force_pages.pending_page==-1 and
        int(s.party[0]["mp"])==75 and int(s.enemies[0]["hp"])==30,"actual page skill settles and pays")
    _check(s.force_actions.completed.size()==1 and s.force_actions.completed[0]["page_ticket"]==0 and
        s.force_actions.ready.size()==1,"ticket matches before unrelated queue drains")
    s.advance_atb(1.0/60.0)
    _check(s.force_actions.completed.size()==2 and not s.force_actions.completed[1].has("page_ticket") and
        bool(s.enemies[0]["guarding"]),"unrelated event runs next frame")
    s.advance_atb(1.0/60.0)
    _check(int(s.party[0]["mp"])==75 and int(s.enemies[0]["hp"])==30,"page exactly once")
    # Resource changes between staging and execution must not consume the
    # page or resume normal battle as though its command succeeded.
    var f=_fixture()
    f.db.tables["skills"]=s.db.tables["skills"].duplicate(true)
    f.party[0]["skills"]=[1]
    f.force_actions.enabled=true
    _check(f.configure_source_force_pages([skill_page]),"late-loss fixture config")
    f.enemies[0]["hp"]=40
    f.source_atb_wait=true
    f.advance_atb(1.0/60.0)
    f.party[0]["mp"]=0
    _check(f.queue_source_force_action(0,0,"guard",0),"unrelated action queued behind failing page")
    f.source_atb_wait=false
    f.advance_atb(1.0/60.0)
    _check(f.troop_force_pages.fired.is_empty() and not f.troop_force_pages.blocked_reason.is_empty() and
        int(f.enemies[0]["hp"])==40 and int(f.party[0]["mp"])==0,"late MP failure explicit hold")
    _check(f.force_actions.completed.size()==1 and not bool(f.force_actions.completed[0]["success"]) and
        f.force_actions.completed[0]["page_ticket"]==0,"failure retains correct ticket")
    _check(not bool(f.enemies[0]["guarding"]) and f.force_actions.ready.size()==1,
        "failed page stops before unrelated action")
    f.party[0]["source_atb_gain_per_frame"]=10
    var stopped_count:int=int(f.party[0]["source_atb_count"])
    f.advance_atb(1.0)
    _check(int(f.party[0]["source_atb_count"])==stopped_count,"blocked event freezes further ATB")
    # Structural skill support is not authorization to execute any effects.
    var u=_fixture()
    u.db.tables["skills"]=s.db.tables["skills"].duplicate(true)
    u.db.tables["skills"][1]["plus_state_set"]=[4]
    u.party[0]["skills"]=[1]
    u.force_actions.enabled=true
    _check(u.configure_source_force_pages([skill_page]),"structural skill page")
    u.enemies[0]["hp"]=40
    u.advance_atb(1.0/60.0)
    _check(u.troop_force_pages.fired.is_empty() and not u.troop_force_pages.blocked_reason.is_empty() and
        int(u.party[0]["mp"])==100 and int(u.enemies[0]["hp"])==40,"unported effect refuses without payment")
    # A lethal skill emits the story-facing finished signal only after
    # its own page receipt has been recorded and acknowledged.
    var lethal=_fixture()
    lethal.db.tables["skills"]=s.db.tables["skills"].duplicate(true)
    lethal.party[0]["skills"]=[1]
    lethal.force_actions.enabled=true
    _check(lethal.configure_source_force_pages([skill_page]),"lethal skill page")
    var outcomes:Array=[]
    lethal.finished.connect(func(victory:bool)->void:
        outcomes.append({"victory":victory,"fired":lethal.troop_force_pages.fired.has(0),
            "receipts":lethal.force_actions.completed.size(),"busy":lethal.force_actions.busy}))
    lethal.enemies[0]["hp"]=5
    lethal.advance_atb(1.0/60.0)
    _check(outcomes.size()==1 and outcomes[0]=={"victory":true,"fired":true,"receipts":1,"busy":false},
        "victory emitted after exact page settlement")
    _check(not lethal.active and int(lethal.party[0]["mp"])==75,"lethal skill pays exactly once")
    lethal.advance_atb(1.0)
    _check(outcomes.size()==1,"no repeated victory")
    print("CRAFT_TROOP_PAGE_NATIVE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; ProductionBridgeWired=False; OriginalVXRuntime=False")
    quit(0 if failures==0 else 1)
