extends Node2D
## T-B PMD0001 Attack visual comparison for Godot 4.7.2.
## This scene is intentionally NOT an ART approval screen.
## Old procedural attack: formally rejected. G9 native rows: motion references only.

const ASSET_ROOT := "res://assets/monsters/tb/"
const EVENTS := {2: "RUSH", 5: "HIT", 7: "RETURN"}
const DURATIONS = [4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4]

var old_sprite: AnimatedSprite2D
var native_1: AnimatedSprite2D
var native_2: AnimatedSprite2D
var status: Label

func _ready() -> void:
    get_window().size = Vector2i(1080, 610)
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.092, 0.11, 0.14, 1.0)
    backdrop.position = Vector2.ZERO
    backdrop.size = Vector2(1080, 610)
    add_child(backdrop)
    _put_label(Vector2(22, 22), "PMD0001 | Attack failure analysis | NOT ART APPROVED", Color(1.0, 0.94, 0.84), 20)
    _put_label(Vector2(38, 90), "REJECTED 8F", Color(1.0, 0.42, 0.36))
    _put_label(Vector2(395, 90), "G9 NATIVE ROW 1 (pose reference)", Color(0.66, 0.88, 1.0))
    _put_label(Vector2(755, 90), "G9 NATIVE ROW 2 (pose reference)", Color(0.66, 0.88, 1.0))
    _put_label(Vector2(38, 404), "Whole-body squash / fireball", Color(1.0, 0.65, 0.57))
    _put_label(Vector2(392, 404), "11 original frames | SOURCE-LOCKED", Color(0.70, 0.84, 0.94))
    _put_label(Vector2(755, 404), "45 degree direction still UNVERIFIED", Color(0.70, 0.84, 0.94))
    old_sprite = _setup_sprite("PMD0001_ATTACK_8F_256x128.png", 8, 4, 64, 64, [], 9.0)
    old_sprite.position = Vector2(170, 256)
    old_sprite.scale = Vector2(4.2, 4.2)
    old_sprite.modulate = Color(1.0, 0.74, 0.7)
    native_1 = _setup_sprite("PMD0001_G9_NATIVE_ATTACK_ROW1_11F_256x288.png", 11, 4, 64, 96, DURATIONS, 30.0)
    native_1.position = Vector2(518, 242)
    native_1.scale = Vector2(3.7, 3.7)
    native_2 = _setup_sprite("PMD0001_G9_NATIVE_ATTACK_ROW2_11F_256x288.png", 11, 4, 64, 96, DURATIONS, 30.0)
    native_2.position = Vector2(879, 242)
    native_2.scale = Vector2(3.7, 3.7)
    status = _put_label(Vector2(30, 476), "SPACE: replay all | 1/2: preview selected native row | R: reset frames", Color.WHITE, 17)
    _put_label(Vector2(30, 529), "Old route = ART FAIL. Native route = MOTION REFERENCE ONLY. Both await concept-style retarget & human ART Gate.", Color(1.0, 0.78, 0.61), 14)
    _reset()

func _put_label(location: Vector2, text: String, color: Color, size: int = 15) -> Label:
    var label := Label.new()
    label.position = location
    label.text = text
    label.add_theme_color_override("font_color", color)
    label.add_theme_font_size_override("font_size", size)
    add_child(label)
    return label

func _setup_sprite(file_name: String, frame_count: int, cols: int, cell_w: int, cell_h: int, ticks: Array, fps: float) -> AnimatedSprite2D:
    var texture: Texture2D = load(ASSET_ROOT + file_name)
    assert(texture != null, "Missing PRIVATE asset: " + file_name)
    assert(texture.get_width() == cols * cell_w)
    assert(texture.get_height() == int(ceil(float(frame_count) / float(cols))) * cell_h)
    var frames := SpriteFrames.new()
    frames.remove_animation("default")
    frames.add_animation("attack")
    frames.set_animation_loop("attack", false)
    frames.set_animation_speed("attack", fps)
    for i in frame_count:
        var tile := AtlasTexture.new()
        tile.atlas = texture
        tile.region = Rect2((i % cols) * cell_w, int(i / cols) * cell_h, cell_w, cell_h)
        tile.filter_clip = true
        frames.add_frame("attack", tile, float(ticks[i]) if not ticks.is_empty() else 1.0)
    var sprite := AnimatedSprite2D.new()
    sprite.sprite_frames = frames
    sprite.animation = "attack"
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(sprite)
    return sprite

func _process(_dt: float) -> void:
    if status == null:
        return
    var event1: String = EVENTS.get(native_1.frame, "")
    var event2: String = EVENTS.get(native_2.frame, "")
    status.text = "SPACE replay | Old F%d | Native row1 F%d %s | row2 F%d %s" % [old_sprite.frame, native_1.frame, event1, native_2.frame, event2]

func _reset() -> void:
    for sprite in [old_sprite, native_1, native_2]:
        sprite.stop()
        sprite.set_frame_and_progress(0, 0.0)

func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE:
        _reset()
        old_sprite.play("attack")
        native_1.play("attack")
        native_2.play("attack")
    elif event.keycode == KEY_1:
        native_1.set_frame_and_progress(0, 0.0)
        native_1.play("attack")
    elif event.keycode == KEY_2:
        native_2.set_frame_and_progress(0, 0.0)
        native_2.play("attack")
    elif event.keycode == KEY_R:
        _reset()
