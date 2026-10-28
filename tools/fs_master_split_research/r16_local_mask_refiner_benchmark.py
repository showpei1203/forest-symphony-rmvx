#!/usr/bin/env python3
"""R16 CPU-only GraphCut refinement A/B vs SAM2, existing full-resolution original Master.
No tile fill, no source pixel replacement. A proposed improvement must pass seed constraints,
not increase negative ground test contamination, and not grow wildly.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,json,hashlib,collections
ROOT=Path(__file__).resolve().parent
OLD=ROOT/"R15_MULTISCALE_MASK_RESEARCH_20261028";NEW=ROOT/"R16_MODEL_TOOL_EVAL_20261028"
NEW.mkdir(parents=True,exist_ok=True)
MASTER=ROOT/"R12_NEW_ELF_VILLAGE_001"/"MASTER_NEW_ELF_VILLAGE_001_R12_CANDIDATE.png"
src=np.asarray(Image.open(MASTER).convert("RGB")).copy()
H,W=src.shape[:2]
cases=json.loads((OLD/"R15_ROI_SAM2_PILOT_GATE.json").read_text(encoding="utf8"))["results"]
r12col=json.loads((ROOT/"R12_NEW_ELF_VILLAGE_001"/"R12_SELECTED14_AND_COLLISION_GATE.json").read_text(encoding="utf8"))
ground=np.zeros((H,W),np.uint8)
for name,poly in r12col["ground_stairs_bridge_exclusions"]:
 cv2.fillPoly(ground,[np.array(poly,np.int32)],1)
baselineground=ground>0
scores=[]
for row in cases:
 oid=row["id"]
 old=np.asarray(Image.open(OLD/(oid+"_SAM2_EXACT_RGBA.png")).convert("RGBA"))[:,:,3]>0
 x0,y0,x1,y1=row["bbox"]
 pad=32;x0=max(0,x0-pad);y0=max(0,y0-pad);x1=min(W,x1+pad);y1=min(H,y1+pad)
 tile=src[y0:y1,x0:x1].copy()
 m=old[y0:y1,x0:x1].astype("uint8")
 # GC mask: outside SAM and 12px band is BG, inside is probable FG.
 gc=np.where(m>0,cv2.GC_PR_FGD,cv2.GC_PR_BGD).astype("uint8")
 kernel=cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(5,5))
 interior=cv2.erode(m,kernel,iterations=2)>0
 gc[interior]=cv2.GC_FGD
 # add reliable true-background just outside dilated mask
 distant=cv2.dilate(m,np.ones((21,21),np.uint8),iterations=1)==0
 gc[distant]=cv2.GC_BGD
 for px,py in row["neg"]:
  lx,ly=px-x0,py-y0
  if 0<=lx<gc.shape[1] and 0<=ly<gc.shape[0]:
   cv2.circle(gc,(lx,ly),3,cv2.GC_BGD,-1)
 for px,py in row["pos"]:
  lx,ly=px-x0,py-y0
  if 0<=lx<gc.shape[1] and 0<=ly<gc.shape[0]:
   cv2.circle(gc,(lx,ly),2,cv2.GC_FGD,-1)
 bkg=np.zeros((1,65),np.float64);fgd=np.zeros((1,65),np.float64)
 try:
  cv2.grabCut(cv2.cvtColor(tile,cv2.COLOR_RGB2BGR),gc,None,bkg,fgd,5,cv2.GC_INIT_WITH_MASK)
  result=np.isin(gc,[cv2.GC_FGD,cv2.GC_PR_FGD])
  error=""
 except Exception as e:
  result=m>0;error=str(e)
 # prevent boundary leaking outside registered ROI + 6 pixels. No whole 32px tiles.
 bx0,by0,bx1,by1=row["bbox"]
 support=np.zeros((H,W),np.uint8);support[max(0,by0-6):min(H,by1+6),max(0,bx0-6):min(W,bx1+6)]=1
 masknew=np.zeros((H,W),bool);masknew[y0:y1,x0:x1]=result
 masknew &= support.astype(bool)
 posmiss=sum(not masknew[py,px] for px,py in row["pos"])
 neghit=int(sum(bool(masknew[py,px]) for px,py in row["neg"]))
 oldposmiss=int(sum(not old[py,px] for px,py in row["pos"]))
 oldneghit=int(sum(bool(old[py,px]) for px,py in row["neg"]))
 oldfloor=int((old&baselineground).sum())
 newfloor=int((masknew&baselineground).sum())
 oldarea=int(old.sum());newarea=int(masknew.sum())
 accepted=bool(not error and posmiss==0 and neghit==0
          and newfloor<=oldfloor and (0.35*oldarea)<=newarea<=(1.4*oldarea))
 # Fail closed: preserve old candidate output if GC worsens metrics.
 use=masknew if accepted else old
 rgba=np.zeros((H,W,4),np.uint8);rgba[use,:3]=src[use];rgba[use,3]=255
 Image.fromarray(rgba,"RGBA").save(NEW/(oid+"_R16_SELECTED_SOURCE_RGBA.png"))
 def panel(mask,color):
  v=src[y0:y1,x0:x1].copy()
  clip=mask[y0:y1,x0:x1]
  v[clip]=(v[clip].astype("float32")*.55+np.array(color)*.45).astype("uint8")
  return v
 im=np.concatenate([src[y0:y1,x0:x1],panel(old,[255,40,144]),panel(masknew,[30,187,243])],axis=1)
 board=Image.new("RGB",(im.shape[1],im.shape[0]+25),(23,27,30))
 board.paste(Image.fromarray(im),(0,25));draw=ImageDraw.Draw(board)
 for j,name in enumerate(["MASTER (no changes)","SAM2 v15","GrabCut proposed v16"]):
  draw.text((j*(x1-x0)+4,5),name,fill="white")
 board.save(NEW/(oid+"_SAM2_GC_COMPARE.png"))
 scores.append({"id":oid,"sam2_area":oldarea,"grabcut_area":newarea,
                "old_positive_missed":oldposmiss,"new_positive_missed":posmiss,
                "old_negative_hit":oldneghit,"new_negative_hit":neghit,
                "old_known_ground_region_overlap_px":oldfloor,
                "new_known_ground_region_overlap_px":newfloor,
                "local_accept":accepted,"graphcut_error":error,
                "exported_choice":"GC_PROPOSAL" if accepted else "SAM2_BASELINE_FALLBACK",
                "source_RGB_exact":bool(np.array_equal(rgba[use,:3],src[use])),
                "user_semantic_correctness":"NOT_PROVEN"})
 print("R16_GRABCUT",json.dumps(scores[-1],ensure_ascii=False),flush=True)
report={"status":"R16_CPU_GRABCUT_SAM2_MASK_BENCHMARK_COMPLETE_ART_HOLD",
        "source_Master_unmodified":True,"canvas":[W,H],
        "algorithm":"cv2.grabCut 5 iterations with SAM2 FG trimap + positive negative point seeds",
        "actual_new_models_executed":["OpenCV GrabCut + existing SAM2 output"],
        "new_SAM3_executed":False,"new_Qwen_executed":False,"new_LayerDiffuse_diffusion_executed":False,
        "PixelART_weights_available":False,
        "accepted_count":sum(a["local_accept"] for a in scores),
        "cases":scores,"human_approved":False,
        "ground_only_polygon_source":"R12 candidate metadata, not gold pixel masks",
        "meaning":"Automated candidate local refinement not a formal segmentation accuracy claim."}
(NEW/"R16_GRABCUT_SAM2_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("R16_GRABCUT_GATE",report["accepted_count"],"/",len(scores),flush=True)