from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
r=Path(__file__).resolve().parent
items=[("S8 baseline","baseline_stage8"),("S9 bands","candidates/bands"),("S9 clusters","candidates/clusters"),("S9 too bright (fail)","candidates/clusters_too_bright")]
W,H=544,416
montage=Image.new("RGB",(W*3,H+36),(28,36,44))
dr=ImageDraw.Draw(montage)
alpha=[]
metrics=[]
for i,(title,dirn) in enumerate(items):
 p=r/dirn
 comp=Image.open(p/"COMPOSITE_PREVIEW.png").convert("RGB")
 par=Image.open(p/"PAR.png").convert("RGBA")
 g=Image.open(p/"GROUND.png").convert("RGB")
 qa=json.loads((p/"QA_REPORT.json").read_text(encoding="utf-8"))
 aa=np.asarray(par.getchannel("A"))
 alpha.append(aa)
 if i<3:
  montage.paste(comp,(i*W,36))
  dr.text((i*W+10,12),title,fill=(245,244,226))
 tree_zones=[(32,18,160,204),(408,18,520,206)]
 patches=[np.asarray(comp.crop(rect)).reshape(-1,3) for rect in tree_zones]
 # report descriptive luminance average and dark share in canopy regions, mixed with background.
 intensity=np.concatenate([p.mean(axis=1) for p in patches])
 metrics.append(dict(version=title,par_border=int(qa["par_border_nonzero"]),ground_mode=qa["ground_mode"],par_mode=qa["par_mode"],full_diff=int(qa["full_vs_alpha_composite_differing_pixel_count"]),mean_zone_luma=round(float(intensity.mean()),3),zone_dark_pct=round(100*float((intensity<89).mean()),2),tree_alpha_nonzero=int(sum(np.sum(aa[y0:y1,x0:x1]>0) for x0,y0,x1,y1 in tree_zones))))
assert len(metrics)==4
for i in range(1,4):
 metrics[i]["par_alpha_changed_vs_stage8"]=int(np.count_nonzero(alpha[0]!=alpha[i]))
 assert metrics[i]["par_alpha_changed_vs_stage8"]==0,"Color style destroyed PAR alpha geometry"
montage.save(r/"out/STAGE9_STYLE_ABC_1X.png")
# diagnostic comparison: at native 1x source; zoom only for readability.
zoom=Image.new("RGB",(4*320,320+42),(28,35,42))
D=ImageDraw.Draw(zoom)
for i,(title,path) in enumerate(items):
 im=Image.open(r/path/"COMPOSITE_PREVIEW.png").convert("RGB")
 crop=im.crop((34,30,142,196))
 crop=crop.resize((208,320),Image.Resampling.NEAREST)
 x=i*320+48
 zoom.paste(crop,(x,42))
 D.text((i*320+8,12),title,fill=(247,246,221))
zoom.save(r/"out/STAGE9_CROWN_DETAIL_4WAY.png")
report={"source":"Native Godot 544x416 same world/camera, self-authored 3D shader on CC0 model, no reverse-cut or full-image blur","images":{"main":"out/STAGE9_STYLE_ABC_1X.png","diagnostic":"out/STAGE9_CROWN_DETAIL_4WAY.png"},"results":metrics,"alpha_preserved_exact":all(row.get("par_alpha_changed_vs_stage8",0)==0 for row in metrics),"selected":"clusters","selection_note":"relative color harmony and leaf clump depth improvement, still requires human art review","formal_seal":False}
(r/"out/STAGE9_ART_COMPARE_QA.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding="utf-8")
print(json.dumps(report,indent=2,ensure_ascii=False))