extends SceneTree
const SLICE=preload("res://scripts/story/FSPlayableSlice.gd")
func _initialize()->void:
    call_deferred("_run")
func _run()->void:
    var s:=SLICE.new()
    root.add_child(s)
    await process_frame
    for i in range(3):s.move_one_tile(Vector2i.RIGHT)
    assert(bool(s.interact_front().get("ok",false)))
    s.dialogue.advance_message()
    await process_frame
    await process_frame
    assert(s.battle!=null and s.battle.active)
    var ui=s.battle_view
    var original=ui.enemy_stage
    assert(original.get_script()==load("res://scripts/ui/FSBattleOriginalEnemyStage.gd"))
    assert(not ui.configure_shj_fixture_candidate(null) and ui.enemy_stage==original)
    assert(not ui.configure_shj_fixture_candidate(SpriteFrames.new()) and ui.enemy_stage==original)
    var shared:=load("res://family/s1/SpriteFrames.tres") as SpriteFrames
    s.battle.db.boot_final_verified=true
    assert(not ui.configure_shj_fixture_candidate(shared) and ui.enemy_stage==original)
    s.battle.db.boot_final_verified=false
    assert(s.battle.attack(s.battle.enemies[0],s.battle.party[0])==20)
    assert(ui.enemy_stage==original)
    print("FS_SHJ_R8_DEFAULT_GUARD_PASS cases=5")
    s.queue_free()
    await process_frame
    quit(0)
