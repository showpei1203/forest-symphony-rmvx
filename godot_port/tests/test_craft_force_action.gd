extends SceneTree
const DB = preload("res://scripts/FSDatabase.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
var failures: int = 0
var checks: int = 0
func _initialize() -> void:
    call_deferred("_run")
func _check(ok: bool,label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("CRAFT_FORCE_FAIL "+label)
func _fixture():
    var db = DB.new()
    db.tables = {"weapons":[null],"armors":[null],"states":[null]}
    var battle = BATTLE.new(db)
    var actor: Dictionary = {"id":1,"actor":true,"name":"A","hp":500,"maxhp":500,
        "mp":100,"maxmp":100,"agi":20,"atk":20,"def":4,"spi":5,"states":[],
        "guarding":false,"equipment":[0,0,0,0,0],"two_swords_style":false}
    var enemy: Dictionary = {"id":551,"actor":false,"name":"B","hp":1000,"maxhp":1000,
        "mp":0,"maxmp":0,"agi":10,"atk":10,"def":2,"spi":3,"states":[],"guarding":false}
    battle.party.append(actor)
    battle.enemies.append(enemy)
    battle.enemies.append(enemy.duplicate(true))
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0,"enemy:1":0}
    _check(battle.start(),"start")
    return battle
func _names(entries: Array) -> Array:
    var names: Array = []
    for entry in entries:
        names.append(str(entry["subject"]["name"]))
    return names
func _run() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size()!=1:
        quit(2)
        return
    var oracle = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
    if not oracle is Dictionary or not oracle.has("force_schedule"):
        quit(2)
        return
    var b = _fixture()
    var a: Dictionary = b.party[0]
    var e: Dictionary = b.enemies[0]
    var twin: Dictionary = b.enemies[1]
    var q = b.force_actions
    _check(not b.queue_source_force_action(1,0,"guard",0),"disabled by default")
    q.enabled=true
    _check(b.queue_source_force_action(1,0,"attack",0),"event A")
    _check(b.queue_source_force_action(0,0,"guard",0),"event B")
    _check(b.queue_source_force_action(1,0,"guard",0),"duplicate A replaces payload")
    _check(q.drain_event(b)==2 and _names(q.ready)==oracle["force_schedule"]["event_order"],"original #462 FIFO/dedupe")
    _check(q.ready[0]["kind"]=="guard","latest validated action remains on original battler position")
    _check(b.queue_source_vx339([1,0,0,1,0]),"native troop slot")
    _check(not b.queue_source_vx339([0,0,0,0,0]),"do not overwrite unresolved interpreter slot")
    _check(q.prepare_troop(b) and _names(q.ready)==oracle["force_schedule"]["troop_order"],"original #231 promotion")
    _check(q.resolve_one(b,true)==0 and q.ready.size()==2,"active action preserved")
    b.source_atb_wait=true
    _check(q.resolve_one(b)==0 and q.ready.size()==2,"wait gate retained")
    b.source_atb_wait=false
    _check(q.resolve_one(b)==1 and bool(e["guarding"]) and q.ready.size()==1,"forced B executes")
    _check(q.resolve_one(b)==1 and bool(a["guarding"]) and q.ready.is_empty(),"forced A executes")
    _check(q.completed.size()==2,"exactly two receipts")
    # Identical enemy records must not be deduplicated by database ID/value.
    e["guarding"]=false
    twin["guarding"]=false
    _check(b.queue_source_force_action(0,0,"guard",0) and b.queue_source_force_action(0,1,"guard",0),"two duplicate DB IDs")
    _check(q.drain_event(b)==2 and not is_same(q.ready[0]["subject"],q.ready[1]["subject"]),"separate instances")
    twin["hp"]=0
    _check(q.resolve_one(b)==1 and bool(e["guarding"]),"living instance executes")
    _check(q.resolve_one(b)==0 and not bool(twin["guarding"]) and q.ready.is_empty(),"dead instance rejected")
    twin["hp"]=1000
    _check(b.queue_source_force_action(0,1,"guard",0),"stage alive")
    twin["hp"]=0
    _check(q.drain_event(b)==0 and q.staged.is_empty(),"dead before drain")
    twin["hp"]=1000
    _check(b.queue_source_force_action(0,1,"guard",0),"stage removable instance")
    b.enemies.remove_at(1)
    b.enemies.append(twin.duplicate(true))
    _check(q.drain_event(b)==0 and q.ready.is_empty(),"removed instance not replaced by equal record")
    _check(not b.queue_source_vx339([1,-1,0,0,0]) and not b.queue_source_vx339([1,0,1,1,0]) and
        not b.queue_source_vx339([1,0,0,0,-1]) and not b.queue_source_vx339([1,0,0,0,-2]) and
        not b.queue_source_vx339([1,0,0,0,0.5]) and not b.queue_source_vx339(["1",0,0,0,0]),"unverified actions and malformed parameters refuse")
    _check(not b.queue_source_force_action(1,0,"skill",0),"no forced skill without authority")
    # Actual frame dispatcher: forced enemy before ordinary charged actor.
    a["source_at_active"]=true
    a["source_atb_count_up"]=false
    a["source_atb_count"]=1000
    a["atb"]=1.0
    a["guarding"]=false
    _check(b.queue_actor_action(0,"guard"),"normal command queued")
    _check(b.queue_source_vx339([0,0,0,0,0]),"forced enemy attack queued")
    var hp_before: int = int(a["hp"])
    var ordinary_before: int = b.action_queue.completed.size()
    b.advance_atb(1.0/60.0)
    _check(int(a["hp"])<hp_before and b.action_queue.completed.size()==ordinary_before and b.has_actor_pending_action(0),"real forced attack priority over ordinary ACT")
    b.advance_atb(1.0/60.0)
    _check(bool(a["guarding"]) and b.action_queue.completed.size()==ordinary_before+1,"normal command resumes next frame")
    # Forced same-subject guard supersedes only that actor's pending ACT.
    a["source_at_active"]=true
    a["source_atb_count_up"]=false
    a["source_atb_count"]=1000
    a["atb"]=1.0
    _check(b.queue_actor_action(0,"attack",0),"normal attack queued")
    _check(b.queue_source_force_action(1,0,"guard",0),"forced replacement")
    var enemy_before: int = int(e["hp"])
    b.advance_atb(1.0/60.0)
    _check(not b.has_actor_pending_action(0) and int(e["hp"])==enemy_before and bool(a["guarding"]),"superseded attack canceled without effect")
    # No silent target substitution after a target is removed.
    _check(b.queue_source_force_action(1,0,"attack",1),"explicit target selected")
    q.drain_event(b)
    b.enemies.remove_at(1)
    b.enemies.append(twin.duplicate(true))
    _check(q.resolve_one(b)==0 and q.ready.is_empty(),"lost target must not redirect")
    _check(int(e["hp"])==enemy_before,"no unrequested damage")
    # Current command UI cannot be claimed as ported.
    b.pending_actor=0
    _check(b.queue_source_force_action(1,0,"guard",0),"queue during command")
    q.drain_event(b)
    _check(q.resolve_one(b)==0 and q.ready.size()==1,"open command UI holds force")
    b.pending_actor=-1
    _check(q.resolve_one(b)==1,"force resumes once command released")
    b.active=false
    _check(not b.queue_source_force_action(1,0,"guard",0) and q.drain_event(b)==0,"outside battle no action")
    print("CRAFT_FORCE_NATIVE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; RealTroopEventWired=False; OriginalVXRuntime=False")
    quit(0 if failures==0 else 1)
