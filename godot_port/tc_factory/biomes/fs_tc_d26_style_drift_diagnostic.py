from PIL import Image
from scipy.ndimage import label,find_objects
from pathlib import Path
import numpy as np,hashlib,json,zipfile,os
p=Path('/mnt/data/TC_D26_ART_FIRST_WORK')
d24=Image.open('/mnt/data/TC_D24_ART_FIRST_WORK/D24_NEW_INDEPENDENT_NATIVE_RGBA_SOURCE_1474x1067.png').convert('RGBA')
a=np.array(d24.getchannel('A'))
l,n=label(a>32,np.ones((3,3),np.uint8)); counts=np.bincount(l.ravel()); bb=find_objects(l)
rects=[]
for i,z in enumerate(bb,1):
 if z and counts[i]>=1000:
  ys,xs=z;rects.append((xs.start,ys.start,xs.stop,ys.stop))
assert len(rects)==11
qa=json.loads((p/'D26_ART_QA.json').read_text())
for i,name in [(0,'FORGE'),(2,'IRON_BRIDGE')]:
 old=np.asarray(d24.crop(rects[i]))
 new=np.asarray(Image.open(p/f'D26_SOURCE_NEW_{name}_1X_RGBA.png').convert('RGBA'))
 def metric(b):
  pix=b[b[:,:,3]>128,:3]
  return {'visible_alpha_gt128':int(len(pix)),'unique_visible_RGB':int(len(np.unique(pix,axis=0))),'unique_colors_per_1000_visible_pixels':round(float(len(np.unique(pix,axis=0)))*1000/len(pix),2)}
 qa.setdefault('STYLE_DIAGNOSTIC_NOT_FORMAL_ART_SCORE',{})[name]={'D24_reference':metric(old),'D26_new_manual_source':metric(new)}
for name in ['IRON_BRIDGE','FORGE','ORE_CRANE','SUPPLY_WORKSHOP']:
 arr=np.array(Image.open(p/f'D26_SOURCE_NEW_{name}_1X_RGBA.png').getchannel('A'))
 n5=int((arr[:5,:]>224).sum()+(arr[-5:,:]>224).sum()+(arr[5:-5,:5]>224).sum()+(arr[5:-5,-5:]>224).sum())
 qa['STYLE_DIAGNOSTIC_NOT_FORMAL_ART_SCORE'][name]={**qa['STYLE_DIAGNOSTIC_NOT_FORMAL_ART_SCORE'].get(name,{}),'SOURCE_FIVE_PX_HIGH_ALPHA_EDGE_PIXELS':n5}
qa['D26_VISUAL_OUTCOME']='REJECT_DUE_TO_LOW_TEXTURE_FIDELITY_AND_STYLE_MISMATCH_WITH_D17_GROUND_AND_D24_PROPS'
qa['SOURCE_NATIVE_ALPHA']='PASS_FOR_FOUR_NEW_MANUAL_SPRITES_NOT_AI_GENERATED_INDEPENDENT_PLATE'
qa['IMAGE_GEN_PREVIOUS_ATTEMPTS']='REJECT: RGB checkerboard isolated oversize bridge, mixed Ground Master with UI footer, mixed full Master with Ground'
qa['GODOT_NATIVE']='NOT_RUN_FAIL_FAST_ON_ART_SOURCE_MISMATCH'
qa['next_method']='Use verified constraint-driven art tool for native-resolution 1x compact world objects with D24 style reference; do not further programmatically repaint or resize D24 originals'
(p/'D26_ART_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False)+'\n')
print(json.dumps(qa['STYLE_DIAGNOSTIC_NOT_FORMAL_ART_SCORE'],indent=2))
