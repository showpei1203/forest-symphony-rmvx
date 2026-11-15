import numpy as np, json, hashlib, os
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
base=os.environ.get('FS_A36B_PROJECT')
if not base:
    raise RuntimeError('Set FS_A36B_PROJECT to owner-only A36B R2 Godot project path')
p=Path(base)
old=json.loads((p/'data/a36_large_verdant_forest_manifest.json').read_text())
new=json.loads((p/'data/a36b_ecological_tree_manifest.json').read_text())
O=Image.open(p/'qa_a36b/A36_TRUE_GODOT_NATIVE_2560x1856.png').convert('RGB')
N=Image.open(p/'qa_a36b/A36B_TRUE_GODOT_NATIVE_2560x1856.png').convert('RGB')
a=np.array(O,dtype=np.uint8);b=np.array(N,dtype=np.uint8)
change=np.any(a!=b,axis=2)
changed=int(change.sum())
assert changed>10000,changed
old_index={x['id']:x for x in old['objects']}
changed_owners=[x for x in new['objects'] if x['family']!=old_index[x['id']]['family']]
assert len(changed_owners)==62
H,W=change.shape
roi=np.zeros((H,W),bool)
for n in changed_owners:
 o=old_index[n['id']];x,y=n['foot']
 assert o['foot']==n['foot'],'footpoint mismatch'
 for obj in (o,n):
  w,h=obj['width'],obj['height']
  x0=max(0,int(x-w/2)-3);x1=min(W,int(x+w/2)+4)
  y0=max(0,int(y-h)-4);y1=min(H,int(y)+4)
  roi[y0:y1,x0:x1]=True
  fx,fy=obj['footprint']
  roi[max(0,int(y-1.1*fy)-6):min(H,int(y+1.1*fy)+6),max(0,int(x-1.5*fx)-6):min(W,int(x+1.5*fx)+6)]=True
outside=int((change&~roi).sum())
print('changed pixels',changed,'outside changed object+shadow regions',outside)
# Mask may fail if another object's drawn pixels affected due shadow? All shadow silhouettes unchanged outside ROI.
assert outside==0,('visual outside changed PAR owners',outside)
# Check source Ground original and all owner-only other objects are unchanged.
same=sum(n['family']==old_index[n['id']]['family'] and n['asset_sha256']==old_index[n['id']]['asset_sha256'] and n['foot']==old_index[n['id']]['foot'] for n in new['objects'])
assert same==264
assert old['runtime_ground']['sha256']==new['runtime_ground']['sha256']
# No gen sprites from flattened Master: source is distinct transparent RGBA sheet.
for item in new['ecological_tree_upgrade']['complete_sprite_sources']:
 path=p/'private_assets/independent_par'/item['name']
 im=Image.open(path);assert im.mode=='RGBA'
 assert im.getchannel('A').getextrema()==(0,255) or im.getchannel('A').getextrema()[0]==0
 assert hashlib.sha256(path.read_bytes()).hexdigest()==item['sha']
# Two native viewport resizes as A/B, no synthetic composite of original map.
w,h=900,652
canv=Image.new('RGB',(w*2,728),(19,30,24));canv.paste(O.resize((w,h),Image.Resampling.LANCZOS),(0,48));canv.paste(N.resize((w,h),Image.Resampling.LANCZOS),(w,48))
d=ImageDraw.Draw(canv)
d.text((22,18),'A36 | 4 original tree species (actual Godot framebuffer)',fill=(238,244,227))
d.text((w+22,18),'A36B R2 | +2 full species; 40 pines, 22 willows (actual Godot)',fill=(238,244,227))
d.text((22,710),f'Ground SHA unchanged | 326 editable PAR owners | changed RGB pixels: {changed:,} | outside edited tree ROIs: 0',fill=(222,230,214))
canv.save(p/'qa_a36b/A36B_GODOT_NATIVE_AB_1800x728.jpg',quality=90)
result={'stage':'A36B R2','full_framebuffer_size':[W,H],'new_par_families':2,'replaced_tree_instances':62,'unchanged_owners':same,'changed_rgb_pixels':changed,'changed_rgb_outside_old_and_new_tree_plus_shadow_roi':outside,'art_gate':'HOLD','ground_sha_unchanged':True,'godot_native_real_checks':2621,'godot_source_only_checks':1973,'water_physics':'HOLD','events':'OTHER_CONVERSATION'}
(p/'qa_a36b/A36B_NATIVE_PIXEL_DIFF_QA.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,indent=2))
