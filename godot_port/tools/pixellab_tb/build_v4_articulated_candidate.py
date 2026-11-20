#!/usr/bin/env python3
"""Source locked independently pose-controlled frog attack candidate.

No PixelLab call. This is a repeatable retargeting fallback; ART HOLD until review.
Original 64px frog is never changed, frame 0 and 10 byte-exact (RGBA).
"""
from pathlib import Path
import hashlib, json, math, os
import numpy as np
from PIL import Image, ImageDraw
from scipy.interpolate import RBFInterpolator

ROOT=Path(__file__).resolve().parent
SOURCE=Path(os.environ.get('TB_PMD0001_SOURCE', str(Path(__file__).resolve().parents[1]/'assets/PMD0001_STATIC_64.png')))
OUT=Path(os.environ.get('TB_ATTACK_V4_OUTPUT', str(ROOT/'v4_articulated')))
OUT.mkdir(exist_ok=True,parents=True)
if not SOURCE.is_file():
 raise FileNotFoundError(f'Pass a real, authorized source image with TB_PMD0001_SOURCE: {SOURCE}')
EXPECTED_SHA='fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c'
actual_source_sha=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
if actual_source_sha!=EXPECTED_SHA:
 raise ValueError(f'Source-lock error: expected {EXPECTED_SHA}; got {actual_source_sha}. Do not silently substitute a new frog.')
SRC64=Image.open(SOURCE).convert('RGBA')
BASE=Image.new('RGBA',(96,96))
BASE.alpha_composite(SRC64,(16,24))
PX=np.asarray(BASE).copy()
assert PX.shape==(96,96,4)

# control-point coordinates in 64px source; deliberately separates 3 feet and eyes/torso.
pts={
 'rear_foot':(18,55), 'rear_knee':(20,48), 'rear_hip':(22,44),
 'near_foot':(33,57), 'near_knee':(31,52), 'near_shoulder':(31,46),
 'far_foot':(47,55), 'far_knee':(45,51), 'far_shoulder':(44,45),
 'torso':(31,44), 'shell_mid':(30,34), 'shell_back':(22,36),
 'eye':(38,40), 'snout':(49,42), 'jaw':(44,47), 'nose':(50,40),
 'head_back':(35,37), 'belly':(40,49),
}
# Anchors around empty margin constrain the mesh, without suppressing foreground articulation.
anchors=[(0,0),(32,0),(64,0),(95,0),(0,32),(95,32),(0,64),(95,64),(0,95),(32,95),(64,95),(95,95)]

# Key pose displacements, relative to original pixels, tracked individually.
# dict: root_xy, three foot_xy, jaw_px, optional eye/snouth counter displacement.
POSES=[
 dict(stage='NEUTRAL',root=(0,0),rear=(0,0),near=(0,0),far=(0,0),jaw=0),
 dict(stage='ANTICIPATION',root=(-1,1),rear=(-2,1),near=(1,1),far=(0,1),jaw=0),
 dict(stage='RUSH_START',root=(3,-2),rear=(-2,2),near=(5,-4),far=(6,-3),jaw=0),
 dict(stage='LEAP',root=(6,-5),rear=(-2,-3),near=(10,-7),far=(11,-6),jaw=0),
 dict(stage='BITE_WINDUP',root=(9,-5),rear=(0,-4),near=(12,-8),far=(13,-7),jaw=2),
 dict(stage='HIT',root=(11,-4),rear=(2,-2),near=(14,-4),far=(15,-3),jaw=5),
 dict(stage='FOLLOW_THROUGH',root=(10,-2),rear=(4,0),near=(13,0),far=(13,0),jaw=3),
 dict(stage='RETURN',root=(6,-1),rear=(3,0),near=(9,-1),far=(8,-1),jaw=1),
 dict(stage='LANDING',root=(3,1),rear=(1,1),near=(4,1),far=(4,0),jaw=0),
 dict(stage='RECOVER',root=(1,0),rear=(0,0),near=(2,0),far=(1,0),jaw=0),
 dict(stage='NEUTRAL_END',root=(0,0),rear=(0,0),near=(0,0),far=(0,0),jaw=0),
]
DURATIONS=[4,2,4,2,2,2,2,2,2,2,4]
assert len(POSES)==len(DURATIONS)==11

# Nose, eye and shell all translate with the body; individual leg toes have separate targets.
def controls(p):
 root=np.array(p['root'],float)
 vals={}
 for nm in pts:
  if nm.startswith('rear_'):
   if nm=='rear_foot':d=p['rear']
   elif nm=='rear_knee': d=.48*np.array(p['rear'])+.52*root
   else:d=root
  elif nm.startswith('near_'):
   if nm=='near_foot':d=p['near']
   elif nm=='near_knee':d=.55*np.array(p['near'])+.45*root
   else:d=root
  elif nm.startswith('far_'):
   if nm=='far_foot':d=p['far']
   elif nm=='far_knee':d=.55*np.array(p['far'])+.45*root
   else:d=root
  elif nm=='jaw': d=root+np.array((0,p['jaw']))
  elif nm in ('eye','snout','nose','head_back'):d=root+np.array((0,-1 if p['stage'] in ('RUSH_START','LEAP','BITE_WINDUP') else 0))
  elif nm=='shell_back':d=root+np.array((-1 if p['stage'] in ('RUSH_START','LEAP') else 0,0))
  else:d=root
  vals[nm]=np.array(pts[nm],float)+np.array((16,24))+np.array(d,float)
 return vals

SRC_CTRL={n:np.array((x+16,y+24),float) for n,(x,y) in pts.items()}


def deform(p):
 if p['stage'] in ('NEUTRAL','NEUTRAL_END'):
  return BASE.copy()
 dst=controls(p)
 target=np.array([*dst.values(),*anchors],float)
 source=np.array([*SRC_CTRL.values(),*anchors],float)
 # Fit mapping target pixel -> source pixel.  Smoothing avoids foldovers near the toes.
 inv=RBFInterpolator(target,source-target,kernel='thin_plate_spline',smoothing=1.0)
 gy,gx=np.mgrid[0:96,0:96]
 loc=np.stack([gx.ravel(),gy.ravel()],axis=-1).astype(float)
 sample=loc+inv(loc)
 ix=np.rint(sample[:,0]).astype(int)
 iy=np.rint(sample[:,1]).astype(int)
 ok=(ix>=0)&(ix<96)&(iy>=0)&(iy<96)
 result=np.zeros((96*96,4),dtype=np.uint8)
 result[ok]=PX[iy[ok],ix[ok]]
 return Image.fromarray(result.reshape((96,96,4)),'RGBA')


def open_jaw(im, p):
 amt=int(p['jaw'])
 if amt==0:return im
 # Actual mouth articulation: dark oral cavity follows the rigid upper snout,
 # lower lip has a separately moved extracted portion, not a floating projectile.
 # Mouth local coordinates reference original 64 pixel source + pose translation.
 dx,dy=p['root']
 ox,oy=16+dx,24+dy
 # Upper lip is at (34..50,43..45) and lower jaw starts (35..47,45..49).
 # Open cavity is a wedge under the upper lip. Preserve eye and upper cranium.
 cavity=Image.new('RGBA',(96,96));d=ImageDraw.Draw(cavity)
 # Pixelized dark cavity creates a visible gap (at 96px original-size canvas).
 x0,y0=34+ox,44+oy
 d.polygon([(x0,y0),(x0+16,y0-1),(x0+14,y0+amt+1),(x0+6,y0+amt+1)],fill=(48,13,23,255))
 d.line([(x0+1,y0),(x0+15,y0-1)],fill=(88,23,28,255),width=1)
 d.point((x0+10,y0+amt),fill=(195,62,39,255))
 im.alpha_composite(cavity)
 # Move a sliver of existing lower lip down, retaining original palette.
 pix=BASE.copy()
 mask=Image.new('L',(96,96),0);md=ImageDraw.Draw(mask)
 md.polygon([(35+16,45+24),(48+16,44+24),(48+16,48+24),(42+16,50+24),(36+16,49+24)],fill=255)
 pix.putalpha(Image.fromarray((np.array(pix.getchannel('A'))*(np.array(mask)/255)).astype('uint8')))
 jaw=Image.new('RGBA',(96,96));jaw.alpha_composite(pix,(int(dx),int(dy+amt)))
 im.alpha_composite(jaw)
 return im

frames=[]
for i,p in enumerate(POSES):
 frame=open_jaw(deform(p),p)
 frames.append(frame)
 frame.save(OUT/f'PMD0001_ATTACK_V4_F{i:02d}.png')

sheet=Image.new('RGBA',(4*96,3*96))
for idx,im in enumerate(frames):sheet.alpha_composite(im,((idx%4)*96,(idx//4)*96))
sheet.save(OUT/'PMD0001_ATTACK_V4_11F_384x288.png')

# human-readable contrast candidate, checker neutral dark and clear pose markers.
comparison=Image.new('RGB',(1050,520),(23,29,37))
d=ImageDraw.Draw(comparison)
d.text((10,8),'PMD0001 | ARTICULATED PHYSICAL LUNGE + BITE | V4 CANDIDATE | NOT PIXELLAB', fill=(245,239,223))
for i,f in enumerate(frames):
 x=10+(i%6)*173;y=36+(i//6)*236
 comparison.paste(f.resize((160,160),Image.Resampling.NEAREST),(x,y),f.resize((160,160),Image.Resampling.NEAREST))
 d.text((x,y+165),f'F{i:02d} {POSES[i]["stage"]}',fill=(255,193,94) if i==5 else (203,210,215))
 d.text((x,y+180),f'body={POSES[i]["root"]}  jaw={POSES[i]["jaw"]}',fill=(182,190,192))
comparison.save(OUT/'PMD0001_ATTACK_V4_CONTACT.png')

frame_durations=[round(x*1000/60) for x in DURATIONS]
frames[0].save(OUT/'PMD0001_ATTACK_V4_PREVIEW.gif',save_all=True,append_images=frames[1:],duration=frame_durations,loop=0,disposal=2,optimize=False)

bbox=[]
for f in frames:
 box=f.getbbox();bbox.append(list(box) if box else None)
 assert box is not None and all([box[0]>0,box[1]>0,box[2]<96,box[3]<96]),box
assert np.array_equal(np.asarray(frames[0]),PX)
assert np.array_equal(np.asarray(frames[10]),PX)
unique=[hashlib.sha256(f.tobytes()).hexdigest() for f in frames]
assert len(set(unique))==10 and unique[0]==unique[10]
# Test independent leg keypoints: foot displacement is not equal to trunk displacement.
assert tuple(POSES[3]['near']) != tuple(POSES[3]['root'])
assert tuple(POSES[3]['rear']) != tuple(POSES[3]['near'])
assert POSES[5]['jaw']>=4 and POSES[5]['stage']=='HIT'
manifest={
 'status':'REGENERATED_KEYPOINT_CONTROLLED_V4_CANDIDATE_ART_HOLD',
 'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
 'source_static_drive_id':'1jDRbwUfk-Y_5wk_8JVSXMygTun2OfSAR',
 'frame_count':len(frames),'frame_size':[96,96],'sheet_size':[384,288],
 'frame_sha256':unique,'bbox':bbox,'durations_ticks':DURATIONS,
 'events':{'rush':2,'hit':5,'return':7},
 'poses':POSES,'method':'Source locked nonrigid spatial keypoints and independently animated mouth; not PixelLab',
 'pixellab_new_generation_count':0,'model':'NONE (procedural mesh-re-targeting) ',
 'qa':{'frame0_source_lock':True,'frame10_source_lock':True,'all_nonendpoint_frames_unique':True,'first_equals_last':True,'no_crop':True,'independent_feet_controls':True,'jaw_opens_at_hit':True,'godot_native':'NOT_RUN','art':'PENDING'},
 'screenshot':'NO_NATIVE_GPU_EVIDENCE',
 'output_sha256':hashlib.sha256((OUT/'PMD0001_ATTACK_V4_11F_384x288.png').read_bytes()).hexdigest(),
}
(OUT/'PMD0001_ATTACK_V4_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({'file':str(OUT/'PMD0001_ATTACK_V4_11F_384x288.png'),'sha':manifest['output_sha256'],'bbox':bbox,'frames_unique':len(set(unique)),'method':manifest['method']},ensure_ascii=False))
