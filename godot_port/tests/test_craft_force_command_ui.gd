extends SceneTree
const DB=preload("res://scripts/FSDatabase.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
var checks:int=0
var failures:int=0
func _initialize()->void:
    call_deferred("_run")
func _check(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failures+=1
        push_error("CRAFT_COMMAND_FAIL "+label)
func _run()->void:
    var db=DB.new()
    db.tables={"weapons":[null],"armors":[null],"states":[null],"skills":[null],"items":[null]}
    var world=WORLD.new()
    var b=BATTLE.new(db,world)
    for id in [1,2]:
        b.party.append({"id":id,"actor":true,"name":"A%d"%id,"hp":500,"maxhp":500,
            "mp":100,"maxmp":100,"agi":20,"atk":20,"def":4,"spi":5,"states":[],"skills":[],
            "guarding":false,"equipment":[0,0,0,0,0],"two_swords_style":false})
    b.enemies.append({"id":551,"actor":false,"name":"B","hp":1000,"maxhp":1000,
        "mp":0,"maxmp":0,"agi":10,"atk":10,"def":2,"spi":3,"states":[],"guarding":false})
    b.source_atb_rolls_for_test={"actor:0":0,"actor:1":0,"enemy:0":0}
    _check(b.start(),"start")
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=b
    screen.world=world
    root.add_child(screen)
    screen.set_process(false)
    var cancelled:Array[int]=[]
    b.source_command_cancelled.connect(func(i:int)->void:cancelled.append(i))
    b.force_actions.enabled=true
    for unit in b.party:
        unit["source_at_active"]=true
        unit["source_atb_count"]=1000
        unit["source_atb_count_up"]=false
        unit["atb"]=1.0
    screen.actor_index=0
    screen._player_attack()
    _check(b.pending_actor==0 and b.source_atb_wait and screen.source_target_help!=null,"real attack target page owns wait")
    var stale:Button=null
    for child in screen.body.get_children():
        if child is Button and child.text.begins_with("B HP"):
            stale=child
    _check(stale!=null,"real target button exists")
    _check(b.queue_source_vx339([1,1,0,1,0]),"different actor troop force")
    b.advance_atb(1.0/60.0)
    _check(cancelled.is_empty() and b.pending_actor==0 and b.source_atb_wait and screen.source_target_help!=null,
        "different actor preserves commander page")
    # Release the other actor's held force explicitly and reopen selection.
    screen._show_battle()
    b.advance_atb(1.0/60.0)
    _check(bool(b.party[1]["guarding"]),"held other actor executes after release")
    screen._player_attack()
    for child in screen.body.get_children():
        if child is Button and child.text.begins_with("B HP"):
            stale=child
    _check(b.queue_source_vx339([1,0,0,1,0]),"same commander troop force")
    b.advance_atb(1.0/60.0)
    _check(cancelled==[0] and b.pending_actor==-1 and not b.source_atb_wait and
        screen.source_target_help==null and bool(b.party[0]["guarding"]),"same commander cleanup and action")
    var previous:int=b.action_queue.pending.size()
    if is_instance_valid(stale):
        stale.pressed.emit()
    _check(b.action_queue.pending.size()==previous and not b.has_actor_pending_action(0),"detached target callback inert")
    b.party[0]["source_at_active"]=true
    b.party[0]["source_atb_count"]=1000
    b.party[0]["source_atb_count_up"]=false
    screen._skill_action()
    _check(b.pending_actor==0 and b.source_atb_wait,"skill window owns commander")
    _check(b.queue_source_vx339([1,0,0,1,0]),"force during skill list")
    b.advance_atb(1.0/60.0)
    _check(cancelled==[0,0] and b.pending_actor==-1 and not b.source_atb_wait,"skill list closed by force")
    screen._item_action()
    _check(b.pending_actor==0 and b.source_atb_wait,"item window owns commander")
    _check(b.queue_source_vx339([1,0,0,1,0]),"force during item list")
    b.advance_atb(1.0/60.0)
    _check(cancelled==[0,0,0] and b.pending_actor==-1 and not b.source_atb_wait,"item list closed by force")
    screen.queue_free()
    print("CRAFT_COMMAND_UI_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; ActualScreen=True; FullVXRuntime=False")
    quit(0 if failures==0 else 1)
