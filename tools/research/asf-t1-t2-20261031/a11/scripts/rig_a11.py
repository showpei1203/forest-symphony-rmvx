from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np, cv2, math, json, hashlib
root=Path('/mnt/data/A11_LAYERED_RIG')
a10=Path('/mnt/data/A10_SINGLE_MASTER_RIG')
W,H=96,112
hero=Image.open(a10/'T1_forest_scout/master_64x80.png').convert('RGBA')
monster=Image.open(a10/'T2_moss_antler/master_64x64.png').convert('RGBA')
sword=Image.open(root/'sword_32x24.png').convert('RGBA')
# Remove a tiny borrowed hair fragment near upper-right from accessory crop.
sp=np.asarray(sword).copy()
sp[:12,25:,3]=0
sword=Image.fromarray(sp,'RGBA').resize((48,36),Image.Resampling.NEAREST);sword.save(root/'weapon_from_attack_reference.png')

def mask_polygon(size,points):
 m=Image.new('L',size,0);ImageDraw.Draw(m).polygon(points,fill=255);return m

def remove_region_keep_body(im,region):
 a=np.asarray(im).copy();m=np.asarray(region)>0
 # Only inpaint where an arm overlaps body, and leave the external silhouette transparent.
 # A replacement fill uses original immediate neighbours in opaque regions.
 alpha=a[:,:,3]>0
 mask=np.where(m & alpha,255,0).astype(np.uint8)
 rgb=cv2.inpaint(a[:,:,:3],mask,2,cv2.INPAINT_TELEA)
 out=a.copy();out[:,:,:3][m]=rgb[m];out[:,:,3][m]=0
 return Image.fromarray(out,'RGBA')

def transform_layer(layer, pivot, degrees, output_size):
 if layer.size!=output_size:
  p=Image.new('RGBA',output_size);p.alpha_composite(layer)
 else:p=layer
 return p.rotate(degrees,Image.Resampling.NEAREST,center=pivot,expand=False)

def render_T1():
 act='attack'; out=root/'T1_forest_scout';(out/'frames').mkdir(parents=True,exist_ok=True)
 hand_mask=mask_polygon(hero.size,[(32,37),(40,37),(45,44),(46,51),(47,58),(38,59),(34,54),(31,49)])
 # Region right near arm, glove and sleeve. Foreground arm extracted from true master.
 orig=np.asarray(hero).copy(); am=np.asarray(hand_mask,dtype=np.uint8)
 orig[:,:,3]=np.minimum(orig[:,:,3],am)
 arm=Image.fromarray(orig,'RGBA')
 body=remove_region_keep_body(hero,hand_mask)
 # Matting fill: use original torso pixels under arm where there is torso behind; other areas remain transparent.
 b=np.asarray(body).copy()
 for yy in range(40,50):
  for xx in range(33,38):
   if b[yy,xx,3]==0:
    sx=min(32,max(24,xx-6)); sy=min(51,yy)
    b[yy,xx,:]=np.asarray(hero)[sy,sx,:]
 body=Image.fromarray(b,'RGBA')
 poses=[(-1,0,8,-47),(-2,0,-2,-46),(-1,-1,-13,-20),(2,0,-23,19),(5,1,-31,53),(6,0,-18,78),(3,0,-8,28),(0,0,5,-35)]
 film=Image.new('RGBA',(8*W,H))
 meta=[]
 for i,(sx,sy,arm_angle,weapon_angle) in enumerate(poses):
  staged=Image.new('RGBA',(64,80))
  staged.alpha_composite(body)
  # Arm is rigidly rotated around its actual shoulder, preserving original colour clusters.
  a=transform_layer(arm,(37,41),arm_angle,(64,80))
  staged.alpha_composite(a)
  # wrist position follows rotated hand part.
  r=math.radians(arm_angle)
  hx=37+4*math.cos(r)+10*math.sin(r)
  hy=41-4*math.sin(r)+10*math.cos(r)
  wlayer=Image.new('RGBA',(64,80))
  wlayer.alpha_composite(sword,(int(round(hx-39)),int(round(hy-28))))
  wlayer=wlayer.rotate(weapon_angle,Image.Resampling.NEAREST,center=(hx,hy))
  staged.alpha_composite(wlayer)
  canvas=Image.new('RGBA',(W,H))
  canvas.alpha_composite(staged,(16+sx,24+sy))
  # Hard-pixel source, no alpha interpolation.
  a=np.asarray(canvas)
  assert set(np.unique(a[:,:,3])).issubset({0,255}),i
  assert not (np.any(a[0,:,3]) or np.any(a[-1,:,3]) or np.any(a[:,0,3]) or np.any(a[:,-1,3]))
  canvas.save(out/'frames'/f'attack_{i:02}.png')
  film.alpha_composite(canvas,(i*W,0))
  meta.append({'frame':i,'body_offset':[sx,sy],'arm_angle':arm_angle,'sword_angle':weapon_angle,'hand_xy':[round(hx,2),round(hy,2)]})
 film.save(out/'attack_strip.png')
 film.resize((W*8*2,H*2),Image.Resampling.NEAREST).save(out/'attack_strip_2x.png')
 (out/'pose_log.json').write_text(json.dumps(meta,indent=2))
 return meta

def render_T2():
 out=root/'T2_moss_antler';(out/'frames').mkdir(parents=True,exist_ok=True)
 W,H=96,96
 # Coherent rigid-body charge without detached horn/leaf layers: all source pixels stay together.
 # The previous independent head rotation was rejected for floating fragments in source sprite.
 poses=[(0,0,0,1.0),(1,1,-2,0.97),(-2,0,1,0.94),(-6,-2,-4,0.95),(-11,-3,-7,0.92),(-12,-2,-9,0.93),(-7,-1,-4,0.97),(0,0,0,1.0)]
 film=Image.new('RGBA',(8*W,H));details=[]
 for i,(shift,bob,rot,squash) in enumerate(poses):
  # All animation is derived only from a single approved species master, with no independent regenerated parts.
  subject=monster.rotate(rot,resample=Image.Resampling.NEAREST,center=(31,50),expand=False)
  if squash!=1.0:
   scaled_h=int(round(64*squash))
   subject=subject.resize((64,scaled_h),Image.Resampling.NEAREST)
   canvas=Image.new('RGBA',(64,64));canvas.alpha_composite(subject,(0,64-scaled_h))
   subject=canvas
  canvas=Image.new('RGBA',(W,H));canvas.alpha_composite(subject,(16+shift,24+bob))
  rgba=np.asarray(canvas)
  assert np.any(rgba[:,:,3]) and set(np.unique(rgba[:,:,3])).issubset({0,255}),i
  assert not any([rgba[0,:,3].any(),rgba[-1,:,3].any(),rgba[:,0,3].any(),rgba[:,-1,3].any()]),i
  canvas.save(out/'frames'/f'attack_{i:02}.png');film.alpha_composite(canvas,(i*W,0))
  details.append({'frame':i,'body_shift_x':shift,'bob':bob,'rotation_degrees':rot,'squash_factor':squash})
 film.save(out/'attack_strip.png');film.resize((W*8*2,H*2),Image.Resampling.NEAREST).save(out/'attack_strip_2x.png')
 (out/'pose_log.json').write_text(json.dumps(details,indent=2))
 return details
if __name__=='__main__':
 print(json.dumps({'T1':render_T1(),'T2':render_T2()},indent=2))