#!/usr/bin/env python3
"""R10 separate formal Map050 blank source from derived CollisionCandidate.
Fails closed on original SHA, artwork exact, script byte guards, native 2 replay and NPC movement.
"""
from pathlib import Path
from rubymarshal.reader import load
from PIL import Image,ImageChops
import json,hashlib,struct
R=Path(__file__).resolve().parent
F=R/"R10_FORMAL_MAP_AUTHORITY";ROOT=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
O=R/"R10_ORIGINAL_MAP050_NATIVE";N=R/"R10_COLLISION_NATIVE_CANDIDATE"
sha="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
mapsha="55bed528d21644de4d840949614163b35a21b9b39fba7e85951b862b84693c26"
assert hashlib.sha256((ROOT/"Data"/"Scripts.rvdata").read_bytes()).hexdigest()==sha
assert hashlib.sha256((ROOT/"Data"/"Map050.rvdata").read_bytes()).hexdigest()==mapsha
src=Image.open(ROOT/"Graphics"/"Parallaxes"/"SCENE21.png").convert("RGBA")
master=Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA")
assert src.size==master.size==(544,416)
assert ImageChops.difference(src,master).getbbox() is None
def get_ids(path):
 obj=load(path.open("rb"));buf=obj.attributes["@data"]._private_data
 dim,w,h,dep,n=struct.unpack_from("<5i",buf,0)
 assert (dim,w,h,dep,n)==(3,17,13,3,663)
 ids=struct.unpack_from("<663H",buf,20)
 return list(ids)
orig=get_ids(ROOT/"Data"/"Map050.rvdata")
assert all(x==0 for x in orig)
formal=load((ROOT/"Data"/"Scripts.rvdata").open("rb"))
for obj in [O,N]:
 pages=load((obj/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
 assert len(pages)==506 and all(pages[i if i<482 else i+1]==formal[i] for i in range(505) if i!=480)
 assert all(pages[i]==formal[i] for i in (145,146,342))
assert hashlib.sha256((O/"FULL505"/"Data"/"Map001.rvdata").read_bytes()).hexdigest()==mapsha
candidate=get_ids(N/"FULL505"/"Data"/"Map001.rvdata")
assert candidate[:442]==orig[:442]
layer=candidate[442:]
assert layer.count(769)==204 and layer.count(768)==17
policy=json.loads((F/"R10_COLLISION_POLICY_CANDIDATE.json").read_text())
assert policy["candidate_blocked_768_count"]==17
assert layer[9+6*17]==769 # blue steps
assert layer[13+5*17]==768 # high conifer red
assert layer[15+7*17]==768 # far conifer red
assert layer[3+8*17]==768 # left shrine bush
raw_base=json.loads((O/"NATIVE_MAP050"/"R10_MAP050_NATIVE_GATE.json").read_text())
assert raw_base["status"]=="R10_MAP050_ORIGINAL_LAYER_NATIVE_PASS"
assert len(raw_base["screenshots"])==10
# All original-zero map test movements correctly remained blocked, including NPC.
assert all("to=[" in z["action"] and z["position_pass"] and z["settled_pass"] for z in raw_base["cases"].values())
for label,z in raw_base["cases"].items():
 assert "from=" in z["action"] and "expected=" in z["action"]
chunks=[]
for key in ["NATIVE_REPLAY1","NATIVE_CANDIDATE"]:
 d=N/key
 meta=json.loads((d/"R10_COLLISION_NATIVE_GATE.json").read_text())
 assert meta["status"]=="R10_COLLISION_CANDIDATE_NATIVE_PASS" and len(meta["screenshots"])==11
 for item,z in meta["cases"].items():
  assert z["position_pass"] and z["settled_pass"],(key,item,z)
  img=d/(item+".png");assert Image.open(img).size==(544,416)
 for b in ["F02_MAP050_TREE_FRONT","F04_MAP050_BUSH_RIGHT","F10_MAP050_NPC_MOVE"]:
  z=meta["cases"][b]
  assert "to=" in z["action"] and "pass=true" in z["action"]
 # Case 11 must actually move injected native Game_Event NPC
 z=meta["cases"]["F11_MAP050_NPC_FREE"]
 assert "from=[10, 7] to=[10, 8]" in z["action"],(key,z)
 z=meta["cases"]["F05_MAP050_STEPS_DOWN"]
 assert "from=[9, 5] to=[9, 6]" in z["action"],(key,z)
 chunks.append({"run":key,"pid":meta["actual_native_pid"],"test_count":len(meta["cases"]),"native_screenshots":len(meta["screenshots"])})
assert chunks[0]["pid"]!=chunks[1]["pid"]
r9=json.loads((R/"R9_EDGE_SEMANTIC_AUDIT"/"R9_EDGE_RISK_AUDIT.json").read_text())
result={"status":"R10_FORMAL_MAP050_IDENTIFIED_AND_ISOLATED_COLLISION_COMPILER_NATIVE_TECH_PASS_ART_HOLD",
"original_fs_k4_scripts_sha256":sha,"original_Map050_sha256":mapsha,"formal_files_modified":False,
"SCENE21_source_image_exact_RGBA_match":True,"Map050_original_layer_0_all_663_tiles":True,
"Map050_native_original_walk":"10/10 expected blocks including NPC, actual in isolated test harness",
"candidate_map_769_walkable":204,"candidate_map_768_blocked":17,"blue_steps_cell_9_6_walkable":True,
"native_candidate_two_replays":chunks,"native_candidate_total_screenshots":22,
"candidate_native_player_and_injected_npc":True,
"original_events_in_Map050_data_exist_but_runtime_test_harness_clears_them":True,
"original_505_runtime_unmodified_pass":False,"original_regression_page480_disabled_only_in_isolation":True,
"original_other_504_source_pages_byte_identical":True,
"source_SEMANTIC_mask_edges_user_approval":"HOLD","r9_six_risk_mask_ids":r9["review_flagged_objects"],
"full_house_footprint_collisions_covered":False,
"formal_Map050_project_full_event_gameplay_pass":False,
"pixel_registration_original_user_red_blue_screenshot":"HOLD, not precisely registered",
"light_shadow_animated_ground":"NOT_TESTED","art_gate_F":"HOLD",
"next_steps":["geometry refine full building footprint and collision cells with gate",
  "R8 6 flagged mask high-res visual review, user annotation registration",
  "native multi-step walking tests with NPC as dynamic object",
  "Light/Shadow, animated ground native loop and 40x29 map"]}
(N/"R10_FINAL_GATE.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print("R10_FINAL",json.dumps({"status":result["status"],"original_data_map_sha":mapsha,
"candidate":(204,17),"native_candidate_replays":chunks,"art_gate_f":result["art_gate_F"]},ensure_ascii=False),flush=True)