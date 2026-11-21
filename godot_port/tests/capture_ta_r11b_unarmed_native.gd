extends SceneTree
# Official Godot 4.7.2 real 64px SubViewport GPU capture of authentic R11B PNG.
const FPS:int=60
const FRAMES:int=72
const TIMES:Array[float]=[0.0,0.14,0.23,0.31,0.38,0.45,0.52,0.63,0.72,0.83,0.94,1.06]
func _initialize()->void:
    call_deferred("_run")
func fail(message:String)->void:
    push_error("R11B_NATIVE_QA_FAIL " + message)
    quit(1)
func _run()->void:
    var dir:String=OS.get_environment("FS_R11B_NATIVE_QA")
    if dir.is_empty() or DirAccess.make_dir_recursive_absolute(dir)!=OK:
        fail("Missing FS_R11B_NATIVE_QA");return
    var art:Image=Image.new()
    if art.load("res://assets/R11B_ACTOR01_UNARMED_BODY_12x64.png")!=OK:
        fail("Source atlas missing");return
    if art.get_size()!=Vector2i(256,192):
        fail("Wrong source dims");return
    for name in ["R11B_WEAPON_EMPTY_ZERO_ALPHA.png","R11B_FX_EMPTY_ZERO_ALPHA.png"]:
        var blank:Image=Image.new()
        if blank.load("res://assets/"+name)!=OK or blank.get_size()!=Vector2i(256,192):
            fail("Missing alpha layer "+name);return
        for y in range(192):
            for x in range(256):
                if blank.get_pixel(x,y).a>0.0:
                    fail("Unexpected weapon/FX content "+name);return
    var tex:ImageTexture=ImageTexture.create_from_image(art)
    var vp:SubViewport=SubViewport.new()
    vp.size=Vector2i(64,64)
    vp.transparent_bg=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    var spr:Sprite2D=Sprite2D.new()
    spr.texture=tex
    spr.region_enabled=true
    spr.region_rect=Rect2(0,0,64,64)
    spr.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    spr.position=Vector2(32,32)
    vp.add_child(spr)
    var visited:Array[int]=[]
    var timeline:Array[Dictionary]=[]
    var contact_count:int=0
    var previous:int=-1
    for tick in range(FRAMES+1):
        var elapsed:float=float(tick)/float(FPS)
        var frame:int=0
        for idx in range(TIMES.size()):
            if elapsed>=TIMES[idx]:
                frame=idx
        spr.region_rect=Rect2((frame%4)*64,(frame/4)*64,64,64)
        if frame!=previous:
            visited.append(frame)
            if frame==7:contact_count+=1
            previous=frame
        await process_frame
        await RenderingServer.frame_post_draw
        var captured:Image=vp.get_texture().get_image()
        if captured==null or captured.get_size()!=Vector2i(64,64):
            fail("no GPU native frame tick "+str(tick));return
        if captured.save_png(dir.path_join("%03d.png"%tick))!=OK:
            fail("frame save failure "+str(tick));return
        timeline.append({"tick":tick,"seconds":elapsed,"frame":frame})
    if visited!=[0,1,2,3,4,5,6,7,8,9,10,11] or contact_count!=1:
        fail("motion frame order or contact "+str(visited)+" "+str(contact_count));return
    var info:Dictionary={"engine":Engine.get_version_info(),"frames":FRAMES+1,"fps":FPS,"visited":visited,
        "contact_events":contact_count,"contact_target_local_seconds":0.63,
        "weapon_pixels":0,"fx_pixels":0,
        "source":"real owner-approved Actor01 + LPC source PNGs",
        "presenter":"isolated SubViewport only; does not test live FSBattle",
        "art_gate":"HOLD — source-front/right 3/4 composite not final artist redraw",
        "timeline":timeline}
    var output:FileAccess=FileAccess.open(dir.path_join("R11B_NATIVE_QA.json"),FileAccess.WRITE)
    if output==null:fail("report file unavailable");return
    output.store_string(JSON.stringify(info,"  "))
    output.close()
    print("FS_TA_R11B_GODOT472_REAL_SOURCE_NATIVE_PASS 73/73, 12 motion poses, 0 weapon/fx")
    quit(0)
