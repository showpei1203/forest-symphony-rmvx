@tool
extends Node2D
## Scene-first editable source map; original Master file never altered.
const MASTER_FILE := "res://private_assets/full_ground.png"
const MASTER_SHA := "091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530"
const ACTOR_FILE := "res://private_assets/actor_f0.png"
const ACTOR_SHA := "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"

@onready var full_ground: Sprite2D = $FullGround
@onready var occluders: Node2D = $Occluders
@onready var player: CharacterBody2D = $Characters/Player
@onready var collision_paint: TileMapLayer = $CollisionPaint
@onready var grid: Node2D = $EditorGrid

func _ready() -> void:
    if not FileAccess.file_exists(MASTER_FILE) or not FileAccess.file_exists(ACTOR_FILE):
        if not Engine.is_editor_hint():
            push_error("FS A29 private source assets missing; see README. No silent placeholder art.")
            get_tree().quit(3)
        return
    if FileAccess.get_sha256(MASTER_FILE) != MASTER_SHA or FileAccess.get_sha256(ACTOR_FILE) != ACTOR_SHA:
        push_error("FS source SHA invalid; refuse to open altered master/actor")
        if not Engine.is_editor_hint():
            get_tree().quit(4)
        return
    var ground := Image.load_from_file(MASTER_FILE)
    var actor := Image.load_from_file(ACTOR_FILE)
    if ground == null or actor == null or ground.is_empty() or actor.is_empty():
        push_error("FS master or actor could not decode")
        if not Engine.is_editor_hint():
            get_tree().quit(5)
        return
    full_ground.texture = ImageTexture.create_from_image(ground)
    full_ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var owners: Array = []
    for owner_node in occluders.get_children():
        if not owner_node.has_method("get_owner_data"):
            continue
        var owner: Dictionary = owner_node.get_owner_data()
        if owner.is_empty():
            if not Engine.is_editor_hint():
                get_tree().quit(6)
            return
        owners.append(owner)
    if Engine.is_editor_hint():
        occluders.visible = true
        return
    # Editor displays complete objects; runtime hides them and adds only the
    # character-specific same-XY overlay ABOVE that specific character.
    occluders.visible = false
    player.configure(actor, owners, Vector2i(ground.get_width(), ground.get_height()))
    print("FS A29 GODOT PLAYABLE MAP: 1280x928 real Master, 3 source-locked occluders, Godot-first")
    print("ART HOLD / collision painting PENDING / no VX runtime claimed")

func _unhandled_key_input(event: InputEvent) -> void:
    if Engine.is_editor_hint() or not event is InputEventKey:
        return
    var key: InputEventKey = event
    if not key.pressed or key.echo:
        return
    if key.keycode == KEY_G:
        grid.visible = not grid.visible
        queue_redraw()
    elif key.keycode == KEY_O:
        player.set_foreground_enabled(not player.overlay_enabled)

func _draw() -> void:
    if not Engine.is_editor_hint() and grid.visible:
        for x in range(0, 1281, 32):
            draw_line(Vector2(x, 0), Vector2(x, 928), Color(1, 1, 1, 0.19), 1.0)
        for y in range(0, 929, 32):
            draw_line(Vector2(0, y), Vector2(1280, y), Color(1, 1, 1, 0.19), 1.0)
