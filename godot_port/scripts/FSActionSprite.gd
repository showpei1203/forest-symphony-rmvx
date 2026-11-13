extends TextureRect
class_name FSActionSprite

# Kaduki-style four sheets, 3 cols × 4 rows each, 32x32 cell: 16 actions, 48 frames.
# This is a data/animation adapter, NOT source-art generation or an RPG VX visual pass.
var sheets: Array[Texture2D] = []
var action_row: int = 0
var frame_index: int = 0
var elapsed: float = 0.0
@export var frames_per_second: float = 6.0

func load_actor(prefix: String) -> bool:
    sheets.clear()
    for postfix in ["", "_1", "_2", "_3"]:
        var path: String = "res://assets/characters/%s%s.png" % [prefix, postfix]
        var tex: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
        if tex == null or tex.get_size() != Vector2(96, 128):
            sheets.clear()
            return false
        sheets.append(tex)
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    custom_minimum_size = Vector2(32, 32)
    expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _refresh()
    return true

func play_action(index: int) -> void:
    action_row = clampi(index, 0, 15)
    elapsed = 0.0
    frame_index = 0
    _refresh()

func _process(delta: float) -> void:
    if sheets.size() != 4:
        return
    elapsed += delta
    if elapsed >= 1.0 / maxf(frames_per_second, 0.01):
        elapsed = 0.0
        frame_index = (frame_index + 1) % 3
        _refresh()

func _refresh() -> void:
    if sheets.size() != 4:
        return
    var atlas := AtlasTexture.new()
    atlas.atlas = sheets[action_row / 4]
    atlas.region = Rect2(frame_index * 32, (action_row % 4) * 32, 32, 32)
    texture = atlas
