extends AnimatedSprite2D
# Candidate presentation only: no damage, hit event, weapon or FX.
const MODES := {"attack":false, "run":true, "damage":false, "dodge":false, "cast":false}
signal motion_started(action: String)
signal motion_completed(action: String)
signal motion_cancelled(action: String)
var current_action := ""

func _ready() -> void:
    sprite_frames = SpriteFrames.new()
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    centered = false
    offset = Vector2(-32,-50)
    animation_finished.connect(_finished)

func _valid_order(action: String, n: int, order: Array) -> bool:
    if order.is_empty():
        return n >= 4 and n <= 16
    if action != "run" or n != 3 or order.size() != 4:
        return false
    for i in order:
        if (typeof(i) != TYPE_INT and typeof(i) != TYPE_FLOAT) or float(i) != floorf(float(i)):
            return false
    return order == [0,1,0,2] or order == [0.0,1.0,0.0,2.0]

func register_motion(action: String, atlas: Image, ms: Array, airborne: Array = [], order: Array = []) -> bool:
    if not MODES.has(action) or atlas == null or sprite_frames == null or sprite_frames.has_animation(action):
        return false
    var n := ms.size()
    if not _valid_order(action,n,order) or atlas.get_size() != Vector2i(256,64 * ceili(n/4.0)):
        return false
    var total := 0.0
    for d in ms:
        if (typeof(d) != TYPE_INT and typeof(d) != TYPE_FLOAT) or float(d) != floorf(float(d)) or d < 20 or d > 500:
            return false
        total += d
    if total < 200 or total > 4000 or (not airborne.is_empty() and action not in ["run","dodge"]):
        return false
    if not order.is_empty():
        var cycle_total := 0.0
        for index in order:
            cycle_total += float(ms[int(index)])
        if cycle_total < 200 or cycle_total > 4000: return false
    var air: Array[int] = []
    for i in airborne:
        if (typeof(i) != TYPE_INT and typeof(i) != TYPE_FLOAT) or float(i) != floorf(float(i)) or i < 0 or i >= n or air.has(int(i)):
            return false
        air.append(int(i))
    var im := atlas.duplicate() as Image
    im.convert(Image.FORMAT_RGBA8)
    var seen: Array[PackedByteArray] = []
    for i in range(4 * ceili(n/4.0)):
        var r := Rect2i(i%4*64,floori(i/4.0)*64,64,64)
        var cell := im.get_region(r)
        var b := cell.get_used_rect()
        if i >= n:
            if b.size != Vector2i.ZERO: return false
            continue
        if b.size == Vector2i.ZERO or b.position.x <= 0 or b.position.y <= 0 or b.end.x >= 64 or b.end.y > 50:
            return false
        if (air.has(i) and b.end.y >= 50) or (not air.has(i) and b.end.y != 50):
            return false
        var raw := cell.get_data()
        for j in range(3,raw.size(),4):
            if raw[j] != 0 and raw[j] != 255: return false
        if seen.has(raw): return false
        seen.append(raw)
    # Only commit after every cell passes.
    var tex := ImageTexture.create_from_image(im)
    sprite_frames.add_animation(action)
    sprite_frames.set_animation_speed(action,1.0)
    sprite_frames.set_animation_loop(action,MODES[action])
    var sequence: Array = range(n) if order.is_empty() else order
    for index in sequence:
        var i := int(index)
        var slice := AtlasTexture.new()
        slice.atlas = tex
        slice.region = Rect2(i%4*64,floori(i/4.0)*64,64,64)
        slice.filter_clip = true
        sprite_frames.add_frame(action,slice,float(ms[i])/1000.0)
    return true

func load_motion(action: String, allow_fixture: bool = false) -> bool:
    if not MODES.has(action): return false
    var base := "res://motions/" + action + "/"
    var m = JSON.parse_string(FileAccess.get_file_as_string(base+"motion.json"))
    if not m is Dictionary or m.get("schema") != 1 or m.get("action") != action or m.get("body_only") != true or m.get("loop") != MODES[action] or m.get("anchor") != [32.0,50.0] or m.get("events") != [] or m.get("art") != "HOLD":
        return false
    if m.get("source_class") != "OWNER_SUPPLIED_UNAUTHENTICATED" and not (allow_fixture and m.get("source_class") == "SYNTHETIC_TEST_ONLY"):
        return false
    if not m.get("durations_ms") is Array or not m.get("frames") is Array or not m.get("airborne_frames") is Array:
        return false
    var n: int = m.durations_ms.size()
    var order = m.get("playback_order", [])
    if not order is Array or (m.has("playback_order") and order.is_empty()) or not _valid_order(action,n,order) or m.get("frame_count") != n or m.frames.size() != n or m.get("cell") != 64 or m.get("columns") != 4:
        return false
    var ap := base+"body.png"
    var sp := base+"source.bin"
    if not FileAccess.file_exists(ap) or not FileAccess.file_exists(sp) or FileAccess.get_sha256(ap) != m.get("atlas_sha256") or FileAccess.get_sha256(sp) != m.get("source_sha256"):
        return false
    var atlas := Image.load_from_file(ap)
    if atlas == null or atlas.get_size() != Vector2i(256,64*ceili(n/4.0)): return false
    atlas.convert(Image.FORMAT_RGBA8)
    for i in range(n):
        var p := base+"F%02d.png" % (i+1)
        var row = m.frames[i]
        if not row is Dictionary or row.get("index") != i or row.get("duration_ms") != m.durations_ms[i] or row.get("airborne") != m.airborne_frames.has(float(i)) or not FileAccess.file_exists(p) or FileAccess.get_sha256(p) != row.get("sha256"):
            return false
        var cell := Image.load_from_file(p)
        if cell == null or cell.get_size() != Vector2i(64,64): return false
        cell.convert(Image.FORMAT_RGBA8)
        if atlas.get_region(Rect2i(i%4*64,floori(i/4.0)*64,64,64)).get_data() != cell.get_data(): return false
    return register_motion(action,atlas,m.durations_ms,m.airborne_frames,order)

func start_motion(action: String) -> bool:
    if sprite_frames == null or not MODES.has(action) or not sprite_frames.has_animation(action): return false
    cancel_motion()
    current_action = action
    animation = action
    set_frame_and_progress(0,0.0)
    play(action)
    motion_started.emit(action)
    return true

func cancel_motion() -> void:
    if current_action.is_empty(): return
    var old := current_action
    current_action = ""
    stop()
    motion_cancelled.emit(old)

func _finished() -> void:
    if current_action.is_empty(): return
    var old := current_action
    current_action = ""
    motion_completed.emit(old)
