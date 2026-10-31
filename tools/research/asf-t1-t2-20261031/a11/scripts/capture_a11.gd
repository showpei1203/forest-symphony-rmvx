extends SceneTree

var instances:Array[AnimatedSprite2D]=[]
var labels:Array=[]
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var vp:=SubViewport.new()
	vp.size=Vector2i(1170,430)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg:=ColorRect.new()
	bg.color=Color8(239,243,247)
	bg.size=vp.size
	vp.add_child(bg)
	var s1:PackedScene=load("res://T1_forest_scout/engine_all/godot/t1-a11-layered-rig.tscn")
	var s2:PackedScene=load("res://T2_moss_antler/engine_all/godot/t2-a11-charge.tscn")
	if s1==null or s2==null:
		push_error("A10_SCENE_MISSING")
		quit(4)
		return
	var a1=["idle","walk","run","attack","hurt","jump"]
	var a2=["idle","walk","attack","hurt","faint"]
	for i in range(a1.size()):
		var a=s1.instantiate() as AnimatedSprite2D
		a.position=Vector2(95+i*190,175)
		a.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(a);a.play(a1[i])
		instances.append(a);labels.append(["T1",a1[i]])
		var lab=Label.new()
		lab.text="T1 / "+a1[i]
		lab.position=Vector2(53+i*190,211)
		lab.add_theme_color_override("font_color",Color("#263444"))
		vp.add_child(lab)
	for i in range(a2.size()):
		var a=s2.instantiate() as AnimatedSprite2D
		a.position=Vector2(95+i*205,352)
		a.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(a);a.play(a2[i])
		instances.append(a);labels.append(["T2",a2[i]])
		var lab=Label.new()
		lab.text="T2 / "+a2[i]
		lab.position=Vector2(53+i*205,389)
		lab.add_theme_color_override("font_color",Color("#263444"))
		vp.add_child(lab)
	var snaps=[]
	for k in range(2):
		await create_timer(0.17 if k==0 else 0.39).timeout
		await RenderingServer.frame_post_draw
		var im=vp.get_texture().get_image()
		var p="res://A11_NATIVE_GPU_"+("A" if k==0 else "B")+".png"
		var ret=im.save_png(p)
		var state=[]
		for j in range(instances.size()):
			var a=instances[j]
			state.append({"case":labels[j][0],"action":a.animation,"frame":a.frame,"x":a.position.x,"y":a.position.y})
		snaps.append({"file":p,"saved":ret==OK,"states":state})
	var evidence={"engine":Engine.get_version_info().get("string","unknown"),"render_driver":"OpenGL 3.3 native","viewport":[1170,430],"assets":11,"captures":snaps}
	var f=FileAccess.open("res://A11_NATIVE_GPU_QA.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(evidence,"  "))
	f.close()
	print("A11_REAL_GPU "+JSON.stringify({"captures":snaps.size(),"assets":instances.size(),"both_saved":snaps[0]["saved"]&&snaps[1]["saved"]}))
	quit(0 if snaps[0]["saved"]&&snaps[1]["saved"] else 5)