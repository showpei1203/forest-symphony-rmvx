extends SceneTree

# Native integration: a Godot 2D marker triggers an authored 2-page treasure chest.
# Story/character data here is synthetic, committed only for demonstration.
const Marker = preload("res://scripts/story/FSStoryEventMarker.gd")
const State = preload("res://scripts/FSGameState.gd")
const Story = preload("res://scripts/story/FSStoryRuntime.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("FS STORY MAP MARKER FAIL: " + label)
        quit(1)
        return false
    return true

func _run() -> void:
    var marker = Marker.new()
    marker.event_file = "res://story/events/map_999_event_001.json"
    root.add_child(marker)
    var state = State.new()
    var story = Story.new()
    root.add_child(story)
    var dialogue: Array = []
    story.runner.message_requested.connect(func(lines: Array,_face: String,_idx: int,_bg: int,_pos: int) -> void:
        dialogue.append(lines))

    var result: Dictionary = marker.interact(state,story)
    if not _check(result.get("ok",false),"first interaction started"): return
    if not _check(result.get("page_index",-1) == 0,"unopened page selected"): return
    if not _check(dialogue.size()==1 and "打開" in str(dialogue[0][0]),"opening dialogue"): return
    story.runner.acknowledge_message()
    if not _check(state.amount("item",1)==1,"item reward obtained once"): return
    if not _check(state.self_switch_on(999,1,"A"),"self-switch A turned on"): return
    story.runner.acknowledge_message()
    if not _check(not story.runner.active,"first event completed"): return

    result = marker.interact(state,story)
    if not _check(result.get("page_index",-1)==1,"last eligible page selected"): return
    if not _check(dialogue.size()==3 and "空" in str(dialogue[2][0]),"empty chest dialogue"): return
    story.runner.acknowledge_message()
    if not _check(state.amount("item",1)==1,"no duplicate reward"): return
    if not _check(not story.runner.active,"second interaction completed"): return
    print("FS map marker/2-page treasure chest/repeat item safety PASS")
    quit(0)
