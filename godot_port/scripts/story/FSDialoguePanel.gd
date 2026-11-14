@tool
extends Control
class_name FSDialoguePanel

# Playable story UI for original VX 101/401 text and 102 choices.
# An intentionally neutral visual scaffold. NOT a pixel-accurate FS Window_Message.
signal message_displayed(text: String)
signal choices_displayed(choices: Array)
signal dialogue_closed()

var runner: FSVXEventInterpreter
var panel: PanelContainer
var message: Label
var continue_button: Button
var choice_list: VBoxContainer
var cancel_button: Button
var _mode: String = ""
var _choices: Array = []
var _cancel_type: int = 0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _create_controls()
    hide()

func bind(event_runner: FSVXEventInterpreter) -> void:
    unbind()
    runner = event_runner
    runner.message_requested.connect(_on_message)
    runner.choices_requested.connect(_on_choices)
    runner.completed.connect(_on_event_end)
    runner.aborted.connect(_on_event_aborted)

func unbind() -> void:
    if runner == null:
        return
    if runner.message_requested.is_connected(_on_message):
        runner.message_requested.disconnect(_on_message)
    if runner.choices_requested.is_connected(_on_choices):
        runner.choices_requested.disconnect(_on_choices)
    if runner.completed.is_connected(_on_event_end):
        runner.completed.disconnect(_on_event_end)
    if runner.aborted.is_connected(_on_event_aborted):
        runner.aborted.disconnect(_on_event_aborted)
    runner = null

func _create_controls() -> void:
    panel = PanelContainer.new()
    panel.name = "DialogueWindow"
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    panel.anchor_left = 0.05
    panel.anchor_right = 0.95
    panel.anchor_top = 1.0
    panel.anchor_bottom = 1.0
    panel.offset_left = 0
    panel.offset_right = 0
    panel.offset_top = -142
    panel.offset_bottom = -8
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.035,0.08,0.16,0.95)
    style.border_color = Color(0.68,0.75,0.84)
    style.set_border_width_all(2)
    style.set_corner_radius_all(4)
    style.set_content_margin_all(10)
    panel.add_theme_stylebox_override("panel",style)
    add_child(panel)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation",4)
    panel.add_child(column)
    message = Label.new()
    message.name = "DialogueText"
    message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message.size_flags_vertical = Control.SIZE_EXPAND_FILL
    message.add_theme_color_override("font_color",Color(0.98,0.98,0.94))
    column.add_child(message)
    choice_list = VBoxContainer.new()
    choice_list.name = "Choices"
    choice_list.add_theme_constant_override("separation",4)
    column.add_child(choice_list)

    continue_button = Button.new()
    continue_button.name = "Continue"
    continue_button.text = "繼續  ▶"
    continue_button.size_flags_horizontal = Control.SIZE_SHRINK_END
    continue_button.pressed.connect(advance_message)
    column.add_child(continue_button)
    cancel_button = Button.new()
    cancel_button.name = "CancelChoice"
    cancel_button.text = "取消"
    cancel_button.pressed.connect(cancel_choice)
    cancel_button.hide()
    column.add_child(cancel_button)

func _place_panel(position: int, background: int) -> void:
    # VX: position 0 top, 1 center, 2 bottom, canvas = 544x416 logical pixels.
    panel.anchor_top = 0.0 if position == 0 else (0.5 if position == 1 else 1.0)
    panel.anchor_bottom = panel.anchor_top
    panel.offset_top = 8 if position == 0 else (-71 if position == 1 else -142)
    panel.offset_bottom = panel.offset_top + 134
    # Transparent window is allowed; keep a readable shadow unless FS art imported.
    if background == 2:
        panel.modulate.a = 0.82
    else:
        panel.modulate.a = 1.0

func _on_message(lines: Array, face: String, face_index: int, background: int, position: int) -> void:
    if runner == null:
        return
    _mode = "message"
    _choices.clear()
    _place_panel(position,background)
    for child in choice_list.get_children():
        choice_list.remove_child(child)
        child.queue_free()
    var text_lines := PackedStringArray()
    for line in lines:
        text_lines.append(str(line))
    # Keep source face identity visible until private source face graphics are imported.
    var face_note: String = ("[%s #%d]\n" % [face,face_index]) if not face.is_empty() else ""
    message.text = face_note + "\n".join(text_lines)
    continue_button.show()
    cancel_button.hide()
    show()
    message_displayed.emit(message.text)

func _on_choices(choices: Array, cancel_type: int) -> void:
    if runner == null:
        return
    _mode = "choice"
    _choices = choices.duplicate(true)
    _cancel_type = cancel_type
    _place_panel(2,0)
    # Expand for the longest VX list (four options plus optional cancel).
    # 544x416 viewport leaves enough room while avoiding overflowing the panel.
    var panel_height: int = 76 + choices.size()*34 + (36 if cancel_type > 0 else 0)
    panel.offset_top = -panel_height - 8
    panel.offset_bottom = -8
    message.text = "請選擇："
    for child in choice_list.get_children():
        choice_list.remove_child(child)
        child.queue_free()
    for index in choices.size():
        var option := Button.new()
        option.name = "Choice_%d" % index
        option.text = "%d. %s" % [index+1,str(choices[index])]
        option.pressed.connect(_choose.bind(index))
        choice_list.add_child(option)

    continue_button.hide()
    if _cancel_type > 0:
        cancel_button.show()
    else:
        cancel_button.hide()
    show()
    # Assign focus immediately once the choice controls are visible and inside
    # the SceneTree; deferred focus could target controls already queue_freed.
    if choice_list.get_child_count() > 0:
        var first: Control = choice_list.get_child(0) as Control
        if first != null and first.is_inside_tree():
            first.grab_focus()
    choices_displayed.emit(_choices)

func advance_message() -> void:
    if _mode != "message" or runner == null:
        return
    _mode = ""
    hide()
    runner.acknowledge_message()

func _choose(index: int) -> void:
    if _mode != "choice" or runner == null:
        return
    _mode = ""
    hide()
    runner.resolve_choice(index)

func cancel_choice() -> void:
    if _mode != "choice" or _cancel_type == 0 or runner == null:
        return
    _mode = ""
    hide()
    runner.resolve_choice(-1)

func _unhandled_key_input(event: InputEvent) -> void:
    if not visible or not event.pressed or event.echo:
        return
    if event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE] and _mode == "message":
        get_viewport().set_input_as_handled()
        advance_message()
    elif event.keycode == KEY_ESCAPE and _mode == "choice" and _cancel_type > 0:
        get_viewport().set_input_as_handled()
        cancel_choice()

func _on_event_end() -> void:
    _mode = ""
    hide()
    dialogue_closed.emit()

func _on_event_aborted(_reason: String) -> void:
    _on_event_end()
