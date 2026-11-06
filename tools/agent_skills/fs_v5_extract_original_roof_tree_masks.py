"""V5 canonical original FS per-source roof/canopy runtime witness assets.
Only uses original ground3 and par3 exact-alpha source pixels.
Outputs source-region candidates, exact par witness, RGB-registered native overlay, and 32px actor sample positions.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,hashlib,json,shutil
R=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\FS_CANONICAL_OCCLUDER_WITNESSES_V5_20261107")
if R.exists():raise SystemExit("FAIL CLOSED: destination exists")
R.mkdir(parents=True)
FS=Path(r"E:\遊戲專案開發\三大項目現行專案\FS project")
G=FS/"Graphics/Parallaxes/ground3.png"
P=FS/"Overlays/par3.png"
rgb=np.asarray(Image.open(G).convert("RGB"))
original=np.asarray(Image.open(P).convert("RGBA"))
W,H=1280,928
assert rgb.shape==(H,W,3) and original.shape==(H,W,4)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
bounds={
  "NW_HOUSE_ROOF":(170,104,358,295),
  "EAST_TREE_CANOPY":(390,0,575,200)
}
all_mask=np.zeros((H,W),dtype=bool)
metrics={}
for n,(x0,y0,x1,y1) in bounds.items():
    roi=(original[y0:y1,x0:x1,3]>127)
    n_pix=int(roi.sum())
    if n_pix<2000:raise RuntimeError(n+" source mask too small "+str(n_pix))
    all_mask[y0:y1,x0:x1]|=roi
    exact=np.zeros((y1-y0,x1-x0,4),dtype=np.uint8)
    exact[roi]=original[y0:y1,x0:x1][roi]
    normalized=exact.copy()
    normalized[roi,:3]=rgb[y0:y1,x0:x1][roi]
    Image.fromarray(exact,"RGBA").save(R/(n+"_ORIGINAL_PAR_EXACT_RGBA.png"))
    Image.fromarray(normalized,"RGBA").save(R/(n+"_SAME_RGB_REGISTERED_RGBA.png"))
    annot=Image.fromarray(rgb[y0:y1,x0:x1]).convert("RGBA")
    overlay=np.zeros_like(normalized)
    overlay[roi]=[240,60,20,112]
    annot=Image.alpha_composite(annot,Image.fromarray(overlay))
    annot.save(R/(n+"_SOURCE_ALPHA_WITNESS.png"))
    metrics[n]={"bbox":[x0,y0,x1,y1],"source_original_alpha_pixels":n_pix,
      "opaque_original_rgb_same_ground":round(float(np.all(original[y0:y1,x0:x1,:3][roi]==rgb[y0:y1,x0:x1][roi],axis=1).mean()),6)}
# full RGB matching native two source-only benchmark overlay
new=np.zeros((H,W,4),dtype=np.uint8)
new[all_mask,:3]=rgb[all_mask]
new[all_mask,3]=255
P_out=R/"PAR50_2CANONICAL_WITNESSES_REGISTERED.png"
Image.fromarray(new,"RGBA").save(P_out)
G_out=R/"RUNTIME_FULL_SCENE_GROUND_FROM_ORIGINAL_GROUND3.png"
shutil.copy2(G,G_out)
assert sha(G)==sha(G_out)
assert int(all_mask.sum())>5000
# Generate 32px grid candidate centers and actor-body intersections, choose from declared per-roi area.
positions=[]
for y in range(29):
 for x in range(40):
  cx=x*32+16;fy=y*32+32
  roi=all_mask[max(0,fy-32):min(H,fy),max(0,cx-12):min(W,cx+12)]
  if roi.shape==(32,24):
   frac=float(roi.mean())
   positions.append({"tile":[x,y],"foot":[cx,fy],"alpha_actor_body_overlap":round(frac,4)})
for n,b in bounds.items():
 x0,y0,x1,y1=b
 inside=[p for p in positions if x0+20<p["foot"][0]<x1-20 and y0+48<p["foot"][1]<y1-12]
 inside=sorted(inside,key=lambda x:x["alpha_actor_body_overlap"],reverse=True)
 print("TOP_SAMPLES",n,inside[:9],flush=True)
 if not inside or inside[0]["alpha_actor_body_overlap"]<.28:raise RuntimeError("no significant occlusion sample "+n)
 metrics[n]["top_sample_candidates"]=inside[:9]
# choose two tiles uniquely and a clear control near road
roof=metrics["NW_HOUSE_ROOF"]["top_sample_candidates"][0]
tree=metrics["EAST_TREE_CANOPY"]["top_sample_candidates"][0]
clear_candidates=[p for p in positions if 7<=p["tile"][0]<=15 and 8<=p["tile"][1]<=12 and p["alpha_actor_body_overlap"]<.002]
if not clear_candidates:raise RuntimeError("no clear sample")
clear=min(clear_candidates,key=lambda x:abs(x["tile"][0]-11)+abs(x["tile"][1]-10))
samples={"ROOF_OCCLUSION":roof,"TREE_OCCLUSION":tree,"CLEAR_NEGATIVE_CONTROL":clear}
qa={"stage":"FS_CANONICAL_FS_GROUND3_PAR3_PER_SOURCE_OCCLUDER_WITNESSES_V5",
"original_ground_sha256":sha(G),"original_par_sha256":sha(P),
"source_regions":metrics,"samples":samples,
"total_runtime_par_opaque_pixels":int(all_mask.sum()),
"total_alpha_coverage":round(float(all_mask.mean()),6),
"source_par_witness_exact":True,"normalized_opaque_rgb_equal_original_ground":bool(np.all(new[all_mask,:3]==rgb[all_mask])),
"runtime_master_equal_under_normalized_par":True,
"source_modified":False,
"restriction":"Canonical extraction/reference only; two manually defined ROI masks do not constitute standalone extracted building or whole-tree art assets.",
"native_gameexe":"NOT_YET_RUN","formal_seal":"NO"}
(R/"SOURCE_WITNESS_MANIFEST.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
# contact images actual known source exact pixels, full frame not concept art
contact=Image.new("RGB",(544*3,416),(22,26,30))
crop=(0,0,544,416)
im=Image.fromarray(rgb).crop(crop).convert("RGB")
contact.paste(im,(0,0))
normal=Image.fromarray(new).crop(crop)
layer=Image.alpha_composite(im.convert("RGBA"),normal)
contact.paste(layer.convert("RGB"),(544,0))
heat=np.zeros((416,544,4),dtype=np.uint8)
heat[new[:416,:544,3]>0]=[255,67,36,118]
contact.paste(Image.alpha_composite(im.convert("RGBA"),Image.fromarray(heat)).convert("RGB"),(1088,0))
contact.save(R/"ORIGINAL_FS_SOURCE_ROOF_AND_TREE_3WAY_544.png")
print("WROTE",R,"SAMPLES",samples,"COVERAGE",qa["total_alpha_coverage"],flush=True)