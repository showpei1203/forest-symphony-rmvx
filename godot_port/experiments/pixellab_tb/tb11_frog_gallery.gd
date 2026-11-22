extends Node2D
# T-B-only art QA, not FS battle UI. Real licensed art stays private.
const MANIFEST := "res://TB11_FROG_FAMILY_MANIFEST.json"
var data: Dictionary = {}
var sprites: Array[AnimatedSprite2D] = []
var labels: Array[Label] = []
var active_action := "idle"
var actions := ["idle", "attack", "hurt", "ko", "guard", "skill", "fly"]
var stage_nodes: Array[Node2D] = []
var status_label: Label

func make_text(t: String, p: Vector2, size: int = 20, parent: Node = self) -> Label:
    var l := Label.new()
    l.text = t
    l.position = p
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", Color("d7efe2"))
    parent.add_child(l)
    return l

func _ready() -> void:
    var text := FileAccess.get_file_as_string(MANIFEST)
    assert(text.length() > 2, "Missing private art manifest")
    data = JSON.parse_string(text) as Dictionary
    var bg := ColorRect.new()
    bg.size = Vector2(1280, 768)
    bg.color = Color("152332")
    add_child(bg)
    make_text("FOREST SYMPHONY  |  T-B LAVA FROG ART FACTORY", Vector2(38, 24), 27)
    make_text("R11: separate source-authentic frog stages, original PixelLab frames | NOT battle/UI integration", Vector2(38, 72), 15)
    var stages: Array = data.get("stages", [])
    assert(stages.size() == 3)
    for i in range(3):
        var stage: Dictionary = stages[i]
        var holder := Node2D.new()
        holder.position = Vector2(235 + i * 412, 285)
        holder.name = "Stage%d" % (i + 1)
        add_child(holder)
        stage_nodes.append(holder)
        var image := AnimatedSprite2D.new()
        image.name = "Monster"
        image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        holder.add_child(image)
        image.scale = Vector2(3.1, 3.1)
        sprites.append(image)
        var name_label = make_text("STAGE %d | %s" % [i + 1, stage.get("name", "?")], Vector2(-155, 195), 17, holder)
        labels.append(name_label)
        make_text("Authentic source %dx%d" % [stage["source_size"][0], stage["source_size"][1]], Vector2(-125, 219), 14, holder)
    status_label = make_text("Idle: 1   Attack: 2   Hurt: 3   KO: 4  |   Space replay", Vector2(42, 658), 19)
    make_text("Unfinished actions show source still, not fabricated motion. QA is technical, human ART review separate.", Vector2(42, 703), 15)
    show_action("idle")

func _frames(path: String, n: int, cols: int, cell: Vector2i, fps: float, loop: bool) -> SpriteFrames:
    var src := load("res://" + path) as Texture2D
    if src == null or src.get_width() != cols*cell.x or src.get_height() != int(ceil(float(n)/cols))*cell.y:
        push_error("Missing or wrong atlas %s" % path)
        return null
    var frames := SpriteFrames.new()
    frames.remove_animation("default")
    frames.add_animation("play")
    frames.set_animation_loop("play", loop)
    frames.set_animation_speed("play", fps)
    for j in range(n):
        var crop := AtlasTexture.new()
        crop.atlas = src
        crop.region = Rect2((j%cols)*cell.x, int(j/cols)*cell.y, cell.x, cell.y)
        crop.filter_clip = true
        frames.add_frame("play", crop)
    return frames

func show_action(action: String) -> void:
    active_action = action
    for i in range(3):
        var sprite := sprites[i]
        var stage: Dictionary = data["stages"][i]
        var motions: Dictionary = stage["motions"]
        sprite.stop()
        if not motions.has(action):
            var still := load("res://" + str(stage["source_path"])) as Texture2D
            var f := SpriteFrames.new()
            f.remove_animation("default")
            f.add_animation("play")
            f.set_animation_loop("play", true)
            f.add_frame("play", still)
            sprite.sprite_frames = f
            sprite.play("play")
            labels[i].text = "STAGE %d | %s | %s NOT YET GENERATED" % [i + 1, stage["name"], action.to_upper()]
        else:
            var m: Dictionary = motions[action]
            sprite.sprite_frames = _frames(str(m["path"]), int(m["frames"]), int(m["columns"]), Vector2i(m["cell"][0], m["cell"][1]), float(m["fps"]), bool(m["loop"]))
            assert(sprite.sprite_frames != null)
            sprite.play("play")
            labels[i].text = "STAGE %d | %s | %s %dF" % [i + 1, stage["name"], action.to_upper(), int(m["frames"])]
    if status_label:
        status_label.text = "Action: %s  |  1:Idle  2:Attack  3:Hurt  4:KO   Space:Replay" % action.to_upper()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var codes := {KEY_1:"idle",KEY_2:"attack",KEY_3:"hurt",KEY_4:"ko"}
        if codes.has(event.keycode):
            show_action(codes[event.keycode])
        elif event.keycode == KEY_SPACE:
            show_action(active_action)
