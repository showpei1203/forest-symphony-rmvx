extends Node2D
class_name FSTAActorMotionRig

# T-A candidate: 3 independent 256x192 RGBA atlases per motion, 12 cells of 64x64.
# Presentation ONLY. The battle damage authority stays in the existing FS ATB code.
signal motion_started(motion: String)
signal frame_entered(motion: String, frame: int)
signal contact_reached(second: float, frame: int)
signal motion_finished(motion: String)
signal motion_failed(reason: String)

const FRAME_COUNT: int = 12
const CELL: int = 64
const COLUMNS: int = 4
const ATLAS_SIZE: Vector2i = Vector2i(256, 192)
const RUN_FRAME_SEC: float = 0.080
# A52 frozen pose key-times from the formal 2026-11-16 handoff.
const ATTACK_KEYS: Array[float] = [0.000, 0.100, 0.190, 0.275, 0.350, 0.455,
    0.560, 0.620, 0.735, 0.830, 0.910, 0.980]
const ATTACK_CONTACT_SEC: float = 0.630
const ATTACK_CONTACT_FRAME: int = 7
const ATTACK_END_SEC: float = 1.060
const HITSTOP_SEC: float = 0.070  # Metadata only; combat authority controls actual hitstop.

var motion: String = ""
var frame_index: int = 0
var playing: bool = false
var elapsed_sec: float = 0.0
var playback_speed: float = 1.0
var _contact_sent: bool = false
var _atlases: Dictionary = {}
var _layers: Array[Sprite2D] = []

func _ready() -> void:
    _ensure_layers()

func _ensure_layers() -> void:
    if _layers.size() == 3:
        return
    for layer_name in ["Body", "Weapon", "FX"]:
        var layer := Sprite2D.new()
        layer.name = layer_name
        layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        layer.centered = true
        layer.region_enabled = true
        layer.region_rect = Rect2(0, 0, CELL, CELL)
        add_child(layer)
        _layers.append(layer)

func layers() -> Array[Sprite2D]:
    _ensure_layers()
    return _layers

func _contains_visible_pixels(texture: Texture2D) -> bool:
    var img: Image = texture.get_image()
    if img == null:
        return false
    for y in img.get_height():
        for x in img.get_width():
            if img.get_pixel(x,y).a > 0.01:
                return true
    return false

func configure_atlases(run_body: Texture2D, run_weapon: Texture2D, run_fx: Texture2D,
        attack_body: Texture2D, attack_weapon: Texture2D, attack_fx: Texture2D) -> bool:
    _ensure_layers()
    var run_textures: Array = [run_body, run_weapon, run_fx]
    var attack_textures: Array = [attack_body, attack_weapon, attack_fx]
    for group in [run_textures, attack_textures]:
        for texture in group:
            if texture == null or texture.get_size() != Vector2(ATLAS_SIZE):
                motion_failed.emit("All six layer atlases must be 256x192")
                return false
    # Do not allow the old transparent RUN weapon placeholder to pass as equipped.
    # FX may legitimately be empty for a non-impact RUN motion.
    for group in [run_textures, attack_textures]:
        if not _contains_visible_pixels(group[0]) or not _contains_visible_pixels(group[1]):
            motion_failed.emit("Body/Weapon atlas is visually empty")
            return false
    _atlases = {"run":run_textures, "attack":attack_textures}
    playing = false
    motion = ""
    return true

func load_private_atlases(folder: String = "res://assets/ta_actor01") -> bool:
    # These PRIVATE binaries must be staged from owner Drive. Never fall back to
    # another actor, or pretend a synthetic test texture is production art.
    if not folder.begins_with("res://") or ".." in folder:
        motion_failed.emit("Invalid private asset folder")
        return false
    var keys: Array[String] = [
        "run_body.png", "run_weapon.png", "run_fx.png",
        "attack_body.png", "attack_weapon.png", "attack_fx.png"
    ]
    var textures: Array[Texture2D] = []
    for key in keys:
        var path: String = folder.path_join(key)
        if not ResourceLoader.exists(path):
            motion_failed.emit("Private source asset missing: " + key)
            return false
        var texture: Texture2D = load(path) as Texture2D
        if texture == null:
            motion_failed.emit("Private source asset invalid: " + key)
            return false
        textures.append(texture)
    return configure_atlases(textures[0], textures[1], textures[2],
        textures[3], textures[4], textures[5])

func start_motion(next_motion: String) -> bool:
    if not _atlases.has(next_motion):
        motion_failed.emit("Missing motion atlases: " + next_motion)
        return false
    _ensure_layers()
    motion = next_motion
    frame_index = 0
    elapsed_sec = 0.0
    _contact_sent = false
    playing = true
    _set_frame(0)
    motion_started.emit(motion)
    frame_entered.emit(motion, 0)
    return true

func cancel() -> void:
    playing = false

func _process(delta: float) -> void:
    advance_seconds(delta)

func advance_seconds(delta: float) -> void:
    if not playing or delta <= 0.0 or playback_speed <= 0.0:
        return
    var step: float = delta * playback_speed
    var previous: float = elapsed_sec
    if motion == "run":
        var cycle: float = RUN_FRAME_SEC * float(FRAME_COUNT)
        elapsed_sec = fposmod(previous + step, cycle)
        var next_frame: int = mini(FRAME_COUNT-1, int(floor(elapsed_sec / RUN_FRAME_SEC)))
        if next_frame != frame_index:
            _set_frame(next_frame)
            frame_entered.emit(motion, next_frame)
    elif motion == "attack":
        elapsed_sec = minf(previous + step, ATTACK_END_SEC)
        # Exact 0.63 second visual contact, independent from actual damage logic.
        if not _contact_sent and previous < ATTACK_CONTACT_SEC and elapsed_sec >= ATTACK_CONTACT_SEC:
            _contact_sent = true
            contact_reached.emit(ATTACK_CONTACT_SEC, ATTACK_CONTACT_FRAME)
        var next_frame: int = 0
        for i in range(FRAME_COUNT):
            if elapsed_sec >= ATTACK_KEYS[i]:
                next_frame = i
        if next_frame != frame_index:
            _set_frame(next_frame)
            frame_entered.emit(motion, next_frame)
        if elapsed_sec >= ATTACK_END_SEC:
            playing = false
            motion_finished.emit(motion)

func _set_frame(index: int) -> void:
    frame_index = index
    var rect := Rect2(float(index % COLUMNS * CELL),
        float(index / COLUMNS * CELL), float(CELL), float(CELL))
    var textures: Array = _atlases[motion]
    for layer_index in range(3):
        var sprite: Sprite2D = _layers[layer_index]
        sprite.texture = textures[layer_index] as Texture2D
        sprite.region_rect = rect
