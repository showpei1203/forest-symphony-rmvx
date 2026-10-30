extends SceneTree

var actors: Array[AnimatedSprite2D] = []
var names: Array = []
var slots: Array = []
var bg_color := Color8(237,242,246)

func _initialize() -> void:
	call_deferred("_run")

func capture(vp:SubViewport,letter:String) -> Dictionary:
	await RenderingServer.frame_post_draw
	var img = vp.get_texture().get_image()
	var e = img.save_png("res://R2_NATIVE_GODOT_"+letter+".png")
	var state=[]
	for a in actors:
		state.append({"clip":a.animation,"frame":a.frame,"playing":a.is_playing(),"pos_x":a.position.x,"pos_y":a.position.y})
	return {"saved":e==OK,"capture":letter,"state":state}

func _run() -> void:
	var vp:=SubViewport.new()
	vp.size=Vector2i(870,360)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg:=ColorRect.new()
	bg.color=bg_color
	bg.size=vp.size
	vp.add_child(bg)
	var hero=load("res://T1_hero/r2/engine_all/godot/forest-scout-r2.tscn") as PackedScene
	var mob=load("res://T2_monster/r2/engine_all/godot/sproutling-r2.tscn") as PackedScene
	if hero==null or mob==null:
		push_error("PACKED_ASF_T1_T2_SCENE_MISSING")
		quit(9)
		return
	var t1=["idle","walk","run","attack","hurt","jump"]
	var t2=["idle","walk","attack","hurt","faint"]
	for i in range(t1.size()):
		var s=hero.instantiate() as AnimatedSprite2D
		s.position=Vector2(60+i*130,100)
		s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(s)
		s.play(t1[i])
		actors.append(s)
		var lb=Label.new()
		lb.text="T1 "+t1[i]
		lb.position=Vector2(30+i*130,137)
		lb.add_theme_color_override("font_color",Color("#263449"))
		vp.add_child(lb)
	for i in range(t2.size()):
		var s=mob.instantiate() as AnimatedSprite2D
		s.position=Vector2(62+i*155,275)
		s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(s)
		s.play(t2[i])
		actors.append(s)
		var lb=Label.new()
		lb.text="T2 "+t2[i]
		lb.position=Vector2(35+i*155,303)
		lb.add_theme_color_override("font_color",Color("#263449"))
		vp.add_child(lb)
	await create_timer(0.11).timeout
	var a=await capture(vp,"A")
	await create_timer(0.35).timeout
	var b=await capture(vp,"B")
	var result={"render":"native Godot 4.7.2 OpenGL, no screen mockup","engine":Engine.get_version_info().get("string","unknown"),"size":[870,360],"t1_count":t1.size(),"t2_count":t2.size(),"captures":[a,b]}
	var f=FileAccess.open("res://R2_GODOT_NATIVE_EVIDENCE.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(result,"  "))
	f.close()
	print("ASF_R2_NATIVE: ",JSON.stringify({"actor_count":actors.size(),"captures":2,"saved":a["saved"] and b["saved"]}))
	quit(0 if a["saved"] and b["saved"] else 10)