extends SceneTree
# Real source / actual Godot 4.7.2 import and animation frame checks only.
func _initialize()->void: call_deferred("check")
func check()->void:
    var manifest := JSON.parse_string(FileAccess.get_file_as_string("res://TB10_ANIMATION_FAMILY_MANIFEST.json")) as Dictionary
    assert(manifest.get("stages",[]).size()==3)
    var scene = load("res://tb10_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene.sprites.size()==3)
    var total := 0
    for action in ["idle","attack","hurt","ko"]:
        scene.show_action(action)
        for stage in range(3):
            var m: Dictionary = manifest["stages"][stage]["motions"]
            var frames: SpriteFrames = scene.sprites[stage].sprite_frames
            assert(frames != null)
            if m.has(action):
                var f: Dictionary = m[action]
                assert(frames.get_frame_count("play") == int(f["frames"]))
                assert(frames.get_frame_texture("play",0).get_size() == Vector2(float(f["cell"][0]),float(f["cell"][1])))
                total += 1
            else:
                assert(frames.get_frame_count("play")==1)
    assert(total>=8,"R10 did not create enough real stage-specific animations")
    print("FS_TB_R10_NATIVE_ART_GALLERY_GODOT472_PASS stages=3 available_motions=%d" % total)
    quit(0)
