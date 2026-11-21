extends Node2D
## FS direct two-stage factory: do NOT infer an actor-occlusion subset.
## GROUND contains terrain only; PAR contains EVERY non-ground source object.
## Display is a preview, not a new gameplay collision / depth design.
var floor_sprite: Sprite2D
var par_sprite: Sprite2D

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

    floor_sprite = Sprite2D.new()
    floor_sprite.name = "SOURCE_GROUND_ONLY_FIRST"
    floor_sprite.centered = false
    floor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    floor_sprite.texture = load("res://tc_factory/generated_direct/GROUND.png")
    floor_sprite.z_index = 0
    add_child(floor_sprite)

    par_sprite = Sprite2D.new()
    par_sprite.name = "SOURCE_COMPLETE_PAR_ALL_NON_GROUND"
    par_sprite.centered = false
    par_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    par_sprite.texture = load("res://tc_factory/generated_direct/PAR.png")
    par_sprite.z_index = 1
    add_child(par_sprite)

    if floor_sprite.texture == null or par_sprite.texture == null:
        push_error("T-C D1 must generate GROUND first and PAR second before native test")
