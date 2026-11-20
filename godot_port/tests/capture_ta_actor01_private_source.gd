extends SceneTree
# T-A real private source GPU capture, run in Godot 4.7.2 with six staged
# owner-private 256x192 PNGs. Never commit licensed sprites to public GitHub.
# Captures 24 1x real GPU frames. Rendering is NOT an ART approval or
# proof that the gameplay battle scene uses this motion.
const FRAMES: int = 12
const ATLAS: Vector2i = Vector2i(256, 192)
const GRID_COLUMNS: int = 4
const CELL: int = 64
const FILES: Array[String] = [
    "res://assets/ta_actor01/run_body.png",
    "res://assets/ta_actor01/run_weapon.png",
    "res://assets/ta_actor01/run_fx.png",
    "res://assets/ta_actor01/attack_body.png",
    "res://assets/ta_actor01/attack_weapon.png",
    "res://assets/ta_actor01/attack_fx.png"
]
var textures: Array[Texture2D] = []
var view: SubViewport
var layers: Array[Sprite2D] = []

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("TA_PRIVATE_NATIVE_FAIL " + reason)
    quit(1)

func _run() -> void:
    var out_dir: String = OS.get_environment("TA_QA_DIR")
    if out_dir.is_empty():
        _fail("TA_QA_DIR env missing")
        return
    if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
        _fail("Cannot create output directory")
        return
    for path in FILES:
        if not FileAccess.file_exists(path):
            _fail("Missing private atlas " + path)
            return
        var img: Image = Image.load_from_file(path)
        if img == null or img.get_size() != ATLAS:
            _fail("Invalid source image size " + path)
            return
        textures.append(ImageTexture.create_from_image(img))
    view = SubViewport.new()
    view.name = "NativeProof64x64"
    view.size = Vector2i(CELL, CELL)
    view.transparent_bg = true
    view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    var origin: Node2D = Node2D.new()
    origin.position = Vector2(CELL / 2, CELL / 2)
    view.add_child(origin)
    for layer_name in ["Body", "Weapon", "FX"]:
        var sprite: Sprite2D = Sprite2D.new()
        sprite.name = layer_name
        sprite.centered = true
        sprite.region_enabled = true
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        origin.add_child(sprite)
        layers.append(sprite)
    var saved: int = 0
    for motion in ["run", "attack"]:
        var offset: int = 0 if motion == "run" else 3
        for frame in range(FRAMES):
            var col: int = frame % GRID_COLUMNS
            var row: int = int(frame / GRID_COLUMNS)
            var atlas_rect: Rect2 = Rect2(col * CELL, row * CELL, CELL, CELL)
            for layer_index in range(3):
                layers[layer_index].texture = textures[offset + layer_index]
                layers[layer_index].region_rect = atlas_rect
            await process_frame
            await process_frame
            var output_image: Image = view.get_texture().get_image()
            if output_image == null or output_image.get_size() != Vector2i(CELL,CELL):
                _fail("Bad GPU readback " + motion + " F" + str(frame))
                return
            var destination: String = "%s/%s_f%02d.png" % [out_dir, motion, frame]
            if output_image.save_png(destination) != OK:
                _fail("Cannot save GPU PNG " + destination)
                return
            saved += 1
    print("TA_PRIVATE_NATIVE_GPU_PASS 24/24 actual source composites (12 RUN,12 ATTACK), 64x64, 3 independent layers")
    quit(0)
