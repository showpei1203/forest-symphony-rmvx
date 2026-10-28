#!/usr/bin/env python3
"""R11 1280x928 same-source SAM2 large village PAR EXPLORATORY pilot.
Source is existing official FS ground3; do NOT claim freshly generated art or complete occlusion coverage.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,torch,cv2,json,hashlib,time,os
R=Path(__file__).resolve().parent
D=R/"R11_VILLAGE_SIZE_TECH";D.mkdir(exist_ok=True)
SRC=Path("/mnt/e/GameAssetToolLab_20261023/FS_FORMAL_RUNTIME_B0_ISOLATED_20261024/clone_project/K4_BASELINE/Graphics/Parallaxes/ground3.png")
source=np.asarray(Image.open(SRC).convert("RGB"));H,W=source.shape[:2]
assert (W,H)==(1280,928)
# Positions manually inferred from visual preview. Must be reviewed at 1x before art acceptance.
registry=[
 {"id":"house_left_north","kind":"building","bbox":[88,92,430,332],"positive":[[245,185],[240,259]],"negative":[[419,334],[43,345]],"anchor":[262,305]},
 {"id":"house_central","kind":"building","bbox":[428,228,822,571],"positive":[[595,339],[617,475]],"negative":[[821,590],[410,572]],"anchor":[618,541]},
 {"id":"house_north_east","kind":"building","bbox":[825,0,1245,320],"positive":[[1018,130],[1040,223]],"negative":[[808,327],[1222,333]],"anchor":[1048,301]},
 {"id":"house_south","kind":"building","bbox":[462,615,908,902],"positive":[[672,718],[680,825]],"negative":[[917,902],[439,917]],"anchor":[685,870]},
 {"id":"tree_mid_right","kind":"tree","bbox":[725,300,990,620],"positive":[[854,423],[851,516]],"negative":[[978,626],[708,619]],"anchor":[851,580]}
]
torch.set_num_threads(min(8,os.cpu_count() or 8))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device="cpu")
predictor=SAM2ImagePredictor(model);start=time.time()
rgba=np.dstack([source,np.full((H,W),255,np.uint8)])
union=np.zeros((H,W),np.uint8);owner=np.zeros((H,W),np.uint8)
rows=[]
with torch.inference_mode():
 predictor.set_image(source)
 for i,o in enumerate(registry,1):
  pts=o["positive"]+o["negative"]
  loc=np.array(pts,np.float32)
  labels=np.array([1]*len(o["positive"])+[0]*len(o["negative"]),np.int32)
  ms,scores,_=predictor.predict(box=np.array(o["bbox"],np.float32),
   point_coords=loc,point_labels=labels,multimask_output=True)
  candidates=[]
  for j,(m,score) in enumerate(zip(ms,scores)):
   mask=np.asarray(m,bool)
   n,lab,stats,cents=cv2.connectedComponentsWithStats(mask.astype(np.uint8),8)
   compids={int(lab[y,x]) for x,y in o["positive"] if mask[y,x]};compids.discard(0)
   select=np.isin(lab,list(compids)) if compids else np.zeros_like(mask)
   missing=sum(not select[y,x] for x,y in o["positive"])
   neg=sum(select[y,x] for x,y in o["negative"])
   bx,by,br,bb=o["bbox"];allowed=np.zeros_like(mask)
   allowed[max(0,by-10):min(H,bb+10),max(0,bx-10):min(W,br+10)]=True
   outside=float((select&~allowed).sum())/max(int(select.sum()),1)
   rank=float(score)-.3*missing-.3*neg-.5*outside
   candidates.append((rank,j,float(score),select,missing,neg,outside))
  _,version,score,mask,miss,neg,outside=max(candidates,key=lambda a:a[0])
  prompt_pass=bool(miss==0 and neg==0 and outside<=.06 and mask.sum()>500)
  # PIL saves original master RGB where source pixels remain non-transparent; full object, no ground inpainting.
  obj=np.zeros((H,W,4),np.uint8);obj[mask,:3]=source[mask];obj[mask,3]=255
  Image.fromarray(obj,"RGBA").save(D/(o["id"]+"_SOURCE_PAR.png"))
  conflict=int(((union>0)&mask).sum())
  valid=mask & (owner==0)
  owner[valid]=i;union[valid]=255
  row={**o,"source_pixels":int(mask.sum()),"confidence":score,"negative_hits":neg,
   "missing_positives":miss,"outside_box10_ratio":round(outside,4),
   "prompt_consistency":prompt_pass,"premerge_source_pixel_conflicts":conflict,
   "artistic_shape_approved":False}
  rows.append(row)
  print("R11_SAM_LARGE",o["id"],"px",row["source_pixels"],"prompt",prompt_pass,"overlap",conflict,flush=True)
par=np.zeros((H,W,4),np.uint8);sel=union>0;par[sel,:3]=source[sel];par[sel,3]=255
Image.fromarray(par,"RGBA").save(D/"R11_GROUND3_5OBJECT_SOURCE_PAR_CANDIDATE.png")
preview=source.copy()
preview[sel]=(preview[sel].astype(np.float32)*.5+np.array([255,35,145])*.5).astype("uint8")
Image.fromarray(preview).save(D/"R11_GROUND3_SAM2_5OBJECT_OVERLAY_QA.png")
outline=Image.fromarray(source,"RGB");d=ImageDraw.Draw(outline)
for x in rows:
 d.rectangle(x["bbox"],outline=(255,25,140),width=3)
 fx,fy=x["anchor"];d.ellipse((fx-6,fy-6,fx+6,fy+6),fill=(255,255,255))
 d.text((x["bbox"][0],max(0,x["bbox"][1]-13)),x["id"],fill="white")
outline.save(D/"R11_GROUND3_GUIDED_BBOX_SEMANTIC_QA.png")
assert np.array_equal(par[sel,:3],source[sel,:3])
meta={"status":"R11_LARGE_ART_SOURCE_MASK_CANDIDATE_ONLY_NOT_FULL_PAR",
 "official_art_file":"K4/Graphics/Parallaxes/ground3.png",
 "source_generated_new_art":False,
 "dims_px":[W,H],
 "sam2_objects":len(registry),"prompt_consistent_count":sum(x["prompt_consistency"] for x in rows),
 "total_source_pixel_alpha_px":int(sel.sum()),"rgb_from_source_exact":True,
 "elapsed_seconds":round(time.time()-start,2),
 "all_scene_3D_occluders_extracted":False,"collision_compiled_for_this_PAR":False,
 "native_dynamic_occlusion_tested":False,"full_house_footprint_semantic_correct":False,
 "human_visual_gate_F":False,
 "note":"This masks five guided objects from an EXISTING map; not new village generation. Need the complete scene objects and user art approval.",
 "objects":rows}
(D/"R11_GROUND3_5OBJECT_SAM2_GATE.json").write_text(json.dumps(meta,ensure_ascii=False,indent=2,default=lambda v:int(v) if isinstance(v,np.integer) else float(v) if isinstance(v,np.floating) else str(v)),encoding="utf8")
print("R11_LARGE_MASK_GATE",json.dumps({k:meta[k] for k in ["dims_px","sam2_objects","prompt_consistent_count","total_source_pixel_alpha_px","elapsed_seconds"]}),flush=True)