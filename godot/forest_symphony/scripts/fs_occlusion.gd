extends RefCounted
## Per-actor, same-XY overlay. Pixel Plays' geometry idea, not its art style.
## A27 invariant: each visible PAR texel comes from the unchanged Master at XY.

const ALLOWED := ["tree_canopy", "roof_front_eave", "bridge_near_rail", "cliff_top"]

static func build_overlay(actor: Image, actor_top_left: Vector2i, foot: Vector2i, owners: Array) -> Image:
    assert(actor != null and not actor.is_empty())
    var result := Image.create_empty(actor.get_width(), actor.get_height(), false, Image.FORMAT_RGBA8)
    result.fill(Color.TRANSPARENT)
    for owner in owners:
        assert(ALLOWED.has(owner["semantic"]))
        var rect: Rect2i = owner["rect"]
        var source: Image = owner["image"]
        assert(source.get_width() == rect.size.x and source.get_height() == rect.size.y)
        assert(owner["far"] <= owner["near"])
        for local_y in range(actor.get_height()):
            var wy := actor_top_left.y + local_y
            if wy < rect.position.y or wy >= rect.end.y:
                continue
            var depth_fraction := float(wy - rect.position.y) / float(maxi(1, rect.size.y - 1))
            var limit: float = float(owner["far"]) + float(owner["near"] - owner["far"]) * depth_fraction
            if float(foot.y) >= limit:
                continue
            for local_x in range(actor.get_width()):
                if actor.get_pixel(local_x, local_y).a <= 0.0:
                    continue
                var wx := actor_top_left.x + local_x
                if wx < rect.position.x or wx >= rect.end.x:
                    continue
                var pixel := source.get_pixel(wx - rect.position.x, wy - rect.position.y)
                if pixel.a > 0.0:
                    result.set_pixel(local_x, local_y, pixel)
    return result

static func opaque_count(image: Image) -> int:
    var count := 0
    for y in image.get_height():
        for x in image.get_width():
            if image.get_pixel(x, y).a > 0.0:
                count += 1
    return count
