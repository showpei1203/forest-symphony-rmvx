extends Node2D
## Forest Symphony T-B family preview. Source images belong exclusively to PRIVATE Drive.
## Godot 4.7.2 standalone, no FS battle-system side effects.
const ATTACK = preload("res://tb_attack_timeline.gd")
const SOURCES := [
    "res://assets/monsters/tb/PMD0001_STATIC_64.png",
    "res://assets/monsters/tb/PMD0002_STATIC_64.png",
    "res://assets/monsters/tb/PMD0003_STATIC_64.png",
]
const IDLE := "res://assets/monsters/tb/PMD0001_IDLE_3F_192x64.png"
const ATTACK_PATH := "res://assets/monsters/tb/PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png"
var attack: Node2D
var idle: AnimatedSprite2D
var event_log: Array[String] = []
var status_label: Label
var title_font_size := 21
func label(t: String, at: Vector2, size: int = 17) -> Label:
    var l := Label.new()
    l.text=t
    l.position=at
    l.add_theme_font_size_override("font_size",size)
    add_child(l)
    return l
func _ready() -> void:
    var bg := ColorRect.new()
    bg.color = Color("17212b")
    bg.size = Vector2(1160,700)
    add_child(bg)
    label("Forest Symphony / T-B Monster Family 01",Vector2(32,18),27)
    label("3-stage evolution  |  source-locked PRIVATE family  |  V6 Attack USER_ART_ACCEPTED",Vector2(32,60),16)
    var family_names := ["PMD0001 / young lava frog", "PMD0002 / basalt armor", "PMD0003 / elder magma core"]
    for i in 3:
        var t=load(SOURCES[i]) as Texture2D
        if t==null:
            push_error("T-B source missing "+SOURCES[i])
            continue
        var s:=Sprite2D.new()
        s.texture=t
        s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        s.scale=Vector2(3.4,3.4)
        s.position=Vector2(205+i*368,217)
        add_child(s)
        label(family_names[i],Vector2(70+i*369,342),16)
    label("Mother Idle  /  genuine historical PixelLab 3-frame", Vector2(92,420),15)
    var src=load(IDLE) as Texture2D
    if src==null:push_error("Missing Idle image")
    else:
        var sf=SpriteFrames.new()
        sf.remove_animation("default")
        sf.add_animation("idle")
        sf.set_animation_loop("idle",true)
        sf.set_animation_speed("idle",3.0)
        for i in 3:
            var crop=AtlasTexture.new()
            crop.atlas=src
            crop.region=Rect2(i*64,0,64,64)
            crop.filter_clip=true
            sf.add_frame("idle",crop)
        idle=AnimatedSprite2D.new()
        idle.sprite_frames=sf
        idle.animation="idle"
        idle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        idle.scale=Vector2(3.0,3.0)
        idle.position=Vector2(215,555)
        add_child(idle)
        idle.play()
    label("Mother Attack  /  PixelLab Skeleton v3 11-frame",Vector2(568,420),15)
    attack=ATTACK.new()
    attack.texture_path=ATTACK_PATH
    attack.position=Vector2(810,553)
    attack.scale=Vector2(2.7,2.7)
    add_child(attack)
    attack.rush_started.connect(func(i:int):event_log.append("RUSH F%d"%i))
    attack.hit_requested.connect(func(i:int, _v:Vector2):event_log.append("HIT F%d"%i))
    attack.return_started.connect(func(i:int):event_log.append("RETURN F%d"%i))
    attack.attack_completed.connect(func():event_log.append("COMPLETE"))
    label("SPACE: attack  |  C: cancel  |  R: replay  |  no PixelLab generation needed",Vector2(42,656),15)
    status_label=label("Ready",Vector2(568,635),13)
func _process(_delta:float)->void:
    if status_label and attack:status_label.text="frame %d  |  %s"%[attack.frame_index, ", ".join(event_log)]
func _input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode in [KEY_SPACE,KEY_R]:
            attack.cancel_attack()
            event_log.clear()
            attack.play_attack()
        elif e.keycode==KEY_C:
            attack.cancel_attack()
            event_log.append("CANCEL")
