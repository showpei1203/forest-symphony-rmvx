extends SceneTree
## Captures real GPU pixel output for PixelLab R1 and curated IDLE, without synthetic pixel generation.
func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var scene: PackedScene = load("res://scenes/battle_animation_preview.tscn")
    assert(scene != null)
    var stage: Node = scene.instantiate()
    root.add_child(stage)
    await process_frame
    var actor: FSBattleActorAnimator = stage.get_node("IdleActor")
    var sprite: AnimatedSprite2D = actor.actor_sprite
    var folder: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(folder)
    for profile in ["idle_raw", "idle_calm", "idle_r2"]:
        assert(actor.play_motion(&"idle", StringName(profile)))
        sprite.stop()
        var collage := Image.create(4*256, 2*256, false, Image.FORMAT_RGBA8)
        var fingerprints: Dictionary = {}
        for i in range(8):
            sprite.frame = i
            await process_frame
            await RenderingServer.frame_post_draw
            await process_frame
            await RenderingServer.frame_post_draw
            var img: Image = root.get_viewport().get_texture().get_image()
            assert(img.get_size().x >= 900 and img.get_size().y >= 680)
            var region: Image = img.get_region(Rect2i(570,240,256,256))
            assert(region.get_size() == Vector2i(256,256))
            var key: int = hash(region.get_data())
            fingerprints[key] = true
            collage.blit_rect(region, Rect2i(0,0,256,256), Vector2i((i%4)*256,(i/4)*256))
        var path := folder.path_join("A38_GODOT_GPU_"+profile.to_upper()+"_EIGHT_FRAMES.png")
        assert(collage.save_png(path) == OK)
        var expected: int = 3 if profile == "idle_calm" else 5
        # Palette/pos differences in UI should not be counted as distinct poses.
        print("A38_GPU_PROFILE="+profile+" DISTINCT_CAPTURE_HASHES="+str(fingerprints.size())+" EXPECTED_MIN="+str(expected)+" PATH="+path)
        assert(fingerprints.size() >= expected)
    print("A38_IDLE_GPU_CAPTURE_PASS")
    quit(0)
