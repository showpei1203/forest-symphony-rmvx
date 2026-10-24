from pathlib import Path
from PIL import Image,ImageDraw
from collections import deque
from shutil import copy2,copytree
import hashlib,json
R=Path(__file__).resolve().parent.parent
V=R/"baseline_v21"
P=R.parent
for x in ("source/clean","source/atlas","source/generated","source/baseline","input",
          "build","semantic_masks","logs","scripts","native_template"):
 (R/x).mkdir(parents=True,exist_ok=True)
def sha(p):
 h=hashlib.sha256()
 with p.open("rb") as f:
  for b in iter(lambda:f.read(1048576),b""):h.update(b)
 return h.hexdigest()
COPY=R/"source"/"clean"
v21=json.loads((V/"scene_manifest.json").read_text(encoding="utf8"))
assert v21["canvas"]==[544,416] and len(v21["objects"])==9
for o in v21["objects"]:
 src=V/o["authoritative_asset_path"]
 assert sha(src)==o["source_sha256"],o["instance_id"]
 copy2(src,COPY/(o["asset_id"]+".png"))
src_ground=V/"source"/"style_ground_v2.png"
assert sha(src_ground)==v21["source_ground_sha256"]
copy2(src_ground,R/"source"/"baseline"/"style_ground_v21.png")
source_sheet=V/"baseline_v1"/"reference_sheets"/"ai_par_prop_sheet_20261024.png"
copy2(source_sheet,R/"source"/"atlas"/"ai_par_prop_sheet_20261024.png")
S=Image.open(source_sheet).convert("RGBA")
# Complete large tree is the top-left isolated 8-connected alpha component on the same art sheet.
bbox=(12,7,373,388)
roi=(9,4,376,391)
raw=S.crop(roi)
alpha=raw.getchannel("A").point(lambda x:255 if x>=64 else 0)
w,h=alpha.size; pix=alpha.load();seen=set();parts=[]
for y in range(h):
 for x in range(w):
  if (x,y) in seen or not pix[x,y]:continue
  q=deque([(x,y)]);seen.add((x,y));pts=[]
  while q:
   sx,sy=q.popleft();pts.append((sx,sy))
   for dx,dy in ((-1,0),(1,0),(0,-1),(0,1),(-1,-1),(1,-1),(-1,1),(1,1)):
    xx,yy=sx+dx,sy+dy
    if 0<=xx<w and 0<=yy<h and (xx,yy) not in seen and pix[xx,yy]:
     seen.add((xx,yy));q.append((xx,yy))
  parts.append(pts)
parts.sort(key=len,reverse=True)
assert len(parts)>=1 and len(parts[0])==85143,(len(parts),len(parts[0]))
t=(min(x for x,y in parts[0]),min(y for x,y in parts[0]),
   max(x for x,y in parts[0])+1,max(y for x,y in parts[0])+1)
assert t==(3,3,364,384),t
mask=Image.new("L",(w,h));mp=mask.load()
for x,y in parts[0]:mp[x,y]=255
raw.putalpha(mask)
# Pixel-crisp transparent hygiene: leave no invisible RGB fringe to leak on import.
raw.putdata([(r,g,b,a) if a else (0,0,0,0) for r,g,b,a in raw.get_flattened_data()])
size=(round(raw.width*.58),round(raw.height*.58))
sprite=raw.resize(size,Image.Resampling.NEAREST)
assert size==(213,224) and sprite.getchannel("A").getextrema()==(0,255)
assert set(sprite.getchannel("A").get_flattened_data()).issubset({0,255})
assert sprite.getchannel("A").getbbox()[0]>0
newfile=R/"source"/"generated"/"sacred_tree_style_v22.png";sprite.save(newfile)
# Unlike old v9, new landmark is derived directly from the approved painterly AI asset sheet.
cut_y=156
trunk=sprite.copy();above=sprite.copy()
trunk_mask=sprite.getchannel("A").copy();tm=trunk_mask.load()
canopy_mask=sprite.getchannel("A").copy();cm=canopy_mask.load()
for y in range(size[1]):
 for x in range(size[0]):
  if y<cut_y:tm[x,y]=0
  else:cm[x,y]=0
trunk.putalpha(trunk_mask);above.putalpha(canopy_mask)
trunk.save(R/"source"/"generated"/"sacred_base_v22.png")
above.save(R/"source"/"generated"/"sacred_canopy_v22.png")
proof=trunk.copy();proof.alpha_composite(above)
assert proof.tobytes()==sprite.tobytes()
objects=[]
for o in v21["objects"]:
 if o["instance_id"]=="forest_tree_east":continue
 obj=json.loads(json.dumps(o))
 obj["authoritative_asset_path"]="source/clean/"+o["asset_id"]+".png"
 if o["instance_id"]=="village_noticeboard_src":
  obj["x"],obj["y"]=20,161
  obj["foot_anchor"]=[20+obj["width"]//2,161+obj["height"]-2]
  obj["z_order"]=obj["foot_anchor"][1]
 if o["instance_id"]=="rock_north":
  obj["x"],obj["y"]=200,19
  obj["foot_anchor"]=[200+obj["width"]//2,19+obj["height"]-3]
  obj["z_order"]=obj["foot_anchor"][1]
 objects.append(obj)
x,y=319,0
sacred={
 "instance_id":"sacred_tree_new_style_v22","asset_id":"sacred_tree_style_v22",
 "authoritative_asset_path":"source/generated/sacred_tree_style_v22.png",
 "source_sha256":sha(newfile),"x":x,"y":y,"width":size[0],"height":size[1],
 "foot_anchor":[x+103,y+221],"z_order":y+221,"kind":"sacred_tree",
 "collision_local":[81,186,137,224],
 "collision_shapes":[{"id":"trunk_and_root_contact","rect":[81,186,137,224]}],
 "base_split_y":cut_y,
 "occlusion_local":[0,0,size[0],cut_y],
 "collision_policy":"ACTOR_FEET_16x12","source_component_area":85143,
 "source_sheet_bbox":bbox,"source_sheet_roi":roi,
 "scale":"0.58 nearest neighbour","style":"STYLE_FIRST_APPROVED_AI_PAR_FAMILY",
 "rights":"PRIVATE_TEST_SOURCE",
 "semantic_masks":{
   "base":"source/generated/sacred_base_v22.png",
   "canopy":"source/generated/sacred_canopy_v22.png",
   "complete":"source/generated/sacred_tree_style_v22.png"
 }
}
assert x+size[0]<=544 and y+size[1]<=416
objects.append(sacred)
objects.sort(key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
assert len(objects)==9
GROUND=Image.open(R/"source"/"baseline"/"style_ground_v21.png").convert("RGBA")
assert GROUND.size==(544,416) and GROUND.getchannel("A").getextrema()==(255,255)
PAR=Image.new("RGBA",(544,416));OWNER=Image.new("I;16",(544,416),0)
C=Image.new("L",(544,416),0);occ=Image.new("RGBA",(544,416));dp=ImageDraw.Draw(C)
op=OWNER.load()
for i,o in enumerate(objects,1):
 asset=R/o["authoritative_asset_path"]
 assert sha(asset)==o["source_sha256"]
 a=Image.open(asset).convert("RGBA")
 sx,sy=o["x"],o["y"]
 PAR.alpha_composite(a,(sx,sy))
 av=a.getchannel("A").load()
 for py in range(a.height):
  for px in range(a.width):
   if av[px,py]:op[sx+px,sy+py]=i
 shapes=o.get("collision_shapes",[{"id":"simple","rect":o["collision_local"]}])
 for shape in shapes:
  lx0,ly0,lx1,ly1=shape["rect"]
  dp.rectangle((sx+lx0,sy+ly0,sx+lx1-1,sy+ly1-1),fill=255)
 M=R/"semantic_masks"/o["instance_id"];M.mkdir(exist_ok=True)
 a.getchannel("A").save(M/"alpha.png")
 if o["instance_id"]=="sacred_tree_new_style_v22":
  mask=canopy_mask
  trunk_mask.save(M/"base.png");canopy_mask.save(M/"occlusion.png")
 else:
  mask=Image.new("L",a.size,0)
  limit=o["collision_local"][1]+3
  ImageDraw.Draw(mask).rectangle((0,0,a.width-1,limit),fill=255)
  mask=Image.composite(a.getchannel("A"),Image.new("L",a.size),mask)
  mask.save(M/"occlusion.png")
 above_a=a.copy();above_a.putalpha(mask);occ.alpha_composite(above_a,(sx,sy))
 collision=Image.new("L",a.size)
 for shape in shapes:
  lx0,ly0,lx1,ly1=shape["rect"]
  b=Image.new("L",a.size)
  ImageDraw.Draw(b).rectangle((lx0,ly0,lx1-1,ly1-1),fill=255)
  b.save(M/("collision_"+shape["id"]+".png"))
  collision=Image.frombytes("L",a.size,bytes(max(c,v) for c,v in zip(collision.getdata(),b.getdata())))
 collision.save(M/"collision.png")
Master=GROUND.copy();Master.alpha_composite(PAR)
out=R/"build"
for name,art in [("Ground.png",GROUND),("PAR_COMPLETE.png",PAR),("Recomposed.png",Master),
                 ("PixelOwner16.png",OWNER),("Collision.png",C),("Occlusion.png",occ)]:
 art.save(out/name)
well_collision=Image.open(R/"semantic_masks"/"stone_well_src"/"collision.png").convert("L")
blocked=[]
for ty in range(13):
 for tx in range(17):
  cx,cy=tx*32+16,ty*32+16
  if any(C.getpixel((px,py)) for py in range(cy-8,cy+9) for px in range(cx-8,cx+9)):
   blocked.append([tx,ty])
# Preserve proven v2.1 additional foot-collision logic for ring & bucket
well=next(o for o in objects if o["instance_id"]=="stone_well_src")
sacred_foot=[]
for o in (well,sacred):
 shapes=o["collision_shapes"]
 footprint=Image.new("L",(544,416),0);p=ImageDraw.Draw(footprint)
 for shape in shapes:
  lx0,ly0,lx1,ly1=shape["rect"]
  p.rectangle((o["x"]+lx0,o["y"]+ly0,o["x"]+lx1-1,o["y"]+ly1-1),fill=255)
 foot=[]
 for ty in range(13):
  for tx in range(17):
   cx,cy=tx*32+16,(ty+1)*32
   if any(footprint.getpixel((xx,yy)) for yy in range(max(0,cy-12),min(416,cy))
          for xx in range(max(0,cx-8),min(544,cx+8))):
    foot.append([tx,ty])
 blocked+=foot
 if o["instance_id"]=="sacred_tree_new_style_v22":sacred_foot=foot
blocked=sorted(set(tuple(x) for x in blocked))
blocked=[list(x) for x in blocked]
assert [8,11] not in blocked
assert sacred_foot
(R/"build"/"BlockedTiles.json").write_text(json.dumps({
 "blocked_tiles":blocked,"sacred_foot_tiles":sacred_foot,
 "well_foot_contact":True,"sacred_overhead_canopy_not_collision":True
},indent=2),encoding="utf8")
manifest={
 "schema":"FS_STYLE_FIRST_V22_SACRED_GROVE",
 "canvas":[544,416],"tile_size":32,
 "source_ground":"source/baseline/style_ground_v21.png",
 "source_ground_sha256":sha(R/"source"/"baseline"/"style_ground_v21.png"),
 "objects":objects,"spawn":[8,11],
 "reused_style":"V21_USER_HUMAN_WELL_PASS_20261024",
 "source_ledger":"input/V22_SACRED_TREE_SOURCE_LEDGER.json",
 "level":0,"rights":"PRIVATE_TEST_ONLY",
 "baseline_v21_manifest_sha256":sha(V/"scene_manifest.json")
}
(R/"scene_manifest.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf8")
ledger={
 "source_sheet":"source/atlas/ai_par_prop_sheet_20261024.png",
 "source_sheet_sha256":sha(R/"source"/"atlas"/"ai_par_prop_sheet_20261024.png"),
 "complete_tree_component_bbox":bbox,
 "complete_tree_component_area":85143,"crop_roi":roi,
 "crop_safety_padding":3,"removed_neighbor_component_pixels":sum(map(len,parts[1:])),
 "resize":"nearest-neighbor to 213x224 (0.58 original crop)",
 "new_tree_source_sha256":sha(newfile),
 "separated_canopy_sha256":sha(R/"source"/"generated"/"sacred_canopy_v22.png"),
 "separated_trunk_sha256":sha(R/"source"/"generated"/"sacred_base_v22.png"),
 "canopy_trunk_pixel_rgba_mismatch":0,
 "collision_in_ground_contact_only":True,
 "v9_old_oak_tree_style":"REJECT_AS_NOT_MATCHING_V21",
 "human_full_visual_gate":"NOT_RUN"
}
(R/"input"/"V22_SACRED_TREE_SOURCE_LEDGER.json").write_text(json.dumps(ledger,indent=2,ensure_ascii=False),encoding="utf8")
assert GROUND.copy().size==(544,416)
assert PAR.getchannel("A").getextrema()[0]==0
print("V22_STYLE_FIRST_SACRED_TREE_COMPILED",json.dumps({
 "full_sheet_component":85143,"new_tree_size":list(size),"9_source_objects":len(objects),
 "blocked_tiles":len(blocked),"sacred_foot_tiles":sacred_foot,
 "source_hash":sha(newfile)[:16],"ground_kept_same":True},ensure_ascii=False),flush=True)
