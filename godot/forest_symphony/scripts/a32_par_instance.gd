@tool
extends Node2D
## FS A32 independent artist-owned complete PAR object. No crops from flattened Master.
## Pivot NODE POSITION is the object FOOTPOINT used by parent YSort.
@export_file("*.png") var source_file: String = ""
@export var source_sha256: String = ""
@export var source_semantic: String = "tree"
@export var source_object_id: String = ""
@export var footprint_width_px: float = 0.0
@export var footprint_height_px: float = 0.0

func _ready() -> void:
    var visual: Sprite2D = get_node_or_null("Sprite") as Sprite2D
    if visual == null: return
    visual.centered = false
    visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if source_file != "" and FileAccess.file_exists(source_file):
        if source_sha256 != "" and FileAccess.get_sha256(source_file) != source_sha256:
            push_error("A32 object source SHA invalid: " + source_object_id)
            return
        var tex: Texture2D = load(source_file) as Texture2D
        if tex == null: return
        visual.texture = tex
        visual.position = Vector2(-float(tex.get_width()) / 2.0, -float(tex.get_height()) + 1.0)
    if Engine.is_editor_hint():return
    var collider: CollisionShape2D = get_node_or_null("Body/Collision") as CollisionShape2D
    if collider != null and footprint_width_px > 0.0 and footprint_height_px > 0.0:
        var box: RectangleShape2D = RectangleShape2D.new()
        box.size = Vector2(footprint_width_px, footprint_height_px)
        collider.shape = box
        collider.position = Vector2(0, -footprint_height_px / 2.0)
    elif collider != null:
        collider.disabled = true
