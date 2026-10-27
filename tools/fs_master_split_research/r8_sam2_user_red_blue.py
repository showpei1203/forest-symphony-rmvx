#!/usr/bin/env python3
"""R8: positive user-labeled RED instances; BLUE exclusion overrides all.
Uses SAM2, saves each mask, source-exact RGBA. No independent PAR/ground repaint.
"""
from pathlib import Path
import json,time,os,hashlib
from PIL import Image,ImageDraw
import numpy as np,torch,cv2
R=Path(__file__).resolve().parent
D=R/"R8_USER_ANNOTATION_20261028"
A=json.loads((D/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
S=R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png"
original=np.asarray(Image.open(S).convert("RGBA"));H,W=original.shape[:2]
assert (W,H)==(544,416)
old=np.asarray(Image.open(R/"R7_SEMANTIC_MASK_CANDIDATES"/"PAR_R7_PROPOSAL_SAME_SOURCE_RGBA.png").convert("RGBA"))
assert old.shape==original.shape
torch.set_num_threads(min(8,os.cpu_count() or 8))
from sam2.build_sam import build_sam2
from sam2.sam2_image_predictor import SAM2ImagePredictor
start=time.time()
model=build_sam2("configs/sam2.1/sam2.1_hiera_s.yaml","checkpoints/sam2.1_hiera_small.pt",device="cpu")
predictor=SAM2ImagePredictor(model)
candidate_results=[]
positive_objects=[]
image=original[:,:,:3].copy()
with torch.inference_mode():
 predictor.set_image(image)
 for obj in A["user_red"]:
  pos=obj["positives"];neg=obj["negatives"]
  pc=np.asarray(pos+neg,dtype=np.float32)
  labels=np.asarray([1]*len(pos)+[0]*len(neg),dtype=np.int32)
  ms,scores,_=predictor.predict(box=np.asarray(obj["box"],dtype=np.float32),
     point_coords=pc,point_labels=labels,multimask_output=True)
  candidates=[]
  for variant,(candidate,score) in enumerate(zip(ms,scores)):
   mask=np.asarray(candidate,dtype=bool)
   # Connected component containing a user-marked positive, not entire ambiguous connected vegetation.
   n,lab,stats,cent=cv2.connectedComponentsWithStats(mask.astype(np.uint8),8)
   ids={int(lab[y,x]) for x,y in pos if mask[y,x]}
   ids.discard(0)
   pick=np.isin(lab,list(ids)) if ids else np.zeros_like(mask)
   missed=sum(not pick[y,x] for x,y in pos)
   neg_hit=sum(pick[y,x] for x,y in neg)
   bx1,by1,bx2,by2=obj["box"]
   expanded=np.zeros_like(pick)
   expanded[max(0,by1-7):min(H,by2+8),max(0,bx1-7):min(W,bx2+8)]=True
   out=int((pick&~expanded).sum())
   ratio=out/max(1,int(pick.sum()))
   value=float(score)-.25*missed-.12*neg_hit-.6*ratio
   candidates.append((value,variant,float(score),pick,missed,neg_hit,ratio))
  value,variant,score,mask,missed,neg_hit,out_ratio=max(candidates,key=lambda z:z[0])
  ok=(missed==0 and neg_hit==0 and out_ratio<=.03 and int(mask.sum())>=8)
  # The center/entire source alpha matters for micro occluders; do NOT clip under foot_y.
  rgba=np.zeros_like(original);rgba[mask]=original[mask];rgba[:,:,3]=mask.astype(np.uint8)*255
  filename=f"{obj['id']}_{obj['name']}_SAM2_SOURCE_PAR.png"
  Image.fromarray(rgba,"RGBA").save(D/filename)
  Image.fromarray(mask.astype(np.uint8)*255,"L").save(D/f"{obj['id']}_RAW_MASK.png")
  item={"id":obj["id"],"name":obj["name"],"candidate_pixels":int(mask.sum()),"sam_score":score,
        "sam_variant":variant,"positive_missing":missed,"negative_hits":neg_hit,
        "outside_box_plus7_ratio":round(out_ratio,5),"prompt_candidate":ok,
        "source_png":filename,"foot_y":obj["foot"][1],"kind":obj["kind"],
        "requires_human_outline_approval":True}
  candidate_results.append(item)
  positive_objects.append(mask)
  print("R8_SAM2_RED",obj["id"],"candidate",int(mask.sum()),"prompt_pass",ok,flush=True)
# Blue: exclude entire user-ring ellipse, preserving the entire original Ground unchanged.
blue=np.zeros((H,W),dtype=np.uint8)
pen=Image.new("L",(W,H),0);dr=ImageDraw.Draw(pen)
for b in A["user_blue"]:
 x1,y1,x2,y2=b["box"]
 dr.ellipse((x1,y1,x2,y2),fill=255)
blue=np.asarray(pen)>0
Image.fromarray(blue.astype(np.uint8)*255,"L").save(D/"R8_BLUE_STEPS_HARD_EXCLUSION_MASK.png")
# Protect user blue first. Then user-red objects take high priority over R7 classes wherever pixels overlap.
alpha=np.asarray(old[:,:,3]>0).copy()
owner=np.asarray(Image.open(R/"R7_SEMANTIC_MASK_CANDIDATES"/"R7_OBJECT_PIXEL_OWNER.png")).astype(np.uint8)
original_owner=owner.copy()
for n,mask in enumerate(positive_objects,1):
  editable=mask & ~blue
  alpha[editable]=True
  owner[editable]=12+n
alpha[blue]=False
owner[blue]=0
# Each red object output also must obey blue exclusion even when original local mask overlaps blue.
for obj,mask in zip(A["user_red"],positive_objects):
 f=D/(obj["id"]+"_"+obj["name"]+"_SAM2_SOURCE_PAR.png")
 arr=np.asarray(Image.open(f).convert("RGBA")).copy()
 arr[blue,3]=0
 Image.fromarray(arr).save(f)
rgba=np.zeros_like(original);rgba[alpha]=original[alpha];rgba[:,:,3]=alpha.astype(np.uint8)*255
Image.fromarray(rgba,"RGBA").save(D/"PAR_R8_USER_RED_BLUE_SOURCE_ALIGNED.png")
Image.fromarray(owner,"L").save(D/"R8_OBJECT_OWNER.png")
rgb=original.copy();rgb[alpha,:3]=(rgb[alpha,:3].astype(np.float32)*.60+np.array([255,25,150])*.40).astype(np.uint8)
Image.fromarray(rgb).save(D/"R8_COMPOSITE_PINK_COVERAGE.png")
overlay=Image.fromarray(original,"RGBA");dra=ImageDraw.Draw(overlay)
for o in A["user_red"]:
 dra.rectangle(tuple(o["box"]),outline=(255,33,52,255),width=2)
 dra.text((o["box"][0],max(0,o["box"][1]-10)),o["id"],fill=(255,33,52,255))
for o in A["user_blue"]:
 dra.ellipse(tuple(o["box"]),outline=(40,90,255,255),width=3)
 dra.text((o["box"][0],max(0,o["box"][1]-12)),o["id"],fill=(40,90,255,255))
overlay.save(D/"R8_SCENE21_USER_OVERRIDES_QA.png")
core_alpha=lambda xy,rad=6: sum(bool(alpha[y,x]) for x0,y0 in xy for y in range(max(0,y0-rad),min(H,y0+rad+1)) for x in range(max(0,x0-rad),min(W,x0+rad+1)))
seed_check=[]
for o in A["user_red"]:
 x,y=o["positives"][0];s=core_alpha([(x,y)])
 expected_pixel=int((positive_objects[A["user_red"].index(o)][max(0,y-6):y+7,max(0,x-6):x+7]&~blue[max(0,y-6):y+7,max(0,x-6):x+7]).sum())
 seed_check.append({"id":o["id"],"source_union_alpha_13x13_px":s,
 "individual_object_alpha_13x13_px":expected_pixel,"passes_seed_coverage":expected_pixel>=20})
steps=A["user_blue"][0]["core"];blue_core=int(alpha[steps[1]:steps[3],steps[0]:steps[2]].sum())
assert blue_core==0
assert np.array_equal(rgba[alpha,:3],original[alpha,:3])
report={
 "status":"R8_RED_BLUE_USER_OVERRIDES_APPLIED_TECH_CANDIDATE_ART_HOLD",
 "source_sha256":hashlib.sha256(S.read_bytes()).hexdigest(),
 "red_requested":len(A["user_red"]),"blue_requested":len(A["user_blue"]),
 "sam2_prompt_consistent_count":sum(x["prompt_candidate"] for x in candidate_results),
 "red_individual_seed_test_pass":sum(x["passes_seed_coverage"] for x in seed_check),
 "red_seed_failed":[x["id"] for x in seed_check if not x["passes_seed_coverage"]],
 "blue_step_core_alpha":blue_core,
 "blue_excluded_area_px":int(blue.sum()),
 "r7_original_union_px":int((old[:,:,3]>0).sum()),
 "r8_union_px":int(alpha.sum()),
 "added_alpha_px":int((alpha & ~(old[:,:,3]>0)).sum()),
 "removed_r7_alpha_for_user_blue_px":int(((old[:,:,3]>0)&blue).sum()),
 "object_owner_overrides_px":int((owner!=original_owner).sum()),
 "all_par_opaque_pixels_match_source_rgb":True,
 "elapsed_cpu_seconds":round(time.time()-start,2),
 "semantic_art_approved":False,
 "coordinate_alignment_independently_pixel_verified":False,
 "original_fs_505_scripts_tested":False,
 "red_objects":candidate_results,"red_seed_checks":seed_check,
 "caution":"Red/blue annotated screenshot has different color tone and canvas height (548x400), source original is 544x416; rough manual region mapping is a candidate, not formal pixel annotation."
}
(D/"R8_SAM2_USER_ANNOTATION_RESULT.json").write_text(json.dumps(report,ensure_ascii=False,indent=2,default=lambda z: int(z) if isinstance(z,np.integer) else float(z) if isinstance(z,np.floating) else str(z)),encoding="utf8")
print("R8_TOTAL",json.dumps({k:report[k] for k in ["sam2_prompt_consistent_count","red_individual_seed_test_pass","red_seed_failed","blue_step_core_alpha","added_alpha_px","removed_r7_alpha_for_user_blue_px","r8_union_px"]},default=lambda z: int(z) if isinstance(z,np.integer) else str(z)),flush=True)