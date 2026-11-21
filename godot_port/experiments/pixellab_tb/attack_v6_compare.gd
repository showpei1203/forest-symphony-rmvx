extends Node2D
const PLAYER = preload("res://tb_attack_timeline.gd")
var old: Node2D
var newer: Node2D
var events: Array[String] = []
var panel: Label
func _ready() -> void:
    var bg=ColorRect.new()
    bg.color=Color("20252a")
    bg.size=Vector2(1140,610)
    add_child(bg)
    old=PLAYER.new()
    old.texture_path="res://assets/monsters/tb/PMD0001_ATTACK_V5_11F_384x288.png"
    old.position=Vector2(295,280)
    old.scale=Vector2(4,4)
    add_child(old)
    newer=PLAYER.new()
    newer.texture_path="res://assets/monsters/tb/PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png"
    newer.position=Vector2(845,280)
    newer.scale=Vector2(4,4)
    add_child(newer)
    newer.rush_started.connect(func(i: int):events.append("RUSH F%d" % i))
    newer.hit_requested.connect(func(i: int, _p: Vector2):events.append("HIT F%d" % i))
    newer.return_started.connect(func(i: int):events.append("RETURN F%d" % i))
    newer.attack_completed.connect(func():events.append("DONE"))
    panel=Label.new()
    panel.position=Vector2(28,20)
    panel.add_theme_font_size_override("font_size",20)
    add_child(panel)
    var labels=Label.new()
    labels.text="V5 manual cutout  /  ART HOLD                                    V6 PixelLab Skeleton v3  /  Pending Art Gate"
    labels.position=Vector2(55,505)
    add_child(labels)
func _process(_delta: float) -> void:
    panel.text="FS PMD0001 : SPACE attack / C cancel / R replay. Frame %d, %s" % [newer.frame_index,", ".join(events)]
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode in [KEY_SPACE,KEY_R]:
            old.cancel_attack()
            newer.cancel_attack()
            events.clear()
            old.play_attack()
            newer.play_attack()
        elif event.keycode == KEY_C:
            old.cancel_attack()
            newer.cancel_attack()
            events.append("CANCEL")
