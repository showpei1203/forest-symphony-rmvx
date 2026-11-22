extends SceneTree
# P539E original FS scripts #381/#462 and #269 exact (non-easing)
# target help + real battle State detail, both source runtime and UI.
const DB=preload("res://scripts/FSDatabase.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const TARGET=preload("res://scripts/ui/FSBattleSourceTargetHelp462.gd")
const STATES=preload("res://scripts/ui/FSBattleSourceStateHUD381.gd")
const STATUS=preload("res://scripts/ui/FSBattleSourceHUD269.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func check(ok:bool,message:String)->bool:
    if not ok:
        push_error("P539E original FS #381/#462 source parity native FAIL: "+message)
        quit(1)
        return false
    return true

func _run()->void:
    var db:FSDatabase=DATA.database()
    var states:Array=[]
    states.resize(34)
    states[30]={"id":30,"name":"燃燒","note":"<MAX_STACK 5><hud_priority:7><hud_detail_text:持續灼傷><target_priority:0>",
        "icon_index":21,"priority":1,"auto_release_prob":0}
    states[31]={"id":31,"name":"麻痺","note":"<hud_show_turns><hud_detail><target_priority:0>",
        "icon_index":22,"priority":3,"auto_release_prob":30}
    states[32]={"id":32,"name":"不可見","note":"<HUD隱藏>",
        "icon_index":23,"priority":10}
    db.tables["states"]=states
    var enemy:Dictionary={"id":1,"name":"來源敵人","hp":600,"maxhp":600,
        "states":[30,31,32],"state_stack":{30:2},
        "state_turns":{31:3}}
    if not check(STATES.source_max_stack(states[30])==5 and (
            STATES.source_stack(enemy,states[30])==2) and (
            STATES.source_turns(enemy,states[31])==3),
            "original #381 exact MAX_STACK source tag, live stack/remaining turns"):
        return
    var quote:Dictionary=STATES.detail_rows(enemy,db)
    if not check(quote["ok"] and quote["rows"].size()==2 and (
            str(quote["rows"][0]["text"])=="燃燒｜層數2/5｜持續灼傷") and (
            str(quote["rows"][1]["text"])=="麻痺｜剩3回合"),
            "original #381 priority/hidden/state detail rows/maxstack"):
        return
    var node:FSBattleSourceTargetHelp462=TARGET.new()
    root.add_child(node)
    node.install(db)
    if not check(TARGET.layout_while_commanding()["width"]==394 and (
            TARGET.layout_while_commanding()["top"]==82) and (
            not TARGET.SHOW_HELP_STATE_ICONS),
            "original #462 command-safe source header/detail placement and NO duplicate help icons"):
        return
    if not check(node.select(enemy,true) and node.visible and (
            node.detail_lines.size()==2) and (
            node.header["name"]=="來源敵人") and (
            not node.header["capture"]["visible"]),
            "original source help header/details; never guess a capture rate"):
        return
    if not check(not TARGET.safe_capture(enemy,true)["visible"] and (
            not TARGET.safe_capture({
                "hp":100,"albert_current_capture_rate":50},true)["visible"]),
            "source Albert_CaptureRate HELP_SHOW verification required"):
        return
    var verified:Dictionary=enemy.duplicate(true)
    verified["albert_capture_help_verified"]=true
    verified["albert_current_capture_rate"]=62.5
    if not check(TARGET.safe_capture(verified,true)["visible"] and (
            TARGET.safe_capture(verified,true)["rate"]==63),
            "source verified capture is displayed, rounded and bounded"):
        return
    var fake:Dictionary=verified.duplicate(true)
    fake["albert_current_capture_rate"]=120
    if not check(not TARGET.safe_capture(fake,true)["visible"],
            "out-of-range capture cannot be rendered as original"):
        return
    var with_no_source:Dictionary=enemy.duplicate(true)
    with_no_source["states"]=[999]
    if not check(node.select(with_no_source,true) and (
            node.detail_lines.is_empty()) and (
            node.source_warnings.size()==1),
            "unknown source State must not fabricate state detail, name remains"):
        return
    if not check(STATUS.source_gauge_width(50,100)==39 and (
            STATUS.source_number(0,"hp")==Vector2(66,370)),
            "original #269 is instant 12px atlas digit substitution, not fake easing"):
        return
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    if not check(battle.add_actor(1) and battle.add_enemy(1) and (
            battle.start()),"original source-shaped synthetic battle setup"):return
    # #372 must NOT guess targetability for arbitrary State.note.
    # Both active synthetic states include explicit target_priority:0,
    # allowing target selection without disabling original source safety.
    # Inject precisely source-shaped State and target name; no private enemy
    # pixel claims or real source 11 postApply data on public GitHub.
    battle.enemies[0]["name"]="來源敵人"
    battle.enemies[0]["states"]=[30,31]
    battle.enemies[0]["state_stack"]={30:2}
    battle.enemies[0]["state_turns"]={31:3}
    var screen=SCREEN.new()
    screen.db=db
    screen.world=world
    screen.battle=battle
    root.add_child(screen)
    battle.advance_atb(2.0)
    if not check(battle.ready_actors().has(0),"original ATB not ready"):return
    var before_hp:int=int(battle.enemies[0]["hp"])
    screen._player_attack()
    if not check(screen.source_target_help!=null and (
            screen.source_target_help.visible) and (
            screen.source_target_help.header["name"]=="來源敵人") and (
            screen.source_target_help.detail_lines.size()==2) and (
            battle.action_queue.pending.is_empty()) and (
            battle.source_atb_wait) and (
            int(battle.enemies[0]["hp"])==before_hp),
            "real target selection must expose source #462 & #381 but never auto-attack"):
        return
    if not check(screen.source_target_help.get_parent()==screen.body and (
            screen.body.get_child_count()>=3),
            "source target help must share scroll target UI, never block choices"):
        return
    screen._show_battle()
    if not check(screen.source_target_help==null and (
            not battle.source_atb_wait),
            "source target help must fully clear on exit, source ATB resume"):
        return
    print("P539E Godot 4.7.2 original #462 target header and #381 stack/turn/detail, source #269 instant atlas digits, real selectable ATB target and capture fail-close PASS")
    quit(0)
