import json,numpy as np
from pathlib import Path
from PIL import Image
r=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
m=json.loads((r/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
scene=np.asarray(Image.open(r/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB"))
res=[]
for ob in m["objects"]:
 if ob["type"]!="tree":continue
 src=np.asarray(Image.open(r/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]).convert("RGBA"))
 x,y=ob["x"],ob["y"];h,w=src.shape[:2];x0=max(x,0);y0=max(y,0);x1=min(x+w,1280);y1=min(y+h,928)
 if x0>=x1 or y0>=y1:continue
 a=src[y0-y:y1-y,x0-x:x1-x]
 opaque=a[:,:,3]>220
 same=np.all(a[:,:,:3]==scene[y0:y1,x0:x1],axis=2)
 frac=float(same[opaque].mean()) if opaque.any() else 0
 res.append((round(frac,4),int(opaque.sum()),ob["id"],x,y,w,h,ob["filename"]))
res.sort(reverse=True)
print("VISIBLE_TOP_30")
for r in res[:30]:print(r)
print("HIDDEN_BOTTOM_15")
for r in res[-15:]:print(r)