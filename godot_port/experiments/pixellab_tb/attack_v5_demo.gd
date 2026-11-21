extends Node2D
## Standalone private visual review scene only (Godot 4.7.2).
## Left V4 RBF candidate rejected; right V5 cutout articulation candidate still ART HOLD.
const ATTACK = preload("res://tb_attack_timeline.gd")
var before: Node2D
var after: Node2D
var text_bar: Label
var events: Array[String] = []

func _ready() -> void:
    get_window().size = Vector2i(1120, 580)
    var background := ColorRect.new()
    background.color = Color("20252a")
    background.size = Vector2(1120, 580)
    add_child(background)
    before = ATTACK.new()
    before.position = Vector2(280,280)
    before.scale = Vector2(4.0,4.0)
    add_child(before)
    after = ATTACK.new()
    after.texture_path = "res://assets/monsters/tb/PMD0001_ATTACK_V5_11F_384x288.png"
    after.position = Vector2(850,280)
    after.scale = Vector2(4.0,4.0)
    add_child(after)
    after.rush_started.connect(func(i: int): events.append("RUSH %d" % i))
    after.hit_requested.connect(func(i: int, _p: Vector2): events.append("HIT %d" % i))
    after.return_started.connect(func(i: int): events.append("RETURN %d" % i))
    after.attack_completed.connect(func(): events.append("DONE"))
    text_bar = Label.new()
    text_bar.position = Vector2(28,20)
    text_bar.add_theme_font_size_override("font_size",18)
    add_child(text_bar)
    var labels := Label.new()
    labels.position = Vector2(75,455)
    labels.text = "V4 RBF full-body warp | ART HOLD                                 V5 independent feet + jaw | ART HOLD"
    labels.add_theme_font_size_override("font_size",16)
    add_child(labels)

func _process(_delta: float) -> void:
    text_bar.text = "FOREST SYMPHONY / PMD0001 | SPACE ATTACK / C CANCEL / R REPLAY\nF%d  %.1f /28 ticks   %s" % [after.frame_index,after.timeline_ticks,", ".join(events)]

func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE or event.keycode == KEY_R:
        before.cancel_attack()
        after.cancel_attack()
        events.clear()
        before.play_attack()
        after.play_attack()
    elif event.keycode == KEY_C:
        before.cancel_attack()
        after.cancel_attack()
        events.append("CANCEL")
