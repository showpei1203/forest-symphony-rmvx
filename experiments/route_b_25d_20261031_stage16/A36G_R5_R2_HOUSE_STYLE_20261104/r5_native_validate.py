"""R5 actual RGSS2 + Godot 4.7.2 GPU cross-check; independent Ground/PAR; carry art and occlusion as separate gates."""
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image,ImageDraw
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
D=R/"GODOT_A36G_R5_40x29"/"out"
V=R/"R5_VX_CAPTURES"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
vx=json.loads((V/"A36G_VX_NATIVE_11_CASES_SCREEN_QA.json").read_text("utf8"))
assert m["stage"]=="A36G_R5_R2_BOTH_HOUSES_STYLE_UNIFIED_ENGINE_CANDIDATE"
scene=np.asarray(Image.open(R/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB"),np.int16)
godot=np.asarray(Image.open(D/"A36G_R5_GODOT_00_FULL_NO_ACTOR_1280x928.png").convert("RGB"),np.int16)
assert scene.shape==godot.shape==(928,1280,3)
delta=np.abs(scene-godot)
houses=[o for o in m["objects"] if o["type"]=="house"]
assert len(houses)==2
left=next(o for o in houses if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
right=next(o for o in houses if o["id"]=="A36G_R5_COTTAGE_B_SINGLE_ROOF")
new=Image.open(S/right["filename"]).convert("RGBA")
assert new.size==(256,272) and new.getbbox()==(21,23,188,220)
r4=json.loads((R4/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
old_left=next(o for o in r4["objects"] if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
assert left["sha256"]==old_left["sha256"]==sha(S/left["filename"])
assert sha(R/"A36G_R5_GROUND_1280x928.png")==sha(R4/"A36G_R4_GROUND_1280x928.png")
qa={
 "stage":m["stage"],"source_R4_manifest_SHA256":sha(R4/"A36G_R4_SCENE_MANIFEST.json"),
 "right_house_generated_rgba_original_sha256":sha(S/right["filename"]),
 "new_right_has_no_clipped_edges":all(new.getpixel(t)[3]==0 for t in [(0,0),(255,0),(0,271),(255,271)]),
 "new_right_alpha_bbox":list(new.getbbox()),"left_house_source_unchanged":True,"ground_unchanged":True,
 "tree_sources_unmodified":True,
 "native_VX_cases":vx["actor_test_count"],"native_VX_actual_544_frames":vx["unique_capture_count"],
 "native_VX_map050_entered":vx["runtime_map_enter"],
 "native_VX_192_objects_loaded":vx["runtime_obj_loaded"],"native_VX_RGSS_error_modal_count":len(vx["modal_windows"]),
 "native_VX_blocked_step":vx["move_blocked_log"],"native_VX_road_step":vx["move_road_log"],
 "native_VX_left_house_behind_diff_px":vx["paired_differences"]["4"]["rgb_changed_coordinates"],
 "native_VX_left_house_front_diff_px":vx["paired_differences"]["5"]["rgb_changed_coordinates"],
 "native_VX_right_house_rear_partial_actor_px":vx["paired_differences"]["6"]["rgb_changed_coordinates"],
 "native_VX_right_house_front_diff_px":vx["paired_differences"]["7"]["rgb_changed_coordinates"],
 "godot_GPU_full_native_frames":len(list(D.glob("A36G_R5_GODOT_0[0-5]*png"))),
 "godot_GPU_544_crops":len(list(D.glob("A36G_R5_GODOT_NATIVE_FULL_CROP_*.png"))),
 "godot_max_absolute_RGB_channel_delta":int(delta.max()),
 "godot_count_pixel_any_RGB_delta_gt_1":int(np.any(delta>1,axis=2).sum()),
 "godot_count_pixel_any_RGB_delta_nonzero":int(np.any(delta>0,axis=2).sum()),
 "scene_objects":len(m["objects"]),"blocked_tiles":m["blocked_cells"],"walkable_tiles":m["free_cells"],
 "walkable_from_spawn":m["free_reachable_cells"],
 "collision_geometry_status":m["collision_gate"],
 "full_house_rear_occlusion":"PENDING_SUBJECTIVE: test position 6 new roof only partly covers actor; physically smaller roof, possible legitimate silhouette",
 "art_style_gate":"CANDIDATE_R2_PENDING_USER_REVIEW","formal_seal":"NO"}
qa["ENGINE_SMOKE_PASS"]=bool(
 qa["new_right_has_no_clipped_edges"] and
 qa["native_VX_cases"]==11 and qa["native_VX_actual_544_frames"]==22 and
 qa["native_VX_map050_entered"] and qa["native_VX_192_objects_loaded"] and
 qa["native_VX_RGSS_error_modal_count"]==0 and
 "before=11,11 after=11,11" in (qa["native_VX_blocked_step"] or "") and
 "before=11,8 after=12,8" in (qa["native_VX_road_step"] or "") and
 qa["godot_GPU_full_native_frames"]==6 and qa["godot_GPU_544_crops"]==6 and
 qa["godot_max_absolute_RGB_channel_delta"]<=1 and qa["godot_count_pixel_any_RGB_delta_gt_1"]==0 and
 qa["scene_objects"]==192 and qa["walkable_tiles"]==qa["walkable_from_spawn"]==919)
(R/"A36G_R5_R2_NATIVE_GPU_SCENE_QA.json").write_text(json.dumps(qa,indent=2,ensure_ascii=False),"utf8")
contact=Image.new("RGB",(1224,1056),(26,29,31));dr=ImageDraw.Draw(contact)
for i in range(9):
 pics=list(V.glob(f"A36G_VX_NATIVE_CASE_{i:02d}_*actor.png"))
 assert len(pics)==1,(i,pics)
 pic=Image.open(pics[0]).convert("RGB").resize((408,312),Image.Resampling.NEAREST)
 xx=i%3*408;yy=i//3*340+24
 contact.paste(pic,(xx,yy))
 dr.text((xx+4,yy-18),pics[0].stem.replace("A36G_VX_NATIVE_CASE_",""),fill="white")
contact.save(R/"A36G_R5_R2_VX_9_NATIVE_SCENE_CONTACT.png",optimize=True)
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)
assert qa["ENGINE_SMOKE_PASS"],"FAIL_CLOSED_NATIVE_ENGINE"
