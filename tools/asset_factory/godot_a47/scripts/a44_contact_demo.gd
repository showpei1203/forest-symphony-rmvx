extends Node2D
## A44 isolated real Godot battle contact: one-clock ATTACK -> moving sword tip
## -> Area2D practice target -> single damage + reaction. No FS ATB claims.
@onready var actor: FSBattleActorAnimator = $Actor
@onready var target: FSA44PracticeTarget = $Target
var last_contact_local: Vector2 = Vector2.ZERO
var last_contact_world: Vector2 = Vector2.ZERO
var last_contact_serial: int = -1
var successful_attacks: int = 0
var misses: int = 0
var _hud: Label
const TARGET_ORIGIN: Vector2 = Vector2(409,392)

func _ready() -> void:
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    actor.attack_contact_anchor.connect(_on_blade_contact)
    _hud=Label.new()
    _hud.position=Vector2(25,24)
    add_child(_hud)
    _hud.text="A44 | A strike / R reset | dynamic blade-tip collision"
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,800,620),Color(0.08,0.115,0.15))
    draw_rect(Rect2(0,445,800,175),Color(0.12,0.17,0.16))
    draw_line(Vector2(0,445),Vector2(800,445),Color(0.25,0.36,0.29),3)
    draw_arc(Vector2(300,430),100,0,TAU,36,Color(0.34,0.43,0.39),2)
    if last_contact_serial>=0:
        draw_circle(last_contact_world,3,Color(1,0.70,0.18))

func start_attack() -> bool:
    return actor.play_motion(&"attack",&"attack_weighted")

func reset_target() -> void:
    target.reset_health()
    target.position=TARGET_ORIGIN
    successful_attacks=0
    misses=0
    last_contact_serial=-1
    queue_redraw()

func _on_blade_contact(serial: int, local_anchor: Vector2, world_anchor: Vector2) -> void:
    last_contact_serial=serial
    last_contact_local=local_anchor
    last_contact_world=world_anchor
    if target.apply_blade_contact(serial,world_anchor,25):
        successful_attacks+=1
        print("A44_PRACTICE_HIT serial=%d hp=%d local=%s" % [serial,target.health,str(local_anchor)])
    else:
        misses+=1
        print("A44_PRACTICE_MISS serial=%d local=%s" % [serial,str(local_anchor)])
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode == KEY_A:
        start_attack()
    elif event.keycode == KEY_R:
        reset_target()
