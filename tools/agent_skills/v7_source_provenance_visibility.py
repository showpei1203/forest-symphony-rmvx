import json,numpy as np
from pathlib import Path
from PIL import Image
r=Path(r"E:\FS_STAGE16_A36G_R5_HOUSE_STYLE_UNIFICATION_20261104")
m=json.loads((r/"A36G_R5_SCENE_MANIFEST.json").read_text("utf8"))
master=np.asarray(Image.open(r/"A36G_R5_TRUE_GROUND_PLUS_PAR_1280x928.png").convert("RGB"))
for id in ["A36G_R5_COTTAGE_B_SINGLE_ROOF","tree_093","tree_010","tree_056","A36G_ELF_HOUSE_AND_WORKSHOP","tree_003"]:
 ob=next(o for o in m["objects"] if o["id"]==id)
 arr=np.asarray(Image.open(r/"SOURCE_INDEPENDENT_RGBA"/ob["filename"]).convert("RGBA"))
 x,y=ob["x"],ob["y"];w,h=ob["w"],ob["h"]
 x0=max(0,x);y0=max(0,y);x1=min(master.shape[1],x+w);y1=min(master.shape[0],y+h)
 sr=arr[y0-y:y1-y,x0-x:x1-x]
 mb=master[y0:y1,x0:x1]
 opaque=sr[:,:,3]>220
 identical=np.all(sr[:,:,:3]==mb,axis=2)
 close=np.max(np.abs(sr[:,:,:3].astype("int16")-mb.astype("int16")),axis=2)<4
 print(id,"total",int(opaque.sum()),"identical",round(float(identical[opaque].mean()),3) if opaque.sum() else -1,"within3",round(float(close[opaque].mean()),3) if opaque.sum() else -1,"bbox",ob["x"],ob["y"],ob["w"],ob["h"])