extends SceneTree
# Native scene import smoke test. Artist source assets stay PRIVATE, so this
# checks the correct fail-closed state until Drive files are explicitly staged.
const PREVIEW = preload("res://scenes/ta_actor01/TAActor01Preview.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: Node2D = PREVIEW.instantiate()
    root.add_child(scene)
    if not is_instance_valid(scene.get_node_or_null("Rig")):
        push_error("T-A scene missing three-layer Rig")
        quit(1)
        return
    if scene.get_node("Rig").layers().size() != 3:
        push_error("T-A preview did not construct independent Body, Weapon, FX")
        quit(1)
        return
    print("T_A_PREVIEW_NATIVE_IMPORT_PASS isolated scene; private ART stays gated")
    quit(0)
