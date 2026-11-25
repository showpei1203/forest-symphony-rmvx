extends Node2D
const Body = preload("res://MotionBody.gd")
const ACTIONS := ["attack","run","damage","dodge","cast"]
var body: Body
var status: Label
func _ready() -> void:
    var bg := ColorRect.new()
    bg.color = Color("29313a")
    bg.size = Vector2(640,480)
    add_child(bg)
    var line := Line2D.new()
    line.add_point(Vector2(70,350))
    line.add_point(Vector2(570,350))
    line.width = 1
    add_child(line)
    body = Body.new()
    body.position = Vector2(320,350)
    body.scale = Vector2(6,6)
    add_child(body)
    status = Label.new()
    status.position = Vector2(16,12)
    add_child(status)
    var available: Array[String] = []
    for action in ACTIONS:
        if FileAccess.file_exists("res://motions/"+action+"/motion.json") and body.load_motion(action): available.append(action)
    status.text = "1 ATTACK | 2 RUN | 3 DAMAGE | 4 DODGE | 5 CAST\nVerified assets: " + ", ".join(available) + "\nMissing actions are not substituted. Body only."
    if available.has("attack"): body.start_motion("attack")
func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var n: int = event.keycode - KEY_1
        if n >= 0 and n < ACTIONS.size(): body.start_motion(ACTIONS[n])
