extends Node
class_name FSVXEventInterpreter

# Source-first RPG Maker VX event commands. No eval(), no automatic Ruby execution.
# A command not explicitly handled is BLOCKED, never silently discarded.
# The UI/game layer must handle the emitted signals and call the continuation API.
signal message_requested(lines: Array, face: String, face_index: int, background: int, position: int)
signal choices_requested(choices: Array, cancel_type: int)
signal transfer_requested(map_id: int, x: int, y: int, direction: int)
signal battle_requested(troop_id: int, can_escape: bool, can_lose: bool)
signal unsupported_command(code: int, parameters: Array, event_index: int)
signal completed()
signal aborted(reason: String)

const MAX_COMMANDS_PER_EVENT: int = 100000
const STEPS_PER_FRAME: int = 256

var world: FSGameState
var commands: Array = []
var cursor: int = 0
var active: bool = false
var waiting: bool = false
var waiting_kind: String = ""
var wait_frames: int = 0
var source_map_id: int = 0
var source_event_id: int = 0
var rng := RandomNumberGenerator.new()
var common_event_lookup: Callable
var _choice_branch: Dictionary = {}
var _battle_branch: Dictionary = {}
var _executed: int = 0

func setup(state: FSGameState, common_lookup: Callable = Callable()) -> void:
    world = state
    common_event_lookup = common_lookup
    set_process(false)

func start_event(list: Array, map_id: int, event_id: int) -> void:
    if world == null:
        aborted.emit("缺少 FSGameState")
        return
    commands = list
    cursor = 0
    active = true
    waiting = false
    waiting_kind = ""
    wait_frames = 0
    source_map_id = map_id
    source_event_id = event_id
    _choice_branch.clear()
    _battle_branch.clear()
    _executed = 0
    set_process(true)
    _pump()

func _process(_delta: float) -> void:
    if not active:
        return
    if wait_frames > 0:
        wait_frames -= 1
        if wait_frames <= 0:
            waiting = false
            waiting_kind = ""
        return
    if not waiting:
        _pump()

func acknowledge_message() -> void:
    if active and waiting_kind == "message":
        waiting = false
        waiting_kind = ""
        _pump()

func acknowledge_transfer() -> void:
    # Host invokes only after loading destination and updating FSGameState position.
    if active and waiting_kind == "transfer":
        waiting = false
        waiting_kind = ""
        _pump()

func resolve_choice(index: int) -> void:
    if not active or waiting_kind != "choice":
        return
    if cursor <= 0 or int(commands[cursor-1].get("code", -1)) != 102:
        # Choice 102 may follow message 101; the waiting command is always 102.
        return
    var command: Dictionary = commands[cursor-1]
    var params: Array = command.get("parameters", [])
    var count: int = int((params[0] as Array).size())
    var cancel_type: int = int(params[1])
    if index < 0:
        if cancel_type < 0:
            return
        index = 4 # VX's cancel branch uses 4, independent of option count.
    if index >= count and index != 4:
        return
    _choice_branch[int(command.get("indent", 0))] = index
    waiting = false
    waiting_kind = ""
    _pump()

func resolve_battle(result: int) -> void:
    # VX: 0 victory / 1 escape / 2 defeat.
    if not active or waiting_kind != "battle" or result < 0 or result > 2:
        return
    _battle_branch[int(commands[cursor-1].get("indent", 0))] = result
    waiting = false
    waiting_kind = ""
    _pump()

func _stop_failure(message: String) -> void:
    active = false
    waiting = false
    waiting_kind = ""
    set_process(false)
    aborted.emit(message)

func _stop_success() -> void:
    active = false
    waiting = false
    waiting_kind = ""
    set_process(false)
    completed.emit()

func _block(code: int, params: Array, index: int) -> void:
    # Permanent fail-closed halt, NOT resumable via acknowledge_message().
    unsupported_command.emit(code, params, index)
    _stop_failure("不支援的 VX 指令 #%d（事件指令 %d），請先完成相容性轉譯" % [code,index])

func _seek(indent: int, codes: Array[int]) -> void:
    while cursor < commands.size():
        var candidate: Dictionary = commands[cursor]
        var nested: int = int(candidate.get("indent", 0))
        if nested < indent:
            return
        if nested == indent and int(candidate.get("code", -1)) in codes:
            return
        cursor += 1

func _skip_to_end(indent: int, code: int) -> void:
    _seek(indent, [code])
    if cursor < commands.size() and int(commands[cursor].get("code", -1)) == code:
        cursor += 1

func _pump() -> void:
    var budget: int = STEPS_PER_FRAME
    while active and not waiting and budget > 0:
        budget -= 1
        _executed += 1
        if _executed > MAX_COMMANDS_PER_EVENT:
            _stop_failure("事件超出執行指令上限，可能存在無窮迴圈")
            return
        if cursor >= commands.size():
            _stop_success()
            return
        var cmd: Dictionary = commands[cursor]
        var code: int = int(cmd.get("code", -1))
        var params: Array = cmd.get("parameters", [])
        var indent: int = int(cmd.get("indent", 0))
        var at_index: int = cursor
        cursor += 1
        match code:
            0:
                _stop_success()
            101: # Show Text
                var lines: Array = []
                while cursor < commands.size() and int(commands[cursor].get("code",-1)) == 401:
                    var continuation: Array = commands[cursor].get("parameters", [])
                    lines.append(str(continuation[0]) if not continuation.is_empty() else "")
                    cursor += 1
                waiting = true
                waiting_kind = "message"
                message_requested.emit(lines, str(params[0]), int(params[1]), int(params[2]), int(params[3]))
            102: # Show Choices
                waiting = true
                waiting_kind = "choice"
                choices_requested.emit(params[0], int(params[1]))
            402: # Choice branch
                if int(_choice_branch.get(indent, -99)) != int(params[0]):
                    _seek(indent, [402,403,404])
            403: # Cancel branch
                if int(_choice_branch.get(indent, -99)) != 4:
                    _seek(indent, [404])
            404:
                _choice_branch.erase(indent)
            111: # Conditional Branch
                var checked: Dictionary = _condition(params)
                if not bool(checked.get("supported",false)):
                    _block(code,params,at_index)
                elif not bool(checked.get("result",false)):
                    _seek(indent,[411,412])
                    if cursor < commands.size() and int(commands[cursor].get("code",-1)) == 411:
                        cursor += 1
            411: # Else; if then branch was true, skip else
                _skip_to_end(indent,412)
            412:
                pass
            121: # Control Switches
                for i in range(int(params[0]),int(params[1])+1):
                    world.set_switch(i,int(params[2]) == 0)
            122: # Control Variables (only source-correct operands 0..2 initially)
                if not _control_variables(params):
                    _block(code,params,at_index)
            123: # Control Self Switch
                world.set_self_switch(source_map_id,source_event_id,str(params[0]),int(params[1]) == 0)
            230: # Wait (VX units = frames)
                wait_frames = maxi(0,int(params[0]))
                waiting = wait_frames > 0
                waiting_kind = "wait" if waiting else ""
            118, 108, 408: # Labels/comments
                pass
            201: # Transfer player
                var indirect: bool = int(params[0]) != 0
                var m: int = world.variable(int(params[1])) if indirect else int(params[1])
                var x: int = world.variable(int(params[2])) if indirect else int(params[2])
                var y: int = world.variable(int(params[3])) if indirect else int(params[3])
                waiting = true
                waiting_kind = "transfer"
                transfer_requested.emit(m,x,y,int(params[4]))
            301: # Battle processing; linked to BATTLE UI
                var troop: int = world.variable(int(params[1])) if int(params[0]) != 0 else int(params[1])
                waiting = true
                waiting_kind = "battle"
                battle_requested.emit(troop,bool(params[2]),bool(params[3]))
            601,602,603: # Battle branch
                if int(_battle_branch.get(indent,-99)) != code-601:
                    _seek(indent,[601,602,603,604])
            604:
                _battle_branch.erase(indent)
            355,655: # Ruby script: no eval in Godot
                _block(code,params,at_index)
            _:
                _block(code,params,at_index)
        if not active:
            return

func _condition(params: Array) -> Dictionary:
    if params.size() < 3:
        return {"supported":false}
    match int(params[0]):
        0: # switch
            return {"supported":true,"result":world.switch_on(int(params[1])) == (int(params[2]) == 0)}
        1: # variable-vs-constant or variable-vs-variable
            if params.size() < 5:
                return {"supported":false}
            var value1: int = world.variable(int(params[1]))
            var value2: int = int(params[3]) if int(params[2]) == 0 else world.variable(int(params[3]))
            var result: bool = false
            match int(params[4]):
                0: result = value1 == value2
                1: result = value1 >= value2
                2: result = value1 <= value2
                3: result = value1 > value2
                4: result = value1 < value2
                5: result = value1 != value2
                _: return {"supported":false}
            return {"supported":true,"result":result}
        2: # independent switch
            return {"supported":true,"result":
                world.self_switch_on(source_map_id,source_event_id,str(params[1])) == (int(params[2]) == 0)}
        _:
            return {"supported":false}

func _control_variables(params: Array) -> bool:
    if params.size() < 5:
        return false
    var value: int = 0
    match int(params[3]):
        0: value = int(params[4])
        1: value = world.variable(int(params[4]))
        2:
            if params.size() < 6:
                return false
            value = rng.randi_range(int(params[4]),int(params[5]))
        _:
            return false # actor/item/map queries are separate authority adapters
    if int(params[2]) not in [0,1,2,3,4,5]:
        return false
    for i in range(int(params[0]),int(params[1])+1):
        var current: int = world.variable(i)
        var next_value: int = current
        match int(params[2]):
            0: next_value = value
            1: next_value += value
            2: next_value -= value
            3: next_value *= value
            4:
                if value != 0:
                    next_value = int(float(current) / float(value))
            5:
                if value != 0:
                    next_value = current % value
        world.set_variable(i,next_value)
    return true
