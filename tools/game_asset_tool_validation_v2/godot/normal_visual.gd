extends Node
var view: SubViewport
var light: PointLight2D
var sprite: Sprite2D
var tex: CanvasTexture
func _ready() -> void:
    view = SubViewport.new()
    view.size = Vector2i(160, 160)
    view.disable_3d = true
    view.transparent_bg = false
    view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    add_child(view)
    var modulate := CanvasModulate.new()
    modulate.color = Color(0.35,0.35,0.35,1)
    view.add_child(modulate)
    sprite = Sprite2D.new()
    tex = CanvasTexture.new()
    tex.diffuse_texture = load("res://tree_A.png")
    tex.normal_texture = load("res://tree_A_n.png")
    sprite.texture = tex
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position = Vector2(80,80)
    view.add_child(sprite)
    light = PointLight2D.new()
    var gradient := Gradient.new()
    gradient.colors = PackedColorArray([Color.WHITE,Color(1,1,1,0)])
    var falloff := GradientTexture2D.new()
    falloff.gradient = gradient
    falloff.width = 160
    falloff.height = 160
    falloff.fill = GradientTexture2D.FILL_RADIAL
    light.texture = falloff
    light.energy = 2.5
    view.add_child(light)
    await _waitframes(15)
    await _capture("T07_normal_left.png", Vector2(38,80), true)
    await _capture("T07_normal_right.png", Vector2(122,80), true)
    await _capture("T07_without_normal_left.png", Vector2(38,80), false)
    print("T07_CAPTURE_DONE source=",tex.diffuse_texture.get_size()," normal=",load("res://tree_A_n.png").get_size())
    get_tree().quit()
func _waitframes(n:int) -> void:
    for i in range(n):
        await get_tree().process_frame
    await RenderingServer.frame_post_draw
func _capture(fname:String, pos:Vector2, use_normal:bool) -> void:
    light.position=pos
    tex.normal_texture = load("res://tree_A_n.png") if use_normal else null
    await _waitframes(10)
    var im=view.get_texture().get_image()
    var path="res://captures/"+fname
    var rc=im.save_png(path)
    print("T07_IMAGE ",path," ",im.get_width(),"x",im.get_height()," result=",rc)
