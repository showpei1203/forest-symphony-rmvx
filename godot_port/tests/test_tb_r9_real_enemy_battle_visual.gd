extends SceneTree
# Actual FS source-shaped FSBattle + FSActionQueue against synthetic atlas.
# Synthetic texture is intentional: real R8 private PNG has separate native QA.
const DB = preload("res://scripts/FSDatabase.gd")
const WORLD = preload("res://scripts/FSGameState.gd")
const BATTLE = preload("res://scripts/FSBattle.gd")
const PRESENTER = preload("res://experiments/pixellab_tb/FS_TBMonsterBattlePresentation.gd")

func _initialize() -> void:
    call_deferred("_run")

func verify(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("FS_TB_R9_REAL_QUEUE_FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var db: FSDatabase = DB.new()
    db.tables = {"skills":[null],"weapons":[null],"armors":[null]}
    var battle: FSBattle = BATTLE.new(db, WORLD.new())
    battle.party.append({"id":1,"actor":true,"name":"Source Hero",
        "hp":500,"maxhp":500,"agi":10,"def":5,"atk":10,"spi":3,
        "mp":50,"maxmp":50,"equipment":[0,0,0,0,0],
        "two_swords_style":false,"odds":4,"states":[],"note":""})
    battle.enemies.append({"id":1,"actor":false,"name":"Source Enemy",
        "fs_monster_visual_id":"TB02_LEAF_BAT", "hp":300,"maxhp":300,
        "mp":50,"maxmp":50,"atk":20,"def":5,"spi":8,"agi":20,
        "note":"","states":[],"actions":[{"kind":0,"basic":0,
        "skill_id":0,"rating":8,"condition_type":0,
        "condition_param1":0,"condition_param2":0}],"atb":0.0})
    battle.source_atb_rolls_for_test = {"actor:0":0,"enemy:0":0}
    battle.action_queue.ai_rng.enable_test(12345)
    var presenter: Node2D = PRESENTER.new()
    presenter.allow_synthetic_qa_art = true
    root.add_child(presenter)
    await process_frame
    if not verify(presenter._is_ready,"all synthetic sprite sheets imported"):return
    if not verify(presenter.bind_battle(battle,0),"explicit TB02 monster tag"):return
    var start_events: Array[String] = []
    var hit_events: Array[String] = []
    var complete_events: Array[String] = []
    presenter.visual_attack_started.connect(func(k:String):start_events.append(k))
    presenter.visual_hit_cue.connect(func(k:String,_p:Vector2):hit_events.append(k))
    presenter.visual_attack_finished.connect(func(k:String):complete_events.append(k))
    if not verify(battle.start(),"actual FSBattle begins"):return
    battle.advance_atb(90.0/60.0)
    if not verify(battle.action_queue.enemy_pending.size()==1 and int(
            battle.party[0]["hp"])==500,"actual ATB enemy queued ACT without damage"):return
    presenter.read_completed_actions()
    if not verify(start_events.is_empty(),"no animation on ACT preparation alone"):return
    battle.advance_atb(1.0/60.0)
    if not verify(int(battle.party[0]["hp"])==430 and (
            battle.action_queue.completed.size()==1) and bool(
            battle.action_queue.completed[0]["success"]),
            "actual FS ACT resolves once, HP500->430"):return
    presenter.read_completed_actions()
    if not verify(start_events==["enemy:0:1"],"resolved AI action starts real presentation exactly once"):return
    presenter._attack.advance_seconds(0.7)
    if not verify(hit_events==["enemy:0:1"] and complete_events==["enemy:0:1"],
            "F5 mouth VFX cue once and one animation end"):return
    if not verify(int(battle.party[0]["hp"])==430 and int(
            battle.enemies[0]["mp"])==50,"no double damage or spend from visual hit"):return
    presenter.read_completed_actions()
    presenter._attack.advance_seconds(1.0)
    if not verify(hit_events.size()==1 and start_events.size()==1,
            "receipt polling/replay never fires duplicate visual hit"):return
    presenter.unbind_battle()
    if not verify(presenter._active_key=="","unbind tears down presentation"):return
    print("FS_TB_R9_REAL_FS_ATB_ACT_472_PASS enemy_action_receipt=1 native_battle_hp=430 visual_f5=1 extra_damage=0 production_mapping=EXPLICIT_ONLY")
    quit(0)
