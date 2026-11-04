from pathlib import Path
from PIL import Image,ImageDraw
import json, numpy as np
R=Path(r"E:\FS_STAGE16_A36G_R4_ALL_REGION_FORESTS_20261104")
orig=json.loads((R/"R4_BASE_SCENE_MANIFEST.json").read_text("utf8"))
new=json.loads((R/"A36G_R4_SCENE_MANIFEST.json").read_text("utf8"))
kept={o["id"] for o in new["objects"]}
lost=[o for o in orig["objects"] if o["type"]=="tree" and o.get("blocking") and o["id"] not in kept]
par=np.array(Image.open(R/"A36G_R4_PAR50_RGBA_1280x928.png").convert("RGBA"))
img=Image.open(R/"A36G_R4_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB")
panel=img.copy()
draw=ImageDraw.Draw(panel)
res=[]
for o in lost:
 x,y=o["foot"];iy=max(0,min(927,y));ix=max(0,min(1279,x))
 center=int(par[iy,ix,3])
 block=par[max(0,iy-16):min(928,iy+17),max(0,ix-16):min(1280,ix+17),3]
 fraction=float(np.mean(block>100))
 # Forest alpha coverage is a proxy for visual blocker; it is NOT proof of root semantic match.
 line={"id":o["id"],"foot":[x,y],"tile":[x//32,y//32],
       "center_alpha":center,"tile_alpha_fraction":round(fraction,3)}
 res.append(line)
 if center<90 or fraction<.38:
  draw.ellipse((x-7,y-7,x+7,y+7),outline=(242,59,48),width=2)
 else:
  draw.point((x,y),fill=(255,255,91))
bad=[x for x in res if x["center_alpha"]<90 or x["tile_alpha_fraction"]<.38]
panel.resize((640,464),Image.Resampling.NEAREST).save(R/"A36G_R4_ROOT_COVERAGE_AUDIT_640.png",optimize=True)
report={"source_stage":orig["stage"],"r4_stage":new["stage"],
 "removed_root_anchors":len(res),"potential_invisible_root_blockers":len(bad),
 "bad_cases":bad[:200],"all":res,
 "diagnostic_caveat":"Alpha coverage is necessary but insufficient: actual trunk/root geometry still needs visual QA",
 "action":"RESTORE_OR_REFINE" if bad else "CHECK_NATIVE_ACTOR_AUDIT",
 "formal_seal":"NO"}
(R/"A36G_R4_ROOT_COVERAGE_QA.json").write_text(json.dumps(report,indent=2,ensure_ascii=False),"utf8")
print(json.dumps({"removed_roots":len(res),"potential_invisible":len(bad),
 "cases":[x["foot"] for x in bad[:30]]},ensure_ascii=False,indent=2))
