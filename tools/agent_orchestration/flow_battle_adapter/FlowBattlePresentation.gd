extends Node2D
# Presentation-only adapter to the official FSAnimationSprite API.
# Install under the actor's visual hierarchy, never as a gameplay authority.
const AnimationSprite = preload("res://scripts/animation/FSAnimationSprite.gd")
const ACTIONS := ["attack","run","damage","dodge","cast"]
const BACKSTEP := [0.0,0.0,4.0,14.0,24.0,24.0,24.0,24.0]
signal visual_finished(action: String)
var animation_player: AnimationSprite
var _away := Vector2.ZERO
var _configured := false

func _ready() -> void:
    animation_player = AnimationSprite.new()
    animation_player.name = "BodyPresentation"
    add_child(animation_player)
    animation_player.frame_entered.connect(_frame_entered)
    animation_player.clip_finished.connect(_clip_finished)
    animation_player.playback_failed.connect(_playback_failed)

# Input must come from the separately verified MotionBody loader. This method
# checks texture geometry and timing but is not a replacement for source SHA QA.
func configure(frames: SpriteFrames) -> bool:
    if animation_player == null or frames == null:
        return false
    var clips: Dictionary = {}
    for action in ACTIONS:
        if not frames.has_animation(action):
            return false
        var count := frames.get_frame_count(action)
        if count < 4 or count > 16 or (action == "dodge" and count != BACKSTEP.size()):
            return false
        if frames.get_animation_loop(action) != (action == "run") or not is_equal_approx(frames.get_animation_speed(action),1.0):
            return false
        var entries: Array = []
        for i in range(count):
            var at := frames.get_frame_texture(action,i) as AtlasTexture
            var ms := frames.get_frame_duration(action,i)*1000.0
            if at == null or at.atlas == null or at.region.size != Vector2(64,64) or at.region.position.x < 0 or at.region.position.y < 0 or at.region.end.x > at.atlas.get_width() or at.region.end.y > at.atlas.get_height() or not is_finite(ms) or ms < 19.99 or ms > 500.01 or absf(ms-roundf(ms)) > 0.01:
                return false
            entries.append({"texture":at.atlas,"rect":[at.region.position.x,at.region.position.y,64,64],"duration_ms":roundi(ms),"offset":[0,-18]})
        clips[action] = {"loop":action == "run","frames":entries}
    if not animation_player.set_profile({"schema":"fs-animation-v1","source":"flow_body_candidate","clips":clips}):
        return false
    _configured = true
    _away = Vector2.ZERO
    animation_player.position = Vector2.ZERO
    return true

# Vector points FROM actor TOWARD enemy, in the actor presentation parent's
# local coordinates. Direction is not inferred from screen facing or changed art.
func start_action(action: String, toward_enemy: Vector2 = Vector2.ZERO) -> bool:
    if not _configured or not ACTIONS.has(action):
        return false
    if action == "dodge" and (not toward_enemy.is_finite() or toward_enemy.length_squared() < 0.000001):
        return false
    _away = -toward_enemy.normalized() if action == "dodge" else Vector2.ZERO
    animation_player.position = Vector2.ZERO
    return animation_player.play_clip(action)

# Called once by a future authoritative resolved-event consumer. Never poll
# fs_last_action_result every screen refresh (the field can be stale).
# Miss must not trigger a dodge or interrupt an existing presentation.
func present_resolved_evade(result_kind: String, toward_enemy: Vector2) -> bool:
    if result_kind != "evade":
        return false
    return start_action("dodge",toward_enemy)

func reset_presentation() -> void:
    if animation_player == null:
        return
    animation_player.stop()
    animation_player.position = Vector2.ZERO
    _away = Vector2.ZERO

func _frame_entered(action: String, index: int) -> void:
    if action == "dodge" and index >= 0 and index < BACKSTEP.size():
        animation_player.position = _away * BACKSTEP[index]
    else:
        animation_player.position = Vector2.ZERO
    # Vertical hop is already baked into the body frames. No extra jump offset.

func _clip_finished(action: String) -> void:
    # Hold the last visual position until the caller explicitly resets or starts
    # the next action. No implicit movement of the actor or combat slot.
    visual_finished.emit(action)

func _playback_failed(_reason: String) -> void:
    reset_presentation()
