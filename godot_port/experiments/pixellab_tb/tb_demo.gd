extends Node2D
## Forest Symphony / T-B monster factory, standalone preview.
## All image files are privately generated SOURCE-LOCKED CANDIDATES.
## Keys: 1/2/3 select family stage, Space plays PMD0001 attack.
## Visual and native Godot acceptance must be reviewed separately.

const ROOT := "res://assets/monsters/tb/"
const STAGES := ["PMD0001", "PMD0002", "PMD0003"]
const POSITIONS := [Vector2(160.0, 175.0), Vector2(450.0, 175.0), Vector2(740.0, 175.0)]
var sprites: Array[Sprite2D] = []
var animator: AnimatedSprite2D
var active_stage := 0
var status: Label

func _ready() -> void:
    for i in STAGES.size():
        var sprite := Sprite2D.new()
        sprite.texture = load(ROOT + STAGES[i] + "_STATIC_64.png")
        if sprite.texture == null:
            push_error("Missing T-B source locked texture: " + STAGES[i])
            get_tree().quit(2)
            return
        sprite.position = POSITIONS[i]
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.scale = Vector2(3.2, 3.2)
        add_child(sprite)
        sprites.append(sprite)
        var label := Label.new()
        label.text = STAGES[i] + [" / Juvenile", " / Basalt", " / Molten Core"][i]
        label.position = POSITIONS[i] + Vector2(-104, 111)
        add_child(label)
    animator = AnimatedSprite2D.new()
    animator.position = Vector2(450.0, 400.0)
    animator.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    animator.scale = Vector2(2.5,2.5)
    animator.sprite_frames = _make_frames()
    animator.animation_finished.connect(_on_finished)
    add_child(animator)
    animator.play("idle")
    status = Label.new()
    status.position = Vector2(24, 505)
    status.text = "PMD0001 Idle (historical provider) | Space: Attack | 1/2/3: stage"
    add_child(status)
    _select_stage(0)

func _make_frames() -> SpriteFrames:
    var frames := SpriteFrames.new()
    if frames.has_animation("default"):
        frames.remove_animation("default")
    _add_atlas_animation(frames, "idle", "PMD0001_IDLE_3F_192x64.png", 3, 3, 4.0, true)
    _add_atlas_animation(frames, "attack", "PMD0001_ATTACK_8F_256x128.png", 8, 4, 9.0, false)
    return frames

func _add_atlas_animation(frames: SpriteFrames, name: String, source: String, count: int, cols: int, fps: float, looping: bool) -> void:
    var source_texture: Texture2D = load(ROOT + source)
    assert(source_texture != null, "Missing atlas " + source)
    assert(source_texture.get_width() == cols * 64, "Bad atlas width " + source)
    assert(source_texture.get_height() == int(ceil(float(count) / float(cols))) * 64, "Bad atlas height " + source)
    frames.add_animation(name)
    frames.set_animation_speed(name,fps)
    frames.set_animation_loop(name,looping)
    for i in count:
        var region_texture := AtlasTexture.new()
        region_texture.atlas = source_texture
        region_texture.region = Rect2(float((i % cols)*64),float(int(i / cols)*64),64.0,64.0)
        region_texture.filter_clip = true
        frames.add_frame(name,region_texture)

func _select_stage(index: int) -> void:
    active_stage = index
    for i in sprites.size():
        sprites[i].modulate = Color.WHITE if i == active_stage else Color(0.56,0.56,0.56,1.0)

func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode >= KEY_1 and event.keycode <= KEY_3:
        _select_stage(event.keycode - KEY_1)
    if event.keycode == KEY_SPACE:
        animator.play("attack")
        if status != null:
            status.text = "PMD0001 attack / procedural candidate | Godot Native ART HOLD"

func _on_finished() -> void:
    if animator.animation == "attack":
        animator.play("idle")
        status.text = "PMD0001 idle / historical PixelLab 3F | 1/2/3 stages | Space attack"
