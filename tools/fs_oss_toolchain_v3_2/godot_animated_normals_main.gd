extends Node
var view: SubViewport
var sprite: Sprite2D
var canvas_tex: CanvasTexture
var light: PointLight2D

func _ready() -> void:
    view=SubViewport.new()
    view.size=Vector2i(160,160)
    view.disable_3d=true
    view.transparent_bg=false
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    add_child(view)
    var ambient=CanvasModulate.new()
    ambient.color=Color(0.34,0.34,0.34)
    view.add_child(ambient)
    sprite=Sprite2D.new()
    canvas_tex=CanvasTexture.new()
    sprite.texture=canvas_tex
    sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.position=Vector2(80,80)
    view.add_child(sprite)
    light=PointLight2D.new()
    var gradient=Gradient.new()
    gradient.colors=PackedColorArray([Color.WHITE,Color(1.0,1.0,1.0,0.0)])
    var falloff=GradientTexture2D.new()
    falloff.gradient=gradient
    falloff.width=160
    falloff.height=160
    falloff.fill=GradientTexture2D.FILL_RADIAL
    light.texture=falloff
    light.energy=2.6
    light.position=Vector2(40,64)
    view.add_child(light)
    var json=JSON.parse_string(FileAccess.get_file_as_string("res://timing_manifest.json"))
    assert(json is Dictionary)
    var durations=json["frame_duration_ms"]
    assert(durations.size()==6)
    var tags=json["frame_tags"]
    assert(tags.size()==1 and tags[0]["from"]==0 and tags[0]["to"]==5)
    var diffuse_atlas:Texture2D=load("res://diffuse_atlas.png")
    var normal_atlas:Texture2D=load("res://normal_atlas.png")
    assert(diffuse_atlas.get_size()==Vector2(384,96))
    assert(normal_atlas.get_size()==Vector2(384,96))
    await get_tree().create_timer(0.12).timeout
    var measured=[]
    var ok:bool=true
    for i in range(6):
        var tex:Texture2D=load("res://frame_%02d.png" % i)
        var norm:Texture2D=load("res://frame_%02d_n.png" % i)
        var new_canvas=CanvasTexture.new()
        new_canvas.diffuse_texture=tex
        new_canvas.normal_texture=norm
        canvas_tex=new_canvas
        sprite.texture=canvas_tex
        await get_tree().process_frame
        await RenderingServer.frame_post_draw
        var capture=view.get_texture().get_image()
        var path="res://captures/T16_frame_%02d.png" % i
        var rc=capture.save_png(path)
        ok = ok and rc==OK and capture.get_size()==Vector2i(160,160)
        var started=Time.get_ticks_usec()
        await get_tree().create_timer(float(durations[i])/1000.0).timeout
        measured.append(int(round((Time.get_ticks_usec()-started)/1000.0)))
        ok = ok and abs(measured[i]-int(durations[i]))<=35
        print("T16_FRAME ",i," metadata_ms=",durations[i]," elapsed_ms=",measured[i]," image=",path," save_rc=",rc)
    print("T16_NATIVE_GPU_ANIMATION_PASS" if ok else "T16_NATIVE_GPU_ANIMATION_FAIL")
    get_tree().quit(0 if ok else 2)
