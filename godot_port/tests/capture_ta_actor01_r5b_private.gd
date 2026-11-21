extends SceneTree
# Owner-private Godot 4.7.2 continuous 60Hz QA. Not real gameplay FSBattle.
# Stage six licensed 256x192 PNGs in res://assets/ta_actor01/; never commit.
const NAMES=["run_body.png","run_weapon.png","run_fx.png",
             "attack_body.png","attack_weapon.png","attack_fx.png"]
const KEYS=[0.000,0.100,0.190,0.275,0.350,0.455,0.560,0.620,
            0.735,0.830,0.910,0.980]
func _initialize()->void:
    call_deferred("_run")
func _fail(message:String)->void:
    push_error("TA_R5B_PRIVATE_NATIVE "+message)
    quit(1)
func _run()->void:
    var output=OS.get_environment("TA_QA_DIR")
    if output.is_empty() or DirAccess.make_dir_recursive_absolute(output)!=OK:
        _fail("TA_QA_DIR must be an absolute writable path")
        return
    var textures:Array[Texture2D]=[]
    for key in NAMES:
        var path="res://assets/ta_actor01/"+key
        if not FileAccess.file_exists(path):
            _fail("Missing real source: "+key)
            return
        var img=Image.load_from_file(path)
        if img==null or img.get_size()!=Vector2i(256,192):
            _fail("Invalid private 256x192 atlas: "+key)
            return
        textures.append(ImageTexture.create_from_image(img))
    var view=SubViewport.new()
    view.transparent_bg=true
    view.size=Vector2i(64,64)
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    var holder=Node2D.new()
    holder.position=Vector2(32,32)
    view.add_child(holder)
    var layers:Array[Sprite2D]=[]
    for label in ["Body","Weapon","FX"]:
        var sprite=Sprite2D.new()
        sprite.name=label
        sprite.centered=true
        sprite.region_enabled=true
        sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        holder.add_child(sprite)
        layers.append(sprite)
    var records:Array=[]
    for tick in range(181):
        var second=float(tick)/60.0
        var attacking=second>=1.92
        var frame:int
        if attacking:
            var local=second-1.92
            frame=0
            for k in range(12):
                if local>=KEYS[k]:
                    frame=k
        else:
            frame=int(floor(second/0.080))%12
        var rect=Rect2(float(frame%4*64),float(int(frame/4)*64),64,64)
        for i in range(3):
            layers[i].texture=textures[i+(3 if attacking else 0)]
            layers[i].region_rect=rect
        await process_frame
        await process_frame
        var image=view.get_texture().get_image()
        if image==null or image.get_size()!=Vector2i(64,64):
            _fail("GPU readback failure at tick "+str(tick))
            return
        var filename="%s/%03d_%s%02d.png"%[output,tick,"a" if attacking else "r",frame]
        if image.save_png(filename)!=OK:
            _fail("Could not save frame "+str(tick))
            return
        records.append({"tick":tick,"time_sec":second,
            "motion":"attack" if attacking else "run","frame":frame})
    var timeline=FileAccess.open(output+"/timeline.json",FileAccess.WRITE)
    if timeline==null:
        _fail("Could not save timeline")
        return
    timeline.store_string(JSON.stringify({"fps":60,"frames":records},"  "))
    timeline.close()
    print("TA_R5B_OWNER_PRIVATE_181_NATIVE_GPU_FRAMES_PASS; ART_HOLD")
    quit(0)
