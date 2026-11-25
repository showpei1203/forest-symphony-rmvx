extends SceneTree
const Adapter = preload("res://FlowBattlePresentation.gd")
const Body = preload("res://MotionBody.gd")
var events: Array[String] = []
func _initialize() -> void:
    call_deferred("run")
func fail(code: String) -> void:
    printerr(code)
    quit(1)
func fixture(n: int, air: bool = false) -> Image:
    var im := Image.create_empty(256,64*ceili(n/4.0),false,Image.FORMAT_RGBA8)
    for i in range(n):
        var y := 19 if air and i == 3 else 24
        im.fill_rect(Rect2i(i%4*64+12+i,floori(i/4.0)*64+y,12,26),Color(0.2,0.4,0.8,1.0))
    return im
func run() -> void:
    var body := Body.new()
    root.add_child(body)
    body.hide()
    var private_input := "--real-v3" in OS.get_cmdline_user_args()
    if private_input:
        for a in Adapter.ACTIONS:
            if not body.load_motion(a):
                fail("PRIVATE_LOAD_"+a); return
    else:
        for a in Adapter.ACTIONS:
            if not body.register_motion(a,fixture(8,a=="dodge"),[80,100,80,100,100,100,110,130] if a=="dodge" else [80,80,80,80,80,80,80,80], [3] if a=="dodge" else []):
                fail("FIXTURE_"+a); return
    var host := Node2D.new()
    root.add_child(host)
    host.position = Vector2(250,150)
    var adapter := Adapter.new()
    host.add_child(adapter)
    adapter.visual_finished.connect(func(a): events.append(a))
    if not adapter.configure(body.sprite_frames):
        fail("CONFIGURE"); return
    var player := adapter.animation_player
    player.set_process(false)
    if player.available_clips().size() != 5:
        fail("PROFILE"); return
    for a in Adapter.ACTIONS:
        if not adapter.start_action(a,Vector2.RIGHT):
            fail("ACTION_"+a); return
        if player.current_frame_count() != body.sprite_frames.get_frame_count(a):
            fail("COUNT_"+a); return
        for i in range(player.current_frame_count()):
            var at := body.sprite_frames.get_frame_texture(a,i) as AtlasTexture
            if player.sprite.texture != at.atlas or player.sprite.region_rect != at.region or player.sprite.offset != Vector2(0,-18) or player.sprite.flip_h or player.current_frame_duration_ms() != roundi(body.sprite_frames.get_frame_duration(a,i)*1000):
                fail("TEXTURE_"+a); return
            player.advance_ms(player.current_frame_duration_ms())
    events.clear()
    for toward in [Vector2.RIGHT,Vector2.LEFT,Vector2(1,1),Vector2(0,-1)]:
        if not adapter.present_resolved_evade("evade",toward):
            fail("DODGE_START"); return
        for i in range(8):
            var expected: Vector2 = -toward.normalized()*Adapter.BACKSTEP[i]
            if not player.position.is_equal_approx(expected) or host.position != Vector2(250,150) or adapter.position != Vector2.ZERO or player.sprite.flip_h:
                fail("DIRECTION_%d" % i); return
            player.advance_ms(player.current_frame_duration_ms())
        if player.playing or not player.position.is_equal_approx(-toward.normalized()*24):
            fail("FINISH_HOLD"); return
        adapter.reset_presentation()
        if player.position != Vector2.ZERO or host.position != Vector2(250,150):
            fail("RESET"); return
    if events != ["dodge","dodge","dodge","dodge"]:
        fail("COMPLETION"); return
    if not adapter.start_action("run") or adapter.present_resolved_evade("miss",Vector2.RIGHT) or adapter.present_resolved_evade("hit",Vector2.RIGHT) or adapter.present_resolved_evade("evade",Vector2.ZERO) or adapter.start_action("unknown") or player.clip_name != "run" or not player.playing:
        fail("REJECT_NO_INTERRUPT"); return
    var run_ms := 0
    for i in range(body.sprite_frames.get_frame_count("run")):
        run_ms += roundi(body.sprite_frames.get_frame_duration("run",i)*1000)
    player.advance_ms(run_ms*3)
    if not player.playing or player.frame_index != 0 or player.position != Vector2.ZERO:
        fail("RUN_LOOP"); return
    if not adapter.present_resolved_evade("evade",Vector2.RIGHT):
        fail("CANCEL_START"); return
    for i in range(4): player.advance_ms(player.current_frame_duration_ms())
    if player.position.x >= 0 or not adapter.start_action("attack") or player.position != Vector2.ZERO:
        fail("SWITCH_RESET"); return
    adapter.reset_presentation()
    if player.playing or host.position != Vector2(250,150):
        fail("CANCEL"); return
    print("FLOW_BATTLE_ADAPTER_PASS scope=%s actions=5 directions=4 host_unchanged=true" % ("REAL_V3" if private_input else "SYNTHETIC"))
    quit(0)
