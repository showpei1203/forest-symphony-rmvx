extends SceneTree
# P537 original FS 54x48 action icons, real ACT readiness, not generated art.
const SCREEN=preload("res://scripts/FSScreen.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,reason:String)->bool:
    if not ok:
        push_error("P537 original battle icon native FAIL: "+reason)
        quit(1)
        return false
    return true

func _run()->void:
    var db=DATA.database()
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    var screen=SCREEN.new()
    screen.db=db
    screen.world=world
    screen.battle=battle
    root.add_child(screen)
    screen.selected_troop_id=1
    screen._show_battle()
    if not _check(battle.active and screen.battle_command_buttons.size()==4,
            "four actual Godot ACT commands and source battle started"):
        return
    if not _check(screen.battle_command_grid!=null and
            screen.battle_command_grid.columns==2 and
            screen.battle_command_grid.get_child_count()==4,
            "original 54x48 source action buttons must fit a 2 by 2 GridContainer"):
        return
    var private_qa:bool=OS.get_environment("FS_PRIVATE_UI_QA")=="1"
    for button in screen.battle_command_buttons:
        if not _check(button.disabled and not screen._battle_actor_ready(),
                "cannot activate original icon command before ATB READY"):
            return
        var key:int=button.get_instance_id()
        if private_qa:
            if not _check(screen.battle_command_art.has(key) and
                    button.icon!=null and (
                    Vector2i(button.icon.get_size())==Vector2i(54,48)) and (
                    button.icon==screen.battle_command_art[key]["inactive"]),
                    "original inactive 54x48 source PNG must be shown"):
                return
        elif not _check(button.icon==null and screen.battle_command_art.is_empty(),
                "public CI cannot silently contain user-private original PNG"):
            return
    screen._process(2.0)
    if not _check(screen._battle_actor_ready(),
            "real Tankentai ATB did not make the actor ready"):
        return
    for button in screen.battle_command_buttons:
        if not _check(not button.disabled,"battle command remains disabled after source ATB READY"):
            return
        if private_qa:
            if not _check(button.icon==screen.battle_command_art[
                    button.get_instance_id()]["active"],
                    "original coloured button does not switch on true ATB READY"):
                return
    if not _check(screen.battle_command_art.size()==(4 if private_qa else 0),
            "source icon count not four; do not fabricate Escape button"):
        return
    print("P537 Godot4.7.2 original FS battle command icons + disabled/READY real ATB PASS")
    quit(0)
