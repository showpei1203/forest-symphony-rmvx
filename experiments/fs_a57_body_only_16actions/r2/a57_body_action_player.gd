extends Node2D
## Source-gated Body-only A53 preview. Real equipment is attached at runtime.
## No weapon, shield, projectile, or FX pixels in the A53 Body.
## No game damage or MP settlement is done in this animation script.

signal contact_requested(action_id: String)
signal animation_cancelled(action_id: String)
signal animation_finished(action_id: String)

@export var preview_mode: bool = true
@export var playback_speed: float = 1.0
@export var start_automatically: bool = false

@onready var body: Sprite2D = $Body
@onready var right_hand: Marker2D = $RightHandAnchor
@onready var weapon: Sprite2D = $RightHandAnchor/Weapon
@onready var shield: Sprite2D = $ShieldMount/Shield
@onready var effects: Node2D = $Effects

const SOURCE_SHA: String = "af2b94a424ab613fa5a8ff45125f0398da3a20432cdeaa744f87f9f1b1a9ac44"
const ACTION_ID: String = "close_ranged_attack"
const WAITING_ID: String = "waiting"
const WAITING_SHA: String = "d5599785d6d76fe2307c49549d21e5b75930a99842b919a1339bd5ec605ed6d3"
const WAITING_PERIOD: float = 0.175
const WAITING_LOOP: Array[int] = [0, 1, 2, 1]
const FRAME_PERIOD: float = 0.09
const TOTAL_FRAMES: int = 12
const CONTACT_SECOND: float = 0.63
const HITSTOP_SECONDS: float = 0.07
var _anchors: Array = []
var _catalog: Dictionary = {}
var _elapsed: float = 0.0
var _current_action: String = ACTION_ID
var _attack_texture: Texture2D = null
var _waiting_texture: Texture2D = null
var _hitstop_remaining: float = 0.0
var _contact_emitted: bool = false
var _active: bool = false
var _last_error: String = ""
var _initialized_ok: bool = false

func _ready() -> void:
    weapon.visible = false
    shield.visible = false
    var src := FileAccess.open("res://assets/actor01_a53_hand_and_fist_anchors.json", FileAccess.READ)
    if src == null:
        _last_error = "Missing A53 hand anchor source"
        return
    var anchor_variant: Variant = JSON.parse_string(src.get_as_text())
    if not (anchor_variant is Dictionary):
        _last_error = "Invalid hand anchor JSON"
        return
    var anchor_data: Dictionary = anchor_variant
    _anchors = anchor_data.get("pose_anchors", [])
    if _anchors.size() != 12 or int(anchor_data.get("contact_frame", -1)) != 7 or absf(float(anchor_data.get("contact_second", -1.0)) - 0.63) > 0.0001:
        _last_error = "A53 anchor count/contact timing mismatch"
        return
    var raw_catalog := FileAccess.get_file_as_string("res://assets/action_catalog_16.json")
    var parsed: Variant = JSON.parse_string(raw_catalog)
    if not (parsed is Dictionary):
        _last_error = "A57 catalog missing/invalid"
        return
    _catalog = parsed
    if _catalog.get("schema", "") != "FS_A57_BODY_ONLY_16_ACTIONS_V1":
        _last_error = "A57 catalog schema mismatch"
        return
    if FileAccess.get_sha256("res://assets/actor01_a53_body_12frames.png") != SOURCE_SHA:
        _last_error = "A53 original Body source SHA mismatch"
        return
    if body.texture == null or body.hframes != 4 or body.vframes != 3:
        _last_error = "A53 Body atlas must be 4x3"
        return
    if FileAccess.get_sha256("res://assets/actor01_a57_waiting_3pose.png") != WAITING_SHA:
        _last_error = "Waiting source atlas SHA mismatch"
        return
    _attack_texture = body.texture
    _waiting_texture = load("res://assets/actor01_a57_waiting_3pose.png")
    if _waiting_texture == null:
        _last_error = "Waiting source atlas cannot load"
        return
    _set_frame(0)
    _initialized_ok = true
    if start_automatically:
        start_action(ACTION_ID)

func _catalog_entry(id: String) -> Dictionary:
    for x in _catalog.get("items", []):
        if x is Dictionary and x.get("id", "") == id:
            return x
    return {}

func start_action(id: String) -> bool:
    if not _initialized_ok:
        _last_error = "A57 initialization failed: " + _last_error
        return false
    _last_error = ""
    var item := _catalog_entry(id)
    if item.is_empty() or id not in [ACTION_ID, WAITING_ID]:
        _last_error = "Action has no verified A57 Body atlas: " + id
        return false
    if item.get("equipment_art", "") != "EXTERNAL_RUNTIME_ONLY":
        _last_error = "Baked equipment manifest rejected"
        return false
    if not preview_mode and item.get("status", "") != "FORMAL_USER_ART_PASS":
        _last_error = "Art HOLD: A53 attack may play in preview only"
        return false
    _current_action = id
    if id == WAITING_ID:
        body.texture = _waiting_texture
        body.hframes = 3
        body.vframes = 1
    else:
        body.texture = _attack_texture
        body.hframes = 4
        body.vframes = 3
    _elapsed = 0.0
    _hitstop_remaining = 0.0
    _contact_emitted = false
    _active = true
    _last_error = ""
    _set_frame(0)
    return true

func _process(delta: float) -> void:
    tick(delta)

func tick(delta: float) -> void:
    if not _active or delta <= 0.0:
        return
    if _current_action == WAITING_ID:
        _elapsed += delta * maxf(0.0, playback_speed)
        var sequence_index: int = int(floor((_elapsed + 0.00001) / WAITING_PERIOD)) % WAITING_LOOP.size()
        _set_frame(WAITING_LOOP[sequence_index])
        return
    if _hitstop_remaining > 0.0:
        _hitstop_remaining = maxf(0.0, _hitstop_remaining - delta)
        return
    _elapsed = minf(TOTAL_FRAMES * FRAME_PERIOD, _elapsed + delta * maxf(0.0, playback_speed))
    var idx: int = mini(int(floor((_elapsed + 0.00001) / FRAME_PERIOD)), TOTAL_FRAMES - 1)
    _set_frame(idx)
    if not _contact_emitted and _elapsed + 0.00001 >= CONTACT_SECOND:
        _contact_emitted = true
        _hitstop_remaining = HITSTOP_SECONDS
        contact_requested.emit(_current_action)
    if _elapsed >= TOTAL_FRAMES * FRAME_PERIOD:
        _active = false
        animation_finished.emit(_current_action)

func cancel() -> void:
    if _active:
        _active = false
        _hitstop_remaining = 0.0
        animation_cancelled.emit(_current_action)

func _set_frame(idx: int) -> void:
    body.frame = idx
    if _current_action == WAITING_ID:
        # Source F0 right wrist is held by A53 Body. No drawn weapon.
        right_hand.position = Vector2(8.6, 8.5)
        return
    var row: Dictionary = _anchors[idx]
    var wrist: Array = row.get("wrist_px", [])
    if wrist.size() == 2:
        # Body Sprite2D is centered: atlas top-left maps to local (-32,-32).
        right_hand.position = Vector2(float(wrist[0])-32.0, float(wrist[1])-32.0)

func set_runtime_weapon(tex: Texture2D) -> void:
    weapon.texture = tex
    weapon.visible = tex != null

func set_runtime_shield(tex: Texture2D) -> void:
    # ShieldMount needs its own approved left-hand positional data for production.
    shield.texture = tex
    shield.visible = tex != null and preview_mode

func get_error() -> String:
    return _last_error

func current_frame() -> int:
    return body.frame

func is_active() -> bool:
    return _active

func contact_was_requested() -> bool:
    return _contact_emitted
