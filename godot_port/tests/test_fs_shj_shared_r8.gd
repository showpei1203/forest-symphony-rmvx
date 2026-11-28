extends SceneTree
const SLICE=preload("res://scripts/story/FSShjSharedFixtureSlice.gd")
const HUD=preload("res://scripts/ui/FSBattleSourceStateHUD381.gd")
var cases:int=0

func _initialize() -> void:
    call_deferred("_run")

func check(ok:bool,why:String) -> bool:
    if not ok:
        push_error("FS_SHJ_R8_FAIL: "+why)
        quit(1)
        return false
    cases+=1
    return true

func _button(fragment:String,container:Node)->Button:
    for child in container.get_children():
        if child is Button and fragment in child.text:
            return child
    return null

func _run() -> void:
    for stage_index in range(1,4):
        if not await run_stage(stage_index):return
    print("FS_SHJ_R8_ALL_STAGES_PASS cases=",cases," engine=",Engine.get_version_info().string)
    quit(0)

func run_stage(stage_index:int)->bool:
    var shared:=load("res://family/s%d/SpriteFrames.tres" % stage_index) as SpriteFrames
    if not check(shared!=null and shared.get_animation_names().size()==3,"candidate resource loaded"):return false
    var slice:=SLICE.new()
    slice.approved_frames=shared
    root.add_child(slice)
    await process_frame
    if not check(slice.installed and slice.map_body.sprite_frames==shared and slice.map_body.visible,"real map event shared art"):return false
    if not check(slice.map_body.position==Vector2(304,188) and slice.map_body.scale==Vector2.ONE and slice.map_body.offset.y==[ -7, -10, -11 ][stage_index-1],"map native-scale stable marker"):return false
    if not check(slice.map_body.start_motion(&"Walk") and slice.map_body.animation==&"walk" and not slice.map_body.start_motion(&"Faint"),"explicit map motion and reject unmapped action"):return false
    slice.map_body.start_motion(&"Idle")
    for i in range(3):
        slice.move_one_tile(Vector2i.RIGHT)
    if not check(slice.player==Vector2i(8,5) and not slice.move_one_tile(Vector2i.RIGHT),"unchanged sentinel collision"):return false
    var result:Dictionary=slice.interact_front()
    if not check(bool(result.get("ok",false)) and slice.dialogue._mode=="message","real VX message"):return false
    slice.dialogue.advance_message()
    await process_frame
    await process_frame
    if not check(slice.battle!=null and slice.battle.active and slice.pmd_stage!=null and not slice.map_body.visible,"actual VX301 -> battle with shared preview"):return false
    var battle:FSBattle=slice.battle
    var ui=slice.battle_view
    var stage=slice.pmd_stage
    if not check(is_instance_valid(stage.fixture_body) and stage.fixture_body.sprite_frames==shared and stage.fixture_body.sprite_frames==slice.map_body.sprite_frames,"same resource identity through map/battle"):return false
    # Invalid candidate and duplicate install must not replace or restart the active stage.
    var bad:=SpriteFrames.new()
    if not check(not ui.configure_shj_fixture_candidate(bad) and ui.enemy_stage==stage,"invalid candidate retains installed stage"):return false
    var starts:int=stage.fixture_body.started_count
    if not check(ui.configure_shj_fixture_candidate(shared) and ui.enemy_stage==stage and stage.fixture_body.started_count==starts,"duplicate opt-in is idempotent"):return false
    var foreign:=shared.duplicate() as SpriteFrames
    if not check(not ui.configure_shj_fixture_candidate(foreign) and ui.enemy_stage==stage,"reject identity swap during battle"):return false
    var body=stage.fixture_body
    var image:Control=stage.enemy_views[0]["image"]
    if not check(body.scale==Vector2.ONE and body.offset==slice.map_body.offset and body.global_position.is_equal_approx(HUD.enemy_anchor_from_rect(image.get_global_rect())),"battle native-scale marker at existing HUD feet anchor"):return false
    if not check(not bool(slice.save_checkpoint().get("ok",false)) and not slice.move_one_tile(Vector2i.DOWN),"unchanged mid-battle blocking"):return false
    var before:int=stage.played_outcomes
    var dmg:int=battle.attack(battle.enemies[0],battle.party[0])
    if not check(dmg==20 and int(battle.party[0]["hp"])==100 and stage.played_outcomes==before+1 and body.animation==&"attack","actual enemy attack emits one presentation outcome"):return false
    battle.changed.emit("refresh only")
    if not check(stage.played_outcomes==before+1,"UI refresh does not replay action"):return false
    # Actual Godot playback at fixed 60 fps, not manually setting frames.
    var frame5_seen:bool=false
    var frame6_seen:bool=false
    var base:Vector2=body.global_position
    for i in range(90):
        await process_frame
        if not is_instance_valid(body):break
        if body.animation==&"attack" and body.frame==5:frame5_seen=true
        if body.animation==&"attack" and body.frame==6:frame6_seen=true
        if not body.global_position.is_equal_approx(base):
            if not check(false,"presentation never moves game slot"):return false
        if body.animation==&"idle":break
    if not check(frame5_seen and frame6_seen and body.animation==&"idle" and body.finished_count==1,"actual Attack plays frames 5 and 6 and returns Idle"):return false
    # Map and battle fixture never mutate HP, ACT timing, or rewards.
    ui._process(2.0)
    if not check(battle.ready_actors().has(0),"real ACT readiness"):return false
    ui._player_attack()
    var enemy_button:Button=_button("測試木靈",ui.body)
    if not check(enemy_button!=null and battle.source_atb_wait,"real target selection"):return false
    enemy_button.pressed.emit()
    if not check(battle.has_actor_pending_action(0) and int(battle.enemies[0]["hp"])==48,"queued action no early damage"):return false
    ui._process(1.0/60.0)
    if not check(not battle.active and slice.world.switch_on(10) and slice.world.gold==50 and slice.battles_completed==1,"ACT victory and one reward"):return false
    await process_frame
    await process_frame
    if not check(slice.battle_overlay==null and not slice.map_body.visible and slice.dialogue._mode=="message","return map after victory with event body hidden"):return false
    slice.dialogue.advance_message()
    if not check(not slice.story.runner.active and slice.world.gold==50,"unchanged VX601 continuation"):return false
    slice.interact_front()
    slice.dialogue.advance_message()
    if not check(slice.world.gold==50 and slice.battle_overlay==null,"no repeat battle or reward"):return false
    slice.queue_free()
    await process_frame
    print("FS_SHJ_R8_STAGE_PASS stage=",stage_index," cumulative_cases=",cases)
    return true
