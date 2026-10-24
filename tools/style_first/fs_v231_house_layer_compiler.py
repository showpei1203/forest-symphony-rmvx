from pathlib import Path
from shutil import copytree,copy2
from PIL import Image,ImageDraw
from collections import deque
import hashlib,json,copy
R=Path(__file__).resolve().parent.parent
P=R.parent
base=R/"baseline_v23"
assert (base/"scene_manifest.json").is_file()
old=json.loads((base/"scene_manifest.json").read_text(encoding="utf8"))
assert old["canvas"]==[544,416] and len(old["objects"])==8
def sha(p):
 h=hashlib.sha256()
 with p.open("rb") as f:
  for chunk in iter(lambda:f.read(1048576),b""):h.update(chunk)
 return h.hexdigest()
def pixels_clean(img):
 return all(not any((r,g,b)) for r,g,b,a in img.convert("RGBA").get_flattened_data() if not a)
assets={
 "elf_blue_cottage_v23":{"file":"elf_blue_cottage.png","kind":"cottage_blue",
    "x":101,"y":1,"contact":[23,116,206,192],
    "door":[114,193],"occlusion_split_y":114},
 "elf_ochre_cottage_v23":{"file":"elf_ochre_cottage.png","kind":"cottage_ochre",
    "x":12,"y":230,"contact":[19,98,206,159],
    "door":[111,160],"occlusion_split_y":94}
}
original=Image.open(R/"source/reference"/"AI_V23_FULL_STYLE_MASTER.png").convert("RGBA")
assert original.size==(1434,1097)
assert sha(R/"source"/"ground_v22.png")==old["source_ground_sha256"]
chosen=[]
for parent in old["objects"]:
 if parent["instance_id"] in ("forest_tree_west","elf_blue_cottage_v23","elf_ochre_cottage_v23"):continue
 o=copy.deepcopy(parent)
 newpath=R/"source"/"reused"/(o["asset_id"]+".png")
 assert sha(newpath)==o["source_sha256"]
 o["authoritative_asset_path"]="source/reused/"+o["asset_id"]+".png"
 if o["instance_id"]=="flower_hedge_src":
  o["x"],o["y"]=255,338
  o["foot_anchor"]=[o["x"]+o["width"]//2,o["y"]+o["height"]-2]
  o["z_order"]=o["foot_anchor"][1]
 if o["instance_id"]=="stone_well_src":
  o["x"],o["y"]=246,219
  o["foot_anchor"]=[o["x"]+o["width"]//2,o["y"]+o["height"]-1]
  o["z_order"]=o["foot_anchor"][1]
 if o["instance_id"]=="crossroad_sign":
  o["x"],o["y"]=342,275
  o["foot_anchor"]=[o["x"]+o["width"]//2,o["y"]+o["height"]]
  o["z_order"]=o["foot_anchor"][1]
 if o["instance_id"]=="sacred_tree_new_style_v22":
  o["x"]=329
  o["foot_anchor"]=[o["x"]+103,o["y"]+221]
  o["z_order"]=o["foot_anchor"][1]
 chosen.append(o)
for name,entry in assets.items():
 sprite=Image.open(R/"source"/"generated"/entry["file"]).convert("RGBA")
 assert pixels_clean(sprite)
 assert sprite.getchannel("A").getextrema()==(0,255)
 assert set(sprite.getchannel("A").get_flattened_data())=={0,255}
 w,h=sprite.size
 assert entry["x"]+w<=544 and entry["y"]+h<=416
 x,y=entry["x"],entry["y"]
 rect=entry["contact"]
 obj={"instance_id":name,"asset_id":name,
      "authoritative_asset_path":"source/generated/"+entry["file"],
      "source_sha256":sha(R/"source"/"generated"/entry["file"]),
      "width":w,"height":h,"x":x,"y":y,
      "foot_anchor":[x+w//2,y+h-2],"z_order":y+h-2,
      "collision_local":rect,"collision_shapes":[{"id":"wall_and_door_footprint","rect":rect}],
      "kind":entry["kind"],"source_generation":"IMAGEGEN_V23_AI_MASTER_REEXTRACTED_20261025",
      "extraction":"EXPLICIT_POLYGON_FULL_BUILDING_COMPONENT_WITH_7PX_PADDING",
      "occlusion_split_y":entry["occlusion_split_y"],
      "door_local":entry["door"],"collision_policy":"ACTOR_FEET_16x12",
      "rights":"PRIVATE_TEST_ONLY"}
 chosen.append(obj)
chosen.sort(key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
assert len(chosen)==7,(len(chosen),[o["instance_id"] for o in chosen])
GROUND=Image.open(R/"source"/"ground_v22.png").convert("RGBA")
assert GROUND.size==(544,416) and GROUND.getchannel("A").getextrema()==(255,255)
PAR=Image.new("RGBA",(544,416))
OWNER=Image.new("I;16",(544,416),0);owner=OWNER.load()
COLL=Image.new("L",(544,416),0);coll=ImageDraw.Draw(COLL)
OCC=Image.new("RGBA",(544,416))
for index,o in enumerate(chosen,1):
 f=R/o["authoritative_asset_path"]
 assert sha(f)==o["source_sha256"]
 im=Image.open(f).convert("RGBA")
 assert im.size==(o["width"],o["height"])
 x,y=o["x"],o["y"]
 PAR.alpha_composite(im,(x,y))
 alpha=im.getchannel("A").load()
 for py in range(im.height):
  for px in range(im.width):
   if alpha[px,py]:owner[x+px,y+py]=index
 shapes=o.get("collision_shapes",[{"id":"generic","rect":o["collision_local"]}])
 c=Image.new("L",im.size,0);ca=ImageDraw.Draw(c)
 for part in shapes:
  x0,y0,x1,y1=part["rect"]
  assert 0<=x0<x1<=im.width and 0<=y0<y1<=im.height
  coll.rectangle((x+x0,y+y0,x+x1-1,y+y1-1),fill=255)
  ca.rectangle((x0,y0,x1-1,y1-1),fill=255)
 mk=R/"semantic_masks"/o["instance_id"];mk.mkdir(exist_ok=True,parents=True)
 c.save(mk/"collision.png")
 im.getchannel("A").save(mk/"alpha.png")
 cut=o.get("occlusion_split_y",o["collision_local"][1])
 mask=Image.new("L",im.size,0)
 d=ImageDraw.Draw(mask);d.rectangle((0,0,im.width-1,cut),fill=255)
 mask=Image.composite(im.getchannel("A"),Image.new("L",im.size,0),mask)
 mask.save(mk/"occlusion.png")
 occluded=im.copy();occluded.putalpha(mask)
 OCC.alpha_composite(occluded,(x,y))
 if o["kind"].startswith("cottage"):
  assert all(c.getpixel((ix,iy))==0 for iy in range(cut) for ix in range(im.width))
MASTER=GROUND.copy();MASTER.alpha_composite(PAR)
for name,im in [("Ground.png",GROUND),("PAR_COMPLETE.png",PAR),("Master.png",MASTER),
                 ("PixelOwner16.png",OWNER),("Collision.png",COLL),("Occlusion.png",OCC)]:
 im.save(R/"build"/name)
blocks=set()
for ty in range(13):
 for tx in range(17):
  cx,cy=tx*32+16,ty*32+16
  if any(COLL.getpixel((xx,yy)) for yy in range(cy-8,cy+9) for xx in range(cx-8,cx+9)):
   blocks.add((tx,ty))
for o in chosen:
 if o["kind"] not in ("well","sacred_tree","cottage_blue","cottage_ochre"):continue
 footmask=Image.new("L",(544,416),0);p=ImageDraw.Draw(footmask)
 for part in o.get("collision_shapes",[{"rect":o["collision_local"]}]):
  x0,y0,x1,y1=part["rect"]
  p.rectangle((o["x"]+x0,o["y"]+y0,o["x"]+x1-1,o["y"]+y1-1),fill=255)
 for ty in range(13):
  for tx in range(17):
   cx,cy=tx*32+16,(ty+1)*32
   if any(footmask.getpixel((xx,yy)) for yy in range(max(0,cy-12),min(416,cy))
           for xx in range(max(0,cx-8),min(544,cx+8))):blocks.add((tx,ty))
assert (8,11) not in blocks
free={(tx,ty) for ty in range(13) for tx in range(17)}-blocks
queue=deque([(8,11)]);reached={(8,11)}
while queue:
 a,b=queue.popleft()
 for nx,ny in ((a+1,b),(a-1,b),(a,b-1),(a,b+1)):
  if (nx,ny) in free and (nx,ny) not in reached:
   reached.add((nx,ny));queue.append((nx,ny))
assert len(reached)>=135,("WALKABLE_SCENE_TOO_SMALL",len(reached))
blocked=sorted(map(list,blocks))
(R/"build"/"BlockedTiles.json").write_text(json.dumps({
 "canvas":[544,416],"blocked_tiles":blocked,"reachable_from_spawn":len(reached),
 "object_foot_collision":"16x12", "houses":[x for x in assets]
},ensure_ascii=False,indent=2),encoding="utf8")
manifest={"schema":"FS_STYLE_FIRST_V231_COTTAGE_FULL_SOURCE_RESCALE",
 "canvas":[544,416],"tile_size":32,"spawn":[8,11],
 "source_ground":"source/ground_v22.png","source_ground_sha256":sha(R/"source"/"ground_v22.png"),
 "objects":chosen,"source_generated_reference":"source/reference/AI_V23_FULL_STYLE_MASTER.png",
 "source_reference_sha256":sha(R/"source/reference/AI_V23_FULL_STYLE_MASTER.png"),
 "baseline_v22_manifest_sha256":sha(base/"scene_manifest.json"),
 "baseline_v22_user_smoke":"2026-10-24_OK",
 "build_status":"V231_REEXTRACTED_LARGER_HOUSES_NATIVE_PENDING",
 "rights":"PRIVATE_TEST_ONLY"}
(R/"scene_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
record={"status":"V231_HOUSES_FULL_SOURCE_MASTER_REEXTRACTED_SCALE_REPAIRED",
 "source_reference_master_sha256":manifest["source_reference_sha256"],
 "generation_id":"5bdfd983-9f00-4f00-bc89-b77c5a8dbc12",
 "house_source_specs":{
  n:{"previous_failed_drive_file_id":("1EN8WrLT00zl-Sycf3Aw0a9QSe5Q4bLeA" if n=="elf_blue_cottage_v23" else "1UkIfAusnU42wC_h5oq1I2f3WD2twQruH"),
     "sprite_sha256":sha(R/"source/generated"/v["file"]),"size":Image.open(R/"source/generated"/v["file"]).size,
     "collision_local":v["contact"],"roof_alpha_not_ground_collision":True}
  for n,v in assets.items()},
 "parent_v22_sha256":sha(base/"scene_manifest.json"),
 "source_quality":"SOURCE_COMPLETENESS_REEXTRACTED_7PX_PADDING_45_PERCENT_LARGER",
 "human_v23_style_quality":"NOT_REVIEWED"}
(R/"input"/"V231_HOUSE_PLACEMENT_LEDGER.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf8")
print("V23_COTTAGE_SOURCE_COMPILE_PASS",json.dumps({
 "objects":len(chosen),"blocked":len(blocks),"reachable":len(reached),
 "house_sources":[x["instance_id"] for x in chosen if x["kind"].startswith("cottage")],
 "source_same_ground":True},ensure_ascii=False),flush=True)
