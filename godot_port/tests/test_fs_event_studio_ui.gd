extends SceneTree

# Headless control-wiring smoke for the editor's actual UI classes.
# Synthetic event only; no legacy source files touched.
const Dock = preload("res://addons/fs_event_studio/FSStoryEditorDock.gd")
const Compiler = preload("res://scripts/story/FSStoryCompiler.gd")
const Data = preload("res://scripts/story/FSStoryData.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("FS EVENT STUDIO UI FAIL: " + reason)
    quit(1)

func _run() -> void:
    var dock = Dock.new()
    root.add_child(dock)
    if dock._doc.get("schema","") != Data.SCHEMA:
        _fail("editor did not initialize new valid event")
        return
    var list: Array = dock._doc["pages"][0]["steps"]
    if not list.is_empty():
        _fail("new document not empty")
        return

    var if_index: int = Compiler.OPS.find("if_switch")
    dock._add_selector.select(if_index)
    dock._add_step()
    if list.size() != 2 or list[0].get("op") != "if_switch" or list[1].get("op") != "end_if":
        _fail("adding IF did not auto-insert END")
        return

    var dialogue_index: int = Compiler.OPS.find("dialogue")
    dock._add_selector.select(dialogue_index)
    dock._selected_step = 0
    dock._add_step()
    if list.size() != 3 or list[1].get("op") != "dialogue":
        _fail("inserting dialogue between IF/END")
        return

    dock._step_selected(1)
    var multi: TextEdit
    for control in dock._inspector.get_children():
        if control is TextEdit:
            multi = control
            break
    if multi == null:
        _fail("dialogue does not display editable TextEdit")
        return
    multi.text = "圖形化編輯器真正修改了事件對話"
    multi.text_changed.emit()
    if str(list[1].get("text","")) != "圖形化編輯器真正修改了事件對話":
        _fail("TextEdit change did not update event model")
        return
    dock._undo()
    if dock._doc["pages"][0]["steps"][1]["text"] != "你好！":
        _fail("Undo did not restore prior dialogue")
        return
    dock._redo()
    if dock._doc["pages"][0]["steps"][1]["text"] != "圖形化編輯器真正修改了事件對話":
        _fail("Redo did not recover edited dialogue")
        return

    if not Compiler.compile_page(dock._doc["pages"][0])["ok"]:
        _fail("UI generated invalid opcode blocks")
        return

    # Assign a reserved synthetic identity to avoid collisions in cloud runner.
    dock._doc["map_id"] = 996
    dock._doc["event_id"] = 992
    dock._save_clicked()
    var location: String = Data.path_for(dock._doc)
    if not FileAccess.file_exists(location) or dock._dirty:
        _fail("Save button did not persist validated event")
        return
    dock._open_file(location)
    if dock._doc["pages"][0]["steps"][1]["text"] != "圖形化編輯器真正修改了事件對話":
        _fail("Open button did not restore edited dialogue")
        return

    dock.queue_free()
    print("FS Event Studio UI controls/command insert/dialogue edit/save/open PASS")
    quit(0)
