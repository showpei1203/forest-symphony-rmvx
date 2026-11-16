extends Node2D
## A38 standalone comparison: unchanged A35 RUN versus real/curated A38 IDLE.
## 1: idle raw R1, 2: idle calm selection, 3: idle R2, 4: run raw, 5: run tuned.

@onready var run_actor: FSBattleActorAnimator = $RunActor
@onready var idle_actor: FSBattleActorAnimator = $IdleActor
var hud: Label
var footer: Label
var paused: bool = false

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    hud = Label.new()
    hud.position = Vector2(27, 20)
    hud.add_theme_color_override("font_color", Color(0.95, 0.96, 0.91))
    add_child(hud)
    footer = Label.new()
    footer.position = Vector2(27, 50)
    footer.text = "1 Idle R1  |  2 Idle Calm  |  3 Idle R2  |  4 Run Raw  |  5 Run Tuned  | Space Pause  | +/- Speed"
    footer.add_theme_color_override("font_color", Color(0.74, 0.82, 0.78))
    add_child(footer)
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1024, 720), Color(0.08, 0.115, 0.15))
    draw_rect(Rect2(0, 479, 1024, 241), Color(0.12, 0.165, 0.17))
    draw_line(Vector2(0, 479), Vector2(1024, 479), Color(0.25, 0.36, 0.30), 3.0)
    for pos in [Vector2(326, 487), Vector2(698, 487)]:
        draw_arc(pos, 99.0, 0.0, TAU, 64, Color(0.30, 0.45, 0.38), 2.0)

func _process(_delta: float) -> void:
    if hud != null:
        hud.text = "FS / A38 GODOT    RUN: %s F%d/8    IDLE: %s F%d/8    BOTH ART HOLD" % [str(run_actor.get_profile()), run_actor.get_frame_index(), str(idle_actor.get_profile()), idle_actor.get_frame_index()]

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1: idle_actor.set_profile(&"idle_raw")
        KEY_2: idle_actor.set_profile(&"idle_calm")
        KEY_3: idle_actor.set_profile(&"idle_r2")
        KEY_4: run_actor.set_profile(&"run_raw")
        KEY_5: run_actor.set_profile(&"run_tuned")
        KEY_SPACE:
            paused = not paused
            if paused:
                run_actor.actor_sprite.pause()
                idle_actor.actor_sprite.pause()
            else:
                run_actor.actor_sprite.play()
                idle_actor.actor_sprite.play()
        KEY_EQUAL, KEY_KP_ADD:
            idle_actor.set_playback_multiplier(idle_actor.playback_multiplier + 0.1)
            run_actor.set_playback_multiplier(run_actor.playback_multiplier + 0.1)
        KEY_MINUS, KEY_KP_SUBTRACT:
            idle_actor.set_playback_multiplier(idle_actor.playback_multiplier - 0.1)
            run_actor.set_playback_multiplier(run_actor.playback_multiplier - 0.1)
