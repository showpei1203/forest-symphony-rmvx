"""A36G R4 R3 separate engine vs art gate: 192 native VX sprites, actual Godot GPU, 6 distinct forest source RGBA."""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
R=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
F=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
R3=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
D=R/"GODOT_A36G_R4_R3_40x29"/"out"
V=R/"R4_R3_VX_CAPTURES"
S=R/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((R/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
vx=json.loads((V/"A36G_VX_NATIVE_11_CASES_SCREEN_QA.json").read_text("utf8"))
assert m["stage"]=="A36G_R4_6REGIONS_R3_ROOT_ART_FIX_ENGINE_CANDIDATE"
a=np.asarray(Image.open(R/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB"),dtype=np.int16)
b=np.asarray(Image.open(D/"A36G_R4_GODOT_00_FULL_NO_ACTOR_1280x928.png").convert("RGB"),dtype=np.int16)
delta=np.abs(a-b)
assert a.shape==b.shape==(928,1280,3)
blocked={(x,y) for y,row in enumerate(m["collision_map_29x40"]) for x,v in enumerate(row) if v}
root=json.loads((R/"A36G_R4_ROOT_COVERAGE_QA.json").read_text("utf8"))
restored=m["restored_legacy_tree_ids_after_seam_audit"]
forest=m["forest_regions_R4"]
source_count=len(forest)
native_files=[p for p in V.glob("A36G_VX_NATIVE_CASE_*.png")]
assert source_count==6 and len(native_files)==22
qa={
 "stage":m["stage"],
 "source":["A36F_R1","A36G_R3B"],
 "real_640_before_after_exists":(R/"A36G_R3B_VS_R4_TRUE_GROUND_PAR_BEFORE_AFTER.png").exists(),
 "actual_native_VX_image_count":len(native_files),
 "actual_native_VX_case_pairs":vx["actor_test_count"],
 "actual_native_VX_client_size":vx["client_size"],
 "native_VX_map_enter":vx["runtime_map_enter"],
 "native_VX_loaded_192":vx["runtime_obj_loaded"],
 "native_VX_modal_windows":len(vx["modal_windows"]),
 "native_VX_blocked_move":vx["move_blocked_log"],
 "native_VX_legal_road_move":vx["move_road_log"],
 "godot_native_full_frames":len(list(D.glob("A36G_R4_GODOT_0[0-5]*png"))),
 "godot_native_544_crops":len(list(D.glob("A36G_R4_GODOT_NATIVE_FULL_CROP_*.png"))),
 "godot_GPU_RGB_channel_max_delta":int(delta.max()),
 "godot_pixels_any_RGB_channel_gt1":int(np.any(delta>1,axis=2).sum()),
 "godot_pixels_any_RGB_channel_nonzero":int(np.any(delta>0,axis=2).sum()),
 "scene_objects":len(m["objects"]),
 "independent_forest_source_count":source_count,
 "forest_new_depth_strips":sum(q["new_depth_strips"] for q in forest),
 "forest_source_RGB_recomputed":False,
 "forest_source_alpha_compiled":True,
 "source_root_blocks_replaced":sum(q["former_blocking_tree_roots"] for q in forest),
 "root_anchor_repair_count":len(restored),
 "root_semantic_mapping_gate":"PENDING_NATIVE_PER_ROOT_VERIFICATION",
 "blocked_tiles":len(blocked),
 "free_tiles":m["free_cells"],
 "free_connected":m["free_reachable_cells"],
 "ground_unchanged_sha256":sha(R/"A36G_R4_GROUND_1280x928.png")==sha(F/"A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png"),
 "par_sha256":sha(R/"A36G_R4_PAR50_RGBA_1280x928.png"),
 "composite_sha256":sha(R/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png"),
 "A36F_source_immutable_sha256":sha(F/"A36F_SCENE_MANIFEST.json"),
 "R3B_source_immutable_sha256":sha(R3/"A36G_SCENE_MANIFEST.json"),
 "full_art_review":"PENDING_USER",
 "all_root_semantic_art":"PENDING",
 "formal_seal":"NO"}
qa["ENGINE_SMOKE_PASS"]=bool(
 qa["actual_native_VX_image_count"]==22 and qa["actual_native_VX_case_pairs"]==11
 and qa["actual_native_VX_client_size"]==[544,416]
 and qa["native_VX_map_enter"] and qa["native_VX_loaded_192"]
 and qa["native_VX_modal_windows"]==0
 and "before=11,11 after=11,11" in (qa["native_VX_blocked_move"] or "")
 and "before=11,8 after=12,8" in (qa["native_VX_legal_road_move"] or "")
 and qa["godot_native_full_frames"]==6 and qa["godot_native_544_crops"]==6
 and qa["godot_GPU_RGB_channel_max_delta"]<=1
 and qa["godot_pixels_any_RGB_channel_gt1"]==0
 and qa["scene_objects"]==192 and qa["independent_forest_source_count"]==6
 and qa["free_tiles"]==qa["free_connected"]==919
 and qa["ground_unchanged_sha256"])
(R/"A36G_R4_R3_NATIVE_GPU_STAGE_QA.json").write_text(json.dumps(qa,indent=2,ensure_ascii=False),"utf8")
contact=Image.new("RGB",(1224,1056),(28,30,34))
dr=ImageDraw.Draw(contact)
for i in range(9):
 pics=list(V.glob(f"A36G_VX_NATIVE_CASE_{i:02d}_*actor.png"))
 assert len(pics)==1,(i,pics)
 im=Image.open(pics[0]).convert("RGB").resize((408,312),Image.Resampling.NEAREST)
 xx=i%3*408;yy=i//3*340+24
 contact.paste(im,(xx,yy))
 dr.text((xx+5,yy-18),pics[0].stem.replace("A36G_VX_NATIVE_CASE_",""),fill="white")
contact.save(R/"A36G_R4_R3_NATIVE_VX_9_REGION_CONTACT.png",optimize=True)
print(json.dumps({k:v for k,v in qa.items() if k not in ("par_sha256","composite_sha256","A36F_source_immutable_sha256","R3B_source_immutable_sha256")},ensure_ascii=False,indent=2))
assert qa["ENGINE_SMOKE_PASS"],"FAIL_CLOSED_R4_NATIVE_GPU_SMOKE_GATE"
