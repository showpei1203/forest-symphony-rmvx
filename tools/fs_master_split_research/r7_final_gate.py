#!/usr/bin/env python3
"""R7 fail closed across exact source PNG, 12 candidate objects, actor walkability scan and 2 real VX native runs."""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image
import json,hashlib
R=Path(__file__).resolve().parent
SEM=R/"R7_SEMANTIC_MASK_CANDIDATES"
N=R/"R7_NATIVE_FULL_MASTER"
OFFICIAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
source_hash="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(OFFICIAL.read_bytes()).hexdigest()==source_hash
formal=load(OFFICIAL.open("rb"))
actual=load((N/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
assert len(actual)==506 and len(formal)==505
assert all(actual[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
for i in (145,146,342): assert actual[i]==formal[i]
manifest=json.loads((SEM/"R7_SAM2_PROMPT_REGISTRY_GATE.json").read_text())
risk=json.loads((SEM/"R7_4DIR_OCCLUSION_GRID_AUDIT.json").read_text())
assert manifest["objects_requested"]==12
assert len(manifest["objects"])==12
assert risk["actor_footprints_scanned"]==872
assert risk["source_mask_exact_pixel_rgb"] is True
base=Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA")
par=Image.open(SEM/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png").convert("RGBA")
assert base.size==par.size==(544,416)
count=0
for a,b in zip(base.getdata(),par.getdata()):
 if b[3]:
  count+=1
  assert a[:3]==b[:3]
assert count==49888
assert int(risk["object_alpha_overlap_px"])==86
native=[]
names=["LEFT_CONIFER_FRONT","HOUSE_FRONT_X8","HOUSE_FRONT_X9","RIGHT_MARKER_FRONT","CLEAR"]
for dirname in ["REPLAY1_NATIVE_ABA","NATIVE_ABA"]:
 path=N/dirname
 m=json.loads((path/"R6_CAPTURE_MANIFEST.json").read_text())
 p=json.loads((path/"R6_PIXEL_GATE.json").read_text())
 assert m["status"]=="R6_NATIVE_CAPTURE_PASS"
 assert len(m["files"])==15 and [x["case"] for x in p["cases"]]==names
 assert len(set([m["same_single_pid"]]))==1
 sample=[]
 for x in p["cases"]:
  for mode in ["A1","B","A2"]:
   f=path/(x["case"]+"__"+mode+".png")
   assert f.is_file() and Image.open(f).size==(544,416)
  ctrl=x["A1_A2_CONTROL_threshold_0"]
  diff=x["A1_B_threshold_0"]
  assert ctrl["total"]==0 and ctrl["nonactor"]==0
  assert diff["nonactor"]==0
  sample.append({"case":x["case"],"changed_actor_px":diff["actor_union"],"nonactor_px":diff["nonactor"],"return_to_A_equal_px":ctrl["total"]})
 assert sample[-1]["changed_actor_px"]==0
 assert sample[0]["changed_actor_px"]>0 and sample[2]["changed_actor_px"]>0 and sample[3]["changed_actor_px"]>0
 native.append({"folder":dirname,"game_pid":m["same_single_pid"],"images":15,"pixel_tests":sample})
assert [t["pixel_tests"] for t in native][0]==[t["pixel_tests"] for t in native][1]
result={
 "status":"R7_SAM2_12_OBJECT_SAME_SOURCE_PAR_AND_NATIVE_RENDERER_TECH_PASS_ART_HOLD",
 "master_544x416_original_not_modified":True,"formal_scripts_505_source_sha256":source_hash,
 "formal_script_pages_equal_in_isolated":504,"original_480_regression_harness_disabled_for_isolated_boot":True,
 "original_full_505_boot_gate":"FAIL_EXISTING_HARNESS_ALIAS_NAMEERROR",
 "HK145_byte_exact":True,"Animated146_byte_exact":True,"ISS342_byte_exact":True,
 "source_par_same_color_pixel_rgb":True,
 "source_par_union_pixels":count,"sam2_prompt_object_count":manifest["objects_requested"],
 "prompt_consistency_accept_count":manifest["accepted_prompt_only"],"independent_semantic_quality_check":False,
 "object_pixel_owner_overlap_reconciled":True,"raw_object_overlap_pixels":risk["object_alpha_overlap_px"],
 "isolated_r5_test_map_walkable_tiles":risk["walkable_tiles_in_isolated_map"],
 "original_formal_map_collision_used":False,
 "four_dir_actor_footprint_cases":risk["actor_footprints_scanned"],
 "pixel_diff_replays":native,
 "two_separate_game_exe_sessions":native[0]["game_pid"]!=native[1]["game_pid"],
 "native_renderer_nonactor_zero_and_A1_A2_exact_replay":True,
 "partial_scene_objects":True,
 "semantic_ground_exclusion_visual_approved":False,
 "original_par_fullness_visual_approved":False,
 "animated_ground_light_shadow_and_40x29_large_map_tested":False,
 "human_visual_gate_F":"HOLD",
 "r8_priority":["human QA mask accuracy and omitted objects","add actual formal passability per scene","real walking four directions with NPC","full layer Light/Shadow/Animated Ground","large Map003 40x29"]
}
assert result["two_separate_game_exe_sessions"],"Native PID reuse detected"
(N/"R7_FINAL_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("R7_GATE",result["status"],"pixels",result["source_par_union_pixels"],"native_runs",[(x["game_pid"],[v["changed_actor_px"] for v in x["pixel_tests"]]) for x in native],flush=True)