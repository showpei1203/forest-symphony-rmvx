extends Node2D
var sprite: Sprite2D
var texture_sheet: Texture2D
func _ready() -> void:
    sprite = Sprite2D.new()
    sprite.centered = false
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position = Vector2(16.0, 16.0)
    add_child(sprite)
    texture_sheet = load("res://assets/T17D1_ARMING_SWORD_HEAD_HAIR_128.png")
    if texture_sheet == null:
        push_error("T17D2 ERROR source image missing")
        get_tree().quit(3)
        return
    await render_all()
func render_all() -> void:
    for row in range(4):
        for frame in range(6):
            var piece: AtlasTexture = AtlasTexture.new()
            piece.atlas = texture_sheet
            piece.region = Rect2(frame*128, row*128, 128, 128)
            piece.filter_clip = true
            sprite.texture = piece
            await RenderingServer.frame_post_draw
            var img: Image = get_viewport().get_texture().get_image()
            if img.get_width() != 160 or img.get_height() != 160:
                push_error("T17D2 viewport mismatch")
                get_tree().quit(4)
                return
            var path: String = "res://captures/T17D2_%d_%d.png" % [row, frame]
            if img.save_png(path) != OK:
                push_error("T17D2 save screenshot failed")
                get_tree().quit(5)
                return
            print("T17D2_CAPTURE_%d_%d" % [row, frame])
    print("T17D2_NATIVE_GPU_24_CAPTURES_PASS")
    get_tree().quit(0)
