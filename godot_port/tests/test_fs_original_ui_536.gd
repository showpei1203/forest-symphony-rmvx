extends SceneTree

const PANEL=preload("res://scripts/ui/FSUIOriginalVitals.gd")
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")

func _initialize()->void:
    call_deferred("_run")

func check(ok:bool,detail:String)->bool:
    if not ok:
        push_error("P536 source art UI native FAIL: "+detail)
        quit(1)
        return false
    return true

func _run()->void:
    if not check(PANEL.fill_width(0.0)==0 and
            PANEL.fill_width(0.5)==36 and PANEL.fill_width(1.0)==72 and (
            PANEL.fill_width(2.0)==72) and PANEL.fill_width(-1.0)==0,
            "bounded authentic source 72px strip width"):
        return
    if not check(PANEL.fill_source_region(0.5)==Rect2(0,42,36,6),
            "original 120x48 image atlas uses 72x6 lower strip, not full image"):
        return
    var a=ART.new()
    var private_qa:bool=OS.get_environment("FS_PRIVATE_UI_QA")=="1"
    if private_qa:
        if not check(a.has_source() and a.texture("system","GaugeHP.png")!=null,
                "owner-only source art must be valid when explicitly staged"):
            return
    elif not check(not a.has_source() and a.texture("system","GaugeHP.png")==null,
            "public CI must never contain private original images"):
        return
    var panel=PANEL.new()
    if not check(panel.install_art(a)==private_qa,
            "authentic source panel only activates with verified owner-only art"):
        return
    panel.set_values({"hp":75,"maxhp":120,"mp":20,"maxmp":40,
        "od":30,"od_max":60})
    if not check(is_equal_approx(panel.hp_rate,0.625) and
            is_equal_approx(panel.mp_rate,0.5) and
            is_equal_approx(panel.od_rate,0.5),
            "true source values map to ratio without fabricating OD max"):
        return
    panel.set_values({"hp":0,"maxhp":0,"od":30})
    if not check(panel.hp_rate==0.0 and panel.od_rate==0.0,
            "unknown maxHP or maxOD fail closed"):
        return
    var db=DATA.database()
    db.tables["actors"][1]["name"]="喬伊"
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    screen._show_status()
    if not check(screen.body.get_child_count()>=3 and
            screen.ui_hud!=null and not screen.ui_hud.visible,
            "compact original status screen real HBox UI constructed"):
        return
    print("P536 original-image 120x48 atlas ROI + live HP/MP/OD + compact status native PASS (source-private GPU QA separate)")
    quit(0)
