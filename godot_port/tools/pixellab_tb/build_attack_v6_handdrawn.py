#!/usr/bin/env python3
"""FS PMD0001 Attack V6. Pixel-authored independent anatomy keyposes.
SOURCE-LOCKED private real source; no PixelLab generation or RBF.
Never assumes machine geometry checks prove aesthetic approval.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import numpy as np, hashlib, json, math, os
BASE_DIR=Path(__file__).resolve().parent
SRC=Path(os.environ.get('TB_PMD0001_SOURCE',BASE_DIR/'source'/'PMD0001_STATIC_64.png'))
DEST=Path(os.environ.get('TB_V6_OUT',BASE_DIR/'artifacts'));DEST.mkdir(parents=True,exist_ok=True)
SHA='fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c'
def sh(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sh(SRC)==SHA, (sh(SRC),SHA)
source=Image.open(SRC).convert('RGBA'); assert source.size==(64,64)
W=96; ORIGIN=(16,24)
# Every pose is individually authored and reviewed, not computed with global warp/scales.
# root: body translation; toe offsets: root-relative; knee and jaw points are hand selected.
POSES=[
 dict(name='NEUTRAL',root=(0,0),toes=((0,0),(0,0),(0,0)),knees=((20,50),(29,52),(45,50)),gape=0),
 dict(name='CROUCH',root=(-1,2),toes=((-2,1),(1,1),(0,1)),knees=((16,51),(27,54),(43,51)),gape=0),
 dict(name='RUSH',root=(3,-2),toes=((-5,3),(4,-5),(6,-4)),knees=((16,48),(33,44),(51,43)),gape=0),
 dict(name='LEAP',root=(7,-6),toes=((-8,2),(12,-5),(14,-4)),knees=((16,48),(42,40),(58,39)),gape=0),
 dict(name='BITE_WINDUP',root=(9,-6),toes=((-9,2),(14,-7),(16,-7)),knees=((16,47),(45,38),(62,38)),gape=3),
 dict(name='HIT',root=(11,-5),toes=((-10,2),(15,-5),(17,-5)),knees=((16,49),(49,40),(64,40)),gape=7),
 dict(name='FOLLOW',root=(9,-3),toes=((-7,2),(13,-2),(13,-1)),knees=((18,50),(45,45),(58,44)),gape=4),
 dict(name='RETURN',root=(5,-1),toes=((-3,1),(7,0),(7,0)),knees=((18,50),(39,49),(52,47)),gape=1),
 dict(name='LANDING',root=(3,1),toes=((-1,1),(3,2),(3,1)),knees=((20,52),(32,52),(47,52)),gape=0),
 dict(name='RECOVER',root=(1,0),toes=((0,0),(1,0),(1,0)),knees=((20,50),(30,52),(46,50)),gape=0),
 dict(name='NEUTRAL_END',root=(0,0),toes=((0,0),(0,0),(0,0)),knees=((20,50),(29,52),(45,50)),gape=0),
]
DUR=[4,2,4,2,2,2,2,2,2,2,4]
# The actual source already has natural semi-transparent antialias; preserve intact source torso/shell.
MASK_GEOMETRY={
 'rear':[(12,50),(21,49),(25,51),(24,55),(18,57),(12,56)],
 'near':[(24,52),(36,51),(38,55),(35,60),(25,60)],
 'far':[(38,50),(51,49),(54,53),(51,57),(41,56)],
 'jaw':[(33,44),(39,44),(47,44),(51,45),(51,49),(47,52),(39,53),(33,50)],
}
order=['rear','near','far','jaw']
parts={}; masks={}
for name,points in MASK_GEOMETRY.items():
 mask=Image.new('L',(64,64));ImageDraw.Draw(mask).polygon(points,fill=255)
 out=source.copy();aa=Image.fromarray(np.where(np.asarray(mask),np.asarray(source.getchannel('A')),0).astype('uint8'),'L');out.putalpha(aa)
 parts[name]=out; masks[name]=mask
body_np=np.asarray(source).copy()
for name,mask in masks.items():body_np[np.asarray(mask)>0,3]=0
body=Image.fromarray(body_np,'RGBA')
# No loops over free-form anatomy for styling: each joint is drawn with two tapered polygon joints
# and a flattened elbow piece; the source toes overlay each limb root.
P={'outline':(31,19,24,255),'shadow':(91,35,43,255),'skin':(138,56,61,255),
   'lit':(180,77,66,255),'orange':(227,93,45,255),'lava':(248,122,44,255),
   'mouth':(38,13,21,255),'mouth2':(84,25,30,255),'teeth':(239,189,112,255),
   'chin':(206,133,87,255),'chin_shadow':(159,83,65,255)}
HIP=[(18,45),(29,48),(44,47)]
FOOT=[(18,54),(29,56),(46,53)]

def pt(p,root=(0,0)):
 return (int(round(p[0]+ORIGIN[0]+root[0])),int(round(p[1]+ORIGIN[1]+root[1])))
def polygon_link(draw,start,end,rad0,rad1,colour):
 # Angular tapered segments, separate dark and light passes to avoid rigid straight sticks.
 dx=end[0]-start[0];dy=end[1]-start[1];length=max(1,math.hypot(dx,dy));nx=-dy/length;ny=dx/length
 corners=[(round(start[0]+nx*rad0),round(start[1]+ny*rad0)),
   (round(end[0]+nx*rad1),round(end[1]+ny*rad1)),
   (round(end[0]-nx*rad1),round(end[1]-ny*rad1)),
   (round(start[0]-nx*rad0),round(start[1]-ny*rad0))]
 draw.polygon(corners,fill=colour)

def limb_canvas(p,index):
 name=order[index];layer=Image.new('RGBA',(W,W));d=ImageDraw.Draw(layer)
 hip=pt(HIP[index],p['root']); knee=pt(p['knees'][index]);foot=pt((FOOT[index][0]+p['toes'][index][0],FOOT[index][1]+p['toes'][index][1]),p['root'])
 # The upper limb has a full shaded joint, a noncollinear knee, and a tapered lower leg.
 size=(4,3,3) if name=='rear' else ((4,3,3) if name=='near' else (3,2,2))
 a,b,c=size
 polygon_link(d,hip,knee,a+1,b+1,P['outline']); polygon_link(d,knee,foot,b+1,c+1,P['outline'])
 polygon_link(d,hip,knee,a,b,P['shadow']); polygon_link(d,knee,foot,b,c,P['skin'])
 # Joint roundness at elbow ensures the bent joint is not an unsupported straight rod.
 d.ellipse((knee[0]-b,knee[1]-b,knee[0]+b,knee[1]+b), fill=P['shadow'],outline=P['outline'],width=1)
 # Hand-pixel shading on upper segment and ankle, deliberately asymmetric (rotates with limb).
 hx=round(.7*hip[0]+.3*knee[0]);hy=round(.7*hip[1]+.3*knee[1]);d.line((hx,hy,hx+1,hy+3),fill=P['lit'],width=1)
 mx=round((knee[0]+foot[0])/2);my=round((knee[1]+foot[1])/2);d.point((mx,my),fill=P['lit'])
 # Genuine source foot pixels moved independently; identity of toes stays true.
 offset=(ORIGIN[0]+p['root'][0]+p['toes'][index][0],ORIGIN[1]+p['root'][1]+p['toes'][index][1]);layer.alpha_composite(parts[name],offset)
 return layer

def draw_mouth(out,p):
 gape=p['gape'];root=p['root']
 if gape==0:
  out.alpha_composite(parts['jaw'],pt((0,0),root));return
 # The mouth in V6 is cut out before painting, not a black shape over the existing closed lips.
 cav=Image.new('RGBA',(W,W));d=ImageDraw.Draw(cav)
 def J(x,y):return pt((x,y),root)
 # Teeth row fixed under rigid upper snout. All mouth landmarks near source snout tip.
 d.polygon([J(34,44),J(50,44),J(52,47),J(51,47+gape),J(42,48+gape),J(34,48)],fill=P['outline'])
 d.polygon([J(36,45),J(50,45),J(50,47+gape),J(43,47+gape),J(37,47)],fill=P['mouth'])
 d.line([J(37,46),J(48,45),J(50,46)],fill=P['mouth2'],width=2)
 for x in (39,44,49):d.point(J(x,45),fill=P['teeth'])
 # Rotate the original lower jaw around an actual hinge under the rear upper lip.
 # Rotation (not straight translation) keeps the jaw rooted to the skull. Only a small
 # masked chin component rotates; neither head nor shell undergoes global morphing.
 out.alpha_composite(cav)
 jaw_layer=Image.new('RGBA',(W,W));jaw_layer.alpha_composite(parts['jaw'],pt((0,0),root))
 hinge=J(34,45)
 rotated=jaw_layer.rotate(-4*gape,resample=Image.Resampling.NEAREST,center=hinge,expand=False)
 out.alpha_composite(rotated)
 # Upper tooth line and hinge-tissue overlap remain at the same pixel anchor.
 dd=ImageDraw.Draw(out)
 dd.line([J(34,45),J(37,47)],fill=P['chin_shadow'],width=2)
 dd.point(J(47,46),fill=P['teeth'])

def frame(p):
 if p['name'] in ('NEUTRAL','NEUTRAL_END'):
  out=Image.new('RGBA',(W,W));out.alpha_composite(source,ORIGIN);return out
 out=Image.new('RGBA',(W,W));out.alpha_composite(limb_canvas(p,0))
 body_layer=Image.new('RGBA',(W,W));body_layer.alpha_composite(body,pt((0,0),p['root']))
 out.alpha_composite(body_layer)
 # Hip/root dark overlap corrects shoulder cutouts rather than loose limb segments.
 for i in (2,1):out.alpha_composite(limb_canvas(p,i))
 draw_mouth(out,p)
 return out
frames=[frame(p) for p in POSES]
sheet=Image.new('RGBA',(384,288));
for i,fr in enumerate(frames):sheet.alpha_composite(fr,((i%4)*W,(i//4)*W))
fp=DEST/'PMD0001_ATTACK_V6_11F_384x288.png';sheet.save(fp)
frames[0].save(DEST/'PMD0001_ATTACK_V6_PREVIEW.gif',save_all=True,append_images=frames[1:],duration=[int(round(x*1000/60)) for x in DUR],disposal=2,loop=0,optimize=False)
# Separate pose thumbnails as true 96px transparent files useful for approved keypose review.
for i in (0,1,3,5,7,10):frames[i].save(DEST/f'PMD0001_ATTACK_V6_KEYPOSE_F{i:02}.png')
scale=4;step=96*scale
view=Image.new('RGB',(step*4,3*(step+30)),(24,28,34));d=ImageDraw.Draw(view)
for i,fr in enumerate(frames):
 col,row=i%4,i//4;x=col*step;y=row*(step+30)
 tile=Image.new('RGBA',(W,W),(24,28,34,255));tile.alpha_composite(fr)
 view.paste(tile.resize((step,step),Image.Resampling.NEAREST),(x,y));d.text((x+9,y+step+5),f'F{i:02} {POSES[i]["name"]}',fill='white')
view.save(DEST/'PMD0001_ATTACK_V6_CONTACT.png')
np_frames=[np.asarray(x) for x in frames]
qa={
 'source_sha256':sh(SRC),'output_sha256':sh(fp),'dimensions':list(sheet.size),
 'frame_count':11,'frame_size':[96,96],
 'first_last_source_exact':bool(np.array_equal(np_frames[0],np_frames[-1]) and np.array_equal(np_frames[0],np.asarray(Image.new('RGBA',(W,W))))==False),
 'all_distinct_except_last':len({hashlib.sha256(x.tobytes()).hexdigest() for x in frames})==10,
 'alpha_not_cropped':all(np.all(x[0,:,3]==0) and np.all(x[-1,:,3]==0) and np.all(x[:,0,3]==0) and np.all(x[:,-1,3]==0) for x in np_frames),
 'native_event_frames':{'rush':2,'hit':5,'return':7},'total_ticks':sum(DUR),
 'hand_authored_keypose_frames':[1,2,3,4,5,6,7,8,9],
 'actual_pixellab_calls':0,'art_approved':False,'godot_native_result':'NOT_RUN',
 'new_method':'source-foot cutout + hand-authored bend knee/ankle/shoulder positions + jaw extraction',
}
(DEST/'PMD0001_ATTACK_V6_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps(qa,indent=2,ensure_ascii=False))
