# -*- coding: utf-8 -*-
from pathlib import Path
from PIL import Image
import json,hashlib,sys
R=Path(__file__).resolve().parent
g=R/"godot_depth_probe"
out=[]
for i in range(4):
 a=Image.open(R/"outputs"/f"DEPTH_COMPARISON_{i}.png").convert("RGBA").crop((0,36,864,676))
 b=Image.open(g/"GPU_PROBES"/f"NATIVE_ZSORT_{i}.png").convert("RGBA")
 assert a.size==b.size==(864,640)
 n=0;delta_max=0;positions=[]
 for k,(x,y) in enumerate(zip(a.get_flattened_data(),b.get_flattened_data())):
  delta=max(abs(x[j]-y[j]) for j in range(3))
  if delta>2:
   n+=1
   if len(positions)<5:positions.append([k%864,k//864,x,y])
  delta_max=max(delta,delta_max)
 out.append({"probe":i,"rgb_pixels_gt2":n,"max_delta":delta_max,"first_examples":positions,
    "sha256":hashlib.sha256((g/"GPU_PROBES"/f"NATIVE_ZSORT_{i}.png").read_bytes()).hexdigest()})
report={"status":"FS_MAP_DYNAMIC_YDEPTH_GODOT_GPU_PASS" if all(x["rgb_pixels_gt2"]==0 for x in out) else "FS_MAP_DYNAMIC_YDEPTH_GPU_FAIL_CLOSED",
  "renderer":"Godot4.7.2 OpenGL native Radeon RX6700XT","frames":out,
  "matching_four_png":sum(x["rgb_pixels_gt2"]==0 for x in out),
  "notes":"Full world 864x640; 2/255 tolerance for GPU blending roundoff only, no resampling, actor-world-position matched"}
(R/"DEPTH_GODOT_GPU_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(report,ensure_ascii=False,indent=2),flush=True)
sys.exit(0 if report["status"].endswith("_PASS") else 2)
