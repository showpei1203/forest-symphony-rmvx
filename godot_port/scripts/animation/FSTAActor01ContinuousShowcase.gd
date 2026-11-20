extends Node2D
class_name FSTAActor01ContinuousShowcase

# Isolated T-A: complete RUN cycles -> preserved A52 ATTACK (presentation only).
# No HP, MP, ATB, queue, or actual combat timing is modified.
signal phase_changed(next_phase: String)
signal run_loop_finished(number: int)
signal attack_started()
signal visual_contact(second: float, frame: int)
signal sequence_finished()
signal showcase_failed(reason: String)

const RIG = preload("res://scripts/animation/FSTAActorMotionRig.gd")
const SOURCE_SHA: Dictionary = {
    "run_body.png": "fab73bc51109ad0b896333899c82ff80a7f5340d0ee25e4d0f7e94f6fd9f0bfb",
    "run_weapon.png": "ff3be6c132da2d8ac285ef60db48be195549b155f22ea5ac490c86a85f120eb7",
    "run_fx.png": "ef58c9f85c4dd5bf843466dffb5c06114c7286fa4d11f19191367e468799e2a7",
    "attack_body.png": "a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f",
    "attack_weapon.png": "6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b",
    "attack_fx.png": "46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c"
}

@export var auto_load_private: bool = true
@export_range(1, 6) var run_loops_before_attack: int = 2
@export var auto_play: bool = true

var rig: FSTAActorMotionRig
var phase: String = "idle"
var completed_run_loops: int = 0
var contact_count: int = 0
var _run_elapsed: float = 0.0
var _run_limit: float = 0.0
var _ready_for_motion: bool = false

func _ready() -> void:
    rig = RIG.new()
    rig.name = "SourceLockedBodyWeaponFX"
    add_child(rig)
    rig.set_process(false) # Single clock authority: showcase explicitly drives rig.
    rig.contact_reached.connect(_relay_visual_contact)
    rig.motion_failed.connect(_on_rig_failed)
    if auto_load_private and not load_private_sources():
        return
    if auto_play and _ready_for_motion:
        start_sequence(run_loops_before_attack)

func _on_rig_failed(reason: String) -> void:
    showcase_failed.emit(reason)

func _relay_visual_contact(second: float, frame: int) -> void:
    contact_count += 1
    visual_contact.emit(second, frame)

func load_private_sources(folder: String = "res://assets/ta_actor01") -> bool:
    if not folder.begins_with("res://") or ".." in folder:
        showcase_failed.emit("Invalid private source folder")
        return false
    for filename in SOURCE_SHA:
        var path: String = folder.path_join(str(filename))
        if not FileAccess.file_exists(path):
            showcase_failed.emit("Missing private source " + str(filename))
            return false
        if FileAccess.get_sha256(path) != str(SOURCE_SHA[filename]):
            showcase_failed.emit("Private source SHA mismatch: " + str(filename))
            return false
    _ready_for_motion = rig.load_private_atlases(folder)
    return _ready_for_motion

func configure_for_synthetic_test(run_body: Texture2D, run_weapon: Texture2D,
        run_fx: Texture2D, attack_body: Texture2D, attack_weapon: Texture2D,
        attack_fx: Texture2D) -> bool:
    # For public native CI only. Never invoked as a production fallback.
    _ready_for_motion = rig.configure_atlases(run_body, run_weapon, run_fx,
        attack_body, attack_weapon, attack_fx)
    return _ready_for_motion

func start_sequence(run_loop_count: int = 2) -> bool:
    if not _ready_for_motion or run_loop_count < 1 or run_loop_count > 6:
        showcase_failed.emit("Sources not loaded or invalid run loop count")
        return false
    _run_limit = FSTAActorMotionRig.RUN_FRAME_SEC * float(FSTAActorMotionRig.FRAME_COUNT) * float(run_loop_count)
    _run_elapsed = 0.0
    completed_run_loops = 0
    contact_count = 0
    if not rig.start_motion("run"):
        return false
    phase = "run"
    phase_changed.emit(phase)
    return true

func cancel_sequence() -> void:
    rig.cancel()
    phase = "cancelled"
    phase_changed.emit(phase)

func _process(delta: float) -> void:
    advance_seconds(delta)

func advance_seconds(delta: float) -> void:
    if delta <= 0.0 or phase not in ["run", "attack"]:
        return
    var remaining: float = delta
    var safety: int = 0
    while remaining > 0.0000001 and safety < 4:
        safety += 1
        if phase == "run":
            var step: float = minf(remaining, maxf(0.0, _run_limit - _run_elapsed))
            rig.advance_seconds(step)
            _run_elapsed += step
            remaining -= step
            var loop_sec: float = FSTAActorMotionRig.RUN_FRAME_SEC * float(FSTAActorMotionRig.FRAME_COUNT)
            var loop_count: int = mini(int(floor((_run_elapsed + 0.000001) / loop_sec)),
                int(round(_run_limit / loop_sec)))
            while completed_run_loops < loop_count:
                completed_run_loops += 1
                run_loop_finished.emit(completed_run_loops)
            if _run_elapsed + 0.000001 >= _run_limit:
                if not rig.start_motion("attack"):
                    cancel_sequence()
                    return
                phase = "attack"
                phase_changed.emit(phase)
                attack_started.emit()
        elif phase == "attack":
            var attack_step: float = minf(remaining,
                maxf(0.0, FSTAActorMotionRig.ATTACK_END_SEC - rig.elapsed_sec))
            rig.advance_seconds(attack_step)
            remaining -= attack_step
            if not rig.playing:
                phase = "complete"
                phase_changed.emit(phase)
                sequence_finished.emit()
        else:
            break
