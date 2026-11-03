from pathlib import Path
import numpy as np,json,hashlib
from PIL import Image,ImageDraw
G=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
F=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
D=G/"GODOT_A36G_PIXELLAB_R3B_40x29"/"out"
C=G/"R3B_VX_CAPTURES"
S=G/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
m=json.loads((G/"A36G_SCENE_MANIFEST.json").read_text("utf8"))
vx=json.loads((C/"A36G_VX_NATIVE_11_CASES_SCREEN_QA.json").read_text("utf8"))
a=np.asarray(Image.open(G/"A36G_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB"),dtype=np.int16)
b=np.asarray(Image.open(D/"A36G_GODOT_00_FULL_NO_ACTOR_1280x928.png").convert("RGB"),dtype=np.int16)
dv=np.abs(a-b)
house=next(o for o in m["objects"] if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
forest=m["forest_region_blueprint"]
h=S/house["filename"];n=S/forest["source_file"];c=S/forest["compiled_alpha_file"]
assert all(x.exists() for x in (h,n,c))
himg=Image.open(h).convert("RGBA")
nimg=Image.open(n).convert("RGBA")
cm=Image.open(c).convert("RGBA")
assert himg.size==(284,259) and nimg.size==cm.size==(464,576)
assert len(m["objects"])==418
assert len([o for o in m["objects"] if o["type"]=="forest_group"])==6
qa={
 "stage":m["stage"],"base_authority":"A36F_R1; baseline never modified",
 "baseline_manifest_sha256":sha(F/"A36F_SCENE_MANIFEST.json"),
 "source_house_sha256":sha(h),"source_house_size_px":list(himg.size),"source_house_alpha_bbox":list(himg.getbbox()),
 "source_forest_sha256":sha(n),"source_forest_size_px":list(nimg.size),
 "source_forest_alpha_bbox":list(nimg.getbbox()),
 "compiled_forest_sha256":sha(c),"offscreen_group_origin":forest["bbox"][:2],
 "reused_A36F_standalone_sprites_outside_group":forest["restored_A36F_sprites_outside_region"],
 "scene_objects":len(m["objects"]),"native_forest_depth_strips":6,
 "native_VX_544x416_screens":vx["unique_capture_count"],
 "native_VX_test_cases":vx["actor_test_count"],
 "native_VX_map050_entered":vx["runtime_map_enter"],
 "native_VX_actual_418_loaded":vx["runtime_obj_loaded"],
 "native_VX_RGSS_modal_count":len(vx["modal_windows"]),
 "native_VX_blocked_log":vx["move_blocked_log"],
 "native_VX_road_walk_log":vx["move_road_log"],
 "native_VX_actor_visible_house_front_diff":vx["paired_differences"]["5"]["rgb_changed_coordinates"],
 "native_VX_actor_hidden_behind_house_diff":vx["paired_differences"]["4"]["rgb_changed_coordinates"],
 "godot_native_GPU_1280_frames":len(list(D.glob("A36G_GODOT_0[0-5]*png"))),
 "godot_native_GPU_544_crops":len(list(D.glob("A36G_GODOT_NATIVE_FULL_CROP_*.png"))),
 "godot_R_G_B_channel_max_delta":int(dv.max()),
 "godot_pixels_gt_RGB_delta1":int(np.any(dv>1,axis=2).sum()),
 "godot_pixels_nonzero_delta":int(np.any(dv>0,axis=2).sum()),
 "tile_grid":[40,29],"blocked_cells":m["blocked_cells"],
 "free_cells":m["free_cells"],"free_reachable":m["free_reachable_cells"],
 "old_road_ground_sha256":sha(F/"A36F_GROUND_GRASS_FLOWERS_ROAD_1280x928.png"),
 "new_ground_sha256":sha(G/"A36G_GROUND_1280x928.png"),
 "new_PAR_sha256":sha(G/"A36G_PAR50_RGBA_1280x928.png"),
 "true_composite_sha256":sha(G/"A36G_TRUE_GROUND_PLUS_PAR_1280x928.png"),
 "art_house":"SIGNIFICANTLY_IMPROVED_PENDING_USER_REVIEW",
 "art_forest":"WEST_FIRST_GROUP_VISUAL_IMPROVED_FULL_MAP_STILL_INCOMPLETE",
 "native_actor_occlusion_complete_QA":"DEFER_FULL_SCENE_COVERAGE",
 "full_west_root_collision_QA":"DEFER_PER_ROOT_MAP",
 "cold_rebuild_full_archive":"NOT_RUN",
 "formal_seal":"NO"
}
qa["ENGINE_SMOKE_PASS"]=(qa["scene_objects"]==418 and
 qa["native_VX_544x416_screens"]==22 and qa["native_VX_test_cases"]==11 and
 qa["native_VX_map050_entered"] and qa["native_VX_actual_418_loaded"] and
 qa["native_VX_RGSS_modal_count"]==0 and
 "before=11,11 after=11,11" in (qa["native_VX_blocked_log"] or "") and
 "before=11,8 after=12,8" in (qa["native_VX_road_walk_log"] or "") and
 qa["godot_native_GPU_1280_frames"]==6 and qa["godot_native_GPU_544_crops"]==6 and
 qa["godot_R_G_B_channel_max_delta"]<=1 and qa["godot_pixels_gt_RGB_delta1"]==0 and
 qa["free_cells"]==qa["free_reachable"] and
 qa["new_ground_sha256"]==qa["old_road_ground_sha256"])
(G/"A36G_PIXELLAB_R3B_NATIVE_ENGINE_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),"utf8")
panel=Image.new("RGB",(1224,1056),(27,30,33));dr=ImageDraw.Draw(panel)
for i in range(9):
 pics=list(C.glob(f"A36G_VX_NATIVE_CASE_{i:02d}_*actor.png"))
 assert len(pics)==1,(i,pics)
 im=Image.open(pics[0]).convert("RGB").resize((408,312),Image.Resampling.NEAREST)
 x=i%3*408;y=i//3*340+24
 panel.paste(im,(x,y))
 dr.text((x+4,y-18),pics[0].stem.replace("A36G_VX_NATIVE_CASE_",""),fill="white")
panel.save(G/"A36G_PIXELLAB_R3B_VX_9_REGION_CONTACT.png",optimize=True)
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)
assert qa["ENGINE_SMOKE_PASS"],"R3B_NATIVE_GPU_X_VX_SMOKE_FAIL"