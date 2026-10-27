#!/usr/bin/env python3
"""R9 sealed-source guard + two native actual Game_Player movement runs + edge risk hold."""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image
import json,hashlib
R=Path(__file__).resolve().parent
N=R/"R9_NATIVE_WALKING_ISOLATED"
K=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
sha="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert hashlib.sha256(K.read_bytes()).hexdigest()==sha
a=load(K.open("rb"));b=load((N/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
assert len(a)==505 and len(b)==506
assert all(b[i if i<482 else i+1]==a[i] for i in range(505) if i!=480)
assert all(b[i]==a[i] for i in [145,146,342])
labels=[
 "T01_TREE_DOWN_BACK","T02_TREE_DOWN_FRONT","T03_TREE_UP","T04_BUSH_LEFT","T05_BUSH_RIGHT",
 "T06_FAR_CONIFER_DOWN","T07_FAR_CONIFER_UP","T08_STEPS_DOWN","T09_BLOCKED_UP","T10_BLOCKED_LEFT"]
runs=[]
for branch in ["NATIVE_WALK_REPLAY1","NATIVE_WALK"]:
 d=N/branch
 record=json.loads((d/"R9_NATIVE_WALK_GATE.json").read_text())
 assert record["status"]=="R9_NATIVE_WALK_PASS",branch
 assert len(record["captures"])==10 and sorted(record["cases"])==sorted(labels)
 log=(d/"GAME_LOG.txt").read_text()
 assert "R9_WALK_GATES_COMPLETE true cases=10" in log
 assert "R9_NATIVE_READY" in log and "third_769=769" in log and "third_768=768" in log
 for id in labels:
  entry=record["cases"][id]
  assert entry["move_gate"] and entry["capture_gate"],(id,entry)
  assert Image.open(d/(id+".png")).size==(544,416)
  assert "R9_ACTUAL_MOVE "+id+" " in log
  assert "R9_WALK_CAPTURE "+id+" " in log
 for id in ["T09_BLOCKED_UP","T10_BLOCKED_LEFT"]:
  assert "expectedMove=false" in record["cases"][id]["actual_move"]
 for id in labels[:8]:
  assert "expectedMove=true" in record["cases"][id]["actual_move"]
 runs.append({"directory":branch,"pid":record["one_native_game_pid"],"images":len(record["captures"]),"actual_move_pass":10,
              "two_blocked_not_moved":True})
assert runs[0]["pid"]!=runs[1]["pid"],"SAME PID"
edges=json.loads((R/"R9_EDGE_SEMANTIC_AUDIT"/"R9_EDGE_RISK_AUDIT.json").read_text())
assert edges["object_count"]==8
old=json.loads((R/"R8_NATIVE_FULL_MASTER"/"R8_FINAL_GATE.json").read_text())
assert old["total_native_shots"]==36
out={"status":"R9_FS_ISOLATED_NATIVE_ACTUAL_WALK_TWO_RUNS_TECH_PASS_ART_EDGE_HOLD",
"sealed_505_source_hash":sha,"formal_sealed_modified":False,
"original_505_full_boot_pass":False,"boot_original_page_480_regression_isolated":True,
"unmodified_original_pages_in_test":504,"HK145_ISSPassa342_original":True,
"actual_native_walk_ten_cases_each":True,"two_separate_native_vx_sessions":True,
"native_walking_real_player_methods":True,"capture_count":20,
"passability_source":"R5 isolated Map001 769/768 third-layer test, NOT real SCENE21 map authority",
"native_runs":runs,
"source_par_static_dynamic_R8_prior_gate":"R8 two native A/B/A runs tech PASS",
"semantic_edge_flags_needing_art_review":edges["review_flagged_objects"],
"semantic_boundary_accuracy_gate":"HOLD; edge detection alone is not manual truth",
"user_annotation_screenshot_exact_geometric_registration":"NOT_TESTED (548x400 vs 544x416 source)",
"original_40x29_formal_map_passability":"NOT_TESTED",
"light_shadow_water_loop":"NOT_TESTED",
"art_gate_f":"HOLD"}
(N/"R9_FINAL_GATE.json").write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding="utf8")
print("R9_FINAL_GATE",out["status"],"native",out["capture_count"],"risk",out["semantic_edge_flags_needing_art_review"],flush=True)