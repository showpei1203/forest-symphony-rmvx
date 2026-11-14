extends SceneTree

const BG := Color(0.15, 0.19, 0.25, 1.0)
var qa_viewport: SubViewport

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    qa_viewport = SubViewport.new()
    qa_viewport.size = Vector2i(1152, 1008)
    qa_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    qa_viewport.transparent_bg = false
    root.add_child(qa_viewport)
    var background := ColorRect.new()
    background.color = BG
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.size = Vector2(1152, 1008)
    qa_viewport.add_child(background)

    var test_cases := [
      {"folder":"A36_APPROVED_BASELINE_VX32","cell":32,"label":"A62 32PX APPROVED"},
      {"folder":"A36_AI_FRAMES_EXPERIMENT_VX32_ART_HOLD","cell":32,"label":"A35 32PX AI INTERMEDIATE"},
      {"folder":"A36_AI_FRAMES_VX48_CELL_EXPERIMENT_ART_HOLD","cell":48,"label":"A35 48PX SOURCE-PRESERVED"}
    ]
    var manifest := []
    var fail_count := 0
    for ridx in range(test_cases.size()):
        var tc: Dictionary = test_cases[ridx]
        var relpath: String = "res://" + tc.folder + "/$actor01_1.png"
        var absolute: String = ProjectSettings.globalize_path(relpath)
        var raw_image: Image = Image.load_from_file(absolute)
        if raw_image == null or raw_image.is_empty():
            push_error("Cannot load: " + absolute)
            fail_count += 1
            continue
        var cell: int = tc.cell
        if raw_image.get_width() != cell*3 or raw_image.get_height() != cell*4:
            push_error("Wrong cell grid: " + str(raw_image.get_size()))
            fail_count += 1
            continue
        var tex: ImageTexture = ImageTexture.create_from_image(raw_image)
        var label := Label.new()
        label.text = tc.label + " | " + str(raw_image.get_width()) + "x" + str(raw_image.get_height())
        label.position = Vector2(48, 35 + ridx*320)
        label.add_theme_font_size_override("font_size", 22)
        label.add_theme_color_override("font_color", Color.WHITE)
        qa_viewport.add_child(label)
        for cidx in range(3):
            var sprite := Sprite2D.new()
            sprite.texture = tex
            sprite.region_enabled = true
            sprite.region_rect = Rect2(cidx*cell, 2*cell, cell, cell)
            sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            sprite.centered = false
            sprite.scale = Vector2(7.0,7.0) if cell==32 else Vector2(5.0,5.0)
            sprite.position = Vector2(48 + cidx*360, 78 + ridx*320)
            qa_viewport.add_child(sprite)
            var frame_image: Image = raw_image.get_region(Rect2i(cidx*cell,2*cell,cell,cell))
            var opaque_count := 0
            for yy in range(cell):
                for xx in range(cell):
                    if frame_image.get_pixel(xx,yy).a > 0.0:
                        opaque_count += 1
            manifest.append({"case":tc.label,"frame":cidx,"opaque":opaque_count,"size":cell})
        print("GODOT_CASE_PASS ",tc.label," image=",raw_image.get_size())
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var screenshot: Image = qa_viewport.get_texture().get_image()
    if screenshot == null or screenshot.is_empty():
        push_error("GPU viewport screenshot is empty")
        fail_count += 1
    else:
        screenshot.convert(Image.FORMAT_RGBA8)
        var transparent_or_bg := 0
        var non_bg := 0
        for yy in range(0,screenshot.get_height(),4):
            for xx in range(0,screenshot.get_width(),4):
                var col: Color = screenshot.get_pixel(xx,yy)
                if col.a > 0.5 and (abs(col.r - BG.r) + abs(col.g - BG.g) + abs(col.b - BG.b)) > 0.15:
                    non_bg += 1
                else:
                    transparent_or_bg += 1
        var outfile: String = ProjectSettings.globalize_path("res://A36_GODOT_ACTUAL_GPU_SPRITE_REGION_CAPTURE.png")
        var save_error: Error = screenshot.save_png(outfile)
        print("GODOT_CAPTURE ",outfile," pixels=",screenshot.get_size()," non_background_samples=",non_bg," status=",save_error)
        if save_error != OK or non_bg < 400:
            push_error("GPU rendering did not visibly draw sprites")
            fail_count += 1
    print("GODOT_FRAME_MANIFEST ",JSON.stringify(manifest))
    if fail_count == 0:
        print("GODOT_NATIVE_SPRITE_REGION_QA_PASS")
    else:
        print("GODOT_NATIVE_SPRITE_REGION_QA_FAIL fail_count=",fail_count)
    quit(0 if fail_count==0 else 1)
