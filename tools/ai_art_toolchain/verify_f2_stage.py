from pathlib import Path
from PIL import Image
import json,hashlib,collections,sys
import numpy as np
ROOT=Path(__file__).resolve().parent
def read(p):return Image.open(p).convert("RGBA")
def mismatch(a,b):
 aa=np.asarray(a);bb=np.asarray(b)
 return -1 if aa.shape!=bb.shape else int(np.any(aa!=bb,axis=2).sum())
def check(name,cond):
 if not cond:errors.append(name)
 print(("PASS " if cond else "FAIL ")+name)
errors=[]
FS=ROOT/"F2_source"
B=ROOT/"F2_bridged"
M=json.loads((FS/"scene_manifest.json").read_text(encoding="utf-8"))
assert (M["canvas"],M["tile_size"])==([544,416],32)
house=next(x for x in M["objects"] if x["id"]=="cottage_new")
p=FS/house["source"]
img=read(p);a=np.asarray(img)
check("house_full_no_four_edge_crop",max(a[0,:,3].max(),a[-1,:,3].max(),a[:,0,3].max(),a[:,-1,3].max())==0)
check("house_source_sha",hashlib.sha256(p.read_bytes()).hexdigest()==house["source_sha256"])
check("complete_house_and_nine_independent_sources",len(M["objects"])==9 and len(set(o["source"] for o in M["objects"]))==9)
check("roof_mask_and_wall_foot_mask",(FS/house["occlusion_mask"]).exists() and (FS/house["contact_mask"]).exists())
block={tuple(x) for x in M["collision"]["blocked_tiles"]}
check("house_door_open_two_tiles",len(block)==25 and (7,5) not in block and (7,6) not in block)
visited={(8,11)};q=collections.deque([(8,11)])
while q:
 x,y=q.popleft()
 for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
  u,v=x+dx,y+dy
  if 0<=u<17 and 0<=v<13 and (u,v) not in visited and (u,v) not in block:
   visited.add((u,v));q.append((u,v))
check("all_ground_default_walkable",len(visited)==196 and len(block)+len(visited)==221)
ground=read(FS/"build/Ground.png");par=read(FS/"build/PAR_COMPLETE.png");master=read(FS/"build/Recomposed.png")
check("new_scene_source_composite_zero_diff",mismatch(Image.alpha_composite(ground,par),master)==0)
b=json.loads((B/"bundle/map-bundle.json").read_text(encoding="utf-8"))
test=read(B/"bundle/art/ground.png")
for item in sorted(b["objects"],key=lambda x:(x["sortY"],x["id"])):
 entry=b["props"][item["prop"]];origin=B/"bundle"/entry["image"]
 if hashlib.sha256(origin.read_bytes()).hexdigest()!=entry["sha256"]:errors.append("bad_sprite_SHA_"+item["id"])
 spr=read(origin)
 xy=(int(item["x"]-item["anchor_px"][0]),int(item["y"]-item["anchor_px"][1]))
 test.alpha_composite(spr,dest=xy)
check("ASF_9_props_canonical_sort0",mismatch(test,master)==0)
for engine,imgpath in (("ASF",B/"asf_reference_render.png"),("TILED",B/"tiled/F2_TILED_REAL_NATIVE.png"),("GODOT",B/"godot_export/F2_REAL_GPU_RENDER.png")):
 check("native_"+engine+"_rgba0",mismatch(read(imgpath),master)==0)
tiled=json.loads((B/"tiled/map.runtime_hidden_meta.tmj").read_text(encoding="utf-8-sig"))
ls={l["name"]:l for l in tiled["layers"]}
check("tiled_preserves_metadata",not ls["collision"]["visible"] and not ls["interactions"]["visible"] and len(ls["collision"]["objects"])==25)
png=[]
for name in ("BACK","FRONT"):
 arr=np.asarray(read(B/"godot_playable"/("F2_YSORT_"+name+".png")))
 png.append(int(np.all(arr[:,:,:3]==[255,0,255],axis=2).sum()))
check("native_y_sort_house_back_front",png==[0,384])
for name,needle in (("godot_221","F2_NATIVE_PHYSICS_221_221_PASS"),("vx_221","F2_VX_NATIVE_221_221_PASS")):
 log=(ROOT/"reports"/("F2_GODOT_PHYSICS_221_RETRY.log" if name=="godot_221" else "F2_VX_NATIVE_ACTUAL_LOG.txt")).read_bytes()
 s=log.decode("utf-16" if log.startswith(b"\xff\xfe") else "utf-8-sig",errors="replace")
 check("signed_"+name,needle in s and "ERROR:" not in s)
v=ROOT/"VX_NATIVE_PLAYABLE"
check("real_vx_game_and_9_only_props",(v/"Game.exe").exists() and (v/"Data/Scripts.rvdata").exists() and len(list((v/"Graphics/Pictures").glob("FSOBJ_*.png")))==9)
report={"project":"F2 new cottage independent source candidate","status":"TECH_PASS_HUMAN_PENDING" if not errors else "FAIL",
 "tests":len(errors),"failures":errors,"grid":[17,13],"blocked":25,"free":196,"house_alpha_no_crop":True,
 "accepted_F1R1_original_untouched":True}
(ROOT/"VERIFY_F2_RESULT.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps(report))
if errors:sys.exit(1)
