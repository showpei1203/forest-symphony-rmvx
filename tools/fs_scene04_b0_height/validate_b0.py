from pathlib import Path
from PIL import Image
from collections import deque
import hashlib,json,subprocess,xml.etree.ElementTree as ET,sys
r=Path(r"E:\GameAssetToolLab_20261023\FS_B0_SCENE04_HEIGHT_20261023")
m=json.loads((r/"SCENE_MANIFEST_B0.json").read_text(encoding="utf8"))
registry=json.loads((r/"SOURCE_REGISTRY.json").read_text(encoding="utf8"))["assets"]
b=r/"build";report={}
def ck(name,pass_,detail=None):report[name]={"pass":bool(pass_),"detail":detail}
checksums={k:hashlib.sha256((r/v["path"]).read_bytes()).hexdigest()==v["sha256"] for k,v in registry.items()}
ck("A_source_hash_all_10",all(checksums.values()),checksums)
names=["Ground","Par_COMPLETE","Par_BASE","Occlusion","Master"]
images={name:Image.open(b/("B0_"+name+".png")).convert("RGBA") for name in names}
ck("A_fixed_544x416",all(z.size==(544,416) for z in images.values()))
ck("A_true_alpha",images["Ground"].getchannel("A").getextrema()==(255,255) and images["Par_COMPLETE"].getchannel("A").getextrema()==(0,255))
master=images["Ground"].copy();master.alpha_composite(images["Par_COMPLETE"])
ck("B_origin_same",master.tobytes()==images["Master"].tobytes())
par=images["Par_BASE"].copy();par.alpha_composite(images["Occlusion"])
ck("C_base_occlusion_strict",par.tobytes()==images["Par_COMPLETE"].tobytes())
tiled=r.parent/"tools"/"Tiled"/"tmxrasterizer.exe"
tiled_file=b/"B0_TILED.png"
proc=subprocess.run([str(tiled),str(b/"B0_from_manifest.tmx"),str(tiled_file)],capture_output=True,text=True,errors="replace",timeout=35)
ck("C_tmxrasterizer_exit",proc.returncode==0,proc.stderr[-400:])
if proc.returncode==0:
 t=Image.open(tiled_file).convert("RGBA")
 diff=sum(a!=bb for a,bb in zip(t.getdata(),images["Master"].getdata()))
 ck("C_independent_tiled_RGBA_zero",diff==0,diff)
terrain=m["terrain"];width,height=17,13
stairedges={frozenset((tuple(edge["tile"]),tuple(edge["high_neighbor"]))) for edge in m["stairs"]}
def can_step(a,b,edges=stairedges):
 x,y=a;xx,yy=b
 if not (0<=x<width and 0<=xx<width and 0<=y<height and 0<=yy<height):return False
 if abs(x-xx)+abs(y-yy)!=1:return False
 ta,tb=terrain[y][x],terrain[yy][xx]
 if not ta["walkable"] or not tb["walkable"]:return False
 if ta["height"]==tb["height"]:return True
 return abs(ta["height"]-tb["height"])==1 and frozenset((a,b)) in edges
def route(start,target,edges=stairedges):
 stack=deque([(start,0)]);seen={start}
 while stack:
  pos,n=stack.popleft()
  if pos==target:return n
  for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
   p=(pos[0]+dx,pos[1]+dy)
   if p not in seen and can_step(pos,p,edges):seen.add(p);stack.append((p,n+1))
 return None
spawn=tuple(m["spawn"])
routes={k:route(spawn,tuple(v)) for k,v in m["targets"].items()}
ck("D_stair_connects_both_plateaus",all(v is not None for v in routes.values()),routes)
ck("D_cliff_crossing_illegal",not can_step((1,4),(1,5)) and not can_step((6,4),(7,4)) and not can_step((15,4),(16,4)))
ck("D_water_impassable",all(not can_step((x,10),(x,11)) for x in range(width)))
ck("D_stair_edge_only",can_step((5,4),(5,5)) and can_step((5,5),(5,4)) and can_step((12,4),(12,5)))
ck("NEG_stair_removal_detected",route(spawn,(5,4),{e for e in stairedges if frozenset(((5,5),(5,4)))!=e}) is None)
tmx=ET.parse(b/"B0_from_manifest.tmx")
sign=tmx.find('.//object[@name="sign_center"]')
assert sign is not None
sign.set("x",str(float(sign.get("x"))+1))
altered=b/"B0_TILED_1PX_MUTANT.tmx";tmx.write(altered,encoding="utf8",xml_declaration=True)
dst=b/"B0_TILED_1PX_MUTANT.png"
p=subprocess.run([str(tiled),str(altered),str(dst)],capture_output=True,text=True,errors="replace",timeout=35)
if p.returncode==0:
 mutant=Image.open(dst).convert("RGBA")
 mutation_diff=sum(a!=bb for a,bb in zip(mutant.getdata(),images["Master"].getdata()))
else:mutation_diff=0
ck("NEG_1PX_object_translation",mutation_diff>0,mutation_diff)
output={"status":"B0_SOURCE_LAYER_HEIGHT_SMOKE_PASS" if all(x["pass"] for x in report.values()) else "B0_FAIL_CLOSED",
 "metrics":{"canvas":[544,416],"source_assets":len(registry),"world_tiles":width*height,"objects":len(m["objects"]),
 "stairs":len(stairedges),"routes":routes,"mutated_pixels":mutation_diff},
 "gates":report,"not_tested":["B0 native Godot real GPU","B0 native VX Game.exe","sealed Forest Symphony runtime integration","human Gate F","reference-level visual fidelity"],
 "formal":"NOT_FORMAL_PASS"}
(r/"reports"/"B0_VALIDATION_V1.json").write_text(json.dumps(output,indent=2,ensure_ascii=False),encoding="utf8")
print(output["status"],"checks",sum(x["pass"] for x in report.values()),"/",len(report),"route lengths",routes,"negative mutated",mutation_diff)
if output["status"]!="B0_SOURCE_LAYER_HEIGHT_SMOKE_PASS":sys.exit(2)
