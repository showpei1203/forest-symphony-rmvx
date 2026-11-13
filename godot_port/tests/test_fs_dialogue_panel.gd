extends SceneTree

# Godot 4.7.2 headless native controls and input lifecycle; no copyrighted source assets.
const Panel = preload("res://scripts/story/FSDialoguePanel.gd")
const Runner = preload("res://scripts/FSVXEventInterpreter.gd")
const State = preload("res://scripts/FSGameState.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error("FS dialogue native UI FAIL: " + message)
        quit(1)
        return false
    return true

func _cmd(code: int, indent: int, params: Array = []) -> Dictionary:
    return {"code":code,"indent":indent,"parameters":params}

func _run() -> void:
    var world = State.new()
    var runner = Runner.new()
    root.add_child(runner)
    runner.setup(world)
    var panel = Panel.new()
    root.add_child(panel)
    panel.bind(runner)
    var seen_text: Array = []
    var seen_options: Array = []
    panel.message_displayed.connect(func(message: String) -> void: seen_text.append(message))
    panel.choices_displayed.connect(func(choices: Array) -> void: seen_options.append(choices))
    runner.start_event([
        _cmd(101,0,["",0,0,2]),
        _cmd(401,0,["第一次對話測試"]),
        _cmd(102,0,[["拿寶物","離開"],5]),
        _cmd(402,0,[0,"拿寶物"]),
        _cmd(126,1,[2,0,0,1]),
        _cmd(402,0,[1,"離開"]),
        _cmd(121,1,[8,8,0]),
        _cmd(403,0),
        _cmd(121,1,[9,9,0]),
        _cmd(404,0),
        _cmd(0,0)
    ],7,6)

    if not _check(panel.visible and panel.message.visible,"message panel is visible"): return
    if not _check(panel._mode == "message" and seen_text.size()==1,"message actually displayed"): return
    if not _check("第一次對話" in panel.message.text,"dialogue text rendered in Label"): return
    panel.continue_button.pressed.emit()
    if not _check(panel._mode == "choice" and seen_options.size()==1,"choice panel visible"): return
    if not _check(panel.choice_list.get_child_count() == 2,"two clickable choices"): return
    if not _check(panel.cancel_button.visible,"cancel enabled from VX cancel_type"): return
    panel.cancel_button.pressed.emit()
    if not _check(world.switch_on(9) and not world.switch_on(8),"independent VX cancel branch selected"): return
    if not _check(world.amount("item",2)==0 and not runner.active,"no reward after cancel"): return

    runner.start_event([
        _cmd(101,0,["",0,0,2]),
        _cmd(401,0,["第二次對話測試"]),
        _cmd(102,0,[["接受","拒絕"],0]),
        _cmd(402,0,[0,"接受"]),
        _cmd(126,1,[2,0,0,1]),
        _cmd(402,0,[1,"拒絕"]),
        _cmd(121,1,[8,8,0]),
        _cmd(404,0),
        _cmd(0,0)
    ],7,6)
    panel.advance_message()
    if not _check(panel._mode == "choice" and not panel.cancel_button.visible,"cancel disabled"): return
    var accept: Button = panel.choice_list.get_child(0)
    accept.pressed.emit()
    if not _check(world.amount("item",2)==1 and not world.switch_on(8),"choice button grants right reward"): return
    if not _check(not panel.visible and not runner.active,"panel hidden on event end"): return
    print("FS dialogue native message/choices/cancel/accept UI PASS")
    quit(0)
