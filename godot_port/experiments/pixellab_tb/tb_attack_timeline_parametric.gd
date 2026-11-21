extends Node2D
## Forest Symphony | T-B deterministic attack event/timeline player.
## Source-locked PMD0001 V4 candidate. This solves event timing, NOT art approval.
## Damage stays in the battle system; this node emits exactly one hit marker.
signal rush_started(frame_index: int)
signal hit_requested(frame_index: int, local_contact: Vector2)
signal return_started(frame_index: int)
signal attack_completed()

const PNG_PATH := "res://assets/monsters/tb/PMD0001_ATTACK_V4_11F_384x288.png"
const FRAME_COUNT := 11
var cell_size := Vector2i(96, 96)
const COLS := 4
const TICKS_PER_SEC := 60.0
const FRAME_TICKS := [4, 2, 4, 2, 2, 2, 2, 2, 2, 2, 4]
const FRAME_START := [0, 4, 6, 10, 12, 14, 16, 18, 20, 22, 24]
const TOTAL_TICKS := 28
const RUSH_FRAME := 2
const HIT_FRAME := 5
const RETURN_FRAME := 7
const CONTACT := Vector2(29, 12)  # frame F5 jaw tip relative to centered 96x96 cell

var texture_path := PNG_PATH
var sprite: AnimatedSprite2D
var active := false
var frame_index := 0
var timeline_ticks := 0.0
var _next_event_seen := {"rush": false, "hit": false, "return": false}

func _ready() -> void:
    var tex := load(texture_path) as Texture2D
    if tex == null:
        push_error("TB animation source missing; keep private PNG in project assets")
        return
    if tex.get_width() != cell_size.x * COLS or tex.get_height() != cell_size.y * int(ceil(float(FRAME_COUNT) / float(COLS))):
        push_error("TB atlas size does not match configured cell size %s" % cell_size)
        return
    var sf := SpriteFrames.new()
    sf.remove_animation("default")
    sf.add_animation("attack")
    sf.set_animation_speed("attack", TICKS_PER_SEC)
    sf.set_animation_loop("attack", false)
    for i in FRAME_COUNT:
        var crop := AtlasTexture.new()
        crop.atlas = tex
        crop.region = Rect2((i % COLS)*cell_size.x, int(i / COLS)*cell_size.y, cell_size.x, cell_size.y)
        crop.filter_clip = true
        sf.add_frame("attack", crop, float(FRAME_TICKS[i]))
    sprite = AnimatedSprite2D.new()
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.sprite_frames = sf
    sprite.animation = "attack"
    sprite.stop()
    add_child(sprite)
    _show_frame(0)

func play_attack() -> bool:
    if active or sprite == null:
        return false
    active = true
    frame_index = 0
    timeline_ticks = 0.0
    _next_event_seen = {"rush": false, "hit": false, "return": false}
    _show_frame(0)
    return true

func cancel_attack() -> void:
    active = false
    frame_index = 0
    timeline_ticks = 0.0
    _next_event_seen = {"rush": false, "hit": false, "return": false}
    _show_frame(0)

func _process(delta: float) -> void:
    advance_seconds(delta)

func advance_seconds(delta: float) -> void:
    if not active or delta <= 0.0:
        return
    # Crossing the event's *start tick* is what emits a marker; one large frame
    # must not skip Rush/Hit/Return even after a pause or frame drop.
    var before := timeline_ticks
    var after: float = minf(float(TOTAL_TICKS), timeline_ticks + delta * TICKS_PER_SEC)
    for i in range(frame_index + 1, FRAME_COUNT):
        var t := float(FRAME_START[i])
        if t > after + 0.00001:
            break
        if t >= before - 0.00001:
            _enter_frame(i)
    timeline_ticks = after
    if active and timeline_ticks >= float(TOTAL_TICKS) - 0.00001:
        active = false
        _show_frame(FRAME_COUNT - 1)
        attack_completed.emit()

func _enter_frame(i: int) -> void:
    if i <= frame_index or not active:
        return
    frame_index = i
    _show_frame(i)
    if i == RUSH_FRAME and not _next_event_seen["rush"]:
        _next_event_seen["rush"] = true
        rush_started.emit(i)
    elif i == HIT_FRAME and not _next_event_seen["hit"]:
        _next_event_seen["hit"] = true
        hit_requested.emit(i, CONTACT)
    elif i == RETURN_FRAME and not _next_event_seen["return"]:
        _next_event_seen["return"] = true
        return_started.emit(i)

func _show_frame(i: int) -> void:
    if sprite != null:
        sprite.set_frame_and_progress(i, 0.0)
