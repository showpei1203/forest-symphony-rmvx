#!/usr/bin/env python3
"""R9 independent spatial/edge risk audit of R8 SAM2 source-pixel masks.
Uses real image intensity gradients, masks and connected components.
Never assert "perfect visual outline" based on model scores or pixel exactness.
"""
from pathlib import Path
import json,cv2,numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
S=R/"SCENE21_GUIDED_SAM2_CANDIDATE"/"MASTER_RGBA.png"
D=R/"R8_USER_ANNOTATION_20261028"
OUT=R/"R9_EDGE_SEMANTIC_AUDIT";OUT.mkdir(exist_ok=True)
authority=json.loads((D/"R8_USER_ANNOTATION_AUTHORITY.json").read_text(encoding="utf8"))
master=np.asarray(Image.open(S).convert("RGBA"))
rgb=master[:,:,:3].copy()
gray=cv2.cvtColor(rgb,cv2.COLOR_RGB2GRAY)
sx=cv2.Sobel(gray,cv2.CV_32F,1,0,ksize=3)
sy=cv2.Sobel(gray,cv2.CV_32F,0,1,ksize=3)
edge=np.sqrt(sx*sx+sy*sy)
# Use 96th percentile of all positive gradients as strong boundary threshold, diagnostic not artifact gate
threshold=float(np.percentile(edge,96))
kern=np.ones((3,3),np.uint8)
findings=[]
canvas=Image.new("RGB",(560*2,18+len(authority["user_red"])*126),(21,24,29))
draw=ImageDraw.Draw(canvas)
draw.text((14,3),"R9 | source pixel vs alpha 4x crop: left SOURCE, right MASK ON SOURCE (MAGENTA) | not a human boundary truth",fill="white")
for i,item in enumerate(authority["user_red"]):
 path=D/(item["id"]+"_"+item["name"]+"_SAM2_SOURCE_PAR.png")
 mask=np.asarray(Image.open(path).convert("RGBA"))[:,:,3]>0
 n,labels,stats,_=cv2.connectedComponentsWithStats(mask.astype("uint8"),8)
 comps=sorted([int(stats[k,cv2.CC_STAT_AREA]) for k in range(1,n)],reverse=True)
 area=int(mask.sum())
 y,x=np.where(mask)
 bounds=[int(x.min()),int(y.min()),int(x.max())+1,int(y.max())+1] if area else None
 eroded=cv2.erode(mask.astype("uint8"),kern)>0
 outline=mask & ~eroded
 dil=cv2.dilate(mask.astype("uint8"),kern)>0
 around=dil & ~mask
 strong=float((edge[outline]>=threshold).mean()) if outline.any() else 0
 score=float(edge[outline].mean()) if outline.any() else 0
 # Risk hints, not evidence of an error:
 # if tiny component count many, or mask is greater than annotated box by large fraction.
 x1,y1,x2,y2=item["box"]
 box=np.zeros_like(mask);box[y1:y2,x1:x2]=True
 outside=int((mask&~box).sum())
 full_bbox_area=(bounds[2]-bounds[0])*(bounds[3]-bounds[1]) if bounds else 0
 fill=area/max(1,full_bbox_area)
 # Conservative score-based review flag
 flags=[]
 if len(comps)>4:flags.append("MANY_DISCONNECTED_COMPONENTS")
 if len(comps)>1 and sum(comps[1:])>area*.04:flags.append("DISCONNECTED_FRAGMENT_4PCT")
 if outside>area*.02:flags.append("OUTSIDE_ANNOTATED_BOX_2PCT")
 if fill<.20:flags.append("VERY_LOW_BBOX_FILL")
 if strong<.10:flags.append("LOW_IMAGE_EDGE_SUPPORT_WARNING")
 x0=max(0,x1-12);y0=max(0,y1-12);x3=min(544,x2+12);y3=min(416,y2+12)
 crop=Image.fromarray(rgb).crop((x0,y0,x3,y3)).convert("RGB")
 overlay=rgb.copy()
 overlay[mask,:]=(overlay[mask,:].astype("float32")*.55+np.array([255,22,180])*.45).astype(np.uint8)
 # magenta boundary
 overlay[outline]=(255,45,198)
 crop_overlay=Image.fromarray(overlay).crop((x0,y0,x3,y3)).convert("RGB")
 scale=min(4, max(1,500//max(crop.size[0],crop.size[1])))
 small_size=(int(crop.size[0]*scale),int(crop.size[1]*scale))
 # Contain 550x104 without distorting raw geometry 
 cell_y=18+i*126
 draw.text((8,cell_y),f"{item['id']} {item['name']} {area}px comps={len(comps)} edgeStrong={strong:.1%} flags={','.join(flags) or 'NONE'}",fill=(225,225,230))
 y_start=cell_y+15
 max_h=106
 thumb=crop.resize((min(500,small_size[0]),min(max_h,small_size[1])),Image.Resampling.NEAREST)
 thumb2=crop_overlay.resize(thumb.size,Image.Resampling.NEAREST)
 canvas.paste(thumb,(12,y_start));canvas.paste(thumb2,(560,y_start))
 findings.append({"id":item["id"],"kind":item["kind"],"alpha_px":area,"bbox_alpha":bounds,
  "components":len(comps),"component_sizes_desc":comps[:12],
  "annotated_box":item["box"],"alpha_px_outside_annotated_box":outside,
  "bbox_fill_ratio":round(fill,4),
  "source_high_gradient_boundary_ratio":round(strong,4),
  "boundary_mean_sobel":round(score,2),"boundary_high_grad_threshold":round(threshold,2),
  "flags":flags,"visual_grade":"NOT_APPROVED"})
out=OUT/"R9_8_RED_SOURCE_ALPHA_BOUNDARY_REVIEW.png";canvas.save(out)
data={
 "status":"R9_OBJECT_EDGE_INDEPENDENT_RISK_AUDIT_ONLY_ART_HOLD",
 "strong_gradient_cutoff":round(threshold,2),
 "source_master_dims":[544,416],
 "object_count":len(findings),"review_flagged_objects":[x["id"] for x in findings if x["flags"]],
 "objects_with_disconnected_fragments":sum(x["components"]>1 for x in findings),
 "all_red_human_art_approved":False,
 "limitations":["Gradient edges sometimes texture edges inside pixel art, not only object boundaries",
   "User colorized annotated 548x400 reference was not precisely registered to 544x416 source",
   "Strict alpha RGB provenance is separate from true object segmentation quality"],
 "objects":findings
}
(OUT/"R9_EDGE_RISK_AUDIT.json").write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding="utf8")
print("R9_EDGE_AUDIT",json.dumps({"objects":len(findings),"flagged":data["review_flagged_objects"],"disconnected":data["objects_with_disconnected_fragments"]}),flush=True)