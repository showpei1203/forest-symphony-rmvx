extends Node2D
## Side-by-side source-locked V4, rejected V1, and historical native motion.
## 4.7.2 REVIEW ONLY. Attack is NOT ART APPROVED.
const ASSET_ROOT := "res://assets/monsters/tb/"
const DURATIONS := [4,2,4,2,2,2,2,2,2,2,4]
var v4: AnimatedSprite2D
var v1: AnimatedSprite2D
var native: AnimatedSprite2D
var feedback: Label
var last_event := ""
func _ready() -> void:
    get_window().size = Vector2i(1140, 610)
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.085,0.11,0.14)
    backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
    backdrop.size = Vector2(1140,610)
    add_child(backdrop)
    _label(Vector2(24,18), "FS / T-B | Real articulation candidate V4 | NOT PixelLab / NOT ART APPROVED", 19)
    _label(Vector2(36,82), "V4: articulated limbs + mouth (11F)", 16)
    _label(Vector2(418,82), "REJECTED: rigid-body V1 (8F)", 16)
    _label(Vector2(806,82), "G9 original motion reference (11F)", 16)
    v4 = _sprite("PMD0001_ATTACK_V4_11F_384x288.png",11,4,96,96,DURATIONS,60.0)
    v4.position = Vector2(180,268)
    v4.scale = Vector2(3.2,3.2)
    v1 = _sprite("PMD0001_ATTACK_8F_256x128.png",8,4,64,64,[],11.0)
    v1.position = Vector2(570,263)
    v1.scale = Vector2(3.6,3.6)
    v1.modulate = Color(1,0.8,0.78)
    native = _sprite("PMD0001_G9_NATIVE_ATTACK_ROW1_11F_256x288.png",11,4,64,96,DURATIONS,60.0)
    native.position = Vector2(938,263)
    native.scale = Vector2(3.2,3.2)
    feedback = _label(Vector2(24,485),"SPACE: play all  |  R: reset  |  0-9: select V4 frame",17)
    _label(Vector2(24,533),"V4 identity locked at F0/F10  •  F2 Rush  •  F5 Hit  •  F7 Return  •  Texture QA != Art Gate",15)
    _reset()
func _label(pos: Vector2, t: String, size: int) -> Label:
    var lab := Label.new()
    lab.position=pos
    lab.text=t
    lab.add_theme_font_size_override("font_size",size)
    lab.add_theme_color_override("font_color",Color(0.91,0.92,0.91))
    add_child(lab)
    return lab
func _sprite(file_name: String,count: int,cols: int,w: int,h: int,ticks: Array,fps: float) -> AnimatedSprite2D:
    var texture: Texture2D = load(ASSET_ROOT+file_name)
    assert(texture != null, "Missing private texture: "+file_name)
    assert(texture.get_width() == cols*w)
    assert(texture.get_height() == int(ceil(float(count)/float(cols)))*h)
    var frames := SpriteFrames.new()
    frames.remove_animation("default")
    frames.add_animation("attack")
    frames.set_animation_speed("attack",fps)
    frames.set_animation_loop("attack",false)
    for i in count:
        var atlas := AtlasTexture.new()
        atlas.atlas=texture
        atlas.region=Rect2((i%cols)*w,int(i/cols)*h,w,h)
        atlas.filter_clip=true
        frames.add_frame("attack",atlas,float(ticks[i]) if not ticks.is_empty() else 1.0)
    var sprite := AnimatedSprite2D.new()
    sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.sprite_frames=frames
    sprite.animation="attack"
    add_child(sprite)
    return sprite
func _process(_delta: float) -> void:
    if feedback == null or v4 == null: return
    var event_name := ""
    if v4.frame == 2: event_name = "RUSH"
    if v4.frame == 5: event_name = "HIT"
    if v4.frame == 7: event_name = "RETURN"
    if event_name != last_event and not event_name.is_empty() and v4.is_playing():
        print("TB_ATTACK_EVENT ", event_name, " FRAME ", v4.frame)
    last_event = event_name
    feedback.text="SPACE: play all | R: reset | V4 F%d %s  / V1 F%d / G9 F%d | 60 ticks/s" % [v4.frame,event_name,v1.frame,native.frame]
func _reset() -> void:
    for a in [v4,v1,native]:
        a.stop()
        a.set_frame_and_progress(0,0.0)
    last_event=""
func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        _reset()
        for a in [v4,v1,native]: a.play("attack")
    elif event.keycode==KEY_R: _reset()
    elif event.keycode>=KEY_0 and event.keycode<=KEY_9:
        v4.stop()
        v4.set_frame_and_progress(event.keycode-KEY_0,0.0)
