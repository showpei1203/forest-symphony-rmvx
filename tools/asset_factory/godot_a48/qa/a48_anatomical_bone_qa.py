from pathlib import Path
from PIL import Image
import json,math
p=Path(__file__).resolve().parents[1]
assets=p/'assets'
baseline=Image.open(assets/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
new=Image.open(assets/'actor01_a48_body_12frames.png').convert('RGBA')
old=Image.open(assets/'actor01_a47_body_12frames.png').convert('RGBA')
joints=json.loads((p/'qa/A48_ARM_JOINT_GEOMETRY.json').read_text(encoding='utf8'))['pose_nodes']
def t(im,i):return im.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
def mass(im,p,radius=2):
 x,y=p
 return sum(im.getpixel((i,j))[3]>0 for j in range(max(0,int(round(y-radius))),min(64,int(round(y+radius+1)))) for i in range(max(0,int(round(x-radius))),min(64,int(round(x+radius+1)))))
def score(im):
 report={'anatomical_bone_coverages':{},'mask_head_preserved':{},'mask_boots_preserved':{}}
 for i in range(12):
  c=t(im,i);ref=baseline
  report['mask_head_preserved'][i]=c.crop((0,0,64,34)).tobytes()==ref.crop((0,0,64,34)).tobytes()
  report['mask_boots_preserved'][i]=c.crop((0,47,64,64)).tobytes()==ref.crop((0,47,64,64)).tobytes()
  if i in [0,11]:continue
  nodes=joints[i]
  j=[nodes['shoulder'],nodes['elbow'],nodes['wrist']]
  cover=[]
  for a,b in [(j[0],j[1]),(j[1],j[2])]:
   for k in [0,0.25,0.5,0.75,1.0]:
    xy=(a[0]*(1-k)+b[0]*k,a[1]*(1-k)+b[1]*k)
    cover.append(mass(c,xy))
  report['anatomical_bone_coverages'][i]=cover
 return report
result={'stage':'A48','control':'A47 known distorted torso/head','active':'A48 connected new sleeve',
 'A47':score(old),'A48':score(new)}
result['A48_pass']=all(result['A48']['mask_head_preserved'].values()) and all(result['A48']['mask_boots_preserved'].values()) and all(min(c)>=5 for c in result['A48']['anatomical_bone_coverages'].values())
result['A47_negative_detected']=not all(result['A47']['mask_head_preserved'].values()) or not all(result['A47']['mask_boots_preserved'].values())
(p/'qa/A48_ANATOMICAL_BONE_COVERAGE_QA.json').write_text(json.dumps(result,indent=2),encoding='utf8')
print('A48_BONE_COVERAGE_QA',result['A48_pass'],'A47_negative',result['A47_negative_detected'],
 'minimum_5x5_opaque',min(min(c) for c in result['A48']['anatomical_bone_coverages'].values()),flush=True)
assert result['A48_pass'] and result['A47_negative_detected']
