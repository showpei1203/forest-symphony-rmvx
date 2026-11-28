extends SceneTree
const SLICE=preload("res://scripts/story/FSShjSharedFixtureSlice.gd")
var out_dir:String

func _initialize()->void:
    call_deferred("_run")

func capture(name:String)->bool:
    var img:Image=root.get_texture().get_image()
    if img==null or img.is_empty() or img.get_width()<544 or img.get_height()<416:
        push_error("missing rendered frame "+name)
        quit(1)
        return false
    if img.save_png(out_dir.path_join(name+".png"))!=OK:
        quit(1)
        return false
    return true

func _run()->void:
    out_dir=OS.get_environment("FS_SHJ_R7_CAPTURE_DIR")
    if out_dir.is_empty():quit(1);return
    root.size=Vector2i(1088,832)
    root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
    var slice:=SLICE.new()
    slice.approved_frames=load("res://family/s%d/SpriteFrames.tres" % int(OS.get_environment("FS_SHJ_STAGE"))) as SpriteFrames
    root.add_child(slice)
    await process_frame
    await RenderingServer.frame_post_draw
    if not slice.installed or not capture("map_real_asset_fixture"):return
    for i in range(3):slice.move_one_tile(Vector2i.RIGHT)
    if not bool(slice.interact_front().get("ok",false)):quit(1);return
    slice.dialogue.advance_message()
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    if slice.pmd_stage==null or not capture("battle_real_asset_idle_fixture"):return
    var body=slice.pmd_stage.fixture_body
    slice.battle.attack(slice.battle.enemies[0],slice.battle.party[0])
    for i in range(80):
        await process_frame
        if body.animation==&"attack" and body.frame==5:
            await RenderingServer.frame_post_draw
            if not capture("battle_real_asset_attack_hit_fixture"):return
            print("FS_SHJ_R7_RENDER_PASS map/battle/attack three actual viewport captures")
            quit(0)
            return
    push_error("actual Attack hit frame not observed")
    quit(1)
