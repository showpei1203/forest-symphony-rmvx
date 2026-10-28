#!/usr/bin/env python3
"""R12 new village genuine original-image Ground and 14 source-PAR real Game.exe two-session gate.
Human will review PAR, so cannot seal art. Formal K4 all untouched.
"""
from pathlib import Path
from PIL import Image,ImageChops
from rubymarshal.reader import load
import json,hashlib,re
R=Path(__file__).resolve().parent;D=R/"R12_NEW_ELF_VILLAGE_001";N=R/"R12_NEW_ELF_VILLAGE_NATIVE"
K4=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
script=K4/"Data"/"Scripts.rvdata";map003=K4/"Data"/"Map003.rvdata";master=D/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
MASTER_SHA="eda8fa28b537d9a96ee839f8c5c667c466bd55102731d41a7a9e560362854c80"
SCRIPT_SHA="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
MAP_SHA="118c6563ea89e4f644bad6e38ca01542ad4955cd4c24a7435a01409686ac1bf4"
assert hashlib.sha256(master.read_bytes()).hexdigest()==MASTER_SHA
assert hashlib.sha256(script.read_bytes()).hexdigest()==SCRIPT_SHA
assert hashlib.sha256(map003.read_bytes()).hexdigest()==MAP_SHA
assert Image.open(master).size==(1280,928)
new_master=Image.open(master).convert("RGB")
old_ground=Image.open(K4/"Graphics"/"Parallaxes"/"ground3.png").convert("RGB")
assert ImageChops.difference(new_master,old_ground).getbbox() is not None
# Actual loader uses legacy resource key ground3; test copied user-visible NEW Master under that resource name only in clone.
runtime_ground=N/"FULL505"/"Graphics"/"Parallaxes"/"ground3.png"
assert hashlib.sha256(runtime_ground.read_bytes()).hexdigest()==MASTER_SHA
runtime_map=N/"FULL505"/"Data"/"Map001.rvdata"
assert hashlib.sha256(runtime_map.read_bytes()).hexdigest()==MAP_SHA
baseline=load(script.open("rb"))
candidate=load((N/"FULL505"/"Data"/"Scripts.rvdata").open("rb"))
assert len(candidate)==506 and all(candidate[i if i<482 else i+1]==baseline[i] for i in range(505) if i!=480)
sam=json.loads((D/"R12_SAM2_18OBJECT_GATE.json").read_text(encoding="utf8"))
sel=json.loads((D/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text(encoding="utf8"))
assert len(sam["objects"])==18 and len(sel["selected_objects"])==14
assert len(sel["rejected_prompt_or_overlap"])==4
assert sel["passable_769_tile_count"]+sel["blocked_768_tile_count"]==1160
assert sel["source_exact_selected14_rgb"] is True
alpha=Image.open(D/"PAR_R12_VX_SELECTED14_SOURCE_ONLY.png").convert("RGBA")
assert alpha.size==(1280,928)
count=0
for x,y in zip(new_master.getdata(),alpha.getdata()):
 if y[3]:
  count+=1;assert x==y[:3]
assert count==sel["PAR_alpha_opaque_pixels"]
# Distinguish "native pixel RGB image" vs separate screenshots darkened by original FS lighting/HUD.
expected_color=new_master.getpixel((100,100))
assert expected_color==(3,22,18)
cases=json.loads((D/"R12_NATIVE_TEST_CASES.json").read_text(encoding="utf8"))
assert len(cases)==14
runs=[]
for folder in ["NATIVE_REPLAY1","NATIVE"]:
 d=N/folder
 res=json.loads((d/"R12_NATIVE_GATE.json").read_text(encoding="utf8"))
 assert res["status"]=="R12_NEW_MASTER_14_PAR_NATIVE_TECH_PASS" and len(res["captures"])==14
 assert all(x["gate"] for x in res["tests"])
 assert sorted(res["captures"])==sorted(x["id"] for x in cases)
 s=(d/"GAME_LOG.txt").read_text()
 w=re.search(r"^R12_WORLD (.+)$",s,re.M)
 assert w and "name=ground3" in w.group(1) and "size=40x29 objects=14" in w.group(1)
 assert "source_sample=[3, 22, 18]" in w.group(1)
 assert "R12_ALL_CASES_COMPLETE true cases=14" in s
 samples=[]
 for case in cases:
  tag=case["id"]
  im=Image.open(d/(tag+".png"))
  assert im.size==(544,416)
  m=re.search(r"^R12_SCREEN "+re.escape(tag)+r" (.+)$",s,re.M)
  assert m and "verified=true" in m.group(1)
  a=re.search(r"camera=\[(\d+), (\d+)\] parObjXY=\[(-?\d+), (-?\d+)\] sourceObjCount=(\d+)",m.group(1))
  assert a,(tag,m.group(1))
  x,y,px,py,n=(int(q) for q in a.groups())
  assert [px,py]==[-x//8,-y//8] and n==14,(tag,x,y,px,py)
  samples.append([x,y])
 runs.append({"session":folder,"pid":res["game_pid"],"shots":len(res["captures"]),
              "all_move_cases_pass":True,
              "sprite_world_camera_offset_verified":True,
              "max_camera":[max(x for x,y in samples),max(y for x,y in samples)]})
assert len(set(x["pid"] for x in runs))==2
report={
 "status":"R12_NEW_ORIGINAL_1280x928_GROUND_14_SOURCE_PAR_NATIVE_2RUN_TECH_PASS_ART_HOLD",
 "new_master_sha256":MASTER_SHA,"master_px":[1280,928],"master_is_new_generation":True,
 "formal_fs_source_505_sha256":SCRIPT_SHA,"formal_Map003_sha256":MAP_SHA,
 "formal_project_modified":False,
 "R12_runtime_uses_original_resource_key_ground3_aliased_to_new_master_in_isolated_clone_only":True,
 "R12_native_ground_bitmap_pixel_sample_verified":list(expected_color),
 "R12_base_original_ground_differs_from_new":True,
 "source_SAM2_guided_18_candidate":18,"candidate_selected":14,
 "candidate_rejected":sel["rejected_prompt_or_overlap"],
 "selected_PAR_source_RGB_exact_alpha_pixels":count,
 "compiled_ground_walk_769":sel["passable_769_tile_count"],
 "compiled_terrain_and_objects_block_768":sel["blocked_768_tile_count"],
 "ground_collision_compiled_runtime_only_vx_file_not_exported":True,
 "native_game_runs":runs,"native_screenshots_total":28,
 "npc_walk_and_block_tests":True,
 "master_art_gate_A":"PENDING_HUMAN_VISUAL_REVIEW",
 "source_PAR_mask_semantic_gate_C":"PENDING_USER",
 "full_map_occluder_coverage":"NOT_PROVEN",
 "native_full_FS_unchanged_505_boot":"KNOWN_FAILURE_DUE_TO_EXISTING_480_HARNESS",
 "original_Map003_25_formal_events_preserved_in_test":"NO_TEST_ADAPTER_CLEARS_ORIGINAL_EVENTS",
 "animation_water_clouds_light_shadow":"NOT_TESTED",
 "native_clean_no_HUD_1x_art_screenshots":"NOT_TESTED",
 "performance_FPS_stress_longrun":"NOT_TESTED",
 "formal_seal":False,
 "recommended_next":["User inspect selected 14 PAR RGB and object alpha on full map", 
    "Improve 4 rejected semantic object masks and discover all occluders",
    "Fix resource key alias and export formally verifiable native Map.rvdata without corrupting Ruby Marshal",
    "Make clear 1x native screenshot without legacy UI overlay, inspect actor 32x32 scale",
    "Animated water, light/shadow and polygon collisions with NPC, then Art Gate F"]
}
out=N/"R12_FINAL_GATE.json";out.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R12_FINAL_GATE",json.dumps({"status":report["status"],"native":report["native_screenshots_total"],
"PAR_source_px":count,"master_sample":report["R12_native_ground_bitmap_pixel_sample_verified"],
"walk":report["compiled_ground_walk_769"],"block":report["compiled_terrain_and_objects_block_768"]},ensure_ascii=False),flush=True)