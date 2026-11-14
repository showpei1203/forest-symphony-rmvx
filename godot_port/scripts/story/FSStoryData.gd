@tool
extends RefCounted
class_name FSStoryData

# Editor-owned FS event format. This is NOT the original VX Map.rvdata layout.
# VX-compatible command arrays are generated on demand by FSStoryCompiler.
const SCHEMA: String = "fs-story-event-v1"
const EVENTS_DIR: String = "res://story/events/"
const TRIGGERS: Array[String] = ["action", "player_touch", "event_touch", "autorun", "parallel"]
const PRIORITIES: Array[String] = ["below", "same", "above"]

static func new_page(title: String = "事件頁 1") -> Dictionary:
    return {
        "title": title, "trigger": "action", "priority": "same",
        "condition": {
            "switch_id": 0, "switch2_id": 0, "variable_id": 0,
            "variable_min": 0, "self_switch": ""
        },
        "steps": []
    }

static func new_event(map_id: int = 1, event_id: int = 1) -> Dictionary:
    return {
        "schema": SCHEMA,
        "map_id": map_id, "event_id": event_id,
        "name": "新事件", "x": 0, "y": 0,
        "pages": [new_page()]
    }

static func get_page(event: Dictionary, index: int) -> Dictionary:
    var pages: Array = event.get("pages", [])
    return pages[index] if index >= 0 and index < pages.size() and pages[index] is Dictionary else {}

static func validate(event: Dictionary) -> PackedStringArray:
    var errors := PackedStringArray()
    if str(event.get("schema", "")) != SCHEMA:
        errors.append("未知事件 schema")
    if int(event.get("map_id", 0)) < 1 or int(event.get("event_id", 0)) < 1:
        errors.append("map_id 與 event_id 必須大於 0")
    var pages: Variant = event.get("pages", [])
    if not pages is Array or pages.is_empty():
        errors.append("事件至少需要一頁")
        return errors
    for i in pages.size():
        if not pages[i] is Dictionary:
            errors.append("第 %d 頁不是 Dictionary" % (i + 1))
            continue
        var page: Dictionary = pages[i]
        if not str(page.get("trigger", "")) in TRIGGERS:
            errors.append("第 %d 頁觸發模式不正確" % (i + 1))
        if not str(page.get("priority", "")) in PRIORITIES:
            errors.append("第 %d 頁優先級不正確" % (i + 1))
        if not page.get("steps", []) is Array:
            errors.append("第 %d 頁指令必須是陣列" % (i + 1))
    return errors

static func path_for(event: Dictionary) -> String:
    return EVENTS_DIR + "map_%03d_event_%03d.json" % [int(event.get("map_id", 0)), int(event.get("event_id", 0))]

static func is_event_path(path: String) -> bool:
    if not path.begins_with(EVENTS_DIR) or not path.ends_with(".json"):
        return false
    if ".." in path or "\\" in path:
        return false
    return true

static func read_event(path: String) -> Dictionary:
    if not is_event_path(path) or not FileAccess.file_exists(path):
        return {}
    var raw: String = FileAccess.get_file_as_string(path)
    var parsed: Variant = JSON.parse_string(raw)
    if not parsed is Dictionary:
        return {}
    if not validate(parsed).is_empty():
        return {}
    return parsed

static func cloud_write_allowed() -> bool:
    # Project HARD RULE 001: generated deliverables must be persisted in GitHub / Drive.
    # Never create a new permanent story file on the user's PC by default.
    # CI and explicitly approved disposable cloud workspaces are the ONLY exceptions.
    return OS.get_environment("GITHUB_ACTIONS") == "true" or (
        OS.get_environment("FS_EVENT_AUTHORIZED_EPHEMERAL_WRITE") == "true")

static func write_event(event: Dictionary, path: String = "") -> Dictionary:
    if not cloud_write_allowed():
        return {"ok":false,"error":"已阻擋本機寫入。使用「複製 JSON」並提交 GitHub／Drive，或改用已授權的隔離雲端工作區。"}
    var errors: PackedStringArray = validate(event)
    if not errors.is_empty():
        return {"ok": false, "error": "; ".join(errors)}
    if path.is_empty():
        path = path_for(event)
    if not is_event_path(path):
        return {"ok": false, "error": "僅允許寫入 res://story/events/*.json"}
    var root: String = ProjectSettings.globalize_path(EVENTS_DIR)
    var err: Error = DirAccess.make_dir_recursive_absolute(root)
    if err != OK:
        return {"ok": false, "error": "無法建立事件資料夾：" + error_string(err)}
    var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return {"ok": false, "error": "無法存檔：" + error_string(FileAccess.get_open_error())}
    file.store_string(JSON.stringify(event, "\t", false) + "\n")
    file.close()
    return {"ok": true, "path": path}

static func selected_page(event: Dictionary, world: Object) -> int:
    # RMVX: the LAST valid page takes precedence. Page conditions are AND.
    var pages: Array = event.get("pages", [])
    for i in range(pages.size() - 1, -1, -1):
        var page: Dictionary = pages[i]
        var condition: Dictionary = page.get("condition", {})
        if int(condition.get("switch_id", 0)) > 0 and not world.switch_on(int(condition["switch_id"])):
            continue
        if int(condition.get("switch2_id", 0)) > 0 and not world.switch_on(int(condition["switch2_id"])):
            continue
        if int(condition.get("variable_id", 0)) > 0 and world.variable(int(condition["variable_id"])) < int(condition.get("variable_min", 0)):
            continue
        var self_letter: String = str(condition.get("self_switch", ""))
        if not self_letter.is_empty() and not world.self_switch_on(
                int(event.get("map_id", 0)), int(event.get("event_id", 0)), self_letter):
            continue
        return i
    return -1
