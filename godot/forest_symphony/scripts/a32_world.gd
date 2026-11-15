@tool
extends Node2D
## Ground FIRST: original source is an opaque texture, independently generated.
## All tall objects are distinct editable source Sprite2D nodes under YSort.
const GROUND_FILE := "res://private_assets/ground_only.png"
const GROUND_SHA := "3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"
const OBJECTS_EXPECTED := 146
@onready var ground_sprite: Sprite2D = $FullGround
@onready var owner_layer: Node2D = $YSort
@onready var player: CharacterBody2D = $YSort/Player
@onready var grid: Node2D = $EditorGrid

func _ready() -> void:
    ground_sprite.centered = false
    ground_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(GROUND_FILE):
        if FileAccess.get_sha256(GROUND_FILE) != GROUND_SHA:
            push_error("A32 ground SHA mismatch; fail closed")
            return
        ground_sprite.texture = load(GROUND_FILE)
    elif not Engine.is_editor_hint():
        push_error("Private A32 Ground-only source missing; see owner-only Drive delivery")
        get_tree().quit(3)
        return
    if Engine.is_editor_hint():return
    if owner_layer.get_child_count() - 1 != OBJECTS_EXPECTED:
        push_error("A32 object count mismatch; inspect scene source")
        get_tree().quit(4)
        return
    print("FS A32 GROUND-FIRST GODOT: separate ground + 146 independent source PAR objects")
    print("ART HOLD / COLLISION CANDIDATE / ORIGINAL MASTER CUTTING FORBIDDEN")

func _unhandled_key_input(event: InputEvent) -> void:
    if Engine.is_editor_hint():return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
        grid.visible = not grid.visible
        queue_redraw()

func _draw() -> void:
    if not Engine.is_editor_hint() and grid.visible:
        for x in range(0,1281,32):
            draw_line(Vector2(x,0),Vector2(x,928),Color(1,1,1,0.18))
        for y in range(0,929,32):
            draw_line(Vector2(0,y),Vector2(1280,y),Color(1,1,1,0.18))
