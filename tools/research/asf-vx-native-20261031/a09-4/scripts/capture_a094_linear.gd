extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var f = FileAccess.open("res://native_weapon_12_samples.json", FileAccess.READ)
	if f == null:
		push_error("NO_NATIVE_RUNTIME_JSON")
		quit(4)
		return
	var obj: Dictionary = JSON.parse_string(f.get_as_text())
	var scene: PackedScene = load("res://fs-joe-pose7.tscn")
	var icon: Texture2D = load("res://weapon_icon_548.png")
	if icon == null or scene == null:
		push_error("MISSING_PRIVATE_SOURCE_ASSETS")
		quit(5)
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(360,315)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	root.add_child(viewport)
	var bg := ColorRect.new()
	bg.size = Vector2(360,315)
	bg.color = Color8(237,242,246)
	viewport.add_child(bg)
	var traces: Array=[]
	for sample in obj["samples"]:
		var i = int(sample["profile"])
		var tick = int(sample["tick"])
		var tile=Vector2(tick*90,i*105)
		var basepos=tile+Vector2(45,55)
		var actor: AnimatedSprite2D = scene.instantiate()
		actor.position=basepos
		actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		viewport.add_child(actor)
		actor.z_index=5
		actor.play(obj["characters"][i])
		actor.pause()
		actor.frame=1
		var w:=Sprite2D.new()
		w.texture=icon
		w.centered=false
		w.offset=Vector2(-float(sample["ox"]),-float(sample["oy"]))
		w.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
		w.flip_h=bool(sample["flip"])
		w.position=basepos+Vector2(float(sample["x"])-float(obj["origin_x"][i]),float(sample["y"])-float(obj["origin_y"]))
		w.z_index=10 if float(sample["z"])>2000.0 else 2
		w.rotation_degrees=-float(sample["angle_rgss"])
		viewport.add_child(w)
		traces.append({"profile":i,"tick":tick,"native_x":sample["x"],"native_angle":sample["angle_rgss"],"godot_rotation_degrees":w.rotation_degrees,"source_frame":1,"mirror":w.flip_h,"ox":sample["ox"],"oy":sample["oy"],"front":w.z_index>5})
	await create_timer(0.30).timeout
	await RenderingServer.frame_post_draw
	var image=viewport.get_texture().get_image()
	var e=image.save_png("res://A094_GODOT_12_TILES_LINEAR.png")
	var logfile=FileAccess.open("res://A094_GODOT_12_LINEAR_LOG.json",FileAccess.WRITE)
	logfile.store_string(JSON.stringify({"rendered":e==OK,"samples":traces},"  "))
	logfile.close()
	print("A094_GODOT_NATIVETRACE ",JSON.stringify({"rendered":e==OK,"count":traces.size()}))
	quit(0 if e==OK else 7)
