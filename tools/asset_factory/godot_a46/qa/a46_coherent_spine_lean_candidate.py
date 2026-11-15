from pathlib import Path
from PIL import Image
import json
p=Path(__file__).resolve().parents[1];a=p/'assets'
base=Image.open(a/'actor01_a46_body_v1_12frames.png').convert('RGBA')
blade=Image.open(a/'actor01_a45_weapon_12frames.png').convert('RGBA')
fx=Image.open(a/'actor01_a45_fx_12frames.png').convert('RGBA')
rig=json.loads((a/'actor01_a46_attack_anchors_v1.json').read_text(encoding='utf8'))
lean={0:0,1:0,2:-1,3:-1,4:-1,5:0,6:1,7:1,8:1,9:0,10:0,11:0}
def frame(im,i):
 x=i%4*64;y=i//4*64
 return im.crop((x,y,x+64,y+64))
def put(sheet,im,i):
 sheet.alpha_composite(im,(i%4*64,i//4*64))
body=Image.new('RGBA',(256,192))
weapon=Image.new('RGBA',(256,192))
effects=Image.new('RGBA',(256,192))
def shift_body(src,offset):
 out=Image.new('RGBA',(64,64))
 if offset==0:
  return src.copy()
 for y in range(64):
  # Single connected spine: shoulder/head lean before pelvis, all hip and foot pixels stay put.
  shift=offset if y<=41 else 0
  if shift:
   strip=src.crop((0,y,64,y+1))
   out.alpha_composite(strip,(shift,y))
  else:
   out.alpha_composite(src.crop((0,y,64,y+1)),(0,y))
 return out
def shift_whole(src,offset):
 if offset==0:return src.copy()
 out=Image.new('RGBA',(64,64))
 out.alpha_composite(src,(offset,0))
 return out
for i in range(12):
 offset=lean[i]
 b=shift_body(frame(base,i),offset)
 wpos=rig['pose_anchors'][i]['wrist_px'][1]
 # Sword root follows wrist; if palm is already in the anchored waist region,
 # blade does not shift with face/shoulder lean.
 wshift=offset if wpos<=41 else 0
 w=shift_whole(frame(blade,i),wshift)
 f=shift_whole(frame(fx,i),wshift)
 put(body,b,i);put(weapon,w,i);put(effects,f,i)
 pose=rig['pose_anchors'][i]
 for key in ['wrist_px','sword_tip_px','hit_marker_local_px']:
  pose[key][0]+=wshift
rig['stage']='A46_COHERENT_SPINE_LEAN_V2'
rig['coherent_upper_body_lean_px']=lean
for name,img in [('body',body),('weapon',weapon),('fx',effects)]:
 img.save(a/('actor01_a46_'+name+'_v2_12frames.png'))
(a/'actor01_a46_attack_anchors_v2.json').write_text(json.dumps(rig,indent=2,ensure_ascii=False),encoding='utf8')
compare=Image.new('RGBA',(768,128))
for i in range(12):
 old=Image.new('RGBA',(64,64));new=Image.new('RGBA',(64,64))
 for imgs,output in [([base,blade,fx],old),([body,weapon,effects],new)]:
  for layer in imgs:output.alpha_composite(frame(layer,i))
 compare.alpha_composite(old,(64*i,0))
 compare.alpha_composite(new,(64*i,64))
compare.resize((2304,384),Image.Resampling.NEAREST).save(p/'A46_V1_V2_COHERENT_LEAN_12FRAMES_3X.png')
print('A46_V2_LEAN_CANDIDATE',lean,flush=True)
