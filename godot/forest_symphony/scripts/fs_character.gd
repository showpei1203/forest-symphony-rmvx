extends CharacterBody2D
## A30: Native Godot movement + exact A62-approved 48px battle RUN reuse.
## This is a directional prototype. Three A62 battle poses are NOT a new walk cycle.
## Pixel positions and actor source are kept 1:1; overlay is recalculated on frame
## change even if world footpoint remains at the same integer XY.

const OverlayEngine = preload("res://scripts/fs_occlusion.gd")
const RUN_ORDER := [0, 1, 0, 2]
@export var walk_speed: float = 120.0
@export var fast_multiplier: float = 2.0
@export_range(1.0, 16.0, 1.0) var run_fps: float = 8.0
@export var preview_battle_run: bool = true

@onready var visual: Sprite2D = $ActorVisual
@onready var foreground: Sprite2D = $ActorForeground

var original_actor: Image
var current_actor: Image
var run_frames: Array[Image] = []
var run_textures: Array[Texture2D] = []
var idle_texture: Texture2D
var owners: Array = []
var dynamic_overlay: ImageTexture
var last_overlay_cpu: Image
var last_foot: Vector2i = Vector2i(-9999,-9999)
var last_visual_id := -9999
var display_id := -1
var run_clock := 0.0
var overlay_enabled := true
var collision_debug_enabled := false
var world_size := Vector2i(1280,928)

func configure(actor: Image, source_owners: Array, map_size: Vector2i, approved_run: Array[Image] = []) -> void:
    assert(actor != null and actor.get_size() == Vector2i(48,48))
    original_actor = actor
    current_actor = actor
    run_frames = approved_run
    owners = source_owners
    world_size = map_size
    idle_texture = ImageTexture.create_from_image(actor)
    run_textures.clear()
    for frame in run_frames:
        assert(frame.get_size() == Vector2i(48,48))
        run_textures.append(ImageTexture.create_from_image(frame))
    if not run_textures.is_empty():
        assert(run_textures.size() == 3)
    visual.texture = idle_texture
    display_id = -1
    last_foot = Vector2i(-9999,-9999)
    last_visual_id = -9999
    var empty := Image.create_empty(actor.get_width(),actor.get_height(),false,Image.FORMAT_RGBA8)
    empty.fill(Color.TRANSPARENT)
    dynamic_overlay = ImageTexture.create_from_image(empty)
    foreground.texture = dynamic_overlay
    refresh_occlusion()

func _ready() -> void:
    for action in ["fs_move_left","fs_move_right","fs_move_up","fs_move_down"]:
        if not InputMap.has_action(action):
            InputMap.add_action(action)

func _set_visual(target_id: int) -> void:
    if target_id == display_id: return
    display_id = target_id
    if target_id == -1:
        current_actor = original_actor
        visual.texture = idle_texture
    else:
        assert(target_id >= 0 and target_id < run_frames.size())
        current_actor = run_frames[target_id]
        visual.texture = run_textures[target_id]

func refresh_occlusion() -> void:
    if current_actor == null or dynamic_overlay == null: return
    var foot := Vector2i(roundi(position.x),roundi(position.y))
    if last_foot == foot and last_visual_id == display_id: return
    last_foot = foot
    last_visual_id = display_id
    # The A62 48px reference shares its F0 anchor at (-24,-47).
    var top_left := foot + Vector2i(-24,-47)
    var overlay: Image = OverlayEngine.build_overlay(current_actor,top_left,foot,owners)
    last_overlay_cpu = overlay
    dynamic_overlay.update(overlay)

func _physics_process(delta: float) -> void:
    if original_actor == null: return
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
    position = position.clamp(Vector2(24,47),Vector2(float(world_size.x-24),float(world_size.y-1)))
    if velocity.length_squared() > 0.01 and preview_battle_run and run_frames.size() == 3:
        run_clock += delta
        var phase := int(floor(run_clock*run_fps)) % RUN_ORDER.size()
        _set_visual(RUN_ORDER[phase])
    else:
        run_clock = 0.0
        _set_visual(-1)
    refresh_occlusion()

func set_foreground_enabled(enabled: bool) -> void:
    overlay_enabled = enabled
    foreground.visible = enabled

func set_battle_run_preview(enabled: bool) -> void:
    preview_battle_run = enabled
    if not enabled:
        _set_visual(-1)
        refresh_occlusion()
