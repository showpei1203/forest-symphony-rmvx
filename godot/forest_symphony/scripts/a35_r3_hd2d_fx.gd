extends Node2D
## FS A35 R3: optional HD-2D atmosphere, independent of Ground/PAR/collision.
## Native effects only; no baked changes. N=day/dusk/night, V=rain, L=on/off.
@export_range(0.0, 1.0, 0.05) var intensity := 0.65
@export var animate := true
var phase := 0
var raining := false
var enabled := true
var elapsed := 0.0
var tint: CanvasModulate
var lanterns: Array[PointLight2D] = []
const LANTERN_FOOTPOINTS := [Vector2(438,473), Vector2(878,492), Vector2(1010,575), Vector2(580,674)]

func _ready() -> void:
    z_index = 70
    tint = CanvasModulate.new()
    tint.name = "DayNightCanvasModulate"
    add_child(tint)
    var glow_image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var radius := Vector2(x - 47.5, y - 47.5).length() / 47.5
            glow_image.set_pixel(x, y, Color(1,1,1,pow(maxf(0.0, 1.0-radius),2.2)))
    var glow_texture := ImageTexture.create_from_image(glow_image)
    for index in range(LANTERN_FOOTPOINTS.size()):
        var lamp := PointLight2D.new()
        lamp.name = "Lantern_%d" % index
        lamp.position = LANTERN_FOOTPOINTS[index]
        lamp.texture = glow_texture
        lamp.texture_scale = 2.35
        lamp.energy = 0
        lamp.color = Color(1.0,0.70,0.35)
        lamp.shadow_enabled = false
        add_child(lamp)
        lanterns.append(lamp)
    _update_phase()
    set_process(true)

func _update_phase() -> void:
    var shade := Color.WHITE
    if phase == 1:
        shade = Color(0.76,0.79,0.87)
    elif phase == 2:
        shade = Color(0.40,0.50,0.70)
    tint.color = Color.WHITE.lerp(shade,intensity if enabled else 0.0)
    var lamp_power := 0.25
    if phase == 1:
        lamp_power = 0.78
    elif phase == 2:
        lamp_power = 1.25
    for lamp in lanterns:
        lamp.energy = lamp_power * intensity if enabled else 0.0
    queue_redraw()

func _process(delta: float) -> void:
    if animate:
        elapsed += delta
        queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_N:
                phase = (phase + 1) % 3
                _update_phase()
            KEY_V:
                raining = not raining
                queue_redraw()
            KEY_L:
                enabled = not enabled
                _update_phase()

func _draw() -> void:
    if not enabled or intensity <= 0.0:
        return
    if phase != 2:
        var rays := [
            PackedVector2Array([Vector2(305,-100),Vector2(335,-100),Vector2(580,665),Vector2(510,665)]),
            PackedVector2Array([Vector2(420,-120),Vector2(438,-120),Vector2(770,755),Vector2(708,755)]),
            PackedVector2Array([Vector2(905,-110),Vector2(925,-110),Vector2(1105,485),Vector2(1050,485)])
        ]
        for rayshape in rays:
            draw_colored_polygon(rayshape,Color(1.0,0.90,0.64,(0.031 if phase == 0 else 0.014)*intensity))
    for i in range(42):
        var x := fmod(float(i*191+83),1250.0) + sin(elapsed*.61+float(i)*1.71)*2.3
        var y := fmod(float(i*127+149),910.0)
        var pulse := .5 + .5*sin(elapsed*1.2+float(i)*2.3)
        draw_circle(Vector2(x,y),0.8 if i%3 else 1.2,Color(1.0,.95,.70,(.12+pulse*.18)*intensity))
    if raining:
        for i in range(74):
            var x := fmod(float(i*157+67)+elapsed*25.0,1310.0)
            var y := fmod(float(i*97+31)+elapsed*105.0,950.0)
            draw_line(Vector2(x,y),Vector2(x-2.0,y+8.0),Color(.72,.85,1.0,.19*intensity),1.0)
