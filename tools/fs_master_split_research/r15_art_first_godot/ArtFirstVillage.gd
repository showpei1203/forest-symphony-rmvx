extends Node2D
@onready var master: Sprite2D = $MASTER
@onready var foreground: Node2D = $PAR
@onready var actor: Sprite2D = $ACTOR

func set_capture_mode(mode: String) -> void:
    master.visible = mode != "PAR"
    foreground.visible = mode != "MASTER"
    actor.visible = mode.begins_with("ACTOR")
    if mode == "ACTOR_BACK":
        actor.position = Vector2(290, 437)
        actor.z_index = 451
    elif mode == "ACTOR_FRONT":
        actor.position = Vector2(290, 535)
        actor.z_index = 569