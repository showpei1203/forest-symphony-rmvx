extends SceneTree
const ATLAS := "res://assets/monsters/tb/PMD0001_ATTACK_V5_11F_384x288.png"
const FRAME_START := [0,4,6,10,12,14,16,18,20,22,24]
func _init() -> void:
    call_deferred("_run")
func _run() -> void:
    var capture_dir := OS.get_environment("TB_NATIVE_CAPTURE_DIR")
    if capture_dir == "":
        capture_dir = "user://tb_native_capture"
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_dir))
    var window := get_root()
    window.size = Vector2i(480,480)
    var bg := ColorRect.new()
    bg.color = Color("20252a")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    window.add_child(bg)
    var player = preload("res://tb_attack_timeline.gd").new()
    player.texture_path = ATLAS
    player.position = Vector2(240,210)
    player.scale = Vector2(4,4)
    window.add_child(player)
    player.set_process(false)
    await process_frame
    if player.sprite == null:
        push_error("Missing V5 private real atlas")
        quit(30)
        return
    for i in range(11):
        player.cancel_attack()
        if not player.play_attack():
            push_error("Cannot start real attack frame %d" % i)
            quit(31)
            return
        player.advance_seconds(float(FRAME_START[i])/60.0)
        if player.frame_index != i:
            push_error("Time/frame mismatch %d at %d" % [player.frame_index, i])
            quit(32)
            return
        for t in 3:
            await process_frame
        var screenshot = window.get_texture().get_image()
        if screenshot == null or screenshot.is_empty():
            push_error("No image readback for %d" % i)
            quit(33)
            return
        var path = capture_dir.path_join("GODOT_NATIVE_V5_%02d.png" % i)
        var err=screenshot.save_png(path)
        if err != OK:
            push_error("native frame save error %d" % err)
            quit(34)
            return
    print("TB_V5_11_NATIVE_RENDER_PASS 4.7.2 real PRIVATE atlas 11 frames saved="+capture_dir)
    quit(0)
