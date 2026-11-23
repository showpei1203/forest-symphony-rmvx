extends SceneTree
# P538D owner-only ORIGINAL source viewport capture. Intentionally NOT
# invoked in public CI: no private sprites are published to GitHub.
# Linux-isolated cloud only; never create temporary project on user PC.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

var output_dir:String=""
var width:int=0
var count:int=0

func _initialize()->void:
    call_deferred("_run")

func _deny(message:String)->void:
    push_error("P538D PRIVATE SOURCE CAPTURE DENIED: "+message)
    quit(9)

func _capture(page:String)->bool:
    await process_frame
    await process_frame
    var frame:Image=root.get_texture().get_image()
    if frame==null or frame.get_size()!=root.size:
        _deny("native Godot viewport missing or wrong dimensions: "+page)
        return false
    var target:String=output_dir.path_join(
        "p538d_PRIVATE_TRUE_GODOT_"+page+"_"+str(width)+".png")
    if FileAccess.file_exists(target):
        _deny("refuse to overwrite an existing private QA screenshot: "+target)
        return false
    if frame.save_png(target)!=OK:
        _deny("cannot save screenshot to preauthorized cloud QA directory")
        return false
    count+=1
    print("P538D true Godot owner-original "+page+" "+
        str(root.size)+" SHA256="+FileAccess.get_sha256(target))
    return true

func _run()->void:
    if OS.get_name()!="Linux":
        _deny("owner Windows and non-isolated systems may not run this script")
        return
    if OS.get_environment("FS_PRIVATE_UI_QA")!="1":
        _deny("FS_PRIVATE_UI_QA=1 explicit private isolated run required")
        return
    if OS.get_environment("FS_UI_QA_WIDTH") not in ["544","1088"]:
        _deny("resolution must be explicitly 544 or 1088")
        return
    width=int(OS.get_environment("FS_UI_QA_WIDTH"))
    output_dir=OS.get_environment("FS_UI_QA_DIR")
    if output_dir.is_empty() or not output_dir.begins_with("/") or (
            not DirAccess.dir_exists_absolute(output_dir)):
        _deny("existing approved private Linux QA output directory required")
        return
    var art=ART.new()
    if not art.has_source():
        _deny("202 original UI images SHA manifest missing or invalid")
        return
    var source_filenames:Array[String]=[
        "menu_喬伊.png","menu_米亞.png","menu_泰勒.png",
        "menu_艾薇.png","menu_薇娜.png","menu_艾卓.png"]
    for file_name in source_filenames:
        if art.texture("menu",file_name)==null:
            _deny("original source portrait SHA failure: "+file_name)
            return
    if art.texture("system","MenuBack_party.png")==null:
        _deny("private original formation background SHA failure")
        return
    var db=DATA.database()
    var names:Array[String]=[
        "喬伊","米亞","泰勒","艾薇","薇娜","艾卓"]
    db.tables["actors"][1]["name"]=names[0]
    for i in range(1,names.size()):
        var actor:Dictionary=db.tables["actors"][1].duplicate(true)
        actor["id"]=i+1
        actor["name"]=names[i]
        actor["initial_level"]=4+i
        db.tables["actors"].append(actor)
    var world=DATA.initial_state()
    world.gain_item("item",1,2)
    var battle=BATTLE.new(db,world)
    for i in range(names.size()):
        if i>0:
            world.party_actor_ids.append(i+1)
        battle.add_actor(i+1)
    root.size=Vector2i(544,416) if width==544 else Vector2i(1088,832)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    if screen.source_page_overlay==null:
        _deny("source page scene is missing")
        return
    # 1) MENU 2) STATUS 3) SKILLS 4) ITEMS 5) ITEM_TARGETS
    # 6) EQUIPMENT 7) EQUIP_CANDIDATES 8) FORMATION
    # 9) FORMATION_FIRST_SELECTED 10) FORMATION_CURRENT_RESERVE_SWAP
    # 11) STATUS_SECOND_MIA (each run -> 11 source-view screenshots).
    screen._show_menu()
    if screen.source_menu_overlay==null or (
            not screen.source_menu_overlay.visible):
        _deny("source original MENU not visible")
        return
    if not await _capture("menu"):
        return
    for category in ["status","skills","items"]:
        match category:
            "status":screen._show_status()
            "skills":screen._show_skills()
            "items":screen._show_items()
        if not screen.source_page_overlay.visible:
            _deny("source original "+category+" page not visible")
            return
        if not await _capture(category):
            return
    screen._source_page_item(1)
    if screen.source_page_overlay.page_kind!="item_targets":
        _deny("original item targets page not available")
        return
    if not await _capture("item_targets"):
        return
    screen._show_equipment()
    if not await _capture("equipment"):
        return
    screen._show_equipment_candidates(0)
    if not await _capture("equipment_candidates"):
        return
    screen._show_formation()
    var party_view=screen.source_page_overlay
    if party_view.page_kind!="formation" or (
            party_view.get_node_or_null("FSOriginalReserveSquad")==null):
        _deny("source original current and reserve formation art unavailable")
        return
    if not await _capture("formation_six_actors"):
        return
    screen._formation_clicked(0)
    if not await _capture("formation_first_selected"):
        return
    screen._formation_clicked(5)
    if world.party_actor_ids!=[6,2,3,4,5,1]:
        _deny("current/reserve swapped source state mismatch")
        return
    if not await _capture("formation_after_reserve_swap"):
        return
    screen.actor_index=1
    screen._show_status()
    if screen.source_page_overlay.displayed_portrait==null:
        _deny("second source actor portrait absent")
        return
    if not await _capture("status_mia_second"):
        return
    print("P538D COMPLETE: "+str(count)+
        " PRIVATE ACTUAL GODOT RENDER SCREENSHOTS width="+str(width)+
        " with 202 original verified SHA sprites; numerical DATA SYNTHETIC; "+
        "original VX same-state/pixel parity and user art approval STILL HOLD")
    quit(0)
