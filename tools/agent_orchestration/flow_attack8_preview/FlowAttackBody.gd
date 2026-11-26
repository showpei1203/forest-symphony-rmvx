extends AnimatedSprite2D
# Presentation only. No weapon, FX, combat event, or damage authority.
const ANCHOR := Vector2(32, 50)
const MS := [110, 90, 170, 100, 80, 120, 120, 210]
const PIN := "9569bc8beac9d928be39f482faaa8f5a2289549c7bb0b099fed8072c118d3ae5"

func configure(atlas: Image) -> bool:
    if atlas == null or atlas.get_size() != Vector2i(256, 128):
        return false
    var rgba := atlas.duplicate() as Image
    rgba.convert(Image.FORMAT_RGBA8)
    var seen: Array[PackedByteArray] = []
    var frames := SpriteFrames.new()
    frames.add_animation(&"attack_body")
    frames.set_animation_speed(&"attack_body", 1.0)
    frames.set_animation_loop(&"attack_body", false)
    var tex := ImageTexture.create_from_image(rgba)
    for i in range(8):
        var r := Rect2i(i % 4 * 64, floori(i / 4.0) * 64, 64, 64)
        var cell := rgba.get_region(r)
        var bounds := cell.get_used_rect()
        if bounds.size == Vector2i.ZERO or bounds.end.y != 50 or bounds.position.x <= 0 or bounds.position.y <= 0 or bounds.end.x >= 64:
            return false
        var pixels := cell.get_data()
        if seen.has(pixels):
            return false
        seen.append(pixels)
        var slice := AtlasTexture.new()
        slice.atlas = tex
        slice.region = Rect2(r)
        slice.filter_clip = true
        frames.add_frame(&"attack_body", slice, MS[i] / 1000.0)
    stop()
    sprite_frames = frames
    animation = &"attack_body"
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    centered = false
    offset = -ANCHOR
    frame = 0
    return true

func load_candidate() -> bool:
    var path := "res://asset/ATTACK8_atlas.png"
    if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != PIN:
        return false
    return configure(Image.load_from_file(path))

func replay() -> bool:
    if sprite_frames == null or not sprite_frames.has_animation(&"attack_body") or sprite_frames.get_frame_count(&"attack_body") != 8:
        return false
    stop()
    animation = &"attack_body"
    set_frame_and_progress(0, 0.0)
    play(&"attack_body")
    return true
