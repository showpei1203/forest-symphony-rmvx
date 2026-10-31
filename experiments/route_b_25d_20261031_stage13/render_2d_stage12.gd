extends SceneTree
# Native Godot 4.7.2 2D GPU capture directly from source sprites and source Ground.
# No reuse of the Pillow compiled Ground/PAR in capture. Source manifest owns geometry.
var vp:SubViewport
var ground_root:Node2D
var par_root:Node2D
var actor_root:Node2D
var screenshot_dir:String
var sid:String
var scene_data:Dictionary
const W=544
const H=416

func _make_sprite(image_path:String, xy:Vector2i,parent:Node2D) -> Sprite2D:
    var texture:Texture2D=load("res://"+image_path)
    assert(texture!=null,"No texture "+image_path)
    var node:=Sprite2D.new()
    node.centered=false
    node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    node.texture=texture
    node.position=Vector2(xy.x,xy.y)
    parent.add_child(node)
    return node

func _set_up()->void:
    var text_data:String=FileAccess.get_file_as_string("res://build/"+sid+"/SCENE_MANIFEST.json")
    scene_data=JSON.parse_string(text_data) as Dictionary
    assert(scene_data.size()>0)
    vp=SubViewport.new()
    vp.size=Vector2i(W,H)
    vp.disable_3d=true
    vp.transparent_bg=true
    vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(vp)
    ground_root=Node2D.new()
    par_root=Node2D.new()
    actor_root=Node2D.new()
    vp.add_child(ground_root)
    vp.add_child(actor_root)
    vp.add_child(par_root)
    var atlas_texture:=AtlasTexture.new()
    atlas_texture.atlas=load("res://source/ground_long.png")
    var roi: Array=scene_data["ground_original_roi"]
    atlas_texture.region=Rect2(roi[0],roi[1],W,H)
    var terrain:=Sprite2D.new()
    terrain.centered=false
    terrain.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    terrain.texture=atlas_texture
    ground_root.add_child(terrain)
    for entry in scene_data["objects"]:
        var obj:Dictionary=entry
        var xy:=Vector2i(int(obj["xy"][0]),int(obj["xy"][1]))
        var source_file:String=obj["source"]
        if obj["layer"]=="SPLIT_TREE32":
            var folder:String="parts/"+source_file.trim_suffix(".png")+"/"
            _make_sprite(folder+"BASE_32.png",xy,ground_root)
            _make_sprite(folder+"ROOT_DECAL_GROUND.png",xy,ground_root)
            _make_sprite(folder+"PAR_UPPER.png",xy,par_root)
        else:
            _make_sprite("source/"+source_file,xy,par_root)

func _make_test_actor(feet:Vector2i)->void:
    for child in actor_root.get_children():child.queue_free()
    var a:=Image.create(32,32,false,Image.FORMAT_RGBA8)
    a.fill(Color.TRANSPARENT)
    # flat 32x32 player silhouette, native source separate from map art
    a.fill_rect(Rect2i(9,14,17,13),Color("#316f9a"))
    a.fill_rect(Rect2i(12,5,12,12),Color("#d6a076"))
    a.fill_rect(Rect2i(9,4,15,6),Color("#624333"))
    a.fill_rect(Rect2i(11,25,6,6),Color("#333951"))
    a.fill_rect(Rect2i(20,25,6,6),Color("#333951"))
    var tex:=ImageTexture.create_from_image(a)
    var node:=Sprite2D.new()
    node.centered=false
    node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    node.texture=tex
    node.position=Vector2(feet.x-16,feet.y-31)
    actor_root.add_child(node)

func _capture(filename:String, g:bool,p:bool,actor:bool)->void:
    ground_root.visible=g
    par_root.visible=p
    actor_root.visible=actor
    await process_frame
    await RenderingServer.frame_post_draw
    var img:Image=vp.get_texture().get_image()
    img.save_png(screenshot_dir+"/"+filename+".png")
    print("CAPTURE ",sid," ",filename," ",img.get_width(),"x",img.get_height()," ",img.get_format())
    
func _initialize()->void:
    sid=OS.get_environment("FS_STAGE12_SCENE")
    if sid=="":
        sid="A_BLUE_COTTAGE"
    screenshot_dir="res://gpu/"+sid
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot_dir))
    call_deferred("_run")

func _run()->void:
    _set_up()
    await _capture("GROUND_GPU",true,false,false)
    await _capture("PAR_GPU",false,true,false)
    await _capture("FULL_GPU",true,true,false)
    for entry in scene_data["objects"]:
        if entry["layer"]=="SPLIT_TREE32":
            var foot:Array=entry["actor_foot"]
            for test in [-16,0,16]:
                _make_test_actor(Vector2i(int(foot[0]),int(foot[1])+test))
                await _capture(entry["id"]+"_ACTOR_"+str(test),true,true,true)
    print("STAGE12_GPU_RENDERED ",sid)
    quit()