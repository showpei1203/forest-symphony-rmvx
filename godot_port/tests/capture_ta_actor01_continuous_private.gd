extends SceneTree
# T-A official Godot 4.7.2 native OpenGL/Mesa real-source 60Hz timeline.
# Body/Weapon/FX 6 atlases staged ONLY from owner-private Drive.
const DEMO = preload("res://scripts/animation/FSTAActor01ContinuousShowcase.gd")
const FPS: int = 60
const TOTAL: int = 180
var viewport: SubViewport
var demo: FSTAActor01ContinuousShowcase
func _initialize() -> void:
    call_deferred("_run")
func fail(reason: String) -> void:
    push_error("TA_R4_REAL_SOURCE_FAIL " + reason)
    quit(1)
func _run() -> void:
    var folder: String = OS.get_environment("TA_QA_DIR")
    if folder.is_empty() or DirAccess.make_dir_recursive_absolute(folder) != OK:
        fail("TA_QA_DIR is required")
        return
    viewport = SubViewport.new()
    viewport.name = "TAActor01NativeFull60Hz"
    viewport.size = Vector2i(64, 64)
    viewport.transparent_bg = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    demo = DEMO.new()
    demo.auto_load_private = false
    demo.auto_play = false
    demo.position = Vector2(32,32)
    viewport.add_child(demo)
    demo.set_process(false)
    if not demo.load_private_sources():
        fail("Six private source SHA locks failed")
        return
    var phases: Array[String] = []
    var contacts: Array[Array] = []
    var loops: Array[int] = []
    demo.phase_changed.connect(func(p: String): phases.append(p))
    demo.visual_contact.connect(func(t: float, f: int): contacts.append([t,f]))
    demo.run_loop_finished.connect(func(n: int): loops.append(n))
    if not demo.start_sequence(2):
        fail("Real source RUN failed to start")
        return
    var timeline: Array[Dictionary] = []
    for i in range(TOTAL + 1):
        if i > 0:
            demo.advance_seconds(1.0 / float(FPS))
        await process_frame
        await RenderingServer.frame_post_draw
        var captured: Image = viewport.get_texture().get_image()
        if captured == null or captured.get_size() != Vector2i(64,64):
            fail("Bad native GPU frame " + str(i))
            return
        var dest: String = "%s/%03d.png" % [folder, i]
        if captured.save_png(dest) != OK:
            fail("Native frame could not be saved " + dest)
            return
        timeline.append({"tick":i,"time_s":float(i)/float(FPS),"phase":demo.phase,
            "frame":demo.rig.frame_index,"contact_count":demo.contact_count,
            "run_loops":demo.completed_run_loops})
    if not (demo.phase == "complete" and demo.contact_count == 1 and
            phases == ["run","attack","complete"] and loops == [1,2] and
            contacts.size() == 1 and absf(contacts[0][0]-0.630) < 0.0001 and
            contacts[0][1] == 7):
        fail("Continuous real source timeline/contact verification failed")
        return
    var manifest: Dictionary = {"engine":Engine.get_version_info(),"fps":FPS,
        "frame_count":TOTAL+1,"capture":"Godot native GL 64px viewport",
        "original_private_source_sha":DEMO.SOURCE_SHA,"phases":phases,"run_loops":loops,
        "attack_visual_contacts":contacts,"timeline":timeline,
        "presentation_only_no_battle_damage":true,"art_gate":"ART_HOLD"}
    var out: FileAccess = FileAccess.open(folder.path_join("native_timeline.json"),FileAccess.WRITE)
    if out == null:
        fail("Cannot store native timeline")
        return
    out.store_string(JSON.stringify(manifest, "  "))
    out.close()
    print("TA_R4_PRIVATE_CONTINUOUS_NATIVE_GPU_PASS 181/181 frames, real RUN12x2 + A52 ATTACK12, F7 0.630 once")
    quit(0)
