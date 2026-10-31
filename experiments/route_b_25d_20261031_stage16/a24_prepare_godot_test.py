from pathlib import Path
import shutil,json
R=Path(__file__).resolve().parent
P=R/'GODOT_ISOLATED_V4_7_2'
AS=P/'assets'
AS.mkdir(parents=True,exist_ok=True)
for n in ['A24_GROUND_544x416.png','A24_PAR_RGBA_544x416.png','A24_PAR_COLLISION_32_GRID.json','A24_SCENE_MANIFEST.json']:
 shutil.copy2(R/n,AS/n)
for p in (R/'PAR_COMPONENTS').glob('*.png'):
 if p.name!='FS_BORDER_RIGHT_95x416_RGBA.png':shutil.copy2(p,AS/p.name)
(P/'project.godot').write_text('config_version=5\n\n[application]\nconfig/name="FS Stage16 A24 Ground / PAR Isolated Godot Test"\n\n[rendering]\nrenderer/rendering_method="gl_compatibility"\nrenderer/rendering_method.mobile="gl_compatibility"\ntextures/default_filters/use_nearest_mipmap_filter=false\n',encoding='utf8')
code=r'''extends SceneTree
const W = 544
const H = 416
var vp: SubViewport
var world: Node2D
var texture_cache: Dictionary = {}
var actor: Sprite2D
var reports: Array = []
func _initialize() -> void:
    call_deferred("_run")
func _texture(name: String) -> Texture2D:
    if texture_cache.has(name):
        return texture_cache[name]
    var file_path: String = ProjectSettings.globalize_path("res://assets/" + name)
    var im: Image = Image.load_from_file(file_path)
    assert(not im.is_empty(), "Missing asset: "+name)
    var tex: Texture2D = ImageTexture.create_from_image(im)
    texture_cache[name] = tex
    return tex
func _add_sprite(name: String, x: float, y: float, w: int, h: int, base_y: float, layer_name: String) -> Sprite2D:
    var node := Sprite2D.new()
    node.name = layer_name
    node.texture = _texture(name)
    node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    node.centered = true
    node.position = Vector2(x + float(w) / 2.0, base_y)
    node.offset = Vector2(0.0, -float(h) / 2.0)
    world.add_child(node)
    return node
func _save(name: String, foot: Vector2, with_actor: bool) -> void:
    actor.visible = with_actor
    actor.position = foot
    await process_frame
    await RenderingServer.frame_post_draw
    var shot: Image = vp.get_texture().get_image()
    assert(shot.get_width() == W and shot.get_height() == H)
    var destination: String = ProjectSettings.globalize_path("res://out/" + name)
    var code: int = shot.save_png(destination)
    assert(code == OK)
    reports.append({"file":name,"size":[shot.get_width(),shot.get_height()],"foot":[foot.x,foot.y],"actor":with_actor,"godot_rendered":true})
func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://out"))
    vp = SubViewport.new()
    vp.name = "A24_Offscreen_Render_Target"
    vp.size = Vector2i(W, H)
    vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    vp.transparent_bg = false
    get_root().add_child(vp)
    world = Node2D.new()
    world.y_sort_enabled = true
    vp.add_child(world)
    var ground := Sprite2D.new()
    ground.name = "GROUND_NATIVE"
    ground.texture = _texture("A24_GROUND_544x416.png")
    ground.centered = false
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    ground.z_index = -5
    world.add_child(ground)
    var file_text: String = FileAccess.get_file_as_string("res://assets/A24_SCENE_MANIFEST.json")
    var manifest: Dictionary = JSON.parse_string(file_text)
    var obj_count: int = 0
    for object in manifest["objects"]:
        var filename: String
        if object["category"] == "forest_boundary":
            filename = "FS_BORDER_LEFT_95x416_RGBA.png" if object["id"] == "forest_left" else "FS_BORDER_RIGHT_70x416_RGBA.png"
        elif object["category"] == "rock":
            filename = "FS_ROCK_32_RGBA.png"
        elif object["category"] == "barrel":
            filename = "FS_BARREL_32_RGBA.png"
        else:
            filename = "FS_LAMP_32x64_RGBA.png"
        var node: Sprite2D = _add_sprite(filename,float(object["x"]),float(object["y"]),int(object["width"]),int(object["height"]),float(object["foot"][1]+1),String(object["id"]))
        obj_count += 1
    var av := Image.create(22, 38, false, Image.FORMAT_RGBA8)
    av.fill(Color(0,0,0,0))
    for yy in range(4, 13):
        for xx in range(6, 16):
            av.set_pixel(xx, yy, Color("#f0d2ae"))
    for yy in range(13, 31):
        for xx in range(4, 18):
            av.set_pixel(xx, yy, Color("#284d9f"))
    for yy in range(31, 38):
        for xx in range(6, 10):
            av.set_pixel(xx, yy, Color("#252d3b"))
        for xx in range(13, 17):
            av.set_pixel(xx, yy, Color("#252d3b"))
    actor = Sprite2D.new()
    actor.name = "TestActorStandIn_NotProductionFSActor"
    actor.texture = ImageTexture.create_from_image(av)
    actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    actor.offset = Vector2(0,-19)
    world.add_child(actor)
    await _save("A24_GODOT_NATIVE_SCENE_NO_ACTOR.png", Vector2(335,208), false)
    # Same x as existing FS lamp, behind / front test in y-sort by actor foot vs PAR prop foot.
    await _save("A24_GODOT_ACTOR_BEHIND_LAMP.png", Vector2(385,112), true)
    await _save("A24_GODOT_ACTOR_IN_FRONT_OF_LAMP.png", Vector2(385,169), true)
    await _save("A24_GODOT_ACTOR_ON_ROAD.png", Vector2(335,208), true)
    var qc: Dictionary = {"stage":"A24","renderer":"ACTUAL_GODOT_4_7_2","rendering":"native 544x416 SubViewport, y-sort for each original alpha object","sprites":obj_count,"actor_sprite":"temporary diagnostic placeholder","samples":reports,"Formal_Seal":"NO","VX":"NOT_RUN","full_art":"NOT_APPROVED"}
    var out := FileAccess.open("res://out/A24_GODOT_RENDER_PROOF.json", FileAccess.WRITE)
    out.store_string(JSON.stringify(qc,"\t"))
    out.close()
    print("A24_GODOT_NATIVE_RENDER_PASS image_count=",reports.size()," par_sprites=",obj_count)
    quit(0)
'''
(P/'a24_godot_render.gd').write_text(code,encoding='utf8')
print('A24_GODOT_ISOLATED_BUILD_PREPARED',len(list(AS.glob('*'))),'script_bytes',len(code))
