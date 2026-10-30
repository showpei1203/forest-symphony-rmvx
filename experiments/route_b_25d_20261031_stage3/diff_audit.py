from PIL import Image, ImageDraw, ImageChops
from pathlib import Path
import numpy as np, json, collections
root=Path(__file__).resolve().parent/'out'
a=np.asarray(Image.open(root/'COMPOSITE_PREVIEW.png').convert('RGB'),dtype=np.int16)
b=np.asarray(Image.open(root/'SCENE_FULL.png').convert('RGB'),dtype=np.int16)
err=np.max(abs(a-b),axis=2)
mask=err>0
ys,xs=np.where(mask)
report={"differing_pixels":int(mask.sum()),"bbox_x0_y0_x1_y1":[int(xs.min()),int(ys.min()),int(xs.max()),int(ys.max())],"errors_gt_5":int(np.sum(err>5)),"errors_gt_20":int(np.sum(err>20)),"row_bands":{},"col_bands":{}}
for y in range(0,416,52):report["row_bands"][f"{y}:{y+52}"]=int(np.sum(mask[y:y+52,:]))
for x in range(0,544,68):report["col_bands"][f"{x}:{x+68}"]=int(np.sum(mask[:,x:x+68]))
vis=Image.open(root/'SCENE_FULL.png').convert('RGB')
m=np.asarray(vis).copy()
m[mask]=np.array([255,36,65],dtype=np.uint8)
Image.fromarray(m).save(root/'COMPOSITE_DIFF_HIGHLIGHT.png')
print(json.dumps(report,indent=2))
(root/'COMPOSITE_DIFF_REPORT.json').write_text(json.dumps(report,indent=2),encoding="utf-8")