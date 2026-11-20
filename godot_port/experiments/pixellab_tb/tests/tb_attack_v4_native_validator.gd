extends SceneTree
## Intended Godot 4.7.2 --headless -s res://tests/tb_attack_v4_native_validator.gd
func _init() -> void:
    call_deferred("_test")
func _test() -> void:
    var root := "res://assets/monsters/tb/"
    var image := Image.load_from_file(root+"PMD0001_ATTACK_V4_11F_384x288.png")
    if image == null or image.get_width()!=384 or image.get_height()!=288:
        push_error("TB native texture dimensions incorrect")
        quit(1)
        return
    var f0 := image.get_region(Rect2i(0,0,96,96))
    var f10 := image.get_region(Rect2i(192,192,96,96))
    if f0.get_data()!=f10.get_data():
        push_error("TB native source locked endpoints mismatch")
        quit(2)
        return
    var frames := SpriteFrames.new()
    frames.remove_animation("default")
    frames.add_animation("attack")
    frames.set_animation_speed("attack",60.0)
    frames.set_animation_loop("attack",false)
    var tex := load(root+"PMD0001_ATTACK_V4_11F_384x288.png") as Texture2D
    if tex == null:
        push_error("TB native Godot atlas load failed")
        quit(3)
        return
    var durations: Array[float] = [4.0,2.0,4.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0]
    for i in 11:
        var crop := AtlasTexture.new()
        crop.atlas = tex
        crop.region = Rect2((i%4)*96, int(i/4)*96, 96, 96)
        frames.add_frame("attack",crop,durations[i])
    assert(frames.get_frame_count("attack")==11)
    assert(frames.get_frame_duration("attack",5)==2.0)
    print("TB_NATIVE_QA_PASS version=4.7.2 frame_count=11 size=96 event_hit=5")
    quit(0)
