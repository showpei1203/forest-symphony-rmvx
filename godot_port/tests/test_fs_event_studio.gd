extends SceneTree

# All records are synthetic: no legacy private FS map, dialogue or graphics.
# GitHub Actions runs this on a disposable cloud runner.
const Data = preload("res://scripts/story/FSStoryData.gd")
const Compiler = preload("res://scripts/story/FSStoryCompiler.gd")
const State = preload("res://scripts/FSGameState.gd")
const Runtime = preload("res://scripts/story/FSStoryRuntime.gd")

func _initialize() -> void:
    call_deferred("_run")

func _assert(condition: bool, message: String) -> bool:
    if not condition:
        push_error("FS EVENT STUDIO TEST FAIL: " + message)
        quit(1)
        return false
    return true

func _run() -> void:
    var record: Dictionary = Data.new_event(997,991)
    record["name"] = "合成事件｜測試寶箱"
    var first: Dictionary = Data.get_page(record,0)
    first["steps"] = [
        Compiler.default_step("dialogue"),
        {"op":"switch","id":1,"enabled":true}
    ]
    var second: Dictionary = Data.new_page("開啟後")
    second["condition"]["switch_id"] = 1
    second["steps"] = [
        {"op":"if_switch","id":1,"enabled":true},
        {"op":"dialogue","text":"已開啟寶箱","face":"","face_index":0,"background":0,"position":2},
        {"op":"else"},
        {"op":"comment","text":"錯誤分支"},
        {"op":"end_if"},
        {"op":"item","id":5,"amount":2},
        {"op":"gold","amount":50},
        {"op":"self_switch","letter":"A","enabled":true},
        {"op":"choice","options":["接受","拒絕"],"cancel_type":0},
        {"op":"when_choice","index":0},
        {"op":"variable","id":7,"operation":0,"source":0,"value":35,"random_to":0},
        {"op":"when_choice","index":1},
        {"op":"variable","id":7,"operation":0,"source":0,"value":99,"random_to":0},
        {"op":"end_choice"}
    ]
    record["pages"].append(second)

    if not _assert(Data.validate(record).is_empty(),"document schema valid"): return
    var state = State.new()
    if not _assert(Data.selected_page(record,state)==0,"last valid page selection defaults page 0"): return
    state.set_switch(1,true)
    if not _assert(Data.selected_page(record,state)==1,"page priority honors switch"): return

    var compiled: Dictionary = Compiler.compile_page(second)
    if not _assert(bool(compiled.get("ok",false)),"compiler succeeds: " + str(compiled.get("errors",[]))): return
    var opcodes: Array = []
    for cmd in compiled["commands"]:
        opcodes.append(int(cmd["code"]))
    for code in [111,411,412,101,401,126,125,123,102,402,404,122]:
        if not _assert(code in opcodes, "compiled opcode %d present" % code): return

    var invalid: Dictionary = Data.new_page()
    invalid["steps"] = [{"op":"end_if"}]
    if not _assert(not Compiler.compile_page(invalid)["ok"],"unmatched branch rejected"): return
    invalid["steps"] = [{"op":"choice","options":["A","B"],"cancel_type":0},
        {"op":"when_choice","index":0},{"op":"end_choice"}]
    if not _assert(not Compiler.compile_page(invalid)["ok"],"missing choice branch rejected"): return

    var saved: Dictionary = Data.write_event(record)
    if not _assert(bool(saved.get("ok",false)),"JSON write to disposable cloud runner"): return
    var loaded: Dictionary = Data.read_event(str(saved["path"]))
    if not _assert(loaded["name"]==record["name"],"UTF-8 JSON round-trip"): return
    if not _assert(Data.selected_page(loaded,state)==1,"page conditions preserved after load"): return
    if not _assert(Compiler.compile_page(Data.get_page(loaded,1))["commands"].size()==compiled["commands"].size(),
            "compiled commands stable after JSON round-trip"): return

    var runtime = Runtime.new()
    root.add_child(runtime)
    var seen: Array = []
    var choices: Array = []
    var failed: Array = []
    runtime.runner.message_requested.connect(func(lines: Array,_face: String,_idx: int,_bg: int,_pos: int) -> void: seen.append(lines))
    runtime.runner.choices_requested.connect(func(v: Array,_cancel: int) -> void: choices.append(v))
    runtime.story_failed.connect(func(v: String) -> void: failed.append(v))
    var start: Dictionary = runtime.interact(loaded,state)
    if not _assert(bool(start.get("ok",false)),"event runtime starts"): return
    if not _assert(seen.size()==1,"dialogue sent to UI"): return
    runtime.runner.acknowledge_message()
    if not _assert(state.amount("item",5)==2,"reward inventory shared"): return
    if not _assert(state.gold==50,"reward money shared"): return
    if not _assert(state.self_switch_on(997,991,"A"),"self switch set"): return
    if not _assert(choices.size()==1,"choice emitted"): return
    runtime.runner.resolve_choice(0)
    if not _assert(state.variable(7)==35,"first branch selected"): return
    if not _assert(not runtime.runner.active and failed.is_empty(),"event finished without unsupported opcode"): return

    # Existing VX events can still run directly, no reauthoring required.
    var old: Array = [
        {"code":121,"indent":0,"parameters":[42,42,0]},
        {"code":0,"indent":0,"parameters":[]}
    ]
    runtime.interact_legacy_vx(old,state,997,123)
    if not _assert(state.switch_on(42),"legacy VX opcode compatibility retained"): return
    print("FS Event Studio schema/compiler/page precedence/JSON/runtime/legacy PASS")
    quit(0)
