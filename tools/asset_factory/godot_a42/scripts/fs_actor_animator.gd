class_name FSBattleActorAnimator
extends Node2D
## FS A42: pixel-perfect A41 disassembled Body/Weapon/FX, one Godot timeline, hitstop.
## Attack is non-looping. A39 approved breathing and original 5 atlas profiles are kept.

signal motion_started(motion: StringName, profile: StringName)
signal motion_unavailable(motion: StringName)
signal attack_hit(attack_serial: int, contact_second: float)
signal attack_contact_anchor(attack_serial: int, local_anchor: Vector2, world_anchor: Vector2)
signal attack_finished(attack_serial: int)
signal attack_cancelled(attack_serial: int)
signal hitstop_started(attack_serial: int, duration: float)
signal hitstop_finished(attack_serial: int)

const ATTACK_HIT_SECOND: float = 0.55
const ATTACK_TOTAL_SECOND: float = 1.00
const ATTACK_FRAME_COUNT: int = 12
@export_range(0.0, 0.25, 0.005) var hitstop_seconds: float = 0.070
@export var weapon_enabled: bool = true
@export var fx_enabled: bool = true

@export_file("*.json") var manifest_file: String = "res://assets/actor01_animation_manifest.json"
@export var initial_motion: StringName = &"idle"
@export var initial_profile: StringName = &"idle_calm"
@export_range(0.25, 3.0, 0.05) var playback_multiplier: float = 1.0

@onready var actor_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var breath_rig: FSActorBreathRig = $BreathRig
@onready var attack_clock: AnimationPlayer = $AttackClock
@onready var attack_marker: Marker2D = $HitMarker
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var fx_sprite: AnimatedSprite2D = $EffectSprite

var _profile_motion: Dictionary = {}
var _default_profiles: Dictionary = {}
var _active_motion: StringName = &""
var _active_profile: StringName = &""
var _attack_serial: int = 0
var _attack_hit_sent: bool = false
var _hitstop_remaining: float = 0.0
var _hitstop_active: bool = false

func _ready() -> void:
    _install_attack_clock()
    attack_clock.animation_finished.connect(_on_attack_clock_finished)
    var raw_text: String = FileAccess.get_file_as_string(manifest_file)
    if raw_text.is_empty():
        push_error("FS A40: manifest missing: " + manifest_file)
        return
    var data: Variant = JSON.parse_string(raw_text)
    if not (data is Dictionary):
        push_error("FS A40: invalid JSON manifest")
        return
    var manifest: Dictionary = data as Dictionary
    _default_profiles = manifest.get("default_profiles", {})
    var profiles: Dictionary = manifest.get("animation_profiles", {})
    var frame_bank := SpriteFrames.new()
    if frame_bank.has_animation("default"):
        frame_bank.remove_animation("default")
    for key in profiles.keys():
        var config: Dictionary = profiles[key]
        var motion: String = str(config.get("motion", ""))
        var sheet_path: String = str(config.get("sprite_sheet", ""))
        var texture: Texture2D = load(sheet_path) as Texture2D
        if texture == null or motion.is_empty():
            push_error("FS A40: missing motion texture or name for " + str(key))
            continue
        var grid: Dictionary = config.get("grid", {})
        var fw: int = int(grid.get("frame_width", 0))
        var fh: int = int(grid.get("frame_height", 0))
        var cols: int = int(grid.get("columns", 0))
        var rows: int = int(grid.get("rows", 0))
        var count: int = int(grid.get("frame_count", 0))
        if fw <= 0 or fh <= 0 or cols <= 0 or rows <= 0 or count <= 0 or count > cols * rows:
            push_error("FS A40: invalid grid for " + str(key))
            continue
        if texture.get_size() != Vector2(fw * cols, fh * rows):
            push_error("FS A40: manifest sprite sheet mismatch for " + str(key))
            continue
        var durations: Array = config.get("durations", [])
        if durations.size() != count:
            push_error("FS A40: invalid duration count for " + str(key))
            continue
        var profile: String = str(key)
        frame_bank.add_animation(profile)
        frame_bank.set_animation_loop(profile, bool(config.get("loop", true)))
        frame_bank.set_animation_speed(profile, float(config.get("fps", 8.0)))
        for i in range(count):
            var atlas := AtlasTexture.new()
            atlas.atlas = texture
            atlas.region = Rect2((i % cols) * fw, int(i / cols) * fh, fw, fh)
            atlas.filter_clip = true
            frame_bank.add_frame(profile, atlas, float(durations[i]))
        _profile_motion[profile] = motion
    actor_sprite.sprite_frames = frame_bank
    _install_layer_frame_bank()
    actor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor_sprite.centered = true
    actor_sprite.speed_scale = playback_multiplier
    attack_clock.speed_scale = playback_multiplier
    if not play_motion(initial_motion, initial_profile):
        push_error("FS A40: initial motion or profile not available")

func _install_layer_frame_bank() -> void:
    # Weapon and FX use distinct RGBA atlases, never mixed into canonical character pixels.
    for sprite_node: AnimatedSprite2D in [weapon_sprite, fx_sprite]:
        var name: String = "weapon" if sprite_node == weapon_sprite else "fx"
        var tex: Texture2D = load("res://assets/actor01_a42_%s_12frames.png" % name) as Texture2D
        assert(tex != null and tex.get_size() == Vector2(256, 192))
        var frames := SpriteFrames.new()
        if frames.has_animation("default"):
            frames.remove_animation("default")
        frames.add_animation("attack_weighted")
        frames.set_animation_loop("attack_weighted", false)
        frames.set_animation_speed("attack_weighted", 12.0)
        for i in range(ATTACK_FRAME_COUNT):
            var cell := AtlasTexture.new()
            cell.atlas = tex
            cell.region = Rect2((i % 4) * 64, int(i / 4) * 64, 64, 64)
            cell.filter_clip = true
            frames.add_frame("attack_weighted", cell)
        sprite_node.sprite_frames = frames
        sprite_node.centered = true
        sprite_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite_node.animation = &"attack_weighted"
        sprite_node.stop()
        sprite_node.visible = false

func set_weapon_enabled(enabled: bool) -> void:
    weapon_enabled = enabled
    weapon_sprite.visible = _active_motion == &"attack" and enabled

func set_fx_enabled(enabled: bool) -> void:
    fx_enabled = enabled
    fx_sprite.visible = _active_motion == &"attack" and enabled

func _set_attack_layers(visible_now: bool) -> void:
    weapon_sprite.visible = visible_now and weapon_enabled
    fx_sprite.visible = visible_now and fx_enabled

func get_hitstop_remaining() -> float:
    return _hitstop_remaining

func _process(delta: float) -> void:
    if not _hitstop_active:
        return
    _hitstop_remaining = maxf(0.0, _hitstop_remaining - delta)
    if _hitstop_remaining <= 0.0:
        _hitstop_active = false
        if _active_motion == &"attack":
            attack_clock.speed_scale = playback_multiplier
            hitstop_finished.emit(_attack_serial)

func _begin_hitstop() -> void:
    if hitstop_seconds <= 0.0:
        return
    _hitstop_remaining = hitstop_seconds
    _hitstop_active = true
    attack_clock.speed_scale = 0.0
    hitstop_started.emit(_attack_serial, hitstop_seconds)

func _install_attack_clock() -> void:
    # Single authoritative Godot AnimationPlayer timeline controls BOTH pose frame
    # and contact method. This eliminates independent SpriteFrames/Clock desync.
    attack_clock.callback_mode_method = AnimationMixer.ANIMATION_CALLBACK_MODE_METHOD_IMMEDIATE
    var strike := Animation.new()
    strike.length = ATTACK_TOTAL_SECOND
    strike.loop_mode = Animation.LOOP_NONE
    var frame_track: int = strike.add_track(Animation.TYPE_VALUE)
    strike.track_set_path(frame_track, NodePath("AnimatedSprite2D:frame"))
    strike.track_set_interpolation_type(frame_track, Animation.INTERPOLATION_NEAREST)
    strike.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
    var weapon_track: int = strike.add_track(Animation.TYPE_VALUE)
    strike.track_set_path(weapon_track, NodePath("WeaponSprite:frame"))
    strike.track_set_interpolation_type(weapon_track, Animation.INTERPOLATION_NEAREST)
    strike.value_track_set_update_mode(weapon_track, Animation.UPDATE_DISCRETE)
    var fx_track: int = strike.add_track(Animation.TYPE_VALUE)
    strike.track_set_path(fx_track, NodePath("EffectSprite:frame"))
    strike.track_set_interpolation_type(fx_track, Animation.INTERPOLATION_NEAREST)
    strike.value_track_set_update_mode(fx_track, Animation.UPDATE_DISCRETE)
    for i in range(ATTACK_FRAME_COUNT):
        var at: float = float(i) / 12.0
        strike.track_insert_key(frame_track, at, i)
        strike.track_insert_key(weapon_track, at, i)
        strike.track_insert_key(fx_track, at, i)
    var hit_track: int = strike.add_track(Animation.TYPE_METHOD)
    strike.track_set_path(hit_track, NodePath("."))
    strike.track_insert_key(hit_track, ATTACK_HIT_SECOND, {"method": "_on_attack_contact", "args": []})
    var library := AnimationLibrary.new()
    library.add_animation("attack_contact", strike)
    attack_clock.add_animation_library("", library)

func _on_attack_contact() -> void:
    if _active_motion != &"attack" or _attack_hit_sent:
        return
    _attack_hit_sent = true
    attack_hit.emit(_attack_serial, ATTACK_HIT_SECOND)
    attack_contact_anchor.emit(_attack_serial, attack_marker.position, to_global(attack_marker.position))
    # A real battle listener may interrupt/cancel during the hit callback.
    # Never freeze an actor that has already changed motion on that same callback.
    if _active_motion == &"attack":
        _begin_hitstop()

func _on_attack_clock_finished(anim_name: StringName) -> void:
    if anim_name != &"attack_contact" or _active_motion != &"attack":
        return
    var serial: int = _attack_serial
    # Re-enter stable A39 shader idle only when the SAME timeline ends.
    play_motion(&"idle", &"idle_rig")
    attack_finished.emit(serial)

func _cancel_attack_clock() -> void:
    if _active_motion == &"attack":
        attack_clock.stop()
        _hitstop_remaining = 0.0
        _hitstop_active = false
        _set_attack_layers(false)
        if not _attack_hit_sent:
            attack_cancelled.emit(_attack_serial)

func play_motion(motion: StringName, profile: StringName = &"") -> bool:
    var motion_key: String = str(motion)
    var profile_key: String = str(profile)
    if profile_key.is_empty():
        profile_key = str(_default_profiles.get(motion_key, ""))
    # Never restart ATTACK before its actual finish: one timeline, at most one hit.
    if motion == &"attack" and _active_motion == &"attack":
        return false
    # A39 Godot breathing remains separate from the atlas-based animations.
    if motion == &"idle" and profile_key == "idle_rig":
        _cancel_attack_clock()
        actor_sprite.stop()
        actor_sprite.visible = false
        breath_rig.visible = true
        breath_rig.start_breathing()
        breath_rig.breath_player.speed_scale = playback_multiplier
        _active_motion = motion
        _active_profile = &"idle_rig"
        motion_started.emit(_active_motion, _active_profile)
        return true
    if not _profile_motion.has(profile_key) or str(_profile_motion[profile_key]) != motion_key:
        motion_unavailable.emit(motion)
        return false
    if actor_sprite.sprite_frames == null or not actor_sprite.sprite_frames.has_animation(profile_key):
        motion_unavailable.emit(motion)
        return false
    _cancel_attack_clock()
    breath_rig.stop_breathing()
    breath_rig.visible = false
    actor_sprite.visible = true
    _active_motion = motion
    _active_profile = StringName(profile_key)
    if motion == &"attack":
        _attack_serial += 1
        _attack_hit_sent = false
        actor_sprite.animation = profile_key
        actor_sprite.stop()
        actor_sprite.frame = 0
        weapon_sprite.animation = &"attack_weighted"
        fx_sprite.animation = &"attack_weighted"
        weapon_sprite.stop()
        fx_sprite.stop()
        weapon_sprite.frame = 0
        fx_sprite.frame = 0
        _set_attack_layers(true)
        _hitstop_remaining = 0.0
        _hitstop_active = false
        attack_clock.stop()
        attack_clock.speed_scale = playback_multiplier
        attack_clock.play("attack_contact")
    else:
        actor_sprite.play(profile_key)
    motion_started.emit(_active_motion, _active_profile)
    return true

func set_profile(profile: StringName) -> bool:
    return play_motion(_active_motion, profile)

func set_playback_multiplier(factor: float) -> void:
    playback_multiplier = clampf(factor, 0.25, 3.0)
    actor_sprite.speed_scale = playback_multiplier
    breath_rig.breath_player.speed_scale = playback_multiplier
    attack_clock.speed_scale = 0.0 if _hitstop_active else playback_multiplier

func get_motion() -> StringName:
    return _active_motion

func get_profile() -> StringName:
    return _active_profile

func get_frame_index() -> int:
    if _active_profile == &"idle_rig":
        return breath_rig.get_phase_index()
    return actor_sprite.frame

func is_motion_supported(motion: StringName) -> bool:
    if motion == &"idle":
        return true
    for available in _profile_motion.values():
        if str(available) == str(motion):
            return true
    return false