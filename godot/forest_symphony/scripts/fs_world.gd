@tool
extends Node2D
## A30 Godot-first FS Master-preserving map, source-locked private artwork.
const MASTER_FILE := "res://private_assets/full_ground.png"
const MASTER_SHA := "091e177a1fd0964dafe0dd79319c525d6b4888e19264f3d1af0ea990d2848530"
const ACTOR_FILE := "res://private_assets/actor_f0.png"
const ACTOR_SHA := "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"
const RUN_SOURCE := [
    "res://private_assets/actor_run_1.png",
    "res://private_assets/actor_run_2.png",
    "res://private_assets/actor_run_3.png",
]
const RUN_SHA := [
    "6b25abb1dd702701716844a2ad36dfb8bfb8e3eccaf87fe7b15b2b85a41d101d",
    "a96d6d4df959f66cb5cc08aa78e7b8f7a22f9e37140584b0fb3c928bc5b37029",
    "84a8edb267bea9608d40de9f3af9b20050d7e85ef2293f0cd4d4199045107b79",
]
const COLLISION_FILE := "res://data/collision_candidate.json"

@onready var full_ground: Sprite2D = $FullGround
@onready var occluders: Node2D = $Occluders
@onready var player: CharacterBody2D = $Characters/Player
@onready var collision_paint: TileMapLayer = $CollisionPaint
@onready var grid: Node2D = $EditorGrid

func _ready() -> void:
    if not FileAccess.file_exists(MASTER_FILE) or not FileAccess.file_exists(ACTOR_FILE):
        if not Engine.is_editor_hint():
            push_error("FS A30 private source assets missing; see README. No placeholder art")
            get_tree().quit(3)
        return
    if FileAccess.get_sha256(MASTER_FILE) != MASTER_SHA or FileAccess.get_sha256(ACTOR_FILE) != ACTOR_SHA:
        push_error("FS source SHA invalid; refusing modified Master/Actor")
        if not Engine.is_editor_hint():get_tree().quit(4)
        return
    var ground_tex: Texture2D = load(MASTER_FILE) as Texture2D
    var actor_tex: Texture2D = load(ACTOR_FILE) as Texture2D
    if ground_tex == null or actor_tex == null:
        push_error("FS original PNG import failed")
        if not Engine.is_editor_hint():get_tree().quit(5)
        return
    var ground: Image = ground_tex.get_image()
    var actor: Image = actor_tex.get_image()
    if ground == null or actor == null or ground.is_empty() or actor.is_empty():
        push_error("Invalid source images")
        if not Engine.is_editor_hint():get_tree().quit(5)
        return
    if ground.get_size() != Vector2i(1280,928) or actor.get_size() != Vector2i(48,48):
        push_error("Unexpected A11 Master / A18 actor image size")
        if not Engine.is_editor_hint():get_tree().quit(5)
        return
    full_ground.texture = ImageTexture.create_from_image(ground)
    full_ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    var owners: Array = []
    for owner_node in occluders.get_children():
        if not owner_node.has_method("get_owner_data"):continue
        var item: Dictionary = owner_node.get_owner_data()
        if item.is_empty():
            if not Engine.is_editor_hint():get_tree().quit(6)
            return
        owners.append(item)
    # TileSet must contain real cell collision shapes; do not accept an atlas only.
    if collision_paint.tile_set == null or collision_paint.tile_set.get_physics_layers_count() != 1:
        push_error("A30 TileSet collision resource missing")
        if not Engine.is_editor_hint():get_tree().quit(7)
        return
    var tile_source := collision_paint.tile_set.get_source(0) as TileSetAtlasSource
    if tile_source == null or tile_source.get_tile_data(Vector2i.ZERO,0).get_collision_polygons_count(0) != 1:
        push_error("A30 TileSet missing real physics polygon")
        if not Engine.is_editor_hint():get_tree().quit(8)
        return
    if collision_paint.get_used_cells().is_empty():
        push_error("A30 collision layer has no painted candidate cells")
        if not Engine.is_editor_hint():get_tree().quit(8)
        return
    if Engine.is_editor_hint():
        occluders.visible = true
        collision_paint.modulate = Color(1,1,1,0.45)
        return
    var run_images: Array[Image] = []
    for index in range(RUN_SOURCE.size()):
        var path: String = RUN_SOURCE[index]
        if not FileAccess.file_exists(path) or FileAccess.get_sha256(path) != RUN_SHA[index]:
            push_error("Approved A62 RUN SHA missing / invalid: " + path)
            get_tree().quit(9)
            return
        var tex: Texture2D = load(path) as Texture2D
        if tex == null:
            push_error("Approved RUN PNG could not import: " + path)
            get_tree().quit(9)
            return
        run_images.append(tex.get_image())
    # Public GitHub CI gets a synthetic-only scene, no private art.
    occluders.visible = false
    # Only the 32px candidate blocks have collisions; unknown cells are NOT proven walkable.
    collision_paint.modulate = Color(1,1,1,0)
    collision_paint.collision_enabled = true
    player.configure(actor,owners,Vector2i(ground.get_width(),ground.get_height()),run_images)
    print("FS A30 GODOT: real A11 Master + approved A62 Run + source-locked PAR + 180 collision CANDIDATES")
    print("ART HOLD, COLLISION USER APPROVAL HOLD, battle animation only; not VX")

func _unhandled_key_input(event: InputEvent) -> void:
    if Engine.is_editor_hint() or not event is InputEventKey:return
    var key: InputEventKey = event
    if not key.pressed or key.echo:return
    if key.keycode == KEY_G:
        grid.visible = not grid.visible
        queue_redraw()
    elif key.keycode == KEY_O:
        player.set_foreground_enabled(not player.overlay_enabled)
    elif key.keycode == KEY_C:
        collision_paint.modulate = Color.WHITE if collision_paint.modulate.a < 0.5 else Color(1,1,1,0)
    elif key.keycode == KEY_R:
        player.set_battle_run_preview(not player.preview_battle_run)

func _draw() -> void:
    if not Engine.is_editor_hint() and grid.visible:
        for x in range(0,1281,32):
            draw_line(Vector2(x,0),Vector2(x,928),Color(1,1,1,0.19),1.0)
        for y in range(0,929,32):
            draw_line(Vector2(0,y),Vector2(1280,y),Color(1,1,1,0.19),1.0)
