class_name FSA44PracticeTarget
extends Area2D
## Isolated Godot battle contact integration target, not formal FS enemy/ATB.
signal damaged(serial: int, amount: int, health_after: int)
@export var radius_px: float = 29.0
@export var max_health: int = 100
var health: int = 100
var damage_count: int = 0
var last_damage_serial: int = -1
var last_contact: Vector2 = Vector2.ZERO
var _flash_time: float = 0.0
var _health_label: Label

func _ready() -> void:
    monitoring = true
    monitorable = true
    collision_layer = 1
    collision_mask = 0
    var shape_node := CollisionShape2D.new()
    shape_node.name = "CollisionShape2D"
    var circle := CircleShape2D.new()
    circle.radius = radius_px
    shape_node.shape = circle
    add_child(shape_node)
    _health_label = Label.new()
    _health_label.position = Vector2(-37,-74)
    add_child(_health_label)
    _update_label()
    set_process(true)

func _update_label() -> void:
    _health_label.text = "Practice target HP %d/%d" % [health,max_health]

func reset_health() -> void:
    health = max_health
    damage_count = 0
    last_damage_serial = -1
    _flash_time = 0.0
    _update_label()
    queue_redraw()

func apply_blade_contact(serial: int, blade_world_tip: Vector2, amount: int = 25) -> bool:
    # A44 contract: the hit is allowed only at the moving sword tip, once per serial.
    if serial == last_damage_serial or health <= 0 or amount <= 0:
        return false
    if blade_world_tip.distance_to(global_position) > radius_px:
        return false
    last_damage_serial = serial
    last_contact = blade_world_tip
    health = maxi(0, health - amount)
    damage_count += 1
    _flash_time = 0.20
    position += Vector2(7,0)
    _update_label()
    queue_redraw()
    damaged.emit(serial,amount,health)
    return true

func _process(delta: float) -> void:
    if _flash_time > 0.0:
        _flash_time = maxf(0.0,_flash_time-delta)
        queue_redraw()

func _draw() -> void:
    var wood: Color=Color(0.28,0.20,0.15)
    var ring: Color=Color(0.63,0.43,0.25)
    var center: Color=Color(0.92,0.73,0.38)
    if _flash_time > 0.0:
        ring=Color(0.96,0.27,0.19)
        center=Color(1.0,0.68,0.42)
    draw_line(Vector2(0,0),Vector2(0,53),wood,8.0)
    draw_circle(Vector2.ZERO,radius_px,wood)
    draw_arc(Vector2.ZERO,radius_px-3,0.0,TAU,48,ring,4.0)
    draw_circle(Vector2.ZERO,radius_px-12,ring)
    draw_circle(Vector2.ZERO,7,center)
    draw_line(Vector2(-9,49),Vector2(9,49),ring,4.0)
