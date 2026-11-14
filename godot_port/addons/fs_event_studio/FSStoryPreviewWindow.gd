@tool
extends Window
class_name FSStoryPreviewWindow

# Zero-file in-memory preview of the CURRENTLY SELECTED editor page.
# Uses the SAME FSVXEventInterpreter and FSDialoguePanel as the game.
# It never writes to res:// or user PC, and does not claim battle/transfer parity.
signal preview_started()
signal preview_failed(reason: String)
signal preview_completed()

const DATA = preload("res://scripts/story/FSStoryData.gd")
const StateScript = preload("res://scripts/FSGameState.gd")
const StoryScript = preload("res://scripts/story/FSStoryRuntime.gd")
const DialogueScript = preload("res://scripts/story/FSDialoguePanel.gd")

var state: FSGameState
var story: FSStoryRuntime
var dialogue: FSDialoguePanel
var header: Label
var footer: Label

func _ready() -> void:
    title = "FS Event Studio｜當前頁面預覽"
    size = Vector2i(544,416)
    min_size = Vector2i(544,416)
    unresizable = false
    close_requested.connect(_on_close)
    _build_view()
    story = StoryScript.new()
    add_child(story)
    story.story_failed.connect(_on_error)
    story.runner.completed.connect(_on_complete)
    story.runner.battle_requested.connect(_on_battle_preview)
    story.runner.transfer_requested.connect(_on_transfer_preview)
    dialogue = DialogueScript.new()
    add_child(dialogue)
    dialogue.bind(story.runner)

func _build_view() -> void:
    var backdrop := ColorRect.new()
    backdrop.name = "Background"
    backdrop.color = Color(0.09,0.17,0.18)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    var caption := Label.new()
    caption.name = "PreviewLabel"
    caption.text = "FS Event Studio：此為事件頁即時預覽，不會寫入磁碟。"
    caption.position = Vector2(12,12)
    backdrop.add_child(caption)
    header = Label.new()
    header.name = "PageTitle"
    header.position = Vector2(12,45)
    header.add_theme_font_size_override("font_size",20)
    backdrop.add_child(header)
    var guidance := Label.new()
    guidance.position = Vector2(12,94)
    guidance.text = "請使用繼續／選項按鈕播放對話。\n效果會寫進此預覽專屬的遊戲狀態，不會更改正在開發的遊戲存檔。"
    backdrop.add_child(guidance)

    footer = Label.new()
    footer.name = "PreviewStatus"
    footer.position = Vector2(12,184)
    footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    footer.custom_minimum_size = Vector2(520,42)
    backdrop.add_child(footer)

func preview_page(event: Dictionary, page_index: int) -> Dictionary:
    var source: Dictionary = DATA.get_page(event,page_index)
    if source.is_empty():
        return {"ok":false,"error":"找不到要預覽的事件頁"}
    if story.runner.active:
        story.runner.abort_current("已重新開始預覽")
    state = StateScript.new()
    state.map_id = int(event.get("map_id",1))
    var isolated: Dictionary = event.duplicate(true)
    isolated["pages"] = [source.duplicate(true)]
    var condition: Dictionary = source.get("condition",{})
    for field in ["switch_id","switch2_id"]:
        if int(condition.get(field,0)) > 0:
            state.set_switch(int(condition[field]),true)
    if int(condition.get("variable_id",0)) > 0:
        state.set_variable(int(condition["variable_id"]),int(condition.get("variable_min",0)))
    var letter: String = str(condition.get("self_switch",""))
    if not letter.is_empty():
        state.set_self_switch(state.map_id,int(event.get("event_id",1)),letter,true)

    header.text = "%s｜第 %d 頁：%s" % [
        str(event.get("name","新事件")),page_index+1,str(source.get("title",""))]
    footer.text = "預覽事件（不存檔）"
    popup_centered(Vector2i(544,416))
    var result: Dictionary = story.interact(isolated,state,str(source.get("trigger","action")))
    if not bool(result.get("ok",false)):
        _on_error(str(result.get("error","預覽失敗")))
        return result
    preview_started.emit()
    return result

func _on_error(reason: String) -> void:
    footer.text = "無法繼續：" + reason
    preview_failed.emit(reason)

func _on_complete() -> void:
    footer.text = "事件執行完成｜金錢 %d｜持有物品種類 %d｜已設開關 %d" % [
        state.gold,state.inventory.size(),state.switches.size()]
    preview_completed.emit()

func _on_battle_preview(troop_id: int,_escape: bool,_lose: bool) -> void:
    story.runner.abort_current("預覽模式未載入原始戰鬥資料，已停在 Troop #%d" % troop_id)

func _on_transfer_preview(map_id: int,_x: int,_y: int,_direction: int) -> void:
    story.runner.abort_current("預覽模式尚未載入 Map #%d，沒有執行傳送" % map_id)

func _on_close() -> void:
    if story.runner.active:
        story.runner.abort_current("使用者關閉預覽")
    hide()
