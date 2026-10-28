#!/usr/bin/env python3
"""Fail closed: R11 official Map003 40x29 K4 exact, two large Map native and two 5-source-object
large PAR native runs, exact source mask RGB + world camera compensation.
Strictly TECH-only; scene2 original events/full 505 boot/automated art generation remain HOLD.
"""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image
import json,hashlib,re
R=Path(__file__).resolve().parent
K=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
orig_map=K/"Data"/"Map003.rvdata";scripts=K/"Data"/"Scripts.rvdata"
assert hashlib.sha256(orig_map.read_bytes()).hexdigest()=="118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4"
assert hashlib.sha256(scripts.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
src=Image.open(K/"Graphics"/"Parallaxes"/"ground3.png").convert("RGB")
assert src.size==(1280,928)
m=json.loads((R/"R11_VILLAGE_SIZE_TECH"/"R11_GROUND3_5OBJECT_SAM2_GATE.json").read_text(encoding="utf8"))
assert m["sam2_objects"]==m["prompt_consistent_count"]==5
assert m["source_generated_new_art"] is False and m["rgb_from_source_exact"]
par=Image.open(R/"R11_VILLAGE_SIZE_TECH"/"R11_GROUND3_5OBJECT_SOURCE_PAR_CANDIDATE.png").convert("RGBA")
assert par.size==(1280,928)
par_alpha=par.getchannel("A")
assert sum(1 for v in par_alpha.getdata() if v)>270000
for x,y in zip(src.getdata(),par.getdata()):
 if y[3]>0:assert y[:3]==x
formal_pages=load(scripts.open("rb"))
result_runs=[]
ids=["L01_CENTER_RIGHT","L02_CENTER_DOWN_BLOCK","L03_EAST_UPPER_RIGHT",
"L04_EAST_MID_DOWN","L05_WEST_WALK","L06_WEST_BLOCK",
"L07_SOUTH_RIGHT","L08_SOUTH_WALK","L09_SOUTH_BLOCK","L10_LEFT_BORDER"]
for branch,art in [("R11_GROUND3_40x29_NATIVE",False),("R11_GROUND3_5OBJECT_NATIVE",True)]:
 base=R/branch
 assert hashlib.sha256((base/"FULL505"/"Data"/"Map001.rvdata").read_bytes()).hexdigest()==hashlib.sha256(orig_map.read_bytes()).hexdigest()
 pages=load((base/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
 assert len(pages)==506 and all(pages[i if i<482 else i+1]==formal_pages[i] for i in range(505) if i!=480)
 for folder in ["NATIVE_REPLAY1","NATIVE"]:
  p=base/folder
  gate=json.loads((p/"R11_NATIVE_GATE.json").read_text(encoding="utf8"))
  assert gate["status"]==("R11_GROUND3_PAR5_NATIVE_PASS" if art else "R11_MAP003_LARGE_NATIVE_PASS")
  assert sorted(gate["shots"])==sorted(ids)
  assert all(z["pass"] for z in gate["cases"])
  log=(p/"GAME_LOG.txt").read_text(encoding="utf8")
  assert "R11_NATIVE_MAP_INFO dim=40x29 par=ground3" in log
  for test_id in ids:
   assert Image.open(p/(test_id+".png")).size==(544,416)
  offsets=[]
  for id in ids:
   mm=re.search(r"^R11_SHOT "+re.escape(id)+r" .+ camera=\[(\d+), (\d+)\](?: objectCount=5 firstObjXY=(-?\d+),(-?\d+))? complete=true$",log,re.M)
   assert mm is not None,(branch,folder,id)
   display=(int(mm.group(1)),int(mm.group(2)))
   if art:
    assert mm.group(3) and mm.group(4)
    xy=(int(mm.group(3)),int(mm.group(4)))
    assert xy==(-display[0]//8,-display[1]//8),(id,display,xy)
   offsets.append(display)
  assert max(x for x,y in offsets)>0 and max(y for x,y in offsets)>0
  result_runs.append({"kind":"large_5object_PAR" if art else "large_original_map_scale_only",
     "session":folder,"pid":gate["game_pid"],"images":len(gate["shots"]),
     "max_camera_display":[max(x for x,y in offsets),max(y for x,y in offsets)],
     "camera_map_to_sprite_offset_verified":bool(art)})
assert len({x["pid"] for x in result_runs})==4
payload={
 "status":"R11_MAP003_40x29_NATIVE_SCROLL_AND_5OBJECT_SAME_SOURCE_PAR_TECH_PASS_ART_HOLD",
 "formal_source_505_sha256":"5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa",
 "formal_map003_sha256":"118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4",
 "formal_source_modified":False,"original_map003_byte_exact_in_isolated":True,
 "ground3_1280_928_source_unmodified":True,
 "new_village_art_generated":False,
 "artistic_quality_of_new_map_proven":False,
 "five_large_source_par_masks_from_ground3":True,
 "five_prompt_consistency_pass":True,
 "par_opaque_pixels_exact_source_RGB":True,
 "sprite_scroll_compensation_5_objects_native_pass":True,
 "total_native_four_runs":len(result_runs),
 "total_real_game_exe_screenshots":sum(x["images"] for x in result_runs),
 "runs":result_runs,
 "official_map003_original_event_count":25,
 "official_map003_25_events_original_runtime_tested":False,
 "original_505_boot_passed":False,"isolated_original_page480_disabled":True,
 "native_ART_par_complete":"HOLD",
 "original_ground3_actual_performance_FPS_measured":False,
 "multi_NPC_dynamic_continuous_move_camera_pass":"NOT_TESTED",
 "large_parallax_STATIC_dynamic_ABA_during_scroll":"NOT_TESTED",
 "full_ground3_complete_par_occlusion_approved":False,
 "original_Ground10_animated_light_shadow_native":"NOT_TESTED",
 "recommend_start_new_1280_928_village_master_controlled_trial":True,
 "new_village_formal_seal":"HOLD",
 "next_gate":["User style reference art: create ONE new full 1280x928 visual master at ground3-level detail, no tile repeats or blur",
              "Prove source-only extraction covering all objects with no omission and accurate blue exclusions",
              "Compile verified building/terrain footprint collision, keep micro plant optional pass",
              "Native VX 40x29 static/dynamic same-session camera scroll, normal movement, multiple NPC, animated ground and light/shadow",
              "Human visual Gate F, only then formal seal"]}
out=R/"R11_VILLAGE_SIZE_TECH"/"R11_FINAL_GATE.json"
out.write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding="utf8")
print("R11_FINAL",json.dumps({"status":payload["status"],"native_images":payload["total_real_game_exe_screenshots"],
 "runs":result_runs,"new_art":payload["new_village_art_generated"]},ensure_ascii=False),flush=True)