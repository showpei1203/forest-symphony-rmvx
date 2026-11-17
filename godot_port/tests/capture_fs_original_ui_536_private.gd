extends SceneTree
# Godot 4.7.2 real private FS original UI art QA. Manual only, never CI:
# requires owner-only 202 PNG already hash-staged under assets/ui/.
# COMBAT DATA here is synthetic fixture and NEVER claims 11 post-Apply DB.
# Produces real viewport OpenGL PNG only to an explicitly provided private
# temporary output directory. No user:// or original VX E: writes.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func _save(label:String)->bool:
    var target:String=OS.get_environment("FS_UI_QA_DIR")
    if target.is_empty() or not DirAccess.dir_exists_absolute(target):
        push_error("P536 PRIVATE QA requires pre-created FS_UI_QA_DIR")
        quit(8)
        return false
    await process_frame
    await process_frame
    var image:Image=root.get_texture().get_image()
    if image==null or image.is_empty() or image.get_size()!=root.size:
        push_error("P536 PRIVATE QA actual GPU frame not rendered")
        quit(9)
        return false
    var filename:String=target.path_join("fs_p536_original_"+label+"_"+str(root.size.x)+"x"+str(root.size.y)+".png")
    if image.save_png(filename)!=OK:
        push_error("P536 PRIVATE QA could not store native viewport")
        quit(10)
        return false
    var file:=FileAccess.open(filename,FileAccess.READ)
    if file==null or file.get_length()<4000:
        push_error("P536 PRIVATE QA screenshot empty")
        quit(11)
        return false
    print("P536_NATIVE_ORIGINAL_UI_GPU "+label+" "+str(root.size)+" "+str(file.get_length())+" bytes SHA256 "+FileAccess.get_sha256(filename))
    return true

func _run()->void:
    var source=ART.new()
    if not source.has_source():
        push_error("P536 PRIVATE QA no original 202-image authority")
        quit(2)
        return
    for item in ["MenuBack_status_a.png","Btskin_main.png","GaugeHP.png",
                 "GaugeMP.png","GaugeOD.png","iconset.png"]:
        if source.texture("system",item)==null:
            push_error("P536 private original texture missing/hash invalid: "+item)
            quit(3)
            return
    if source.texture("menu","menu_喬伊.png")==null:
        push_error("P536 private source protagonist portrait missing")
        quit(4)
        return
    var width:int=int(OS.get_environment("FS_UI_QA_WIDTH"))
    root.size=Vector2i(544,416) if width==544 else Vector2i(1088,832)
    var db=DATA.database()
    db.tables["actors"][1]["name"]="喬伊" # QA fixture, not original post-Apply
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_child(screen)
    screen._show_menu()
    if not await _save("menu"):
        return
    screen._show_status()
    var portrait:Node=screen.body.find_child("FSOriginalPortrait_0",true,false)
    if portrait==null:
        push_error("P536 original 6-character portrait not bound to status")
        quit(5)
        return
    if not await _save("status"):
        return
    screen.selected_troop_id=1
    screen._show_battle()
    if screen.ui_hud==null or not screen.ui_hud.visible or (
            screen.ui_hud._records.size()!=1) or (
            screen.ui_hud._records[0]["original"]==null):
        push_error("P536 Btskin + original gauge atlas not actually present in battle HUD")
        quit(6)
        return
    if not await _save("battle"):
        return
    print("P536_NATIVE_ORIGINAL_UI_3FRAMES_PASS; ART HOLD until same-state VX parity")
    quit(0)
