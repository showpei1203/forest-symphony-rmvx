"""R5 R2 build actual 1280x928 Ground/PAR from independent sprite sources. Right house one-piece PixelLab, left and forest immutably SHA-locked."""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,shutil
import numpy as np
from collections import deque
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
R=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
S=R/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
base=json.loads((R/"R5_BASE_R4_SCENE_MANIFEST.json").read_text("utf8"))
assert base["stage"]=="A36G_R4_6REGIONS_R3_ROOT_ART_FIX_ENGINE_CANDIDATE"
a=next(o for o in base["objects"] if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
b=next(o for o in base["objects"] if o["id"]=="A36F_ELF_COTTAGE_B")
new=S/"A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_RGBA.png"
lock=R/"A36G_R5_PIXELLAB_RIGHT_HOUSE_SINGLE_GABLE_R2_SUBMISSION_LOCK.json"
l=json.loads(lock.read_text("utf8"))
assert l["status"]=="SOURCE_READY_UNREVIEWED" and sha(new)==l["output_sha"]
im=Image.open(new).convert("RGBA")
assert im.size==(256,272),im.size
box=im.getbbox()
assert box and box[0]>=8 and box[1]>=8 and box[2]<=248 and box[3]<=264,box
assert sha(S/a["filename"])==a["sha256"]
assert sha(S/b["filename"])==b["sha256"]
m=json.loads(json.dumps(base))
o=next(x for x in m["objects"] if x["id"]==b["id"])
# Door keeps its old legal pathway anchor (869,596). New source door around (126,210).
x,y=743,376
o.update(id="A36G_R5_COTTAGE_B_SINGLE_ROOF",filename=new.name,sha256=sha(new),
 x=x,y=y,w=256,h=272,foot=[869,596],blocking_footprint_px=[778,535,921,588],
 source_parent="STYLE_CROP_FROM_APPROVED_LEFT_HOUSE_WITH_OLD_B_LAYOUT",
 design_variation="NEW_COHERENT_UNIQUE_SINGLE_GABLE_RIGHT_HOUSE_NO_ATTACHED_WORKSHOP",
 art_gate="PENDING_NATIVE_RENDER_REVIEW")
m["objects"].sort(key=lambda t:(t["foot"][1],t["id"]))
# Adjust the ACTUAL blocked roof foundation footprint, not just render alpha.
def cells(rect):
 x0,y0,x1,y1=rect
 return {(i,j) for j in range(29) for i in range(40) if x0<=i*32+16<=x1 and y0<=j*32+16<=y1}
blocked={(i,j) for j,row in enumerate(base["collision_map_29x40"]) for i,z in enumerate(row) if z}
blocked=(blocked-cells(b["blocking_footprint_px"]))|cells(o["blocking_footprint_px"])
free={(i,j) for j in range(29) for i in range(40) if (i,j) not in blocked}
spawn=tuple(m["spawn_tile"]);assert spawn in free
stack=deque([spawn]);seen={spawn}
while stack:
 i,j=stack.popleft()
 for t in ((i-1,j),(i+1,j),(i,j-1),(i,j+1)):
  if t in free and t not in seen:seen.add(t);stack.append(t)
assert len(free)==len(seen),(len(free),len(seen))
assert (11,8) in free and (12,8) in free and (11,12) in blocked
m["collision_map_29x40"]=[[int((i,j) in blocked) for i in range(40)] for j in range(29)]
m["blocked_cells"]=len(blocked);m["free_cells"]=len(free);m["free_reachable_cells"]=len(seen)
m["collision_gate"]="STATIC_BFS_PASS_NEW_HOUSE_B_FOOTPRINT"
m["stage"]="A36G_R5_R2_BOTH_HOUSES_STYLE_UNIFIED_ENGINE_CANDIDATE"
m["source_stage"]=base["stage"]
m["source_R4_manifest_sha256"]=sha(R4/"A36G_R4_SCENE_MANIFEST.json")
m["house_left_locked_sha256"]=sha(S/a["filename"])
m["house_right_new_sha256"]=sha(new)
m["house_right_old_sha256"]=sha(S/b["filename"])
m["original_ground_sha256"]=sha(R4/"A36G_R4_GROUND_1280x928.png")
m["art_gate"]="CANDIDATE_PENDING_USER_SIGNOFF"
m["formal_seal"]="NO"
# True pixel-source alpha PAR.
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for q in m["objects"]:
 p=S/q["filename"]
 assert sha(p)==q["sha256"],q["id"]
 img=Image.open(p).convert("RGBA")
 assert img.size==(q["w"],q["h"]),q["id"]
 par.alpha_composite(img,(q["x"],q["y"]))
pf=R/"A36G_R5_PAR50_RGBA_1280x928.png"
par.save(pf,optimize=True)
gp=R/"A36G_R5_GROUND_1280x928.png"
shutil.copy2(R4/"A36G_R4_GROUND_1280x928.png",gp)
scene=Image.open(gp).convert("RGBA");scene.alpha_composite(par)
cf=R/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png"
scene.convert("RGB").save(cf,optimize=True)
scene.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(R/"A36G_R5_PREVIEW_640.png",optimize=True)
old=Image.open(R4/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
newfull=scene.convert("RGB")
# 1x comparison of ACTUAL ground and par compositing at cottage location
crop=(720,315,1010,661)
comp=Image.new("RGB",(580,371),(24,28,31));dr=ImageDraw.Draw(comp)
comp.paste(old.crop(crop),(0,25));comp.paste(newfull.crop(crop),(290,25))
dr.text((7,5),"R4 old flat green-roofed RIGHT house",fill="white")
dr.text((296,5),"R5 new matching RIGHT house",fill="white")
comp.save(R/"A36G_R4_VS_R5_RIGHT_HOUSE_1X_BEFORE_AFTER.png",optimize=True)
full=Image.new("RGB",(1280,492),(24,27,30));d=ImageDraw.Draw(full)
full.paste(old.resize((640,464),Image.Resampling.NEAREST),(0,28))
full.paste(newfull.resize((640,464),Image.Resampling.NEAREST),(640,28))
d.text((5,7),"R4  - two houses mismatched",fill="white")
d.text((649,7),"R5 R2 - matching moss/wood/stone art family",fill="white")
full.save(R/"A36G_R4_VS_R5_FULL_MAP_TRUE_GROUND_PAR.png",optimize=True)
# Actual independent RGBA comparison, not a conceptual illustration
review=Image.new("RGBA",(600,296),(211,212,203,255))
review.alpha_composite(Image.open(S/a["filename"]).convert("RGBA"),(14,14))
review.alpha_composite(im,(316,12))
review.convert("RGB").save(R/"A36G_R5_TWO_ACTUAL_RGBA_HOUSE_SOURCES.png",optimize=True)
m["ground_sha256"]=sha(gp);m["par_sha256"]=sha(pf);m["composite_sha256"]=sha(cf)
(R/"A36G_R5_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),"utf8")
qa={"stage":m["stage"],"source_objects":len(m["objects"]),
 "right_new_full_sprite_rgba_sha256":sha(new),"right_new_source_size":list(im.size),
 "right_source_rgba_bbox":box,"right_truly_uncropped":True,
 "original_left_house_sha256":a["sha256"],"left_unchanged":sha(S/a["filename"])==a["sha256"],
 "old_right_house_sha256":b["sha256"],"right_origin":[x,y],"right_foot":[869,596],
 "actual_right_world_alpha_bbox":[x+box[0],y+box[1],x+box[2],y+box[3]],
 "right_new_blocking_footprint_px":o["blocking_footprint_px"],
 "collision_blocked":len(blocked),"collision_walkable":len(free),"collision_reachable":len(seen),
 "ground_sha256":sha(gp),"ground_unchanged":sha(gp)==sha(R4/"A36G_R4_GROUND_1280x928.png"),
 "par_sha256":sha(pf),"composite_sha256":sha(cf),
 "forest_source_unchanged":True,"native_vx":"NOT_RUN","godot":"NOT_RUN",
 "art_gate":"PENDING_USER","formal_seal":"NO"}
(R/"A36G_R5_R2_INTEGRATION_QA.json").write_text(json.dumps(qa,indent=2,ensure_ascii=False),"utf8")
print(json.dumps(qa,indent=2,ensure_ascii=False),flush=True)
