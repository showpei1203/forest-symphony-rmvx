extends SceneTree
## R25 native M2/M4: validates REAL Bone2D parent/child transforms, 3-point swing arc,
## A52 source sword grip, 128px native captures and real animation time/contact signals.
## NO claim of 64px new pixel art, nor completed original FS Battle integration.
var errors: Array[String] = []
var hit_events: Array[float] = []
var changed: int=0
var stop_events: Array[int] = []
var resume_events: Array[int] = []

func gate(ok: bool, name: String) -> void:
    if ok:
        print("R25_PASS "+name)
    else:
        errors.append(name)
        push_error("R25_FAIL "+name)

func _on_hit(sec: float) -> void:
    hit_events.append(sec)

func _on_hitstop(_seconds: float) -> void:
    stop_events.append(Time.get_ticks_msec())

func _on_resume(_seconds: float) -> void:
    resume_events.append(Time.get_ticks_msec())

func _initialize() -> void:
    call_deferred("_run")

func _native_snap(v: SubViewport) -> Image:
    await process_frame
    await RenderingServer.frame_post_draw
    var pic: Image=v.get_texture().get_image()
    pic.convert(Image.FORMAT_RGBA8)
    return pic

func _run() -> void:
    var viewport=SubViewport.new()
    viewport.size=Vector2i(128,128)
    viewport.transparent_bg=true
    viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    root.add_child(viewport)
    var scene: PackedScene=load("res://scenes/r25_preview.tscn")
    gate(scene != null,"preview-scene-load")
    if scene==null:
        quit(1)
        return
    var rig=scene.instantiate()
    rig.position=Vector2(32,32)
    rig.autoplay_preview=false
    rig.preview_repeat=false
    viewport.add_child(rig)
    await process_frame
    gate(rig.skeleton is Skeleton2D,"actual-Skeleton2D-entity")
    gate(rig.pelvis is Bone2D and rig.chest is Bone2D and rig.upper is Bone2D and rig.forearm is Bone2D and rig.wrist is Bone2D,"actual-kinematic-Bone2D-chain")
    gate(rig.get_bone_count()>=8,"at-least-eight-parented-Bone2D")
    gate(rig.forearm.get_parent()==rig.upper and rig.wrist.get_parent()==rig.forearm,"forearm-and-wrist-child-hierarchy")
    gate(rig.sword.get_parent()==rig.wrist,"actual-A52-sword-parented-to-wrist-Bone2D")
    gate(rig.animator is AnimationPlayer and rig.animator.get_animation_list().size()==2,"two-real-AnimationPlayer-motion-profiles")
    var src=Image.load_from_file(ProjectSettings.globalize_path("res://assets/actor01_a62_approved_F0_64.png"))
    gate(src!=null and src.get_size()==Vector2i(64,64),"A62-original-64-source-identical-sized")
    var blade=Image.load_from_file(ProjectSettings.globalize_path("res://assets/source_a52_sword_F1_grip_pivot_7x21.png"))
    gate(blade!=null and blade.get_size()==Vector2i(7,21),"original-A52-sword-real-source-sprite")
    var output=ProjectSettings.globalize_path("res://qa/output/r25")
    DirAccess.make_dir_recursive_absolute(output)
    var infos=[]
    # R25: true bone-bound original A52 visible-source arms/coat, not just bone guides.
    gate(rig is FSTASourceBoundSlashR25, "R25-original-source-bound-subclass")
    gate(rig.skin_parts.size()==9, "R25-nine-independent-visible-source-pieces")
    gate(rig.skin_parts["torso"].get_parent()==rig.chest,"original-torso-attached-chest-Bone2D")
    gate(rig.skin_parts["near_upper"].get_parent()==rig.upper,"original-upper-sleeve-attached-upper-Bone2D")
    gate(rig.skin_parts["near_forearm"].get_parent()==rig.forearm,"original-forearm-attached-elbow-Bone2D")
    gate(rig.skin_parts["near_hand"].get_parent()==rig.wrist,"original-hand-attached-wrist-Bone2D")
    gate(rig.skin_parts["far_arm"].get_parent()==rig.offhand,"original-offhand-attached-guard-Bone2D")
    gate(rig.sword.get_parent()==rig.wrist,"original-sword-still-child-of-wrist")
    # Negative and positive original torso proof. No new paint colors or hidden underpaint.
    rig.sword.visible=false
    rig.apply_key_pose(0,rig.PROFILE_OVERHEAD)
    var idle_image=await _native_snap(viewport)
    var original_src=Image.load_from_file(ProjectSettings.globalize_path("res://assets/actor01_a62_approved_F0_64.png"))
    var pixel_errors=0
    for yy in range(64):
        for xx in range(64):
            if idle_image.get_pixel(xx+32,yy+32)!=original_src.get_pixel(xx,yy):
                pixel_errors+=1
    gate(pixel_errors==0,"original-F0-exact-native-GPU-original-RGBA-delta-%d"%pixel_errors)
    rig.apply_key_pose(7,rig.PROFILE_OVERHEAD)
    var body_before=await _native_snap(viewport)
    rig.skin_parts["torso"].visible=false
    var body_missing=await _native_snap(viewport)
    var changed_coat=0
    for yy in range(128):
        for xx in range(128):
            if body_before.get_pixel(xx,yy)!=body_missing.get_pixel(xx,yy):
                changed_coat+=1
    gate(changed_coat>=20,"real-native-bone-bound-torso-coat-layer-delete-%dpx"%changed_coat)
    rig.skin_parts["torso"].visible=true
    var restored=await _native_snap(viewport)
    var mismatch=0
    for yy in range(128):
        for xx in range(128):
            if body_before.get_pixel(xx,yy)!=restored.get_pixel(xx,yy):
                mismatch+=1
    gate(mismatch==0,"R25-original-torso-visibility-restored-exact-%dpx"%mismatch)
    rig.sword.visible=true
    var profiles=[rig.PROFILE_OVERHEAD,rig.PROFILE_DIAGONAL]
    for prof in profiles:
        var p_name: String=prof["name"]
        var hands: Array[Vector2]=[]
        var tips: Array[Vector2]=[]
        var angles=[]
        var tip_bounds=Rect2(Vector2(100000,100000),Vector2.ZERO)
        for i in range(12):
            rig.apply_key_pose(i,prof)
            var shot: Image=await _native_snap(viewport)
            gate(shot.get_size()==Vector2i(128,128),"%s-native-128-capture-f%02d"%[p_name,i])
            gate(shot.save_png(output.path_join("%s_F%02d_NATIVE.png"%[p_name,i]))==OK,"%s-native-PNG-save-f%02d"%[p_name,i])
            gate((i==0 or i==11) == (not rig.source_skin_active),"%s-source-skin-swap-per-F%02d"%[p_name,i])
            gate(rig.source_frame==i,"%s-R23-source-full-body-atlas-F%02d"%[p_name,i])
            if i in [3,5,7,9]:
                rig.sword.visible=false
                var isolated_body=await _native_snap(viewport)
                gate(isolated_body.save_png(output.path_join("%s_F%02d_BONE_BOUND_SOURCE_ONLY.png"%[p_name,i]))==OK,"%s-native-original-body-no-sword-F%02d"%[p_name,i])
                rig.sword.visible=true
            var want=prof["hand"][i]+rig.position
            var hand: Vector2=rig.measured_hand_position()
            var tip: Vector2=rig.measured_tip_position()
            hands.append(hand)
            tips.append(tip)
            var alpha=(tip-hand).angle()
            angles.append(rad_to_deg(alpha))
            gate(hand.distance_to(want)<0.25,"%s-IK-F%02d-hand-target-distance-%.3f"%[p_name,i,hand.distance_to(want)])
            gate(tip.x>2 and tip.y>2 and tip.x<126 and tip.y<126,"%s-F%02d-tip-not-clipped"%[p_name,i])
        var p0=tips[4];var p1=tips[7];var p2=tips[9]
        var arc_deg=absf(float(prof["blade_deg"][9])-float(prof["blade_deg"][4]))
        gate(arc_deg>=200.0,"%s-swing-large-angle-%.1f"%[p_name,arc_deg])
        gate(p0.distance_to(p1)>20.0,"%s-worldtip-travel-windup-to-impact-%.2f"%[p_name,p0.distance_to(p1)])
        gate(p1.distance_to(p2)>19.0,"%s-worldtip-followthrough-%.2f"%[p_name,p1.distance_to(p2)])
        gate(rig._pose_model(0,prof)["hand"].distance_to(rig._pose_model(7,prof)["hand"])>6.0,"%s-physical-wrist-travels-across-strike"%p_name)
        infos.append({"profile":p_name,"frames":12,"swing_degrees":arc_deg,"tip_windup_to_contact_px":p0.distance_to(p1),"tip_contact_to_followthrough_px":p1.distance_to(p2),"hand_targets":hands.map(func(v):return [v.x,v.y]),"tip_targets":tips.map(func(v):return [v.x,v.y]),"tip_angles_degrees":angles,"native_12_screenshots":"SAVED"})
    # Validate real AnimationPlayer drives Bone2D values, not just direct pose assignment.
    rig.slash_contact.connect(_on_hit)
    rig.hitstop_started.connect(_on_hitstop)
    rig.hitstop_finished.connect(_on_resume)
    rig.play_large_slash("overhead_arched_slash")
    await process_frame
    await create_timer(0.38).timeout
    var actual_playback_tip_before: Vector2=rig.measured_tip_position()
    await create_timer(0.30).timeout
    gate(hit_events.size()==1,"real-playback-f7-contact-fired-once")
    gate(stop_events.size()==1,"real-AnimationPlayer-hitstop-started")
    gate(rig.animator.current_animation_position>=0.629 and rig.animator.current_animation_position<0.70,"real-animation-paused-near-F7")
    if hit_events.size()==1:
        gate(absf(hit_events[0]-0.630)<0.001,"f7-contact-contract-0.630")
    gate(rig.animator.current_animation_position>0.62,"real-AnimationPlayer-timeline-crossed-contact")
    await create_timer(0.12).timeout
    gate(resume_events.size()==1,"real-70ms-hitstop-resumed")
    if resume_events.size()==1 and stop_events.size()==1:
        var elapsed=resume_events[0]-stop_events[0]
        gate(elapsed>=60 and elapsed<=140,"real-70ms-hitstop-wall-msec-%d"%elapsed)
    gate(not rig.hitstop_active and rig.animator.speed_scale==1.0,"real-AnimationPlayer-unpaused")
    var actual_playback_tip_after: Vector2=rig.measured_tip_position()
    gate(actual_playback_tip_before.distance_to(actual_playback_tip_after)>12.0,"real-AnimationPlayer-moves-Bone2D-sword-not-static-%.2f"%actual_playback_tip_before.distance_to(actual_playback_tip_after))
    await create_timer(0.67).timeout
    gate(hit_events.size()==1,"real-playback-no-double-contact-after-recovery")
    gate(not rig.animator.is_playing(),"actual-animation-player-stopped-at-end")
    # M4: actual AnimationPlayer timeline for the SECOND distinct diagonal swing.
    hit_events.clear()
    stop_events.clear()
    resume_events.clear()
    rig.play_large_slash("diagonal_slash")
    await create_timer(0.39).timeout
    var diagonal_tip_before: Vector2=rig.measured_tip_position()
    await create_timer(0.45).timeout
    var diagonal_tip_after: Vector2=rig.measured_tip_position()
    gate(diagonal_tip_before.distance_to(diagonal_tip_after)>15.0,"second-sample-real-AnimationPlayer-diagonal-moves-sword-%.2f"%diagonal_tip_before.distance_to(diagonal_tip_after))
    gate(hit_events.size()==1 and absf(hit_events[0]-0.630)<0.001,"second-sample-real-F7-single-contact")
    gate(stop_events.size()==1 and resume_events.size()==1,"second-sample-real-70ms-hitstop-signals")
    await create_timer(0.48).timeout
    gate(not rig.animator.is_playing(),"second-sample-real-diagonal-animation-ended")
    rig.slash_contact.disconnect(_on_hit)
    print("R25_NATIVE_SOURCE_BOUND_PROFILE_QA "+JSON.stringify(infos))
    print("R25_QA_STATUS "+("PASS" if errors.is_empty() else "FAIL"))
    quit(0 if errors.is_empty() else 1)
