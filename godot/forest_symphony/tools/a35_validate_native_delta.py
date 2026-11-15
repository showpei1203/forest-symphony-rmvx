from pathlib import Path
from PIL import Image,ImageChops,ImageDraw,ImageFont
import json, hashlib, numpy as np
root=Path('/mnt/data/fs_godot_a35')
base=Image.open(root/'qa_a35/A35_NATIVE_BASELINE_A34_1280x928.png').convert('RGB')
new=Image.open(root/'qa_a35/A35_NATIVE_4FAMILY_8TREES_1280x928.png').convert('RGB')
assert base.size==new.size==(1280,928)
mask=np.any(np.asarray(base)!=np.asarray(new),axis=-1)
y,x=np.nonzero(mask)
changed=int(mask.sum())
m=json.loads((root/'data/a35_independent_tree_family_manifest.json').read_text())
oldm=json.loads((root/'data/a34_groundfirst_full_houses_manifest.json').read_text())
old={o['id']:o for o in oldm['objects']}
allowed=np.zeros((928,1280),bool)
for obj in m['a35_tree_gate']['replacements']:
 o_old=old[obj['instance_id']]
 o_new=next(x for x in m['objects'] if x['id']==obj['instance_id'])
 for o in [o_old,o_new]:
  xx,yy=o['x'],o['y']; w,h=o['w'],o['h'];
  allowed[max(0,yy):min(928,yy+h),max(0,xx):min(1280,xx+w)]=True
outlier=int(np.count_nonzero(mask&~allowed))
assert outlier==0, f'{outlier} changed pixels beyond 8 changed source object rectangles'
new_ground=root/'private_assets/ground_only.png'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(new_ground)=='3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000'
assert sha(new_ground)==sha(Path('/mnt/data/fs_godot_a34/private_assets/ground_only.png'))
# Show real native screenshots, not new raster scene outputs.
W,H=1280,928
canvas=Image.new('RGB',(1280,1115),'#f4f5ef')
canvas.paste(base.resize((630,457),Image.Resampling.NEAREST),(4,34))
canvas.paste(new.resize((630,457),Image.Resampling.NEAREST),(646,34))
D=ImageDraw.Draw(canvas)
D.text((10,11),'A34 BASELINE: ORIGINAL TREE MIX',fill='#143b26')
D.text((652,11),'A35: 8 FULL NEW SOURCE TREES',fill='#143b26')
boxes=[('LEFT FOREST', (0,130,280,555)),('TOP BORDER',(710,0,1040,280)),('RIGHT FOREST',(1040,280,1280,760)),('LOW LEFT',(0,565,340,905))]
for i,(label,b) in enumerate(boxes):
 x0=0 if i%2==0 else 650
 y0=520 if i<2 else 825
 # native 1x pixel crop scaled 0.8; preserve nearest-neighbor only.
 tile_new=new.crop(b)
 target=(610,260)
 tile_new.thumbnail(target,Image.Resampling.NEAREST)
 canvas.paste(tile_new,(x0+12,y0+24))
 D.text((x0+12,y0+4),label+' | A35 Godot source-only crop',fill='#143b26')
# Caption
D.text((12,1083),f'Godot 4.7.2 framebuffer A/B | changed {changed} pixels | outside changed-tree ROI 0 | ART HOLD',fill='#143b26')
canvas.save(root/'qa_a35/A35_GODOT_NATIVE_A34_VS_A35_ART_REVIEW.png')
qa={'stage':'A35','render_engine':'Godot 4.7.2 OpenGL llvmpipe real framebuffer','ground_sha256':sha(new_ground),'rgba_source_family_count':4,'changed_tree_instances':8,'scene_instances_total':146,'all_other_source_instances_unchanged':138,'native_difference_pixels':changed,'pixel_delta_outside_eight_tree_ROIS':outlier,'art_status':'HOLD','terrain_map_expansion_art_status':'NOT_BUILT'}
(root/'qa_a35/A35_NATIVE_VISUAL_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False)+'\n')
print(json.dumps(qa,indent=2,ensure_ascii=False))
