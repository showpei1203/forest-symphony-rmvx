from pathlib import Path
from PIL import Image
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
lab=r/"vx_real_actor_20261031"/"a09_4"
n5=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\N5_RUNTIME_CLONE")
k4=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
b0=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\N5_B0_ADAPTER_CANDIDATE")
native=r/"VX_A09_4_N5_RUNTIME"
godot=r/"vx_real_actor_20261031"/"a09_2_actor_poses"/"engine"/"godot"
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(n5/"Data"/"Scripts.rvdata")=="3271f5653a7f53cb55c0762d3b047e2300fbb6d6547257bef1fb2328be2b3ea9"
assert sha(k4/"Data"/"Scripts.rvdata")=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
assert sha(b0/"Data"/"Scripts.rvdata")=="26f85ad278b6e08cc8634e3f9dc8b4ba15539888bf2920567d12244e328fa03c"
st0=json.loads((lab/"stage0_run.json").read_text())
st1=json.loads((lab/"stage1_run.json").read_text())
raw=json.loads((lab/"native_weapon_12_samples.json").read_text())
compare=json.loads((lab/"A094_RENDER_SAMPLER_AB.json").read_text())
assert st0["frame_test"] and st0["screenshot"]["size"]==[544,416] and st0["screenshot"]["nonblack_fraction"]>0.95
assert st1["status"]=="CAPTURE_DONE_MARKER" and len(st1["ppm_files"])==12
assert len(raw["samples"])==12 and len(set((x["profile"],x["tick"]) for x in raw["samples"]))==12
assert raw["icon"]["icon_index"]==548 and raw["icon"]["crop"]==[96,816,24,24]
expected={0:[-203,-67,69,205],1:[205,140,75,10],2:[65,65,65,65]}
for profile in range(3):
 seq=sorted((a for a in raw["samples"] if a["profile"]==profile),key=lambda x:x["tick"])
 assert [int(x["angle_rgss"]) for x in seq]==expected[profile]
for x in raw["samples"]:
 if x["profile"]==0:
  assert x["z"]==2999 and x["ox"]==24 and x["oy"]==24 and x["flip"]==False
 if x["profile"]==1:
  assert x["z"]==1999 and x["ox"]==0 and x["oy"]==24 and x["flip"]==True
assert compare["nearest"]["mean_iou"]>compare["linear"]["mean_iou"]
assert compare["nearest"]["total_diff_pixels"]>0
assert all(Image.open(native/"ASF_A094_NATIVE_PROOFS"/f"weapon_{i}_tick_{t}.ppm").size==(90,105) for i in range(3) for t in range(4))
assert Image.open(godot/"A094_GODOT_12_TILES_NATIVE_VALUES.png").size==(360,315)
report={"status":"A09_4_REAL_NATIVE_SPRITE_WEAPON_PASS_GODOT_NEAR_MATCH_NOT_FORMAL",
"baseline":{"K4_SHA256":sha(k4/"Data"/"Scripts.rvdata"),"N5_SEALED_SHA256":sha(n5/"Data"/"Scripts.rvdata"),
"N5_B0_CONTROL_SHA256":sha(b0/"Data"/"Scripts.rvdata"),"A094_TEST_RUNTIME_SHA256":sha(native/"Data"/"Scripts.rvdata"),
"original_entry_unchanged":True},
"stage0":{"ruby_hook_loaded":True,"title_update_called":True,"map_frame_35_reached":True,"screen_544x416_nonblack_fraction":st0["screenshot"]["nonblack_fraction"]},
"stage1":{"native_Sprite_Weapon_profiles":3,"native_dynamic_samples":12,"native_ppm_captures":12,
"weapon_id":2,"weapon_icon_index":548,"iconset_crop_xywh":[96,816,24,24],
"native_angle_sequences":expected,"mirrored_weapon_origin":[0,24],"unmirrored_origin":[24,24]},
"cross_engine":{"engine":"Godot 4.7.2 Radeon RX6700XT OpenGL","Godot_rendered_samples":12,
"nearest_mean_occupancy_iou":compare["nearest"]["mean_iou"],
"nearest_diff_rgb_pixels":compare["nearest"]["total_diff_pixels"],
"nearest_mean_abs_rgb_delta":compare["nearest"]["mean_mae"],
"linear_mean_occupancy_iou":compare["linear"]["mean_iou"],
"linear_diff_rgb_pixels":compare["linear"]["total_diff_pixels"],
"source_rgb_pixel_exact":False,"visual_gate_F":"PENDING"},
"error_corrections":[
"ERROR_SOURCE_ASSET: weapon_id2 is NOT icon_index2; Weapon2.icon_index=548",
"ERROR_TIMING_DENOMINATOR: ANIME_PATTERN=3 is used for @moving_x and @angling; @time starts ANIME_PATTERN+1=4",
"ERROR_MAPPING: mirrored weapon origin Or4 swaps to Or3",
"ERROR_XA: incremental integer movement not full Xa at t0",
"ERROR_NATIVE_ENVIRONMENT: the prior K4 start path did not produce valid capture, while sealed N5+B0 control does; root cause of K4 not established"],
"scope":{"original_Source_Art_unchanged":True,"N5_map_is_control_not_full_joe_Scene_Battle":True,"real_attack_dispatch_in_Actual_Scene_Battle":False,
"pixel_exact_comparison_PASSED":False,"model_generated_new_action":False,"formal_seal":False}}
(lab/"A09_4_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
files=[]
for p in lab.iterdir():
 if p.is_file() and p.suffix in (".py",".rb",".json",".md",".png"):
  files.append((p,"a09_4/"+p.name))
for p in (native/"ASF_A094_NATIVE_PROOFS").glob("*.ppm"):
 files.append((p,"native_frames/"+p.name))
for name in ["A094_GODOT_12_TILES_NATIVE_VALUES.png","A094_GODOT_12_TILES_LINEAR.png",
"A094_GODOT_12_LOG.json","A094_GODOT_12_LINEAR_LOG.json","capture_a094_native_parity.gd","capture_a094_linear.gd","weapon_icon_548.png"]:
 files.append((godot/name,"godot/"+name))
zipfile=lab/"ASF_A09_4_NATIVE_WEAPON_PARITY_PRIVATE_20261031.zip"
with ZipFile(zipfile,"w",ZIP_DEFLATED,compresslevel=8) as z:
 for p,rel in files:
  assert p.exists(),p
  z.write(p,rel)
with ZipFile(zipfile) as z:
 assert z.testzip() is None
 inv={"name":zipfile.name,"path":str(zipfile),"files":len(z.namelist()),"bytes":zipfile.stat().st_size,"sha256":sha(zipfile),"CRC":"PASS","scope":"PRIVATE_LOCAL_WINDOWS_TEST_ASSETS_ONLY_NO_CLOUD_BINARY"}
(lab/"A09_4_ZIP_INVENTORY.json").write_text(json.dumps(inv,indent=2))
print(json.dumps({"status":report["status"],"qa":report["cross_engine"],"inventory":inv},indent=2))