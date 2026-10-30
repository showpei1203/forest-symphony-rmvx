from pathlib import Path
from PIL import Image
import json, numpy as np
root=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\vx_real_actor_20261031")
scene=root/"godot"/"godot"
source=Image.open(Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Graphics\Characters\$actor01.png")).convert("RGBA")
ims={t:Image.open(scene/f"fs_actor_vx_gpu_{t}.png").convert("RGB") for t in ["A","B"]}
directions=["down","left","right","up"]
results={"captures":{},"background":ims["A"].getpixel((0,0)),"method":"source 3x4 RGBA frame over pixel background compared with native Godot screenshot crop at exact 1x frame bounds"}
bg=results["background"]
for t,sceneimg in ims.items():
 rows=[]
 for rid,d in enumerate(directions):
  x=70+rid*130;y=105
  crop=sceneimg.crop((x-16,y-21,x+16,y+11)).convert("RGB")
  scores=[]
  for c in range(3):
   frame=source.crop((c*32,rid*32,(c+1)*32,(rid+1)*32))
   composited=Image.new("RGBA",(32,32),(*bg,255))
   composited.alpha_composite(frame)
   diff=np.abs(np.asarray(crop,dtype=np.int16)-np.asarray(composited.convert("RGB"),dtype=np.int16))
   scores.append({"source_col":c,"mae":float(np.mean(diff)),"worst":int(diff.max()),"diff_rgb_px":int(np.any(diff,axis=2).sum())})
  rows.append({"direction":d,"scores":scores,"best":min(scores,key=lambda r:r["mae"])["source_col"]})
 results["captures"][t]=rows
results["temporal_changes"]={}
for rid,d in enumerate(directions):
 x=70+rid*130;y=105
 a=np.asarray(ims["A"].crop((x-16,y-21,x+16,y+11)),dtype=np.int16)
 b=np.asarray(ims["B"].crop((x-16,y-21,x+16,y+11)),dtype=np.int16)
 results["temporal_changes"][d]=int(np.any(a!=b,axis=2).sum())
(root/"native_godot_parity_report.json").write_text(json.dumps(results,indent=2),encoding="utf-8")
print(json.dumps({"background":bg,"best":{t:[{"dir":x["direction"],"col":x["best"],"mae":next(a["mae"] for a in x["scores"] if a["source_col"]==x["best"]),"max":next(a["worst"] for a in x["scores"] if a["source_col"]==x["best"])} for x in lines] for t,lines in results["captures"].items()},"temporal_changes":results["temporal_changes"]},indent=2))