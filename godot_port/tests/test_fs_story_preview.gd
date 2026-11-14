extends SceneTree

# Visual in-memory event-page preview: no JSON write, no legacy source changes.
const PreviewScript = preload("res://addons/fs_event_studio/FSStoryPreviewWindow.gd")
const DataScript = preload("res://scripts/story/FSStoryData.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("FS event page preview FAILED: "+message)
        quit(1)
        return false
    return true

func _run() -> void:
    var preview = PreviewScript.new()
    root.add_child(preview)
    var doc: Dictionary = DataScript.new_event(989,984)
    doc["name"] = "尚未儲存的預覽事件"
    var page: Dictionary = doc["pages"][0]
    page["condition"]["switch_id"] = 10
    page["steps"] = [
        {"op":"dialogue","text":"不需要存檔就能預覽","face":"","face_index":0,"background":0,"position":2},
        {"op":"choice","options":["領取","拒絕"],"cancel_type":0},
        {"op":"when_choice","index":0},
        {"op":"item","id":13,"amount":2},
        {"op":"when_choice","index":1},
        {"op":"comment","text":"不領取"},
        {"op":"end_choice"}
    ]
    var result: Dictionary = preview.preview_page(doc,0)
    if not _check(result.get("ok",false),"preview selected conditional page"): return
    if not _check(preview.state.switch_on(10),"preview-local state satisfies page condition"): return
    if not _check(preview.dialogue._mode=="message","in-memory dialogue visible"): return
    if not _check("不需要存檔" in preview.dialogue.message.text,"unsaved author content rendered"): return
    preview.dialogue.advance_message()
    if not _check(preview.dialogue._mode=="choice","choice preview"): return
    preview.dialogue._choose(0)
    if not _check(preview.state.amount("item",13)==2,"preview-local reward updates"): return
    if not _check(not preview.story.runner.active,"preview runner finished"): return
    result = preview.preview_page(doc,0)
    if not _check(result.get("ok",false) and preview.state.amount("item",13)==0,
            "preview resets state; does not mutate game save"): return
    preview.dialogue.advance_message()
    preview.dialogue._choose(1)
    if not _check(preview.state.amount("item",13)==0,"decline path no item"): return

    page["steps"] = [
        {"op":"battle","troop_id":4,"escape":false,"lose":false},
        {"op":"when_win"},
        {"op":"end_battle"}
    ]
    result = preview.preview_page(doc,0)
    if not _check(result.get("ok",false),"preview opens unsupported battle event"): return
    if not _check(not preview.story.runner.active and "Troop" in preview.footer.text,
            "battle without original database aborts safely"): return
    print("FS in-memory unsaved story preview dialogue/choices/state reset/battle guard PASS")
    quit(0)
