extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(900, 260)
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var bg := ColorRect.new()
	bg.color = Color("#e9edf2")
	bg.size = Vector2(900, 260)
	viewport.add_child(bg)
	var names := ["idle", "walk", "run", "attack", "jump", "hurt"]
	var packed = load("res://fs-hero-six.tscn")
	if packed == null:
		printerr("SIXACTION:FAIL cannot load")
		quit(2)
		return
	for i in range(names.size()):
		var anim: AnimatedSprite2D = packed.instantiate()
		anim.position = Vector2(88 + i * 145, 193)
		anim.scale = Vector2(1.65, 1.65)
		viewport.add_child(anim)
		anim.play(names[i])
		var label = Label.new()
		label.text = names[i]
		label.position = Vector2(51 + i * 145, 220)
		label.add_theme_color_override("font_color", Color("#17283b"))
		viewport.add_child(label)
	await create_timer(0.24).timeout
	await RenderingServer.frame_post_draw
	var img1 = viewport.get_texture().get_image()
	var err1 = img1.save_png("res://six-actions-A-v2.png")
	await create_timer(0.29).timeout
	await RenderingServer.frame_post_draw
	var img2 = viewport.get_texture().get_image()
	var err2 = img2.save_png("res://six-actions-B-v2.png")
	print("SIXACTION_CAPTURE: frameA=",err1," frameB=",err2," size=",img2.get_width(),"x",img2.get_height()," names=",names)
	quit(0 if err1 == OK and err2 == OK else 3)
