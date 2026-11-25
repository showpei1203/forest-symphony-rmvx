extends SceneTree
const DB=preload("res://scripts/FSDatabase.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
var checks:int=0
var failures:int=0
func _initialize()->void:
    call_deferred("_run")
func _check(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failures+=1
        push_error("CRAFT_RESOURCE_FAIL "+label)
func _skill(id:int,scope:int,damage:int,note:String="")->Dictionary:
    return {"id":id,"name":"Test Skill","scope":scope,"occasion":0,"mp_cost":10,
        "note":note,"base_damage":damage,"atk_f":0,"spi_f":0,"plus_state_set":[],
        "minus_state_set":[],"damage_to_mp":false,"absorb_damage":false}
func _run()->void:
    var db=DB.new()
    db.tables={"skills":[null,_skill(1,1,10,"<costo mp:25>"),_skill(2,7,-20),
        _skill(3,9,-20),_skill(4,1,10,"<costo hp:15>")],
        "items":[null,{"id":1,"name":"Potion","scope":7,"occasion":0,"consumable":true,
        "note":"","hp_recovery":100,"hp_recovery_rate":0,"mp_recovery":0,"mp_recovery_rate":0,
        "base_damage":0,"atk_f":0,"spi_f":0,"variance":0,"element_set":[],
        "plus_state_set":[],"minus_state_set":[],"parameter_type":0,"parameter_points":0,"common_event_id":0}],
        "weapons":[null],"armors":[null],"states":[null]}
    var world=WORLD.new()
    world.gain_item("item",1,2)
    var b=BATTLE.new(db,world)
    b.party.append({"id":1,"actor":true,"name":"A","hp":200,"maxhp":500,"mp":100,"maxmp":100,
        "agi":20,"atk":20,"def":4,"spi":5,"states":[],"skills":[1,2,3,4],
        "guarding":false,"equipment":[0,0,0,0,0],"two_swords_style":false})
    b.enemies.append({"id":551,"actor":false,"name":"B","hp":500,"maxhp":1000,"mp":100,"maxmp":100,
        "agi":10,"atk":10,"def":2,"spi":3,"states":[],"guarding":false})
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    _check(b.start(),"start")
    var a:Dictionary=b.party[0]
    var e:Dictionary=b.enemies[0]
    var q=b.force_actions
    q.enabled=true
    _check(b.queue_source_vx339([1,0,1,1,0]),"339 skill accepted")
    _check(int(a["mp"])==100 and int(e["hp"])==500,"no early payment")
    var before_gauge:int=int(a["source_atb_count"])
    var gain:int=int(a["source_atb_gain_per_frame"])
    b.advance_atb(1.0/60.0)
    _check(int(a["mp"])==75 and int(e["hp"])==490,"actual damage and exact custom MP payment")
    _check(q.completed.size()==1 and q.completed[0]["object_id"]==1,"one receipt")
    _check(int(a["source_atb_count"])==before_gauge+gain,"forced skill preserves live frame gauge, not skill recharge")
    b.advance_atb(1.0/60.0)
    _check(int(a["mp"])==75 and int(e["hp"])==490,"no replay")
    _check(b.queue_source_force_action(0,0,"skill",0,2),"enemy heal same side")
    b.advance_atb(1.0/60.0)
    _check(int(e["hp"])==510 and int(e["mp"])==90 and int(a["hp"])==200,"enemy heal target relative to user")
    _check(b.queue_source_force_action(1,0,"item",0,1),"actor item")
    _check(world.amount("item",1)==2 and int(a["hp"])==200,"item no early debit")
    b.advance_atb(1.0/60.0)
    _check(world.amount("item",1)==1 and int(a["hp"])==300,"item effect and debit once")
    _check(not b.queue_source_vx339([1,0,2,1,0]),"339 does not interpret item as skill")
    _check(not b.queue_source_force_action(0,0,"item",0,1),"enemy item unsupported")
    _check(not b.queue_source_force_action(1,0,"skill",0,3),"revive scope remains hold")
    _check(not b.queue_source_force_action(1,0,"skill",0,4),"unknown HP cost refused")
    _check(not b.queue_source_force_action(1,0,"skill",0,999),"missing skill refused")
    _check(b.queue_source_force_action(1,0,"skill",0,1),"stage before MP loss")
    a["mp"]=0
    var before:int=int(e["hp"])
    b.advance_atb(1.0/60.0)
    _check(int(e["hp"])==before and int(a["mp"])==0 and q.ready.is_empty(),"MP revalidated before effects")
    a["mp"]=100
    _check(b.queue_source_force_action(1,0,"skill",0,1),"stage before target loss")
    e["hp"]=0
    b.advance_atb(1.0/60.0)
    _check(int(a["mp"])==100,"lost target no MP debit")
    e["hp"]=500
    _check(b.queue_source_force_action(1,0,"item",0,1),"stage before item loss")
    world.gain_item("item",1,-1)
    b.advance_atb(1.0/60.0)
    _check(int(a["hp"])==300 and world.amount("item",1)==0,"missing item no effect")
    print("CRAFT_FORCE_RESOURCE_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; ForcedBypass=False; OriginalVXRuntime=False")
    quit(0 if failures==0 else 1)
