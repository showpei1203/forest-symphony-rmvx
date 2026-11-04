"""A36G R4: compile true native independent Ground/PAR from source-first whole-forest RGBA.
Fail closed: source SHA, provider lock, size, alpha; scene collision remains geometric baseline until per-root art review.
"""
from pathlib import Path
import json,hashlib,math,shutil
from collections import deque,Counter
import numpy as np
from PIL import Image,ImageDraw
from scipy.ndimage import binary_dilation,distance_transform_edt,label
F=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103")
R3=Path(r"E:\FS_STAGE16_A36G_INTEGRATED_REGIONS_20261104")
R4=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
S=R4/"SOURCE_INDEPENDENT_RGBA"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
plan=json.loads((R4/"R4_FOREST_REGION_BLUEPRINT.json").read_text("utf8"))
regions=plan["regions"]
base=json.loads((R4/"R4_BASE_SCENE_MANIFEST.json").read_text("utf8"))
assert base["stage"]=="A36G_PIXELLAB_HOUSE_R2_WEST_FOREST_R3B_CANDIDATE"
W,H=1280,928
road=np.asarray(Image.open(R4/"A36F_NATURAL_PATH_MASK.png").convert("L"))>127
assert road.shape==(H,W)
# Protect walkways, house footprint plus surrounding access/roof, village intersection.
clear=binary_dilation(road,iterations=19)
safety=Image.new("L",(W,H),0);p=ImageDraw.Draw(safety)
for house in (o for o in base["objects"] if o["type"]=="house"):
 x,y,w,h=house["x"],house["y"],house["w"],house["h"]
 p.rounded_rectangle([x-36,y-33,x+w+31,y+h+39],radius=33,fill=255)
# Open central village green and crossroads between the homes.
p.ellipse((496,345,913,648),fill=255)
# Maintain lower meadow around shop door and road forks.
p.ellipse((400,412,735,594),fill=255)
safety_binary=np.asarray(safety)>0
clear|=safety_binary
Image.fromarray(np.uint8(clear)*255,"L").save(R4/"R4_CLEARING_AND_ROAD_SAFETY_MASK.png")
m=dict(base)
active=[]
all_omitted=[]
all_restored=[]
region_details=[]
# Each provider image is real editable source; do not interpolate, repeat or paste individual tree sprites into it.
for reg in regions:
 rid=reg["id"]
 source=S/f"A36G_R4_{rid}_PIXELLAB_CONTIGUOUS_RGBA.png"
 lock=R4/f"A36G_R4_{rid}_PROVIDER_LOCK.json"
 if not source.exists() or not lock.exists():
  print("NOT_GENERATED_SKIP",rid,flush=True)
  continue
 l=json.loads(lock.read_text("utf8"))
 assert l["status"]=="SOURCE_READY_ART_UNREVIEWED" and l["output_sha"]==sha(source),(rid,l.get("status"))
 img=Image.open(source).convert("RGBA")
 assert img.size==(reg["w"],reg["h"]),(rid,img.size,reg["w"],reg["h"])
 active.append(reg)
 # Build pixel-aligned cutout from real world-coordinate collision/road safety, preserve full source file.
 ox,oy=reg["x"],reg["y"];w,h=img.size
 blocked_mask=np.zeros((h,w),bool)
 gx0=max(0,ox);gx1=min(W,ox+w)
 gy0=max(0,oy);gy1=min(H,oy+h)
 if gx0<gx1 and gy0<gy1:
  blocked_mask[gy0-oy:gy1-oy,gx0-ox:gx1-ox]=clear[gy0:gy1,gx0:gx1]
 dist=distance_transform_edt(~blocked_mask)
 a=np.array(img,dtype=np.uint8)
 original_a=a[:,:,3].astype(np.float32)
 factor=np.clip((dist-0.5)/5.5,0,1)
 a[:,:,3]=np.clip(original_a*factor,0,255).astype(np.uint8)
 a[a[:,:,3]==0,:3]=0
 safeimg=Image.fromarray(a,"RGBA")
 safe_name=f"A36G_R4_{rid}_COMPILED_CLEARING_SAFE_RGBA.png"
 safeimg.save(S/safe_name,optimize=True)
 # Preserve realistic local alpha coverage for replacing old independent sprites.
 comp_a=np.array(safeimg.getchannel("A"),dtype=np.uint8)
 removed=[]
 for o in m["objects"]:
  if o["type"] not in ("tree","shrub"):continue
  fx,fy=o["foot"];lx=int(round(fx-ox));ly=int(round(fy-oy))
  if 0<=lx<w and 0<=ly<h and int(comp_a[ly,lx])>=160:
   removed.append(o)
 if not removed:
  print("REGION_NO_ROOT_REPLACED",rid,flush=True)
 ids={x["id"] for x in removed}
 m["objects"]=[o for o in m["objects"] if o["id"] not in ids]
 all_omitted.extend(removed)
 # Segments are contiguous rectangular crops from same source, sorted by true world-y foot.
 strips=[]
 for iy,y0 in enumerate(range(0,h,91)):
  y1=min(h,y0+91)
  cut=safeimg.crop((0,y0,w,y1))
  if not cut.getbbox():continue
  f=f"A36G_R4_{rid}_DEPTH_{iy+1:02d}_RGBA.png"
  cut.save(S/f,optimize=True)
  ybottom=oy+y1
  strips.append({"id":f"a36g_r4_{rid.lower()}_depth_{iy+1:02d}",
     "type":"forest_group","x":ox,"y":oy+y0,"w":w,"h":y1-y0,
     "foot":[max(0,min(1279,ox+w//2)),ybottom],
     "filename":f,"sha256":sha(S/f),"blocking":False,"alpha_isolated":True,
     "continuous_source":source.name,"compiled_source":safe_name,
     "region_id":rid,"depth_interval":[oy+y0,ybottom]})
 m["objects"].extend(strips)
 labels,count=label(comp_a>127)
 bins=np.bincount(labels[labels>0])
 largest=(int(bins.max())/int((comp_a>127).sum())) if bins.size else 0.0
 region_details.append({"id":rid,"world_bbox":[ox,oy,ox+w,oy+h],
  "source_size":[w,h],"pixel_source_sha256":sha(source),"compiled_source_sha256":sha(S/safe_name),
  "source_bbox_alpha":img.getbbox(),"source_alpha_pixels":int((np.array(img.getchannel("A"))>127).sum()),
  "compiled_alpha_pixels":int((comp_a>127).sum()),"connected_component_count":count,
  "largest_component_fraction":round(largest,5),
  "former_sprite_objects_removed":len(removed),
  "former_blocking_tree_roots":sum(o.get("blocking",False) and o["type"]=="tree" for o in removed),
  "old_removed_root_anchors":[o["foot"] for o in removed if o["type"]=="tree" and o.get("blocking")],
  "new_depth_strips":len(strips),"source_sha256":sha(source),"compiled_sha256":sha(S/safe_name),
  "source_format":"single_contiguous_native_provider_RGBA","art_gate":"PENDING_USER_REVIEW"})
 m["objects"].sort(key=lambda o:(o["foot"][1],o["id"]))
assert active,"No provider forest generated; fail closed"
# Existing verified collision topology maintained; per-root geometry mapping is a distinct test to run.
blocked={(x,y) for y,row in enumerate(m["collision_map_29x40"]) for x,v in enumerate(row) if v}
free={(x,y) for y in range(29) for x in range(40) if (x,y) not in blocked}
spawn=tuple(m["spawn_tile"])
assert spawn in free
q=deque([spawn]);seen={spawn}
while q:
 x,y=q.popleft()
 for z in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
  if z in free and z not in seen:
   seen.add(z);q.append(z)
assert len(seen)==len(free),(len(seen),len(free))
m["stage"]=f"A36G_R4_FOREST_{len(active)}REGIONS_ENGINE_CANDIDATE"
m["source_stage"]=base["stage"]
m["forest_regions_R4"]=region_details
m["forest_group_source_count_R4"]=len(active)
m["collision_gate"]="STATIC_BFS_PASS; PER_ROOT_VISUAL_MATCH_PENDING"
m["forest_art_gate"]="PENDING_USER_REVIEW"
m["formal_seal"]="NO"
# Accurate final scene: ground, alpha PAR, and composite are three independent files.
gp=R4/"A36G_R4_GROUND_1280x928.png"
pfile=R4/"A36G_R4_PAR50_RGBA_1280x928.png"
par=Image.new("RGBA",(W,H),(0,0,0,0))
for o in m["objects"]:
 p=S/o["filename"]
 assert p.exists() and sha(p)==o["sha256"],(o["id"],str(p))
 s=Image.open(p).convert("RGBA")
 assert s.size==(o["w"],o["h"]),(o["id"],s.size)
 par.alpha_composite(s,(o["x"],o["y"]))
par.save(pfile,optimize=True)
g=Image.open(gp).convert("RGBA")
g.alpha_composite(par)
cf=R4/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png"
g.convert("RGB").save(cf,optimize=True)
g.convert("RGB").resize((640,464),Image.Resampling.NEAREST).save(R4/"A36G_R4_PREVIEW_640.png",optimize=True)
old=Image.open(R4/"A36G_R3B_BASE_COMPOSITE_1280x928.png").convert("RGB")
panel=Image.new("RGB",(1280,492),(26,28,28))
panel.paste(old.resize((640,464),Image.Resampling.NEAREST),(0,28))
panel.paste(g.convert("RGB").resize((640,464),Image.Resampling.NEAREST),(640,28))
dp=ImageDraw.Draw(panel)
dp.text((8,8),"R3B BASE | Single integrated WEST forest",fill="white")
dp.text((650,8),f"R4 | {len(active)} real integrated new forest groups",fill="white")
panel.save(R4/"A36G_R3B_VS_R4_TRUE_GROUND_PAR_BEFORE_AFTER.png",optimize=True)
m["ground_sha256"]=sha(gp)
m["par_sha256"]=sha(pfile)
m["composite_sha256"]=sha(cf)
(R4/"A36G_R4_SCENE_MANIFEST.json").write_text(json.dumps(m,ensure_ascii=False,indent=2),"utf8")
qa={"stage":m["stage"],"region_count":len(active),"regions":[r["id"] for r in active],
 "source_full_region_pngs":len(active),"source_objects":len(m["objects"]),
 "source_roots_replaced":sum(q["former_sprite_objects_removed"] for q in region_details),
 "root_blocks_requiring_visual_audit":sum(q["former_blocking_tree_roots"] for q in region_details),
 "forest_depth_strip_count_new":sum(q["new_depth_strips"] for q in region_details),
 "blocked":len(blocked),"free":len(free),"reachable":len(seen),
 "ground_sha256":sha(gp),"par_sha256":sha(pfile),"composite_sha256":sha(cf),
 "A36F_immutable_sha256":sha(F/"A36F_SCENE_MANIFEST.json"),
 "R3B_immutable_sha256":sha(R3/"A36G_SCENE_MANIFEST.json"),
 "art_gate":"PENDING","native_vx":"NOT_TESTED","godot":"NOT_TESTED",
 "formal_seal":"NO"}
(R4/"A36G_R4_INTEGRATION_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),"utf8")
print(json.dumps(qa,ensure_ascii=False,indent=2),flush=True)
