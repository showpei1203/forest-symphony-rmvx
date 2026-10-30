extends SceneTree

var targets: Array = ["喬伊普攻武器", "喬伊普攻武器2", "正常武器待機"]
var poses: Array = ["p01", "p03", "p05"]
var angles: Array = [0.0, 0.25, 0.5, 0.75, 1.0]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var path = "res://joe_weapon_authority.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("NO_WPN_AUTHORITY")
		quit(5)
		return
	var data = JSON.parse_string(file.get_as_text())
	var entries = data["weapon_table"]
	var scene: PackedScene = load("res://fs-joe-pose7.tscn")
	var icon: Texture2D = load("res://weapon_icon_2.png")
	if icon == null or scene == null:
		push_error("MISSING_PRIVATE_ASSETS")
		quit(6)
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1050, 500)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var bg := ColorRect.new()
	bg.size = viewport.size
	bg.color = Color("#edf2f5")
	viewport.add_child(bg)
	var observed: Array = []
	for row in range(3):
		var wdef: Dictionary = entries[targets[row]]
		for k in range(5):
			var basepos := Vector2(75 + k*190, 80 + row*150)
			var actor: AnimatedSprite2D = scene.instantiate()
			actor.position = basepos
			actor.scale = Vector2(2.5, 2.5)
			actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			actor.z_index = 5
			viewport.add_child(actor)
			actor.play(poses[row])
			actor.pause()
			var w := Sprite2D.new()
			w.texture = icon
			w.centered = false
			w.offset = Vector2(-24, -24) if int(wdef["origin_id"]) == 4 else Vector2(-12, -12)
			w.position = basepos + Vector2(int(wdef["xa"])+int(wdef["pos_offset_x"]), int(wdef["ya"])+int(wdef["pos_offset_y"])) * 2.5
			w.scale = Vector2(2.5*float(wdef["scale_x"]),2.5*float(wdef["scale_y"]))
			w.flip_h = bool(wdef["invert_horizontal"])
			w.z_index = 10 if bool(wdef["za_front"]) else 2
			var t = angles[k]
			var native_deg = lerp(float(wdef["angle_start_rgss"]),float(wdef["angle_end_rgss"]),t)
			w.rotation_degrees = -native_deg
			w.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			viewport.add_child(w)
			var label = Label.new()
			label.text = "p%s  %3d%%   G:%+.0f" % [poses[row].substr(1,2),int(round(t*100.0)),w.rotation_degrees]
			label.position = Vector2(basepos.x-60,basepos.y+57)
			label.add_theme_color_override("font_color",Color("#203047"))
			viewport.add_child(label)
			observed.append({"weapon":targets[row],"t":t,"angle_expected":-native_deg,"angle_rendered":w.rotation_degrees,"x_expected":w.position.x,"x_rendered":w.position.x,"mirrored":w.flip_h,"front":w.z_index>actor.z_index})
	await create_timer(0.30).timeout
	await RenderingServer.frame_post_draw
	var screenshot = viewport.get_texture().get_image()
	var e = screenshot.save_png("res://A09_3_WEAPON_AUTHORITY_CANDIDATE.png")
	var output={"capture_ok":e==OK,"tested":observed.size(),"engine":Engine.get_version_info().get("string","unknown"),"samples":observed}
	var jsonfile=FileAccess.open("res://A09_3_WEAPON_RENDER.json", FileAccess.WRITE)
	jsonfile.store_string(JSON.stringify(output,"  "))
	jsonfile.close()
	print("A093_GODOT_WEAPON_CANDIDATE ",JSON.stringify({"ok":e==OK,"samples":observed.size()}))
	quit(0 if e==OK else 7)