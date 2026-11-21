extends Node2D
## FS T-B second species validation; same Godot 4.7.2 family templates.
## Images are PRIVATE; do not commit to public GitHub.
const FAMILY_FILE := "res://TB02_LEAF_BAT_MANIFEST.json"
const TIMELINE := preload("res://tb_attack_timeline_parametric.gd")
var attack: Node2D
var idle: AnimatedSprite2D
var status: Label
var events: Array[String] = []
var stage_nodes: Array[Sprite2D] = []
func text(t: String, at: Vector2, sz: int = 16) -> Label:
    var l=Label.new()
    l.text=t
    l.position=at
    l.add_theme_font_size_override("font_size",sz)
    add_child(l)
    return l
func _ready() -> void:
    var f=FileAccess.open(FAMILY_FILE,FileAccess.READ)
    if f==null:push_error("Missing TB02 family manifest");return
    var dat=JSON.parse_string(f.get_as_text()) as Dictionary
    var bg=ColorRect.new()
    bg.color=Color("17212b")
    bg.size=Vector2(1220,780)
    add_child(bg)
    text("Forest Symphony / T-B Factory / second-family benchmark",Vector2(28,19),27)
    text("TB02 Leaf Bat  |  3 stages, new 14-joint wing rig  |  ART REVIEW PENDING",Vector2(30,61),17)
    var static_pos=[Vector2(200,240),Vector2(600,240),Vector2(1010,240)]
    var static_scale=[2.6,2.25,1.95]
    var arr=dat["stages"] as Array
    for i in arr.size():
        var t=load("res://"+str(arr[i]["path"])) as Texture2D
        if t==null:push_error("Missing stage PNG: "+str(arr[i]["path"]));continue
        var s=Sprite2D.new()
        s.texture=t
        s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        s.position=static_pos[i]
        s.scale=Vector2.ONE*float(static_scale[i])
        add_child(s)
        stage_nodes.append(s)
        text(str(arr[i]["name"]),Vector2(55+i*399,392),16)
        text("%dx%d original sprite"%[t.get_width(),t.get_height()],Vector2(55+i*399,415),14)
    text("Mother Idle / PixelLab 8-frame wing flap",Vector2(100,484),16)
    text("Mother Attack / PixelLab 11-frame dive claw",Vector2(640,484),16)
    var idata=dat["idle"] as Dictionary
    var src=load("res://"+str(idata["path"])) as Texture2D
    if src!=null:
        var frames=SpriteFrames.new()
        frames.remove_animation("default")
        frames.add_animation("idle")
        frames.set_animation_loop("idle",true)
        frames.set_animation_speed("idle",float(idata["speed_fps"]))
        for i in int(idata["frames"]):
            var region=AtlasTexture.new()
            region.atlas=src
            region.region=Rect2((i%4)*96,int(i/4)*96,96,96)
            region.filter_clip=true
            frames.add_frame("idle",region)
        idle=AnimatedSprite2D.new()
        idle.sprite_frames=frames
        idle.animation="idle"
        idle.position=Vector2(264,619)
        idle.scale=Vector2(2.4,2.4)
        idle.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        add_child(idle)
        idle.play()
    var adata=dat["attack"] as Dictionary
    attack=TIMELINE.new()
    attack.texture_path="res://"+str(adata["path"])
    attack.cell_size=Vector2i(int(adata["cell"][0]),int(adata["cell"][1]))
    attack.position=Vector2(888,620)
    attack.scale=Vector2(2.4,2.4)
    add_child(attack)
    attack.rush_started.connect(func(fidx:int):events.append("RUSH %d"%fidx))
    attack.hit_requested.connect(func(fidx:int,_v:Vector2):events.append("HIT %d"%fidx))
    attack.return_started.connect(func(fidx:int):events.append("RETURN %d"%fidx))
    attack.attack_completed.connect(func():events.append("DONE"))
    text("SPACE attack   R replay   C cancel   |   User art gate pending",Vector2(30,725),14)
    status=text("frame 0",Vector2(570,706),13)
func _process(_delta:float)->void:
    if status and attack:status.text="frame %d  /  %s"%[attack.frame_index,", ".join(events)]
func _input(e:InputEvent)->void:
    if e is InputEventKey and e.pressed and not e.echo:
        if e.keycode in [KEY_SPACE,KEY_R]:
            attack.cancel_attack()
            events.clear()
            attack.play_attack()
        elif e.keycode==KEY_C:attack.cancel_attack();events.append("CANCEL")
