extends FSAnimationSprite
class_name FSActionSprite

# Backward-compatible façade for original FS 16-row Kaduki actions.
# New Godot animations should use FSAnimationSprite directly with arbitrary frames.
const PROFILE = preload("res://scripts/animation/FSAnimationProfile.gd")

var frames_per_second: float = 6.0

func load_actor(prefix: String) -> bool:
    var duration_ms: int = maxi(1,int(round(1000.0 / maxf(frames_per_second,0.01))))
    return set_profile(PROFILE.legacy_kaduki(prefix,"res://assets/characters/",duration_ms))

func play_action(index: int) -> bool:
    if index < 0 or index >= 16:
        playback_failed.emit("原版 Kaduki 動作 index 必須介於 0..15")
        return false
    return play_clip("legacy_%02d" % index)

func load_flexible_profile(next_profile: Dictionary) -> bool:
    return set_profile(next_profile)

func play_named_action(name: String) -> bool:
    return play_clip(name)
