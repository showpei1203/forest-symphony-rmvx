extends CharacterBody2D
## A32 explicit overworld movement geometry. Original A62 battle RUN is NOT used as fake 4-way sprite.
@export var speed: float = 115.0
@export_file("*.png") var actor_image_file: String = "res://private_assets/actor_f0.png"
@export var actor_sha256: String = "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"

func _ready() -> void:
    var visual := $Sprite as Sprite2D
    visual.centered = false
    visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(actor_image_file):
        if FileAccess.get_sha256(actor_image_file) != actor_sha256:
            push_error("A32 Actor01 original SHA mismatch")
            return
        visual.texture = load(actor_image_file)
        visual.position = Vector2(-24,-47)

func _physics_process(_delta: float) -> void:
    var v := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    velocity = v * speed
    move_and_slide()
    global_position.x = clampf(global_position.x, 7, 1273)
    global_position.y = clampf(global_position.y, 7, 921)
