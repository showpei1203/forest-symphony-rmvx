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
    var owner_original_staged:bool=FileAccess.file_exists(
        "res://assets/battlers/$001.png")
    if not check(loader.has_source()==owner_original_staged,
            "public CI is asset-free, owner GPU has SHA-pinned real Battler source"):
        return
    var source_image:Texture2D=loader.texture_for_enemy({
        "battler_name":"$001","battler_hue":0})
    if not check((source_image!=null)==owner_original_staged,
            "private real original source only, public must fail closed"):return
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
    if owner_original_staged:
        # Original source #462 name is in target help, not a permanent
        # debug caption covering the original #381 enemy State badges.
        battle.enemies[0]["battler_name"]="$001"
        battle.enemies[0]["battler_hue"]=0
        if not check(node.bind_real(battle)==1 and (
                not node.enemy_views[0]["caption"].visible),
                "owner-private original Battler must have NO permanent debug-name label"):return
        node.clear_enemies()
    var screen=SCREEN.new()
    root.add_child(screen)
    screen.db=data
    screen.world=world
    screen.battle=battle
    screen._show_battle()
    if not check(screen.size.x>=530.0 and not screen.status_label.visible,
            "battle screen must fill game window and keep source 2x2 commands visible"):
        return
    if not check(screen.enemy_stage!=null and not screen.enemy_stage.visible,
            "public original BATTLE should remain fail-closed without private assets"):
        return
    print("P537C native real FSBattle enemy stage, source name-only lookup, dead-enemy hide, public private-source gate PASS; synthetic texture fixture ONLY")
    quit(0)
