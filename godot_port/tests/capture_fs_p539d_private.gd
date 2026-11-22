extends SceneTree
# P539D real owner-only original 505-source Battle UI + 7 SHA-scape GPU QA.
# Native Win64 AMD/OpenGL, not public CI synthetic texture fixture.
# All image outputs and original PNGs remain G: Google Drive private.
const DB=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
var private_out:String=""
var requested_width:int=544

func _initialize()->void:
    call_deferred("_run")

func _fail(message:String)->void:
    push_error("FS P539D PRIVATE ORIGINAL BATTLE SOURCE GPU FAIL: "+message)
    quit(1)

func _snapshot(stage:String)->bool:
    await process_frame
    await process_frame
    var image:Image=root.get_texture().get_image()
    if image==null or image.is_empty() or (
            image.get_width()!=requested_width):
        _fail("native Godot OpenGL framebuffer missing at "+stage)
        return false
    var path:String=private_out.path_join(
        "P539D_FS_OriginalBattle_"+stage+"_"+str(requested_width)+".png")
    if image.save_png(path)!=OK:
        _fail("could not write source-private G Drive Godot GPU PNG")
        return false
    if not FileAccess.file_exists(path) or (
            FileAccess.get_sha256(path).length()!=64):
        _fail("source-private original GPU PNG missing")
        return false
    return true

func _pixel_delta(a:Image,b:Image,roi:Rect2i)->int:
    if a==null or b==null or a.get_size()!=b.get_size():return 0
    var changed:int=0
    for y in range(maxi(0,roi.position.y),mini(a.get_height(),roi.end.y)):
        for x in range(maxi(0,roi.position.x),mini(a.get_width(),roi.end.x)):
            var p:Color=a.get_pixel(x,y)
            var q:Color=b.get_pixel(x,y)
            if absf(p.r-q.r)+absf(p.g-q.g)+absf(p.b-q.b)>0.15:
                changed+=1
    return changed

func _run()->void:
    if OS.get_environment("FS_PRIVATE_SOURCE_QA")!="1":
        _fail("owner-private original source QA must be explicitly authorized")
        return
    private_out=OS.get_environment("FS_P539D_QA_DIR")
    var normalized:String=private_out.replace("\\","/")
    if not normalized.begins_with("G:/") or not normalized.contains(
            "/FS_PRIVATE_P539D_FACING_AND_STATEHUD_20261122/") or (
            not DirAccess.dir_exists_absolute(private_out)):
        _fail("private Godot GPU output must be owner G: cloud FS_P539D")
        return
    requested_width=OS.get_environment("FS_P539D_QA_WIDTH").to_int()
    if requested_width not in [544,1088]:
        _fail("only original VX 544 and doubled 1088 renderer QA supported")
        return
    root.size=Vector2i(requested_width,int(
        float(requested_width)*416.0/544.0))
    root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
    var db=DB.database()
    # Private source HUD269 is not a generic test-name banner. Use one
    # actual FS portrait identity, but keep ALL battle numeric DB synthetic.
    db.tables["actors"][1]["name"]="喬伊"
    # Only combat stats/Enemy1 record are synthetic source-shaped data.
    # Original BATTLE command pixels and seven source Scape images are real.
    var enemy:Dictionary=db.record("enemies",1)
    enemy["battler_name"]="$001"
    enemy["battler_hue"]=0
    var world=DB.initial_state()
    world.map_id=12
    world.set_variable(1000,2)
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_enemy(1)
    if not battle.start():
        _fail("original battle source-shape candidate not active")
        return
    var scene=SCREEN.new()
    scene.db=db
    scene.world=world
    scene.battle=battle
    scene.selected_troop_id=12
    root.add_child(scene)
    var scape=scene.original_scape
    var commands=scene.original_commands
    if scape==null or scape.planes.size()!=2 or (
            scape.last_scape_ids!=[14,3]) or not scape.visible:
        _fail("source #264 exact troop12 BattleScape [14,3] not rendered")
        return
    if commands==null or not commands.source_enabled or (
            commands.source_buttons.size()!=5) or (
            scene.battle_command_grid.visible):
        _fail("source #232/#268 authentic five vertical commands unavailable")
        return
    if not commands.source_buttons[4].disabled:
        _fail("source Escape artwork must NOT run unverified gameplay")
        return
    if scene.source_skin_hud==null or (
            not scene.source_skin_hud.source_enabled) or (
            not scene.source_skin_hud.visible) or scene.ui_hud.visible:
        _fail("source #269 original HUD/portrait not replacing generic top HFlow")
        return
    if scene.title_label.visible or scene.tab_bar.visible or (
            scene.developer_scroll.visible) or scene.log_label.visible:
        _fail("old Godot debug tabs/status and return MENU overlay original battle")
        return
    if not scene.actor01_presentation.private_source_ready or (
            scene.enemy_stage.enemy_views.size()!=1):
        _fail("source A52 actor + original source Battler missing")
        return
    for view in scene.enemy_stage.enemy_views:
        if view["caption"].visible:
            _fail("#462 target-help enemy name cannot be permanently stamped across original #381 status icons")
            return
    for btn in commands.source_buttons:
        var bounds:Rect2=btn.get_global_rect()
        if not Rect2(Vector2.ZERO,Vector2(544,416)).encloses(bounds):
            _fail("source #268 original 5 sprites clipped from 544 game space")
            return
    scene.set_process(false)
    scene.actor01_presentation.rig.set_process(false)
    await process_frame
    await process_frame
    # Verify real art changes physical framebuffer, not just exists in nodes.
    scape.visible=false
    await process_frame
    await process_frame
    var blank:Image=root.get_texture().get_image()
    scape.visible=true
    await process_frame
    await process_frame
    var full:Image=root.get_texture().get_image()
    var region:Rect2i=Rect2i(Vector2i.ZERO,
        Vector2i(requested_width,int(float(requested_width)*190.0/544.0)))
    var backdrop_ink:int=_pixel_delta(blank,full,region)
    if backdrop_ink<250:
        _fail("source original new_back01+ffog pixels not visible on physical GPU")
        return
    # Original 135x135 portrait + #269 bottom-source Btskin status
    # need REAL GPU pixels (not just Texture2D installed and node visible).
    scene.source_skin_hud.visible=false
    await process_frame
    await process_frame
    var hud_baseline:Image=root.get_texture().get_image()
    scene.source_skin_hud.visible=true
    await process_frame
    await process_frame
    var hud_actual:Image=root.get_texture().get_image()
    var ratio:float=float(requested_width)/544.0
    var hud_rect:Rect2i=Rect2i(Vector2i(int(9.0*ratio),
        int(249.0*ratio)),Vector2i(int(135.0*ratio),int(162.0*ratio)))
    var hud_pixels:int=_pixel_delta(hud_baseline,hud_actual,hud_rect)
    if hud_pixels<300:
        _fail("original #269 source portrait/skin did not affect actual GPU")
        return
    if not await _snapshot("source_troop12_idle"):
        return
    scene._process(2.0)
    if not scene._battle_actor_ready():
        _fail("real FS Tankentai source ATB did not ready actor")
        return
    if not await _snapshot("source_ATB_READY"):
        return
    var enemy_hp:int=int(battle.enemies[0]["hp"])
    scene._do_player_attack(battle.enemies[0])
    if scene.actor01_presentation.visual_attack_count!=1:
        _fail("ACT queued original A52 animation did not start")
        return
    scene.actor01_presentation.rig.advance_seconds(0.63)
    if scene.actor01_presentation.rig.frame_index!=7 or (
            scene.actor01_presentation.contact_count!=1) or (
            int(battle.enemies[0]["hp"])!=enemy_hp):
        _fail("A52 visual F7 must have one presentation-only contact")
        return
    if not await _snapshot("source_A52_F7"):
        return
    # User-corrected A52 source facing: 180-degree opposite LOOK direction
    # is horizontal reflection, not a literal upside-down 180 rotation.
    var rig=scene.actor01_presentation.rig
    if rig.transform.determinant()>=0 or rig.rotation!=0.0:
        _fail("A52 Body/Weapon/FX are not ALL horizontally mirrored")
        return
    rig.scale=Vector2(1,1)
    await process_frame
    await process_frame
    var before_facing:Image=root.get_texture().get_image()
    if not await _snapshot("wrong_horizontal_facing_reference"):
        return
    rig.scale=Vector2(-1,1)
    await process_frame
    await process_frame
    var after_facing:Image=root.get_texture().get_image()
    var face_roi:=Rect2i(Vector2i(int(440.0*ratio),int(70.0*ratio)),
        Vector2i(int(100.0*ratio),int(130.0*ratio)))
    var face_pixels:int=_pixel_delta(before_facing,after_facing,face_roi)
    if face_pixels<15:
        _fail("original A52 horizontal mirror did NOT change real GPU actor/weapon/fx")
        return
    if not await _snapshot("correct_opposite_facing_A52_F7"):
        return
    # #381: seed ONE explicitly synthetic state only AFTER the ATB/ACT
    # witness has completed. Native source Iconset pixels must appear
    # near the real Enemy TextureRect anchor (not arbitrary screen coords).
    var new_states:Array=[]
    new_states.resize(32)
    new_states[30]={"id":30,"name":"Test source state",
        "icon_index":21,"priority":4,"note":"<hud_priority:7>"}
    db.tables["states"]=new_states
    battle.enemies[0]["states"]=[30]
    scene._refresh_source_state_hud()
    # Compare SOURCE #381 actual enemy badge anchor against its feet
    # baseline. Rendering 20px over the monster's face is an ART FAIL.
    var image_rect:Rect2=scene.enemy_stage.enemy_views[0]["image"].get_global_rect()
    var feet:Vector2=Vector2(image_rect.get_center().x,image_rect.end.y)
    var badge_pos:Vector2=scene.source_state_hud.entries[0]["position"] if (
        scene.source_state_hud!=null and not scene.source_state_hud.entries.is_empty()
    ) else Vector2(-999,-999)
    if badge_pos.distance_to(feet+Vector2(-35,0))>1.0:
        _fail("#381 state icon incorrectly covers enemy face; source battler_y must be feet")
        return
    if scene.source_state_hud==null or (
            not scene.source_state_hud.source_enabled) or (
            scene.source_state_hud.entries.size()!=1):
        _fail("source #381 real original Iconset enemy badge missing")
        return
    scene.source_state_hud.visible=false
    await process_frame
    await process_frame
    var hidden_state:Image=root.get_texture().get_image()
    scene.source_state_hud.visible=true
    await process_frame
    await process_frame
    var visible_state:Image=root.get_texture().get_image()
    var state_roi:=Rect2i(Vector2i(int(190.0*ratio),int(65.0*ratio)),
        Vector2i(int(180.0*ratio),int(115.0*ratio)))
    var state_pixels:int=_pixel_delta(hidden_state,visible_state,state_roi)
    if state_pixels<45:
        _fail("real GPU source #381 original State Iconset pixels absent")
        return
    if not await _snapshot("source381_status_icon_visible"):
        return
    if int(battle.enemies[0]["hp"])!=enemy_hp:
        _fail("State HUD and horizontal mirror must never mutate combat HP")
        return
    print("P539D PRIVATE ORIGINAL 7-SOURCE SCAPE+FIVE SOURCE COMMANDS+"
        +"A52 BODY/WEAPON/FX+SOURCE ENEMY: Godot 4.7.2 native GPU 6/6 "
        +str(requested_width)+" px PASS; source backdrop pixels="
        +str(backdrop_ink)+", source #269 HUD pixels="
        +str(hud_pixels)+", real face mirrored GPU pixels="+str(face_pixels)
        +", original #381 Iconset pixels="+str(state_pixels)
        +". Synthetic combat DB; not final 505-alias parity.")
    quit(0)
