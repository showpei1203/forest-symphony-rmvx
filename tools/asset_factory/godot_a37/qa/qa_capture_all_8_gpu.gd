extends SceneTree
## Capture each A35 RUN frame using Godot's real GPU renderer; independent of PIL.
func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var scene: PackedScene = load("res://scenes/battle_run_preview.tscn")
    var stage: Node = scene.instantiate()
    root.add_child(stage)
    await process_frame
    var actor: FSBattleActorAnimator = stage.get_node("Actor01")
    var sprite: AnimatedSprite2D = actor.actor_sprite
    assert(actor.get_frame_index() >= 0)
    assert(actor.play_motion(&"run", &"run_tuned"))
    sprite.pause()
    var crop_rect := Rect2i(352, 245, 320, 320)
    var contact: Image = Image.create(4 * 320, 2 * 320, false, Image.FORMAT_RGBA8)
    var outdir: String = ProjectSettings.globalize_path("res://qa/output")
    DirAccess.make_dir_recursive_absolute(outdir)
    var unique_hashes: Dictionary = {}
    for i in range(8):
        sprite.frame = i
        await process_frame
        await RenderingServer.frame_post_draw
        var full: Image = root.get_viewport().get_texture().get_image()
        var clip: Image = full.get_region(crop_rect)
        assert(clip.get_size() == Vector2i(320, 320))
        var path: String = outdir.path_join("A37_GPU_RUN_F%02d.png" % i)
        assert(clip.save_png(path) == OK)
        contact.blit_rect(clip, Rect2i(0, 0, 320, 320), Vector2i(i % 4 * 320, i / 4 * 320))
        var md5: String = str(hash(clip.get_data()))
        unique_hashes[md5] = true
        print("A37_GPU_FRAME_%d=%s" % [i, md5])
    assert(unique_hashes.size() == 8)
    var destination: String = outdir.path_join("A37_GODOT_GPU_EIGHT_FRAME_CONTACT.png")
    assert(contact.save_png(destination) == OK)
    print("A37_GPU_8FRAME_UNIQUE=" + str(unique_hashes.size()))
    print("A37_GPU_8FRAME_CONTACT=" + destination)
    print("A37_GPU_8FRAME_QA_PASS")
    quit(0)
