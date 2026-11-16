extends SceneTree

# Godot native fail-closed test. CI must never mount a fake "official" map.
const GATE=preload("res://scripts/story/FSPrivateA35Gate.gd")

func _initialize()->void:
    call_deferred("_run")

func _run()->void:
    var gate:Dictionary=GATE.inspect()
    if bool(gate.get("ok",false)):
        push_error("FS P534 native CI accidentally authorized private art without private assets")
        quit(1)
        return
    if str(gate.get("reason","")).is_empty():
        push_error("FS P534 gate did not explain denial")
        quit(1)
        return
    print("FS P534 Godot A35 private map gate FAIL-CLOSED PASS: "+str(gate["reason"]))
    quit(0)
