@tool
extends Sprite2D
## An editor-adjustable, source-locked foreground object. NOT a generated tile.

@export var object_id: String = ""
@export_enum("tree_canopy", "roof_front_eave", "bridge_near_rail", "cliff_top") var semantic: String = "tree_canopy"
@export_file("*.png") var source_path: String = ""
@export var source_sha256: String = ""
@export_range(0, 4096, 1) var far_foot_y: int = 0
@export_range(0, 4096, 1) var near_foot_y: int = 0

func _ready() -> void:
    centered = false
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if source_path != "" and FileAccess.file_exists(source_path):
        var imported: Texture2D = load(source_path) as Texture2D
        if imported != null:
            texture = imported

func get_owner_data() -> Dictionary:
    if object_id.is_empty() or source_path.is_empty():
        push_error("Missing object identity/source path: " + str(name))
        return {}
    if not FileAccess.file_exists(source_path):
        push_error("Missing PRIVATE source PNG: " + source_path)
        return {}
    if FileAccess.get_sha256(source_path) != source_sha256:
        push_error("SHA MISMATCH: " + source_path)
        return {}
    var imported: Texture2D = load(source_path) as Texture2D
    if imported == null:
        push_error("PNG not imported as Texture2D: " + source_path)
        return {}
    var image: Image = imported.get_image()
    if image == null or image.is_empty():
        push_error("Could not decode source PNG: " + source_path)
        return {}
    if image.get_format() != Image.FORMAT_RGBA8:
        image.convert(Image.FORMAT_RGBA8)
    var x := int(position.x)
    var y := int(position.y)
    if near_foot_y < far_foot_y or far_foot_y < 0 or near_foot_y > 4096:
        push_error("Invalid depth footpoint limits: " + object_id)
        return {}
    return {
        "object_id": object_id,
        "semantic": semantic,
        "image": image,
        "rect": Rect2i(x, y, image.get_width(), image.get_height()),
        "far": far_foot_y,
        "near": near_foot_y,
    }
