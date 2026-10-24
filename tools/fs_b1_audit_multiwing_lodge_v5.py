from pathlib import Path
from PIL import Image
from collections import deque
from shutil import copytree,copy2,rmtree
import json,hashlib,subprocess,sys
R=Path(__file__).resolve().parent.parent
for k in ("negative","logs","outputs"):(R/k).mkdir(exist_ok=True)
m=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
orig=json.loads((R/"scene_manifest_v4_baseline.json").read_text(encoding="utf8"))
obj=next(o for o in m["instances"] if o["id"]=="house_wood_east")
old=next(o for o in orig["instances"] if o["id"]=="house_wood_east")
assert (old["asset_id"],old["dimensions"])==("house_shop",[96,160])
assert (obj["asset_id"],obj["dimensions"])==("lodge_multiwing_v5",[160,192])
assert (obj["x"],obj["y"],obj["draw_order"])==(550,76,268)
assert obj["y"]+obj["dimensions"][1]==obj["draw_order"]
assert obj["collision_local"]==[[15,140,154,178]]
assert len(m["instances"])==len(orig["instances"])==48
assert len(m["ground_decor"])==len(orig["ground_decor"])==43
unchanged=[(a,b) for a,b in zip(m["instances"],orig["instances"]) if a["id"] not in ("house_wood_east","lamp_shop")]
assert len(unchanged)==46 and all(a==b for a,b in unchanged)
assert all(m["ground_decor"][i]==orig["ground_decor"][i] for i in range(43))

ledger=json.loads((R/"input"/"V5_LODGE_CONSTRUCTION_LEDGER.json").read_text(encoding="utf8"))
asset=R/"source"/"clean"/(obj["asset_id"]+".png")
sha=hashlib.sha256(asset.read_bytes()).hexdigest()
assert sha==obj["sha256"]==ledger["source_sha256"]
for part in ledger["built_from_source"]:
 p=R/part["path"]
 assert hashlib.sha256(p.read_bytes()).hexdigest()==part["sha256"],("PART_SOURCE_MISMATCH",part["path"])
hero=Image.open(asset).convert("RGBA")
assert hero.size==(160,192)
assert all(v==0 for v in hero.getchannel("A").histogram()[1:255]),"NON_BINARY_ALPHA"

W,H=864,640
master=Image.open(R/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
ground=Image.open(R/"build"/"FS_ELF_RICH_Ground.png").convert("RGBA")
par=Image.open(R/"build"/"FS_ELF_RICH_Par_COMPLETE.png").convert("RGBA")
coll=Image.open(R/"build"/"FS_ELF_RICH_Collision.png").convert("L")
assert master.size==ground.size==par.size==coll.size==(W,H)
assert ground.getchannel("A").getextrema()==(255,255)
reconstructed=ground.copy()
reconstructed.alpha_composite(par)
assert reconstructed.tobytes()==master.tobytes()
owner=Image.open(R/"outputs"/"PIXEL_OWNER_ID.png")
index=json.loads((R/"outputs"/"INSTANCE_ID_INDEX.json").read_text(encoding="utf8"))
hero_id=int(next(i for i,o in index.items() if o["id"]=="house_wood_east"))
assert index[str(hero_id)]["draw_order"]==268
for role in ("source","terrain"):
 assert (R/role).is_dir() or (R/"source"/role).is_dir()

def clear(tx,ty):
 if not (0<=tx<27 and 0<=ty<20):return False
 cx=tx*32+16;cy=ty*32+16
 return all(coll.getpixel((xx,yy))==0
  for yy in range(max(0,cy-8),min(H-1,cy+8)+1)
  for xx in range(max(0,cx-8),min(W-1,cx+8)+1))
spawn=(m["spawn"]["x"]//32,m["spawn"]["y"]//32)
valid={(tx,ty) for ty in range(20) for tx in range(27) if clear(tx,ty)}
assert spawn in valid
previous={spawn:None}
queue=deque([spawn])
while queue:
 current=queue.popleft()
 for n in ((current[0]+1,current[1]),(current[0]-1,current[1]),(current[0],current[1]+1),(current[0],current[1]-1)):
  if n in valid and n not in previous:previous[n]=current;queue.append(n)
def route(goal):
 assert goal in previous,("UNREACHABLE_TILE",goal)
 out=[]
 while goal is not None:out.append(goal);goal=previous[goal]
 return list(reversed(out))
targets={"BEHIND":(19,5),"FRONT":(19,8)}
overlaps={}
for role,(tx,ty) in targets.items():
 foot=(ty+1)*32
 n=sum(owner.getpixel((xx,yy))==hero_id
    for yy in range(max(0,foot-32),min(H,foot))
    for xx in range(max(0,tx*32),min(W,tx*32+32)))
 assert n>=100,("ZERO_HERO_VISIBLE_OWNER_OVERLAP",role,n)
 assert (foot<=obj["draw_order"])==(role=="BEHIND")
 overlaps[role]={"tile":[tx,ty],"hero_visible_pixels_under_native_actor_bbox":n,
                 "actor_foot_y":foot,"steps_from_spawn":len(route((tx,ty)))-1,
                 "path_from_spawn":route((tx,ty))}
assert all(clear(*pos) for pos in targets.values())
# Negative: the earlier overly deep building collider would obstruct the actor's valid front tile.
cx,cy=19*32+16,8*32+16
bad_bbox=[obj["x"]+15,obj["y"]+140,obj["x"]+154,obj["y"]+190]
would_block_front=(bad_bbox[0]<=cx+8 and bad_bbox[2]>cx-8 and
                   bad_bbox[1]<=cy+8 and bad_bbox[3]>cy-8)
assert would_block_front and (19,8) in valid
# source-backed 1px drift actual compiler negative; include fully independent image witness.
temp=R/"negative"/"V5_LODGE_TEMP_COMPILE"
for dn in ("source/clean","source/terrain","scripts","build/semantic_masks","work"): (temp/dn).mkdir(parents=True,exist_ok=True)
copytree(R/"source"/"clean",temp/"source"/"clean",dirs_exist_ok=True)
copytree(R/"source"/"terrain",temp/"source"/"terrain",dirs_exist_ok=True)
copy2(R/"scripts"/"compile_scene_v4.py",temp/"scripts"/"compile_scene_v4.py")
mut=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
changed=next(o for o in mut["instances"] if o["id"]=="house_wood_east")
changed["x"]+=1
(temp/"scene_manifest.json").write_text(json.dumps(mut,ensure_ascii=False,indent=2),encoding="utf8")
ret=subprocess.run([sys.executable,str(temp/"scripts"/"compile_scene_v4.py")],cwd=temp,
                   capture_output=True,text=True,timeout=45)
assert ret.returncode==0,("MUTATED_COMPILE_ERROR",ret.stderr)
shifted=Image.open(temp/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
def count_diff(a,b):
 assert a.size==b.size and a.mode==b.mode=="RGBA"
 return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
drift=count_diff(master,shifted)
assert drift>0
# Visual audit debug only; never alter source. Heatmap uncompressed colors.
red=master.copy();pix=red.load();sa=shifted.load();ma=master.load()
for y in range(H):
 for x in range(W):
  if sa[x,y]!=ma[x,y]:pix[x,y]=(255,38,44,255)
red.save(R/"negative"/"LODGE_SHIFT_1PX_HEATMAP.png")
# Source mismatch gate: malformed SHA must be rejected before any output.
mut=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
next(o for o in mut["instances"] if o["id"]=="house_wood_east")["sha256"]="0"*64
(temp/"scene_manifest.json").write_text(json.dumps(mut,ensure_ascii=False,indent=2),encoding="utf8")
ret2=subprocess.run([sys.executable,str(temp/"scripts"/"compile_scene_v4.py")],cwd=temp,
                    capture_output=True,text=True,timeout=45)
assert ret2.returncode!=0,"TAMPERED_SOURCE_HASH_NOT_BLOCKED"
rmtree(temp)
previous_master=Image.open(R/"baseline"/"v4_master.png").convert("RGBA")
change=count_diff(master,previous_master)
assert change>1000
report={"status":"V5_LODGE_SOURCE_AND_NATIVE_LEGAL_DEPTH_REFERENCE_PASS",
"source_asset_sha256":sha,"source_provenance_parts":len(ledger["built_from_source"]),
"hero_silhouette":[160,192],"previous_silhouette":[96,160],
"master_changed_pixels_from_v4":change,
"master_from_ground_par_rgba_mismatch_pixels":0,
"ground_alpha_min":255,"instances":48,"ground_decor":43,
"hero_owner_id":hero_id,
"walkable_tiles":len(valid),"reachable_tiles":len(previous),
"legal_hero_actor_positions":overlaps,
"negative_old_collision_would_block_front_tile":would_block_front,
"negative_new_lodge_shift_1px_difference_pixels":drift,
"negative_tampered_asset_sha_compile_rejected":True,
"formal_fs_runtime":"NOT_RUN","visual_reference_level":"NOT_PASS","human_gate_f":"NOT_RUN"}
(R/"logs"/"V5_LODGE_LAYER_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V5_LODGE_LAYER_GATE_PASS",json.dumps({
 "v4_to_v5_changed_pixels":change,
 "source_components":len(ledger["built_from_source"]),
 "walkable":len(valid),"reachable":len(previous),
 "behind_steps":overlaps["BEHIND"]["steps_from_spawn"],
 "front_steps":overlaps["FRONT"]["steps_from_spawn"],
 "negative_lodge_1px":drift,
 "tampered_sha_rejected":True},ensure_ascii=False),flush=True)
