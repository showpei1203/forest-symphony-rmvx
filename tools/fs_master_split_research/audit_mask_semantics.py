#!/usr/bin/env python3
"""Conservative FS SAM2 mask QA: classify risk, never self-certify semantics."""
import argparse, json
from pathlib import Path
import cv2, numpy as np
from PIL import Image, ImageDraw
ap=argparse.ArgumentParser()
ap.add_argument("--candidate",required=True)
a=ap.parse_args(); out=Path(a.candidate)
d=json.loads((out/"PILOT_METRICS.json").read_text(encoding="utf-8"))
original=np.asarray(Image.open(out/"MASTER_RGBA.png").convert("RGB"))
ground=np.asarray(Image.open(out/"GROUND_TELEA_EXPERIMENT_ONLY.png").convert("RGB"))
union=np.asarray(Image.open(out/"UNION_MASK.png"))>0
h,w=union.shape; rgb=original
errors=[]; results=[]
viz=Image.fromarray(original.copy()); draw=ImageDraw.Draw(viz)
for o in d["objects"]:
 mask=(np.asarray(Image.open(out/o["mask_candidate"]))>0).astype(np.uint8)
 count, comps, stats, centroids=cv2.connectedComponentsWithStats(mask,connectivity=8)
 xs=[]
 for j in range(1,count):
  area=int(stats[j,cv2.CC_STAT_AREA])
  if area<20: continue
  xs.append({"area":area,"box":stats[j,:4].astype(int).tolist(),
             "centroid":[round(x,1) for x in centroids[j].tolist()]})
 xs=sorted(xs,key=lambda t:t["area"],reverse=True)
 ratio=0 if not xs else sum(e["area"] for e in xs[1:])/max(1,sum(e["area"] for e in xs))
 if len(xs)>1:errors.append(f"{o['id']}: {len(xs)-1} detached components >=20px")
 if ratio>=0.02:errors.append(f"{o['id']}: detached region accounts for {ratio:.1%}")
 for item in xs[1:]:
  x,y,ww,hh=item["box"]
  draw.rectangle((x,y,x+ww,y+hh),outline=(255,0,0),width=2)
 results.append({"id":o["id"],"sam_confidence":o["sam2_score"],"component_count_over_20":len(xs),
                 "detached_ratio_over_20":ratio,"components":xs[:12]})
 # SAM2 probability and geometric coherence are not proof of semantic correctness.
# Laplacian texture attenuation compared to one ring of known source (for illustration, not strict threshold).
kernel=cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(21,21))
outer=cv2.dilate(union.astype(np.uint8),kernel).astype(bool)&~union
lv0=cv2.Laplacian(cv2.cvtColor(rgb,cv2.COLOR_RGB2GRAY),cv2.CV_64F)
lv1=cv2.Laplacian(cv2.cvtColor(ground,cv2.COLOR_RGB2GRAY),cv2.CV_64F)
ref=float(lv0[outer].std()) if outer.any() else 0.
inside=float(lv1[union].std()) if union.any() else 0.
risk={
 "qa_result":"ART_HOLD",
 "reason":"Semantic classification, Ground-exclusive ownership, hidden Ground pixel art, par completeness unverified",
 "sam2_only_three_boxes":True,
 "component_risks":results,
 "pixel_gradient_std_outside_reference_ring":round(ref,3),
 "pixel_gradient_std_inside_telea_fill":round(inside,3),
 "texture_ratio_inside_vs_outer":round(inside/ref,4) if ref else None,
 "raw_recompose_diff":d["reconstruction_mismatched_pixels"],
 "warning":"0-diff recomposition is algebraic, NOT proof of mask correctness or hidden ground art quality",
 "violations":errors,
 "gates":{"mask_semantic_human_approval":False,"ground_exclusive_owner_independently_audited":False,
          "ground_fill_visual_quality":False,"all_non_ground_objects_covered":False,"vx_native_depth":False,
          "pixel_technical_reconstruction":d["reconstruction_mismatched_pixels"]==0,
          "misalignment_negative_test":d["negative_1px_shift_detected_pixels"]>0}
}
viz.save(out/"MASK_CONNECTED_COMPONENT_RISKS.png")
(out/"MASK_SEMANTIC_QA.json").write_text(json.dumps(risk,ensure_ascii=False,indent=2),encoding="utf-8")
print(json.dumps({"status":risk["qa_result"],"risks":errors,"texture_ratio":risk["texture_ratio_inside_vs_outer"],"objects":results},ensure_ascii=False)[:5800])