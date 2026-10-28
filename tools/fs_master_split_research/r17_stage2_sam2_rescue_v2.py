#!/usr/bin/env python3
"""R17 Stage2 R2 full-scene semantic inventory expansion from NEW 544x416 generated Master.
Add 6 small objects via SAM2 source locked, refine a failed narrow railing via GrabCut.
Uncertain shapes remain ART HOLD. No whole tile Alpha.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,os,time
import torch,numpy as np,cv2
R=Path(__file__).resolve().parent;D=R/"R17_STAGE2_NEW_ART_20261029"
source=D/"MASTER_STAGE2_NEW_GENERATED.png"
src=np.asarray(Image.open(source).convert("RGB")).copy();H,W=src.shape[:2];assert (W,H)==(544,416)
torch.set_num_threads(min(6,os.cpu_count() or 6))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
pred=SAM2ImagePredictor(build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml",
"checkpoints/sam2.1_hiera_small.pt",device="cpu"))
newcases=[
{"id":"TREE_MIDDLE_GARDEN","category":"tree","bbox":[296,59,406,208],
"pos":[[350,86],[355,114],[365,143],[365,166]],
"neg":[[303,69],[409,113],[312,215],[394,207],[295,174]],
"foot":[367,188]},
{"id":"LAMP_WEST","category":"lamp","bbox":[84,217,136,319],
"pos":[[103,242],[106,259],[106,285]],
"neg":[[87,234],[135,288],[119,318],[90,315]],
"foot":[106,302]},
{"id":"MARKET_STALL","category":"stall","bbox":[253,159,356,268],
"pos":[[290,189],[326,203],[302,224],[319,244]],
"neg":[[261,273],[354,274],[258,162],[356,172],[253,234]],
"foot":[315,260]},
{"id":"FENCE_LEFT_STEPS","category":"railing","bbox":[85,266,182,370],
"pos":[[110,291],[125,310],[146,323],[166,345]],
"neg":[[89,311],[180,367],[98,366],[166,272],[173,300]],
"foot":[146,345]},
{"id":"FENCE_NORTH_EAST","category":"railing","bbox":[463,92,541,153],
"pos":[[488,116],[509,122],[529,133]],
"neg":[[463,91],[541,93],[493,156],[471,142]],
"foot":[514,140]},
{"id":"FENCE_SOUTH_EAST","category":"railing","bbox":[462,335,542,393],
"pos":[[486,352],[502,365],[525,362]],
"neg":[[463,389],[540,391],[469,340],[534,339]],
"foot":[508,377]}
]
old=json.loads((D/"R17_STAGE2_NEW_ART_SAM2_GATE.json").read_text(encoding="utf8"))
oldmask=np.asarray(Image.open(D/"R17_STAGE2_PAR_5OBJECT_SOURCE_CANDIDATE.png").convert("RGBA"))[:,:,3]>0
meta=old["candidate_objects"]
records=[]
with torch.inference_mode():
 pred.set_image(src)
 for o in newcases:
  pts=np.asarray(o["pos"]+o["neg"],np.float32)
  labs=np.asarray([1]*len(o["pos"])+[0]*len(o["neg"]),np.int32)
  masks,scores,_=pred.predict(point_coords=pts,point_labels=labs,
                         box=np.asarray(o["bbox"],np.float32),multimask_output=True)
  variants=[]
  for variant,(m,score) in enumerate(zip(masks,scores)):
   m=m.astype(bool)
   n,l,st,cent=cv2.connectedComponentsWithStats(m.astype(np.uint8),8)
   keep={int(l[y,x]) for x,y in o["pos"] if m[y,x]};keep.discard(0)
   mask=np.isin(l,list(keep)) if keep else np.zeros_like(m,dtype=bool)
   x0,y0,x1,y1=o["bbox"]
   area=np.zeros_like(mask)
   area[max(0,y0-4):min(H,y1+5),max(0,x0-4):min(W,x1+5)]=True
   mask &= area
   missed=int(sum(not bool(mask[y,x]) for x,y in o["pos"]))
   wrong=int(sum(bool(mask[y,x]) for x,y in o["neg"]))
   metric=float(score)-.6*missed-.5*wrong
   variants.append((metric,mask,float(score),variant,missed,wrong))
  _,selected,confidence,variant,missed,wrong=max(variants,key=lambda x:x[0])
  root=None
  if o["category"]=="tree":
   fx,fy=o["foot"];rx=fx//32;ry=fy//32
   selected[ry*32:min(H,(ry+1)*32),rx*32:min(W,(rx+1)*32)]=False
   root=[int(rx),int(ry)]
  a=np.zeros((H,W,4),np.uint8);a[selected,:3]=src[selected];a[selected,3]=255
  name=o["id"]
  Image.fromarray(a,"RGBA").save(D/("R17_STAGE2_"+name+"_PAR_CANDIDATE.png"))
  rec={**o,"variant":int(variant),"score":float(confidence),"alpha_pixels":int(selected.sum()),
  "positive_missed":missed,"negative_selected":wrong,"root_exclusion":root,
  "source_rgb_exact":True,"human_mask_contour":"HOLD",
  "prompt_gate":"PASS" if missed==0 and wrong==0 else "FAIL"}
  records.append(rec)
  print("R17_R2_NEW_MASK",name,rec["alpha_pixels"],"prompt",rec["prompt_gate"],flush=True)
# Existing R1 bridge railing misses one positive; GrabCut+point seeds can rescue but must be stricter.
previous=next(z for z in meta if z["id"]=="BRIDGE_RAILING")
oldpiece=np.asarray(Image.open(D/"R17_STAGE2_BRIDGE_RAILING_PAR_CANDIDATE.png").convert("RGBA"))[:,:,3]>0
roi=(334,284,446,402);x0,y0,x1,y1=roi
small=oldpiece[y0:y1,x0:x1].astype("uint8")
gc=np.where(small>0,cv2.GC_PR_FGD,cv2.GC_PR_BGD).astype("uint8")
gc[cv2.erode(small,np.ones((3,3),np.uint8),iterations=2)>0]=cv2.GC_FGD
gc[cv2.dilate(small,np.ones((9,9),np.uint8),iterations=2)==0]=cv2.GC_BGD
for x,y in previous["neg"]:
 if x0<=x<x1 and y0<=y<y1:cv2.circle(gc,(x-x0,y-y0),3,cv2.GC_BGD,-1)
for x,y in previous["pos"]:
 if x0<=x<x1 and y0<=y<y1:cv2.circle(gc,(x-x0,y-y0),3,cv2.GC_FGD,-1)
bg=np.zeros((1,65),np.float64);fg=np.zeros((1,65),np.float64)
try:
 cv2.grabCut(cv2.cvtColor(src[y0:y1,x0:x1],cv2.COLOR_RGB2BGR),gc,None,bg,fg,5,cv2.GC_INIT_WITH_MASK)
 gcm=np.isin(gc,[cv2.GC_FGD,cv2.GC_PR_FGD])
 rescue=np.zeros((H,W),bool);rescue[y0:y1,x0:x1]=gcm
 miss=int(sum(not bool(rescue[y,x]) for x,y in previous["pos"]))
 wrong=int(sum(bool(rescue[y,x]) for x,y in previous["neg"]))
 # Avoid unbounded growth. Background negative mask remains a necessary but insufficient guard.
 allowed=int(rescue.sum())>int(oldpiece.sum())*.35 and int(rescue.sum())<=int(oldpiece.sum())*1.35
 ok=(miss==0 and wrong==0 and allowed)
except Exception as e:
 rescue=oldpiece.copy();ok=False;miss=-1;wrong=-1;print("GC_REFINE_FAIL",str(e),flush=True)
chosen=rescue if ok else oldpiece
a=np.zeros((H,W,4),np.uint8);a[chosen,:3]=src[chosen];a[chosen,3]=255
Image.fromarray(a,"RGBA").save(D/"R17_STAGE2_BRIDGE_RAILING_V2_SELECTED.png")
print("R17_R2_BRIDGE_REFINE",{"accept":bool(ok),"old_px":int(oldpiece.sum()),"new_px":int(rescue.sum()),"miss":miss,"wrong":wrong},flush=True)
# Build direct source-locked union of all 11 object candidates
allmasks=[]
for ob in meta:
 f=D/("R17_STAGE2_"+ob["id"]+"_PAR_CANDIDATE.png")
 if ob["id"]=="BRIDGE_RAILING":f=D/"R17_STAGE2_BRIDGE_RAILING_V2_SELECTED.png"
 allmasks.append(np.asarray(Image.open(f).convert("RGBA"))[:,:,3]>0)
for r in records:allmasks.append(np.asarray(Image.open(D/("R17_STAGE2_"+r["id"]+"_PAR_CANDIDATE.png")).convert("RGBA"))[:,:,3]>0)
assert len(allmasks)==11
union=np.logical_or.reduce(allmasks)
par=np.zeros((H,W,4),np.uint8);par[union,:3]=src[union];par[union,3]=255
Image.fromarray(par,"RGBA").save(D/"R17_STAGE2_PAR_11_OBJECT_SOURCE_CANDIDATE.png")
tint=src.copy();tint[union]=(tint[union].astype(np.float32)*.58+np.array([255,37,133])*.42).astype("uint8")
Image.fromarray(tint,"RGB").save(D/"R17_STAGE2_PAR_11_OBJECT_PINK_QA.png")
r={"status":"R17_STAGE2_11OBJECT_SOURCE_SAM2_PLUS_GC_ART_HOLD",
"master_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),
"source_pixels":[W,H],"original_art_modified":False,
"total_objects":len(allmasks),"R1_candidate_count":len(meta),
"R2_new_candidate_count":len(records),
"R2_prompt_pass_count":sum(v["prompt_gate"]=="PASS" for v in records),
"old_bridge_refine_accepted":bool(ok),"bridge_old_pixels":int(oldpiece.sum()),"bridge_new_pixels":int(rescue.sum()),
"bridge_positive_missed_after_attempt":miss,
"source_alpha_opaque_pixels":int(union.sum()),"source_rgb_exact":True,
"full_3complete_trees_and_full_house":"NOT_VERIFIED",
"native_art_grade":"HOLD","global_PAR_complete":False,"art_user_review":"PENDING",
"objects_new":records}
(D/"R17_STAGE2_R2_11OBJECT_GATE.json").write_text(json.dumps(r,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_R2_COMPLETE",json.dumps({k:r[k] for k in ["total_objects","R2_prompt_pass_count","old_bridge_refine_accepted","source_alpha_opaque_pixels"]}),flush=True)