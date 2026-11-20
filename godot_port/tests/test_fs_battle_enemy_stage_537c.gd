extends SceneTree
const ART=preload("res://scripts/ui/FSOriginalBattlerArt.gd")
const STAGE=preload("res://scripts/ui/FSBattleOriginalEnemyStage.gd")
const DB=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")

func _initialize()->void:
    call_deferred("_run")
func check(condition:bool,why:String)->bool:
    if not condition:
        push_error("P537C Godot 4.7.2 original Battler stage fail: "+why)
        quit(1)
        return false
    return true
func texture_for_fixture(_enemy:Dictionary)->Texture2D:
    var image=Image.create(24,24,false,Image.FORMAT_RGBA8)
    image.fill(Color(0.1,0.5,0.2,1.0)) # Synthetic test only, not FS artwork.
    return ImageTexture.create_from_image(image)
func _run()->void:
    var loader=ART.new()
    if not check(not loader.has_source(),"private owner-only Battlers must not be in GitHub CI"):
        return
    if not check(loader.texture_for_enemy({
            "battler_name":"$001","battler_hue":0})==null,
            "no source PNG in public CI must mean no original enemy art"):return
    if not check(not ART._safe_name("../../evil.png") and not (
            ART._safe_name("$001/evil.png")) and (
            ART._safe_name("$騎狼矮人.png")),
            "original Unicode filename and path traversal guard"):return
    var node=STAGE.new()
    root.add_child(node)
    var enemies:Array=[
        {"id":7,"name":"測試木靈","battler_name":"$001","hp":100},
        {"id":8,"name":"失去生命","battler_name":"$002","hp":0}]
    var drawn=node.rebuild(enemies,Callable(self,"texture_for_fixture"))
    if not check(drawn==2 and node.enemy_views.size()==2,
            "native 2D stage must support actual source-shaped enemies"):return
    if not check(node.enemy_views[0]["view"].visible and not (
            node.enemy_views[1]["view"].visible),
            "dead enemy must not keep an active Battler sprite"):return
    enemies[0]["hp"]=0
    node.refresh(enemies)
    if not check(not node.visible,"battle end must remove all dead enemy visuals"):return
    node.clear_enemies()
    if not check(node.enemy_views.is_empty() and not node.visible,
            "enemy stage clearing/reset failed"):return
    var data=DB.database()
    var world=DB.initial_state()
    var battle=BATTLE.new(data,world)
    battle.add_actor(1)
    battle.add_enemy(1)
    battle.start()
    var screen=SCREEN.new()
    root.add_child(screen)
    screen.db=data
    screen.world=world
    screen.battle=battle
    screen._show_battle()
    if not check(screen.enemy_stage!=null and not screen.enemy_stage.visible,
            "public original BATTLE should remain fail-closed without private assets"):
        return
    print("P537C native real FSBattle enemy stage, source name-only lookup, dead-enemy hide, public private-source gate PASS; synthetic texture fixture ONLY")
    quit(0)
