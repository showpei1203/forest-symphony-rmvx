#!/usr/bin/env python3
"""R6 fail-closed technical renderer gate with 2 independent native replays.
Technical != semantic/art/VX formal 505 full regression.
"""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image
import hashlib,json
ROOT=Path(__file__).resolve().parent
DIR=ROOT/"R6_SAME_SESSION_ISOLATED"
ORIG=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
script=DIR/"FULL505"/"Data"/"Scripts.rvdata"
# Explicit actual source SHA guard
SOURCE_SHA="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(ORIG.read_bytes()).hexdigest()==SOURCE_SHA
b=load(ORIG.open("rb"));a=load(script.open("rb"))
assert len(b)==505 and len(a)==506
assert all(a[j if j<482 else j+1]==b[j] for j in range(505) if j!=480)
for index in [145,146,342]:assert a[index]==b[index]
cases=["PLAYER_FRONT_NPC_BEHIND","PLAYER_BEHIND_NPC_FRONT","BOTH_FRONT","BOTH_BEHIND","CLEAR"]
review=[]
for folder_name in ["R6_FROZEN_PASS_REPLAY_1","NATIVE_ABA"]:
 folder=DIR/folder_name
 m=json.loads((folder/"R6_CAPTURE_MANIFEST.json").read_text())
 p=json.loads((folder/"R6_PIXEL_GATE.json").read_text())
 assert m["status"]=="R6_NATIVE_CAPTURE_PASS" and len(m["files"])==15
 assert "R6_FROZEN_RENDER_GATES_ON" in (folder/"GAME_LOG.txt").read_text(errors="replace")
 for case in cases:
  for mode in ("A1","B","A2"):
   assert (folder/(case+"__"+mode+".png")).is_file()
   assert Image.open(folder/(case+"__"+mode+".png")).size==(544,416)
 assert [x["case"] for x in p["cases"]]==cases
 for x in p["cases"]:
  assert x["A1_A2_CONTROL_threshold_0"]["total"]==0,(folder_name,x["case"],"controller temporal changed")
  assert x["A1_B_threshold_0"]["nonactor"]==0,(folder_name,x["case"],"NON_ACTOR_DIFF")
  assert x["A1_B_threshold_0"]["actor_union"]==x["A1_B_threshold_0"]["total"]
 assert p["cases"][0]["A1_B_threshold_0"]["actor_union"]>0
 assert p["cases"][1]["A1_B_threshold_0"]["actor_union"]>0
 assert p["cases"][2]["A1_B_threshold_0"]["actor_union"]>0
 assert p["cases"][3]["A1_B_threshold_0"]["total"]==0
 assert p["cases"][4]["A1_B_threshold_0"]["total"]==0
 review.append({"folder":folder_name,"images":len(m["files"]),"same_game_pid":m["same_single_pid"],
 "threshold0":{"cases":[{"case":x["case"],"changed_actor_px":x["A1_B_threshold_0"]["actor_union"],
                              "nonactor_px":x["A1_B_threshold_0"]["nonactor"],
                              "A1_A2_px":x["A1_A2_CONTROL_threshold_0"]["total"]} for x in p["cases"]]},
 "visual_gate":"TECH_PASS","semantic_art_gate":"HOLD"})
out={"status":"R6_NATIVE_VX_RENDERER_ABA_REPEATABLE_TECH_PASS","formal_505_unmodified_runtime":False,
 "formal_baseline_original_sha256":SOURCE_SHA,
 "sealed_files_modified":False,"source_505_pages":505,"pages_identical_in_isolated_test":504,
 "original_regression_page_480_test_only_disabled":True,"original_HK_145":True,"original_Animated_146":True,"original_ISS_Passa_342":True,
 "test_only_added_r6_adapter":True,"two_independent_actual_native_runs":True,
 "all_five_cases_threshold_zero_no_nonactor_change":True,"all_controls_A1_A2_exactly_equal":True,
 "all_source_masks_semantic_quality_passed":False,"all_full_ground_PAR_visual_gate_passed":False,
 "no_live_NPC_path_or_large_map_40x29_test":True,"replays":review}
(DIR/"R6_FINAL_GATE.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"status":out["status"],"replays":[(x["folder"],[(z["case"],z["changed_actor_px"]) for z in x["threshold0"]["cases"]]) for x in review]},ensure_ascii=False),flush=True)