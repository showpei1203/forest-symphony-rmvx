#!/usr/bin/env python3
"""Compare ONLY native Godot 4.7.2 framebuffers. Original A33 and new A34, same scene/viewport.
Never use this metric as final art acceptance.
"""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np,json,hashlib
r=Path(__file__).resolve().parents[1]
a=np.array(Image.open(r/'qa_a34/A34_NATIVE_A33_HOUSE_BASELINE_1280x928.png').convert('RGB'))
b=np.array(Image.open(r/'qa_a34/A34_NATIVE_NEW_HOUSES_1280x928.png').convert('RGB'))
assert a.shape==b.shape==(928,1280,3)
# Bounds are fully enveloping old and new house image envelopes. Includes 3px sprite fringe reserve.
roi=[(135,118,440,432),(916,128,1180,445)]
mask=np.zeros(a.shape[:2],dtype=bool)
for x0,y0,x1,y1 in roi:mask[y0:y1,x0:x1]=True
change=np.any(a!=b,axis=2)
changed=int(change.sum());outside=int((change&~mask).sum())
assert changed>1000 and outside==0,(changed,outside)
num=[int(change[y0:y1,x0:x1].sum()) for x0,y0,x1,y1 in roi]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
result={'engine':'Godot 4.7.2 native llvmpipe OpenGL','art_status':'HOLD','new_scene':'a34_groundfirst_full_houses_scene.tscn','source':'two independent generated full transparent house RGBA sprites, not image split','pixels_changed_full_scene':changed,'pixels_changed_outside_union_houses':outside,'per_house_changes':num,'native_before_sha':sha(r/'qa_a34/A34_NATIVE_A33_HOUSE_BASELINE_1280x928.png'),'native_after_sha':sha(r/'qa_a34/A34_NATIVE_NEW_HOUSES_1280x928.png'),'ground_sha':'3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000','roi':roi,'note':'The visual change is confined to the two house ROIs. This does not prove art approval or door placement.'}
(r/'qa_a34/A34_NATIVE_DIFF_QA.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
ft=ImageFont.truetype(font,17)
# Compare 2 house ROIs using exact unresampled 1x pixel scenes; no manual re-compositing.
cols=[]
for j,(x0,y0,x1,y1) in enumerate(roi):
    for image,name in [(a,'A33 previous house'),(b,'A34 new independent house')]:
        crop=Image.fromarray(image[y0:y1,x0:x1],'RGB')
        canvas=Image.new('RGB',(345,360),(22,31,44))
        d=ImageDraw.Draw(canvas)
        d.text((12,10),f'{name}  #{j+1}',font=ft,fill=(246,238,215))
        # View 1x crop in consistent 315x315 viewport, no resize; checker edge only.
        canvas.paste(crop,((345-crop.width)//2,35))
        cols.append(canvas)
combo=Image.new('RGB',(690,720),(22,31,44))
for i,img in enumerate(cols):combo.paste(img,((i%2)*345,(i//2)*360))
combo.save(r/'qa_a34/A34_NATIVE_HOUSE_AB_1X.png',optimize=True)
print('A34 side-by-side',r/'qa_a34/A34_NATIVE_HOUSE_AB_1X.png')
