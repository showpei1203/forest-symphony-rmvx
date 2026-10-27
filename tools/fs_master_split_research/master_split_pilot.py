#!/usr/bin/env python3
"""FS master-first semantic split PILOT. NON-PRODUCTION. Read-only source."""
import argparse, hashlib, json, os, time
from pathlib import Path
import cv2, numpy as np, torch
from PIL import Image, ImageDraw
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor

OBJS=[
 {"id":"house","box":[272,47,422,244],"type":"PAR_CANDIDATE","foot_estimate":[332,219]},
 {"id":"left_tree","box":[67,45,227,222],"type":"PAR_CANDIDATE","foot_estimate":[149,203]},
 {"id":"right_tree","box":[420,100,533,281],"type":"PAR_CANDIDATE","foot_estimate":[480,258]},
]
def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def save(arr,p):
 Image.fromarray(arr).save(str(p))
def main():
 ap=argparse.ArgumentParser()
 ap.add_argument("--image",required=True)
 ap.add_argument("--out",required=True)
 ap.add_argument("--cpu",action="store_true")
 args=ap.parse_args()
 out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
 raw=Image.open(args.image).convert("RGBA")
 master=np.asarray(raw,dtype=np.uint8)
 h,w=master.shape[:2]
 assert (w,h)==(544,416),f"Unexpected original dimensions {w}x{h}"
 rgb=master[:,:,:3].copy()
 objects=[dict(x) for x in OBJS]
 device="cuda" if torch.cuda.is_available() and not args.cpu else "cpu"
 ts=time.time(); torch.set_num_threads(min(8,os.cpu_count() or 1))
 model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device=device)
 predictor=SAM2ImagePredictor(model)
 with torch.inference_mode():
  predictor.set_image(rgb)
  for obj in objects:
   box=np.array(obj["box"],dtype=np.float32)
   masks,scores,_=predictor.predict(box=box,multimask_output=True)
   # Highest confidence is only an algorithmic candidate, not an ART pass.
   idx=int(np.argmax(scores)); m=np.asarray(masks[idx]).astype(bool)
   obj["sam2_score"]=float(scores[idx]);obj["mask_pixels"]=int(m.sum())
   obj["mask_candidate"]=obj["id"]+"_SAM2_RAW.png"
   save((m*255).astype(np.uint8),out/obj["mask_candidate"])
   obj["_mask"]=m
 # Resolve competing mask pixel owners deterministically by priority, but flag overlaps.
 n=np.zeros((h,w),dtype=np.uint16)
 for obj in objects: n+=obj["_mask"]
 overlaps=int((n>1).sum())
 owner=np.zeros((h,w),dtype=np.uint8)
 for i,obj in enumerate(objects,1):
  m=obj["_mask"] & (owner==0)
  owner[m]=i
  obj["claimed_pixels"]=int(m.sum())
  obj["overlap_lost_pixels"]=int((obj["_mask"] & ~m).sum())
 union=owner!=0
 # PIL preserved original rgba on every claimed PAR pixel; no resizing / filtering.
 par=np.zeros_like(master);par[union]=master[union];par[:,:,3]=np.where(union,255,0)
 ground_known=master.copy()
 ground_known[union]=[0,0,0,0]
 # Inpainting is exploratory ONLY. Never pretend that hidden terrain is recovered.
 inp=(union.astype(np.uint8)*255)
 # Exclude nothing: one failure mode is terrain smeared by nearby foliage.
 fill_cv=cv2.inpaint(rgb,inp,3,cv2.INPAINT_TELEA)
 complete=np.dstack([fill_cv,np.full((h,w),255,dtype=np.uint8)])
 # Existing unobscured master visible pixels must remain EXACT.
 complete[~union]=master[~union]
 reconstructed=complete.copy()
 reconstructed[union]=par[union]
 err=int(np.count_nonzero(np.any(master!=reconstructed,axis=2)))
 paralpha=np.dstack([rgb,np.where(union,255,0).astype(np.uint8)])
 overlay=rgb.copy()
 overlay[union]=(overlay[union]*.4+np.array([255,60,200])*.6).astype(np.uint8)
 # no near-neighbor adjustments or antialiasing at this stage
 save(master,out/"MASTER_RGBA.png")
 save(par,out/"PAR_CANDIDATE_RGBA.png")
 save(ground_known,out/"GROUND_VISIBLE_HOLES.png")
 save(complete,out/"GROUND_TELEA_EXPERIMENT_ONLY.png")
 save(reconstructed,out/"RECOMPOSE.png")
 save((union*255).astype(np.uint8),out/"UNION_MASK.png")
 save(owner,out/"PIXEL_OWNER_ID.png")
 save(overlay,out/"MASK_OVERLAY_QA.png")
 discrep=np.zeros((h,w,3),dtype=np.uint8)
 discrep[n>1]=[255,40,40]
 save(discrep,out/"OVERLAP_CONFLICTS_RED.png")
 # failure injection: shift PAR mask 1px without ground shift -> must detect visible difference
 shifted=np.zeros_like(union);shifted[:,1:]=union[:,:-1]
 test_corrupted=complete.copy();test_corrupted[shifted]=par[shifted]
 negative=int(np.count_nonzero(np.any(test_corrupted!=master,axis=2)))
 manifest={
  "status":"TECHNICAL_SPLIT_PILOT_ONLY_ART_NOT_APPROVED",
  "master_reference":"SCENE21.png",
  "source_sha256":sha(args.image),
  "source_dimensions":[w,h],
  "method":"SAM2.1 small guided boxes + deterministic mask ownership + experimental OpenCV Telea inpaint",
  "device":device,
  "seconds":round(time.time()-ts,3),
  "objects":[{k:v for k,v in o.items() if k!="_mask"} for o in objects],
  "union_px":int(union.sum()),
  "union_ratio":float(union.mean()),
  "raw_mask_overlap_px":overlaps,
  "reconstruction_mismatched_pixels":err,
  "negative_1px_shift_detected_pixels":negative,
  "ground_fill":"EXPERIMENTAL_CV_INPAINT_DO_NOT_SHIP",
  "art_gate":"PENDING_MANUAL_SEMANTIC_MASK_AND_GROUND_VISUAL_REVIEW",
  "par_complete":False,
  "vx_runtime_tested":False,
  "ground_exclusive_semantics_verified":False,
  "license":"PRIVATE_REFERENCE_ONLY",
  "files_sha256":{}
 }
 for f in out.glob("*.png"):manifest["files_sha256"][f.name]=sha(f)
 (out/"PILOT_METRICS.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
 print(json.dumps({k:manifest[k] for k in ["status","device","seconds","union_px","union_ratio","raw_mask_overlap_px","reconstruction_mismatched_pixels","negative_1px_shift_detected_pixels","art_gate"]},ensure_ascii=False))
if __name__=="__main__": main()