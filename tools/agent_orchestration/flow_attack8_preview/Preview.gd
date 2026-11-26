extends Node2D
const Body = preload("res://FlowAttackBody.gd")
var actor: Body
var status: Label
func _ready() -> void:
    var bg := ColorRect.new()
    bg.color = Color("29313a")
    bg.size = Vector2(640, 480)
    add_child(bg)
    var line := Line2D.new()
    line.add_point(Vector2(90, 340))
    line.add_point(Vector2(550, 340))
    line.width = 1
    line.default_color = Color("77868e")
    add_child(line)
    actor = Body.new()
    actor.position = Vector2(320, 340)
    actor.scale = Vector2(6, 6)
    add_child(actor)
    status = Label.new()
    status.position = Vector2(20, 18)
    add_child(status)
    if not actor.load_candidate():
        status.text = "SOURCE HASH / FORMAT HOLD"
        return
    actor.frame_changed.connect(_refresh)
    actor.animation_finished.connect(_refresh)
    actor.replay()
    _refresh()
func _refresh() -> void:
    status.text = "Flow ATTACK8 | BODY ONLY | %d / 8\nSpace: replay | No weapon / FX / damage" % (actor.frame + 1)
func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
        if actor != null:
            actor.replay()
