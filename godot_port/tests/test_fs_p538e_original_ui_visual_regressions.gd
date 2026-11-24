extends SceneTree
# P538E native UI geometry/contrast test. Test textures are FLAT generated
# fixtures, not owner-private source art or original VX pixel parity.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const PAGE=preload("res://scripts/ui/FSOriginalMenuPage.gd")

class ColorFixture extends FSUIArtLibrary:
    var generated:Dictionary={}
    func texture(category:String,name:String)->Texture2D:
        var key:String=category+"/"+name
        if generated.has(key):
            return generated[key]
        var size:=Vector2i.ZERO
        if category=="system" and name.begins_with("MenuBack"):
            size=Vector2i(544,416)
        elif category=="menu" and name.begins_with("menu_"):
            size=Vector2i(252,312)
        elif category=="menu" and name.begins_with("Menu0"):
            size=Vector2i(50,20)
        elif category=="menu" and (name.begins_with("Status") or
                name.begins_with("Skill") or name.begins_with("Item") or
                name.begins_with("Equip")):
            size=Vector2i(60,20)
        if size==Vector2i.ZERO:
            return null
        var pixels:=Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
        pixels.fill(Color(0.3,0.4,0.5,1))
        var result:=ImageTexture.create_from_image(pixels)
        generated[key]=result
        return result

func _initialize()->void:
    call_deferred("_run")

func require(value:bool,issue:String)->bool:
    if value:
        return true
    push_error("P538E ORIGINAL-UI VISUAL-REGRESSION native FAIL: "+issue)
    quit(1)
    return false

func _run()->void:
    var db=DATA.database()
    db.tables["actors"][1]["name"]="喬伊"
    var second:Dictionary=db.tables["actors"][1].duplicate(true)
    second["id"]=2
    second["name"]="米亞"
    second["initial_level"]=7
    db.tables["actors"].append(second)
    var world=DATA.initial_state()
    world.party_actor_ids.append(2)
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_actor(2)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    screen.ui_art=ColorFixture.new()
    var page:FSOriginalMenuPage=screen.source_page_overlay
    for dimensions in [Vector2i(544,416),Vector2i(1088,832)]:
        root.size=dimensions
        screen.size=Vector2(dimensions)
        screen._layout_source_menu()
        await process_frame
        for category in ["status","skills","items","equipment"]:
            match category:
                "status":screen._show_status()
                "skills":screen._show_skills()
                "items":screen._show_items()
                "equipment":screen._show_equipment()
            if not require(page.source_ready and page.visible and
                    page.page_kind==category,category+" source page missing"):
                return
            var heading:Label=page.get_node("FSOriginalPageHeader")
            if not require(heading.autowrap_mode==TextServer.AUTOWRAP_OFF and
                    heading.position==Vector2(144,23) and
                    heading.size.x>=140,
                    category+" native heading must not wrap into vertical text"):
                return
            var back:Button=page.get_node("FSOriginalPageReturn")
            if not require(back.position==Vector2(436,73) and
                    back.position.x>=144+heading.size.x,
                    category+" source back button cannot crush heading"):
                return
            if not require(page.feedback_label!=null and
                    page.feedback_label.visible and
                    page.feedback_label.position.y<42,
                    category+" synthetic QA marker must not sit on source footer"):
                return
            var content:VBoxContainer=page.get_node(
                "FSOriginalPageFunctionalWindow/FSOriginalRowsScroll/FSOriginalPageRows")
            if not require(content.get_child_count()>0,
                    category+" page content missing"):
                return
            var first_label:Control=content.get_child(0)
            if first_label is Label:
                var fg:Color=first_label.get_theme_color("font_color")
                if not require(fg.r>0.7 and fg.g>0.7 and fg.b>0.7,
                        category+" source dark window needs bright text"):
                    return
            if category in ["status","skills","equipment"]:
                var nav:HBoxContainer=page.get_node("FSOriginalActorSelection")
                if not require(nav.position==Vector2(213,49) and
                        nav.position.y+nav.size.y<78,
                        category+" actor nav must not cover source tabs"):
                    return
                var portrait:TextureRect=page.displayed_portrait
                if not require(portrait!=null,
                        category+" SHA-identity portrait fixture route missing"):
                    return
                if category!="status":
                    if not require(portrait.position.y+portrait.size.y<=108,
                            "portrait must not cover original Description banner"):
                        return
        screen.actor_index=1
        screen._show_status()
        if not require(page.displayed_portrait!=null and
                page.displayed_portrait.name=="FSOriginalPortrait_1",
                "second independent actor original-identity portrait route"):
            return
        screen.actor_index=0
    print("P538E official Godot4.7.2 native headline/STATUS white font/source portrait/QA marker 544+1088, original-identity second actor PASS; true owner original PNG separately evaluated in isolated cloud")
    quit(0)
