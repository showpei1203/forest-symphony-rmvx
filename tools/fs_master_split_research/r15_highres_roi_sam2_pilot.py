#!/usr/bin/env python3
"""R15 new A/B/C pilot: original rich Master unchanged, test prompt-guided ROI masks only.
No tile-snap, no "paint full 32px tile" allowed. SAM2 is existing CPU baseline; not SAM3/Qwen.
Model confidence != artistic correctness. Invalid candidates stay FAIL/HOLD, never fill floor tiles.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,torch,hashlib,json,time,os
R=Path(__file__).resolve().parent;S=R/"R12_NEW_ELF_VILLAGE_001"
D=R/"R15_MULTISCALE_MASK_RESEARCH_20261028";D.mkdir(exist_ok=True)
MASTER=S/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
src=np.asarray(Image.open(MASTER).convert("RGB"))
H,W=src.shape[:2];assert (H,W)==(928,1280)
R13=R/"R13_TILE_OCCLUSION_PAR_20261028"
cases=[
 {"id":"TREE_LEFT_MAJOR","legacy_id":"A10_LARGE_LEFT_TREE",
 "type":"tree","bbox":[174,312,440,567],
 "pos":[[282,381],[292,419],[305,451],[288,486]],
 "neg":[[204,560],[435,552],[440,382],[181,462],[365,555],[240,559]],
 "foot":[290,534]},
 {"id":"CAFE_RED_HOUSE","legacy_id":"A05_RED_CAFE",
 "type":"building","bbox":[658,268,904,526],
 "pos":[[764,350],[786,420],[759,382],[720,389]],
 "neg":[[653,520],[901,518],[897,296],[661,278],[752,535]],
 "foot":[784,499]},
 {"id":"LAMP_FOUNTAIN_NW","legacy_id":"LAMP03_FOUNTAIN_NW",
 "type":"lamp","bbox":[424,380,477,515],
 "pos":[[449,402],[448,431],[452,458]],
 "neg":[[428,509],[474,508],[420,401],[483,427],[425,484],[471,486]],
 "foot":[453,488]},
]
# Use an alpha scorer to reject bleeding outside object, missing positive or unwanted negative.
torch.set_num_threads(min(8,os.cpu_count() or 8))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device="cpu")
pred=SAM2ImagePredictor(model);start=time.time()
def roi_intersection(mask,box):
 b=np.zeros_like(mask)
 left,top,right,bottom=box
 b[top:bottom,left:right]=True
 return mask & b
rows=[]
with torch.inference_mode():
 pred.set_image(src)
 for o in cases:
  pts=np.asarray(o["pos"]+o["neg"],np.float32)
  lbs=np.asarray([1]*len(o["pos"])+[0]*len(o["neg"]),np.int32)
  masks,scores,_=pred.predict(point_coords=pts,point_labels=lbs,
                              box=np.asarray(o["bbox"],np.float32),multimask_output=True)
  candidates=[]
  for v,(m,s) in enumerate(zip(masks,scores)):
   m=m.astype(bool)
   # require all positive sample points are connected in one region and negative sample points are absent
   n,label,stats,cents=cv2.connectedComponentsWithStats(m.astype(np.uint8),8)
   labels={int(label[y,x]) for x,y in o["pos"] if m[y,x]}
   labels.discard(0)
   selected=np.isin(label,list(labels)) if labels else np.zeros_like(m)
   missed=sum(not selected[y,x] for x,y in o["pos"])
   wrong=sum(selected[y,x] for x,y in o["neg"])
   bx,by,br,bb=o["bbox"]
   allow=np.zeros_like(m);allow[max(0,by-8):min(H,bb+9),max(0,bx-8):min(W,br+9)]=True
   spilling=int((selected & ~allow).sum())/max(1,int(selected.sum()))
   metric=float(s)-.35*missed-.3*wrong-.8*spilling
   candidates.append((metric,v,float(s),selected,missed,wrong,spilling))
  q=max(candidates,key=lambda x:x[0]);_,variant,score,m,missed,wrong,spilling=q
  # Reject if any positive missing or certain negative selected. Keep raw suggestion even on FAIL for review.
  prompt_pass=bool(missed==0 and wrong==0 and spilling<=.02 and m.sum()>=16)
  alpha=np.zeros((H,W,4),dtype=np.uint8);alpha[m,:3]=src[m];alpha[m,3]=255
  Image.fromarray(alpha,"RGBA").save(D/(o["id"]+"_SAM2_EXACT_RGBA.png"))
  obj13=R13/(o["legacy_id"]+"_PAR.png")
  if obj13.is_file():
   old=np.asarray(Image.open(obj13).convert("RGBA"))[:,:,3]>0
  else:old=np.zeros_like(m)
  shared=int((old&m).sum())
  # Output binary mask strictly pixel aligned with full Master.
  box=o["bbox"];x0,y0,x1,y1=box
  x0=max(0,x0-16);y0=max(0,y0-16);x1=min(W,x1+16);y1=min(H,y1+16)
  def marked(base,mask,color):
   z=base.copy();z[mask]=(z[mask].astype(np.float32)*.55+np.array(color)*.45).astype("uint8");return z
  original=src[y0:y1,x0:x1]
  mask=m[y0:y1,x0:x1];oldmask=old[y0:y1,x0:x1]
  trio=np.concatenate([original,marked(original,oldmask,[255,25,135]),marked(original,mask,[28,180,245])],axis=1)
  im=Image.fromarray(trio)
  canvas=Image.new("RGB",(im.width,im.height+28),(25,28,31))
  canvas.paste(im,(0,28))
  d=ImageDraw.Draw(canvas)
  d.text((4,4),"SOURCE",fill="white")
  d.text((im.width//3+4,4),"R13: overfilled grid",fill="white")
  d.text((2*im.width//3+4,4),"R15: ROI SAM2 mask",fill="white")
  canvas.save(D/(o["id"]+"_SOURCE_R13_VS_R15.png"))
  rows.append({**o,"sam2_variant":variant,"confidence":score,"alpha_px":int(m.sum()),
    "R13_legacy_alpha_px":int(old.sum()),"R13_vs_ROI_overlap_px":shared,
    "missed_positive":int(missed),"selected_negative":int(wrong),"roi_spill_ratio":float(spilling),
    "prompt_consistency_pass":prompt_pass,
    "source_rgb_exact":bool(np.array_equal(alpha[m,:3],src[m])),
    "pixel_level_art_verified":False,
    "note":"No blanket 32px tile alpha, source-only original RGB; human pixel-art contour review required"})
  print("R15_MASK_RESULT",o["id"],"srcpx",int(m.sum()),"old",int(old.sum()),"score",round(score,3),
        "miss",missed,"wrong",wrong,"spill",round(spilling,5),"PASS",prompt_pass,flush=True)
payload={
 "status":"R15_HIGH_RES_ROI_SAM2_MASK_PROPOSAL_ONLY_ART_HOLD",
 "master_full_res":[W,H],
 "master_SHA256":hashlib.sha256(MASTER.read_bytes()).hexdigest(),
 "original_MASTER_unchanged":True,
 "algorithm":"SAM2.1 local ROI full 1280x928 native pixel resolution, 4 point positives 5-6 negatives, no tile fill",
 "Qwen_Image_Layered_tested":False,"SAM3_tested":False,
 "total_objects":len(rows),
 "prompt_pass_count":sum(int(z["prompt_consistency_pass"]) for z in rows),
 "semantic_quality_art_pass":False,
 "masks_source_exact":all(z["source_rgb_exact"] for z in rows),
 "estimated_runtime_seconds":round(time.time()-start,2),
 "results":rows}
(D/"R15_ROI_SAM2_PILOT_GATE.json").write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding="utf8")
print("R15_PILOT",json.dumps({k:payload[k] for k in ["status","total_objects","prompt_pass_count","estimated_runtime_seconds"]}),flush=True)