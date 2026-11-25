extends SceneTree
const Body = preload("res://MotionBody.gd")
var actor: Body
var started: Array[String] = []
var completed: Array[String] = []
var cancelled: Array[String] = []
func _initialize() -> void:
    call_deferred("run")
func fail(code: String) -> void:
    printerr(code)
    quit(1)
func fixture(n: int) -> Image:
    var im := Image.create_empty(256,64*ceili(n/4.0),false,Image.FORMAT_RGBA8)
    for i in range(n): im.fill_rect(Rect2i(i%4*64+12+i,floori(i/4.0)*64+24,12,26),Color(0.2,0.4,0.8,1.0))
    return im
func run() -> void:
    actor = Body.new()
    root.add_child(actor)
    actor.motion_started.connect(func(a): started.append(a))
    actor.motion_completed.connect(func(a): completed.append(a))
    actor.motion_cancelled.connect(func(a): cancelled.append(a))
    var private_input := FileAccess.file_exists("res://motions/attack/motion.json")
    var fixture_mode := "--synthetic-disk" in OS.get_cmdline_user_args()
    if private_input:
        if fixture_mode and actor.load_motion("attack"):
            fail("SYNTHETIC_PROVENANCE_GATE"); return
        if not fixture_mode and FileAccess.get_sha256("res://motions/attack/body.png") != "9569bc8beac9d928be39f482faaa8f5a2289549c7bb0b099fed8072c118d3ae5":
            fail("PRIVATE_ATTACK_PIN"); return
        if not actor.load_motion("attack",fixture_mode):
            fail("PRIVATE_ATTACK_LOAD"); return
    elif not actor.register_motion("attack",fixture(8),[110,90,170,100,80,120,120,210]):
        fail("ATTACK_REGISTER"); return
    if actor.start_motion("run"):
        fail("MISSING_ACTION"); return
    if actor.register_motion("run",fixture(4),[100,100,0,100]) or actor.register_motion("bad",fixture(4),[100,100,100,100]):
        fail("INVALID_META"); return
    var clipped := fixture(4)
    clipped.set_pixel(0,49,Color.WHITE)
    if actor.register_motion("run",clipped,[100,100,100,100]):
        fail("CLIPPED"); return
    var dup := fixture(4)
    dup.blit_rect(dup.get_region(Rect2i(0,0,64,64)),Rect2i(0,0,64,64),Vector2i(64,0))
    if actor.register_motion("run",dup,[100,100,100,100]):
        fail("DUPLICATE"); return
    var fractional := fixture(4)
    fractional.set_pixel(12,24,Color(1,1,1,0.5))
    if actor.register_motion("run",fractional,[100,100,100,100]):
        fail("ALPHA"); return
    for a in ["run","damage","dodge","cast"]:
        if not actor.register_motion(a,fixture(6),[100,100,100,100,100,100]):
            fail("REGISTER "+a); return
    if actor.register_motion("attack",fixture(4),[100,100,100,100]) or actor.offset != Vector2(-32,-50):
        fail("IMMUTABILITY_OR_ANCHOR"); return
    if not actor.start_motion("run"):
        fail("START_RUN"); return
    for i in range(170): await process_frame
    if not actor.is_playing() or actor.current_action != "run" or not completed.is_empty():
        fail("RUN_LOOP"); return
    if actor.start_motion("unknown") or actor.current_action != "run":
        fail("MISSING_INTERRUPTED"); return
    for a in ["attack","damage","dodge","cast"]:
        if not actor.start_motion(a) or actor.frame != 0:
            fail("SWITCH "+a); return
        var ticks := 0
        while not actor.current_action.is_empty() and ticks < 300:
            await process_frame
            ticks += 1
        if not actor.current_action.is_empty() or actor.is_playing() or completed.back() != a:
            fail("ONESHOT "+a); return
    if started != ["run","attack","damage","dodge","cast"] or completed != ["attack","damage","dodge","cast"] or cancelled != ["run"]:
        fail("SIGNALS"); return
    if not actor.start_motion("attack") or actor.frame != 0:
        fail("REPLAY"); return
    actor.cancel_motion()
    if actor.is_playing() or cancelled != ["run","attack"]:
        fail("CANCEL"); return
    var scope := "SYNTHETIC_ONLY"
    if private_input: scope = "SYNTHETIC_DISK" if fixture_mode else "PRIVATE_ATTACK_OTHER_SYNTHETIC"
    print("FLOW_FACTORY_NATIVE_PASS scope=%s actions=5 oneshots=4 loop=1" % scope)
    quit(0)
