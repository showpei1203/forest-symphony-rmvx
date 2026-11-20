extends SceneTree
const PRESENTER=preload("res://scripts/ui/FSBattleActor01Presenter.gd")
const RIG=preload("res://scripts/animation/FSTAActorMotionRig.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
func _initialize()->void:
    call_deferred("_run")
func check(ok:bool,why:String)->bool:
    if not ok:
        push_error("P537B original Actor01 visual/native fail: "+why)
        quit(1)
        return false
    return true
func synthetic_atlas()->Texture2D:
    var img=Image.create(256,192,false,Image.FORMAT_RGBA8)
    img.fill(Color.TRANSPARENT)
    for y in range(3):
        for x in range(4):
            img.set_pixel(x*64+30,y*64+30,Color(0.5,0.2+float(x+y)*0.05,0.8))
    return ImageTexture.create_from_image(img)
func _run()->void:
    var visual=PRESENTER.new()
    root.add_child(visual)
    if not check(not visual.private_source_ready and not visual.visible and visual.rig!=null,
            "public GitHub must not claim owner-only A52 att PNG is installed"):return
    if not check(visual.rig.layers().size()==3 and visual.rig.FRAME_COUNT==12 and (
            visual.rig.ATTACK_CONTACT_SEC==0.630), "T-A 3-layer 12-frame source timing lost"):return
    var atlas=synthetic_atlas()
    if not check(visual.rig.configure_attack_only(atlas,atlas,atlas),
            "isolated Godot motion rig fixture cannot configure"):return
    visual.private_source_ready=true # Test-only fixture, no private source claim.
    var db=DATA.database()
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_enemy(1)
    battle.start()
    # Seed the existing source queue only through real validated ATB.
    battle.advance_atb(2.0)
    if not check(battle.ready_actors().has(0), "source ATB did not become ready"):return
    if not check(battle.queue_actor_action(0,"attack",0), "valid ACT queue refused"):return
    var hp_before:int=int(battle.enemies[0]["hp"])
    var mp_before:int=int(battle.party[0]["mp"])
    visual.sync_from_battle(battle)
    if not check(visual.visual_attack_count==1 and visual.rig.playing and (
            visual.rig.motion=="attack"),"real queued actor action did not trigger visual"):return
    visual.sync_from_battle(battle)
    if not check(visual.visual_attack_count==1,"presentation duplicate replayed same serial"):return
    visual.rig.advance_seconds(0.63)
    if not check(visual.contact_count==1 and visual.rig.frame_index==7 and (
            int(battle.enemies[0]["hp"])==hp_before) and (
            int(battle.party[0]["mp"])==mp_before),
            "A52 contact must be one-shot and VISUAL ONLY; no early damage/cost"):return
    visual.rig.advance_seconds(0.43)
    if not check(not visual.rig.playing and not visual.visible and visual.contact_count==1,
            "A52 finish must hide final pose after 1.06s and one contact"):return
    visual.cancel_visual()
    if not check(not visual.visible and not visual.rig.playing,
            "visual cancel must not mutate combat state"):return
    print("P537B Godot 4.7.2 real ACT queue -> A52 12-frame source rig -> F7/0.63 presentation contact, no early HP/MP mutation PASS (synthetic texture fixture; ART HOLD)")
    quit(0)
