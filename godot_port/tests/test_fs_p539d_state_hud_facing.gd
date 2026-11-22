extends SceneTree
# FS original section #381 StateHUD, #462 target help, #269 exact source
# anchor; P539D owner requested opposite actor facing of all A52 layers.
const HUD=preload("res://scripts/ui/FSBattleSourceStateHUD381.gd")
const DB=preload("res://scripts/FSDatabase.gd")
const PRESENTER=preload("res://scripts/ui/FSBattleActor01Presenter.gd")
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")

func _initialize()->void:
    call_deferred("_run")

func require(ok:bool,why:String)->bool:
    if not ok:
        push_error("P539D original FS source #381 state HUD + opposite facing FAIL: "+why)
        quit(1)
        return false
    return true

func _run()->void:
    var db=DB.new()
    db.tables["states"]=[null,
        {"id":1,"name":"low","note":"","icon_index":20,"priority":1},
        {"id":2,"name":"high","note":"<hud_priority:99>","icon_index":21},
        {"id":3,"name":"hidden","note":"<HUD隱藏>","icon_index":22},
        {"id":4,"name":"show","note":"<HUD隱藏><HUD強制顯示>","icon_index":23},
        {"id":5,"name":"zero","note":"","icon_index":0},
        {"id":6,"name":"forcezero","note":"<hud_show>","icon_index":0},
        {"id":7,"name":"middle","note":"<HUD優先:5><HUD圖示:31>","icon_index":24},
        {"id":8,"name":"middle2","note":"<hud_priority:3>","icon_index":25},
        {"id":9,"name":"last","note":"","icon_index":26}]
    var actor:Dictionary={"id":1,"hp":120,"states":[1,2,3,4,5,6,7,8,9]}
    var quote:Dictionary=HUD.visible_states(actor,db)
    if not require(quote["ok"] and quote["states"].size()==7 and (
            int(quote["states"][0]["id"])==2) and (
            int(quote["states"][1]["id"])==7) and (
            int(quote["states"][2]["id"])==8) and (
            int(quote["states"][3]["id"])==1) and (
            int(quote["states"][4]["id"])==4) and (
            int(quote["states"][5]["id"])==6),
            "#381 priorities, hide, force-show and source ID tie rules"):return
    var slots:Dictionary=HUD.visible_slots(quote["states"])
    if not require(slots["shown"].size()==3 and slots["overflow"]==4 and (
            int(slots["shown"][0]["icon"])==21) and (
            int(slots["shown"][1]["icon"])==31),
            "source #381 max 4 badge slots, 3 icons plus +4 overflow"):return
    actor["states"]=[3,5]
    if not require(HUD.visible_states(actor,db)["states"].is_empty(),
            "#381 hidden notes and zero icon must both stay hidden"):return
    actor["states"]=[999]
    if not require(not bool(HUD.visible_states(actor,db)["ok"]),
            "missing original State must fail closed"):return
    if not require(HUD.source_top_left(Vector2(486,120),false)==Vector2(470,120)
            and HUD.source_top_left(Vector2(258,99),true)==Vector2(223,99)
            and HUD.MAX_ICONS==4 and HUD.ICON_SIZE==20 and (
            HUD.ICON_SPACING==20) and HUD.ICON_OPACITY==180,
            "original #381 actor(-16,+20,oy20), enemy(+45,+20,ox80,oy20)"):return
    if not require(HUD.enemy_anchor_from_rect(
            Rect2(226,60,64,78))==Vector2(258,138) and (
            HUD.source_top_left(
                HUD.enemy_anchor_from_rect(Rect2(226,60,64,78)),true
            )==Vector2(223,138)),
            "#381 badge must anchor to monster FEET, never cover its face at centre y99"):return
    var stage=HUD.new()
    root.add_child(stage)
    var source_art=ART.new()
    var private_images_available:bool=source_art.has_source()
    # Native owner GPU QA intentionally stages authentic source Iconset.
    # Public GitHub CI never does. Both modes must obey exact source gate.
    var installed:bool=stage.install(source_art,db)
    if not require(installed==private_images_available and (
            stage.source_enabled==private_images_available) and (
            not stage.visible),
            "private original Iconset must install; public synthetic mode must fail closed"):return
    var presenter=PRESENTER.new()
    root.add_child(presenter)
    if not require(presenter.rig.transform.determinant()<0 and (
            is_equal_approx(presenter.rig.scale.x,-1.0)) and (
            is_equal_approx(presenter.rig.scale.y,1.0)) and (
            is_zero_approx(presenter.rig.rotation)) and (
            presenter.rig.layers().size()==3),
            "ALL Body/Weapon/FX inherit reversed horizontal facing, never rotate upside-down"):return
    for layer in presenter.rig.layers():
        if not require(layer.get_parent()==presenter.rig and (
                not layer.flip_h),
                "cannot mirror individual layers separately/double-flip the sword"):return
    print("P539D original #381 priority/hidden/show/overflow Iconset State HUD, #462 no duplicated help icons, source actor/enemy screen offsets, and A52 all 3 layers opposite horizontal facing Godot 4.7.2 PASS")
    quit(0)
