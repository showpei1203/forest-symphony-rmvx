extends Node2D
## Standalone battle animation gallery. Key 1: raw, 2: tuned; Space pause; +/- speed.

@onready var actor: FSBattleActorAnimator = $Actor01
var hud: Label
var caption: Label
var paused := false

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    hud = Label.new()
    hud.position = Vector2(25.0, 20.0)
    add_child(hud)
    caption = Label.new()
    caption.position = Vector2(25.0, 48.0)
    add_child(caption)
    caption.text = "1: RAW  |  2: TUNED  |  SPACE: pause  |  +/-: speed"
    hud.add_theme_color_override("font_color", Color(0.94, 0.94, 0.85))
    caption.add_theme_color_override("font_color", Color(0.72, 0.81, 0.77))
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1024, 720), Color(0.075, 0.11, 0.145))
    draw_rect(Rect2(0, 445, 1024, 275), Color(0.11, 0.16, 0.17))
    draw_line(Vector2(0, 445), Vector2(1024, 445), Color(0.24, 0.34, 0.3), 3.0)
    draw_circle(Vector2(512, 478), 92.0, Color(0.05, 0.08, 0.09, 0.85), false)
    draw_arc(Vector2(512, 478), 92.0, 0.0, TAU, 64, Color(0.22, 0.32, 0.28), 2.0, false)

func _process(_delta: float) -> void:
    if hud != null:
        hud.text = "FS / GODOT A37      ACTOR01 / RUN   %s  |  F%d / 8   |  speed %.2fx   |  ART HOLD" % [str(actor.get_profile()), actor.get_frame_index(), actor.playback_multiplier]

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_1: actor.set_profile(&"run_raw")
            KEY_2: actor.set_profile(&"run_tuned")
            KEY_SPACE:
                paused = not paused
                actor.actor_sprite.pause() if paused else actor.actor_sprite.play()
            KEY_EQUAL, KEY_KP_ADD: actor.set_playback_multiplier(actor.playback_multiplier + 0.1)
            KEY_MINUS, KEY_KP_SUBTRACT: actor.set_playback_multiplier(actor.playback_multiplier - 0.1)
