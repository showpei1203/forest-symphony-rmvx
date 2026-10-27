#!/usr/bin/env python3
"""R7 object-grid actor spatial QA: detects foreground overdraw and incomplete static-depth.
17x13 restricted scene; R5 Map001 mock passability, NOT actual original MapXX authority.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np,hashlib,collections
R=Path(__file__).resolve().parent;ROOT=R/"R7_SEMANTIC_MASK_CANDIDATES"
d=json.loads((ROOT/"R7_SAM2_PROMPT_REGISTRY_GATE.json").read_text())
master=np.asarray(Image.open(R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png").convert("RGBA"))
H,W=master.shape[:2];assert (W,H)==(544,416)
owner=np.asarray(Image.open(ROOT/"R7_OBJECT_PIXEL_OWNER.png"))
masks=[]
for i,o in enumerate(d["objects"],1):
 rgba=np.asarray(Image.open(ROOT/(o["id"]+"_PAR_OCCLUSION_CANDIDATE.png")).convert("RGBA"))
 mask=rgba[:,:,3]>0
 # Confirm source-derived per pixel AND zero alpha where not masked.
 assert np.array_equal(rgba[mask,:3],master[mask,:3]),o["id"]
 assert rgba[~mask,3].max(initial=0)==0
 masks.append({"id":o["id"],"foot_y":o["foot"][1],"mask":mask,"kind":o["kind"],"prompt":o["prompt_consistency"]})
assert owner.max()<=len(masks)
union=owner>0
finalpar=np.asarray(Image.open(ROOT/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png").convert("RGBA"))
assert np.array_equal(finalpar[union,:3],master[union,:3])
assert np.all(finalpar[~union,3]==0)
# Check map used for *isolated* R5 passability only; exported by Windows Python rubymarshal.
third=np.asarray(json.loads((ROOT/"R5_ISOLATED_MAP001_THIRD_LAYER_17x13.json").read_text())["ids"])
assert third.shape==(13,17)
assert all(third[y,x]==768 for x,y in [(5,6),(10,7),(14,8)])
# 768=no move, 769=move, directions TBD. No fake claim actual formal maps.
walk=(third==769)
# union is source-semantics, no independent subjective proof.
charfile=Path("/mnt/e/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Characters/$001.png")
chars=np.asarray(Image.open(charfile).convert("RGBA"))
assert chars.shape==(128,96,4)
poses=[chars[i*32:(i+1)*32,32:64,3]>0 for i in range(4)]
# Compare actor with source PAR pixel candidates; risk if player foot is in front of object but still covered.
tile_proposals=np.zeros_like(union)
for iy in range(13):
 for ix in range(17):
  raw=union[iy*32:(iy+1)*32,ix*32:(ix+1)*32]
  if raw.any():tile_proposals[iy*32:(iy+1)*32,ix*32:(ix+1)*32]=True
false_area=int((tile_proposals&~union).sum())
risk=[]
object_risk=collections.defaultdict(list)
for iy in range(13):
 for ix in range(17):
  if not walk[iy,ix]:continue
  origin_x=ix*32;origin_y=iy*32
  foot_y=origin_y+32
  local=union[origin_y:origin_y+32,origin_x:origin_x+32]
  over=tile_proposals[origin_y:origin_y+32,origin_x:origin_x+32]&~local
  for di,pose in enumerate(poses):
   # 32px x32px FS actor; each direction has independent alpha.
   unwanted_opaque=int((pose&over).sum())
   semantic_behind={}
   for ob in masks:
    if foot_y<=ob["foot_y"]:continue
    covered=int((ob["mask"][origin_y:origin_y+32,origin_x:origin_x+32] & pose).sum())
    if covered:
     semantic_behind[ob["id"]]=covered
     object_risk[ob["id"]].append({"cell":[ix,iy],"direction":di,"covered_px":covered})
   risk.append({"tile":[ix,iy],"direction":di,"foot_y":foot_y,
                "full_32px_non_object_occlusion":unwanted_opaque,
                "static_depth_conflict_by_object":semantic_behind})
fulltile_risk=sum(z["full_32px_non_object_occlusion"]>0 for z in risk)
depth_risk=sum(bool(z["static_depth_conflict_by_object"]) for z in risk)
unique_depth=sorted(set(tuple(z["tile"]) for z in risk if z["static_depth_conflict_by_object"]))
# 12-object mask overlap audit: overlap does not violate compositing if resolved but is not perfect isolated owner
overlap_total=np.zeros((H,W),np.uint8)
for ob in masks:overlap_total+=ob["mask"].astype(np.uint8)
overlap_conflict=int((overlap_total>1).sum())
heat=Image.fromarray(master.copy(),"RGBA")
draw=ImageDraw.Draw(heat,"RGBA")
bycell={}
for z in risk:
 key=tuple(z["tile"])
 o=bycell.setdefault(key,{"over":0,"depth":0})
 o["over"]=max(o["over"],z["full_32px_non_object_occlusion"])
 o["depth"]=max(o["depth"],max(z["static_depth_conflict_by_object"].values(),default=0))
for (ix,iy),v in bycell.items():
 bbox=(ix*32+1,iy*32+1,ix*32+30,iy*32+30)
 if v["depth"]>0:draw.rectangle(bbox,outline=(255,50,60,255),width=2)
 elif v["over"]>0:draw.rectangle(bbox,outline=(255,180,50,200),width=1)
heat.save(ROOT/"R7_4DIRECTION_DEPTH_AND_32PX_OVERDRAW_HEATMAP.png")
report={
 "status":"R7_SOURCE_ALIGNED_PAR_AND_GRID_TECH_PASS_ART_NOT_APPROVED",
 "master_unchanged":True,"source_mask_exact_pixel_rgb":True,
 "candidate_objects":len(masks),"full_32px_tile_pixels":int(tile_proposals.sum()),"candidate_union_px":int(union.sum()),
 "fulltile_extra_nonsemantic_pixels":false_area,
 "fulltile_extra_fraction":round(false_area/max(1,int(tile_proposals.sum())),5),
 "object_alpha_overlap_px":overlap_conflict,
 "r5_isolated_30x25_third_layer_crop_17x13_used":True,
 "original_51_formal_maps_not_used_for_these_coordinates":True,
 "walkable_tiles_in_isolated_map":int(walk.sum()),
 "four_directions_per_tile":4,"actor_footprints_scanned":len(risk),
 "directional_tile_hard_overdraw_risks":fulltile_risk,
 "directional_tile_static_depth_conflicts":depth_risk,
 "unique_depth_conflict_cells":unique_depth,
 "risk_by_object":{k:{"num_directional_tile_cases":len(v),"max_overlaid_actor_px":max(q["covered_px"] for q in v),
                      "examples":sorted(v,key=lambda q:-q["covered_px"])[:25]} for k,v in object_risk.items()},
 "input_mask_prompt_consistency_not_semantic_proof":True,
 "ground_touched":False,"visual_gate_F":False,
 "fail_closed_notes":["Object prompt acceptance not independent segmentation accuracy proof",
                      "Depth anchor approximated from current scene, visual inspection required",
                      "R5 Map001 cropped fake test collision (3 blockers), not actual original FS 17x13 passability",
                      "Entire object/foreground completeness NOT checked",
                      "Static full 32 tile vs selective source PAR overdraw compared using actor 4-direction pose masks"]
}
(ROOT/"R7_4DIR_OCCLUSION_GRID_AUDIT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R7_4DIR_RESULT",json.dumps({k:report[k] for k in ["walkable_tiles_in_isolated_map","actor_footprints_scanned","candidate_union_px","fulltile_extra_nonsemantic_pixels","object_alpha_overlap_px","directional_tile_hard_overdraw_risks","directional_tile_static_depth_conflicts","unique_depth_conflict_cells"]}),flush=True)