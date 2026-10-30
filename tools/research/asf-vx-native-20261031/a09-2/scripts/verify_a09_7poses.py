from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031\a09_2_actor_poses")
base=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
g=root/"engine"/"godot"
shots={x:Image.open(g/f"A09_7POSE_GPU_{x}.png").convert("RGB") for x in ("A","B")}
lineage=json.loads((root/"native_pose_lineage.json").read_text(encoding="utf-8"))
report={"version":"A09-2","source":"FS-K4-SEALED-CLONE", "native_renderer":"Godot 4.7.2 Radeon RX6700XT OpenGL", "background_rgb":shots["A"].getpixel((0,0)),"poses":[]}
bg=report["background_rgb"]
for i,p in enumerate(lineage):
 src=base/"Graphics"/"Characters"/p["filename"]
 assert hashlib.sha256(src.read_bytes()).hexdigest()==p["original_image_sha256"]
 source=Image.open(src).convert("RGBA")
 x,y=77+i*148,98
 orig_frames=[]
 for col in ([p["fixed"]] if p["fixed"] in (0,1,2) else [0,1,2]):
  cell=source.crop((col*32,p["row"]*32,(col+1)*32,p["row"]*32+32))
  expected=Image.new("RGBA",(32,32),(*bg,255))
  expected.alpha_composite(cell)
  orig_frames.append((col,np.asarray(expected.convert("RGB"),dtype=np.int16)))
 pics={}
 for t,img in shots.items():
  roi=np.asarray(img.crop((x-16,y-21,x+16,y+11)),dtype=np.int16)
  scored=[{"column":c,"max_channel_delta":int(np.abs(roi-orig).max()),"mean_delta":float(np.abs(roi-orig).mean())} for c,orig in orig_frames]
  pics[t]=min(scored,key=lambda z:z["mean_delta"])
 arrA=np.asarray(shots["A"].crop((x-16,y-21,x+16,y+11)),dtype=np.int16)
 arrB=np.asarray(shots["B"].crop((x-16,y-21,x+16,y+11)),dtype=np.int16)
 row={"clip_id":p["clip_id"],"pose_key":p["pose_key"],"file":p["filename"],"row":p["row"],"fixed":p["fixed"],"ticks_per_cell":p["ticks_per_cell"],"matches":pics,"changed_rgb_pixels":int(np.any(arrA!=arrB,axis=2).sum())}
 report["poses"].append(row)
report["all_source_rgba_native_matches_zero_delta"]=all(x["max_channel_delta"]==0 for p in report["poses"] for x in p["matches"].values())
report["no_visual_change_expected_for_single_fixed_frame"]=report["poses"][2]["changed_rgb_pixels"]==0
assert report["all_source_rgba_native_matches_zero_delta"],"PIXEL PARITY FAIL"
assert report["no_visual_change_expected_for_single_fixed_frame"],"FIXED FRAME BEHAVIOR FAIL"
(root/"native_7pose_rgba_parity.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"status":"PASS","all_rgb_delta_zero":report["all_source_rgba_native_matches_zero_delta"],"fixed_static":report["no_visual_change_expected_for_single_fixed_frame"],"pose_changes":[{"pose":x["clip_id"],"A":x["matches"]["A"],"B":x["matches"]["B"],"changed":x["changed_rgb_pixels"]} for x in report["poses"]]},ensure_ascii=True,indent=2))