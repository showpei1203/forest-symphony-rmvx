#!/usr/bin/env python3
"""R15 empirical failure tests: source-art richness vs whole-tile PAR overcapture and old tile repetition.
Ground is R12 visually rich Master. All user-facing categories are CANDIDATE; no hidden user acceptance.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,json,hashlib
R=Path(__file__).resolve().parent
A=R/"R12_NEW_ELF_VILLAGE_001";B=R/"R13_TILE_OCCLUSION_PAR_20261028";C=R/"R14_GODOT_LAYER_AUTHORING_20261028"
OUT=R/"R15_MULTISCALE_MASK_RESEARCH_20261028";OUT.mkdir(exist_ok=True)
src=np.asarray(Image.open(A/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png").convert("RGB"))
r12=np.asarray(Image.open(A/"PAR_R12_VX_SELECTED14_SOURCE_ONLY.png").convert("RGBA"))[:,:,3]>0
r13=np.asarray(Image.open(B/"PAR_R13_GRID_FIRST_SOURCE_CANDIDATE.png").convert("RGBA"))[:,:,3]>0
assert src.shape[:2]==r12.shape==r13.shape==(928,1280)
# Prior R12 scene blueprint semantic exclusions; candidate, not gold ground truth
original=json.loads((A/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text(encoding="utf8"))
exclusions=original["ground_stairs_bridge_exclusions"]
result=[]
all_mask=np.zeros(r13.shape,np.uint8)
for name,poly in exclusions:
 m=np.zeros_like(all_mask)
 cv2.fillPoly(m,[np.array(poly,np.int32)],1)
 sel=m>0
 n=int(sel.sum()); n12=int((sel&r12).sum());n13=int((sel&r13).sum())
 result.append({"id":name,"floor_semantics":"R12 explicitly ground-only candidate","pixels":n,
   "r12_PAR_overlap":n12,"r13_PAR_overlap":n13,
   "r13_PAR_overlap_pct":round(100*n13/max(1,n),2)})
 all_mask=np.maximum(all_mask,m)
all_floor=all_mask>0
r13_floor_count=int((r13&all_floor).sum())
r12_floor_count=int((r12&all_floor).sum())
# 14 R12 segmenter generated only 20% overlay; R13 overcovers 57.6%: neither is semantic completeness.
r12_total=int(r12.sum());r13_total=int(r13.sum())
# Visual R13 overcapture of known floor-only samples
viz=src.copy()
overlay=np.zeros_like(src,dtype=np.uint8)
overlay[r13]=[255,25,145]
viz=(src.astype(np.float32)*.7+overlay.astype(np.float32)*.3).astype("uint8")
viz[~r13]=src[~r13]
v=Image.fromarray(viz,"RGB");draw=ImageDraw.Draw(v)
for item,(name,poly) in zip(result,exclusions):
 pts=[tuple(x) for x in poly]
 draw.line(pts+[pts[0]],fill=(255,240,0),width=4)
 p=pts[0];draw.text((p[0]+5,p[1]+5),f"{name}: {item['r13_PAR_overlap_pct']}%",fill=(255,255,255))
v.save(OUT/"R15_R13_PAR_OVER_FLOOR_EXCLUSION_AUDIT.png")
# Tile repetition test: reuse of 2 32x32 ground assets over 221 cells vs unique rich master
scene=json.loads((C/"SCENE_LAYER_MANIFEST.json").read_text(encoding="utf8"))
floors=[x for x in scene["objects"] if x["asset"] in ("grass","path")]
assets=set(x["asset"] for x in floors)
assert len(floors)==221 and len(assets)==2
report={
 "status":"R15_FAILURE_PROFILING_COMPLETE_NOT_NEW_PAR_ART_PASS",
 "source_master_px":[1280,928],
 "R12_PAR_alpha_px":r12_total,"R13_PAR_alpha_px":r13_total,
 "R12_PAR_coverage_of_canvas_pct":round(100*r12_total/src.shape[0]/src.shape[1],2),
 "R13_PAR_coverage_of_canvas_pct":round(100*r13_total/src.shape[0]/src.shape[1],2),
 "known_ground_exclusion_semantic_polygons_count":len(exclusions),
 "R12_alpha_overlap_with_ground_exclusions_px":r12_floor_count,
 "R13_alpha_overlap_with_ground_exclusions_px":r13_floor_count,
 "R13_floor_exclusions_total_pixels":int(all_floor.sum()),
 "ground_semantics":"Based on unapproved R12 authored collision manifest, not user-gold. A hit indicates conflict against the project's own prior ground-only labels.",
 "exclusions":result,
 "Godot_R14_floor_tile_total_nodes":len(floors),
 "Godot_R14_floor_unique_tile_graphic_count":len(assets),
 "Godot_R14_floor_unique_tile_assets":sorted(assets),
 "conclusion":"R13 whole-tile rescue introduces false-positive PAR over ground while R14 repetition is structurally unavoidable with two 32px source tiles, neither meets dual gate.",
 "recommendation":"Master-first beauty; dedicated new-layer decomposition proposal via QwenImageLayered+SAM3, high-resolution ROI SAM2 presently available; only use predicted alpha over exact immutable master RGB, no 32x32 blanket PAR, art human review.",
 "both_formal_FS_and_R12_R13_R14_unmodified":True
}
(OUT/"R15_R12_R13_R14_FAILURE_DIAGNOSTICS.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R15_FAILURES",json.dumps({k:report[k] for k in ("R12_PAR_alpha_px","R13_PAR_alpha_px","R13_alpha_overlap_with_ground_exclusions_px","Godot_R14_floor_tile_total_nodes","Godot_R14_floor_unique_tile_graphic_count")},ensure_ascii=False),flush=True)