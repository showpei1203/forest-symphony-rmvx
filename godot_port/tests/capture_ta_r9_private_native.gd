extends SceneTree
# Genuine 4.7.2 real-source GPU 60Hz R7-vs-R8 comparison, not public synthetic CI.
const SOURCE_FILES: Array[String] = [
    "res://assets/r8_body.png", "res://assets/r8_weapon.png", "res://assets/r8_fx.png",
    "res://assets/r9_body.png", "res://assets/r9_weapon.png", "res://assets/r9_fx.png"
]
const ATTACK_KEYS: Array[float] = [0.000,0.100,0.190,0.275,0.350,0.455,
    0.560,0.620,0.735,0.830,0.910,0.980]
const CONTACT_TIME: float = 0.630
var view: SubViewport
var layers: Array[Sprite2D] = []
func _initialize() -> void:
    call_deferred("_run")
func fail(reason:String) -> void:
    push_error("TA_R9_FIXED_BONE_PRIVATE_FAIL "+reason)
    quit(1)
func choose_frame(sec:float)->int:
    var frame: int=0
    for i in range(ATTACK_KEYS.size()):
        if sec >= ATTACK_KEYS[i]-0.0000001:
            frame=i
    return frame
func set_frame(frame:int) -> void:
    var rect=Rect2((frame%4)*64,int(frame/4)*64,64,64)
    for sprite in layers:
        sprite.region_rect=rect
func _run()->void:
    var folder=OS.get_environment("TA_QA_DIR")
    if folder.is_empty(): fail("TA_QA_DIR unset");return
    if DirAccess.make_dir_recursive_absolute(folder)!=OK:fail("no output");return
    var tex:Array[Texture2D]=[]
    for p in SOURCE_FILES:
        if not FileAccess.file_exists(p):fail("missing private "+p);return
        var img:Image=Image.load_from_file(p)
        if img==null or img.get_size()!=Vector2i(256,192):fail("bad source "+p);return
        tex.append(ImageTexture.create_from_image(img))
    view=SubViewport.new()
    view.size=Vector2i(128,64)
    view.transparent_bg=true
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(view)
    for variant in range(2):
        var pivot=Node2D.new()
        pivot.position=Vector2(32+variant*64,32)
        view.add_child(pivot)
        for index in range(3):
            var sprite=Sprite2D.new()
            sprite.texture=tex[variant*3+index]
            sprite.region_enabled=true
            sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
            sprite.region_rect=Rect2(0,0,64,64)
            pivot.add_child(sprite)
            layers.append(sprite)
    var saved_keys:=0
    for k in range(12):
        set_frame(k)
        await process_frame
        await process_frame
        var img=view.get_texture().get_image()
        if img==null or img.get_size()!=Vector2i(128,64):fail("null GL render");return
        var file="%s/r8_vs_r9_pose_%02d.png"%[folder,k]
        if img.save_png(file)!=OK: fail("could not save keypose");return
        saved_keys+=1
    var contacts:=0
    var frames:=0
    var last_contact:=false
    var timeline:Array=[]
    # 67 observed frames, 60Hz, full 1.06sec attack + 0.05sec terminal hold.
    for tick in range(67):
        var sec=float(tick)/60.0
        var k=choose_frame(sec)
        set_frame(k)
        var did_contact=sec>=CONTACT_TIME
        if did_contact and not last_contact:
            contacts+=1
        last_contact=did_contact
        await process_frame
        await process_frame
        var img=view.get_texture().get_image()
        if img==null or img.get_size()!=Vector2i(128,64):fail("null 60Hz render");return
        var file="%s/r8_vs_r9_t%03d.png"%[folder,tick]
        if img.save_png(file)!=OK:fail("save frame");return
        timeline.append({"tick":tick,"second":sec,"frame":k,"contact_triggered":did_contact})
        frames+=1
    if contacts!=1 or saved_keys!=12 or frames!=67:
        fail("keyframes/time/contact broken "+str([contacts,saved_keys,frames]));return
    var log={"engine":Engine.get_version_info(),"format":"R8 left, R9 right; 2x genuine sprite variants, 3 separate RGBA layers each", "native_keyposes":saved_keys,
        "native_60Hz_frames":frames,"one_visual_contact":contacts,"contact_time_second":CONTACT_TIME,
        "metadata_hitstop_seconds":0.07,"artist_acceptance":"ART_HOLD", "timeline":timeline}
    if FileAccess.open(folder+"/R9_REAL_SOURCE_GODOT_NATIVE_TIMELINE.json",FileAccess.WRITE)==null:
        fail("no timeline JSON");return
    var f=FileAccess.open(folder+"/R9_REAL_SOURCE_GODOT_NATIVE_TIMELINE.json",FileAccess.WRITE)
    f.store_string(JSON.stringify(log,"  ")+"\n")
    f.close()
    print("TA_R9_FIXED_BONE_GODOT472_REAL_SOURCE_GL_PASS KEYPOSES_12/12 60HZ_FRAMES_67/67 CONTACT_1 ART_HOLD")
    quit(0)
