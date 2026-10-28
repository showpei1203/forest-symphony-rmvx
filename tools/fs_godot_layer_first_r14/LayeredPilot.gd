extends Node2D
## Editable scene layers: GROUND and CONTACT have no floor pixels in PAR.
## Z uses logical world foot Y for the PAR nodes and actor.
@onready var ground_layer: Node2D = $GROUND
@onready var root_contact_layer: Node2D = $CONTACT
@onready var raised_layer: Node2D = $PAR
@onready var actor: Sprite2D = $ACTOR

func set_export_mode(mode: String) -> void:
    ground_layer.visible = mode != "PAR"
    root_contact_layer.visible = mode != "PAR"
    raised_layer.visible = mode != "BASE"
    actor.visible = mode.begins_with("ACTOR")
    if mode == "ACTOR_BACK":
        actor.position = Vector2(120, 153)
        actor.z_index = 185
    if mode == "ACTOR_FRONT":
        actor.position = Vector2(120, 188)
        actor.z_index = 230