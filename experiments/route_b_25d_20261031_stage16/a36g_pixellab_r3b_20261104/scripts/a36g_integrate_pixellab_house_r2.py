from pathlib import Path
import json,hashlib,shutil
from PIL import Image,ImageDraw
G=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
S=G/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
backup=G/"HOUSE_R1_WEST_FOREST_R2_ARCHIVE"
backup.mkdir(exist_ok=True)
for n in ("A36G_SCENE_MANIFEST.json","A36G_PAR50_RGBA_1280x928.png","A36G_TRUE_GROUND_PLUS_PAR_1280x928.png","A36G_PREVIEW_640.png"):
 p=G/n
 if not (backup/n).exists():shutil.copy2(p,backup/n)
m=json.loads((G/"A36G_SCENE_MANIFEST.json").read_text("utf8"))
assert m["stage"]=="A36G_HOUSE_WEST_FOREST_R2_ART_CANDIDATE"
assert len(m["objects"])==411
h=next(o for o in m["objects"] if o["id"]=="A36G_ELF_HOUSE_AND_WORKSHOP")
oldname=h["filename"]
newname="A36G_PIXELLAB_INTEGRATED_HOUSE_R2_RGBA.png"
new=S/newname
im=Image.open(new).convert("RGBA")
assert im.size==(284,259) and im.getbbox()
oldbbox=[h["x"],h["y"],h["x"]+h["w"],h["y"]+h["h"]]
h["filename"]=newname;h["sha256"]=sha(new)
# Align new house's actual door (x~215) to old village footpath x~562.
h["x"]=353;h["y"]=209;h["foot"]=[563,458]
h["source_parent"]="ORIGINAL_A36F_HOUSE_STYLE_REFERENCE_PIXEL_LAB_SINGLE_NATIVE_FULL_BUILDING"
h["design_variation"]="ONE_COMPLETELY_GENERATED_INTEGRATED_GABLED_COTTAGE_LEFT_WORKSHOP"
# Foundation collision estimated from physically occupied facade (not roof), recalculation in engine build.
h["blocking_footprint_px"]=[379,389,618,454]
m["objects"].sort(key=lambda o:(o["foot"][1],o["id"]))
m["stage"]="A36G_PIXELLAB_HOUSE_R2_WEST_FOREST_R2_CANDIDATE"
m["house_art_gate"]="SOURCE_GENERATED_RGBA_PENDING_NATIVE_SCREEN_QA"
m["forest_art_gate"]="FAIL: CONTIGUOUS_CANOPY_STILL_FLAT"
m["formal_seal"]="NO"
m["source_art_approval"]="PENDING"
m["house_source_bbox"]=im.getbbox()
m["house_source_sha256"]=sha(new)
m["house_origin_old_bbox"]=oldbbox
m["house_origin_new_bbox"]=[h["x"],h["y"],h["x"]+h["w"],h["y"]+h["h"]]
# New grounded alignment collision tile calculation (old footprint removed)
blocked={(x,y) for y,row in enumerate(m["collision_map_29x40"]) for x,b in enumerate(row) if b}
old_extent=[433,414,655,463]
def coll(rect):
 x0,y0,x1,y1=rect
 return {(x,y) for y in range(29) for x in range(40) if x0 <=x*32+16 <= x1 and y0 <=y*32+16 <= y1}
blocked=(blocked-coll(old_extent))|coll(h["blocking_footprint_px"])
from collections import deque
free={(x,y) for y in range(29) for x in range(40) if (x,y) not in blocked}
spawn=tuple(m["spawn_tile"]);assert spawn in free
queue=deque([spawn]);seen=set(queue)
while queue:
 x,y=queue.popleft()
 for z in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
  if z in free and z not in seen:queue.append(z);seen.add(z)
m["collision_map_29x40"]=[[int((x,y) in blocked) for x in range(40)] for y in range(29)]
m["blocked_cells"]=len(blocked);m["free_cells"]=len(free);m["free_reachable_cells"]=len(seen)
m["collision_gate"]="STATIC_BFS_PASS" if len(seen)==len(free) else "STATIC_BFS_FAIL"
# Source-sprite reconstruction with actual alpha, not flattening.
par=Image.new("RGBA",(1280,928),(0,0,0,0))
for o in m["objects"]:
 p=S/o["filename"]
 assert sha(p)==o["sha256"],o["id"]
 z=Image.open(p).convert("RGBA");assert z.size==(o["w"],o["h"]),o["id"]
 par.alpha_composite(z,(o["x"],o["y"]))
par.save(G/"A36G_PAR50_RGBA_1280x928.png",optimize=True)
gr=Image.open(G/"A36G_GROUND_1280x928.png").convert("RGBA")
gr.alpha_composite(par)
gr.convert("RGB").save(G/"A36G_TRUE_GROUND_PLUS_PAR_1280x928.png",optimize=True)
gr.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(G/"A36G_PREVIEW_640.png",optimize=True)
baseline=Image.open(backup/"A36G_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
now=gr.convert("RGB")
panel=Image.new("RGB",(840,400),(25,28,25))
for i,z in enumerate((baseline,now)):
 panel.paste(z.crop((305,166,725,566)),(i*420,0))
panel.save(G/"A36G_HOUSE_R1_VS_PIXELLAB_R2_NATIVE_BEFORE_AFTER.png",optimize=True)
m["ground_sha"]=sha(G/"A36G_GROUND_1280x928.png")
m["par_sha"]=sha(G/"A36G_PAR50_RGBA_1280x928.png")
m["composite_sha"]=sha(G/"A36G_TRUE_GROUND_PLUS_PAR_1280x928.png")
(G/"A36G_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),"utf8")
qa={"stage":m["stage"],"house_source":newname,"source_sha":h["sha256"],
 "source_size":list(im.size),"original_reference_sha":sha(S/oldname),
 "house_origin":(h["x"],h["y"]),"house_foot":h["foot"],"source_alpha_bbox":im.getbbox(),
 "source_corners_alpha":[im.getpixel(p)[3] for p in ((0,0),(283,0),(0,258),(283,258))],
 "objects":len(m["objects"]),"collision_blocked":len(blocked),"free":len(free),"reachable":len(seen),
 "static_collision_gate":m["collision_gate"],"native_vx":"PENDING","godot":"PENDING",
 "art_gate":"PENDING","formal_seal":"NO"}
(G/"A36G_PIXELLAB_HOUSE_R2_INTEGRATION_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),"utf8")
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)