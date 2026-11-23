extends SceneTree
# P538A private only. Original 202 files are owner-only staged from Drive,
# never uploaded to public GitHub. DATA remains explicitly synthetic.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _frame(page:String)->bool:
    await process_frame
    await process_frame
    var directory:String=OS.get_environment("FS_UI_QA_DIR")
    if directory.is_empty() or not DirAccess.dir_exists_absolute(directory):
        push_error("P538A private capture requires already-created QA directory")
        quit(7)
        return false
    var image:Image=root.get_texture().get_image()
    if image==null or image.get_size()!=root.size:
        push_error("P538A viewport not captured")
        quit(8)
        return false
    var path:String=directory.path_join("p538a_original_"+page+"_"+str(root.size.x)+".png")
    if image.save_png(path)!=OK:
        quit(9)
        return false
    print("P538A PRIVATE ORIGINAL GPU "+page+" "+str(root.size)+
        " sha256="+FileAccess.get_sha256(path))
    return true

func _run()->void:
    var original=ART.new()
    if not original.has_source() or original.texture("system","MenuBack_b.png")==null:
        push_error("P538A requires SHA-gated original private MenuBack_b")
        quit(2)
        return
    var db=DATA.database()
    # Two independent actor portraits are real source art; numbers are QA.
    db.tables["actors"][1]["name"]="喬伊"
    var actor_two:Dictionary=db.tables["actors"][1].duplicate(true)
    actor_two["id"]=2
    actor_two["name"]="米亞"
    db.tables["actors"].append(actor_two)
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_actor(2)
    root.size=Vector2i(544,416) if OS.get_environment("FS_UI_QA_WIDTH")=="544" else Vector2i(1088,832)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    screen._show_menu()
    if screen.source_menu_overlay==null or not screen.source_menu_overlay.visible:
        push_error("P538A native original navigation not rendered")
        quit(3)
        return
    for view in ["menu","status","skills","items","equipment","formation"]:
        match view:
            "menu":screen._show_menu()
            "status":screen._show_status()
            "skills":screen._show_skills()
            "items":screen._show_items()
            "equipment":screen._show_equipment()
            "formation":screen._show_formation()
        if not await _frame(view):
            return
    # M4 second sample: different source-locked protagonist portrait/actor.
    screen.actor_index=1
    screen._show_status()
    if screen.body.find_child("FSOriginalPortrait_1",true,false)==null:
        push_error("P538A second original protagonist Mia source portrait missing")
        quit(10)
        return
    if not await _frame("status_mia_second_actor"):
        return
    print("P538A PRIVATE ORIGINAL MENU SIX PAGES + SECOND ACTOR GPU PASS; VX SAME-STATE PIXEL PARITY HOLD")
    quit(0)
