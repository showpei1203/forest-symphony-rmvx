extends SceneTree
# P538B owner-only PRIVATE original UI captures. Execute only in a
# reviewed isolated cloud workspace with staged SHA-verified 202 PNGs.
# Never generate source screenshots on user's PC without authorization.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func _capture(page:String)->bool:
    await process_frame
    await process_frame
    var folder:String=OS.get_environment("FS_UI_QA_DIR")
    if folder.is_empty() or not DirAccess.dir_exists_absolute(folder):
        push_error("P538B requires an existing, authorized PRIVATE QA destination")
        quit(7)
        return false
    var image:Image=root.get_texture().get_image()
    if image==null or image.get_size()!=root.size:
        push_error("P538B native viewport evidence missing: "+page)
        quit(8)
        return false
    var pathname:String=folder.path_join("p538b_source_"+
        page+"_"+str(root.size.x)+".png")
    if image.save_png(pathname)!=OK:
        push_error("P538B private capture write failed: "+page)
        quit(9)
        return false
    print("P538B OWNER-ONLY SOURCE "+page+
        " "+str(root.size)+" SHA256="+FileAccess.get_sha256(pathname))
    return true

func _run()->void:
    var library=ART.new()
    if not library.has_source():
        push_error("P538B requires all 202 original SHA-verified UI PNGs")
        quit(2)
        return
    var db=DATA.database()
    db.tables["actors"][1]["name"]="喬伊"
    var sample:Dictionary=db.tables["actors"][1].duplicate(true)
    sample["id"]=2
    sample["name"]="米亞"
    db.tables["actors"].append(sample)
    var world=DATA.initial_state()
    world.party_actor_ids.append(2)
    world.gain_item("item",1,2)
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_actor(2)
    root.size=Vector2i(544,416) if (
        OS.get_environment("FS_UI_QA_WIDTH")=="544") else Vector2i(1088,832)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    for page in ["menu","status","skills","items","equipment","formation"]:
        match page:
            "menu":screen._show_menu()
            "status":screen._show_status()
            "skills":screen._show_skills()
            "items":screen._show_items()
            "equipment":screen._show_equipment()
            "formation":screen._show_formation()
        if page=="menu":
            if screen.source_menu_overlay==null or (
                    not screen.source_menu_overlay.visible):
                quit(3)
                return
        elif screen.source_page_overlay==null or (
                not screen.source_page_overlay.visible):
            push_error("P538B failed source page render: "+page)
            quit(4)
            return
        if not await _capture(page):
            return
    screen.actor_index=1
    screen._show_status()
    if screen.source_page_overlay.displayed_portrait==null:
        push_error("P538B actual second original Mia portrait missing")
        quit(10)
        return
    if not await _capture("status_mia_second_source"):
        return
    screen._show_items()
    screen._source_page_item(1)
    if screen.source_page_overlay.page_kind!="item_targets":
        quit(11)
        return
    if not await _capture("item_targets"):
        return
    screen._show_equipment()
    screen._show_equipment_candidates(0)
    if screen.source_page_overlay.page_kind!="equipment_candidates":
        quit(12)
        return
    if not await _capture("equipment_candidates"):
        return
    screen._show_formation()
    screen._formation_clicked(0)
    screen._formation_clicked(1)
    if not await _capture("formation_after_swap"):
        return
    print("P538B 10 SOURCE UI native captures completed; source portraits authentic, numeric data SYNTHETIC; no original VX same-state pixel-parity claim")
    quit(0)
