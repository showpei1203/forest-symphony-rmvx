extends "res://scripts/fs_slash_skeleton_r24.gd"
class_name FSTASourceBoundSlashR25

## R25 source-bound BODY/BONE prototype, distinct from approved original LPC paper doll.
## Uses only verified R23 A52 visible source pixels. Never creates hidden underpaint.
## Base R24 AnimationPlayer, Skeleton2D, IK, sword pivot and contact remain intact.

signal source_skin_changed(active: bool)

const SOURCE_PARTS := {
    "far_arm": "res://assets/r25_orig_F00_far_arm_sleeve.png",
    "torso": "res://assets/r25_orig_F00_torso_coat_belly.png",
    "head": "res://assets/r25_orig_F00_head_hair.png",
    "belt": "res://assets/r25_orig_F00_belt_waist.png",
    "pants": "res://assets/r25_orig_F00_pants.png",
    "boots": "res://assets/r25_orig_F00_boots.png"
}
var skin_parts: Dictionary = {}
var source_skin_active: bool = false
var donor_frame: int = 4
var initialized_skin: bool = false
var manual_pose: bool = false
var source_frame: int = -1
var source_atlas: Dictionary = {}

func _ready() -> void:
    super._ready()
    debug_enabled = false
    # All already-registered full skeleton bones are reused; no R24 rest reinit.
    _part("far_arm", offhand, SOURCE_PARTS["far_arm"], Vector2(-28,-33), -2)
    _part("pants", pelvis, SOURCE_PARTS["pants"], Vector2(-32,-43), -1)
    _part("boots", pelvis, SOURCE_PARTS["boots"], Vector2(-32,-43), -1)
    _part("belt", pelvis, SOURCE_PARTS["belt"], Vector2(-32,-43), 1)
    _part("torso", chest, SOURCE_PARTS["torso"], Vector2(-32,-33), 2)
    _part("near_upper", upper, "res://assets/r25_A52_F04_near_upper.png", Vector2(-39,-34), 3)
    _part("near_forearm", forearm, "res://assets/r25_A52_F04_near_forearm.png", Vector2(-43,-35), 3)
    _part("near_hand", wrist, "res://assets/r25_A52_F04_near_hand.png", Vector2(-46,-36), 4)
    _part("head", chest, SOURCE_PARTS["head"], Vector2(-32,-33), 5)
    sword.z_as_relative = false
    sword.z_index = 6
    initialized_skin = true
    # Existing R23 exact original owner-pixel atlas, not generated wardrobe.
    for part_name in ["far_arm","pants","boots","belt","torso","head"]:
        var source_role = part_name
        if part_name == "far_arm": source_role="far_arm_sleeve"
        if part_name == "torso": source_role="torso_coat_belly"
        if part_name == "head": source_role="head_hair"
        if part_name == "belt": source_role="belt_waist"
        var tex := AtlasTexture.new()
        tex.atlas = load("res://assets/R23_%s_visible_12x64.png" % source_role)
        tex.region = Rect2(0,0,64,64)
        source_atlas[part_name] = tex
        (skin_parts[part_name] as Sprite2D).texture=tex
    _use_source_frame(0)
    # Unchanged approved A62 full-body pixels at idle F0 and F11.
    _use_source_skin(false)
    _use_donor(4)
    if autoplay_preview:
        # R24 already schedules the same preview from its super._ready().
        pass

func _part(part_name: String, bone: Bone2D, src: String, offset: Vector2, depth: int) -> void:
    var sprite := Sprite2D.new()
    sprite.name = "R25_A52_Original_%s_BoneBound" % part_name
    sprite.texture = load(src)
    assert(sprite.texture != null)
    sprite.centered = false
    sprite.position = offset
    sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    sprite.z_as_relative = false
    sprite.z_index = depth
    bone.add_child(sprite)
    skin_parts[part_name] = sprite

func _use_source_frame(frame_index: int) -> void:
    assert(frame_index >= 0 and frame_index < 12)
    if frame_index == source_frame:
        return
    source_frame=frame_index
    var bounds=Rect2(float((frame_index%4)*64),float((frame_index/4)*64),64.0,64.0)
    for role in source_atlas:
        var tex: AtlasTexture=source_atlas[role]
        tex.region=bounds

func _use_donor(source_index: int) -> void:
    assert(source_index == 4 or source_index == 5)
    donor_frame = source_index
    for piece in ["upper", "forearm", "hand"]:
        var sprite: Sprite2D = skin_parts["near_" + piece]
        sprite.texture = load("res://assets/r25_A52_F%02d_near_%s.png" % [source_index, piece])
        assert(sprite.texture != null)

func _use_source_skin(allow: bool) -> void:
    if source_skin_active == allow and initialized_skin:
        # Always make the sprite visibility deterministic, even after scene reset.
        pass
    var old = source_skin_active
    source_skin_active = allow
    if silhouette != null:
        silhouette.visible = not allow
    for name in skin_parts:
        (skin_parts[name] as Sprite2D).visible = allow
    if old != allow:
        source_skin_changed.emit(allow)

func apply_key_pose(index: int, profile: Dictionary) -> void:
    super.apply_key_pose(index,profile)
    if initialized_skin:
        manual_pose=true
        _use_source_frame(index)
        _use_donor(4 if String(profile["name"])=="overhead_arched_slash" else 5)
        _use_source_skin(index > 0 and index < 11)

func play_large_slash(profile_name: String="overhead_arched_slash") -> void:
    if initialized_skin:
        manual_pose=false
        _use_source_frame(0)
        _use_donor(4 if profile_name=="overhead_arched_slash" else 5)
        _use_source_skin(false)
    super.play_large_slash(profile_name)

func _process(delta: float) -> void:
    super._process(delta)
    if not initialized_skin or animator==null:
        return
    if animator.is_playing():
        var t = animator.current_animation_position
        var frame=0
        for j in range(FRAME_TIMES.size()):
            if t >= FRAME_TIMES[j]: frame=j
        _use_source_frame(frame)
        _use_source_skin(t >= 0.095 and t < 0.978)
    elif source_skin_active and not manual_pose:
        _use_source_skin(false)

func source_binding_contract() -> Dictionary:
    return {
        "engine": "Godot 4.7.2",
        "inherits": "R24 existing Skeleton2D, 8 Bone2D, original sword and F7 timing",
        "source_masks": "R23 7 EXCLUSIVE visible-owner A52 atlases, frame-to-frame source chest/legs/head artwork while Bone2D drives torso/arms",
        "source_near_arm": "A52 donor F04 or F05 real visible pixels split across UPPER, FOREARM and WRIST",
        "bone_bound_regions": skin_parts.size(),
        "approved_source_idle_F0_unmodified": true,
        "torso_repainted": false,
        "original_hidden_LPC_underpaint": "MISSING",
        "poseable_full_native_LPC_costume": false,
        "sprite_mesh_weight_painting": "NOT_DONE",
        "art_status": "HOLD",
        "formal_FSBattle": "NOT_RUN"
    }
