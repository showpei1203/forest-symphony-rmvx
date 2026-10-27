#!/usr/bin/env python3
"""Fail-closed R8 technical gate. Real artistic completeness and formal untouched 505 boot remain HOLD."""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image
import json,hashlib
ROOT=Path(__file__).resolve().parent
D=ROOT/"R8_USER_ANNOTATION_20261028";N=ROOT/"R8_NATIVE_FULL_MASTER"
authority=json.loads((D/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
sam=json.loads((D/"R8_SAM2_USER_ANNOTATION_RESULT.json").read_text(encoding="utf8"))
spatial=json.loads((D/"R8_4DIR_FOOTPRINT_AUDIT.json").read_text(encoding="utf8"))
baseline=json.loads((D/"R8_BASELINE_RED_BLUE_COVERAGE.json").read_text(encoding="utf8"))
build=json.loads((N/"R8_BUILD_MANIFEST.json").read_text(encoding="utf8"))
assert len(authority["user_red"])==8 and len(authority["user_blue"])==1
assert len(authority["rules"])==8
assert sam["sam2_prompt_consistent_count"]==8 and sam["red_individual_seed_test_pass"]==8
assert sam["blue_step_core_alpha"]==0
assert sam["all_par_opaque_pixels_match_source_rgb"] is True
assert len(spatial["results"])==8
assert build["object_count"]==20 and build["all_20_depth_sprites_blue_excluded"]
assert baseline["red_seed_coarse_present"]==0 and bool(baseline["blue_exclusion_violations"])
source=Image.open(ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA")
par=Image.open(D/"PAR_R8_USER_RED_BLUE_SOURCE_ALIGNED.png").convert("RGBA")
assert source.size==par.size==(544,416)
cnt=0
for a,b in zip(source.getdata(),par.getdata()):
 if b[3]:
  cnt+=1
  assert a[:3]==b[:3],("DIFFERENT_RGB",cnt,a,b)
assert cnt==sam["r8_union_px"]
excluded=Image.open(D/"R8_BLUE_STEPS_HARD_EXCLUSION_MASK.png").convert("L")
for px,mask in zip(par.getchannel("A").getdata(),excluded.getdata()):
 if mask:assert px==0
blue_rect=authority["user_blue"][0]["core"]
original_source=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
formal_hash="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(original_source.read_bytes()).hexdigest()==formal_hash
form=load(original_source.open("rb"))
current=load((N/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
assert len(form)==505 and len(current)==506
assert all(current[i if i<482 else i+1]==form[i] for i in range(505) if i!=480)
for i in [145,146,342]:assert current[i]==form[i]
# All sprites must individually respect user blue. Do not only remove it from union Par1.
ids=[o["id"] for o in json.loads((ROOT/"R7_SEMANTIC_MASK_CANDIDATES"/"R7_SAM2_PROMPT_REGISTRY_GATE.json").read_text())["objects"]]
ids+=[o["id"] for o in authority["user_red"]]
assert len(ids)==20
for id in ids:
 png=Image.open(N/"FULL505"/"Graphics"/"Pictures"/("R5_OC_"+id+".png")).convert("RGBA")
 core=png.getchannel("A").crop(tuple(blue_rect))
 assert core.getbbox() is None,id
names=["RED_HOUSE_CONIFER","RED_FAR_RIGHT_CONIFER","RED_LEFT_INNER_MICRO","RED_BOTTOM_MICRO","BLUE_STEPS","CLEAR"]
replays=[]
for dirname in ["REPLAY1_NATIVE_ABA","NATIVE_ABA"]:
 directory=N/dirname
 meta=json.loads((directory/"R6_CAPTURE_MANIFEST.json").read_text())
 audit=json.loads((directory/"R6_PIXEL_GATE.json").read_text())
 assert meta["status"]=="R6_NATIVE_CAPTURE_PASS" and len(meta["files"])==18
 assert [x["case"] for x in audit["cases"]]==names
 assert "R6_SAME_SESSION_A_B_A_COMPLETE" in (directory/"GAME_LOG.txt").read_text(errors="replace")
 rec=[]
 for item in audit["cases"]:
  a=item["A1_A2_CONTROL_threshold_0"]
  ab=item["A1_B_threshold_0"]
  assert a["total"]==0,("CONTROL_NOT_REVERSIBLE",dirname,item["case"])
  assert ab["nonactor"]==0,("BG_CHANGE",dirname,item["case"])
  for k in ("A1","B","A2"):
   assert Image.open(directory/(item["case"]+"__"+k+".png")).size==(544,416)
  rec.append({"case":item["case"],"actor_changed_px":ab["actor_union"],"background_changed_px":ab["nonactor"],"A1A2_total_px":a["total"]})
 assert next(z for z in rec if z["case"]=="BLUE_STEPS")["actor_changed_px"]==0
 assert next(z for z in rec if z["case"]=="CLEAR")["actor_changed_px"]==0
 assert all(next(z for z in rec if z["case"]==name)["actor_changed_px"]>0 for name in ["RED_FAR_RIGHT_CONIFER","RED_LEFT_INNER_MICRO","RED_BOTTOM_MICRO"])
 replays.append({"folder":dirname,"pid":meta["same_single_pid"],"images":18,"results":rec})
assert replays[0]["results"]==replays[1]["results"],"NONDETERMINISTIC_NATIVE_REPLAY"
assert replays[0]["pid"]!=replays[1]["pid"],"NOT_INDEPENDENT_PROCESS"
result={
 "status":"R8_USER_ANNOTATION_COMPOSITE_PAR_AND_NATIVE_TWO_RUN_TECH_PASS_ART_HOLD",
 "user_red_mandatory_count":8,"user_blue_excluded_count":1,
 "R7_red_core_misses":baseline["red_seed_coarse_missing"],
 "R8_red_core_verified":sam["red_individual_seed_test_pass"],
 "R8_prompt_positive_negative_consistency":sam["sam2_prompt_consistent_count"],
 "blue_steps_par_alpha_pixels":sam["blue_step_core_alpha"],
 "r7_blue_removed_alpha_px":sam["removed_r7_alpha_for_user_blue_px"],
 "r8_new_alpha_px":sam["added_alpha_px"],
 "r8_union_source_exact_color_px":cnt,
 "native_20_objects_respect_blue":True,
 "two_native_independent_sessions":True,"total_native_shots":36,"replays":replays,
 "formal_fs_source_sha256":formal_hash,"formal_source_modified":False,
 "original_byte_identical_fs_pages":504,"formal_page480_disabled_in_isolated_clone":True,
 "original_505_unmodified_native_boot":"FAIL_KNOWN_REGRESSION_HARNESS_ALIAS",
 "artistic_object_edges_and_complete_map_semantics":"HOLD",
 "blue_annotated_548x400_to_source_544x416_manual_registration":"CANDIDATE",
 "original_formal_map_passability":"NOT_TESTED",
 "actual_4dir_character_pathing":"NOT_TESTED",
 "animation_shadow_light_loop":"NOT_TESTED",
 "user_gate_f":"HOLD",
 "red_house_conifer_A_B_zero_note":"Player test tile (13,5) has no alpha overlap in front; independent 4dir scan finds behind tile (13,3) with 261 actor mask pixels overlap. Does not prove missing occlusion or correct human outline; retest independently."
}
(N/"R8_FINAL_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("R8_FAIL_CLOSED_GATE",result["status"],json.dumps({"red":result["R8_red_core_verified"],"blue":result["blue_steps_par_alpha_pixels"],"native":result["total_native_shots"],"actor_changes":[(x["case"],x["actor_changed_px"]) for x in replays[0]["results"]]}),flush=True)