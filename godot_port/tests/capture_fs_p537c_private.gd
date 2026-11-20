extends SceneTree
# P537C private-only OpenGL evidence harness; REAL owner-only A52 and Battlers
# must be SHA-staged separately BEFORE Godot 4.7.2 --editor --quit imports.
# Never run against main working directory, E: original FS project or public CI.
const DB=preload("res://scripts/story/FSPlayableSliceData.gd")
const BATTLE=preload("res://scripts/FSBattle.gd")
const SCREEN=preload("res://scripts/FSScreen.gd")
const BATTLER_ART=preload("res://scripts/ui/FSOriginalBattlerArt.gd")
var output:String=""
var width:int=544

func _initialize()->void:
    call_deferred("_run")

func _fail(why:String)->void:
    push_error("PRIVATE P537C actual original sprite GPU QA REFUSED: "+why)
    quit(1)

func _snapshot(label:String)->bool:
    await process_frame
    await process_frame
    var img:Image=root.get_texture().get_image()
    if img==null or img.is_empty() or img.get_width()<width:
        _fail("Godot 4.7.2 OpenGL viewport unreadable "+label)
        return false
    var path:String=output.path_join("p537c_"+label+"_"+str(width)+".png")
    if img.save_png(path)!=OK:
        _fail("could not save original-art Godot GPU image "+label)
        return false
    var f:=FileAccess.open(path,FileAccess.READ)
    if f==null or f.get_length()<1200:
        _fail("native GPU image empty "+label)
        return false
    f.close()
    return true

func _run()->void:
    if OS.get_environment("FS_PRIVATE_SOURCE_QA")!="1":
        _fail("explicit private source authorization flag required")
        return
    output=OS.get_environment("FS_P537C_QA_DIR")
    if not output.begins_with("/tmp/") or not DirAccess.dir_exists_absolute(output):
        _fail("owner-authorized Linux temp output directory /tmp/... required")
        return
    width=OS.get_environment("FS_P537C_QA_WIDTH").to_int()
    if width not in [544,1088]:
        _fail("only original 544 or doubled 1088 viewport accepted")
        return
    root.size=Vector2i(width,int(float(width)*416.0/544.0))
    root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
    var art=BATTLER_ART.new()
    if not art.has_source():
        _fail("167 original owner-only Battlers not SHA-staged")
        return
    var enemy={"name":"$001","battler_hue":0,"battler_name":"$001"}
    if art.texture_for_enemy(enemy)==null:
        _fail("canonical $001 original PNG cannot render")
        return
    var db=DB.database()
    # Explicitly SYNTHETIC combat fixture (not an original Enemy.rvdata proof).
    # Original enemy sprite is chosen by its exact SOURCE NAME, never guessed ID.
    var enemyrec:Dictionary=db.record("enemies",1)
    enemyrec["battler_name"]="$001"
    enemyrec["battler_hue"]=0
    var world=DB.initial_state()
    var battle=BATTLE.new(db,world)
    battle.add_actor(1)
    battle.add_enemy(1)
    if not battle.start():
        _fail("source-shaped fixture ACT battle cannot start")
        return
    var screen=SCREEN.new()
    screen.db=db
    screen.world=world
    screen.battle=battle
    root.add_child(screen)
    if not screen.actor01_presentation.private_source_ready or (
            screen.enemy_stage.enemy_views.size()!=1) or (
            not screen.enemy_stage.visible):
        _fail("real source original 3-layer actor+source-name enemy not in Godot screen")
        return
    screen.set_process(false)
    screen.actor01_presentation.rig.set_process(false)
    if not await _snapshot("original_enemy"):
        return
    screen._process(2.0)
    if not screen._battle_actor_ready():
        _fail("real Godot ATB source did not make Actor01 ready")
        return
    if not await _snapshot("atb_ready"):
        return
    var enemy_hp:int=int(battle.enemies[0]["hp"])
    screen._do_player_attack(battle.enemies[0])
    var visual=screen.actor01_presentation
    if visual.visual_attack_count!=1 or not visual.rig.playing:
        _fail("queued ACT did not trigger original A52 visuals")
        return
    visual.rig.advance_seconds(0.63)
    if visual.rig.frame_index!=7 or visual.contact_count!=1 or (
            int(battle.enemies[0]["hp"])!=enemy_hp):
        _fail("F7 source contact must be cosmetic only, no early damage")
        return
    if not await _snapshot("a52_f7_contact"):
        return
    print("P537C genuine original VX Battler + A52 Body/Weapon/FX: native Godot 4.7.2 GPU 3/3 frames PASS at "+str(width)+" px; synthetic combat Enemy/Actor DB fixture, NOT original VX 1:1 battle parity")
    quit(0)
