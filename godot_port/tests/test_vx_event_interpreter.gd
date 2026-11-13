extends SceneTree

# Synthetic VX EventCommand records only; no private story data.
# Native test command (NOT YET EXECUTED):
# godot --headless --path godot_port --script res://tests/test_vx_event_interpreter.gd

const StateScript = preload("res://scripts/FSGameState.gd")
const EventScript = preload("res://scripts/FSVXEventInterpreter.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, description: String) -> void:
    if not ok:
        push_error("FAIL: " + description)
        quit(1)

func _cmd(code: int, indent: int, params: Array = []) -> Dictionary:
    return {"code":code,"indent":indent,"parameters":params}

func _run() -> void:
    var state = StateScript.new()
    var runner = EventScript.new()
    root.add_child(runner)
    runner.setup(state)
    var messages: Array = []
    var options: Array = []
    var ended: Array = []
    var blocked: Array = []
    runner.message_requested.connect(func(lines: Array,_face: String,_id: int,_bg: int,_pos: int) -> void: messages.append(lines))
    runner.choices_requested.connect(func(choices: Array,_cancel: int) -> void: options.append(choices))
    runner.completed.connect(func() -> void: ended.append(true))
    runner.unsupported_command.connect(func(code: int,_params: Array,_index: int) -> void: blocked.append(code))
    var source_event: Array = [
        _cmd(121,0,[2,2,0]), # switch 2 = ON
        _cmd(122,0,[5,5,0,0,7]), # var 5 = 7
        _cmd(111,0,[0,2,0]), # if switch 2 ON
        _cmd(101,1,["",0,0,2]),
        _cmd(401,1,["第一段測試對話"]),
        _cmd(411,0),
        _cmd(121,1,[3,3,0]), # else: must never run
        _cmd(412,0),
        _cmd(102,0,[["接受","拒絕"],4]),
        _cmd(402,0,[0,"接受"]),
        _cmd(122,1,[5,5,1,0,3]), # var5 += 3
        _cmd(402,0,[1,"拒絕"]),
        _cmd(122,1,[5,5,1,0,100]), # must never run
        _cmd(403,0),
        _cmd(404,0),
        _cmd(0,0)
    ]
    runner.start_event(source_event,1,2)
    _check(state.switch_on(2), "switch 2 ON")
    _check(not state.switch_on(3), "ELSE skipped")
    _check(state.variable(5) == 7, "initial variable")
    _check(messages.size() == 1 and messages[0].size() == 1, "message emitted")
    runner.acknowledge_message()
    _check(options.size() == 1, "choice emitted")
    runner.resolve_choice(0)
    _check(state.variable(5) == 10, "selected branch only")
    _check(ended.size() == 1, "event completed")
    _check(blocked.is_empty(), "no unsupported command")

    runner.start_event([_cmd(355,0,["do_not_eval"]),_cmd(121,0,[3,3,0]),_cmd(0,0)],1,2)
    _check(not state.switch_on(3), "unsupported Ruby must block further execution")
    _check(blocked.size() == 1 and blocked[0] == 355, "unsupported callback")
    print("FS event synthetic test assertions complete (not original story parity)")
    quit(0)
