extends SceneTree

const FS_ATLAS = preload("res://tools/sprite_gen_fs/FSSpriteGenAtlas.gd")


func _initialize() -> void:
    var img := Image.create(128, 64, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    img.fill_rect(Rect2i(12, 15, 28, 37), Color(0.8, 0.4, 0.2, 1.0))
    img.fill_rect(Rect2i(76, 15, 28, 37), Color(0.8, 0.5, 0.2, 1.0))
    var tex := ImageTexture.create_from_image(img)
    var sidecar := {
        "schema": "fs-sprite-gen-atlas/v1",
        "technical_qa": "PASS", "art_gate": "HOLD",
        "atlas_size": [128, 64],
        "states": {"ATTACK": {"fps": 12.0, "loop": false,
            "frames": [
                {"region": [0, 0, 64, 64], "duration_ms": 83.33},
                {"region": [64, 0, 64, 64], "duration_ms": 83.33}
            ]}}
    }
    var frames: SpriteFrames = FS_ATLAS.build_sprite_frames(tex, sidecar)
    if frames == null or not frames.has_animation("ATTACK"):
        push_error("FS sprite-gen native adapter failed to create ATTACK")
        quit(2)
        return
    if frames.get_frame_count("ATTACK") != 2 or frames.get_animation_loop("ATTACK"):
        push_error("FS sprite-gen native adapter wrong count or loop")
        quit(2)
        return
    if not is_equal_approx(frames.get_animation_speed("ATTACK"), 12.0):
        push_error("FS sprite-gen native adapter wrong FPS")
        quit(2)
        return
    var cell: Texture2D = frames.get_frame_texture("ATTACK", 1)
    if cell == null or cell.get_width() != 64 or cell.get_height() != 64:
        push_error("FS sprite-gen native adapter wrong cell")
        quit(2)
        return
    print("FS_SPRITE_GEN_GODOT472_SYNTHETIC_ADAPTER_PASS frames=2 loop=false art=HOLD")
    quit(0)
