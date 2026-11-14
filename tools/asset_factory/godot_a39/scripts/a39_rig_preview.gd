extends Node2D
## Three-way 1:1 pixel-art comparison: approved static vs A38 AI calm vs native A39 shader rig.
@onready var rig: FSActorBreathRig = $BreathRig
var title_label: Label

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    title_label = Label.new()
    title_label.position = Vector2(36, 30)
    title_label.text = "FOREST SYMPHONY | A39 GODOT LOCAL BREATH RIG | SHOULDER + CHEST ONLY"
    title_label.add_theme_color_override("font_color", Color(0.95,0.95,0.92))
    add_child(title_label)

func _draw() -> void:
    draw_rect(Rect2(0,0,1024,720),Color(0.09,0.13,0.17))
    draw_rect(Rect2(0,480,1024,240),Color(0.13,0.18,0.19))
    draw_line(Vector2(0,480),Vector2(1024,480),Color(0.27,0.37,0.32),2)
    for x in [200,500,800]:
        draw_arc(Vector2(x,480),98,0,TAU,64,Color(0.29,0.43,0.38),2.0)

func _process(_delta: float) -> void:
    if title_label != null:
        title_label.text = "FS A39 GODOT  |  STATIC SOURCE  /  AI CALM HOLD  /  CONTROLLED RIG  |  breath %.2f" % rig.get_breath()
