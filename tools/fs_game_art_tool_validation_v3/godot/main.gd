extends Node
var view:SubViewport
var light:PointLight2D
var sprite:Sprite2D
var texture:CanvasTexture
const FRAME_W:int=64
const FRAME_H:int=96
func _ready() -> void:
    view=SubViewport.new()
    view.size=Vector2i(224,224)
    view.disable_3d=true
    view.transparent_bg=false
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    add_child(view)
    var backdrop=CanvasModulate.new()
    backdrop.color=Color(0.26,0.26,0.26,1.0)
    view.add_child(backdrop)
    texture=CanvasTexture.new()
    texture.diffuse_texture=load("res://diffuse_6.png")
    texture.normal_texture=load("res://normal_6.png")
    sprite=Sprite2D.new()
    sprite.texture=texture
    sprite.centered=false
    sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position=Vector2(80,64)
    sprite.region_enabled=true
    sprite.region_rect=Rect2(0,0,FRAME_W,FRAME_H)
    view.add_child(sprite)
    light=PointLight2D.new()
    var grad=Gradient.new()
    grad.colors=PackedColorArray([Color.WHITE,Color(1,1,1,0)])
    var tex=GradientTexture2D.new()
    tex.gradient=grad
    tex.width=256
    tex.height=256
    tex.fill=GradientTexture2D.FILL_RADIAL
    light.texture=tex
    light.energy=2.8
    view.add_child(light)
    await _waitframes(14)
    await _snapshot("t13_frame0_normal_left.png",0,Vector2(60,95),true)
    await _snapshot("t13_frame0_normal_right.png",0,Vector2(162,95),true)
    await _snapshot("t13_frame0_flat_left.png",0,Vector2(60,95),false)
    await _snapshot("t13_frame5_normal_left.png",5,Vector2(60,95),true)
    print("T13_GODOT_NATIVE_GPU_DONE diffuse=",texture.diffuse_texture.get_size()," normal=",load("res://normal_6.png").get_size())
    get_tree().quit(0)
func _waitframes(count:int) -> void:
    for i in range(count):
        await get_tree().process_frame
    await RenderingServer.frame_post_draw
func _snapshot(filename:String,frame:int,light_pos:Vector2,use_normal:bool) -> void:
    sprite.region_rect=Rect2(frame*FRAME_W,0,FRAME_W,FRAME_H)
    texture.normal_texture=load("res://normal_6.png") if use_normal else null
    light.position=light_pos
    await _waitframes(12)
    var img=view.get_texture().get_image()
    var output="res://captures/"+filename
    var result=img.save_png(output)
    print("T13_GPU_CAPTURE frame=",frame," normal=",use_normal," file=",filename," size=",img.get_size()," rc=",result)
    assert(img.get_size()==Vector2i(224,224) and result==OK)
