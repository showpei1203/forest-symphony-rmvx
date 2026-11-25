extends "res://tests/test_fs_battle_accuracy_205.gd"
const BODY=preload("res://scripts/animation/FSFlowMotionBody.gd")

func _frames() -> SpriteFrames:
    var body=BODY.new()
    root.add_child(body)
    body.hide()
    for action in ["attack","run","damage","dodge","cast"]:
        if "--real-v3" in OS.get_cmdline_user_args():
            if not body.load_motion(action): return null
            continue
        var img:=Image.create_empty(256,128,false,Image.FORMAT_RGBA8)
        for i in range(8):
            var y:int=19 if action=="dodge" and i==3 else 24
            img.fill_rect(Rect2i(i%4*64+12+i,floori(i/4.0)*64+y,12,26),Color.WHITE)
        if not body.register_motion(action,img,[80,80,80,80,80,80,80,80],[3] if action=="dodge" else []):
            return null
    return body.sprite_frames

func _run() -> void:
    var b: FSBattle = _battle()
    var ui=SCREEN.new()
    ui.db=b.db
    ui.battle=b
    root.add_child(ui)
    ui.set_process(false)
    await process_frame
    var p=ui.flow_presentation
    if not _check(not p.configured and not p.visible,"default art untouched"): return
    var frames: SpriteFrames=_frames()
    if not _check(frames!=null and ui.configure_flow_candidate(frames),"explicit candidate"): return
    p.adapter.animation_player.set_process(false)
    var actor: Dictionary=b.party[0]
    var enemy: Dictionary=b.enemies[0]
    var im:=Image.create_empty(32,32,false,Image.FORMAT_RGBA8)
    im.fill(Color.WHITE)
    var tex:=ImageTexture.create_from_image(im)
    ui.enemy_stage.rebuild(b.enemies,func(_e: Dictionary)->Texture2D: return tex)
    await process_frame
    b.accuracy.scripted_rolls=[95]
    b.attack(actor,enemy)
    if not _check(p.played==1 and p.last_action=="attack" and p.visible,"actor attack on settled miss"): return
    ui._refresh_battle_status()
    if not _check(p.played==1,"redraw silent"): return
    var serial:int=p.last_serial
    p._on_outcome({"serial":serial,"result":"hit","source_side":"party","source_slot":0,"source_id":1,"action":"attack"})
    if not _check(p.played==1,"duplicate ignored"): return
    p.adapter.animation_player.advance_ms(4000)
    if not _check(not p.visible and p.adapter.animation_player.position==Vector2.ZERO,"attack finish reset"): return
    b.accuracy.scripted_rolls=[95]
    b.attack(enemy,actor)
    if not _check(p.played==1 and not p.visible,"enemy miss no dodge"): return
    b.accuracy.scripted_rolls=[0,0]
    b.attack(enemy,actor)
    if not _check(p.played==2 and p.last_action=="dodge" and p.visible,"enemy evade routed"): return
    var anchor: Vector2=p.global_position
    var source: Vector2=ui._flow_enemy_anchor(0)
    for i in range(4):
        p.adapter.animation_player.advance_ms(p.adapter.animation_player.current_frame_duration_ms())
    var delta:Vector2=p.adapter.animation_player.global_position-anchor
    if not _check(delta.length()>23.9 and delta.dot(source-anchor)<0 and p.global_position==anchor,"backstep away under mirrored parent"): return
    p.adapter.animation_player.advance_ms(4000)
    if not _check(not p.visible and p.adapter.animation_player.position==Vector2.ZERO,"dodge reset"): return
    b.accuracy.scripted_rolls=[0,99,0,3]
    b.attack(enemy,actor)
    if not _check(p.played==3 and p.last_action=="damage","positive damage routed"): return
    b.accuracy.scripted_rolls=[50]
    if not _check(b.use_skill(actor,enemy,1) and p.played==4 and p.last_action=="cast","skill miss still cast"): return
    ui._show_menu()
    if not _check(not p.visible and not p.adapter.animation_player.playing,"menu cleanup"): return
    ui._show_battle()
    if not _check(p.played==4 and p.last_serial>0,"rebind no stale replay"): return
    b.accuracy.scripted_rolls=[95]
    b.attack(actor,enemy)
    actor["hp"]=0
    p.tick_context()
    if not _check(not p.visible,"death cleanup"): return
    actor["hp"]=1000
    enemy["hp"]=1
    b.accuracy.scripted_rolls=[0,99,99,0,9]
    b.attack(actor,enemy)
    if not _check(not b.active and not p.visible and p.adapter.animation_player.position==Vector2.ZERO,"finish cleanup"): return
    print("FLOW_V4_UI_PASS cases=12 scope=%s" % ("REAL_V3" if "--real-v3" in OS.get_cmdline_user_args() else "SYNTHETIC"))
    quit(0)
