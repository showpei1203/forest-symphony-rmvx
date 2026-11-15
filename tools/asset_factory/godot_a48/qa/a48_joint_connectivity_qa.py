from PIL import Image
from pathlib import Path
import json,math,collections
p=Path(__file__).resolve().parents[1]
a=p/'assets'
canon=Image.open(a/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
body=Image.open(a/'actor01_a48_body_R1_12frames.png').convert('RGBA')
old=Image.open(a/'actor01_a47_body_12frames.png').convert('RGBA')
rig=json.loads((a/'actor01_a47_attack_anchors.json').read_text(encoding='utf8'))
pose=json.loads((p/'qa/A48_ARM_JOINT_GEOMETRY.json').read_text(encoding='utf8'))['pose_nodes']
def tile(im,i):
 x=i%4*64;y=i//4*64
 return im.crop((x,y,x+64,y+64))
def components(im):
 pts={(x,y) for y in range(64) for x in range(64) if im.getpixel((x,y))[3]>0}
 sizes=[]
 while pts:
  start=pts.pop();queue=[start];size=1
  while queue:
   x,y=queue.pop()
   for xx in range(x-1,x+2):
    for yy in range(y-1,y+2):
     if (xx,yy) in pts:
      pts.remove((xx,yy));queue.append((xx,yy));size+=1
  sizes.append(size)
 return sorted(sizes,reverse=True)
def joint_dist(im,x,y):
 pts=[math.hypot(x-a,y-b) for a in range(max(0,x-3),min(64,x+4)) for b in range(max(0,y-3),min(64,y+4)) if im.getpixel((a,b))[3]>0]
 return min(pts or [99])
report={'stage':'A48 R1','known_bad_previous':'A47','head_exact_A62':[],
'feet_pelvis_exact_A62':[],'offhand_exact_A62':[],
'component_sizes':[],'joint_touch':[],'pose_uniqueness':0,
'temporal_pixels_change':[],'changed_from_A47':[],'border_alpha':[],
'lower_body_color_pass':[]}
sigs=[]
for i in range(12):
 b=tile(body,i);last=tile(body,max(0,i-1));old_frame=tile(old,i)
 sigs.append(b.tobytes())
 report['component_sizes'].append(components(b))
 report['head_exact_A62'].append(b.crop((0,0,64,34)).tobytes()==canon.crop((0,0,64,34)).tobytes())
 report['feet_pelvis_exact_A62'].append(b.crop((0,47,64,64)).tobytes()==canon.crop((0,47,64,64)).tobytes())
 report['offhand_exact_A62'].append(b.crop((0,34,30,47)).tobytes()==canon.crop((0,34,30,47)).tobytes())
 report['changed_from_A47'].append(sum(x!=y for x,y in zip(b.get_flattened_data(),old_frame.get_flattened_data())))
 report['temporal_pixels_change'].append(sum(x!=y for x,y in zip(b.get_flattened_data(),last.get_flattened_data())))
 report['border_alpha'].append(sum(b.getpixel((x,0))[3]>0 or b.getpixel((x,63))[3]>0 for x in range(64)))
 j=pose[i]
 report['joint_touch'].append({name:round(joint_dist(b,*j[name]),2) for name in ['shoulder','elbow','wrist']})
report['pose_uniqueness']=len(set(sigs))
# PASS requires visible whole-limb connectedness, not just 1 border pixel or 1 component.
report['structural_pass']=(
 all(len(a)==1 for a in report['component_sizes']) and
 all(report['head_exact_A62']) and
 all(report['feet_pelvis_exact_A62']) and
 all(report['offhand_exact_A62']) and
 all(max(x.values())<=1.0 for x in report['joint_touch'][1:11]) and
 report['pose_uniqueness']>=10 and max(report['border_alpha'])==0
)
(p/'qa/A48_CONNECTION_QA.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('A48_R1_CONNECTION_QA',report['structural_pass'],
 'components',report['component_sizes'],'joint',report['joint_touch'],
 'unique',report['pose_uniqueness'],'head',report['head_exact_A62'],
 'pelvis',report['feet_pelvis_exact_A62'],'delta',report['changed_from_A47'],flush=True)
