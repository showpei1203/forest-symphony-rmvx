from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
lab=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
out=lab/"A13_KEYPOSE_RIG"/"T2_moss_antler"
orig=Image.open(lab/"A10_ONE_MASTER_RIG"/"T2_moss_antler"/"master.png").convert("RGBA")
cfg=json.loads((out/"rig_authority.json").read_text(encoding="utf8"))
# Asset-specific source-pixel segmentation; physically still a candidate until human art.
legs={
 "front_far":{"box":(14,45,25,60),"anchor":(20,48),"z":"back"},
 "front_near":{"box":(22,45,35,62),"anchor":(28,48),"z":"front"},
 "back_far":{"box":(37,46,49,60),"anchor":(43,49),"z":"back"},
 "back_near":{"box":(46,45,60,61),"anchor":(52,49),"z":"front"},
}
patches={k:orig.crop(v["box"]) for k,v in legs.items()}
# Body without the existing lower hooves; keep upper identity and all antlers unchanged.
body=orig.copy()
pixels=np.array(body)
for y in range(51,64):
  for x in range(64):
    if 12<=x<60:
      pixels[y,x]=[0,0,0,0]
body=Image.fromarray(pixels,"RGBA")
ox,oy=16,15
for row in cfg["semantic_frames"]:
 i=row["frame"]
 dx,dy=row["root_offset"]
 canvas=Image.new("RGBA",(96,96))
 # back legs prior to body
 def paste_leg(name):
  b=legs[name]["box"]
  contact=bool(row["contacts"][name])
  # preserve foot position for planted stance; move only on swing/flight, data-driven step offsets
  target=row["foot_targets"][name]
  fx,fy=target
  # original sprite foot bottom y ~59, compensate per original box extents.
  new_left=int(round(fx-(legs[name]["anchor"][0]-b[0])))
  new_top=int(round(fy-(60-b[1])))
  canvas.alpha_composite(patches[name],(new_left,new_top))
 for n in ("front_far","back_far"):paste_leg(n)
 canvas.alpha_composite(body,(ox+dx,oy+dy))
 for n in ("front_near","back_near"):paste_leg(n)
 canvas.save(out/"frames"/f"attack_{i:02d}.png")
cfg["revision"]="A13_T2_R2_SOURCE_PIXEL_LEGS"
cfg["source_leg_patches"]=legs
cfg["limitations"]=["Patches contain pixels from source Master, but independent leg anchors can still reveal seams","No verified 4-paw contact friction or full quadruped realism","Human Gate F pending"]
(out/"rig_authority.json").write_text(json.dumps(cfg,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"revision":cfg["revision"],"source_master_only":True,"frames":len(cfg["semantic_frames"])}))