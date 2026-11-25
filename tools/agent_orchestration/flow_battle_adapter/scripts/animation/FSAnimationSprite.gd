extends Node2D
class_name FSAnimationSprite

# New default for FS characters, enemies and action poses.
# A clip has any number of frames; each frame may have its own size and duration.
# Supports source-exact legacy Kaduki sheets through FSAnimationProfile.legacy_kaduki().
# Does not apply battle damage; marker is a PRESENTATION signal only.

signal clip_started(clip_name: String)
signal frame_entered(clip_name: String, frame: int)
signal marker_reached(clip_name: String, frame: int, marker: String)
signal clip_finished(clip_name: String)
signal playback_failed(reason: String)

const PROFILE = preload("res://scripts/animation/FSAnimationProfile.gd")

var sprite: Sprite2D
var profile: Dictionary = {}
var clip_name: String = ""
var frame_index: int = 0
var elapsed_ms: float = 0.0
var playing: bool = false
var speed_scale: float = 1.0

func _ready() -> void:
    _ensure_sprite()

func _ensure_sprite() -> void:
    if sprite != null:
        return
    sprite = Sprite2D.new()
    sprite.name = "Frame"
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.centered = true
    add_child(sprite)

func set_profile(next_profile: Dictionary) -> bool:
    var errors: PackedStringArray = PROFILE.validate(next_profile)
    if not errors.is_empty():
        playback_failed.emit("; ".join(errors))
        return false
    # Asset validation is deliberately done at playback time, so the private
    # original FS PNGs may arrive in a later cloud asset-import stage.
    profile = next_profile.duplicate(true)
    clip_name = ""
    frame_index = 0
    elapsed_ms = 0.0
    playing = false
    _ensure_sprite()
    sprite.texture = null
    return true

func load_manifest(path: String) -> bool:
    if not path.begins_with("res://") or ".." in path or not path.ends_with(".json"):
        playback_failed.emit("動畫清單必須是 res:// 下的 JSON")
        return false
    if not FileAccess.file_exists(path):
        playback_failed.emit("動畫清單檔尚未匯入：" + path)
        return false
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if not parsed is Dictionary:
        playback_failed.emit("動畫清單 JSON 解析錯誤")
        return false
    return set_profile(parsed)

func available_clips() -> PackedStringArray:
    var out := PackedStringArray()
    for name in profile.get("clips",{}):
        out.append(str(name))
    return out

func play_clip(name: String, restart: bool = true) -> bool:
    _ensure_sprite()
    if not restart and playing and clip_name == name:
        return true
    var clip: Dictionary = profile.get("clips",{}).get(name,{})
    if clip.is_empty() or clip.get("frames",[]).is_empty():
        playback_failed.emit("動作不存在：" + name)
        return false
    var previous: String = clip_name
    clip_name = name
    frame_index = 0
    elapsed_ms = 0.0
    playing = true
    if not _show_frame():
        clip_name = previous
        playing = false
        return false
    clip_started.emit(name)
    _emit_frame()
    return true

func stop(hold_last_frame: bool = true) -> void:
    playing = false
    if not hold_last_frame and sprite != null:
        sprite.texture = null

func current_frame_count() -> int:
    return _frames().size()

func current_frame_duration_ms() -> int:
    var frames: Array = _frames()
    if frame_index >= frames.size():
        return 0
    return maxi(1,int(frames[frame_index].get("duration_ms",100)))

func _frames() -> Array:
    var clip: Dictionary = profile.get("clips",{}).get(clip_name,{})
    return clip.get("frames",[])

func _process(delta: float) -> void:
    advance_ms(delta*1000.0)

func advance_ms(milliseconds: float) -> void:
    # Public method allows deterministic CI regression without frame-rate timing.
    if not playing or milliseconds <= 0:
        return
    elapsed_ms += milliseconds * maxf(0.0,speed_scale)
    var transitions: int = 0
    while playing and elapsed_ms >= current_frame_duration_ms() and transitions < 10000:
        elapsed_ms -= float(current_frame_duration_ms())
        transitions += 1
        var clips: Dictionary = profile.get("clips",{})
        var clip: Dictionary = clips.get(clip_name,{})
        if frame_index == current_frame_count()-1:
            if not bool(clip.get("loop",true)):
                playing = false
                clip_finished.emit(clip_name)
                break
            frame_index = 0
        else:
            frame_index += 1
        if not _show_frame():
            playing = false
            break
        _emit_frame()
    if transitions >= 10000:
        playing = false
        playback_failed.emit("單次播放消耗超過 10000 格，已停止以避免循環")

func _emit_frame() -> void:
    frame_entered.emit(clip_name,frame_index)
    var frames: Array = _frames()
    if frame_index < frames.size():
        var marker: String = str(frames[frame_index].get("marker",""))
        if not marker.is_empty():
            marker_reached.emit(clip_name,frame_index,marker)

func _show_frame() -> bool:
    var frames: Array = _frames()
    if frame_index < 0 or frame_index >= frames.size():
        playback_failed.emit("動畫索引超出範圍")
        return false
    var frame: Dictionary = frames[frame_index]
    var raw: Variant = frame.get("texture",null)
    var texture: Texture2D = null
    if raw is Texture2D:
        texture = raw
    elif raw is String and ResourceLoader.exists(raw):
        texture = load(raw) as Texture2D
    if texture == null:
        playback_failed.emit("找不到動畫圖片：" + str(raw))
        return false
    var rect: Rect2 = Rect2(Vector2.ZERO,texture.get_size())
    if frame.has("grid"):
        var grid: Dictionary = frame["grid"]
        var columns: int = int(grid.get("columns",1))
        var rows: int = int(grid.get("rows",1))
        if columns < 1 or rows < 1 or texture.get_width() % columns != 0 or texture.get_height() % rows != 0:
            playback_failed.emit("動畫圖集尺寸無法整除：" + str(raw))
            return false
        var cell: Vector2 = Vector2(texture.get_width()/columns,texture.get_height()/rows)
        rect = Rect2(Vector2(int(grid.get("column",0)),int(grid.get("row",0)))*cell,cell)
    elif frame.has("rect"):
        var raw_rect: Array = frame["rect"]
        rect = Rect2(float(raw_rect[0]),float(raw_rect[1]),float(raw_rect[2]),float(raw_rect[3]))
    if rect.position.x < 0 or rect.position.y < 0 or rect.end.x > texture.get_width() or rect.end.y > texture.get_height():
        playback_failed.emit("影格裁切超過來源貼圖：" + str(raw))
        return false
    sprite.texture = texture
    sprite.region_enabled = true
    sprite.region_rect = rect
    sprite.flip_h = bool(frame.get("flip_h",false))
    sprite.flip_v = bool(frame.get("flip_v",false))
    var raw_offset: Variant = frame.get("offset",[0,0])
    sprite.offset = Vector2(float(raw_offset[0]),float(raw_offset[1]))
    return true
