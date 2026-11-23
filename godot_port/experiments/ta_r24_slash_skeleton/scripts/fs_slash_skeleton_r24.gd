extends Node2D
class_name FSTASlashSkeletonR24

@export var autoplay_preview: bool=false
@export var preview_repeat: bool=false
## Real independent Bone2D chain drives original A52 sword sprite. ENGINEERING ONLY.
## The approved A62 full Body is kept unmodified as reference, not deforming paper doll.
## Original LPC hidden garments/underpaint missing: animated arm is a diagnostics skeleton.

signal slash_contact(second: float)
signal hitstop_started(seconds: float)
signal hitstop_finished(seconds: float)

const FRAME_TIMES: Array[float] = [0.0, 0.100, 0.190, 0.275, 0.350, 0.455, 0.560, 0.620, 0.735, 0.830, 0.910, 0.980]
const CONTACT_SECONDS: float = 0.630
const HITSTOP_SECONDS: float = 0.070
const UPPER_LEN: float = 8.0
const LOWER_LEN: float = 8.0
const BLADE_LEN: float = 19.0

# Each point is in the ORIGINAL 64x64 A62 source coordinate system.
# No claimed true source anatomical underpaint, shoulder/hilt coords are PREVIEW estimates.
const PROFILE_OVERHEAD := {
    "name": "overhead_arched_slash",
    "hand": [Vector2(40,37),Vector2(38,34),Vector2(34,29),Vector2(31,24),Vector2(33,22),Vector2(38,25),Vector2(43,29),Vector2(47,33),Vector2(46,38),Vector2(42,42),Vector2(40,39),Vector2(40,37)],
    "blade_deg": [-75,-105,-135,-165,-170,-105,-42,20,72,108,35,-75],
    "hips_deg": [0,-3,-5,-8,-8,-4,3,10,11,8,3,0],
    "chest_deg": [0,-4,-7,-11,-14,-6,7,19,17,10,3,0],
    "offhand": [Vector2(28,34),Vector2(28,33),Vector2(29,32),Vector2(29,31),Vector2(29,31),Vector2(29,32),Vector2(30,33),Vector2(31,34),Vector2(30,34),Vector2(29,35),Vector2(29,34),Vector2(28,34)]
}
const PROFILE_DIAGONAL := {
    "name": "diagonal_slash",
    "hand": [Vector2(40,37),Vector2(37,34),Vector2(33,29),Vector2(32,25),Vector2(34,24),Vector2(39,27),Vector2(44,30),Vector2(48,34),Vector2(47,38),Vector2(43,41),Vector2(40,39),Vector2(40,37)],
    "blade_deg": [-75,-95,-118,-145,-150,-85,-20,35,80,100,30,-75],
    "hips_deg": [0,-4,-5,-6,-7,-3,4,8,8,5,2,0],
    "chest_deg": [0,-5,-7,-10,-12,-4,10,17,14,6,2,0],
    "offhand": [Vector2(28,34),Vector2(28,33),Vector2(29,31),Vector2(29,31),Vector2(29,31),Vector2(29,32),Vector2(30,33),Vector2(30,34),Vector2(30,34),Vector2(29,34),Vector2(28,34),Vector2(28,34)]
}

var current_profile: Dictionary = PROFILE_OVERHEAD
var silhouette: Sprite2D
var skeleton: Skeleton2D
var pelvis: Bone2D
var chest: Bone2D
var upper: Bone2D
var forearm: Bone2D
var wrist: Bone2D
var offhand: Bone2D
var lead_leg: Bone2D
var rear_leg: Bone2D
var sword: Sprite2D
var animator: AnimationPlayer
var debug_enabled: bool = true
var last_playback_seconds: float = -1.0
var contact_emitted: bool = false
var hitstop_active: bool = false
var sword_handle_offset: Vector2 = Vector2(-3,-19)
var fk_hand_targets: Array[Vector2] = []
var fk_tip_targets: Array[Vector2] = []

func _ready() -> void:
    # Keep complete approved full body source; never mutate/reshape for the preview.
    silhouette = Sprite2D.new()
    silhouette.name = "A62_Approved_FullBody_Static_Source_Reference"
    silhouette.centered = false
    silhouette.texture = load("res://assets/actor01_a62_approved_F0_64.png")
    silhouette.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(silhouette)
    assert(silhouette.texture != null)

    skeleton = Skeleton2D.new()
    skeleton.name = "R24_Skeleton2D"
    pelvis = _bone(skeleton,"Pelvis_Root",Vector2(32,43),8.0)
    chest = _bone(pelvis,"Chest_Twist",Vector2(0,-10),8.0)
    upper = _bone(chest,"Near_UpperArm_Shoulder",Vector2(3,0),UPPER_LEN)
    forearm = _bone(upper,"Near_Forearm_Elbow",Vector2(UPPER_LEN,0),LOWER_LEN)
    wrist = _bone(forearm,"Near_Wrist_Grip",Vector2(LOWER_LEN,0),1.0)
    offhand = _bone(chest,"Far_UpperArm_Guard",Vector2(-4,0),8.0)
    lead_leg = _bone(pelvis,"Lead_Leg_Hip",Vector2(3,0),10.0)
    rear_leg = _bone(pelvis,"Rear_Leg_Hip",Vector2(-4,0),10.0)
    # Publish the COMPLETE REST skeleton at once to avoid invalid zero rest transforms.
    add_child(skeleton)

    sword = Sprite2D.new()
    sword.name = "A52_Real_Sword_Grip_Pivot"
    sword.texture = load("res://assets/source_a52_sword_F1_grip_pivot_7x21.png")
    sword.centered = false
    sword.position = sword_handle_offset
    sword.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    wrist.add_child(sword)
    assert(sword.texture != null)

    animator = AnimationPlayer.new()
    animator.name = "Slash_12Frame_Animator"
    add_child(animator)
    animator.root_node = NodePath("..")
    build_animation(PROFILE_OVERHEAD)
    build_animation(PROFILE_DIAGONAL)
    apply_key_pose(0,PROFILE_OVERHEAD)
    queue_redraw()
    if autoplay_preview:
        animator.animation_finished.connect(_on_preview_finished)
        call_deferred("play_large_slash")

func _bone(parent: Node, node_name:String, p: Vector2, arm_len: float) -> Bone2D:
    var b := Bone2D.new()
    b.name=node_name
    b.position=p
    b.rest=b.transform
    b.auto_calculate_length_and_angle=false
    b.length=arm_len
    parent.add_child(b)
    return b

func _pose_model(index: int, profile: Dictionary) -> Dictionary:
    var hip_rot = deg_to_rad(float(profile["hips_deg"][index]))
    var chest_rot = deg_to_rad(float(profile["chest_deg"][index]))
    var total_rot = hip_rot+chest_rot
    var pivot := Vector2(32,43)
    var shoulder = pivot+Vector2(0,-10).rotated(hip_rot)+Vector2(3,0).rotated(total_rot)
    var hand: Vector2 = profile["hand"][index]
    var v: Vector2 = hand-shoulder
    var d = clampf(v.length(),0.1,UPPER_LEN+LOWER_LEN-0.0001)
    var c = clampf((d*d-UPPER_LEN*UPPER_LEN-LOWER_LEN*LOWER_LEN)/(2.0*UPPER_LEN*LOWER_LEN),-1,1)
    var elbow_internal = acos(c)
    var first_global = v.angle()-atan2(LOWER_LEN*sin(elbow_internal),UPPER_LEN+LOWER_LEN*cos(elbow_internal))
    var desired_blade = deg_to_rad(float(profile["blade_deg"][index]))
    # Source sword vector is (3,-19), pointing ~-81 degrees; apply rotation to get exact desired blade azimuth.
    var source_blade = Vector2(3,-19).angle()
    var upper_relative = first_global-total_rot
    var wrist_relative = desired_blade-source_blade-first_global-elbow_internal
    var end = shoulder+Vector2(UPPER_LEN,0).rotated(first_global)+Vector2(LOWER_LEN,0).rotated(first_global+elbow_internal)
    return {"hip":hip_rot,"chest":chest_rot,"upper":upper_relative,"forearm":elbow_internal,"wrist":wrist_relative,"offhand":deg_to_rad(-145.0+float(index)*0.8),"shoulder":shoulder,"elbow_point":shoulder+Vector2(UPPER_LEN,0).rotated(first_global),"hand":end,"tip":end+Vector2(3,-19).rotated(desired_blade-source_blade)}

func build_animation(profile: Dictionary) -> void:
    var a := Animation.new()
    a.resource_name=String(profile["name"])
    a.length=1.08
    a.loop_mode=Animation.LOOP_NONE
    var tracks = ["R24_Skeleton2D/Pelvis_Root:rotation","R24_Skeleton2D/Pelvis_Root/Chest_Twist:rotation","R24_Skeleton2D/Pelvis_Root/Chest_Twist/Near_UpperArm_Shoulder:rotation","R24_Skeleton2D/Pelvis_Root/Chest_Twist/Near_UpperArm_Shoulder/Near_Forearm_Elbow:rotation","R24_Skeleton2D/Pelvis_Root/Chest_Twist/Near_UpperArm_Shoulder/Near_Forearm_Elbow/Near_Wrist_Grip:rotation", "R24_Skeleton2D/Pelvis_Root/Chest_Twist/Far_UpperArm_Guard:rotation"]
    var keys = ["hip","chest","upper","forearm","wrist","offhand"]
    for k in range(tracks.size()):
        var tr=a.add_track(Animation.TYPE_VALUE)
        a.track_set_path(tr,NodePath(tracks[k]))
        a.track_set_interpolation_type(tr,Animation.INTERPOLATION_LINEAR)
        for i in range(12):
            a.track_insert_key(tr,FRAME_TIMES[i],_pose_model(i,profile)[keys[k]])
    if animator.has_animation_library(""):
        var lib=animator.get_animation_library("")
        lib.add_animation(String(profile["name"]),a)
    else:
        var lib=AnimationLibrary.new()
        lib.add_animation(String(profile["name"]),a)
        animator.add_animation_library("",lib)

func apply_key_pose(index: int,profile: Dictionary) -> void:
    assert(index>=0 and index<12)
    current_profile=profile
    var p=_pose_model(index,profile)
    pelvis.rotation=p["hip"]
    chest.rotation=p["chest"]
    upper.rotation=p["upper"]
    forearm.rotation=p["forearm"]
    wrist.rotation=p["wrist"]
    offhand.rotation=p["offhand"]
    queue_redraw()

func play_large_slash(profile_name: String="overhead_arched_slash") -> void:
    assert(animator.has_animation(profile_name))
    last_playback_seconds=-1.0
    contact_emitted=false
    hitstop_active=false
    animator.speed_scale=1.0
    animator.play(profile_name)

func track_contact(playback_seconds: float) -> void:
    if not contact_emitted and last_playback_seconds < CONTACT_SECONDS and playback_seconds >= CONTACT_SECONDS:
        contact_emitted=true
        slash_contact.emit(CONTACT_SECONDS)
        _hitstop_at_impact()
    last_playback_seconds=playback_seconds

func measured_hand_position() -> Vector2:
    return wrist.global_position

func measured_tip_position() -> Vector2:
    # Sword tip in source sword 7x21 is sprite local point (6,0); original pivot grip (3,19).
    return sword.to_global(Vector2(6,0))

func get_bone_count() -> int:
    return 8

func _draw() -> void:
    if not debug_enabled or skeleton==null or not is_instance_valid(wrist):
        return
    var pts=[upper.global_position,forearm.global_position,wrist.global_position]
    draw_line(to_local(pts[0]),to_local(pts[1]),Color(0.98,0.56,0.28,1),2.0)
    draw_line(to_local(pts[1]),to_local(pts[2]),Color(1,0.79,0.27,1),2.0)
    for v in pts:
        draw_circle(to_local(v),1.25,Color(0.98,0.92,0.38,1))
    draw_line(to_local(sword.to_global(Vector2(3,19))),to_local(measured_tip_position()),Color(0.4,0.86,1,0.35),1.0)

func motion_contract() -> Dictionary:
    return {"engine":"Godot 4.7.2","construction":"real Skeleton2D/Bone2D shoulder elbow wrist + original A52 source sword","body_source":"approved A62 64px intact static identity reference","joint_underpaint":"MISSING", "art_status":"HOLD","main_FS_Battle":"NOT_RUN","frame_times":FRAME_TIMES,"f7_hit_seconds":CONTACT_SECONDS,"hitstop_seconds":HITSTOP_SECONDS}

func _process(_delta: float) -> void:
    if animator == null or not animator.is_playing():
        return
    track_contact(animator.current_animation_position)
    queue_redraw()

func _hitstop_at_impact() -> void:
    if hitstop_active:
        return
    hitstop_active = true
    animator.speed_scale = 0.0
    hitstop_started.emit(HITSTOP_SECONDS)
    await get_tree().create_timer(HITSTOP_SECONDS).timeout
    animator.speed_scale = 1.0
    hitstop_active = false
    hitstop_finished.emit(HITSTOP_SECONDS)

func _on_preview_finished(animation_name: StringName) -> void:
    if preview_repeat:
        play_large_slash(String(animation_name))
