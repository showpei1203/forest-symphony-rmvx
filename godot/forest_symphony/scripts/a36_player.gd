extends CharacterBody2D
## F0 original 45-degree battle actor is only scale/occlusion proxy, NOT approved four-way overworld.
@export var speed: float=115.0
const ACTOR_PATH := "res://private_assets/actor_f0.png"
const ACTOR_SHA := "a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba"
func _ready()->void:
    var visual: Sprite2D=$Sprite
    visual.centered=false
    visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    if FileAccess.file_exists(ACTOR_PATH):
        if FileAccess.get_sha256(ACTOR_PATH)!=ACTOR_SHA:push_error("A36 actor F0 original mismatch");return
        visual.texture=load(ACTOR_PATH)
        visual.position=Vector2(-24,-47)
func _physics_process(_delta:float)->void:
    velocity=Input.get_vector("ui_left","ui_right","ui_up","ui_down") *speed
    move_and_slide()
    global_position.x=clampf(global_position.x,7,2553)
    global_position.y=clampf(global_position.y,7,1849)
