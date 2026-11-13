@tool
extends VBoxContainer

signal step_edited()

# FS Event Studio command inspector. Typed widgets, never raw JSON editing.
const FIELDS: Dictionary = {
    "dialogue": [
        ["text","對話文字","multi"], ["face","臉圖名稱","string"],
        ["face_index","臉圖序號 0-7","int"],
        ["background","訊息背景","background"], ["position","訊息位置","position"]],
    "comment":[["text","註解","multi"]],
    "choice":[["options","選項（一行一個，最多四個）","lines"],["cancel_type","取消行為","cancel"]],
    "when_choice":[["index","選項序號（從 0 起）","int"]],
    "if_switch":[["id","開關 ID","int"],["enabled","必須為 ON","bool"]],
    "switch":[["id","開關 ID","int"],["enabled","設定 ON","bool"]],
    "if_variable":[["id","變數 ID","int"],["compare","比較方式","compare"],["value","比較數值","int"]],
    "variable":[["id","變數 ID","int"],["operation","計算方式","operation"],
        ["source","來源","source"],["value","常數／來源變數 ID／亂數最小值","int"],
        ["random_to","亂數最大值","int"]],
    "self_switch":[["letter","獨立開關 A/B/C/D","string"],["enabled","設定 ON","bool"]],
    "item":[["id","物品 ID","int"],["amount","數量（負數代表失去）","int"]],
    "gold":[["amount","金錢變化（可為負數）","int"]],
    "party_add":[["id","角色 ID","int"]],
    "party_remove":[["id","角色 ID","int"]],
    "wait":[["frames","等待幀數（VX 單位）","int"]],
    "transfer":[["map_id","目的地 Map ID","int"],["x","座標 X","int"],
        ["y","座標 Y","int"],["direction","面朝方向","direction"]],
    "battle":[["troop_id","Troop ID","int"],["escape","允許逃跑","bool"],["lose","允許失敗","bool"]]
}
const ENUM_OPTIONS: Dictionary = {
    "background":[["一般",0],["暗色",1],["透明",2]],
    "position":[["上",0],["中",1],["下",2]],
    "operation":[["指定 =",0],["加 +",1],["減 -",2],["乘 ×",3],["除 ÷",4],["餘數 %",5]],
    "source":[["常數",0],["變數",1],["亂數",2]],
    "compare":[["=",0],[">=",1],["<=",2],[">",3],["<",4],["≠",5]],
    "direction":[["向下",2],["向左",4],["向右",6],["向上",8]],
    "cancel":[["禁止取消",0],["取消時選 1",1],["取消時選 2",2],["取消時選 3",3],
        ["取消時選 4",4],["使用獨立取消分支",5]]
}

var _step: Dictionary = {}

func edit_step(step: Dictionary) -> void:
    _step = step
    for control in get_children():
        remove_child(control)
        control.queue_free()
    if _step.is_empty():
        var hint := Label.new()
        hint.text = "選擇上方指令後，這裡會出現可編輯欄位。"
        add_child(hint)
        return
    var heading := Label.new()
    heading.text = "指令屬性：" + str(_step.get("op",""))
    add_child(heading)
    for field in FIELDS.get(str(_step.get("op","")),[]):
        _add_field(str(field[0]),str(field[1]),str(field[2]))

func _add_field(key: String, title: String, typ: String) -> void:
    var label := Label.new()
    label.text = title
    add_child(label)
    match typ:
        "multi", "lines":
            var widget := TextEdit.new()
            widget.custom_minimum_size = Vector2(280,72)
            widget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            if typ == "lines":
                widget.text = "\n".join(PackedStringArray(_step.get(key,[])))
                widget.text_changed.connect(func() -> void:
                    var entries: Array = []
                    for item in widget.text.split("\n",false):
                        entries.append(item.strip_edges())
                    _step[key] = entries
                    step_edited.emit())
            else:
                widget.text = str(_step.get(key,""))
                widget.text_changed.connect(func() -> void:
                    _step[key] = widget.text
                    step_edited.emit())
            add_child(widget)
        "string":
            var widget := LineEdit.new()
            widget.text = str(_step.get(key,""))
            widget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            widget.text_changed.connect(func(value: String) -> void:
                _step[key] = value
                step_edited.emit())
            add_child(widget)
        "int":
            var widget := SpinBox.new()
            widget.min_value = -99999999
            widget.max_value = 99999999
            widget.step = 1
            widget.rounded = true
            widget.value = int(_step.get(key,0))
            widget.value_changed.connect(func(value: float) -> void:
                _step[key] = int(value)
                step_edited.emit())
            add_child(widget)
        "bool":
            var widget := CheckBox.new()
            widget.button_pressed = bool(_step.get(key,false))
            widget.text = "啟用"
            widget.toggled.connect(func(value: bool) -> void:
                _step[key] = value
                step_edited.emit())
            add_child(widget)
        _:
            var widget := OptionButton.new()
            var options: Array = ENUM_OPTIONS.get(typ,[])
            for item in options:
                widget.add_item(str(item[0]),int(item[1]))
            var current_value: int = int(_step.get(key,0))
            for i in widget.item_count:
                if widget.get_item_id(i) == current_value:
                    widget.select(i)
                    break
            widget.item_selected.connect(func(index: int) -> void:
                _step[key] = widget.get_item_id(index)
                step_edited.emit())
            add_child(widget)
