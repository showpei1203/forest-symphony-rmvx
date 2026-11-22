extends Node2D
# ART GALLERY ONLY. Absolutely no Forest Symphony combat, HUD, Enemy ID or ATB integration.
const MANIFEST := "res://TB12_MONSTER_FAMILY_MANIFEST.json"
const ACTIONS := ["idle", "attack", "hurt", "ko", "guard", "skill", "locomotion"]
var data: Dictionary = {}
var sprites: Array[AnimatedSprite2D] = []
var labels: Array[Label] = []
var active_action := "guard"
var status_label: Label

func make_label(text_value: String, pos: Vector2, size: int=18, parent: Node=self, tint: Color=Color("e2efe3")) -> Label:
    var l := Label.new()
    l.text = text_value
    l.position = pos
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", tint)
    parent.add_child(l)
    return l

func _ready() -> void:
    var raw := FileAccess.get_file_as_string(MANIFEST)
    assert(raw.length() > 100, "Missing PRIVATE monster-family manifest")
    data = JSON.parse_string(raw) as Dictionary
    assert(data.has("families") and data["families"].size()==2)
    var bg := ColorRect.new()
    bg.size = Vector2(1280,900)
    bg.color=Color("152635")
    add_child(bg)
    var upper := ColorRect.new()
    upper.position = Vector2(24,142)
    upper.size=Vector2(1230,308)
    upper.color=Color("1c3340")
    add_child(upper)
    var lower := ColorRect.new()
    lower.position=Vector2(24,480)
    lower.size=Vector2(1230,306)
    lower.color=Color("1a303a")
    add_child(lower)
    make_label("FOREST SYMPHONY  |  T-B R12 MONSTER ART FACTORY",Vector2(30,20),28)
    make_label("SOURCE-LOCKED PIXELLAB  |  6 FORMS / 42 CLIPS / 340 FRAMES  |  NO COMBAT INTEGRATION", Vector2(30,66),17,self,Color("a5bfbe"))
    make_label("1 Idle   2 Attack   3 Hurt   4 KO   5 Guard   6 Skill   7 Fly/Hop   Space Replay",Vector2(30,104),18,self,Color("e3ce9c"))
    for family_index in range(2):
        var family: Dictionary = data["families"][family_index]
        var label := "LEAF BAT  /  THREE-STAGE EVOLUTION" if family_index==0 else "LAVA FROG  /  THREE-STAGE EVOLUTION"
        var y0: float = 162.0 if family_index==0 else 499.0
        make_label(label,Vector2(42,y0),20,self,Color("eacb8a"))
        for stage_index in range(3):
            var stage: Dictionary = family["stages"][stage_index]
            var holder := Node2D.new()
            holder.name="Family%dStage%d" % [family_index+1, stage_index+1]
            holder.position=Vector2(252+stage_index*400,y0+143)
            add_child(holder)
            var sprite := AnimatedSprite2D.new()
            sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
            sprite.name="OriginalPixels"
            holder.add_child(sprite)
            sprites.append(sprite)
            labels.append(make_label("STAGE %d  |  %s" % [stage_index+1,str(stage.get("name","?"))],Vector2(90+stage_index*400,y0+262),17))
    status_label=make_label("",Vector2(36,830),20,self,Color("e2efe3"))
    make_label("Technical QA PASS is not human art approval. Original owner-approved attacks remain locked.",Vector2(36,863),16,self,Color("a3bcbd"))
    show_action("guard")

func load_frames(m: Dictionary) -> SpriteFrames:
    var path := "res://"+str(m["path"])
    var source := load(path) as Texture2D
    assert(source != null,"Missing real sprite atlas: "+path)
    var n := int(m["frames"])
    var cols := int(m["columns"])
    var cell := Vector2i(int(m["cell"][0]),int(m["cell"][1]))
    assert(source.get_width()==cols*cell.x and source.get_height()==int(ceil(float(n)/float(cols)))*cell.y,"Wrong atlas dimensions: "+path)
    var result:=SpriteFrames.new()
    result.remove_animation("default")
    result.add_animation("play")
    result.set_animation_loop("play",bool(m["loop"]))
    result.set_animation_speed("play",float(m["fps"]))
    for i in range(n):
        var frame:=AtlasTexture.new()
        frame.atlas=source
        frame.region=Rect2((i%cols)*cell.x,int(i/cols)*cell.y,cell.x,cell.y)
        frame.filter_clip=true
        result.add_frame("play",frame)
    return result

func show_action(action: String) -> void:
    assert(ACTIONS.has(action))
    active_action=action
    var j:=0
    for fi in range(2):
        var f: Dictionary=data["families"][fi]
        for si in range(3):
            var s: Dictionary=f["stages"][si]
            var key: String=("fly" if fi==0 else "hop") if action=="locomotion" else action
            var m: Dictionary=s["motions"][key]
            var sprite: AnimatedSprite2D=sprites[j]
            sprite.stop()
            sprite.sprite_frames=load_frames(m)
            sprite.scale=Vector2(245.0/float(m["cell"][0]),245.0/float(m["cell"][1]))
            sprite.play("play")
            labels[j].text="STAGE %d  |  %s  |  %s %dF" % [si+1,s["name"],key.to_upper(),int(m["frames"])]
            j+=1
    if status_label != null:
        status_label.text="ACTION: %s    |    Original PixelLab atlases (source SHA locked)  |  ART REVIEW PENDING" % action.to_upper()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var keys: Dictionary={KEY_1:"idle",KEY_2:"attack",KEY_3:"hurt",KEY_4:"ko",KEY_5:"guard",KEY_6:"skill",KEY_7:"locomotion"}
        if keys.has(event.keycode):show_action(keys[event.keycode])
        elif event.keycode==KEY_SPACE:show_action(active_action)
