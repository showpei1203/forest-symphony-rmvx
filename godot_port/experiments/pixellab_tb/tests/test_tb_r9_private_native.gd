# R9 standalone PRIVATE art QA bridge fixture (no FSBattle source bundles).
extends SceneTree
const PRESENTER=preload("res://experiments/pixellab_tb/FS_TBMonsterBattlePresentation.gd")
class BattleStub extends RefCounted:
    var enemies: Array[Dictionary]=[]
    var action_queue: Dictionary={"completed":[]}
func _initialize()->void:call_deferred("_test")
func check(condition:bool,why:String)->bool:
    if not condition:push_error("TB_R9_FAIL: "+why);quit(1);return false
    return true
func _test()->void:
    var visual:=PRESENTER.new()
    root.add_child(visual)
    await process_frame
    if not check(visual._is_ready,"private SHA and atlas accepted"):return
    var b:=BattleStub.new()
    b.enemies=[{"name":"TB02 Leaf Bat","fs_monster_visual_id":"TB02_LEAF_BAT","hp":500,"mp":100}]
    var events: Array[String]=[]
    var points: Array[Vector2]=[]
    visual.visual_attack_started.connect(func(k:String):events.append("START:"+k))
    visual.visual_hit_cue.connect(func(k:String,p:Vector2):events.append("F5:"+k);points.append(p))
    visual.visual_attack_finished.connect(func(k:String):events.append("DONE:"+k))
    if not check(visual.bind_battle(b,0),"explicit monster authorizes stage"):return
    b.action_queue.completed.append({"serial":31,"side":"actor","kind":"attack","success":true})
    b.action_queue.completed.append({"serial":32,"side":"enemy","enemy_index":0,"kind":"skill","success":true})
    b.action_queue.completed.append({"serial":33,"side":"enemy","enemy_index":0,"kind":"attack","success":false})
    visual.read_completed_actions()
    if not check(events.is_empty(),"do not animate wrong/failing actions"):return
    b.action_queue.completed.append({"serial":34,"side":"enemy","enemy_index":0,"kind":"attack","success":true})
    visual.read_completed_actions(); visual.read_completed_actions()
    if not check(events==["START:enemy:0:34"],"visual starts exactly once"):return
    visual._attack.advance_seconds(0.11)
    if not check(events.size()==1,"no premature F5 cue"):return
    visual._attack.advance_seconds(1.0)
    if not check(events==["START:enemy:0:34","F5:enemy:0:34","DONE:enemy:0:34"],"frame skip F5 once"):return
    if not check(points.size()==1 and points[0]==visual._attack.to_global(Vector2(14,0)),"mouth anchor is source-defined"):return
    if not check(b.enemies[0]["hp"]==500 and b.enemies[0]["mp"]==100,"VFX no combat mutation"):return
    visual.read_completed_actions()
    if not check(events.size()==3,"cannot replay same receipt"):return
    b.action_queue.completed.append({"serial":35,"side":"enemy","enemy_index":0,"kind":"attack","success":true})
    visual.read_completed_actions()
    visual._attack.advance_seconds(1.0)
    if not check(events.size()==6,"different action serial plays separately"):return
    visual.unbind_battle()
    var untagged:=BattleStub.new()
    untagged.enemies=[{"name":"TB02 Leaf Bat","hp":500}]
    if not check(not visual.bind_battle(untagged,0),"name-only source refused"):return
    print("TB_R9_PRIVATE_GODOT_472_PASS real_R8_sha=LOCKED visual_F5_twice_for_two_actions HPMP_unchanged tag_failclosed")
    quit(0)
