extends SceneTree
# Real Godot 4.7.2 art-only 42-clip, 340-frame gate.
func _initialize() -> void:
    call_deferred("check")
func check() -> void:
    root.size=Vector2i(1280,900)
    var data:=JSON.parse_string(FileAccess.get_file_as_string("res://TB12_MONSTER_FAMILY_MANIFEST.json")) as Dictionary
    assert(data.get("stage_count",0)==6)
    assert(data.get("clip_count",0)==42)
    assert(data.get("total_frames",0)==340)
    var scene=load("res://tb12_gallery.tscn").instantiate()
    root.add_child(scene)
    await process_frame
    assert(scene.sprites.size()==6)
    var tested=0
    var total_frames=0
    for action in ["idle","attack","hurt","ko","guard","skill","locomotion"]:
        scene.show_action(action)
        for family_index in range(2):
            for stage_index in range(3):
                var key=("fly" if family_index==0 else "hop") if action=="locomotion" else action
                var m: Dictionary=data["families"][family_index]["stages"][stage_index]["motions"][key]
                var sprite=scene.sprites[family_index*3+stage_index]
                assert(sprite.sprite_frames != null)
                assert(sprite.sprite_frames.get_frame_count("play")==int(m["frames"]),"Missing original %s"%key)
                assert(sprite.sprite_frames.get_frame_texture("play",0).get_size()==Vector2(float(m["cell"][0]),float(m["cell"][1])))
                assert(str(m.get("art_status",""))!="" )
                tested+=1
                total_frames+=int(m["frames"])
    assert(tested==42 and total_frames==340)
    print("FS_TB_R12_GODOT472_NATIVE_ART_ONLY_PASS clips=%d frames=%d stages=6 actions=7" % [tested,total_frames])
    quit(0)
