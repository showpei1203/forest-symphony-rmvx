class_name FSAttackBridge
extends Node
signal attack_resolved(serial: int, applied_damage: int, target_hp: int)
signal attack_missed(serial: int, reason: String)
@export var actor_path: NodePath
@export var target_path: NodePath
@export_range(1, 999999) var base_damage: int = 35
@export_range(1.0, 1024.0) var attack_reach: float = 128.0
var actor: FSBattleActorAnimator
var target: FSCombatTarget
var _handled: Dictionary = {}
var _latest_serial: int = 0
func _ready() -> void:
    actor = get_node_or_null(actor_path) as FSBattleActorAnimator
    target = get_node_or_null(target_path) as FSCombatTarget
    if actor == null or target == null:
        push_error("FS bridge: actor/target missing")
        return
    actor.attack_contact_anchor.connect(_on_contact)
    actor.attack_cancelled.connect(_on_cancel)
func _on_cancel(serial: int) -> void:
    _handled[serial] = true
func _on_contact(serial: int, _local: Vector2, world: Vector2) -> void:
    if actor == null or target == null:
        return
    if _handled.has(serial):
        return
    if serial <= _latest_serial:
        attack_missed.emit(serial, "stale_serial")
        return
    _latest_serial = serial
    _handled[serial] = true
    if target.hp <= 0:
        attack_missed.emit(serial, "target_defeated")
        return
    if world.distance_to(target.global_position) > attack_reach:
        attack_missed.emit(serial, "out_of_range")
        return
    var actual: int = target.receive_attack(base_damage, serial)
    attack_resolved.emit(serial, actual, target.hp)
