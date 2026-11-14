@tool
extends Node2D
## A36 continuous Ground-first large forest, 80x58 at 32px. Events are NOT part of this art project.
const WORLD_SIZE := Vector2i(2560,1856)
const GROUND_FILE := "res://private_assets/a36_ground_only_2560x1856.png"
const SHADOW_FILE := "res://private_assets/a36_contact_shadows_2560x1856.png"
const GROUND_SHA := "ac591877b05c00543e6756e44e6ba81f6fea7e36086049e35de81e2610e0c911"
const SHADOW_SHA := "f65ffa73fa49fffec4179084d712f03dccc3cfb828ef02b99857d03800a603a3"
const EXPECTED_OBJECTS := 326
@onready var ground: Sprite2D = $FullGround
@onready var contact_shadows: Sprite2D = $ContactShadows
@onready var owner_layer: Node2D = $YSort
@onready var grid: Node2D = $EditorGrid
func _ready() -> void:
    ground.centered = false
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    contact_shadows.centered = false
    contact_shadows.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(GROUND_FILE):
        if FileAccess.get_sha256(GROUND_FILE) != GROUND_SHA:
            push_error("A36 source Ground SHA mismatch"); return
        ground.texture = load(GROUND_FILE)
    elif not Engine.is_editor_hint():
        push_error("Owner-only A36 Ground missing: use the private project ZIP"); get_tree().quit(3); return
    if FileAccess.file_exists(SHADOW_FILE):
        if FileAccess.get_sha256(SHADOW_FILE) != SHADOW_SHA:
            push_error("A36 contact shadow SHA mismatch");return
        contact_shadows.texture = load(SHADOW_FILE)
    if Engine.is_editor_hint(): return
    if owner_layer.get_child_count() - 1 != EXPECTED_OBJECTS:
        push_error("A36 expected full independent object count mismatch");get_tree().quit(4);return
    print("FS A36 GODOT REAL GROUND-FIRST: 80x58 world; "+str(EXPECTED_OBJECTS)+" individually editable full-source PAR instances")
    print("ART HOLD; river candidate, not nav approved; no NPC/events in this art scene")
func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
        grid.visible = not grid.visible
        queue_redraw()
func _draw() -> void:
    if grid.visible:
        for x in range(0, WORLD_SIZE.x+1, 32):
            draw_line(Vector2(x,0),Vector2(x,WORLD_SIZE.y),Color(1,1,1,.14))
        for y in range(0, WORLD_SIZE.y+1, 32):
            draw_line(Vector2(0,y),Vector2(WORLD_SIZE.x,y),Color(1,1,1,.14))
