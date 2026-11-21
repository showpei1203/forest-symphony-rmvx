#!/usr/bin/env python3
"""R8 independent art-semantic regression, source-identity checks and clipping.
The reference rejected R7 frame's forearm protrusion and near-closed mouth are
baseline measurements; new R8 should remove limb and visibly open its mouth.
"""
import hashlib,json,pathlib
from PIL import Image
import numpy as np
ROOT=pathlib.Path(__file__).resolve().parent
OLD=ROOT/'TB02_BAT_ATTACK_11F_PAD128.png'
NEW=ROOT/'TB02_R8_BITE_PROVIDER_11F_512x384.png'
SRC=ROOT/'BAT_STAGE1.png'
IDLE=ROOT/'TB02_BAT_IDLE_8F.png'


def inspect(p):
 im=Image.open(p).convert('RGBA'); assert im.size==(512,384),im.size
 metrics=[]
 for i in range(11):
  ar=np.asarray(im.crop((i%4*128,i//4*128,i%4*128+128,i//4*128+128)))
  eye=(ar[:,:,0]>=185)&(ar[:,:,1]>=95)&(ar[:,:,1]<230)&(ar[:,:,2]<160)&(ar[:,:,3]>0)
  yy,xx=np.indices((128,128)); y,x=np.nonzero(eye)
  if not len(x):raise AssertionError('identity eye missing at F'+str(i))
  cx=int(np.median(x));cy=int(np.median(y))
  purple=(ar[:,:,0].astype(int)>ar[:,:,1].astype(int)+6)&(ar[:,:,2].astype(int)>ar[:,:,1].astype(int)-7)&(ar[:,:,3]>0)
  arm=int(np.count_nonzero(purple&(xx>cx+14)&(yy>=69)&(yy<87)))
  inner=(ar[:,:,0]<45)&(ar[:,:,1]<25)&(ar[:,:,2]<55)&(ar[:,:,3]>0)
  mouth=int(np.count_nonzero(inner&(xx>=cx-7)&(xx<=cx+9)&(yy>=cy+6)&(yy<=cy+20)))
  fang=(ar[:,:,0]>140)&(ar[:,:,1]>120)&(ar[:,:,2]>80)&(ar[:,:,3]>0)&(yy>cy+4)&(yy<cy+20)&(xx>cx-8)&(xx<cx+12)
  alpha=ar[:,:,3]
  bounds=int(np.count_nonzero(alpha[0,:]))+int(np.count_nonzero(alpha[-1,:]))+int(np.count_nonzero(alpha[1:-1,0]))+int(np.count_nonzero(alpha[1:-1,-1]))
  metrics.append(dict(i=i,eye_center=[cx,cy],mouth_dark=mouth,fang_pixels=int(fang.sum()),purple_arm_region=arm,border_pixels=bounds,visible=int(np.count_nonzero(alpha))))
 return metrics
old=inspect(OLD);new=inspect(NEW)
checks={
'R7 source identity unchanged': hashlib.sha256(SRC.read_bytes()).hexdigest()=='208e28e4f7732233c75456e9e5de671f5616fb68ef735165219a4b3aa2a959a2',
'R8 PNG 512x384 11x128':Image.open(NEW).size==(512,384),
'R7 idle sprite unchanged':hashlib.sha256(IDLE.read_bytes()).hexdigest()=='5153e58ccf29dee9d924937fb185169f45e2d0f748a36373cc2f53d4eb72e0a2',
'11 full frames no crop':all(d['border_pixels']==0 for d in new),
'eyes and identity 11/11':all(d['visible']>500 for d in new),
'new mouth dark region F4 and F5 > x2 old':all(new[i]['mouth_dark']>2*old[i]['mouth_dark'] for i in [4,5]),
'visible fang pixel in F3 F4 F5 F6':all(new[i]['fang_pixels']>=2 for i in [3,4,5,6]),
'F5 no forearm-like protrusion':new[5]['purple_arm_region']<=3 and old[5]['purple_arm_region']>=20,
'F6 no forearm-like protrusion':new[6]['purple_arm_region']<=3 and old[6]['purple_arm_region']>=15,
'F5 clean cheek and mouth recovery F10':new[10]['mouth_dark']<new[5]['mouth_dark']*.75,
'11 visible nonidentical consecutive frames':all(Image.open(NEW).crop((i%4*128,i//4*128,i%4*128+128,i//4*128+128)).tobytes()!=Image.open(NEW).crop(((i+1)%4*128,(i+1)//4*128,((i+1)%4+1)*128,((i+1)//4+1)*128)).tobytes() for i in range(10))
}
report={'schema':'fs-tb02-mouth-bite-r8-qa','source_sha256':hashlib.sha256(SRC.read_bytes()).hexdigest(),'old_sha256':hashlib.sha256(OLD.read_bytes()).hexdigest(),'new_sha256':hashlib.sha256(NEW.read_bytes()).hexdigest(),'tests':checks,'pass':sum(checks.values()),'total':len(checks),'old':old,'new':new}
(ROOT/'TB02_R8_BITE_QA.json').write_text(json.dumps(report,indent=2,ensure_ascii=False))
print('TB02_R8_BITE_QA',report['pass'],'/',report['total'])
print('MEANINGFUL_F5',json.dumps({'old':old[5],'new':new[5]}))
assert all(checks.values()),'Bite art/technical semantic gate failed'
