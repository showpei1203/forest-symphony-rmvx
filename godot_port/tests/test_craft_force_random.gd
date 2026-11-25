extends SceneTree
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
        push_error("CRAFT_RANDOM_FAIL "+label)
func _member(actor:bool,id:int)->Dictionary:
    return {"id":id,"actor":actor,"name":"Probe","hp":100,"maxhp":100,
        "mp":100,"maxmp":100,"agi":10,"atk":10,"def":2,"spi":3,"states":[],
        "skills":[1,2],"odds":1,"note":"","guarding":false,
        "equipment":[0,0,0,0,0],"two_swords_style":false}
func _fixture(rows:Array,actor_targets:bool):
    var db=DB.new()
    db.tables={"weapons":[null],"armors":[null],"states":[null],
        "skills":[null,{"id":1,"name":"Probe","scope":1,"occasion":0,"mp_cost":10,
            "note":"","base_damage":10,"atk_f":0,"spi_f":0,"plus_state_set":[],
            "minus_state_set":[],"damage_to_mp":false,"absorb_damage":false},
        {"id":2,"name":"Heal","scope":7,"occasion":0,"mp_cost":10,
            "note":"","base_damage":-10,"atk_f":0,"spi_f":0,"plus_state_set":[],
            "minus_state_set":[],"damage_to_mp":false,"absorb_damage":false}]}
    var b=BATTLE.new(db)
    var targets:Array[Dictionary]=[]
    for row:Dictionary in rows:
        var member:Dictionary=_member(actor_targets,1 if actor_targets else 551)
        member["hp"]=int(row["hp"])
        member["hidden"]=bool(row["hidden"])
        member["odds"]=int(row["odds"])
        member["note"]=str(row["note"])
        member["states"]=[14] if bool(row["provoke"]) else []
        member["fs_disappear"]=bool(row["disappear"])
        targets.append(member)
    if actor_targets:
        b.party.assign(targets)
        b.enemies.append(_member(false,551))
    else:
        b.enemies.assign(targets)
        b.party.append(_member(true,1))
    _check(b.start(),"fixture starts")
    for unit:Dictionary in b.party+b.enemies:
        unit["source_atb_gain_per_frame"]=0
        unit["source_atb_count"]=0
        unit["source_atb_count_up"]=true
        unit["source_at_active"]=false
        unit["source_act_active"]=false
    b.force_actions.enabled=true
    return b
func _run()->void:
    var args=OS.get_cmdline_user_args()
    if args.size()!=1:
        quit(2)
        return
    var oracle=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
    if not oracle is Dictionary or oracle.get("random_cases",[]).size()!=10:
        quit(2)
        return
    var matched:int=0
    for row:Dictionary in oracle["random_cases"]:
        var actor_targets:bool=bool(row["members"][0]["actor"])
        var b=_fixture(row["members"],actor_targets)
        var q=b.force_actions
        var rng=b.action_queue.ai_rng
        rng.enable_test(int(row["seed"]))
        var params:Array=[0 if actor_targets else 1,0,1,1,-1]
        _check(not b.queue_source_vx339(params) and rng.count==0,"random disabled by default")
        q.random_targets_enabled=true
        var result:bool=b.queue_source_vx339(params)
        var selected:int=-1
        if result:
            var group:Array=b.party if actor_targets else b.enemies
            for i in range(group.size()):
                if is_same(group[i],q.troop_slot["target"]):
                    selected=i
                    break
        var trace_equal:bool=rng.trace.size()==row["trace"].size()
        if trace_equal:
            for i in range(rng.trace.size()):
                var actual:Dictionary=rng.trace[i]
                var expected:Dictionary=row["trace"][i]
                trace_equal=trace_equal and int(actual["count"])==int(expected["count"]) and (
                    str(actual["tag"])==str(expected["tag"])) and (
                    int(actual["maximum"])==int(expected["maximum"])) and (
                    int(actual["value"])==int(expected["value"]))
        var equal:bool=selected==int(row["selected"]) and trace_equal and result==(selected>=0)
        _check(equal,"source target and exact RNG trace "+str(row["id"]))
        if equal:
            matched+=1
        print("CRAFT_RANDOM_CASE; ID="+str(row["id"])+"; Source="+str(row["selected"])+"; Godot="+str(selected)+"; Draws="+str(rng.count))
        if selected>=0:
            var target:Dictionary=q.troop_slot["target"]
            var subject:Dictionary=q.troop_slot["subject"]
            var hp_before:int=int(target["hp"])
            var mp_before:int=int(subject["mp"])
            var draws:int=rng.count
            b.advance_atb(1.0/60.0)
            _check(int(target["hp"])==hp_before-10 and int(subject["mp"])==mp_before-10 and (
                q.completed.size()==1 and q.completed[0]["target_mode"]=="random") and rng.count==draws,
                "actual settlement uses selected identity, no target redraw")
    var base:Array=oracle["random_cases"][0]["members"]
    var late=_fixture(base,false)
    late.force_actions.random_targets_enabled=true
    late.action_queue.ai_rng.enable_test(47)
    _check(late.queue_source_force_action(1,0,"skill",-1,1),"event API random target")
    var selected_target:Dictionary=late.force_actions.staged[0]["target"]
    selected_target["hp"]=0
    var before:int=late.action_queue.ai_rng.count
    late.advance_atb(1.0/60.0)
    _check(int(late.party[0]["mp"])==100 and late.action_queue.ai_rng.count==before and (
        late.force_actions.completed.size()==1 and not late.force_actions.completed[0]["success"]),
        "lost selected identity never rerolls or pays")
    var h=_fixture(base,false)
    h.force_actions.random_targets_enabled=true
    h.action_queue.ai_rng.enable_test(47)
    h.enemies[0]["fs_target_unverified"]=true
    _check(not h.queue_source_vx339([1,0,1,1,-1]) and h.action_queue.ai_rng.count==0,"unknown target authority refuses without draw")
    h.enemies[0].erase("fs_target_unverified")
    h.enemies[0]["friendly"]=true
    _check(not h.queue_source_vx339([1,0,1,1,-1]) and h.action_queue.ai_rng.count==0,"friendly target override remains HOLD")
    h.enemies[0].erase("friendly")
    h.party[0]["mp"]=0
    _check(not h.queue_source_vx339([1,0,1,1,-1]) and h.action_queue.ai_rng.count==0,"unpayable skill refuses before draw")
    h.party[0]["mp"]=100
    _check(not h.queue_source_vx339([1,0,1,1,-2]) and h.action_queue.ai_rng.count==0,"last target action-index authority remains HOLD")
    print("CRAFT_FORCE_RANDOM_SUMMARY; Checks="+str(checks)+"; OracleMatches="+str(matched)+"; Failures="+str(failures)+"; FullVXRuntime=False")
    quit(0 if failures==0 and matched==10 else 1)
