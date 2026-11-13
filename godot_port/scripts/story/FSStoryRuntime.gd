extends Node
class_name FSStoryRuntime

# Uses FSStoryData for new content, FSVXEventInterpreter for the shared VX codes.
# Old RVData events can also call interpreter.start_event directly after conversion.
signal page_started(map_id: int, event_id: int, page_index: int)
signal story_failed(reason: String)

const DATA = preload("res://scripts/story/FSStoryData.gd")
const COMPILER = preload("res://scripts/story/FSStoryCompiler.gd")
var runner: FSVXEventInterpreter

func _ready() -> void:
    runner = FSVXEventInterpreter.new()
    add_child(runner)
    runner.aborted.connect(func(reason: String) -> void: story_failed.emit(reason))

func interact(event: Dictionary, state: FSGameState, trigger: String = "action") -> Dictionary:
    var errors: PackedStringArray = DATA.validate(event)
    if not errors.is_empty():
        return {"ok":false,"error":"; ".join(errors)}
    var page_index: int = DATA.selected_page(event,state)
    if page_index == -1:
        return {"ok":false,"error":"事件沒有符合條件的頁"}
    var page: Dictionary = DATA.get_page(event,page_index)
    if str(page.get("trigger","action")) != trigger:
        return {"ok":false,"error":"頁面觸發方式不相符"}
    if runner.active:
        return {"ok":false,"error":"目前仍有事件執行中"}
    var result: Dictionary = COMPILER.compile_page(page)
    if not bool(result.get("ok",false)):
        return {"ok":false,"error":"; ".join(PackedStringArray(result.get("errors",[])))}
    runner.setup(state)
    # Avoid sending a secondary message after start_event; callbacks may be synchronous.
    page_started.emit(int(event["map_id"]),int(event["event_id"]),page_index)
    runner.start_event(result["commands"],int(event["map_id"]),int(event["event_id"]))
    return {"ok":true,"page_index":page_index}

func interact_legacy_vx(list: Array, state: FSGameState, map_id: int, event_id: int) -> Dictionary:
    # Preserves old events without having to author or migrate them to FS story files.
    if runner.active:
        return {"ok":false,"error":"有另一個事件執行中"}
    runner.setup(state)
    runner.start_event(list,map_id,event_id)
    return {"ok":true,"legacy":true}
