class_name FSCombatTarget
extends Node2D
signal damaged(amount: int, hp_after: int, attack_serial: int)
signal defeated(attack_serial: int)
@export_range(1, 999999) var max_hp: int = 120
@export_range(0, 999999) var defense: int = 6
var hp: int = 120
func _ready() -> void:
    hp = max_hp
func receive_attack(raw_damage: int, serial: int) -> int:
    if hp <= 0:
        return 0
    var actual: int = maxi(1, raw_damage - defense)
    actual = mini(actual, hp)
    hp -= actual
    damaged.emit(actual, hp, serial)
    if hp == 0:
        defeated.emit(serial)
    return actual
