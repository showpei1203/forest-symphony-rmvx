extends SceneTree
# P538A source-original menu commands, 4 page tabs and safety/regression.
# FS_PRIVATE_UI_QA=1 only in isolated owner-only original artwork test.
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const OVERLAY=preload("res://scripts/ui/FSOriginalMenuOverlay.gd")
const DATA=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func require(condition:bool,info:String)->bool:
    if condition:
        return true
    push_error("P538A MENU native QA failed: "+info)
    quit(1)
    return false

func _run()->void:
    var private_mode:bool=OS.get_environment("FS_PRIVATE_UI_QA")=="1"
    var art=ART.new()
    var nav=OVERLAY.new()
    root.add_child(nav)
    if not require(nav.configure(art,[],false)==private_mode,
            "private SHA-gated 202 original PNG required for source menu"):
        return
    if private_mode:
        if not require(nav.source_ready and nav.command_buttons.size()==8,
                "all eight original Menu source images must load"):
            return
        for i in range(8):
            var icon:TextureButton=nav.command_buttons[i]
            if not require(icon.texture_normal.get_size()==Vector2(50,20)
                    and icon.disabled==(i>=5),
                    "source art 50x20 + unported Quest/Save/System disabled "+str(i)):
                return
    elif not require(not nav.source_ready and nav.command_buttons.is_empty(),
            "public repository without source art must fail closed"):
        return
    var db=DATA.database()
    var world=DATA.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    var before_name:String=str(battle.party[0].get("name",""))
    var screen=SCREEN.new()
    screen.db=db
    screen.battle=battle
    screen.world=world
    root.add_child(screen)
    screen._show_menu()
    if not require(screen.source_menu_overlay.visible==private_mode,
            "authentic source menu visibility only on private source"):
        return
    if not require(before_name==str(battle.party[0].get("name","")),
            "menu render must not mutate actual actor dictionary"):
        return
    for pair in [[0,"物品"],[1,"角色狀態"],[2,"技能"],[3,"裝備"],[4,"編隊"]]:
        screen._source_menu_command(int(pair[0]))
        if not require(str(pair[1]) in screen.title_label.text and
                not screen.source_menu_overlay.visible,
                "every original menu art action routes existing UI only"):
            return
    screen._source_menu_command(5)
    if not require("尚未通過" in screen.log_label.text,
            "unsupported Quest / Save / System fail closed"):
        return
    for section in ["status","skills","items","equipment"]:
        match section:
            "status":screen._show_status()
            "skills":screen._show_skills()
            "items":screen._show_items()
            "equipment":screen._show_equipment()
        var tab:Node=screen.body.find_child("FSOriginal_"+section+"_tabs",true,false)
        if not require((tab!=null)==private_mode,
                "source page tabs use original private source only: "+section):
            return
    screen._show_menu()
    if not require(screen.source_menu_overlay.visible==private_mode,
            "returning to source original MENU must restore current party"):
        return
    print("P538A Godot4.7.2 native source-original Menu01..08/action-page-tabs/failclosed PASS; private art="+str(private_mode))
    quit(0)
