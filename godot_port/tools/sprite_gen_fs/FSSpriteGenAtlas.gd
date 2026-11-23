## Runtime-only bridge: sprite-gen manifest -> SpriteFrames with AtlasTexture regions.
## No source PNG edits, no dynamic AI calls and no art acceptance.
extends RefCounted


static func read_sidecar(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("FS sprite-gen: sidecar cannot be opened: " + path)
        return {}
    var payload: Variant = JSON.parse_string(file.get_as_text())
    if typeof(payload) != TYPE_DICTIONARY:
        push_error("FS sprite-gen: sidecar JSON must be a dictionary")
        return {}
    return payload as Dictionary


static func build_sprite_frames(atlas: Texture2D, sidecar: Dictionary) -> SpriteFrames:
    if atlas == null or str(sidecar.get("schema", "")) != "fs-sprite-gen-atlas/v1":
        push_error("FS sprite-gen: invalid atlas or validated sidecar schema")
        return null
    if str(sidecar.get("technical_qa", "")) != "PASS":
        push_error("FS sprite-gen: technical QA is not PASS")
        return null
    var size: Array = sidecar.get("atlas_size", [])
    if size.size() != 2 or int(size[0]) != atlas.get_width() or int(size[1]) != atlas.get_height():
        push_error("FS sprite-gen: atlas dimensions do not match validated sidecar")
        return null
    var states: Dictionary = sidecar.get("states", {})
    if states.is_empty():
        push_error("FS sprite-gen: missing animations")
        return null
    var sprite_frames := SpriteFrames.new()
    if sprite_frames.has_animation("default"):
        sprite_frames.remove_animation("default")
    for key: Variant in states.keys():
        var name := str(key)
        var state: Dictionary = states[key]
        var fps := float(state.get("fps", 0.0))
        var is_loop: bool = state.get("loop", false)
        var entries: Array = state.get("frames", [])
        if name.is_empty() or fps <= 0.0 or entries.is_empty():
            push_error("FS sprite-gen: malformed animation " + name)
            return null
        sprite_frames.add_animation(name)
        sprite_frames.set_animation_speed(name, fps)
        sprite_frames.set_animation_loop(name, is_loop)
        for entry: Variant in entries:
            var frame_data: Dictionary = entry
            var region: Array = frame_data.get("region", [])
            if region.size() != 4:
                push_error("FS sprite-gen: malformed frame region")
                return null
            var x := float(region[0])
            var y := float(region[1])
            var w := float(region[2])
            var h := float(region[3])
            if x < 0.0 or y < 0.0 or w <= 0.0 or h <= 0.0 or x + w > atlas.get_width() or y + h > atlas.get_height():
                push_error("FS sprite-gen: out of bounds frame region")
                return null
            var region_texture := AtlasTexture.new()
            region_texture.atlas = atlas
            region_texture.region = Rect2(x, y, w, h)
            var duration_ms := float(frame_data.get("duration_ms", 1000.0 / fps))
            if duration_ms <= 0.0:
                push_error("FS sprite-gen: invalid frame duration")
                return null
            sprite_frames.add_frame(name, region_texture, duration_ms * fps / 1000.0)
    return sprite_frames
