extends Node
var view: SubViewport
var tex: CanvasTexture
var sprite: Sprite2D
var light: PointLight2D
var normal_cli: Texture2D
var normal_laigter: Texture2D
func _ready() -> void:
    view=SubViewport.new()
    view.size=Vector2i(160,160)
    view.disable_3d=true
    view.transparent_bg=false
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    add_child(view)
    var ambient=CanvasModulate.new()
    ambient.color=Color(0.3,0.3,0.3,1.0)
    view.add_child(ambient)
    normal_cli=load("res://tree_cli_n.png")
    normal_laigter=load("res://tree_laigter_n.png")
    tex=CanvasTexture.new()
    tex.diffuse_texture=load("res://tree.png")
    tex.normal_texture=normal_cli
    sprite=Sprite2D.new()
    sprite.texture=tex
    sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position=Vector2(80,80)
    view.add_child(sprite)
    light=PointLight2D.new()
    var gradient=Gradient.new()
    gradient.colors=PackedColorArray([Color.WHITE,Color(1,1,1,0)])
    var falloff=GradientTexture2D.new()
    falloff.gradient=gradient
    falloff.width=160
    falloff.height=160
    falloff.fill=GradientTexture2D.FILL_RADIAL
    light.texture=falloff
    light.energy=2.5
    view.add_child(light)
    await _wait_frames(15)
    await _capture("T13_cli_left.png",Vector2(32,80),normal_cli)
    await _capture("T13_cli_right.png",Vector2(128,80),normal_cli)
    await _capture("T13_laigter_left.png",Vector2(32,80),normal_laigter)
    await _capture("T13_laigter_right.png",Vector2(128,80),normal_laigter)
    await _capture("T13_flat_left.png",Vector2(32,80),null)
    print("T13_B0_NORMAL_GPU_CAPTURE_DONE engine=OpenGL tree64x96 five_views")
    get_tree().quit()
func _wait_frames(count:int) -> void:
    for i in range(count):
        await get_tree().process_frame
    await RenderingServer.frame_post_draw
func _capture(name:String, location:Vector2, normal:Texture2D) -> void:
    tex.normal_texture=normal
    light.position=location
    await _wait_frames(10)
    var pic=view.get_texture().get_image()
    var rc=pic.save_png("res://captures/"+name)
    print("T13_FRAME ",name," rc=",rc," size=",pic.get_size())
