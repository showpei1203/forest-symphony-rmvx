from pathlib import Path
from PIL import Image, ImageDraw
from collections import deque
from zipfile import ZipFile
from shutil import copy2
import hashlib,json
R=Path(__file__).resolve().parent.parent
V1=R/"baseline_v1"
for s in ("source/clean","source/patches","build","semantic_masks","logs","input"):
 (R/s).mkdir(parents=True,exist_ok=True)
def sha(p):
 h=hashlib.sha256()
 with p.open("rb") as f:
  for data in iter(lambda:f.read(1048576),b""):h.update(data)
 return h.hexdigest()
original=json.loads((V1/"source_candidate"/"scene_manifest.json").read_text(encoding="utf8"))
assert original["canvas"]==[544,416] and len(original["objects"])==6
for ob in original["objects"]:
 f=V1/"source_candidate"/ob["authoritative_asset_path"]
 assert sha(f)==ob["source_sha256"]
 copy2(f,R/"source"/"clean"/(ob["asset_id"]+".png"))
z=ZipFile(V1/"source_archives"/"FS_STYLE_FIRST_FOREST_BENCH_V1_PRIVATE_SOURCE_CANDIDATE.zip")
for name in ("grass_decal_01","grass_decal_02","dirt_corner_01"):
 f=R/"source"/"patches"/(name+".png")
 f.write_bytes(z.read("source/"+name+".png"))
sheet=V1/"reference_sheets"/"ai_par_prop_sheet_20261024.png"
parent=Image.open(sheet).convert("RGBA")
assert parent.size==(1448,1086)
parenthash=sha(sheet)
parts=[
 ("stone_well_src",(1085,822,1252,981),.47,(164,198),"well",(21,45,61,69)),
 ("village_noticeboard_src",(1250,580,1442,749),.47,(337,169),"board",(14,51,76,78)),
 ("flower_hedge_src",(337,374,525,529),.43,(145,308),"bush",(15,47,69,65))]
def largest(alpha):
 w,h=alpha.size;v=alpha.load();seen=set();groups=[]
 for y in range(h):
  for x in range(w):
   if not v[x,y] or (x,y) in seen:continue
   q=deque([(x,y)]);seen.add((x,y));pts=[]
   while q:
    a,b=q.popleft();pts.append((a,b))
    for dx,dy in ((-1,0),(1,0),(0,1),(0,-1),(-1,-1),(-1,1),(1,-1),(1,1)):
     xx,yy=a+dx,b+dy
     if 0<=xx<w and 0<=yy<h and v[xx,yy] and (xx,yy) not in seen:
      seen.add((xx,yy));q.append((xx,yy))
   groups.append(pts)
 groups.sort(key=len,reverse=True)
 out=Image.new("L",(w,h),0);px=out.load()
 for x,y in groups[0]:px[x,y]=255
 return out,sum(len(g) for g in groups[1:])
added=[];crop_ledger=[]
for name,bbox,scale,(x,y),kind,collision in parts:
 raw=parent.crop(bbox).convert("RGBA")
 mask=raw.getchannel("A").point(lambda a:255 if a>=64 else 0)
 tight=mask.getbbox();assert tight
 raw=raw.crop(tight);mask=mask.crop(tight)
 mask,orphan=largest(mask)
 raw.putalpha(mask)
 spr=raw.resize((round(raw.width*scale),round(raw.height*scale)),Image.Resampling.NEAREST)
 w,h=spr.size
 assert set(spr.getchannel("A").get_flattened_data()).issubset({0,255})
 assert collision[2]<=w and collision[3]<=h
 dest=R/"source"/"clean"/(name+".png");spr.save(dest)
 ob={"instance_id":name,"asset_id":name,"source_sha256":sha(dest),"x":x,"y":y,
 "width":w,"height":h,"foot_anchor":[x+w//2,y+h-2],"z_order":y+h-2,
 "kind":kind,"collision_local":list(collision),
 "occlusion_local":[0,0,w,collision[1]+3],"transform":"NONE",
 "authoritative_asset_path":"source/clean/"+name+".png"}
 added.append(ob)
 crop_ledger.append({"name":name,"parent":"ai_par_prop_sheet_20261024.png","parent_sha256":parenthash,
 "crop":bbox,"tight_box":tight,"scale":scale,"resize":"NEAREST","orphan_pixels_removed":orphan,
 "binary_alpha":"THRESHOLD64_LARGEST_CC_PRIVATE_ONLY","sha256":sha(dest),"dimensions":[w,h]})
ground=Image.open(V1/"source_candidate"/"build"/"Ground.png").convert("RGBA")
assert ground.size==(544,416) and ground.getchannel("A").getextrema()==(255,255)
ground_patches=[]
for name,x,y in (("grass_decal_01",147,46),("grass_decal_02",129,345),("dirt_corner_01",352,172)):
 f=R/"source"/"patches"/(name+".png")
 spr=Image.open(f).convert("RGBA")
 assert set(spr.getchannel("A").get_flattened_data()).issubset({0,255})
 assert x+spr.width<=544 and y+spr.height<=416
 ground.alpha_composite(spr,(x,y))
 ground_patches.append({"source":str(f.relative_to(R)).replace("\\","/"),"sha256":sha(f),
                       "asset_id":name,"x":x,"y":y,"width":spr.width,"height":spr.height})
assert ground.getchannel("A").getextrema()==(255,255)
gname=R/"source"/"style_ground_v2.png";ground.save(gname)
for ob in original["objects"]:
 ob["authoritative_asset_path"]="source/clean/"+ob["asset_id"]+".png"
objects=sorted(original["objects"]+added,key=lambda o:(o["foot_anchor"][1],o["instance_id"]))
assert len(objects)==9
manifest=json.loads(json.dumps(original))
manifest.update({"schema":"FS_STYLE_FIRST_V2_SOURCE_MANIFEST",
"source_ground":"source/style_ground_v2.png","source_ground_sha256":sha(gname),
"objects":objects,"ground_decor":ground_patches,
"source_asset_registry":"input/V2_STYLE_ASSET_LEDGER.json",
"parent_v1_manifest_sha256":sha(V1/"source_candidate"/"scene_manifest.json"),
"style_direction":"USER_POSITIVE_FEEDBACK_STYLE_FIRST_V1",
"status":"SOURCE_COMPILED_NATIVE_NOT_TESTED",
"sources_rights":"PRIVATE_TEST_CANDIDATE_NOT_COMMERCIAL_APPROVED"})
(R/"scene_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
(R/"input"/"V2_STYLE_ASSET_LEDGER.json").write_text(json.dumps({
"parent_v1_manifest_sha256":manifest["parent_v1_manifest_sha256"],
"style_anchor":"USER_VISUAL_POSITIVE_FEEDBACK_V1",
"original_generated_sheet_sha256":parenthash,
"new_PAR":crop_ledger,"new_ground_patches":ground_patches,
"new_GROUND_sha256":sha(gname),"rights":"PRIVATE_TEST_ONLY"},ensure_ascii=False,indent=2),encoding="utf8")
par=Image.new("RGBA",(544,416));owner=Image.new("I;16",(544,416))
coll=Image.new("L",(544,416),0);occl=Image.new("RGBA",(544,416))
o_px=owner.load();dr=ImageDraw.Draw(coll)
for i,ob in enumerate(objects,1):
 src=R/ob["authoritative_asset_path"];assert sha(src)==ob["source_sha256"]
 img=Image.open(src).convert("RGBA")
 assert img.size==(ob["width"],ob["height"])
 x,y=ob["x"],ob["y"];w,h=img.size
 assert 0<=x and x+w<=544 and 0<=y and y+h<=416
 par.alpha_composite(img,(x,y))
 v=img.getchannel("A").load()
 for yy in range(h):
  for xx in range(w):
   if v[xx,yy]:o_px[x+xx,y+yy]=i
 lx0,ly0,lx1,ly1=ob["collision_local"]
 dr.rectangle((x+lx0,y+ly0,x+lx1-1,y+ly1-1),fill=255)
 alpha=img.getchannel("A")
 mask=Image.new("L",(w,h),0)
 ImageDraw.Draw(mask).rectangle((0,0,w-1,min(h-1,ly0+2)),fill=255)
 mask=Image.composite(alpha,Image.new("L",(w,h),0),mask)
 above=img.copy();above.putalpha(mask);occl.alpha_composite(above,(x,y))
 target=R/"semantic_masks"/ob["instance_id"];target.mkdir(exist_ok=True)
 alpha.save(target/"alpha.png");mask.save(target/"occlusion.png")
 c=Image.new("L",(w,h),0)
 ImageDraw.Draw(c).rectangle((lx0,ly0,lx1-1,ly1-1),fill=255)
 c.save(target/"collision.png")
comp=ground.copy();comp.alpha_composite(par)
out=R/"build"
for name,im in (("Ground.png",ground),("PAR_COMPLETE.png",par),("Recomposed.png",comp),
                ("PixelOwner16.png",owner),("Occlusion.png",occl),("Collision.png",coll)):
 im.save(out/name)
verify=ground.copy();verify.alpha_composite(Image.open(out/"PAR_COMPLETE.png").convert("RGBA"))
assert verify.tobytes()==Image.open(out/"Recomposed.png").convert("RGBA").tobytes()
blocked=[]
for ty in range(13):
 for tx in range(17):
  cx,cy=tx*32+16,ty*32+16
  if any(coll.getpixel((xx,yy)) for yy in range(cy-8,cy+9) for xx in range(cx-8,cx+9)):
   blocked.append([tx,ty])
assert [8,11] not in blocked and [8,10] not in blocked and len(blocked)>=10
old=Image.open(V1/"source_candidate"/"build"/"Recomposed.png").convert("RGBA")
changed=sum(a!=b for a,b in zip(old.get_flattened_data(),comp.get_flattened_data()))
assert changed>1500
(R/"logs"/"V2_STYLE_SOURCE_COMPILE_GATE.json").write_text(json.dumps({
"status":"STYLE_V2_SOURCE_GROUND_PAR_COMPILED_NATIVE_PENDING",
"new_objects":len(added),"total_objects":len(objects),"ground_patches":len(ground_patches),
"changed_rgba_pixels_from_v1":changed,"strict_recompose_mismatches":0,
"blocked_tiles":blocked,"source_ground_sha256":sha(gname),
"rights":"PRIVATE_TEST_ONLY","human_gate_f":"NOT_RUN"},ensure_ascii=False,indent=2),encoding="utf8")
print("STYLE_V2_SOURCE_PASS",json.dumps({"new_ground_sha":sha(gname)[:16],"objects":len(objects),
 "blocked":len(blocked),"changed_pixels":changed,"new_par":len(added)},ensure_ascii=False),flush=True)
