extends AnimatedSprite2D
# R27: isolated fixture only. Raw source row 1; not a global direction mapping.
# Preserve frame-cell displacement; never infer per-frame recentering.
var configured: bool = false
var started_count: int = 0
var finished_count: int = 0
var last_started: StringName = &""

func configure(frames: SpriteFrames) -> bool:
    if frames == null:
        return false
    for name in [&"idle", &"walk", &"attack"]:
        if not frames.has_animation(name):
            return false
    if frames.get_animation_loop(&"attack"):
        return false
    sprite_frames=frames
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    scale=Vector2.ONE
    centered=true
    var tex := frames.get_frame_texture(&"idle", 0)
    var box := tex.get_image().get_used_rect()
    offset=Vector2(0, tex.get_height()*0.5-box.end.y)
    if not animation_finished.is_connected(_return_idle):
        animation_finished.connect(_return_idle)
    configured=true
    return start_motion(&"Idle")

func start_motion(action: StringName) -> bool:
    if not configured:
        return false
    if action==&"Strike":
        action=&"Attack"
    # Explicit fixture motion contract; other source motions remain accessible
    # in the shared resource but are not automatically mapped to gameplay.
    if not action in [&"Idle",&"Walk",&"Attack"]:
        return false
    var clip:=StringName(String(action).to_lower())
    if not sprite_frames.has_animation(clip):
        return false
    stop()
    play(clip)
    last_started=action
    started_count+=1
    return true

func _return_idle() -> void:
    finished_count+=1
    if configured:
        play(&"idle")
