extends SceneTree

# Use real editor dock buttons and preview Window. Never save source files.
const DockScript = preload("res://addons/fs_event_studio/FSStoryEditorDock.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(ok: bool, msg: String) -> bool:
    if not ok:
        push_error("FS Event Studio editor preview FAILURE: " + msg)
        quit(1)
        return false
    return true

func _run() -> void:
    var dock = DockScript.new()
    root.add_child(dock)
    var p: Dictionary = dock._doc["pages"][0]
    p["steps"] = [
        {"op":"dialogue","text":"尚未儲存但能立即預覽","face":"","face_index":0,"background":0,"position":2},
        {"op":"switch","id":31,"enabled":true}
    ]
    dock._changed()
    if not _assert(dock._dirty and dock._path.is_empty(),"in-memory edit is unsaved"): return
    dock._preview_clicked()
    var window: FSStoryPreviewWindow = dock._preview_dialog
    if not _assert(window.visible and window.dialogue._mode == "message","button opens native preview window"): return
    if not _assert("尚未儲存但能立即預覽" in window.dialogue.message.text,"unsaved script previewed"): return
    window.dialogue.advance_message()
    if not _assert(window.state.switch_on(31) and not window.story.runner.active,"preview executes switch"): return
    if not _assert(dock._dirty and dock._path.is_empty(),"preview did not persist document"): return
    dock.queue_free()
    print("FS Event Studio actual editor button unsaved page preview PASS")
    quit(0)
