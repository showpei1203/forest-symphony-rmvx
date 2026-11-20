extends Node2D
## Independent T-C art pilot; actual FS baseline scenes are never modified.
## Pixel source is generated from the historical PixelLab A36G input with exact XY.
@export var generated_dir: String = "res://tc_factory/generated/"
var floor_image: Sprite2D
var actor: Node2D
var overlays: Array[Dictionary] = []
var owners_loaded := 0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    floor_image = Sprite2D.new()
    floor_image.name = "Runtime_FullGround"
    floor_image.centered = false
    floor_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    floor_image.texture = load(generated_dir + "Runtime_FullGround.png")
    if floor_image.texture == null:
        push_error("T-C generated source missing. Run build_tc_village_pilot.py first.")
        return
    floor_image.z_index = -10
    add_child(floor_image)
    actor = Node2D.new()
    actor.name = "TCTestActor_NotProductionActor"
    actor.z_index = 0
    add_child(actor)
    _build_test_actor()
    var file := FileAccess.open(generated_dir + "TC_PILOT_OCCLUSION_OWNERS.json", FileAccess.READ)
    if file == null:
        push_error("T-C occlusion owner manifest missing.")
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Array):
        push_error("T-C invalid owner manifest.")
        return
    for owner in parsed:
        var sprite := Sprite2D.new()
        sprite.name = str(owner["id"])
        sprite.centered = false
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.texture = load(generated_dir + "occlusion_owners/" + str(owner["file"]))
        if sprite.texture == null:
            push_error("T-C owner layer missing: " + str(owner["file"]))
            return
        sprite.z_index = 10
        add_child(sprite)
        overlays.append({"node":sprite,"foot_y":float(owner["foot_y"]),
                         "bbox":owner["bbox"]})
    owners_loaded = overlays.size()
    set_test_actor_foot(Vector2(305, 280))

func _block(x:float,y:float,w:float,h:float,c:Color) -> void:
    var rect := ColorRect.new()
    rect.color = c
    rect.position = Vector2(x,y)
    rect.size = Vector2(w,h)
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    actor.add_child(rect)

func _build_test_actor() -> void:
    # TEST PLACEHOLDER, not FS character art or actor identity acceptance.
    _block(-4,-18,8,5,Color("#d9d5bc"))
    _block(-5,-20,10,3,Color("#f1e8c7"))
    _block(-5,-13,10,10,Color("#426481"))
    _block(-3,-3,3,5,Color("#46352e"))
    _block(1,-3,3,5,Color("#46352e"))
    _block(-6,-11,2,6,Color("#b08c67"))
    _block(4,-11,2,6,Color("#b08c67"))

func set_test_actor_foot(pos: Vector2) -> void:
    actor.position = pos
    for layer in overlays:
        var bounds: Array = layer["bbox"]
        var inside_x := pos.x >= float(bounds[0])-9 and pos.x <= float(bounds[2])+9
        var behind := pos.y < float(layer["foot_y"])
        (layer["node"] as Sprite2D).visible = inside_x and behind

func visible_occlusion_owners() -> int:
    var count := 0
    for layer in overlays:
        if (layer["node"] as Sprite2D).visible:
            count += 1
    return count
