from __future__ import annotations
import json,hashlib,shutil,random
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
S=R/"outputs/FS_F1R1_GROUND_SORTY_REPAIR_20261025"
O=R/"outputs/FS_F2_COTTAGE_SOURCE_FIRST_20261025"
if O.exists():raise SystemExit("Fail-closed: F2 output already exists")
shutil.copytree(S,O)
m=json.loads((O/"scene_manifest.json").read_text(encoding="utf-8"))
rng=random.Random(2026102502)
W,H=192,188
im=Image.new("RGBA",(W,H),(0,0,0,0))
d=ImageDraw.Draw(im)
pal={"outline":"#222d35","roof_shadow":"#34465c","roof_deep":"#405d71","roof":"#537b91","roof_mid":"#648da1","roof_light":"#8bb2b1","roof_spec":"#a8c9bf","timber_deep":"#5a3a32","timber":"#785340","timber_light":"#af8061","timber_edge":"#dbad7f","plaster":"#d3ba8e","plaster_hi":"#e6ce9e","plaster_sh":"#baa079","stone":"#7c796c","stone_l":"#a29a82","door_dark":"#272a31","door":"#6f513f","door_l":"#a47a53"}
# outside foundation & foot shadow, margin around source for crop integrity
d.ellipse((16,172,179,186),fill="#353b39")
d.polygon([(16,89),(174,89),(178,169),(170,179),(21,179),(13,168)],fill=pal["outline"])
d.rectangle((20,89,170,175),fill=pal["plaster_sh"])
d.rectangle((25,94,166,167),fill=pal["plaster"])
d.rectangle((29,99,163,159),fill=pal["plaster_hi"])
# lower stone courses
for y in range(158,176,8):
  d.rectangle((17,y,173,y+2),fill=pal["stone"])
  for x in range(24+(4 if y%16 else 0),169,19):
    d.line((x,y,x,y+6),fill=pal["stone_l"],width=2)
# timber support and lintels
for x in (19,42,148,170):
 d.rectangle((x,91,x+7,169),fill=pal["timber_deep"])
 d.line((x+2,99,x+2,165),fill=pal["timber_light"],width=2)
d.rectangle((21,107,170,116),fill=pal["timber_deep"])
d.rectangle((24,109,167,112),fill=pal["timber_light"])
d.rectangle((19,160,172,166),fill=pal["timber"])
for x,y,xx,yy in [(24,118,45,148),(146,118,166,148)]:
 d.line((x,y,xx,yy),fill=pal["timber_deep"],width=5)
 d.line((x+2,y,xx+2,yy),fill=pal["timber_light"],width=2)
# paired windows outside door clearance; glass interiors
for x in (51,129):
 d.rectangle((x-11,122,x+11,151),fill=pal["outline"])
 d.rectangle((x-8,125,x+8,148),fill="#386673")
 d.rectangle((x-5,128,x+4,141),fill="#739e98")
 d.line((x,125,x,149),fill=pal["timber_light"],width=3)
 d.line((x-10,137,x+10,137),fill=pal["timber_light"],width=3)
 d.rectangle((x-13,152,x+13,157),fill=pal["timber_deep"])
 d.line((x-10,153,x+10,153),fill=pal["timber_edge"],width=2)
# door framed and dark center with step
d.rectangle((76,117,115,180),fill=pal["outline"])
d.rectangle((80,122,111,178),fill=pal["door_dark"])
d.rectangle((86,128,105,178),fill=pal["door"])
for x in (90,96,102):
 d.line((x,128,x,175),fill=pal["timber_light"],width=1)
d.ellipse((101,152,104,155),fill=pal["timber_edge"])
d.rectangle((77,178,113,183),fill=pal["stone"])
d.line((78,179,112,179),fill=pal["stone_l"],width=2)
# porch: two isolated solid side posts, centre door remains open
for x in (72,115):
 d.rectangle((x,118,x+6,169),fill=pal["timber_deep"])
 d.line((x+2,120,x+2,165),fill=pal["timber_light"],width=2)
# One coherent house roof: whole triangle from native art, zero opaque touching top edge
roof_polygon=[(5,94),(8,83),(93,16),(98,16),(184,85),(188,93),(186,111),(6,111)]
d.polygon(roof_polygon,fill=pal["outline"])
d.polygon([(11,88),(96,19),(181,88),(181,100),(11,100)],fill=pal["roof_deep"])
# packed, roof slope-aligned shingle banding, all within the outer silhouette
for y in range(38,104,9):
 left=round(96-(y-17)*1.22)+9
 right=round(96+(y-17)*1.22)-9
 left=max(15,left);right=min(175,right)
 if right<=left:continue
 d.line((left,y,right,y),fill=pal["roof_mid"],width=3)
 for x in range(left+((y//9)%2)*8,right-3,17):
  d.line((x,y,x+4,y-5),fill=pal["roof_shadow"],width=2)
  if rng.random()<.38:
   d.line((x+5,y-2,x+10,y-2),fill=pal["roof_light"],width=2)
# eave unifies roof and house
d.polygon([(7,95),(185,95),(183,108),(10,108)],fill=pal["roof_shadow"])
d.line((13,101,179,101),fill=pal["roof_light"],width=3)
d.line((16,108,176,108),fill=pal["outline"],width=3)
# centered crest & tiny roof dormer detail
d.polygon([(78,68),(96,48),(114,68),(111,93),(81,93)],fill=pal["roof_shadow"],outline=pal["outline"])
d.polygon([(84,67),(96,53),(108,67),(105,85),(87,85)],fill=pal["roof_mid"])
d.rectangle((92,67,100,83),fill=pal["outline"])
d.line((94,68,98,68),fill=pal["roof_spec"],width=2)
# native px crisp; exact full sprite dimensions; no cropped alpha on its four boundaries
new=O/"source/props/cottage_new.png"
new.parent.mkdir(parents=True,exist_ok=True)
im.save(new)
arr=np.asarray(im)
assert arr.shape==(H,W,4)
for edge in (arr[0,:,3],arr[-1,:,3],arr[:,0,3],arr[:,-1,3]):
 assert int(edge.max())==0,"No source crop accepted"
assert np.count_nonzero(arr[:,:,3])>14000
# independent semantic collision & occlusion masks, doorway is walkable.
coll=Image.new("L",(W,H),0);dc=ImageDraw.Draw(coll)
# wall foot strips left/right of x=76..115 doorway
dc.rectangle((18,160,65,184),fill=255)
dc.rectangle((126,160,173,184),fill=255)
coll.save(O/"source/props/cottage_contact_mask.png")
occ=Image.new("L",(W,H),0);do=ImageDraw.Draw(occ)
do.polygon(roof_polygon,fill=255)
occ.save(O/"source/props/cottage_roof_occlusion_mask.png")
# adjust existing sign to prevent door occlusion, preserve source hashes
for o in m["objects"]:
 if o["id"]=="sign_crossroads":
  newxy=(67,225)
  lx,ly=o["foot_local"];o["x"],o["y"]=newxy;o["foot_anchor"]=[newxy[0]+lx,newxy[1]+ly]
 if o["id"]=="rock_north":
  newxy=(379,187)
  lx,ly=o["foot_local"];o["x"],o["y"]=newxy;o["foot_anchor"]=[newxy[0]+lx,newxy[1]+ly]
# cottage at y=19 -> 207, door center world (158+96,19+180)=(254,199)
x,y=158,19
obj={"id":"cottage_new","kind":"house","x":x,"y":y,"width":W,"height":H,"source":"source/props/cottage_new.png","source_sha256":hashlib.sha256(new.read_bytes()).hexdigest(),
 "foot_anchor":[x+96,y+179],"foot_local":[96,179],"contact_local":[18,160,174,185],
 "collision_exclusion_local":[65,126],"contact_mask":"source/props/cottage_contact_mask.png",
 "occlusion_mask":"source/props/cottage_roof_occlusion_mask.png","roof_dna":"one coherent blue shingle gable, no crop"}
m["objects"].append(obj)
m["schema"]="FS_F2_NEW_HOUSE_SOURCE_FIRST_V1"
m["revision"]="F2_COTTAGE_NEW_SOURCE_20261025"
m["human_visual"]="PENDING"
m["ground_default_walkable"]=True
# Recompose by FOOT anchor Y-sort, respecting semantically independent house object
ground=Image.open(O/"build/Ground.png").convert("RGBA")
overlay=Image.new("RGBA",ground.size)
for o in sorted(m["objects"],key=lambda a:(a["foot_anchor"][1],a["id"])):
 z=Image.open(O/o["source"]).convert("RGBA")
 overlay.alpha_composite(z,dest=(o["x"],o["y"]))
ground.save(O/"build/Ground.png")
overlay.save(O/"build/PAR_COMPLETE.png")
Image.alpha_composite(ground,overlay).save(O/"build/Recomposed.png")
# Ground default free. Treat actor footbox per 32px cell, mask sampling correct
blocked=set()
for ty in range(13):
 for tx in range(17):
  ax0,ax1=tx*32+8,tx*32+24
  ay0,ay1=ty*32+20,ty*32+32
  solid=False
  for o in m["objects"]:
   if o["id"]=="cottage_new":
    roi=(max(0,ax0-x),max(0,ay0-y),min(W,ax1-x),min(H,ay1-y))
    if roi[0]<roi[2] and roi[1]<roi[3]:
     if np.any(np.asarray(coll)[roi[1]:roi[3],roi[0]:roi[2]]>0):
      solid=True;break
   else:
    cx0,cy0,cx1,cy1=o["contact_local"]
    if ax0<o["x"]+cx1 and ax1>o["x"]+cx0 and ay0<o["y"]+cy1 and ay1>o["y"]+cy0:
     solid=True;break
  if solid:blocked.add((tx,ty))
start=(m["spawn_world"][0]//32,m["spawn_world"][1]//32)
assert start not in blocked
# explicit doorway walk test 1 cell in front of house and visually at doorway
doorway=(7,5)
doorfront=(7,6)
assert doorway not in blocked and doorfront not in blocked,("door blocked",doorway,doorfront,sorted(blocked))
m["collision"]={"default_ground_walkable":True,"blocked_tiles":[list(x) for x in sorted(blocked)],"actor_footbox":[16,12],
 "house_collision_mask":"source/props/cottage_contact_mask.png","doorway_tile":[7,5],"doorfront_tile":[7,6],
 "interior":"not implemented"}
m["ground_sha256"]=hashlib.sha256((O/"build/Ground.png").read_bytes()).hexdigest()
(O/"scene_manifest.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),encoding="utf-8")
(O/"F2_GENERATION_AUDIT.json").write_text(json.dumps({"source":"fully new native-pixel PIL house","alpha_edge_cropping":0,
 "house_rgba_sha256":obj["source_sha256"],"sourced_existing_props":len(m["objects"])-1,"new_complete_house":1,
 "collider":"semantic doorway gap; never entire sprite bounding box",
 "tile_blocked":len(blocked),"doorway_free":True,"doorfront_free":True,
 "preexisting_f1r1_unchanged":True,"human_visual":"PENDING"},indent=2),encoding="utf-8")
print(json.dumps({"F2":str(O),"objects":len(m["objects"]),"blocked_tiles":len(blocked),"doorway":doorway,"doorfront":doorfront,"house_sha":obj["source_sha256"]}))
