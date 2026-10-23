from pathlib import Path
from PIL import Image
import json
r=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
screen=Image.open(r/"logs"/"VX_TEST_RUNNING.png").convert("RGB")
master=Image.open(r/"build"/"FS_FOREST_V32_Master_FromScene.png").convert("RGB")
results=[]
for dy in range(22,30):
 for dx in range(1,6):
  if dx+544>screen.width or dy+416>screen.height:continue
  cropped=screen.crop((dx,dy,dx+544,dy+416))
  pix1=cropped.load();pix2=master.load()
  total=0;count=0;maxdelta=0;first=[]
  for y in range(416):
   for x in range(544):
    if 251<=x<=293 and 182<=y<=228:continue
    a=pix1[x,y];b=pix2[x,y]
    delta=sum(abs(a[i]-b[i]) for i in range(3))
    total+=delta;maxdelta=max(maxdelta,delta)
    if delta:
      count+=1
      if len(first)<3:first.append([x,y,a,b])
  results.append({"offset":[dx,dy],"differing_pixels":count,"channel_abs_sum":total,"max_channel_sum":maxdelta,"samples":first})
best=min(results,key=lambda v:v["differing_pixels"])
report={"best":best,"examined_offsets":len(results),"strict_background_match":best["differing_pixels"]==0,"excluded_actor_rect":[251,182,293,228]}
(r/"logs"/"VX_SCREENSHOT_PIXEL_AUDIT.json").write_text(json.dumps(report,indent=2),encoding="utf8")
print("SCREENSHOT_PIXEL_AUDIT",json.dumps(report))
