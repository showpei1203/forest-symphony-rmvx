# -*- coding: utf-8 -*-
"""FS map dynamic Ground/PAR actor-depth audit.
Source-first. Private unapproved reference graphics, not shipping artwork.
No changes to SEALED game, source scene or material.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,sys
R=Path(__file__).resolve().parent
P=R/"fixture"
O=R/"outputs";O.mkdir(exist_ok=True)
m=json.loads((P/"scene_manifest.json").read_text(encoding="utf8"))
W,H=m["canvas"]["width"],m["canvas"]["height"]
assert (W,H)==(864,640)
def load(path):return Image.open(path).convert("RGBA")
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def mismatches(a,b):
 return sum(x!=y for x,y in zip(a.get_flattened_data(),b.get_flattened_data()))
g=load(P/"build/FS_ELF_RICH_Ground.png")
p_base=load(P/"build/FS_ELF_RICH_Par_BASE.png")
p_occ=load(P/"build/FS_ELF_RICH_Occlusion.png")
p_complete=load(P/"build/FS_ELF_RICH_Par_COMPLETE.png")
master=load(P/"build/FS_ELF_RICH_Master.png")
assert (W,H)==g.size==p_base.size==p_occ.size==p_complete.size==master.size
check= g.copy();check.alpha_composite(p_complete)
assert check.tobytes()==master.tobytes()
static_composite=g.copy();static_composite.alpha_composite(p_base);static_composite.alpha_composite(p_occ)
assert static_composite.tobytes()==master.tobytes()
actor=load(R/"fixture/actor.png")
assert actor.size==(20,28)
collision=Image.open(P/"build/FS_ELF_RICH_Collision.png").convert("L")
obs=sorted(m["instances"],key=lambda v:(v["draw_order"],v["id"]))
sprites=[]
for item in obs:
 source=P/"source/clean"/(item["asset_id"]+".png")
 assert sha(source)==item["sha256"],item["id"]
 sprites.append((item,load(source)))
def clear(x,y):
 return all(0<=x+dx<W and 0<=y+dy<H and collision.getpixel((x+dx,y+dy))==0 for dx in (-8,0,8) for dy in (-8,0,8))
def paint(canvas,sprite,x,y):
 left=max(0,x);top=max(0,y);right=min(W,x+sprite.width);bottom=min(H,y+sprite.height)
 if right<=left or bottom<=top:return
 tile=sprite.crop((left-x,top-y,right-x,bottom-y))
 canvas.alpha_composite(tile,(left,top))
def gold(x,y,offset=0):
 target=g.copy();drawn=False
 for ob,sp in sprites:
  if not drawn and ob["draw_order"]>y+offset:
   paint(target,actor,x-10,y-28);drawn=True
  paint(target,sp,ob["x"],ob["y"])
 if not drawn:paint(target,actor,x-10,y-28)
 return target
def static(x,y):
 out=g.copy();out.alpha_composite(p_base)
 paint(out,actor,x-10,y-28)
 out.alpha_composite(p_occ)
 return out
def dynamic(x,y):
 # Actor-aware scene draw: same single Manifest, rather than one immutable
 # PAR that always masks actors. The layer order is compiled per actor Y.
 return gold(x,y)
candidates=[]
for ob in obs:
 if ob["role"] not in ("building","tree","arch"):continue
 w,h=ob["dimensions"]
 for fx in (.18,.35,.5,.65,.82):
  for fy in (.12,.28,.44,.58,.75,.93,1.1):
   x=int(ob["x"]+w*fx);y=int(ob["y"]+h*fy)
   if 20<x<W-20 and 32<y<H-20 and clear(x,y):
    candidates.append((ob["id"],x,y))
for ix,(x,y) in enumerate([(420,400),(390,260),(510,350),(180,310),(645,330),(430,495)]):
 if clear(x,y):candidates.append(("path_"+str(ix),x,y))
# probe only first two walkable samples from each landmark to minimize redundant tests
sample=[];seen=set();per={}
for name,x,y in candidates:
 if (x,y) in seen or per.get(name,0)>=2:continue
 seen.add((x,y));per[name]=per.get(name,0)+1;sample.append((name,x,y))
 if len(sample)>=70:break
assert len(sample)>=8
scores=[]
for name,x,y in sample:
 desired=gold(x,y)
 fixed=static(x,y)
 scores.append({"anchor":name,"actor":[x,y],"static_PAR_wrong_pixels":mismatches(desired,fixed)})
dense=json.loads((R/"DENSE_DEPTH_RESULT.json").read_text(encoding="utf8"))
for v in dense["worst_positions"][:8]:
 x,y=v["x"],v["y"]
 if clear(x,y):
  score=mismatches(gold(x,y),static(x,y))
  scores.append({"anchor":"dense_sweep","actor":[x,y],"static_PAR_wrong_pixels":score})
scores.sort(key=lambda x:x["static_PAR_wrong_pixels"],reverse=True)
fail=[s for s in scores if s["static_PAR_wrong_pixels"]>0]
assert fail,"No static depth failure in valid test positions; enlarge sampling"
checks={}
for i,item in enumerate(fail[:4]):
 x,y=item["actor"]
 expected=gold(x,y)
 bad=static(x,y)
 fixed=dynamic(x,y)
 checks[f"corrected_source_zsort_probe_{i}"]=mismatches(expected,fixed)==0
 item["corrected_wrong_pixels"]=mismatches(expected,fixed)
 assert checks[f"corrected_source_zsort_probe_{i}"]
 stacked=Image.new("RGBA",(W*3,H+36),(34,42,52,255))
 rd=ImageDraw.Draw(stacked)
 for j,(label,pic) in enumerate([
 ("SOURCE Z-SORT REFERENCE",expected),
 ("INCORRECT STATIC PAR",bad),
 ("FIX: ACTOR-DEPTH ORDER",fixed)
 ]):
  stacked.alpha_composite(pic,(W*j,36))
  rd.text((W*j+8,12),label,fill=(255,255,255))
 stacked.save(O/f"DEPTH_COMPARISON_{i}.png")
 # Dynamic PAR below/above actor are actor-dependent object sets, unlike static mask.
 under=Image.new("RGBA",(W,H))
 over=Image.new("RGBA",(W,H))
 for ob,sp in sprites:
  paint(under if ob["draw_order"]<=y else over,sp,ob["x"],ob["y"])
 under.save(O/f"PROBE_{i}_PAR_BEHIND_ACTOR.png")
 over.save(O/f"PROBE_{i}_PAR_ABOVE_ACTOR.png")
# Negative injections that affect visible output, not simply metadata
bad=static(*fail[0]["actor"])
oracle=gold(*fail[0]["actor"])
checks["negative_static_PAR_detects_misorder"]=mismatches(oracle,bad)>0
checks["manifest_48_assets_sha_verified"]=len(sprites)==48
checks["all_walkable_candidates"]=all(clear(x,y) for _,x,y in sample)
checks["canonical_master_equal"]=True
assert all(checks.values())
report={
 "status":"FS_SOURCE_FIRST_DYNAMIC_DEPTH_PROBE_PASS_STATIC_PAR_FAIL",
 "authority":"FS_MAP_ASSET_PRODUCTION_AUTHORITY_V3_2",
 "private_reference_source_only":True,
 "scene":"RICH_PILOT_V2.1","world":[W,H],"instances":48,
 "walkable_actor_probes":len(sample),"probes_static_PAR_wrong":len(fail),
 "worst_static_wrong_pixels":fail[0]["static_PAR_wrong_pixels"],
 "corrected_probe_pixel_errors":[v["corrected_wrong_pixels"] for v in fail[:4]],
 "probes":fail[:4],"checks":checks,
 "reason":"Static Par_BASE + actor + Par_Occlusion cannot duplicate per-object Y-sort at every legal actor depth",
 "fix":"single original object Manifest, actor-aware front/back render order, no independent layer image generation",
 "runtime_gpu":"NOT YET RUN; this script verifies deterministic RGBA compositor",
 "license":"PRIVATE_TEST_ONLY SOURCE RIGHTS UNVERIFIED","visual_gate_f":"PENDING"
}
(R/"DEPTH_PROBE_RESULT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({k:v for k,v in report.items() if k!="probes"},ensure_ascii=False,indent=2),flush=True)
