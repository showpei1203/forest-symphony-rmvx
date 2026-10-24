# -*- coding: utf-8 -*-
"""Dense walkable actor-depth sweep, crop exact source RGBA to actor bbox.
Only 20x28 patch evaluated per walkable candidate, not 864x640 full world.
"""
from pathlib import Path
from PIL import Image
import json,hashlib
R=Path(__file__).resolve().parent
P=R/"fixture"
OUT=R/"outputs";OUT.mkdir(exist_ok=True)
m=json.loads((P/"scene_manifest.json").read_text(encoding="utf8"))
def load(p):return Image.open(p).convert("RGBA")
g=load(P/"build/FS_ELF_RICH_Ground.png")
pb=load(P/"build/FS_ELF_RICH_Par_BASE.png")
po=load(P/"build/FS_ELF_RICH_Occlusion.png")
actor=load(R/"fixture/actor.png")
coll=Image.open(P/"build/FS_ELF_RICH_Collision.png").convert("L")
objs=[(o,load(P/"source/clean"/(o["asset_id"]+".png"))) for o in sorted(m["instances"],key=lambda x:(x["draw_order"],x["id"]))]
def walk(x,y):
 return all(coll.getpixel((x+dx,y+dy))==0 for dx in [-8,0,8] for dy in [-8,0,8])
def region_patch(x,y):
 return (x-10,y-28,x+10,y)
def add_obj(tgt,obj,sprite,box):
 x0,y0,x1,y1=box;x=obj["x"];y=obj["y"]
 l=max(x0,x);t=max(y0,y);r=min(x1,x+sprite.width);b=min(y1,y+sprite.height)
 if l<r and t<b:tgt.alpha_composite(sprite.crop((l-x,t-y,r-x,b-y)),(l-x0,t-y0))
def both(x,y):
 box=region_patch(x,y)
 static=g.crop(box);static.alpha_composite(pb.crop(box));static.alpha_composite(actor)
 static.alpha_composite(po.crop(box))
 source=g.crop(box);has_actor=False
 for o,sp in objs:
  if not has_actor and o["draw_order"]>y:
   source.alpha_composite(actor);has_actor=True
  add_obj(source,o,sp,box)
 if not has_actor:source.alpha_composite(actor)
 return source,static
positions=[]
for y in range(32,608,8):
 for x in range(24,824,8):
  if not walk(x,y):continue
  a,b=both(x,y)
  mismatch=sum(p!=q for p,q in zip(a.get_flattened_data(),b.get_flattened_data()))
  if mismatch:positions.append((mismatch,x,y))
positions.sort(reverse=True)
result={"status":"FS_DENSE_YDEPTH_SCANNED",
 "walkable_stride":8,"tested_world":"864x640","static_mismatch_positions":len(positions),
 "max_wrong_visible_pixels_in_actor":positions[0][0] if positions else 0,
 "worst_positions":[{"x":x,"y":y,"incorrect_actor_pixels":n} for n,x,y in positions[:12]],
 "semantic":"Defect in static Ground/ParBASE/Occ actor draw order, not standalone map quality",
 "human_gate":"PENDING"}
(R/"DENSE_DEPTH_RESULT.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps(result,ensure_ascii=False,indent=2),flush=True)
