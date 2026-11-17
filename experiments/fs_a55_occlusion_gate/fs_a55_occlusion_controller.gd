class_name FSA55OcclusionController
extends Node2D
## A55 runtime preview gate: never changes original PixelLab Body or weapon assets.
## Can hide the fully-occluded weapon graphic and expose a *separate, approved*
## tip-only sprite. Shield depth must remain greater than Body depth.
## Sprite-wide hiding is insufficient to fix a baked/hallucinated hand in Body:
## production use therefore requires independent per-frame Body mask QA.

@export_file("*.json") var visibility_file: String = "res://experiments/fs_a55_occlusion_gate/a55_visibility_manifest_reference.json"
@export_node_path("CanvasItem") var body_path: NodePath
@export_node_path("CanvasItem") var shield_path: NodePath
@export_node_path("CanvasItem") var weapon_path: NodePath
@export_node_path("CanvasItem") var weapon_tip_path: NodePath
@export var preview_mode: bool = false

var _body: CanvasItem
var _shield: CanvasItem
var _weapon: CanvasItem
var _tip: CanvasItem
var _lookup: Dictionary = {}
var _last_error: String = ""

func _ready() -> void:
    _body = get_node_or_null(body_path) as CanvasItem
    _shield = get_node_or_null(shield_path) as CanvasItem
    _weapon = get_node_or_null(weapon_path) as CanvasItem
    _tip = get_node_or_null(weapon_tip_path) as CanvasItem
    _load_visibility()

func _key(view: String, action: String, frame: int) -> String:
    return "%s|%s|%d" % [view, action, frame]

func _load_visibility() -> bool:
    _lookup.clear()
    if not FileAccess.file_exists(visibility_file):
        _last_error = "A55 manifest file missing"
        return false
    var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(visibility_file))
    if not (v is Dictionary):
        _last_error = "A55 manifest invalid JSON"
        return false
    var source: Dictionary = v as Dictionary
    var entries: Array = source.get("example_frames", source.get("frames", []))
    if entries.is_empty():
        _last_error = "A55 manifest has no frames"
        return false
    for entry in entries:
        if not (entry is Dictionary):
            _last_error = "A55 manifest frame not Dictionary"
            _lookup.clear()
            return false
        var d: Dictionary = entry
        var frame: int = int(d.get("frame", -1))
        if frame < 0 or frame >= 12 or str(d.get("view", "")).is_empty() or str(d.get("action", "")).is_empty():
            _last_error = "A55 invalid frame/view/action"
            _lookup.clear()
            return false
        var k: String = _key(str(d["view"]), str(d["action"]), frame)
        if _lookup.has(k):
            _last_error = "A55 duplicate visibility key"
            _lookup.clear()
            return false
        var parts: Dictionary = d.get("part_visibility", {})
        if parts.is_empty() or str(d.get("occluder", "")) == "":
            _last_error = "A55 missing visibility or occluder"
            _lookup.clear()
            return false
        _lookup[k] = d
    _last_error = ""
    return true

func get_last_error() -> String:
    return _last_error

func apply_frame(view: String, action: String, frame: int) -> bool:
    if _body == null or _shield == null or _weapon == null or _tip == null:
        _last_error = "A55 requires Body, shield, weapon and tip CanvasItems"
        return false
    var k: String = _key(view, action, frame)
    if not _lookup.has(k):
        _last_error = "A55 frame absent from visibility contract: " + k
        return false
    var d: Dictionary = _lookup[k]
    if not preview_mode:
        if str(d.get("native_art_status", "")) != "ART_PASS":
            _last_error = "A55 unapproved art cannot run as production"
            return false
        if not bool(d.get("body_mask_qa_pass", false)) or str(d.get("source_qa_hash", "")).is_empty():
            _last_error = "A55 missing Body pixel occlusion QA provenance"
            return false
    var vis: Dictionary = d.get("part_visibility", {})
    if not preview_mode:
        if _shield is Sprite2D and (_shield as Sprite2D).texture == null:
            _last_error = "A55 shield has no approved texture"
            return false
        if str(vis.get("blade", "")) == "partially_occluded":
            if _tip is Sprite2D and (_tip as Sprite2D).texture == null:
                _last_error = "A55 visible blade tip texture is missing"
                return false
    var exclusions: Array = d.get("guide_must_exclude", [])
    var hand_hidden: bool = str(vis.get("sword_hand", "")) == "fully_occluded"
    if hand_hidden:
        for part in ["sword_hand", "sword_forearm", "fist"]:
            if str(vis.get(part, "")) == "fully_occluded" and not exclusions.has(part):
                _last_error = "A55 hidden part absent from guide exclusion: " + part
                return false
    var shield_front: int = maxi(_body.z_index, 0) + 2
    _shield.z_index = shield_front
    _weapon.z_index = shield_front - 1
    _tip.z_index = shield_front + 1
    _shield.visible = true
    # Fully occluded hand/hilt must not be drawn on top of the shield.
    # A separately prepared visible blade tip is the only exposed weapon part.
    _weapon.visible = not hand_hidden
    _tip.visible = str(vis.get("blade", "")) == "partially_occluded"
    _last_error = ""
    return true
