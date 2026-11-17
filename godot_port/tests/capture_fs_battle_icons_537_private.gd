extends SceneTree
# Owner-only QA, NOT normal CI. Actual original FS battle art is staged
# from private Drive and source SHA-locked. Actor and enemy stats remain
# explicitly synthetic; never claim original post-Apply 11 DB.
# Requires pre-existing temporary FS_UI_QA_DIR; no user:// or VX E: writes.
const SCREEN=preload("res://scripts/FSScreen.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _shot(stage:String)->bool:
    await process_frame
    await process_frame
    var output:String=OS.get_environment("FS_UI_QA_DIR")
    if output.is_empty() or not DirAccess.dir_exists_absolute(output):
        push_error("P537 PRIVATE QA requires existing FS_UI_QA_DIR")
        quit(1)
        return false
    var frame:Image=root.get_texture().get_image()
    if frame==null or frame.is_empty() or frame.get_size()!=root.size:
        push_error("P537 actual Godot OpenGL viewport screenshot absent")
        quit(2)
        return false
    var path:String=output.path_join(
        "fs_p537_original_battle_"+stage+"_"+
        str(root.size.x)+"x"+str(root.size.y)+".png")
    if frame.save_png(path)!=OK:
        push_error("P537 native PNG could not be saved")
        quit(3)
        return false
    print("P537_NATIVE_PRIVATE_SOURCE_GPU "+stage+" "+
        str(root.size)+" SHA256 "+FileAccess.get_sha256(path))
    return true

func _run()->void:
    var width:int=int(OS.get_environment("FS_UI_QA_WIDTH"))
    root.size=Vector2i(544,416) if width==544 else Vector2i(1088,832)
    var db=DATA.database()
    db.tables["actors"][1]["name"]="喬伊" # synthetic QA combat fixture
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(screen)
    screen.selected_troop_id=1
    screen._show_battle()
    if screen.battle_command_art.size()!=4 or not battle.active or (
            screen.battle_command_grid==null) or (
            screen.battle_command_grid.columns!=2):
        push_error("P537 private original command icons/grid not live")
        quit(4)
        return
    for button in screen.battle_command_buttons:
        if not button.disabled or button.icon==null:
            push_error("P537 original inactive command icon missing")
            quit(5)
            return
    if not await _shot("inactive"):
        return
    screen._process(2.0)
    if not screen._battle_actor_ready():
        push_error("P537 true original Tankentai ATB did not become ready")
        quit(6)
        return
    for button in screen.battle_command_buttons:
        if button.disabled or button.icon!=screen.battle_command_art[
                button.get_instance_id()]["active"]:
            push_error("P537 source coloured active icon not tied to ATB READY")
            quit(7)
            return
    if not await _shot("ready"):
        return
    screen._player_attack()
    if not screen.title_label.text.contains("選擇敵方目標"):
        push_error("P537 real source ACT target selector not accessible")
        quit(8)
        return
    if not await _shot("select_target"):
        return
    print("P537_PRIVATE_SOURCE_ACTIVE_INACTIVE_NATIVE_GPU_PASS (not full original art parity)")
    quit(0)
