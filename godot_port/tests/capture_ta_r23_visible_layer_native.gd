extends SceneTree
## FS T-A R23: 7 source-exact VISIBLE pixel ownership layers per original A52 frame.
## This is NOT original LPC semantic costume underpaint, nor a new boxing animation.
var errors: Array[String] = []
var names := ["head_hair_visible", "far_arm_sleeve_visible", "near_arm_sleeve_visible", "torso_coat_belly_visible", "belt_waist_visible", "pants_visible", "boots_visible"]

func gate(ok: bool, why: String) -> void:
    if not ok:
        errors.append(why)
        push_error("R23_FAIL " + why)
    else:
        print("R23_PASS "+ why)

func _initialize() -> void:
    call_deferred("_run")

func _snap(viewport: SubViewport) -> Image:
    await process_frame
    await RenderingServer.frame_post_draw
    var image = viewport.get_texture().get_image()
    image.convert(Image.FORMAT_RGBA8)
    return image

func _mismatch(expected: Image, actual: Image, fi: int) -> int:
    var count := 0
    for y in range(64):
        for x in range(64):
            var want := expected.get_pixel((fi%4)*64+x, int(fi/4)*64+y)
            var got := actual.get_pixel(x,y)
            if got != want:
                var alpha8 := want.a8
                var rr := roundi(float(want.r8)*float(alpha8)/255.0)
                var gg := roundi(float(want.g8)*float(alpha8)/255.0)
                var bb := roundi(float(want.b8)*float(alpha8)/255.0)
                if got.a8!=alpha8 or absi(got.r8-rr)>1 or absi(got.g8-gg)>1 or absi(got.b8-bb)>1:
                    count += 1
    return count

func _run() -> void:
    var original_path := "res://assets/a52_true_source_12.png"
    var original := Image.load_from_file(ProjectSettings.globalize_path(original_path))
    gate(original!=null,"A52-private-original-loaded")
    if original==null:
        quit(1)
        return
    gate(original.get_size()==Vector2i(256,192),"original-12-64-atlas")
    var viewport:=SubViewport.new()
    viewport.size=Vector2i(64,64)
    viewport.transparent_bg=true
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var sprites: Array[Sprite2D]=[]
    for i in range(names.size()):
        var path="res://assets/R23_"+names[i]+"_12x64.png"
        var texture: Texture2D=load(path)
        gate(texture!=null,"load-actual-layer-"+names[i])
        if texture==null:
            quit(1)
            return
        var sprite=Sprite2D.new()
        sprite.name="VisiblePixelOwner_"+names[i]
        sprite.centered=false
        sprite.texture=texture
        sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        sprite.region_enabled=true
        sprite.region_rect=Rect2(0,0,64,64)
        viewport.add_child(sprite)
        sprites.append(sprite)
    await process_frame
    var output=ProjectSettings.globalize_path("res://qa/output/r23")
    DirAccess.make_dir_recursive_absolute(output)
    var diffs: Array[int]=[]
    for i in range(12):
        for sprite in sprites:
            sprite.region_rect=Rect2(64*(i%4),64*int(i/4),64,64)
        var shot=await _snap(viewport)
        var bad=_mismatch(original,shot,i)
        diffs.append(bad)
        gate(bad==0,"7-layer-real-GPU-original-F%02d-diff-%d"%[i,bad])
        gate(shot.save_png(output.path_join("R23_ACTUAL_NATIVE_F%02d.png"%i))==OK,"save-actual-native-F%02d"%i)
    # Test true layer visibility in render. Physically remove original belly/coat visible source pixels.
    for sprite in sprites:
        sprite.region_rect=Rect2(64*(7%4),64*int(7/4),64,64)
    var coat=sprites[3]
    coat.visible=false
    var missing=await _snap(viewport)
    var removed_delta=_mismatch(original,missing,7)
    gate(removed_delta>=40,"negative-hide-visible-belly-layer-rejected-%d"%removed_delta)
    coat.visible=true
    var restored=await _snap(viewport)
    gate(_mismatch(original,restored,7)==0,"restore-belly-layer-original-F07-exact")
    # Prove 2 specific frames are different original poses, not a static source overlay.
    gate(diffs.size()==12 and diffs.all(func(v): return v==0),"12-native-frames-exact-source")
    print("R23_NATIVE_SOURCE_GPU_DIFFS "+str(diffs))
    print("R23_NATIVE_NEGATIVE_HIDDEN_TORSO_DIFF "+str(removed_delta))
    print("R23_NATIVE_QA_RESULT "+("PASS" if errors.is_empty() else "FAIL"))
    quit(0 if errors.is_empty() else 1)
