#!/usr/bin/env python3
"""R13 strict new rule source mask + 32px registry + 52 sprite native two session gate.
Fail-closed visual art remains HOLD, due conservative full tile rescue possibly over-occluding ground.
"""
from pathlib import Path
from PIL import Image,ImageChops
from rubymarshal.reader import load
import hashlib,json,re
R=Path(__file__).resolve().parent;D=R/"R13_TILE_OCCLUSION_PAR_20261028"
N=R/"R13_NEW_ELF_VILLAGE_NATIVE";Q=R/"R12_NEW_ELF_VILLAGE_001"
root=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
new=Q/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
assert hashlib.sha256(new.read_bytes()).hexdigest()=="eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80"
assert hashlib.sha256((root/"Data"/"Scripts.rvdata").read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256((root/"Data"/"Map003.rvdata").read_bytes()).hexdigest()=="118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4"
assert hashlib.sha256((N/"FULL505"/"Graphics"/"Parallaxes"/"ground3.png").read_bytes()).hexdigest()==hashlib.sha256(new.read_bytes()).hexdigest()
reg=json.loads((D/"R13_GRID_PAR_CANDIDATE_REGISTRY.json").read_text(encoding="utf8"))
spr=json.loads((D/"R13_OPTIMIZED_SPRITE_MANIFEST.json").read_text(encoding="utf8"))
assert len(reg["objects"])==len(spr["objects"])==52
assert len(reg["candidate_tiles"])==843
assert reg["counts"]["rail_objects"]==16 and reg["counts"]["lamp_objects"]==10 and reg["counts"]["tree_objects"]==9
orig=Image.open(new).convert("RGB")
par=Image.open(D/"PAR_R13_GRID_FIRST_SOURCE_CANDIDATE.png").convert("RGBA")
alpha=par.getchannel("A")
mask_sum=sum(1 for px in alpha.getdata() if px)
assert mask_sum==reg["counts"]["new_alpha_px"]==684860
diff=ImageChops.difference(par.convert("RGB"),orig)
assert Image.composite(diff,Image.new("RGB",orig.size,(0,0,0)),alpha).getbbox() is None
total_root_exceptions=0
for obj in reg["objects"]:
 p=D/(obj["id"]+"_PAR.png")
 image=Image.open(p).convert("RGBA")
 layer_alpha=image.getchannel("A")
 assert layer_alpha.getbbox() is not None
 diff=ImageChops.difference(image.convert("RGB"),orig)
 assert Image.composite(diff,Image.new("RGB",orig.size,(0,0,0)),layer_alpha).getbbox() is None,obj["id"]
 if obj["root_exclusion"] is not None:
  total_root_exceptions+=1
  x,y=obj["root_exclusion"]
  assert layer_alpha.crop((x*32,y*32,(x+1)*32,(y+1)*32)).getbbox() is None,obj["id"]
for ob in spr["objects"]:
 crop=Image.open(D/ob["crop_filename"]).convert("RGBA")
 assert crop.size==tuple(ob["rgba_bbox_size"])
 x0,y0,x1,y1=ob["bbox"]
 
 assert ImageChops.difference(crop,Image.open(D/(ob["id"]+"_PAR.png")).convert("RGBA").crop((x0,y0,x1,y1))).getbbox() is None,ob["id"]
 assert (N/"FULL505"/"Graphics"/"Pictures"/("R5_OC_"+ob["id"]+".png")).is_file()
assert total_root_exceptions>=10
formal=load((root/"Data"/"Scripts.rvdata").open("rb"))
pages=load((N/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
assert len(pages)==506 and all(pages[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
assert hashlib.sha256((N/"FULL505"/"Data"/"Map001.rvdata").read_bytes()).hexdigest()==hashlib.sha256((root/"Data"/"Map003.rvdata").read_bytes()).hexdigest()
cases=json.loads((Q/"R12_NATIVE_TEST_CASES.json").read_text(encoding="utf8"))
assert len(cases)==14
runs=[]
for branch in ["REPLAY1","NATIVE"]:
 p=N/branch
 v=json.loads((p/"R13_NATIVE_GATE.json").read_text(encoding="utf8"))
 assert v["status"]=="R13_NEW_MASTER_GRID_PAR52_NATIVE_TECH_PASS",branch
 assert len(v["captures"])==14 and all(row["gate"] for row in v["tests"])
 logfile=(p/"GAME_LOG.txt").read_text(encoding="utf8")
 first=re.search(r"^R12_WORLD (.+)$",logfile,re.M)
 assert first and "objects=52" in first.group(1) and "source_sample=[3, 22, 18]" in first.group(1)
 for tag in v["captures"]:
  assert Image.open(p/(tag+".png")).size==(544,416)
  pattern=re.compile(r"^R12_SCREEN "+re.escape(tag)+r" (.+)$",re.M)
  match=pattern.search(logfile)
  assert match,tag
  m=re.search(r"camera=\[(\d+), (\d+)\] parObjXY=\[(-?\d+), (-?\d+)\] parObjWorldBase=\[(\d+), (\d+)\] sourceObjCount=(\d+)",match.group(1))
  assert m,(branch,tag,match.group(1))
  camx,camy,spx,spy,ox,oy,count=(int(a) for a in m.groups())
  assert [spx,spy]==[ox-camx//8,oy-camy//8] and count==52,(tag,m.groups())
 runs.append({"run":branch,"pid":v["game_pid"],"screenshot_count":len(v["captures"]),
              "actual_movement_pass":14,"source_ground_cache_pixel_match":True,"world_offset_match":True})
assert runs[0]["pid"]!=runs[1]["pid"]
report={
"status":"R13_NEW_PAR32_GRID_52_OBJECTS_NATIVE_TWO_RUN_TECH_PASS_ART_HOLD",
"authority":"FS_R13_PAR_32PX_OCCLUSION_TILE_RULES_20261028.md",
"formal_original_source_untouched":True,
"new_master_1280x928_source_unchanged":True,
"R12_PAR_benchmark_source_untouched":True,
"new_par52_nontransparent_px_sourceRGB_exact":reg["counts"]["new_alpha_px"],
"r12_old_par_alpha_px":reg["counts"]["old_alpha_px"],
"r13_new_additional_covered_px":reg["counts"]["new_only_px"],
"r13_omitted_R12_alpha_px":reg["counts"]["lost_vs_R12_px"],
"omitted_R12_alpha_reason":"Ground step/carved decks + individual trees root-base, must visually audit",
"candidate_32px_tiles":reg["include_tile_count"],
"candidate_total_40x29_tiles":1160,
"object_count":52,
"object_subcategories":{"tree_new":9,"lamp":10,"railings":16,"other_uprights":3,"legacy_R12_selected":14},
"individual_tree_root_base_tiles_excluded":total_root_exceptions,
"source_cropped_texture_saving_frac":spr["virtual_bitmap_memory_reduction"],
"two_independent_native_runs":runs,
"native_screenshots_total":28,
"original_FS_scripts_505_full_unmodified_boot":False,
"original_formal_25_Map003_events_fullplay":False,
"same_session_static_dynamic_A_B_A_during_camera_scroll":False,
"full_tile_overshadow_ground_visual_risk":True,
"some_polygons_include_floor_pixels":True,
"semantic_all_obstacle_completeness_proven":False,
"human_visual_gate_F":"HOLD",
"final_seal":False,
"next_actions":["Manually review 1x 40x29 R13 pink coverage, especially plaza, building steps, tree root and lamps","Reduce over-occlusion per cell with isolated pixel masks without losing 32px semantic marked tiles","Add missed tiny fences and lights based on user feedback","Run native A/B/A front and rear character depth + full-scene parallax animation"]
}
(N/"R13_FINAL_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R13_FINAL_GATE",json.dumps({"state":report["status"],"alpha":mask_sum,"native":report["native_screenshots_total"],"tree_base_exclusions":total_root_exceptions}),flush=True)