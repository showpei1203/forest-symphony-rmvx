extends SceneTree
# P538C: visible-layout and callback QA using GENERATED FLAT TEXTURES.
# This is never called original VX art or exact source parity.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

class SyntheticArt extends FSUIArtLibrary:
    var fixtures:Dictionary={}
    func texture(category:String,file_name:String)->Texture2D:
        var key:String=category+"/"+file_name
        if fixtures.has(key):
            return fixtures[key]
        var dimension:=Vector2i.ZERO
        if category=="system" and file_name.begins_with("MenuBack"):
            dimension=Vector2i(544,416)
        elif category=="menu" and file_name.begins_with("Menu0"):
            dimension=Vector2i(50,20)
        elif category=="menu" and (
                file_name.begins_with("Status") or
                file_name.begins_with("Skill") or
                file_name.begins_with("Item") or
                file_name.begins_with("Equip")):
            dimension=Vector2i(60,20)
        elif category=="menu" and file_name.begins_with("menu_"):
            dimension=Vector2i(112,142)
        if dimension==Vector2i.ZERO:
            return null
        var pixels:=Image.create(
            dimension.x,dimension.y,false,Image.FORMAT_RGBA8)
        # Plain colored geometry test fixture, NOT a source image.
        pixels.fill(Color(0.2,0.38,0.39,1.0))
        var sample:=ImageTexture.create_from_image(pixels)
        fixtures[key]=sample
        return sample

func _initialize()->void:
    call_deferred("_run")

func check(ok:bool,why:String)->bool:
    if ok:
        return true
    push_error("P538C SOURCE GEOMETRY/OPERATIONS native FAIL: "+why)
    quit(1)
    return false

func _run()->void:
    var db=DATA.database()
    var names:Array[String]=["喬伊","米亞","艾薇","泰勒"]
    db.tables["actors"][1]["name"]=names[0]
    for i in range(1,names.size()):
        var actor:Dictionary=db.tables["actors"][1].duplicate(true)
        actor["id"]=i+1
        actor["name"]=names[i]
        actor["initial_level"]=5+i
        db.tables["actors"].append(actor)
    var world=DATA.initial_state()
    world.gain_item("item",1,2)
    var battle=BATTLE.new(db,world)
    for i in range(names.size()):
        if i>0:
            world.party_actor_ids.append(i+1)
        battle.add_actor(i+1)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    # This fixture art is deliberately NOT FS original, despite matching
    # the native dimensions; these tests only prove placement and state.
    screen.ui_art=SyntheticArt.new()
    var page=screen.source_page_overlay
    for dimensions in [Vector2i(544,416),Vector2i(1088,832)]:
        root.size=dimensions
        # SceneTree script runs without a normal Window resize/layout loop.
        # Explicitly propagate the viewport geometry to its root Control.
        screen.size=Vector2(dimensions)
        screen._layout_source_menu()
        await process_frame
        for item in ["status","skills","items","equipment","formation"]:
            match item:
                "status":screen._show_status()
                "skills":screen._show_skills()
                "items":screen._show_items()
                "equipment":screen._show_equipment()
                "formation":screen._show_formation()
            if not check(page.visible and page.source_ready and
                    page.page_kind==item and not screen.developer_scroll.visible,
                    item+" must display only source geometry mock, no debug chrome"):
                return
            var expected:Vector2=Vector2(
                maxf(0.0,float(dimensions.x-544)*0.5),
                maxf(0.0,float(dimensions.y-416)*0.5))
            if not check(page.position==expected,
                    item+" screen 1x/2x centered source window; got="+str(page.position)+" expected="+str(expected)+" control="+str(screen.size)):
                return
            if item!="formation":
                var panel:PanelContainer=page.get_node(
                    "FSOriginalPageFunctionalWindow")
                var area:Rect2=FSOriginalMenuPage.SOURCE_ROW_RECTS[item]
                if not check(panel.position==area.position and
                        panel.size==area.size and
                        panel.get_theme_stylebox("panel") is StyleBoxEmpty,
                        item+" source window geometry may not be repainted"):
                    return
            else:
                if not check(page.get_node_or_null(
                        "FSOriginalCurrentSlot_0")!=null and
                        page.get_node_or_null("FSOriginalReserveSquad")!=null and
                        page.get_node_or_null("FSOriginalPageFunctionalWindow")==null,
                        "three source current-squad slots and separate reserve"):
                    return
    # M4 other actor and long current+reserve party, no secret source pixels.
    screen.actor_index=1
    screen._show_status()
    if not check(page.displayed_portrait!=null and
            page.displayed_portrait.name=="FSOriginalPortrait_1",
            "second actor original-identity filename route"):
        return
    screen._show_items()
    screen._source_page_item(1)
    if not check(page.page_kind=="item_targets" and page.visible,
            "real item target UI after source-menu click"):
        return
    var count_before:int=world.amount("item",1)
    screen._source_page_item_target(1,0)
    if not check(world.amount("item",1)==count_before and
            page.page_kind=="items" and page.feedback_label.visible and
            page.feedback_label.text.contains("拒"),
            "unverified item cannot debit; source page must show refusal"):
        return
    screen._show_equipment()
    screen._show_equipment_candidates(0)
    if not check(page.page_kind=="equipment_candidates" and
            page.get_node("FSOriginalPageFunctionalWindow")!=null,
            "source equipment option UI"):
        return
    screen._source_page_return()
    if not check(page.page_kind=="equipment",
            "cancel equipment options returns equipment"):
        return
    screen._show_formation()
    screen._formation_clicked(0)
    screen._formation_clicked(3)
    if not check(int(battle.party[0].get("id",0))==4 and
            world.party_actor_ids==[4,2,3,1],
            "original current/real reserve swap must persist in game state"):
        return
    print("P538C Godot4.7.2 SOURCE-RECT/SYNTHETIC-TEXTURE UI 5 PAGES, 2 resolutions, 4 actors, item denial, equipment cancel, reserve swap PASS; original sprite visual NOT TESTED")
    quit(0)
