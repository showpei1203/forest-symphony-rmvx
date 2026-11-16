from pathlib import Path
from PIL import Image,ImageDraw
import json,math,hashlib,io
p=Path(__file__).resolve().parents[1]
a=p/'assets'
base=Image.open(a/'actor01_a46_body_v1_12frames.png').convert('RGBA')
old=Image.open(a/'actor01_a46_body_12frames.png').convert('RGBA')
weapon=Image.open(a/'actor01_a46_weapon_12frames.png').convert('RGBA')
fx=Image.open(a/'actor01_a46_fx_12frames.png').convert('RGBA')
anchors=json.loads((a/'actor01_a46_attack_anchors.json').read_text(encoding='utf8'))['pose_anchors']
assert base.size==old.size==weapon.size==fx.size==(256,192)
# A57 and A65 source-informed rule: replace deprecated scanline translation
# with continuous 2-D full-body coordinate fields under wrist, pelvis and boot locks.
# The image is resampled once using a smooth whole-body field; the source is
# always immutable A46-V1 (no stacked retries or extra RGB recoloring).
KINETICS=[
 # anticipation, shoulder counter-rotation, neck lead
 {'phase':'idle','load':0.,'twist':0.,'recoil':0.},
 {'phase':'anticipate','load':-.45,'twist':-.40,'recoil':0.},
 {'phase':'draw_back','load':-1.40,'twist':-.90,'recoil':-.10},
 {'phase':'draw_back_peak','load':-2.15,'twist':-1.25,'recoil':-.25},
 {'phase':'pre_accel','load':-1.75,'twist':-1.00,'recoil':-.20},
 {'phase':'accelerate','load':.35,'twist':.55,'recoil':.15},
 {'phase':'contact','load':1.85,'twist':1.35,'recoil':.15},
 {'phase':'follow_through','load':1.90,'twist':1.20,'recoil':.10},
 {'phase':'recover','load':.80,'twist':.45,'recoil':0.},
 {'phase':'recover','load':.25,'twist':.15,'recoil':0.},
 {'phase':'settle','load':-.15,'twist':-.05,'recoil':0.},
 {'phase':'idle','load':0.,'twist':0.,'recoil':0.}
]
def g(x,y,cx,cy,sx,sy):
 return math.exp(-.5*((x-cx)/sx)**2-.5*((y-cy)/sy)**2)
def motion_at(i,x,y):
 data=KINETICS[i]; L=data['load'];T=data['twist'];R=data['recoil']
 # Head/neck, shoulders, rib cage and pelvis form ONE continuous field;
 # joint influences blend through the lower torso, unlike horizontal scanline patches.
 dx=(L*(0.62*g(x,y,34,25,11,9)+
        0.94*g(x,y,35,36,15,6)+
        0.62*g(x,y,34,40,13,5)+
        0.17*g(x,y,34,44,11,4)))
 # Posterior/anterior shoulders rotate in opposite depth directions.
 dy=(T*((x-34)/11.0)*g(x,y,34,36,15,6)+
     R*g(x,y,34,42,11,5))
 # Actor01's wrist is already posed by the A42 sword trajectory.
 # Keep physical hand at that known place; alter shoulder/elbow/torso through IK blend.
 wrist=anchors[i].get('wrist_px')
 if wrist:
  wx,wy=wrist
  lock=g(x,y,wx,wy,4.2,4.0)
  dx*=(1.-min(1.,lock*1.05))
  dy*=(1.-min(1.,lock*1.05))
 # Pelvis, knees and planted boots must not slide.
 foot_lock=max(0.,min(1.,(y-43.)/4.))
 dx*=1.-foot_lock
 dy*=1.-foot_lock
 return (dx,dy)
def cell(img,i):
 x=i%4*64;y=i//4*64
 return img.crop((x,y,x+64,y+64))
def render_variant(strength,tag):
 atlas=Image.new('RGBA',(256,192))
 for i in range(12):
  c=cell(base,i)
  if i in (0,11):
   out=c.copy()
  else:
   out=Image.new('RGBA',(64,64))
   # backward sampling of smooth invertible displacement field; nearest neighbor
   # preserves original A62 palette RGB, sharp non-antialiased pixel edges.
   for y in range(64):
    for x in range(64):
     dx,dy=motion_at(i,x,y)
     # first-order inverse with two steps for spatial derivatives
     X=x-strength*dx;Y=y-strength*dy
     dx2,dy2=motion_at(i,X,Y)
     srcx=int(round(x-strength*dx2));srcy=int(round(y-strength*dy2))
     if 0<=srcx<64 and 0<=srcy<64:
      out.putpixel((x,y),c.getpixel((srcx,srcy)))
  atlas.alpha_composite(out,(i%4*64,i//4*64))
 atlas.save(a/('actor01_a47_body_'+tag+'_12frames.png'))
 return atlas
r1=render_variant(0.72,'R1')
r2=render_variant(1.0,'R2')
r3=render_variant(1.43,'R3')
# identity locked: weapon and FX remain as A46; wrist near-field is anchored.
# No invented sword positions or zero-value hit events.
old_composite=Image.new('RGBA',(256,192))
for l in [old,weapon,fx]:old_composite.alpha_composite(l)
comp1=Image.new('RGBA',(256,192))
for l in [r1,weapon,fx]:comp1.alpha_composite(l)
comp2=Image.new('RGBA',(256,192))
for l in [r2,weapon,fx]:comp2.alpha_composite(l)
full=Image.new('RGBA',(768,192))
for i in range(12):
 for row,layer in enumerate([old_composite,comp1,comp2]):
  full.alpha_composite(cell(layer,i),(i*64,row*64))
full.save(p/'A47_A46_VS_R1_VS_R2_1X.png')
full.resize((2304,576),Image.Resampling.NEAREST).save(p/'A47_A46_VS_R1_VS_R2_3X.png')
# Two candidates are new pixels, independently inspect both and select after QA.
for tag,comp in [('R1',comp1),('R2',comp2)]:
 frames=[cell(comp,i).resize((256,256),Image.Resampling.NEAREST) for i in range(12)]
 b=io.BytesIO()
 frames[0].save(b,format='GIF',save_all=True,append_images=frames[1:],
   duration=[120,90,85,85,70,70,170,90,90,100,105,120],loop=0,disposal=2)
 (p/('A47_'+tag+'_KINEMATIC_CANDIDATE_4X.gif')).write_bytes(b.getvalue())
comp3=Image.new('RGBA',(256,192))
for l in [r3,weapon,fx]:comp3.alpha_composite(l)
full3=Image.new('RGBA',(768,256))
for i in range(12):
 for row,layer in enumerate([old_composite,comp1,comp2,comp3]):
  full3.alpha_composite(cell(layer,i),(i*64,row*64))
full3.resize((2304,768),Image.Resampling.NEAREST).save(p/'A47_A46_R1_R2_R3_COMPARISON_3X.png')
frames3=[cell(comp3,i).resize((256,256),Image.Resampling.NEAREST) for i in range(12)]
buffer=io.BytesIO()
frames3[0].save(buffer,format='GIF',save_all=True,append_images=frames3[1:],duration=[120,90,85,85,70,70,170,90,90,100,105,120],loop=0,disposal=2)
(p/'A47_R3_KINEMATIC_CANDIDATE_4X.gif').write_bytes(buffer.getvalue())
info={'stage':'A47','authority':['A57 18-joint prompt','A62 small-stride accepted','A65 scanline flat-waist negative'],
      'source':'A46 V1 clean anatomical core + A46 approved separate weapon and fx',
      'method':'2D smooth inverse sample Gaussian body coupling with wrist/foot constraint, NOT scanline offsets',
      '12_frame_profile':KINETICS,
      'generated_variants':['R1 strength=0.72','R2 strength=1.0','R3 strength=1.43'],
      'source_A46_body_sha256':hashlib.sha256((a/'actor01_a46_body_v1_12frames.png').read_bytes()).hexdigest(),
      'weapon_sha256':hashlib.sha256((a/'actor01_a46_weapon_12frames.png').read_bytes()).hexdigest(),
      'no_paid_pixellab_calls':True}
(p/'qa/A47_MOTION_SPEC.json').write_text(json.dumps(info,indent=2,ensure_ascii=False),encoding='utf8')
print('A47_2_VARIANTS_RENDERED',*[str((a/('actor01_a47_body_'+t+'_12frames.png')).stat().st_size) for t in ['R1','R2']],flush=True)
