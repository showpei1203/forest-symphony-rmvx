extends SceneTree
const W: int = 1280
const H: int = 928
var vp: SubViewport
var world: Node2D
var actor: Sprite2D
var cache: Dictionary = {}
var reports: Array = []
func _initialize() -> void:
    call_deferred("_run")
func tex(filename: String) -> Texture2D:
    if cache.has(filename): return cache[filename]
    var im := Image.load_from_file(ProjectSettings.globalize_path("res://assets/"+filename))
    assert(not im.is_empty(),filename)
    var t := ImageTexture.create_from_image(im)
    cache[filename] = t
    return t
func add_owned(ob: Dictionary) -> void:
    var pivot: Node2D = Node2D.new()
    pivot.name = String(ob["id"])+"_Footpoint"
    pivot.position = Vector2(float(ob["foot"][0]),float(ob["foot"][1])+1.0)
    world.add_child(pivot)
    var child: Sprite2D = Sprite2D.new()
    child.texture = tex(String(ob["filename"]))
    child.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    child.centered = false
    child.position = Vector2(float(ob["x"])-pivot.position.x,float(ob["y"])-pivot.position.y)
    pivot.add_child(child)
func save_native(filename: String, show: bool, pos: Vector2) -> void:
    actor.visible = show
    actor.position = pos
    await process_frame
    await RenderingServer.frame_post_draw
    var im := vp.get_texture().get_image()
    assert(im.get_size()==Vector2i(W,H))
    assert(im.save_png(ProjectSettings.globalize_path("res://out/"+filename))==OK)
    reports.append({"file":filename,"actor":show,"pos":[pos.x,pos.y],"engine_native_full_size":true})
func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://out"))
    vp = SubViewport.new()
    vp.size = Vector2i(W,H)
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    vp.transparent_bg = false
    get_root().add_child(vp)
    world = Node2D.new()
    world.y_sort_enabled = true
    vp.add_child(world)
    var ground: Sprite2D = Sprite2D.new()
    ground.texture = tex("A36G_R5_GROUND_1280x928.png")
    ground.centered = false
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    ground.z_index = -10
    world.add_child(ground)
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/A36G_R5_GODOT_SOURCE_SCENE.json"))
    assert(int(manifest["meta"]["size_px"][0])==W and int(manifest["meta"]["size_px"][1])==H)
    var count: int = 0
    var trees: int = 0
    for ob in manifest["objects"]:
        add_owned(ob)
        count+=1
        if ob["type"]=="tree": trees+=1
    assert(count==192 and trees==59)
    actor = Sprite2D.new()
    actor.texture = tex("FS_ACTOR01_DOWN_STAND_32x32.png")
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.offset = Vector2(0,-16)
    world.add_child(actor)
    await save_native("A36G_R5_GODOT_00_FULL_NO_ACTOR_1280x928.png",false,Vector2(650,470))
    await save_native("A36G_R5_GODOT_01_MAIN_CROSSROADS_ACTOR.png",true,Vector2(650,470))
    await save_native("A36G_R5_GODOT_02_WEST_TRAIL_ACTOR.png",true,Vector2(305,500))
    await save_native("A36G_R5_GODOT_03_EAST_REST_ACTOR.png",true,Vector2(990,470))
    await save_native("A36G_R5_GODOT_04_SOUTH_BRANCH_ACTOR.png",true,Vector2(700,734))
    await save_native("A36G_R5_GODOT_05_NORTH_BRANCH_ACTOR.png",true,Vector2(610,170))
    var snapshot: Image = Image.load_from_file(ProjectSettings.globalize_path("res://out/A36G_R5_GODOT_00_FULL_NO_ACTOR_1280x928.png"))
    for i in range(6):
        var cx: int = [0,368,736,0,368,736][i]
        var cy: int = [0,0,0,512,512,512][i]
        var cut := snapshot.get_region(Rect2i(cx,cy,544,416))
        assert(cut.get_size()==Vector2i(544,416))
        assert(cut.save_png(ProjectSettings.globalize_path("res://out/A36G_R5_GODOT_NATIVE_FULL_CROP_%02d.png" % i))==OK)
    var proof: Dictionary = {"stage":"A36G_R5","renderer":"Godot_4_7_2_OpenGL_actual_GPU",
      "native_full_size":[1280,928],"total_objects":count,"trees":trees,
      "full_scene_views":reports,"native_gpu_crops":6,"formal_seal":"NO","art_signoff":"PENDING"}
    var f := FileAccess.open("res://out/A36G_R5_GODOT_FULL_MAP_RENDER_QA.json",FileAccess.WRITE)
    f.store_string(JSON.stringify(proof,"	"))
    f.close()
    print("A36G_R5_GODOT_FULL_MAP_NATIVE_PASS trees=",trees," objects=",count," full_frames=",reports.size())
    quit(0)
