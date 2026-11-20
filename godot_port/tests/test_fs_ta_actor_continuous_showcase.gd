extends SceneTree
# Godot 4.7.2 synthetic test; no owner-private asset in public repository/CI.
const SHOWCASE = preload("res://scripts/animation/FSTAActor01ContinuousShowcase.gd")
func _initialize() -> void:
    call_deferred("_run")
func must(condition: bool, why: String) -> bool:
    if not condition:
        push_error("TA_R4 continuous regression: " + why)
        quit(1)
        return false
    return true
func make_texture(paint: bool) -> Texture2D:
    var img := Image.create_empty(256, 192, false, Image.FORMAT_RGBA8)
    img.fill(Color.TRANSPARENT)
    if paint:
        for frame in 12:
            img.set_pixel((frame % 4) * 64 + 32, int(frame / 4) * 64 + 32, Color.WHITE)
    return ImageTexture.create_from_image(img)
func _run() -> void:
    var demo = SHOWCASE.new()
    demo.auto_load_private = false
    demo.auto_play = false
    root.add_child(demo)
    demo.set_process(false)
    var body := make_texture(true)
    var sword := make_texture(true)
    var fx := make_texture(false)
    if not must(demo.configure_for_synthetic_test(body, sword, fx, body, sword, fx),
            "synthetic six-layer atlas must pass"): return
    var phases: Array[String] = []
    var loops: Array[int] = []
    var contacts: Array[Array] = []
    demo.phase_changed.connect(func(p: String): phases.append(p))
    demo.run_loop_finished.connect(func(n: int): loops.append(n))
    demo.visual_contact.connect(func(t: float, f: int): contacts.append([t,f]))
    if not must(demo.start_sequence(2) and demo.rig.motion == "run",
            "two RUN cycles started"): return
    demo.advance_seconds(0.960)
    if not must(demo.phase == "run" and demo.completed_run_loops == 1,
            "first true 12-frame RUN completes"): return
    demo.advance_seconds(0.960)
    if not must(demo.phase == "attack" and demo.completed_run_loops == 2 and
            demo.rig.frame_index == 0, "RUN loop x2 transitions to A52 ATTACK F0"): return
    demo.advance_seconds(0.629)
    if not must(contacts.size() == 0 and demo.rig.frame_index == 7,
            "F7 pose before 0.630 must not cause premature contact"): return
    demo.advance_seconds(0.002)
    if not must(contacts.size() == 1 and absf(contacts[0][0]-0.630) < 0.0001 and
            contacts[0][1] == 7, "one original A52 F7/0.630 visual contact"): return
    demo.advance_seconds(0.500)
    if not must(demo.phase == "complete" and not demo.rig.playing and
            contacts.size() == 1 and phases == ["run","attack","complete"] and
            loops == [1,2], "sequence must complete without duplicate contact"): return
    if not must(demo.start_sequence(1), "second sequence must reuse source"): return
    demo.advance_seconds(0.300)
    demo.cancel_sequence()
    demo.advance_seconds(4.000)
    if not must(demo.phase == "cancelled" and contacts.size() == 1 and
            not demo.rig.playing, "cancel must not trigger a visual contact"): return
    if not must(demo.start_sequence(1), "large-delta test starts"): return
    demo.advance_seconds(8.0)
    if not must(demo.phase == "complete" and demo.contact_count == 1,
            "one contact only for large delta crossing RUN and ATTACK"): return
    print("TA_R4_CONTINUOUS_GODOT472_PASS RUN12x2 ATTACK12 F7_0.630 one contact, cancel, large-delta, synthetic CI")
    quit(0)
