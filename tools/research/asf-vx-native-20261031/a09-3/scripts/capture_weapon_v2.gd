extends SceneTree

var names: Array = ["喬伊普攻武器","喬伊普攻武器2","正常武器待機"]
var poses: Array = ["p01","p03","p05"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var f = FileAccess.open("res://source_formula_audit.json",FileAccess.READ)
	if f == null: 
		push_error("MISSING_NATIVE_WEAPON_FORMULA_AUTHORITY")
		quit(9)
		return
	var model = JSON.parse_string(f.get_as_text())
	var configs: Dictionary = {}
	for entry in model["weapon_results"]:
		configs[entry["weapon"]] = entry
	var scene: PackedScene = load("res://fs-joe-pose7.tscn")
	var icon: Texture2D = load("res://weapon_icon_2.png")
	if scene == null or icon == null:
		push_error("MISSING_PRIVATE_TEST_ASSETS")
		quit(9)
		return
	var vp := SubViewport.new()
	vp.size=Vector2i(1000,490)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var bg:=ColorRect.new()
	bg.size=vp.size
	bg.color=Color("#edf2f5")
	vp.add_child(bg)
	var evidence: Array=[]
	for row in range(3):
		var o: Dictionary=configs[names[row]]
		var v: Dictionary=o["native_values"]
		for col in range(4):
			var smp: Dictionary=o["4_tick_inferred_samples"][col]
			var basepos=Vector2(75+col*245,85+row*152)
			var actor: AnimatedSprite2D=scene.instantiate()
			actor.position=basepos
			actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			actor.scale=Vector2(2.3,2.3)
			actor.z_index=5
			vp.add_child(actor)
			actor.play(poses[row])
			actor.pause()
			var weapon:=Sprite2D.new()
			weapon.texture=icon
			weapon.centered=false
			var pivot=o["effective_pivot_24x24"]
			weapon.offset=Vector2(-float(pivot[0]),-float(pivot[1]))
			weapon.flip_h=bool(o["actual_mirror_when_base_unmirrored"])
			weapon.z_index=10 if bool(v["za_front"]) else 2
			weapon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			weapon.scale=Vector2(2.3,2.3)
			weapon.position=basepos+Vector2(int(v["pos_offset_x"])+int(smp["move_x_inferred"]),int(v["pos_offset_y"])+int(smp["move_y_inferred"]))*2.3
			weapon.rotation_degrees=float(smp["angle_godot_candidate"])
			vp.add_child(weapon)
			var lbl=Label.new()
			lbl.text="p%s t%d G:%+.0f" % [poses[row].substr(1,2),col,weapon.rotation_degrees]
			lbl.position=Vector2(basepos.x-63,basepos.y+52)
			lbl.add_theme_color_override("font_color",Color("#203047"))
			vp.add_child(lbl)
			evidence.append({"pose":poses[row],"tick":col,"Godot_rotation":weapon.rotation_degrees,"pivot_x":pivot[0],"pivot_y":pivot[1],"mirror":weapon.flip_h,"front":weapon.z_index>actor.z_index,"offset_delta_x":weapon.position.x-basepos.x,"offset_delta_y":weapon.position.y-basepos.y})
	await create_timer(0.26).timeout
	await RenderingServer.frame_post_draw
	var frame=vp.get_texture().get_image()
	var err=frame.save_png("res://A09_3_WEAPON_FORMULA_V2_CANDIDATE.png")
	var f2=FileAccess.open("res://A09_3_WEAPON_FORMULA_V2_LOG.json",FileAccess.WRITE)
	f2.store_string(JSON.stringify({"status":"candidate_not_VX_parity","draw_ok":err==OK,"samples":evidence},"  "))
	f2.close()
	print("A093_WEAPON_FORMULA_V2 ",JSON.stringify({"draw_ok":err==OK,"samples":evidence.size()}))
	quit(0 if err==OK else 7)