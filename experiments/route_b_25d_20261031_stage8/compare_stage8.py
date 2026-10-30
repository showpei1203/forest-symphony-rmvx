from PIL import Image, ImageDraw, ImageChops
from pathlib import Path
import numpy as np,json,hashlib
r=Path(__file__).resolve().parent
stage7=r/"baseline_stage7/COMPOSITE_PREVIEW.png"
caseA=r/"candidates/A_LEFT_PALE/COMPOSITE_PREVIEW.png"
final=r/"out/COMPOSITE_PREVIEW.png"
labels=["STAGE 7  | low-detail trees","STAGE 8 A  | first detailed oak","STAGE 8 C  | two detailed oaks"]
sources=[stage7,caseA,final]
images=[Image.open(p).convert("RGB") for p in sources]
assert all(im.size==(544,416) for im in images)
canvas=Image.new("RGB",(544*3,452),(29,35,42))
D=ImageDraw.Draw(canvas)
for i,(name,im) in enumerate(zip(labels,images)):
 canvas.paste(im,(i*544,36))
 D.text((i*544+11,12),name,fill=(246,248,227))
canvas.save(r/"out/STAGE8_TREE_ABC_1X.png")
# Strictly compare same coordinate frames. Changes should remain in tree zones.
old=np.asarray(images[0]).astype('int16')
now=np.asarray(images[2]).astype('int16')
diff=np.any(old!=now,axis=2)
zones={
 "WEST_TREE_ZONE":(25,15,145,205),
 "EAST_TREE_ZONE":(410,20,530,205),
 "COTTAGE_CORE":(180,110,385,285),
 "GROUND_PATH":(215,292,328,410),
}
metrics=[]
for name,(x0,y0,x1,y1) in zones.items():
 patch=diff[y0:y1,x0:x1]
 metrics.append(dict(region=name,pixels=int(patch.size),changed=int(np.sum(patch)),change_ratio=round(float(np.mean(patch)),6)))
cv=Image.new("RGB",images[0].size,(19,34,41))
d=ImageDraw.Draw(cv)
base=Image.fromarray(np.asarray(images[0])).copy()
pix=np.asarray(base).copy()
pix[diff]=[255,78,100]
Image.fromarray(pix).save(r/"out/STAGE8_CHANGED_PIXEL_MAP.png")
# zoom the actual left tree area for pixel geometry inspection; NN only in visual QA, not production layers
crop1=images[0].crop((25,15,145,205)).resize((360,570),Image.Resampling.NEAREST)
crop2=images[2].crop((25,15,145,205)).resize((360,570),Image.Resampling.NEAREST)
large=Image.new("RGB",(720,606),(29,36,44))
large.paste(crop1,(0,36)); large.paste(crop2,(360,36))
Ld=ImageDraw.Draw(large)
Ld.text((10,12),"STAGE 7 | original crown",fill=(246,245,218))
Ld.text((370,12),"STAGE 8 | native leaf geometry",fill=(246,245,218))
large.save(r/"out/STAGE8_LEFT_CROWN_3X_DIAGNOSTIC.png")
from shutil import copyfile
copyfile(r/"out/STAGE6_ACTOR_OCCLUSION_6PANEL.png",r/"out/STAGE8_ACTOR_OCCLUSION_6PANEL.png")
copyfile(r/"out/STAGE6_ACTOR_OCCLUSION_QA.json",r/"out/STAGE8_ACTOR_OCCLUSION_QA.json")
audit={
 "native_res":[544,416],
 "stage7_composite_sha256":hashlib.sha256(stage7.read_bytes()).hexdigest(),
 "stage8_composite_sha256":hashlib.sha256(final.read_bytes()).hexdigest(),
 "region_comparison":metrics,
 "image_paths":["out/STAGE8_TREE_ABC_1X.png","out/STAGE8_LEFT_CROWN_3X_DIAGNOSTIC.png","out/STAGE8_CHANGED_PIXEL_MAP.png"],
 "critical_caveat":"Only a visual and pixel-difference probe. Difference density is not a quality score. FS artwork remains not approved.",
 "formal_seal":False
}
(r/"out/STAGE8_ART_COMPARE_QA.json").write_text(json.dumps(audit,indent=2),encoding="utf-8")
print(json.dumps(audit,indent=2))