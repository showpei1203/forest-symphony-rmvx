extends SceneTree
const ART=preload("res://scripts/ui/FSUIArtLibrary.gd")
const HUD=preload("res://scripts/ui/FSUIBattleHUD.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")

func fail(why:String)->void:
    push_error("FS P535 UI art native QA failed: "+why)
    quit(1)

func _run()->void:
    var assets=ART.new()
    if assets.has_source() or assets.texture("system","iconset.png")!=null:
        fail("public GitHub QA must never claim private original art imported")
        return
    var icon0:Rect2=ART.icon_region(0,Vector2i(384,15096))
    var icon15:Rect2=ART.icon_region(15,Vector2i(384,15096))
    var icon16:Rect2=ART.icon_region(16,Vector2i(384,15096))
    var out:Rect2=ART.icon_region(999999,Vector2i(384,15096))
    if icon0.position!=Vector2.ZERO or icon15.position!=Vector2(360,0) or (
            icon16.position!=Vector2(0,24)) or out.size!=Vector2.ZERO:
        fail("original 24px iconset grid region invalid")
        return
    var ui=HUD.new()
    ui.set_art(assets)
    root.add_child(ui)
    var party=[{"name":"FS Test","hp":75,"maxhp":120,"mp":30,
        "maxmp":50,"source_atb_count":350,"source_at_active":false}]
    ui.bind_party(party)
    if ui.get_child_count()!=1 or ui._records.size()!=1:
        fail("actual Godot Control HUD missing party card")
        return
    var gauges:Dictionary=ui._records[0]["gauges"]
    var hp:ProgressBar=gauges["HP"]["bar"]
    var mp:ProgressBar=gauges["MP"]["bar"]
    var atb:ProgressBar=gauges["ATB"]["bar"]
    if not is_equal_approx(hp.value,62.5) or not is_equal_approx(mp.value,60.0) or (
            not is_equal_approx(atb.value,35.0)):
        fail("live HP/MP/ATB bars do not reflect real Actor values")
        return
    party[0]["hp"]=10
    party[0]["mp"]=0
    party[0]["source_atb_count"]=1000
    party[0]["source_at_active"]=true
    ui.refresh(party)
    if hp.value>=10.0 or mp.value!=0.0 or atb.value!=100.0:
        fail("dynamic status bar did not update HP/MP/ATB")
        return
    if not "就緒" in (gauges["ATB"]["label"] as Label).text:
        fail("real ATB READY not displayed")
        return
    var screen=SCREEN.new()
    root.add_child(screen)
    if screen.ui_art==null or screen.ui_hud==null or screen.ui_hud.visible:
        fail("real FSScreen did not construct hidden pre-battle UI HUD")
        return
    print("FS P535 Godot native original-art gate + actual HP/MP/ATB HUD + IconSet 24px atlas PASS; PRIVATE ORIGINAL IMAGE GPU STILL NOT RUN")
    quit(0)
