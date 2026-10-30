extends SceneTree

const LABELS := ["defend", "attack", "summon", "attack2", "cast", "standby", "advance"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1050, 365)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var bg := ColorRect.new()
	bg.color = Color("#eef2f5")
	bg.size = Vector2(1050,365)
	viewport.add_child(bg)
	var source: PackedScene = load("res://fs-joe-pose7.tscn")
	if source == null:
		push_error("FAIL: missing source scene")
		quit(2)
		return
	for i in range(7):
		for row in range(2):
			var actor: AnimatedSprite2D = source.instantiate()
			actor.position = Vector2(77 + i*148, 98 + row*178)
			actor.scale = Vector2(1,1) if row == 0 else Vector2(3,3)
			actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			viewport.add_child(actor)
			actor.play("p%02d" % i)
		var title = Label.new()
		title.text = "p%02d: %s" % [i, LABELS[i]]
		title.position = Vector2(18+i*148,158)
		title.add_theme_color_override("font_color",Color("#263849"))
		viewport.add_child(title)
	await create_timer(0.12).timeout
	await RenderingServer.frame_post_draw
	var a = viewport.get_texture().get_image()
	var ea = a.save_png("res://A09_7POSE_GPU_A.png")
	await create_timer(0.29).timeout
	await RenderingServer.frame_post_draw
	var b = viewport.get_texture().get_image()
	var eb = b.save_png("res://A09_7POSE_GPU_B.png")
	print("A09_POSES_GPU:",JSON.stringify({"size":a.get_size(),"names":LABELS,"a_ok":ea==OK,"b_ok":eb==OK}))
	quit(0 if ea==OK and eb==OK else 3)