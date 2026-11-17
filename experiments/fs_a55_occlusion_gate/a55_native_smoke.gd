extends SceneTree
## Native Godot 4.7.2 semantic occlusion smoke, no GPU/art acceptance claim.

var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
    if condition:
        print("A55_NATIVE_PASS " + message)
    else:
        failures.append(message)
        push_error("A55_NATIVE_FAIL " + message)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var controller_script: Script = load("res://fs_a55_occlusion_controller.gd")
    check(controller_script != null, "controller-script-load")
    if controller_script == null:
        quit(1)
        return
    var rig: Node2D = controller_script.new()
    rig.name = "A55Rig"
    rig.preview_mode = true
    rig.visibility_file = "res://a55_visibility_manifest_reference.json"
    rig.body_path = NodePath("Body")
    rig.shield_path = NodePath("Shield")
    rig.weapon_path = NodePath("Weapon")
    rig.weapon_tip_path = NodePath("WeaponTip")
    for name in ["Body", "Shield", "Weapon", "WeaponTip"]:
        var part := Sprite2D.new()
        part.name = name
        rig.add_child(part)
    root.add_child(rig)
    await process_frame

    check(rig.get_last_error() == "", "manifest-parse-and-frame-contract")
    for frame in [5, 6]:
        check(rig.apply_frame("NW", "attack", frame), "apply-NW-attack-F%d" % frame)
        var body: CanvasItem = rig.get_node("Body")
        var shield: CanvasItem = rig.get_node("Shield")
        var weapon: CanvasItem = rig.get_node("Weapon")
        var tip: CanvasItem = rig.get_node("WeaponTip")
        check(body.visible, "body-never-deleted-F%d" % frame)
        check(shield.visible and shield.z_index > body.z_index, "shield-in-front-of-body-F%d" % frame)
        check(not weapon.visible, "hidden-sword-hand-and-hilt-F%d" % frame)
        check(tip.visible and tip.z_index > shield.z_index, "blade-tip-over-shield-F%d" % frame)
    check(not rig.apply_frame("NW", "attack", 4), "missing-frame-fail-closed")
    check(not rig.apply_frame("SE", "attack", 5), "wrong-view-fail-closed")
    rig.preview_mode = false
    check(not rig.apply_frame("NW", "attack", 5), "non-approved-art-blocks-production")
    check(rig.get_last_error() != "", "production-rejection-explains-reason")
    print("A55_NATIVE_QA_RESULT " + ("PASS" if failures.is_empty() else "FAIL"))
    rig.queue_free()
    quit(0 if failures.is_empty() else 1)
