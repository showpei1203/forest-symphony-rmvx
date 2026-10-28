#!/usr/bin/env python3
"""R17 Stage2: fully NEW 544x416 image-gen candidate. Use local SAM2.1 full native pixels.
Source RGB immutable, candidate masks only, NOT artist-approved, no 32px whole alpha.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,time,os
import numpy as np,cv2,torch
R=Path(__file__).resolve().parent;D=R/"R17_STAGE2_NEW_ART_20261029"
MASTER=D/"MASTER_STAGE2_NEW_GENERATED.png"
src=np.asarray(Image.open(MASTER).convert("RGB"));H,W=src.shape[:2]
assert (W,H)==(544,416)
torch.set_num_threads(min(6,os.cpu_count() or 6))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
predictor=SAM2ImagePredictor(build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml",
 "checkpoints/sam2.1_hiera_small.pt",device="cpu"))
# Native pixel coordinates visually verified against generated source; examples are not ground truth.
REG=[
{"id":"HOUSE_BLUE_ROOF","category":"house","bbox":[30,0,278,242],
"pos":[[130,57],[196,81],[100,157],[218,177],[137,189]],
"neg":[[287,27],[20,225],[249,255],[280,216],[319,74],[268,236]],
"foot":[177,233]},
{"id":"TREE_LARGE_EAST","category":"tree","bbox":[402,145,543,349],
"pos":[[471,188],[508,225],[490,268],[510,292],[509,306]],
"neg":[[397,218],[423,337],[541,355],[454,352],[396,310],[478,142]],
"foot":[508,336]},
{"id":"TREE_WEST_EDGE","category":"tree","bbox":[0,257,149,415],
"pos":[[35,306],[62,337],[34,371],[89,369]],
"neg":[[160,306],[141,410],[0,254],[110,273],[150,341]],
"foot":[51,410]},
{"id":"LAMP_CENTRAL","category":"lamp","bbox":[347,190,398,311],
"pos":[[374,212],[373,242],[374,268]],
"neg":[[346,241],[399,252],[352,303],[396,304],[356,200]],
"foot":[373,287]},
{"id":"BRIDGE_RAILING","category":"railing","bbox":[344,294,437,389],
"pos":[[370,338],[394,344],[416,353],[422,374]],
"neg":[[353,386],[437,382],[359,311],[430,306]],
"foot":[399,373]}
]
ground_rois=[
 ("CLEAR_CENTER_ROAD",[(218,252),(317,249),(312,291),(215,296)]),
 ("BOTTOM_STEPS",[(224,348),(282,348),(279,395),(224,398)]),
 ("CLEAR_UPPER_PATH",[(397,66),(470,64),(460,103),(404,104)])]
negmask=np.zeros((H,W),np.uint8)
for id,pts in ground_rois:cv2.fillPoly(negmask,[np.asarray(pts,np.int32)],255)
start=time.time();out=np.zeros((H,W,4),dtype=np.uint8);records=[]
with torch.inference_mode():
 predictor.set_image(src)
 for o in REG:
  pts=o["pos"]+o["neg"];labels=[1]*len(o["pos"])+[0]*len(o["neg"])
  masks,scores,_=predictor.predict(point_coords=np.asarray(pts,np.float32),
    point_labels=np.asarray(labels,np.int32),box=np.asarray(o["bbox"],np.float32),
    multimask_output=True)
  opts=[]
  for var,(mask,score) in enumerate(zip(masks,scores)):
   mask=mask.astype(bool)
   n,lab,stat,c=cv2.connectedComponentsWithStats(mask.astype(np.uint8),8)
   positives={int(lab[y,x]) for x,y in o["pos"] if mask[y,x]};positives.discard(0)
   filtered=np.isin(lab,list(positives)) if positives else np.zeros_like(mask)
   # ensure in bbox + only 6px tolerance, no all-tile filling
   x0,y0,x1,y1=o["bbox"]
   allowed=np.zeros_like(mask);allowed[max(0,y0-6):min(H,y1+7),max(0,x0-6):min(W,x1+7)]=True
   filtered &= allowed
   miss=int(sum(not bool(filtered[y,x]) for x,y in o["pos"]))
   errors=int(sum(bool(filtered[y,x]) for x,y in o["neg"]))
   groundhit=int(np.logical_and(filtered,negmask>0).sum())
   value=float(score)-0.55*miss-.5*errors-0.001*groundhit
   opts.append((value,filtered,float(score),var,miss,errors,groundhit))
  value,chosen,conf,var,miss,err,groundhit=max(opts,key=lambda q:q[0])
  # Semantically ensure only tree contact world-tile root is removed, no giant Y-strip.
  root_exclusion=None
  if o["category"]=="tree":
   fx,fy=o["foot"];rx=min(16,max(0,fx//32));ry=min(12,max(0,fy//32))
   chosen[ry*32:(ry+1)*32,rx*32:(rx+1)*32]=False
   root_exclusion=[rx,ry]
  pix=np.zeros((H,W,4),np.uint8)
  pix[chosen,:3]=src[chosen];pix[chosen,3]=255
  Image.fromarray(pix,"RGBA").save(D/("R17_STAGE2_"+o["id"]+"_PAR_CANDIDATE.png"))
  overwrite=chosen&(out[:,:,3]==0)
  out[overwrite,:3]=src[overwrite];out[overwrite,3]=255
  # Individual sample gates are necessary, but not enough for Art Gate.
  r={**o,"mask_variant":int(var),"sam2_score":float(conf),
  "opaque_px":int(chosen.sum()),"missing_positive_count":int(miss),
  "false_negative_seed_selected_count":int(err),
  "overlap_with_three_ground_negative_ROIs_px":int(groundhit),
  "source_rgb_exact":bool(np.array_equal(pix[chosen,:3],src[chosen])),
  "root_ground_only_tile":root_exclusion,
  "object_contour_human_art_review":"HOLD",
  "mask_seed_gate":"PASS" if miss==0 and err==0 and groundhit==0 else "FAIL"}
  records.append(r)
  print("R17_STAGE2_MASK",r["id"],"alpha",r["opaque_px"],"GND",groundhit,"posmiss",miss,"negerr",err,"seed",r["mask_seed_gate"],flush=True)
Image.fromarray(out,"RGBA").save(D/"R17_STAGE2_PAR_5OBJECT_SOURCE_CANDIDATE.png")
qa=src.copy();active=out[:,:,3]>0
qa[active]=(qa[active].astype(np.float32)*.58+np.array([255,35,147])*.42).astype(np.uint8)
Image.fromarray(qa,"RGB").save(D/"R17_STAGE2_PAR_PINK_QA.png")
points=Image.fromarray(qa,"RGB");dr=ImageDraw.Draw(points)
for o in REG:
 for x,y in o["pos"]:dr.ellipse([x-3,y-3,x+3,y+3],fill=(0,255,100))
 for x,y in o["neg"]:dr.ellipse([x-3,y-3,x+3,y+3],fill=(255,40,20))
points.save(D/"R17_STAGE2_PAR_PROMPT_AND_MASK_AUDIT.png")
payload={
"status":"R17_STAGE2_NEW_ART_MASTER_SAM2_5OBJECT_PROPOSAL_ART_MASK_HOLD",
"source_master_sha256":hashlib.sha256(MASTER.read_bytes()).hexdigest(),
"source":"new image generation visual scene (cropped from illustrated comparison board); not R12 Master",
"master_native_size":[544,416],"is_new_art":True,"is_pure_original_image_gen_single_panel":True,
"not_claimed":"full user-approved 3 trees and 1 house and rail clean layered",
"source_RGB_exact":True,"total_par_alpha_px":int(active.sum()),
"ground_only_rois":[{"name":id,"polygon":p} for id,p in ground_rois],
"human_ART_gate":"HOLD","human_mask_gate":"HOLD",
"actual_model":"SAM2.1 native full resolution CPU","model_time_sec":round(time.time()-start,2),
"candidate_objects":records,"whole_scene_semantically_complete":False,"formal_Seal":False}
(D/"R17_STAGE2_NEW_ART_SAM2_GATE.json").write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding="utf8")
print("R17_STAGE2_TOTAL",json.dumps({"alpha":payload["total_par_alpha_px"],"seed_pass_count":sum(z["mask_seed_gate"]=="PASS" for z in records),"total":len(records)},ensure_ascii=False),flush=True)