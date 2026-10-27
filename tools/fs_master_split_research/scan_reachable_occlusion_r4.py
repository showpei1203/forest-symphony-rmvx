#!/usr/bin/env python3
"""R4 coverage: 32x32 actor footprints over test-only reachable grid and SOURCE PAR mask. Non-production passability."""
from pathlib import Path
from PIL import Image,ImageDraw
from collections import defaultdict
import numpy as np,json
root=Path(__file__).resolve().parent;src=root/"SCENE21_GUIDED_SAM2_CANDIDATE"
out=root/"R4_WALKABLE_GRID_OCCLUSION_SCAN";out.mkdir(exist_ok=True)
master=np.asarray(Image.open(src/"MASTER_RGBA.png").convert("RGBA"))
H,W=master.shape[:2];tile=32;X,Y=W//tile,H//tile;assert (X,Y)==(17,13)
obj=[{"id":"house","mask":"house_SAM2_RAW.png","cutoff":196,"foot":214},
     {"id":"left_tree","mask":"left_tree_SAM2_RAW.png","cutoff":187,"foot":190},
     {"id":"right_tree","mask":"right_tree_prompt_v2_variant1.png","cutoff":217,"foot":237}]
masks={}
for o in obj:
 m=np.asarray(Image.open(src/o["mask"]).convert("L"))>=128
 m[o["cutoff"]:,:]=False
 masks[o["id"]]=m
allmask=np.logical_or.reduce(list(masks.values()))
# Actual small TEST ONLY blocked list from isolated source, not authoritative FS map.
blocked={(5,6),(10,7),(14,8)}
actor_sheet=Image.open("/mnt/e/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Characters/$001.png").convert("RGBA")
assert actor_sheet.size==(96,128),actor_sheet.size
poses=[]
for direction in range(4):
 # VX 4 dir: down,left,right,up, column=1 (rest)
 a=np.asarray(actor_sheet.crop((32,direction*32,64,direction*32+32)))
 poses.append(a[:,:,3]>0)
results=[];risky=defaultdict(list)
for ty in range(Y):
 for tx in range(X):
  if (tx,ty) in blocked:continue
  fx=tx*32+16;fy=(ty+1)*32
  ax=fx-16;ay=fy-32
  score={}
  for name,m in masks.items():
   foot=next(ob["foot"] for ob in obj if ob["id"]==name)
   if fy<=foot:continue # object z above actor when actor standing behind -> intentional cover
   actor_overlap=[]
   for pi,pose in enumerate(poses):
    layer=m[ay:ay+32,ax:ax+32]
    assert layer.shape==(32,32)
    actor_overlap.append(int((layer&pose).sum()))
   if max(actor_overlap)>0:
    score[name]=actor_overlap
    risky[name].append((tx,ty,max(actor_overlap)))
  full_by_mask=np.zeros((32,32),dtype=bool)
  # Source candidate full 32px tile selection from prior R1, compare opaque tile false positives
  r1=np.asarray(Image.open(root/"OCCLUSION_GRID_R1_20261027"/"PAR_32PIXEL_FULL_TILE_OVERDRAW.png").convert("RGBA"))[:,:,3]>0
  full_by_mask=r1[ay:ay+32,ax:ax+32]
  overdraw=int((full_by_mask & ~allmask[ay:ay+32,ax:ax+32] & poses[0]).sum())
  results.append({"tile":[tx,ty],"actor_foot":[fx,fy],"static_fg_overrides_needed":score,
                  "overdraw_nonobject_actor_px_down_pose":overdraw})
heat=Image.fromarray(master,"RGBA").copy()
draw=ImageDraw.Draw(heat,"RGBA")
for rec in results:
 v=max([max(k) for k in rec["static_fg_overrides_needed"].values()],default=0)
 x,y=rec["tile"];xy=(x*32+1,y*32+1,x*32+30,y*32+30)
 if v>0:draw.rectangle(xy,fill=(236,50,50,min(170,60+v)),outline=(255,230,70,230),width=1)
 elif rec["overdraw_nonobject_actor_px_down_pose"]>0:
  draw.rectangle(xy,fill=(255,165,0,55),outline=(250,175,0,210),width=1)
draw.rectangle((0,0,W-1,H-1),outline=(40,215,250,255),width=1)
heat.save(out/"R4_17x13_OCCLUSION_RISK_HEATMAP.png")
overview={
 "status":"TEST_ONLY_GRID_CANDIDATE_NOT_FS_PASSPASSA_AUTHORITY",
 "original_scene_size":[W,H],
 "actor_sprite":"FS $001.png, 4 directions, 32x32 poses",
 "test_only_blocked":[list(v) for v in sorted(blocked)],
 "assumed_walkable_cells":len(results),"official_para_passa_runtime_verified":False,
 "cells_where_static_PAR_wrong_for_front_actor":sum(bool(v["static_fg_overrides_needed"]) for v in results),
 "cells_fulltile_overdraw_nonobject_actor":sum(v["overdraw_nonobject_actor_px_down_pose"]>0 for v in results),
 "by_object":{name:{"at_risk_cells":len(q),"max_character_covered_px":max((z[2] for z in q),default=0),
                     "positions_sorted_by_covered_px":sorted([list(z) for z in q],key=lambda x:-x[2])[:35]}
              for name,q in risky.items()},
 "gate":"RESEARCH_ONLY","human_visual_gate":False,
 "all_walkable":{"count":len(results),"covered_cells":results},
 "notes":"R3 source masks incomplete/uncertified. A hit means the static z=900 overlay covers actor pixels even when actor foot is in front of object's foot, so requires collision or per-object y-sort."
}
(out/"R4_17x13_REACHABILITY_CANDIDATE.json").write_text(json.dumps(overview,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({k:overview[k] for k in ["status","assumed_walkable_cells","cells_where_static_PAR_wrong_for_front_actor","cells_fulltile_overdraw_nonobject_actor","by_object"]},ensure_ascii=False)[:5500],flush=True)