extends Node2D
## Visual review only. Original V4 (left) vs shared 32-color candidate (right).
## No main FS integration or battle damage changes. Godot 4.7.2.
var controller: Node2D
var palette: Node2D
var msg: Label
var events: Array[String] = []
func _ready() -> void:
    get_window().size = Vector2i(960,560)
    var b := ColorRect.new()
    b.color = Color(0.12,0.15,0.19)
    b.size = Vector2(960,560)
    add_child(b)
    controller = preload("res://tb_attack_timeline.gd").new()
    controller.position = Vector2(260,248)
    controller.scale = Vector2(3.6,3.6)
    add_child(controller)
    palette = preload("res://tb_attack_timeline.gd").new()
    palette.texture_path = "res://assets/monsters/tb/ATTACK_V4_SHARED_PALETTE_32.png"
    palette.position = Vector2(710,248)
    palette.scale = Vector2(3.6,3.6)
    add_child(palette)
    controller.rush_started.connect(func(i: int): events.append("RUSH %d" % i))
    controller.hit_requested.connect(func(i: int, loc: Vector2): events.append("HIT %d @ %s" % [i,loc]))
    controller.return_started.connect(func(i: int): events.append("RETURN %d" % i))
    controller.attack_completed.connect(func(): events.append("DONE"))
    msg = Label.new()
    msg.position = Vector2(30,27)
    msg.add_theme_font_size_override("font_size",18)
    add_child(msg)
func _process(_delta: float) -> void:
    msg.text = "T-B source V4 (left) vs 32-color palette (right) | BOTH ART HOLD\nSPACE Play / C Cancel / R Replay | F%d / %.2f ticks\nEvents: %s" % [controller.frame_index,controller.timeline_ticks,", ".join(events)]
func _input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_SPACE:
        events.clear()
        controller.play_attack()
        palette.play_attack()
    elif event.keycode == KEY_C:
        controller.cancel_attack()
        palette.cancel_attack()
        events.append("CANCEL")
    elif event.keycode == KEY_R:
        controller.cancel_attack()
        palette.cancel_attack()
        events.clear()
        controller.play_attack()
        palette.play_attack()
