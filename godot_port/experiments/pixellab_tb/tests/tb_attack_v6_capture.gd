extends SceneTree
const FRAME_START := [0,4,6,10,12,14,16,18,20,22,24]
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var atlas := OS.get_environment("TB_PRIVATE_ATLAS")
    var cap := OS.get_environment("TB_NATIVE_CAPTURE_DIR")
    if atlas == "":atlas="res://assets/monsters/tb/PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png"
    if cap == "":cap="user://tb_capture"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(cap))
    var window := get_root()
    window.size = Vector2i(480,480)
    var bg := ColorRect.new()
    bg.color = Color("20252a")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    window.add_child(bg)
    var pl=preload("res://tb_attack_timeline.gd").new()
    pl.texture_path=atlas
    pl.position=Vector2(240,210)
    pl.scale=Vector2(4,4)
    window.add_child(pl)
    pl.set_process(false)
    await process_frame
    if pl.sprite == null:
        push_error("Failed atlas " + atlas)
        quit(30)
        return
    for i in range(11):
        pl.cancel_attack()
        if not pl.play_attack():
            push_error("No play")
            quit(31)
            return
        pl.advance_seconds(float(FRAME_START[i])/60.0)
        if pl.frame_index != i:
            push_error("Frame mismatch")
            quit(32)
            return
        for k in 3: await process_frame
        var img=window.get_texture().get_image()
        if img==null or img.is_empty():
            quit(33)
            return
        var file=cap.path_join("GODOT_TB_V6_%02d.png" % i)
        if img.save_png(file)!=OK:
            quit(34)
            return
    print("TB_V6_GODOT_472_11_NATIVE_RENDER_PASS REAL_PRIVATE_ATLAS; ART_GATE_HOLD")
    quit(0)
