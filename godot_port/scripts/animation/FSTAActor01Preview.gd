extends Node2D
class_name FSTAActor01Preview

# Candidate-only playable preview, NOT the user's approved ART PASS.
# PRIVATE source images must be staged into res://assets/ta_actor01/ first.
# No source PNGs are distributed through public GitHub.
const RIG := preload("res://scripts/animation/FSTAActorMotionRig.gd")

var rig: Node2D
var _message: Label
var _private_assets_present: bool = false

func _ready() -> void:
    rig = RIG.new()
    rig.name = "Rig"
    rig.position = Vector2(272, 205)
    add_child(rig)
    _message = Label.new()
    _message.name = "Status"
    _message.position = Vector2(15, 12)
    _message.text = "ACTOR01 T-A | R=RUN  A=ATTACK  SPACE=Cancel"
    add_child(_message)
    rig.motion_failed.connect(_report_missing)
    rig.motion_started.connect(_report_motion)
    _private_assets_present = rig.load_private_atlases()
    if _private_assets_present:
        play_run()
    else:
        _message.text = "T-A ART HOLD: private PNG assets not staged; see Handoff"

func _report_missing(reason: String) -> void:
    if _message != null:
        _message.text = "T-A asset gate: " + reason

func _report_motion(motion_name: String) -> void:
    if _message != null:
        _message.text = "ACTOR01 " + motion_name.to_upper() + " | R=RUN  A=ATTACK  SPACE=Cancel"

func play_run() -> void:
    if _private_assets_present:
        rig.start_motion("run")

func play_attack() -> void:
    if _private_assets_present:
        rig.start_motion("attack")

func _unhandled_key_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    if event.keycode == KEY_R:
        play_run()
    elif event.keycode == KEY_A:
        play_attack()
    elif event.keycode == KEY_SPACE:
        rig.cancel()
