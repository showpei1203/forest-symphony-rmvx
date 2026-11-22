extends SceneTree
# P539C batch source #312 action seals + #269 original status Skin.
# Original source notes must control both command UI AND queued ACT execution.
const SEAL=preload("res://scripts/FSOriginalActionSeal.gd")
const HUD=preload("res://scripts/ui/FSBattleSourceHUD269.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const UI_ART=preload("res://scripts/ui/FSUIArtLibrary.gd")

func _initialize()->void:
    call_deferred("_run")

func check(ok:bool,why:String)->bool:
    if not ok:
        push_error("P539C FS original source #312/#269 parity FAIL: "+why)
        quit(1)
        return false
    return true

func _run()->void:
    var db=DATA.database()
    db.tables["states"]=[null,
        {"id":1,"note":"攻撃封印"},  # exact JP, not Chinese 攻擊
        {"id":2,"note":"スキル封印"},
        {"id":3,"note":"防御封印"},
        {"id":4,"note":"アイテム封印"},
        {"id":5,"note":"攻擊封印"}]
    var who:Dictionary={"name":"Source actor","hp":120,"states":[]}
    if not check(SEAL.flags(who,db)["blocked"]==[false,false,false,false],
            "no source State => no imaginary seal"):return
    for i in range(4):
        who["states"]=[i+1]
        var expected:Array=[false,false,false,false]
        expected[i]=true
        if not check(SEAL.flags(who,db)["blocked"]==expected and (
                not SEAL.can_use(who,db,SEAL.KINDS[i])),
                "original #312 four exact JP State.note tags / kind order "+str(i)):return
    who["states"]=[1,2,3,4]
    if not check(SEAL.all_commands_sealed(who,db) and (
            SEAL.flags(who,db)["blocked"]==[true,true,true,true]),
            "multiple source State notes must combine via OR"):return
    who["states"]=[5]
    if not check(SEAL.can_use(who,db,"attack"),
            "Chinese 攻擊 not the original Japanese 攻撃 source tag"):return
    who["a_seal"]=true
    if not check(SEAL.can_use(who,db,"attack"),
            "unrelated runtime actor.a_seal boolean must NOT override State.note"):return
    who["states"]=[99]
    if not check(not SEAL.flags(who,db)["ok"] and (
            not SEAL.can_use(who,db,"attack")),
            "unknown source State record must FAIL CLOSED"):return
    who["states"]=[]
    var source:FSBattleSourceHUD269=HUD.new()
    root.add_child(source)
    var art=UI_ART.new()
    if not check(HUD.source_base(0)==Vector2(9,371) and (
            HUD.source_base(2)==Vector2(287,371)) and (
            HUD.source_portrait(0)==Vector2(9,249)) and (
            HUD.source_gauge(0,"hp")==Vector2(52,374)) and (
            HUD.source_gauge(0,"mp")==Vector2(52,387)) and (
            HUD.source_number(0,"od")==Vector2(74,397)),
            "source #269 effective real Ruby set_xy/BTSKIN offsets"):return
    if not check(HUD.source_gauge_width(0,100)==1 and (
            HUD.source_gauge_width(100,100)==77) and (
            HUD.source_gauge_width(50,100)==39),
            "source #269 gauge 77px source +1 truncation"):return
    if not check(not source.install(art,[who]) and not source.visible,
            "private original #269 HUD must fail closed in public CI"):return
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    if not check(battle.add_actor(1) and battle.add_enemy(1) and (
            battle.start()),"real Godot FSBattle source fixture won't start"):return
    battle.advance_atb(2.0)
    if not check(battle.ready_actors().has(0),
            "source Tankentai 60fps actor must reach ATB READY"):return
    var actor:Dictionary=battle.party[0]
    actor["states"]=[1] # attack sealed BEFORE queued
    if not check(not battle.queue_actor_action(0,"attack",0),
            "source #312 attack seal must forbid queued ACT at request"):return
    actor["states"]=[3]
    if not check(not battle.queue_actor_action(0,"guard"),
            "source #312 guard seal must forbid queued ACT"):return
    actor["states"]=[]
    var screen=SCREEN.new()
    screen.db=db
    screen.world=world
    screen.battle=battle
    root.add_child(screen)
    screen._update_battle_command_buttons()
    actor["states"]=[1]
    screen._update_battle_command_buttons()
    if not check(screen.battle_command_buttons[0].disabled and (
            not screen.battle_command_buttons[1].disabled) and (
            not screen.battle_command_buttons[2].disabled) and (
            not screen.battle_command_buttons[3].disabled),
            "source #312 attack-only State must disable only attack UI"):return
    actor["states"]=[]
    var original_hp:int=int(battle.enemies[0]["hp"])
    if not check(battle.queue_actor_action(0,"attack",0),
            "unsealed actor must be able to queue actual ACT"):return
    actor["states"]=[1] # state becomes sealed WHILE action charges
    battle.advance_atb(1.0/60.0)
    if not check(int(battle.enemies[0]["hp"])==original_hp and (
            not battle.has_actor_pending_action(0)) and (
            not battle.action_queue.completed.is_empty()) and (
            not bool(battle.action_queue.completed[-1]["success"])),
            "new attack-seal DURING ACT must reject attack without HP loss"):return
    print("P539C real Godot 4.7.2 source #312 four Japanese State seals request/ACT/AI fail closed; #269 source status coordinates, gauges and private source gate PASS")
    quit(0)
