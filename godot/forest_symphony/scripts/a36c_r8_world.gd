@tool
extends "res://scripts/a36b_world.gd"
## A36C R8: non-destructive 4-frame river highlights, source Ground/PAR unchanged.
const RIVER_FRAMES := [
    "res://private_assets/a36c_r8_river_glints_f0.png",
    "res://private_assets/a36c_r8_river_glints_f1.png",
    "res://private_assets/a36c_r8_river_glints_f2.png",
    "res://private_assets/a36c_r8_river_glints_f3.png"
]
@onready var river_glints: AnimatedSprite2D = $AnimatedRiverGlints
func _ready() -> void:
    super._ready()
    river_glints.centered = false
    river_glints.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var atlas := SpriteFrames.new()
    atlas.add_animation("flow")
    atlas.set_animation_speed("flow", 5.0)
    atlas.set_animation_loop("flow", true)
    for file in RIVER_FRAMES:
        if not FileAccess.file_exists(file):
            push_error("R8 missing private animated water frame: " + file)
            return
        atlas.add_frame("flow", load(file))
    river_glints.sprite_frames = atlas
    river_glints.animation = "flow"
    if not Engine.is_editor_hint():
        river_glints.play("flow")
