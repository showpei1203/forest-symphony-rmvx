extends SceneTree
# Synthetic three-layer texture is ONLY a native timing fixture, never ART PASS.
const DB=preload("res://scripts/FSDatabase.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const PRESENTER=preload("res://scripts/ui/FSBattleActor01Presenter.gd")
var checks:int=0
var failures:int=0
func _initialize()->void:
    call_deferred("_run")
func _check(ok:bool,label:String)->void:
    checks+=1
    if not ok:
        failures+=1
        push_error("CRAFT_VISUAL_FAIL "+label)
func _fixture():
    var db=DB.new()
    db.tables={"weapons":[null],"armors":[null],"states":[null]}
    var b=BATTLE.new(db)
    b.party.append({"id":1,"actor":true,"name":"A","hp":500,"maxhp":500,
        "mp":100,"maxmp":100,"agi":20,"atk":20,"def":4,"spi":5,"states":[],
        "guarding":false,"equipment":[0,0,0,0,0],"two_swords_style":false})
    b.enemies.append({"id":551,"actor":false,"name":"B","hp":1000,"maxhp":1000,
        "mp":0,"maxmp":0,"agi":10,"atk":10,"def":2,"spi":3,"states":[],"guarding":false})
    b.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    _check(b.start(),"battle starts")
    b.force_actions.enabled=true
    return b
func _ready_actor(b)->void:
    b.party[0]["source_at_active"]=true
    b.party[0]["source_atb_count_up"]=false
    b.party[0]["source_atb_count"]=1000
    b.party[0]["atb"]=1.0
func _run()->void:
    var p=PRESENTER.new()
    root.add_child(p)
    var image=Image.create(256,192,false,Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)
    var tex=ImageTexture.create_from_image(image)
    _check(p.rig.configure_attack_only(tex,tex,tex),"synthetic atlas config")
    p.private_source_ready=true # fixture only; never production source proof
    p.rig.set_process(false)
    var b=_fixture()
    _ready_actor(b)
    _check(b.queue_actor_action(0,"attack",0),"normal attack pending")
    p.sync_from_battle(b)
    _check(p.rig.playing and p.visible and p.visual_attack_count==1,"real rig starts one visual")
    p.rig.advance_seconds(0.30)
    var before:int=int(b.enemies[0]["hp"])
    _check(b.queue_source_vx339([1,0,0,1,0]),"force guard supersedes attack")
    b.advance_atb(1.0/60.0)
    p.sync_from_battle(b)
    _check(not p.rig.playing and not p.visible and not b.has_actor_pending_action(0),"force replacement cancels actual rig")
    p.rig.advance_seconds(2.0)
    _check(p.contact_count==0 and int(b.enemies[0]["hp"])==before,"canceled rig cannot emit contact or damage")
    _ready_actor(b)
    _check(b.queue_actor_action(0,"attack",0),"second attack")
    p.sync_from_battle(b)
    _check(p.rig.playing and p.visual_attack_count==2,"new serial plays")
    b.party[0]["source_act_count"]=1000
    b.party[0]["source_act_active"]=true
    b.party[0]["source_at_active"]=false
    b.party[0]["source_atb_count_up"]=false
    b.advance_atb(1.0/60.0)
    p.sync_from_battle(b)
    _check(b.action_queue.completed.size()==1 and bool(b.action_queue.completed[0]["success"]) and p.rig.playing,
        "successful normal ACT can finish presentation")
    var hp_after:int=int(b.enemies[0]["hp"])
    p.rig.advance_seconds(2.0)
    _check(p.contact_count==1 and not p.visible and not p.rig.playing and int(b.enemies[0]["hp"])==hp_after,
        "visual contact independent of gameplay")
    p.sync_from_battle(b)
    _check(p.visual_attack_count==2,"completed action not replayed")
    var fresh=_fixture()
    _ready_actor(fresh)
    _check(fresh.queue_actor_action(0,"attack",0),"fresh battle serial")
    p.sync_from_battle(fresh)
    _check(p.rig.playing and p.visual_attack_count==3 and p.last_attack_serial==1,"serial namespace resets per battle")
    fresh.party[0]["source_atb_count_up"]=true
    fresh.action_queue.cancel_interrupted(fresh)
    p.sync_from_battle(fresh)
    _check(not p.visible and not p.rig.playing,"ordinary interruption cancels rig")
    p.rig.advance_seconds(2.0)
    _check(p.contact_count==1,"interrupted visual cannot contact")
    p.queue_free()
    print("CRAFT_FORCE_VISUAL_SUMMARY; Checks="+str(checks)+"; Failures="+str(failures)+"; SyntheticArt=True; GameplayTimingParity=False")
    quit(0 if failures==0 else 1)
