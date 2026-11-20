extends SceneTree

# Headless native integration gate. Uses memory-only mock images so the approved
# private Actor01 artwork is never committed to this public repository.
const RIG = preload("res://scripts/animation/FSTAActorMotionRig.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool, label: String) -> bool:
    if not ok:
        push_error("T-A rig native FAIL: " + label)
        quit(1)
        return false
    return true

func _atlas(seed: float) -> Texture2D:
    var picture := Image.create_empty(256, 192, false, Image.FORMAT_RGBA8)
    picture.fill(Color(0, 0, 0, 0))
    for i in range(12):
        var left: int = i % 4 * 64
        var top: int = int(i / 4) * 64
        picture.fill_rect(Rect2i(left+12+i%4, top+14, 22, 35),
            Color(0.1 + seed, float(i+1)/13.0, 0.4, 1.0))
    return ImageTexture.create_from_image(picture)

func _run() -> void:
    var rig = RIG.new()
    root.add_child(rig)
    var contacts: Array = []
    var completes: Array = []
    var errors: Array = []
    rig.contact_reached.connect(func(t: float, f: int) -> void: contacts.append([t,f]))
    rig.motion_finished.connect(func(m: String) -> void: completes.append(m))
    rig.motion_failed.connect(func(s: String) -> void: errors.append(s))
    if not _assert(not rig.start_motion("run"), "missing atlases fail closed"): return
    if not _assert(errors.size() == 1, "missing atlases is reported"): return
    errors.clear()
    var atlas: Texture2D = _atlas(0.02)
    var blank := Image.create_empty(256, 192, false, Image.FORMAT_RGBA8)
    blank.fill(Color(0,0,0,0))
    var empty_weapon: Texture2D = ImageTexture.create_from_image(blank)
    if not _assert(not rig.configure_atlases(atlas,empty_weapon,atlas,atlas,atlas,atlas),
        "transparent RUN sword blocked before playback"): return
    if not _assert(errors.size() == 1, "missing equipped sword reported"): return
    errors.clear()
    if not _assert(rig.configure_atlases(atlas, atlas, atlas, atlas, atlas, atlas), "six layers configured"): return
    if not _assert(rig.layers().size() == 3, "body/weapon/fx remain separate"): return
    if not _assert(rig.start_motion("run"), "RUN starts"): return
    rig.advance_seconds(0.080)
    if not _assert(rig.frame_index == 1, "RUN advances frame 1"): return
    if not _assert(rig.layers()[0].region_rect.position == Vector2(64,0), "RUN 4-column atlas indexing"): return
    rig.advance_seconds(0.080*11.0)
    if not _assert(rig.frame_index == 0 and rig.playing, "RUN loops 12 frames"): return
    if not _assert(rig.start_motion("attack"), "ATTACK starts"): return
    rig.advance_seconds(0.620)
    if not _assert(rig.frame_index == 7 and contacts.is_empty(), "A52 frame F7 before contact"): return
    rig.advance_seconds(0.010)
    if not _assert(rig.frame_index == 7 and contacts.size() == 1 and contacts[0] == [0.630,7],
        "0.63 sec attack contact exactly once"): return
    if not _assert(rig.layers()[1].region_rect.position == Vector2(192,64),
        "weapon and body frame coordinates match F7"): return
    rig.advance_seconds(0.450)
    if not _assert(not rig.playing and rig.frame_index == 11, "ATTACK completes at F11"): return
    if not _assert(completes == ["attack"] and contacts.size() == 1, "exactly one completion/contact"): return
    if not _assert(rig.start_motion("attack"), "ATTACK can replay"): return
    rig.advance_seconds(0.30)
    var held: int = rig.frame_index
    rig.cancel()
    rig.advance_seconds(1.0)
    if not _assert(not rig.playing and rig.frame_index == held, "cancel prevents phantom contact"): return
    if not _assert(contacts.size() == 1 and errors.is_empty(), "no duplicate hit or errors"): return
    print("T_A_NATIVE_RIG_TEST_PASS 3x layers, RUN12, ATTACK12, F7 0.63 contact, cancel")
    quit(0)
