from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import hashlib,json
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
assets=root/"a09_2_actor_poses"
r=json.loads((assets/"native_7pose_rgba_parity.json").read_text(encoding="utf-8"))
assert r["all_source_rgba_native_matches_zero_delta"]
assert len(r["poses"])==7
assert r["no_visual_change_expected_for_single_fixed_frame"]
assert all(v["max_channel_delta"]==0 for pose in r["poses"] for v in pose["matches"].values())
a=json.loads((root/"actor1_binding_a09_2.json").read_text(encoding="utf-8"))
assert a["actor1"]["filename"]=="$actor01" and a["actor1"]["name"]=="喬伊"
assert a["actor_specific_pose_defs"]==7 and a["actor_specific_pose_cell_risks"]==0 and a["all_9_risk_labels_are_other_actor"]
ref=(base/"Graphics"/"Characters"/"$actor01.png")
assert hashlib.sha256(ref.read_bytes()).hexdigest()=="df6abaa888dc4ffcaf5351daf26d678bace121e277f21b4651eb69884591a2a5"
meta=json.loads((assets/"engine"/"engine-export.json").read_text(encoding="utf-8"))
report={"status":"A09_2_GODOT_RGBA_TECH_PASS_VX_NATIVE_PARITY_PENDING",
"actor1":a["actor1"],"actor_named_poses":7,"actor_named_missing_cells":0,
"all9_prior_risks_other_named_actor":True,"ASF_strict_warnings":0,"ASF_frames":19,
"ASF_clips":7,"Godot_native_gpu_images":2,"Godot_source_ROI_compared":14,
"max_RGB_channel_delta":0,"fixed_single_frame_static":True,
"original_actor01_sha256":hashlib.sha256(ref.read_bytes()).hexdigest(),
"export_metadata":meta,"limitations":[
"7 named poses are defined in the script and match asset cells but actual runtime actor dispatch not instrumented",
"original VX Game.exe opens in isolated copy yet window capture is black; foreground switching returned false; no new native RGSS2 battlefield screenshot parity",
"no actual AI image-to-video generation nor new same-style FS sprite generation performed",
"no sealed FS source edits or published proprietary art"]}
(root/"a09_2_final_validation.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
out=root/"ASF_A09_2_JOE_SEVEN_POSES_PRIVATE_20261031.zip"
parts=["a09_2_actor_poses","native_a09"]
explicit=["resolve_actor_binding.py","build_actor1_real_poses.py","verify_a09_7poses.py","actor1_binding_a09_2.json","a09_2_final_validation.json","A09_POSE_COVERAGE_HANDOFF.md"]
files=[root/p for p in explicit]
for folder in parts:
 for f in (root/folder).rglob("*"):
  if f.is_file() and not any(x in f.parts for x in (".godot","__pycache__")) and f.suffix.lower() not in (".zip",):
   files.append(f)
with ZipFile(out,"w",ZIP_DEFLATED,compresslevel=8) as z:
 for p in sorted(set(files)):
  z.write(p,p.relative_to(root).as_posix())
with ZipFile(out) as z:
 assert z.testzip() is None
 inv={"file":out.name,"path":str(out),"files":len(z.namelist()),
 "bytes":out.stat().st_size,"sha256":hashlib.sha256(out.read_bytes()).hexdigest(),
 "crc":"PASS","storage":"PRIVATE_LOCAL_ONLY_NO_CLOUD_BINARY_UPLOAD"}
(root/"A09_2_ZIP_INVENTORY.json").write_text(json.dumps(inv,indent=2),encoding="utf-8")
print(json.dumps(inv,indent=2))