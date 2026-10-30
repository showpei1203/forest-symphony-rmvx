extends SceneTree

const DIRS := ["down", "left", "right", "up"]
const ANGLES := [75.0, 15.0, -45.0]
const RES := "res://fs-native-4dir.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(560, 340)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.transparent_bg = false
	root.add_child(vp)
	var bg := ColorRect.new()
	bg.color = Color("#edf2f6")
	bg.size = Vector2(560, 340)
	vp.add_child(bg)
	var packed: PackedScene = load(RES)
	var weapon_texture: Texture2D = load("res://weapon_icon_2.png")
	if packed == null or weapon_texture == null:
		printerr("FAILED TO LOAD AUTHORED FS TEST ASSETS")
		quit(2)
		return
	var actors: Array[AnimatedSprite2D] = []
	for i in range(4):
		var actor: AnimatedSprite2D = packed.instantiate()
		actor.position = Vector2(70+ i*130, 105)
		actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(actor)
		actor.play("walk_"+DIRS[i])
		actors.append(actor)
		var title := Label.new()
		title.text = DIRS[i]
		title.position=Vector2(49 + i*130, 140)
		title.add_theme_color_override("font_color",Color("#222b39"))
		vp.add_child(title)
	for j in range(3):
		var actor: AnimatedSprite2D = packed.instantiate()
		actor.position=Vector2(130+j*150, 251)
		actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(actor)
		actor.play("idle_down")
		var w:=Sprite2D.new()
		w.texture=weapon_texture
		w.centered=false
		w.offset=Vector2(-24,-24)
		w.position=actor.position
		w.rotation_degrees=ANGLES[j]
		w.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		w.z_index=2
		vp.add_child(w)
		var label:=Label.new()
		label.text="RGSS "+str(-ANGLES[j])+" / G "+str(ANGLES[j])
		label.position=Vector2(68+j*150, 285)
		label.add_theme_color_override("font_color",Color("#222b39"))
		vp.add_child(label)
	await create_timer(0.11).timeout
	await RenderingServer.frame_post_draw
	var a = vp.get_texture().get_image()
	var ae = a.save_png("res://fs_actor_vx_gpu_A.png")
	await create_timer(0.34).timeout
	await RenderingServer.frame_post_draw
	var b = vp.get_texture().get_image()
	var be = b.save_png("res://fs_actor_vx_gpu_B.png")
	var result={
		"texture_frame_size":Vector2i(32,32),
		"ground_origin":Vector2i(16,21),
		"angles":ANGLES,
		"native_Godot_Version":Engine.get_version_info().get("string","unknown"),
		"capture_A_ok":ae==OK,"capture_B_ok":be==OK,
		"directions":DIRS
	}
	print("FS_VX_NATIVE_CAPTURES: "+JSON.stringify(result))
	quit(0 if ae==OK and be==OK else 3)