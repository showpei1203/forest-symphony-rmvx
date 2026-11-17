extends SceneTree
## Real Godot 4.7.2 native body-only playback (requires private A53 image)
## All gameplay damage is external; assertions only count contact requests.
var failures: Array[String] = []
var hits: int = 0
var finishes: int = 0

func check(ok: bool, description: String) -> void:
    if ok:
        print("A57_NATIVE_PASS ", description)
    else:
        failures.append(description)
        push_error("A57_NATIVE_FAIL " + description)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://scenes/A57BodyOnlyDemo.tscn")
    check(scene != null, "body-scene-load")
    if scene == null:
        quit(1)
        return
    var actor: Node2D = scene.instantiate()
    root.add_child(actor)
    await process_frame
    actor.cancel()
    actor.contact_requested.connect(func(_id): hits += 1)
    actor.animation_finished.connect(func(_id): finishes += 1)
    check(actor.get_error() == "", "anchor-and-action-catalog-import")
    check(actor.body.texture.get_size() == Vector2(256,192), "A53-layout-256x192")
    check(not actor.weapon.visible and actor.weapon.texture == null, "weapon-not-in-body-scene")
    check(not actor.shield.visible and actor.shield.texture == null, "shield-not-in-body-scene")
    check(actor.start_action("close_ranged_attack"), "play-A53-body-attack")
    actor.tick(0.54)
    check(hits == 0 and actor.current_frame() == 6, "pre-contact-no-hit-frame-6")
    actor.tick(0.09)
    check(hits == 1 and actor.current_frame() == 7, "F7-t063-one-contact")
    check(actor.right_hand.position.distance_to(Vector2(15.0,13.0)) < 0.02, "F7-wrist-follows-anchor")
    actor.tick(0.02)
    check(actor.current_frame() == 7, "70ms-hitstop-holds-contact-frame")
    actor.tick(0.07)
    actor.tick(1.0)
    check(hits == 1 and finishes == 1 and not actor.is_active(), "once-only-contact-and-finish")
    check(actor.start_action("close_ranged_attack"), "restart")
    actor.tick(0.20)
    actor.cancel()
    actor.tick(5.0)
    check(hits == 1 and not actor.is_active(), "cancel-prevents-second-contact")
    actor.playback_speed = 2.0
    check(actor.start_action("close_ranged_attack"), "play-double-speed")
    actor.tick(0.315)
    check(hits == 2 and actor.current_frame() == 7, "double-speed-lands-contact-once")
    actor.tick(0.07)
    actor.tick(0.30)
    check(hits == 2, "double-speed-no-duplicate-contact")
    actor.cancel()
    check(not actor.start_action("damage"), "uncreated-action-rejected")
    actor.preview_mode = false
    check(not actor.start_action("close_ranged_attack") and "Art HOLD" in actor.get_error(), "ART-HOLD-production-rejected")
    actor.preview_mode = true
    actor.playback_speed = 1.0
    check(actor.start_action("waiting"), "real-source-derived-waiting-3pose-start")
    check(actor.body.hframes == 3 and actor.body.vframes == 1, "waiting-has-3-stored-body-frames")
    actor.tick(0.175)
    check(actor.current_frame() == 1, "waiting-shift-right-1px-phase")
    actor.tick(0.175)
    check(actor.current_frame() == 2, "waiting-shift-right-2px-phase")
    actor.tick(0.175)
    check(actor.current_frame() == 1, "waiting-intermediate-return")
    actor.tick(0.175)
    check(actor.current_frame() == 0, "waiting-loop-closes-to-F0")
    check(hits == 2, "waiting-must-not-emit-attack-contact")
    actor.cancel()
    print("A57_NATIVE_RESULT ", "PASS" if failures.is_empty() else "FAIL")
    quit(0 if failures.is_empty() else 1)
