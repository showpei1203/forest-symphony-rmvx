#!/usr/bin/env python3
"""Scan each user-required object against 4 real FS directions and isolated test passability.
No art semantics pass inferred; behind/front overlap is diagnostic only.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json
R=Path(__file__).resolve().parent;D=R/"R8_USER_ANNOTATION_20261028"
auth=json.loads((D/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
Sam=json.loads((D/"R8_SAM2_USER_ANNOTATION_RESULT.json").read_text(encoding="utf8"))
tiles=np.asarray(json.loads((R/"R7_SEMANTIC_MASK_CANDIDATES"/"R5_ISOLATED_MAP001_THIRD_LAYER_17x13.json").read_text())["ids"])
assert tiles.shape==(13,17)
character=np.asarray(Image.open("/mnt/e/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Characters/$001.png").convert("RGBA"))
assert character.shape==(128,96,4)
poses=[character[32*i:32*i+32,32:64,3]>0 for i in range(4)]
master=Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA")
picture=master.copy()
draw=ImageDraw.Draw(picture)
results=[]
for o in auth["user_red"]:
 a=np.asarray(Image.open(D/(o["id"]+"_"+o["name"]+"_SAM2_SOURCE_PAR.png")).convert("RGBA"))
 mask=a[:,:,3]>0
 contact_y=o["foot"][1]
 behind=[];front=[];all_cases=0
 for ty in range(13):
  for tx in range(17):
   if tiles[ty,tx]!=769:continue
   area=mask[ty*32:(ty+1)*32,tx*32:(tx+1)*32]
   for di,actor in enumerate(poses):
    overlap=int((area&actor).sum())
    if overlap<=0:continue
    record={"tile":[tx,ty],"actor_foot":(ty+1)*32,"direction_index":di,"actor_masked_pixels":overlap}
    if (ty+1)*32<=contact_y:behind.append(record)
    else:front.append(record)
    all_cases+=1
 behind.sort(key=lambda x:-x["actor_masked_pixels"]);front.sort(key=lambda x:-x["actor_masked_pixels"])
 out={"id":o["id"],"kind":o["kind"],"contact_y":contact_y,
      "mask_px":int(mask.sum()),"test_isolated_walkable_directions_with_overlap":all_cases,
      "behind_depth_overlap_cases":len(behind),"front_depth_overlap_cases":len(front),
      "best_behind":behind[:3],"best_front":front[:3],
      "source_semantic_accepted_by_human":False,
      "note":"The test 769 walkability map is isolated artificial; real FS map collisions NOT verified"}
 results.append(out)
 # mark strongest front/behind candidates only for debug
 for candidates,color in [(behind,(40,180,245,255)),(front,(255,205,20,255))]:
  if candidates:
   x,y=candidates[0]["tile"]
   draw.rectangle((x*32+2,y*32+2,x*32+29,y*32+29),outline=color,width=2)
 draw.text((max(0,o["box"][0]-3),max(0,o["box"][1]-12)),o["id"],fill=(250,50,85,255))
picture.save(D/"R8_ALL_RED_ACTOR_4DIRECTION_SPATIAL_PROBE_MAP.png")
res={"status":"R8_8_RED_OBJECTS_4DIRECTION_GRID_DIAGNOSTIC",
     "real_character_sprite":"K4 $001.png 32x32 four poses",
     "original_formal_map_passability_used":False,"r5_isolated_walkable_tile_count":int((tiles==769).sum()),
     "object_count":len(results),"objects_with_any_behind_overlap":sum(bool(x["best_behind"]) for x in results),
     "objects_with_any_front_overlap":sum(bool(x["best_front"]) for x in results),
     "total_actor_mask_overlap_directions":sum(x["test_isolated_walkable_directions_with_overlap"] for x in results),
     "results":results,"gate_f":"HOLD"}
(D/"R8_4DIR_FOOTPRINT_AUDIT.json").write_text(json.dumps(res,ensure_ascii=False,indent=2),encoding="utf8")
print("R8_SPATIAL",json.dumps({x["id"]:{"behind":len(x["best_behind"]),"front":len(x["best_front"]),"max_front_px":x["best_front"][0]["actor_masked_pixels"] if x["best_front"] else 0} for x in results}),flush=True)