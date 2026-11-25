extends SceneTree
# Tests genuine pinned ATTACK and RUN only. No synthetic substitution.
const Body = preload("res://MotionBody.gd")
const ATTACK := "9569bc8beac9d928be39f482faaa8f5a2289549c7bb0b099fed8072c118d3ae5"
const RUN := "5b3d48b21e01deb6a33d6e01d2f8451f727ba6850dcdbe6d9a7acd9769f94bab"
var actor: Body
var entered: Array[int] = []
var started: Array[String] = []
var completed: Array[String] = []
var cancelled: Array[String] = []
var loops: int = 0
func _initialize() -> void:
    call_deferred("run")
func fail(code: String) -> void:
    printerr(code)
    quit(1)
func run() -> void:
    if FileAccess.get_sha256("res://motions/attack/body.png") != ATTACK or FileAccess.get_sha256("res://motions/run/body.png") != RUN:
        fail("PAIR_PIN"); return
    actor = Body.new()
    root.add_child(actor)
    if not actor.load_motion("attack") or not actor.load_motion("run"):
        fail("PAIR_LOAD"); return
    if actor.sprite_frames.get_frame_count("attack") != 8 or actor.sprite_frames.get_frame_count("run") != 8 or actor.sprite_frames.get_animation_loop("attack") or not actor.sprite_frames.get_animation_loop("run") or actor.offset != Vector2(-32,-50):
        fail("PAIR_CONTRACT"); return
    var run_image := Image.load_from_file("res://motions/run/body.png")
    run_image.convert(Image.FORMAT_RGBA8)
    for i in range(8):
        var expected := Rect2i(i%4*64,floori(i/4.0)*64,64,64)
        var frame_tex := actor.sprite_frames.get_frame_texture("run",i) as AtlasTexture
        if frame_tex == null or frame_tex.region != Rect2(expected) or not is_equal_approx(actor.sprite_frames.get_frame_duration("run",i),0.08):
            fail("PAIR_TEXTURE_OR_TIMING"); return
        var native_image := frame_tex.get_image()
        native_image.convert(Image.FORMAT_RGBA8)
        if native_image.get_data() != run_image.get_region(expected).get_data():
            fail("PAIR_PIXEL_PARITY"); return
    actor.motion_started.connect(func(a): started.append(a))
    actor.motion_completed.connect(func(a): completed.append(a))
    actor.motion_cancelled.connect(func(a): cancelled.append(a))
    actor.frame_changed.connect(func(): entered.append(actor.frame))
    actor.animation_looped.connect(func(): loops += 1)
    if not actor.start_motion("run"):
        fail("PAIR_START"); return
    entered.clear()
    var ticks := 0
    while loops < 3 and ticks < 500:
        await process_frame
        ticks += 1
    if loops != 3 or not actor.is_playing() or actor.current_action != "run" or not completed.is_empty() or ticks < 450 or ticks > 470:
        fail("PAIR_LOOP_TIMING_%d" % ticks); return
    var expected_order: Array[int] = []
    for i in range(24): expected_order.append((i+1)%8)
    if entered != expected_order:
        fail("PAIR_LOOP_SEQUENCE_%d" % entered.size()); return
    if actor.start_motion("damage") or actor.current_action != "run":
        fail("PAIR_MISSING"); return
    if not actor.start_motion("attack") or actor.frame != 0:
        fail("PAIR_SWITCH_ATTACK"); return
    entered.clear()
    ticks = 0
    while actor.current_action != "" and ticks < 260:
        await process_frame
        ticks += 1
    if actor.is_playing() or actor.frame != 7 or completed != ["attack"] or entered != [1,2,3,4,5,6,7] or ticks < 235 or ticks > 245:
        fail("PAIR_ATTACK_FINISH_%d" % ticks); return
    if not actor.start_motion("run") or actor.frame != 0 or started != ["run","attack","run"] or cancelled != ["run"]:
        fail("PAIR_RESTART"); return
    actor.cancel_motion()
    if actor.is_playing() or cancelled != ["run","run"]:
        fail("PAIR_CANCEL"); return
    print("FLOW_REAL_PAIR_NATIVE_PASS attack=8 run=8 run_loops=3 run_transitions=24 atlas_pixel_parity=8 body_only=true")
    quit(0)
