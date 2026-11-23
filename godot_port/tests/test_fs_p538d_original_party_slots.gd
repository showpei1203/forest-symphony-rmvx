extends SceneTree
# P538D M2/M4: exact ORIGINAL source-image frame-coordinate contract,
# but using generated COLOR textures in PUBLIC Godot CI. No private pixels.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const PAGE=preload("res://scripts/ui/FSOriginalMenuPage.gd")

class SyntheticArt extends FSUIArtLibrary:
    var cache:Dictionary={}
    func texture(category:String,filename:String)->Texture2D:
        var key:String=category+"/"+filename
        if cache.has(key):
            return cache[key]
        var dims:=Vector2i.ZERO
        if category=="system" and filename.begins_with("MenuBack"):
            dims=Vector2i(544,416)
        elif category=="menu" and filename.begins_with("menu_"):
            dims=Vector2i(252,312)
        elif category=="menu" and filename.begins_with("Menu0"):
            dims=Vector2i(50,20)
        elif category=="menu" and filename.begins_with("Equip"):
            dims=Vector2i(60,20)
        if dims==Vector2i.ZERO:
            return null
        var pixels:=Image.create(dims.x,dims.y,false,Image.FORMAT_RGBA8)
        pixels.fill(Color(0.18,0.4,0.43,0.8))
        var t:=ImageTexture.create_from_image(pixels)
        cache[key]=t
        return t

func _initialize()->void:
    call_deferred("_run")

func ensure(ok:bool,message:String)->bool:
    if ok:
        return true
    push_error("P538D native QA FAIL: "+message)
    quit(1)
    return false

func _run()->void:
    var db=DATA.database()
    var names:Array[String]=["喬伊","米亞","泰勒","艾薇","薇娜","艾卓"]
    db.tables["actors"][1]["name"]=names[0]
    for i in range(1,names.size()):
        var actor:Dictionary=db.tables["actors"][1].duplicate(true)
        actor["id"]=i+1
        actor["name"]=names[i]
        actor["initial_level"]=4+i
        db.tables["actors"].append(actor)
    var world=DATA.initial_state()
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
    screen.ui_art=SyntheticArt.new()
    var page:FSOriginalMenuPage=screen.source_page_overlay
    for resolution in [Vector2i(544,416),Vector2i(1088,832)]:
        root.size=resolution
        screen.size=Vector2(resolution)
        screen._layout_source_menu()
        await process_frame
        screen._show_formation()
        if not ensure(page.visible and page.source_ready and
                page.page_kind=="formation","six-source actor formation visible"):
            return
        for i in range(3):
            var slot:Control=page.get_node("FSOriginalCurrentSlot_"+str(i))
            var frame:Rect2=PAGE.PARTY_CURRENT_SLOTS[i]
            if not ensure(slot is TextureButton and
                    (slot as TextureButton).texture_normal!=null,
                    "current slot "+str(i)+" uses verified-identity art selector"):
                return
            if not ensure(slot.position==frame.position and
                    slot.size==frame.size and
                    slot.position.y+slot.size.y<=142,
                    "current slot "+str(i)+" must fit source 544x416 frame"):
                return
        var reserve:ScrollContainer=page.get_node("FSOriginalReserveSquad")
        if not ensure(reserve.position==PAGE.PARTY_RESERVE_RECT.position and
                reserve.size==PAGE.PARTY_RESERVE_RECT.size and
                reserve.position.y>=361,
                "reserve list must not overlap source Reserve Squad caption"):
            return
        var rows:HBoxContainer=reserve.get_node("FSOriginalReserveRows")
        if not ensure(rows.get_child_count()==3,
                "independent 6 actors means 3 source current + 3 reserve"):
            return
    # Native interaction via ACTUAL source window buttons/signals, not
    # directly calling the formation model or faking world.party_actor_ids.
    var first:TextureButton=page.get_node("FSOriginalCurrentSlot_0")
    first.pressed.emit()
    if not ensure(screen.formation_first==0 and
            page.get_node_or_null("FSOriginalFormationSelectedHint")!=null,
            "original first slot signal must mark selected member"):
        return
    var reserve_rows:HBoxContainer=page.get_node(
        "FSOriginalReserveSquad/FSOriginalReserveRows")
    var other:Button=reserve_rows.get_child(2)
    other.pressed.emit()
    if not ensure(screen.formation_first==-1 and
            world.party_actor_ids==[6,2,3,4,5,1] and
            int(battle.party[0].get("id",0))==6,
            "real last reserve member must swap and save into GameState"):
        return

    # Real denied equipment source route: previous P538C implementation
    # emitted feedback and THEN rebuilt the candidate page, erasing it.
    screen.actor_index=0
    screen._show_equipment_candidates(0)
    if not ensure(page.page_kind=="equipment_candidates",
            "equipment candidate source page"):
        return
    screen._source_page_equipment_selected(0,999999)
    if not ensure(page.visible and page.page_kind=="equipment_candidates" and
            page.feedback_label!=null and page.feedback_label.visible and
            page.feedback_label.text.contains("拒絕"),
            "denied equip must be visible on the *new* candidate page"):
        return
    if not ensure(world.party_actor_ids==[6,2,3,4,5,1],
            "denied equip must not revert formation"):
        return
    print("P538D official Godot4.7.2 native 544+1088 real-source-frame GEOMETRY (synthetic textures), 6 actor current-reserve button signals and rejected equip UI PASS; PRIVATE SOURCE PNG SCREENSHOTS NOT RUN")
    quit(0)
