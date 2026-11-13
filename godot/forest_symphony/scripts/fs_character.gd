extends CharacterBody2D
## Movement and collision are Godot-native. This pilot uses original stationary F0.
## Character position = footpoint. The old VX screen_y 4px bias does not apply.

const OverlayEngine = preload("res://scripts/fs_occlusion.gd")
@export var walk_speed: float = 120.0
@export var fast_multiplier: float = 2.0

@onready var visual: Sprite2D = $ActorVisual
@onready var foreground: Sprite2D = $ActorForeground

var original_actor: Image
var owners: Array = []
var dynamic_overlay: ImageTexture
var last_overlay_cpu: Image
var last_foot: Vector2i = Vector2i(-9999, -9999)
var overlay_enabled := true
var world_size := Vector2i(1280, 928)

func configure(actor: Image, source_owners: Array, map_size: Vector2i) -> void:
    original_actor = actor
    owners = source_owners
    world_size = map_size
    visual.texture = ImageTexture.create_from_image(actor)
    var empty := Image.create_empty(actor.get_width(), actor.get_height(), false, Image.FORMAT_RGBA8)
    empty.fill(Color.TRANSPARENT)
    dynamic_overlay = ImageTexture.create_from_image(empty)
    foreground.texture = dynamic_overlay
    refresh_occlusion()

func refresh_occlusion() -> void:
    if original_actor == null or dynamic_overlay == null:
        return
    var foot := Vector2i(roundi(position.x), roundi(position.y))
    if last_foot == foot:
        return
    last_foot = foot
    var top_left := foot + Vector2i(-24, -47)
    var overlay := OverlayEngine.build_overlay(original_actor, top_left, foot, owners)
    last_overlay_cpu = overlay
    dynamic_overlay.update(overlay)

func _ready() -> void:
    # Allow deterministic InputMap action simulation and future controller remaps.
    for action in ["fs_move_left", "fs_move_right", "fs_move_up", "fs_move_down"]:
        if not InputMap.has_action(action):
            InputMap.add_action(action)

func _physics_process(_delta: float) -> void:
    if original_actor == null:
        return
    var move_direction := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or Input.is_action_pressed("fs_move_left"):
        move_direction.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or Input.is_action_pressed("fs_move_right"):
        move_direction.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or Input.is_action_pressed("fs_move_up"):
        move_direction.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or Input.is_action_pressed("fs_move_down"):
        move_direction.y += 1.0
    var speed := walk_speed * (fast_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
    velocity = move_direction.normalized() * speed
    move_and_slide()
    position = position.clamp(Vector2(24.0, 47.0), Vector2(float(world_size.x - 24), float(world_size.y - 1)))
    refresh_occlusion()

func set_foreground_enabled(enabled: bool) -> void:
    overlay_enabled = enabled
    foreground.visible = enabled
