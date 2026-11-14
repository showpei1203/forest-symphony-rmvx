@tool
extends VBoxContainer

# Native visual authoring for NEW FS content, preserving VX opcode compatibility.
# Does not modify original E: source or import the legacy map/event database.
const DATA = preload("res://scripts/story/FSStoryData.gd")
const COMPILER = preload("res://scripts/story/FSStoryCompiler.gd")
const Inspector = preload("res://addons/fs_event_studio/FSStoryStepInspector.gd")
const PreviewWindow = preload("res://addons/fs_event_studio/FSStoryPreviewWindow.gd")

var _doc: Dictionary = {}
var _path: String = ""
var _page_index: int = 0
var _selected_step: int = -1
var _dirty: bool = false
var _pending_action: String = ""
var _history: Array = []
var _history_index: int = -1
var _saved_snapshot: String = ""

var _status: Label
var _metadata: VBoxContainer
var _page_fields: VBoxContainer
var _pages: OptionButton
var _step_list: ItemList
var _add_selector: OptionButton
var _inspector: VBoxContainer
var _open_dialog: FileDialog
var _discard_dialog: ConfirmationDialog
var _preview_dialog: FSStoryPreviewWindow

func _ready() -> void:
    name = "FS Event Studio"
    custom_minimum_size = Vector2(780,350)
    _build_ui()
    _set_document(DATA.new_event(),"")

func _make_button(parent: Node, caption: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = caption
    button.pressed.connect(callback)
    parent.add_child(button)
    return button

func _make_label(parent: Node, caption: String) -> Label:
    var label := Label.new()
    label.text = caption
    parent.add_child(label)
    return label

func _clear(parent: Node) -> void:
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func _build_ui() -> void:
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var toolbar := HBoxContainer.new()
    add_child(toolbar)
    _make_label(toolbar,"FS Event Studio")
    _make_button(toolbar,"新建事件",_new_clicked)
    _make_button(toolbar,"開啟事件",_open_clicked)
    _make_button(toolbar,"儲存 JSON",_save_clicked)
    _make_button(toolbar,"複製 JSON",_copy_clicked)
    _make_button(toolbar,"預覽目前頁",_preview_clicked)
    _make_button(toolbar,"試玩劇情測試場",_sandbox_clicked)
    _make_button(toolbar,"復原",_undo)
    _make_button(toolbar,"重做",_redo)
    _make_button(toolbar,"檢查所有頁",_validate_clicked)
    _status = _make_label(toolbar,"")
    _status.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var split := HSplitContainer.new()
    split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    split.size_flags_vertical = Control.SIZE_EXPAND_FILL
    add_child(split)

    var left_scroll := ScrollContainer.new()
    left_scroll.custom_minimum_size = Vector2(300,290)
    left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    split.add_child(left_scroll)
    var left := VBoxContainer.new()
    left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left_scroll.add_child(left)
    _metadata = VBoxContainer.new()
    left.add_child(_metadata)
    var pages_header := HBoxContainer.new()
    left.add_child(pages_header)
    _make_label(pages_header,"事件頁")
    _pages = OptionButton.new()
    _pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    pages_header.add_child(_pages)
    _pages.item_selected.connect(_page_selected)
    _make_button(pages_header,"＋",_add_page)
    _make_button(pages_header,"－",_remove_page)
    _page_fields = VBoxContainer.new()
    left.add_child(_page_fields)

    var right := VBoxContainer.new()
    right.custom_minimum_size = Vector2(460,290)
    right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right.size_flags_vertical = Control.SIZE_EXPAND_FILL
    split.add_child(right)
    _make_label(right,"事件指令（從上到下執行，選取後在下方修改）")
    _step_list = ItemList.new()
    _step_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _step_list.custom_minimum_size = Vector2(450,130)
    _step_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right.add_child(_step_list)
    _step_list.item_selected.connect(_step_selected)
    var commands_bar := HBoxContainer.new()
    right.add_child(commands_bar)
    _add_selector = OptionButton.new()
    _add_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    commands_bar.add_child(_add_selector)
    for op in COMPILER.OPS:
        _add_selector.add_item(str(COMPILER.LABELS.get(op,op)))
        _add_selector.set_item_metadata(_add_selector.item_count-1,op)
    _make_button(commands_bar,"新增指令",_add_step)
    _make_button(commands_bar,"↑",func() -> void: _move_step(-1))
    _make_button(commands_bar,"↓",func() -> void: _move_step(1))
    _make_button(commands_bar,"刪除",_remove_step)

    var inspector_scroll := ScrollContainer.new()
    inspector_scroll.custom_minimum_size = Vector2(460,140)
    inspector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    right.add_child(inspector_scroll)
    _inspector = Inspector.new()
    _inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _inspector.step_edited.connect(_step_edited)
    inspector_scroll.add_child(_inspector)

    _open_dialog = FileDialog.new()
    _open_dialog.access = FileDialog.ACCESS_RESOURCES
    _open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    _open_dialog.filters = PackedStringArray(["*.json ; FS Event Studio"])
    _open_dialog.current_dir = DATA.EVENTS_DIR
    _open_dialog.file_selected.connect(_open_file)
    add_child(_open_dialog)

    _discard_dialog = ConfirmationDialog.new()
    _discard_dialog.title = "尚未儲存"
    _discard_dialog.dialog_text = "目前事件尚未儲存，確定放棄修改嗎？"
    _discard_dialog.confirmed.connect(_discard_confirmed)
    add_child(_discard_dialog)
    _preview_dialog = PreviewWindow.new()
    add_child(_preview_dialog)

func _line(parent: Node, caption: String, value: String, cb: Callable) -> LineEdit:
    var row := HBoxContainer.new()
    parent.add_child(row)
    var label := _make_label(row,caption)
    label.custom_minimum_size.x = 95
    var field := LineEdit.new()
    field.text = value
    field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    field.text_changed.connect(cb)
    row.add_child(field)
    return field

func _number(parent: Node, caption: String, value: int, cb: Callable,
        minimum: int = 0, maximum: int = 999999) -> SpinBox:
    var row := HBoxContainer.new()
    parent.add_child(row)
    var label := _make_label(row,caption)
    label.custom_minimum_size.x = 95
    var field := SpinBox.new()
    field.min_value = minimum
    field.max_value = maximum
    field.step = 1
    field.rounded = true
    field.value = value
    field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    field.value_changed.connect(cb)
    row.add_child(field)
    return field

func _choice(parent: Node, caption: String, options: Array, current: String, cb: Callable) -> OptionButton:
    var row := HBoxContainer.new()
    parent.add_child(row)
    var label := _make_label(row,caption)
    label.custom_minimum_size.x = 95
    var field := OptionButton.new()
    field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for option in options:
        field.add_item(str(option))
    var index: int = options.find(current)
    if index >= 0:
        field.select(index)
    field.item_selected.connect(cb)
    row.add_child(field)
    return field

func _set_document(event: Dictionary, path: String) -> void:
    _doc = event.duplicate(true)
    _path = path
    _page_index = 0
    _selected_step = -1
    _dirty = false
    _history = [_doc.duplicate(true)]
    _history_index = 0
    _saved_snapshot = JSON.stringify(_doc)
    _refresh_metadata()
    _refresh_pages()
    _refresh_steps()
    _show_status("已載入：" + (path if not path.is_empty() else "尚未儲存的新事件"))

func _refresh_metadata() -> void:
    _clear(_metadata)
    _make_label(_metadata,"事件基本資訊")
    _line(_metadata,"事件名稱",str(_doc.get("name","")),
        func(v: String) -> void: _doc["name"] = v; _changed())
    _number(_metadata,"地圖 ID",int(_doc.get("map_id",1)),
        func(v: float) -> void: _doc["map_id"] = int(v); _changed(),1,9999)
    _number(_metadata,"事件 ID",int(_doc.get("event_id",1)),
        func(v: float) -> void: _doc["event_id"] = int(v); _changed(),1,9999)
    _number(_metadata,"位置 X",int(_doc.get("x",0)),
        func(v: float) -> void: _doc["x"] = int(v); _changed(),0,9999)
    _number(_metadata,"位置 Y",int(_doc.get("y",0)),
        func(v: float) -> void: _doc["y"] = int(v); _changed(),0,9999)

func _refresh_pages() -> void:
    _pages.clear()
    var pages: Array = _doc.get("pages",[])
    for i in pages.size():
        _pages.add_item(str(pages[i].get("title","事件頁 %d" % (i+1))))
    if pages.is_empty():
        _page_index = -1
        _clear(_page_fields)
        return
    _page_index = clampi(_page_index,0,pages.size()-1)
    _pages.select(_page_index)
    _refresh_page_fields()

func _refresh_page_fields() -> void:
    _clear(_page_fields)
    var page: Dictionary = DATA.get_page(_doc,_page_index)
    if page.is_empty():
        return
    _line(_page_fields,"頁面名稱",str(page.get("title","")),
        func(v: String) -> void: page["title"] = v; _changed())
    _choice(_page_fields,"觸發方式",DATA.TRIGGERS,str(page.get("trigger","action")),
        func(i: int) -> void: page["trigger"] = DATA.TRIGGERS[i]; _changed())
    _choice(_page_fields,"事件優先級",DATA.PRIORITIES,str(page.get("priority","same")),
        func(i: int) -> void: page["priority"] = DATA.PRIORITIES[i]; _changed())
    var cond: Dictionary = page.get("condition",{})
    _number(_page_fields,"開關條件 1",int(cond.get("switch_id",0)),
        func(v: float) -> void: cond["switch_id"] = int(v); _changed())
    _number(_page_fields,"開關條件 2",int(cond.get("switch2_id",0)),
        func(v: float) -> void: cond["switch2_id"] = int(v); _changed())
    _number(_page_fields,"變數條件 ID",int(cond.get("variable_id",0)),
        func(v: float) -> void: cond["variable_id"] = int(v); _changed())
    _number(_page_fields,"變數最低值",int(cond.get("variable_min",0)),
        func(v: float) -> void: cond["variable_min"] = int(v); _changed(),-999999,999999)
    _choice(_page_fields,"獨立開關",["","A","B","C","D"],str(cond.get("self_switch","")),
        func(i: int) -> void: cond["self_switch"] = ["","A","B","C","D"][i]; _changed())

func _refresh_steps() -> void:
    _step_list.clear()
    var page: Dictionary = DATA.get_page(_doc,_page_index)
    var steps: Array = page.get("steps",[])
    var level: int = 0
    for i in steps.size():
        var step: Dictionary = steps[i]
        var op: String = str(step.get("op",""))
        if op in ["else","end_if","when_choice","when_cancel","end_choice",
                "when_win","when_escape","when_lose","end_battle"]:
            level = maxi(0,level-1)
        var label: String = "%02d  %s%s" % [i+1,"  ".repeat(level),COMPILER.describe(step)]
        _step_list.add_item(label)
        if op in ["if_switch","if_variable","choice","battle","else",
                "when_choice","when_cancel","when_win","when_escape","when_lose"]:
            level += 1
    if _selected_step >= 0 and _selected_step < steps.size():
        _step_list.select(_selected_step)
        _inspector.edit_step(steps[_selected_step])
    else:
        _selected_step = -1
        _inspector.edit_step({})

func _page_selected(index: int) -> void:
    _page_index = index
    _selected_step = -1
    _refresh_page_fields()
    _refresh_steps()

func _add_page() -> void:
    var pages: Array = _doc["pages"]
    pages.append(DATA.new_page("事件頁 %d" % (pages.size()+1)))
    _page_index = pages.size()-1
    _selected_step = -1
    _changed()
    _refresh_pages()
    _refresh_steps()

func _remove_page() -> void:
    var pages: Array = _doc["pages"]
    if pages.size() <= 1:
        _show_status("至少要保留一個事件頁")
        return
    pages.remove_at(_page_index)
    _page_index = maxi(0,_page_index-1)
    _selected_step = -1
    _changed()
    _refresh_pages()
    _refresh_steps()

func _step_selected(index: int) -> void:
    _selected_step = index
    var page: Dictionary = DATA.get_page(_doc,_page_index)
    _inspector.edit_step(page["steps"][index])

func _step_edited() -> void:
    # Do NOT rebuild the inspector while TextEdit / LineEdit is emitting text_changed:
    # destroying the active widget would break typing and focus.
    _changed()
    var steps: Array = DATA.get_page(_doc,_page_index).get("steps",[])
    if _selected_step >= 0 and _selected_step < steps.size():
        _step_list.set_item_text(_selected_step,
            "%02d  %s" % [_selected_step+1,COMPILER.describe(steps[_selected_step])])

func _add_step() -> void:
    if _add_selector.selected < 0:
        return
    var op: String = str(_add_selector.get_item_metadata(_add_selector.selected))
    var steps: Array = DATA.get_page(_doc,_page_index)["steps"]
    var index: int = _selected_step+1 if _selected_step >= 0 else steps.size()
    var group: Array = [COMPILER.default_step(op)]
    # New blocks are always initially well-formed. Insert other steps between markers.
    if op in ["if_switch","if_variable"]:
        group.append(COMPILER.default_step("end_if"))
    elif op == "choice":
        group.append(COMPILER.default_step("when_choice"))
        group.append({"op":"when_choice","index":1})
        group.append(COMPILER.default_step("end_choice"))
    elif op == "battle":
        group.append(COMPILER.default_step("when_win"))
        group.append(COMPILER.default_step("end_battle"))
    for i in group.size():
        steps.insert(index+i,group[i])
    _selected_step = index
    _changed()
    _refresh_steps()

func _remove_step() -> void:
    var steps: Array = DATA.get_page(_doc,_page_index).get("steps",[])
    if _selected_step < 0 or _selected_step >= steps.size():
        return
    steps.remove_at(_selected_step)
    _selected_step = mini(_selected_step,steps.size()-1)
    _changed()
    _refresh_steps()

func _move_step(offset: int) -> void:
    var steps: Array = DATA.get_page(_doc,_page_index).get("steps",[])
    var new_index: int = _selected_step + offset
    if _selected_step < 0 or new_index < 0 or new_index >= steps.size():
        return
    var moved: Dictionary = steps[_selected_step]
    steps[_selected_step] = steps[new_index]
    steps[new_index] = moved
    _selected_step = new_index
    _changed()
    _refresh_steps()

func _changed() -> void:
    if _history_index + 1 < _history.size():
        _history.resize(_history_index+1)
    _history.append(_doc.duplicate(true))
    if _history.size() > 100:
        _history.remove_at(0)
    _history_index = _history.size()-1
    _dirty = JSON.stringify(_doc) != _saved_snapshot
    _show_status("● 尚未儲存的修改" if _dirty else "目前無修改")

func _restore_history() -> void:
    _doc = _history[_history_index].duplicate(true)
    _page_index = clampi(_page_index,0,_doc.get("pages",[]).size()-1)
    _selected_step = -1
    _dirty = JSON.stringify(_doc) != _saved_snapshot
    _refresh_metadata()
    _refresh_pages()
    _refresh_steps()
    _show_status("● 尚未儲存的修改" if _dirty else "目前無修改")

func _undo() -> void:
    if _history_index > 0:
        _history_index -= 1
        _restore_history()

func _redo() -> void:
    if _history_index + 1 < _history.size():
        _history_index += 1
        _restore_history()

func _show_status(text: String) -> void:
    if _status != null:
        _status.text = text

func _validate_all() -> PackedStringArray:
    var errors: PackedStringArray = DATA.validate(_doc)
    if not errors.is_empty():
        return errors
    var pages: Array = _doc.get("pages",[])
    for i in pages.size():
        var compiled: Dictionary = COMPILER.compile_page(pages[i])
        for message in compiled.get("errors",[]):
            errors.append("第 %d 頁 %s" % [i+1,str(message)])
    return errors

func _validate_clicked() -> void:
    var errors: PackedStringArray = _validate_all()
    if errors.is_empty():
        _show_status("全部 %d 頁已通過 VX 指令結構驗證" % _doc.get("pages",[]).size())
    else:
        _show_status("不可儲存： " + errors[0])

func _preview_clicked() -> void:
    var page: Dictionary = DATA.get_page(_doc,_page_index)
    if page.is_empty():
        _show_status("目前沒有可預覽的事件頁")
        return
    var result: Dictionary = COMPILER.compile_page(page)
    if not bool(result.get("ok",false)):
        var errors: Array = result.get("errors",[])
        _show_status("無法預覽：" + str(errors[0] if not errors.is_empty() else "不合法的事件"))
        return
    var outcome: Dictionary = _preview_dialog.preview_page(_doc,_page_index)
    if not bool(outcome.get("ok",false)):
        _show_status("無法預覽：" + str(outcome.get("error","未知原因")))

func _sandbox_clicked() -> void:
    # Separate runnable demo; does NOT require private FS database imports.
    EditorInterface.play_custom_scene("res://scenes/story/FSStorySandbox.tscn")

func _copy_clicked() -> void:
    # Cloud-first alternative: copy serialized event to chat for direct GitHub commit.
    # Does not write a local file. Native Save above writes to the opened project's res://.
    var errors: PackedStringArray = _validate_all()
    if not errors.is_empty():
        _show_status("複製已阻擋：" + errors[0])
        return
    DisplayServer.clipboard_set(JSON.stringify(_doc,"\t",false))
    _show_status("事件 JSON 已複製，尚未存入 GitHub")

func _save_clicked() -> void:
    var errors: PackedStringArray = _validate_all()
    if not errors.is_empty():
        _show_status("儲存已阻擋：" + errors[0])
        return
    var target: String = DATA.path_for(_doc)
    if FileAccess.file_exists(target) and target != _path:
        _show_status("編號已存在：請先開啟該事件，避免覆寫其他檔案")
        return
    var saved: Dictionary = DATA.write_event(_doc,target)
    if not bool(saved.get("ok",false)):
        _show_status("儲存失敗：" + str(saved.get("error","")))
        return
    _path = str(saved["path"])
    _saved_snapshot = JSON.stringify(_doc)
    _dirty = false
    _show_status("儲存成功：" + _path)

func _new_clicked() -> void:
    if _dirty:
        _pending_action = "new"
        _discard_dialog.popup_centered()
    else:
        _set_document(DATA.new_event(),"")

func _open_clicked() -> void:
    if _dirty:
        _pending_action = "open"
        _discard_dialog.popup_centered()
    else:
        _open_dialog.popup_centered_ratio(0.7)

func _discard_confirmed() -> void:
    if _pending_action == "new":
        _set_document(DATA.new_event(),"")
    elif _pending_action == "open":
        _open_dialog.popup_centered_ratio(0.7)
    _pending_action = ""

func _open_file(path: String) -> void:
    var loaded: Dictionary = DATA.read_event(path)
    if loaded.is_empty():
        _show_status("開啟失敗：事件格式錯誤或不在允許的路徑")
        return
    _set_document(loaded,path)
