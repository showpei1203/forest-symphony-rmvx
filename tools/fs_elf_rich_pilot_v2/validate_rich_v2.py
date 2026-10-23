from pathlib import Path
from PIL import Image
import hashlib,subprocess,json,collections,sys
r=Path(r"E:\GameAssetToolLab_20261023\FS_ElfVillage_RichPilot_20261023")
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
w,h=m["canvas"]["width"],m["canvas"]["height"]
tool=r.parent/"tools"/"Tiled"/"tmxrasterizer.exe"
tmx=r/"work"/"FS_ELF_RICH_scene.tmx"
out=r/"build"/"FS_ELF_RICH_TILED.png"
ret=subprocess.run([str(tool),str(tmx),str(out)],capture_output=True,text=True,errors="replace",timeout=35)
checks={}
def ck(k,b,info=None):checks[k]={"pass":bool(b),"detail":info}
def load(x):return Image.open(r/"build"/("FS_ELF_RICH_"+x+".png")).convert("RGBA")
ims={key:load(key) for key in ["Ground","Par_COMPLETE","Par_BASE","Occlusion","Master","TILED"]}
src=r/"source"/"clean"
ck("A_dimensions",all(z.size==(w,h) for z in ims.values()))
ck("A_ground_opaque",ims["Ground"].getchannel("A").getextrema()==(255,255))
ck("A_par_true_alpha",ims["Par_COMPLETE"].getchannel("A").getextrema()==(0,255))
ck("A_integer_world",all(isinstance(a["x"],int) and isinstance(a["y"],int) for a in m["instances"]))
ck("B_asset_sha",all(hashlib.sha256((src/(o["asset_id"]+".png")).read_bytes()).hexdigest()==o["sha256"] for o in m["instances"]+m["ground_decor"]))
ck("B_distinct_houses",(src/"house_A.png").read_bytes()!=(src/"house_shop.png").read_bytes())
ck("B_counts",len(m["instances"])==48 and len(m["ground_decor"])==19 and len(m["interactions"])==5)
ck("C_tiled_exit",ret.returncode==0,ret.stderr[-160:])
ck("C_tiled_exact",ims["TILED"].tobytes()==ims["Master"].tobytes())
both=ims["Ground"].copy();both.alpha_composite(ims["Par_COMPLETE"])
ck("C_master_origin",both.tobytes()==ims["Master"].tobytes())
combined=ims["Ground"].copy()
combined.alpha_composite(ims["Par_BASE"])
combined.alpha_composite(ims["Occlusion"])
layer_diff=sum(a!=b for a,b in zip(combined.getdata(),ims["Master"].getdata()))
ck("D_base_occlusion_exact",layer_diff==0,layer_diff)
coll=Image.open(r/"build"/"FS_ELF_RICH_Collision.png").convert("L")
def clear(x,y,rad=8):
 if not (rad<=x<w-rad and rad<=y<h-rad):return False
 return all(coll.getpixel((px,py))==0 for py in range(y-rad,y+rad+1) for px in range(x-rad,x+rad+1))
spawn=m["spawn"]
ck("E_spawn_clear",clear(spawn["x"],spawn["y"]))
valid={(x,y) for y in range(h//32) for x in range(w//32) if clear(x*32+16,y*32+16)}
start=(spawn["x"]//32,spawn["y"]//32)
queue=collections.deque([start]);seen={start}
while queue:
 x,y=queue.popleft()
 for q in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  if q in valid and q not in seen:seen.add(q);queue.append(q)
reach={ev["id"]:any(abs(x*32+16-ev["x"])+abs(y*32+16-ev["y"])<=70 for x,y in seen) for ev in m["interactions"]}
ck("E_interactions_reachable",all(reach.values()),reach)
ck("E_world_navigable",len(seen)>120,len(seen))
report={"status":"PASS" if all(v["pass"] for v in checks.values()) else "FAIL_CLOSED","checks":checks,"failed":[k for k,v in checks.items() if not v["pass"]],"runtime":"NOT_RUN","formal":"NOT_APPROVED"}
(r/"logs"/"RICH_V2_GATES.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf8")
print("RICH_V2_GATES",report["status"],"passed",sum(v["pass"] for v in checks.values()),"of",len(checks),"fail",report["failed"],"recompose_diff",layer_diff,"reachable",reach)
if report["status"]!="PASS":sys.exit(2)
