extends SceneTree
# P538B complete 5-page source UI routing. Public CI proves fail-closed;
# owner-only FS_PRIVATE_UI_QA=1 additionally proves real source sprites.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const PAGE=preload("res://scripts/ui/FSOriginalMenuPage.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func check(ok:bool,detail:String)->bool:
    if ok:
        return true
    push_error("P538B source page native FAIL: "+detail)
    quit(1)
    return false

func _run()->void:
    var private_mode:bool=OS.get_environment("FS_PRIVATE_UI_QA")=="1"
    var art=ART.new()
    var db=DATA.database()
    db.tables["actors"][1]["name"]="喬伊"
    var actor_two:Dictionary=db.tables["actors"][1].duplicate(true)
    actor_two["id"]=2
    actor_two["name"]="米亞"
    db.tables["actors"].append(actor_two)
    var world=DATA.initial_state()
    world.party_actor_ids.append(2)
    world.gain_item("item",1,2)
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_actor(2)
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    var sections=["status","skills","items","equipment","formation"]
    for kind in sections:
        match kind:
            "status":screen._show_status()
            "skills":screen._show_skills()
            "items":screen._show_items()
            "equipment":screen._show_equipment()
            "formation":screen._show_formation()
        var overlay:FSOriginalMenuPage=screen.source_page_overlay
        if not check(overlay.visible==private_mode,
                kind+" requires actual SHA-verified original art"):
            return
        if private_mode:
            if not check(overlay.page_kind==kind and overlay.source_ready and
                    overlay.action_buttons.size()>0 and
                    not screen.developer_scroll.visible and
                    not screen.tab_bar.visible,
                    kind+" must be a functional source-styled page, not debug UI"):
                return
            if not check(screen.original_background.texture!=null and
                    screen.original_background.texture.get_size()==Vector2(544,416),
                    kind+" source background must be 544x416"):
                return
        elif not check(screen.developer_scroll.visible and
                overlay.action_buttons.is_empty(),
                kind+" public missing-source fallback must stay functional"):
            return
    if private_mode:
        screen._show_status()
        screen._source_page_actor(1)
        if not check(screen.actor_index==1 and
                screen.source_page_overlay.displayed_portrait!=null and
                screen.source_page_overlay.displayed_portrait.texture!=null,
                "second original Mia portrait/actor navigation"):
            return
        screen._show_items()
        screen._source_page_item(1)
        if not check(screen.source_page_overlay.page_kind=="item_targets" and
                screen.source_page_overlay.visible and
                screen.source_page_overlay.action_buttons.size()>1,
                "source-backed item target selection"):
            return
        var amount_before:int=world.amount("item",1)
        screen._source_page_item_target(1,0)
        if not check(world.amount("item",1)==amount_before and
                screen.source_page_overlay.page_kind=="items",
                "unverified synthetic item cannot be consumed"):
            return
    screen._show_formation()
    screen._formation_clicked(0)
    screen._formation_clicked(1)
    if not check(int(battle.party[0].get("id",0))==2 and
            world.party_actor_ids==[2,1],
            "native formation swap must use existing FSMenuModel"):
        return
    if private_mode and not check(screen.source_page_overlay.visible and
            screen.source_page_overlay.page_kind=="formation",
            "source UI must survive formation refresh"):
        return
    print("P538B Godot4.7.2 source MENU full-pages, second actor, item and formation QA PASS; owner-only artwork="+str(private_mode))
    quit(0)
