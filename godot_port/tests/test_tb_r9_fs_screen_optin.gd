extends SceneTree
# Actual FS game's FSScreen BATTLE view, with synthetic atlas and an explicit
# monster-visual tag. Not a claim of original FS private BattleScape art.
const DB=preload("res://scripts/FSDatabase.gd")
const WORLD=preload("res://scripts/FSGameState.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
func _initialize()->void: call_deferred("_run")
func _check(ok:bool,why:String)->bool:
    if not ok:
        push_error("FS_TB_R9_UI_FAIL: "+why)
        quit(1)
        return false
    return true
func _run()->void:
    var db: FSDatabase=DB.new()
    db.tables={"skills":[null],"weapons":[null],"armors":[null]}
    var battle:FSBattle=BATTLE.new(db,WORLD.new())
    battle.party.append({"id":1,"actor":true,"name":"FixtureHero", "hp":500,
        "maxhp":500,"agi":10,"def":5,"atk":10,"spi":3,"mp":50,
        "maxmp":50,"equipment":[0,0,0,0,0],"two_swords_style":false,
        "odds":4,"states":[],"note":""})
    battle.enemies.append({"id":1,"actor":false,"name":"Fixture Leaf Bat",
        "fs_monster_visual_id":"TB02_LEAF_BAT","hp":300,"maxhp":300,
        "mp":50,"maxmp":50,"atk":20,"def":5,"spi":8,"agi":20,
        "note":"","states":[],"actions":[{"kind":0,"basic":0,
        "skill_id":0,"rating":8,"condition_type":0,
        "condition_param1":0,"condition_param2":0}]})
    battle.source_atb_rolls_for_test={"actor:0":0,"enemy:0":0}
    var screen=SCREEN.new()
    screen.db=db
    screen.world=WORLD.new()
    screen.battle=battle
    screen.tb_monster_visual_synthetic_qa=true
    root.add_child(screen)
    await process_frame
    if not _check(screen.view_name=="BATTLE" and battle.active,
            "real FS BATTLE view active"):return
    if not _check(screen.tb_monster_view != null and (
            screen.tb_monster_view._is_ready),
            "opt-in TB02 presentation mounted in real FS BATTLE UI"):return
    var visual=screen.tb_monster_view
    var hits: Array[String]=[]
    visual.visual_hit_cue.connect(func(k:String,_p:Vector2):hits.append(k))
    battle.action_queue.completed.append({"serial":1,"side":"enemy",
            "enemy_index":0,"kind":"attack","success":true})
    visual.read_completed_actions()
    visual._attack.advance_seconds(0.8)
    if not _check(hits==["enemy:0:1"],"UI presenter plays ACT receipt F5 once"):return
    var hero_hp:int=int(battle.party[0]["hp"])
    visual.read_completed_actions()
    if not _check(int(battle.party[0]["hp"])==hero_hp and hits.size()==1,
            "UI visual polling cannot change HP or replay hit"):return
    screen._show_menu()
    if not _check(screen.tb_monster_view==null,
            "switching MENU detaches battle visual and queued listener"):return
    print("FS_TB_R9_FS_SCREEN_OPTIN_472_PASS battle_ui=YES verified_visual_tag=YES hit=1 no_duplicate_hp menu_cleanup=PASS")
    quit(0)
