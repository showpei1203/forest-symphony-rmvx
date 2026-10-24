from pathlib import Path
from PIL import Image
from collections import deque
from shutil import copy2,copytree,rmtree
import hashlib,json,subprocess,sys
R=Path(__file__).resolve().parent.parent
src=R/"source"/"clean"
m=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
b=json.loads((R/"scene_manifest_v5_baseline.json").read_text(encoding="utf8"))
assert len(m["instances"])==len(b["instances"])==48
assert len(m["ground_decor"])==len(b["ground_decor"])==43
assert all(o==p for o,p in zip(m["ground_decor"],b["ground_decor"]))
previous={o["id"]:o for o in b["instances"]}
changed=[o["id"] for o in m["instances"] if o!=previous[o["id"]]]
assert changed==["grove_tree_south"],("UNEXPECTED_OBJECT_CHANGES",changed)
ob=next(o for o in m["instances"] if o["id"]=="grove_tree_south")
assert (ob["asset_id"],ob["x"],ob["y"],ob["draw_order"],ob["dimensions"])==(
 "treehouse_grove_v6",361,142,334,[160,192])
assert ob["y"]+ob["dimensions"][1]==ob["draw_order"]
assert ob["upper_structure_level"]==1 and ob["level_adapter_state"]=="VISUAL_ONLY_NOT_PLAYABLE_ABOVE"
assert ob["collision_local"]==[[63,165,98,190]]
source_file=src/"treehouse_grove_v6.png"
ledger=json.loads((R/"input"/"V6_TREEHOUSE_LEDGER.json").read_text(encoding="utf8"))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(source_file)==ledger["source_sha256"]==ob["sha256"]
for path,h in ledger["parts"].items():assert sha(R/path)==h,("PART_PROVENANCE_MISMATCH",path)
for entry in m["instances"]+m["ground_decor"]:
 assert sha(src/(entry["asset_id"]+".png"))==entry["sha256"]
G=Image.open(R/"build"/"FS_ELF_RICH_Ground.png").convert("RGBA")
P=Image.open(R/"build"/"FS_ELF_RICH_Par_COMPLETE.png").convert("RGBA")
M=Image.open(R/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
C=Image.open(R/"build"/"FS_ELF_RICH_Collision.png").convert("L")
assert G.size==P.size==M.size==C.size==(864,640)
assert G.getchannel("A").getextrema()==(255,255)
reconstructed=G.copy();reconstructed.alpha_composite(P)
assert M.tobytes()==reconstructed.tobytes(),"GROUND_PAR_MASTER_DIFF"
assert G.tobytes()==Image.open(R/"baseline"/"v5_Ground.png").convert("RGBA").tobytes(),"GROUNDS_UNEXPECTEDLY_CHANGED"
OLD=Image.open(R/"baseline"/"v5_Master.png").convert("RGBA")
pixel_diff=sum(a!=b for a,b in zip(M.getdata(),OLD.getdata()))
assert pixel_diff>10000,pixel_diff
owner=Image.open(R/"outputs"/"PIXEL_OWNER_ID.png")
index=json.loads((R/"outputs"/"INSTANCE_ID_INDEX.json").read_text(encoding="utf8"))
idx=int(next(i for i,item in index.items() if item["id"]=="grove_tree_south"))
assert index[str(idx)]["draw_order"]==334
nav={}
def passable(tx,ty):
 if not 0<=tx<27 or not 0<=ty<20:return False
 wx,wy=tx*32+16,ty*32+16
 return all(C.getpixel((x,y))==0 for y in range(wy-8,wy+9) for x in range(wx-8,wx+9))
valid={(tx,ty) for ty in range(20) for tx in range(27) if passable(tx,ty)}
spawn=(m["spawn"]["x"]//32,m["spawn"]["y"]//32)
assert spawn in valid
q=deque([spawn]);nav[spawn]=None
while q:
 current=q.popleft()
 for n in ((current[0]+1,current[1]),(current[0]-1,current[1]),(current[0],current[1]+1),(current[0],current[1]-1)):
  if n in valid and n not in nav:nav[n]=current;q.append(n)
def path(t):
 assert t in nav,("UNREACHABLE",t)
 out=[]
 while t is not None:out.append(t);t=nav[t]
 return list(reversed(out))
probes={}
for name,(tx,ty) in (("BEHIND",(13,7)),("FRONT",(15,10))):
 assert (tx,ty) in nav
 foot=(ty+1)*32
 overlap=sum(owner.getpixel((x,y))==idx for y in range(max(0,foot-32),min(640,foot))
             for x in range(tx*32,tx*32+32))
 assert overlap>=20,(name,overlap)
 assert (foot<=334)==(name=="BEHIND")
 probes[name]={"tile":[tx,ty],"foot_y":foot,"owner_pixels_in_actor_bbox":overlap,
               "steps_from_spawn":len(path((tx,ty)))-1,"route":path((tx,ty))}
bad_local=[63,165,140,191]
x0=ob["x"]+bad_local[0];y0=ob["y"]+bad_local[1]
x1=ob["x"]+bad_local[2];y1=ob["y"]+bad_local[3]
tx,ty=15,10;cx,cy=tx*32+16,ty*32+16
wrong_collider_blocks_front=(x0<cx+8 and x1>cx-8 and y0<cy+8 and y1>cy-8)
assert wrong_collider_blocks_front and (15,10) in valid
NEG=R/"negative"/"V6_TEMP_SHIFT"
for dn in ("source/clean","source/terrain","scripts","build/semantic_masks","work"):
 (NEG/dn).mkdir(parents=True,exist_ok=True)
copytree(R/"source"/"clean",NEG/"source"/"clean",dirs_exist_ok=True)
copytree(R/"source"/"terrain",NEG/"source"/"terrain",dirs_exist_ok=True)
copy2(R/"scripts"/"compile_scene_v4.py",NEG/"scripts"/"compile_scene_v4.py")
mut=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
next(o for o in mut["instances"] if o["id"]=="grove_tree_south")["x"]+=1
(NEG/"scene_manifest.json").write_text(json.dumps(mut,ensure_ascii=False),encoding="utf8")
p=subprocess.run([sys.executable,str(NEG/"scripts"/"compile_scene_v4.py")],cwd=NEG,capture_output=True,text=True,timeout=60)
assert p.returncode==0,("NEGATIVE_COMPILE_CRASH",p.stderr)
shifted=Image.open(NEG/"build"/"FS_ELF_RICH_Master.png").convert("RGBA")
drift=sum(a!=b for a,b in zip(shifted.getdata(),M.getdata()))
assert drift>0
mut=json.loads((R/"scene_manifest.json").read_text(encoding="utf8"))
next(o for o in mut["instances"] if o["id"]=="grove_tree_south")["sha256"]="0"*64
(NEG/"scene_manifest.json").write_text(json.dumps(mut,ensure_ascii=False),encoding="utf8")
p2=subprocess.run([sys.executable,str(NEG/"scripts"/"compile_scene_v4.py")],cwd=NEG,capture_output=True,text=True,timeout=60)
assert p2.returncode!=0,"TAMPERED_SOURCE_SHA_NOT_REJECTED"
rmtree(NEG)
native=json.loads((R/"logs"/"V6_NATIVE_TREEHOUSE_AUDIT.json").read_text(encoding="utf8"))
assert native["status"]=="B1_V6_ISOLATED_NATIVE_TREEHOUSE_DEPTH_PASS_NOT_SEALED_FS"
assert len(native["automated_native_screen_audit"])==6
assert all(a["outside_actor_mismatches"]==0 and a["wrongly_overdrawn_occlusion_pixels"]==0
 for a in native["automated_native_screen_audit"].values())
report={
 "status":"V6_TREEHOUSE_SOURCE_NATIVE_LAYER_PASS_NOT_FORMAL",
 "treehouse_asset_sha256":ob["sha256"],"new_asset_shape":[160,192],
 "v5_to_v6_changed_rgba_pixels":pixel_diff,
 "source_manifest_objects":48,"ground_flora":43,
 "source_part_hashes_valid":len(ledger["parts"]),
 "ground_unchanged":True,"strict_rgba_master_diff":0,
 "owner_pixels":json.loads((R/"logs"/"OWNER_DEPTH_V3_REPORT.json").read_text(encoding="utf8"))["opaque_par_pixels"],
 "reachable_cells":len(nav),"possible_cells":len(valid),"legal_actor_probes":probes,
 "negative_treehouse_shift_1px_master_diff":drift,
 "negative_wrong_collider_detected":wrong_collider_blocks_front,
 "negative_wrong_asset_sha_rejected":True,
 "isolated_native_capture_probes":len(native["automated_native_screen_audit"]),
 "height1_climb":"NOT_IMPLEMENTED","sealed_fs":"NOT_TESTED",
 "visual_reference_approved":False,"human_gate_f":"NOT_RUN"}
(R/"logs"/"V6_TREEHOUSE_SOURCE_LAYER_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V6_SOURCE_LAYER_GATE_PASS",json.dumps({
 "changed_pixels":pixel_diff,"owner_pixels":report["owner_pixels"],"reachable":len(nav),
 "behind_steps":probes["BEHIND"]["steps_from_spawn"],
 "front_steps":probes["FRONT"]["steps_from_spawn"],
 "drift_1px":drift,"native_probes":6,"source_parts":len(ledger["parts"])
},ensure_ascii=False),flush=True)
