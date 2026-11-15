from pathlib import Path
from PIL import Image
import json,math,hashlib
p=Path(__file__).resolve().parents[1]
assets=p/'assets'
a62=Image.open(assets/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
a45=Image.open(assets/'actor01_a45_body_12frames.png').convert('RGBA')
body=Image.open(assets/'actor01_a46_body_v1_12frames.png').convert('RGBA')
weapon=Image.open(assets/'actor01_a46_weapon_12frames.png').convert('RGBA')
fx=Image.open(assets/'actor01_a46_fx_12frames.png').convert('RGBA')
rig=json.loads((assets/'actor01_a46_attack_anchors.json').read_text(encoding='utf8'))
def frame(img,i):
 return img.crop(((i%4)*64,(i//4)*64,(i%4+1)*64,(i//4+1)*64))
def alpha_components(im):
 pts={(x,y) for y in range(64) for x in range(64) if im.getpixel((x,y))[3]>0}
 sets=[]
 while pts:
  seed=pts.pop();q=[seed];total=1
  while q:
   x,y=q.pop()
   for X in (x-1,x,x+1):
    for Y in (y-1,y,y+1):
     if (X,Y) in pts:
      pts.remove((X,Y));q.append((X,Y));total+=1
  sets.append(total)
 return sorted(sets,reverse=True)
def nearest(im,pt):
 x,y=pt
 return min([math.hypot(X-x,Y-y) for Y in range(max(0,y-6),min(64,y+7)) for X in range(max(0,x-6),min(64,x+7)) if im.getpixel((X,Y))[3]] or [99])
report={'stage':'A46','type':'independent whole-body regression','frame_count':12,'components':[],
'waist_rows_vs_A62_exact':[],'head_alpha_rgba_exact':[],'wrist_body_distances':[],
'blade_handle_distances':[],'tip_weapon_distances':[],'feet_A62_reference':[],
'changes_vs_A45':[]}
for i in range(12):
 b=frame(body,i);before=frame(a45,i);w=frame(weapon,i)
 report['components'].append(alpha_components(b))
 report['head_alpha_rgba_exact'].append(b.crop((0,0,64,34)).tobytes()==before.crop((0,0,64,34)).tobytes())
 # x29-37 y42..46 should retain contiguous approved torso texture
 report['waist_rows_vs_A62_exact'].append(
   sum(b.getpixel((x,y))!=a62.getpixel((x,y)) for y in range(42,47) for x in range(29,38)))
 report['changes_vs_A45'].append(sum(u!=v for u,v in zip(b.get_flattened_data(),before.get_flattened_data())))
 if 1<=i<=10:
  pose=rig['pose_anchors'][i]
  report['wrist_body_distances'].append(round(nearest(b,pose['wrist_px']),2))
  report['blade_handle_distances'].append(round(nearest(w,pose['wrist_px']),2))
  report['tip_weapon_distances'].append(round(nearest(w,pose['sword_tip_px']),2))
 else:
  report['wrist_body_distances'].append(None)
  report['blade_handle_distances'].append(None)
  report['tip_weapon_distances'].append(None)
 footline=lambda im: [(x,y) for y in range(46,50) for x in range(25,48) if im.getpixel((x,y))[3]>0]
 feet=footline(b)
 report['feet_A62_reference'].append(
   {'observed_ymax':max([y for x,y in feet],default=-1),
    'support_forefoot_x':min([x for x,y in feet],default=-1)})
assert all(len(c)==1 for c in report['components']),report['components']
assert all(report['head_alpha_rgba_exact'])
assert all(v==0 for v in report['waist_rows_vs_A62_exact']),report['waist_rows_vs_A62_exact']
assert all(v<=1.5 for v in report['wrist_body_distances'][1:11]),report['wrist_body_distances']
assert all(v<=1.5 for v in report['blade_handle_distances'][1:11]),report['blade_handle_distances']
assert all(v<=1.5 for v in report['tip_weapon_distances'][1:11]),report['tip_weapon_distances']
assert min(report['changes_vs_A45'][1:11])>20
report['qa_result']='PASS'
(p/'qa/A46_V1_INDEPENDENT_KINETIC_QA.json').write_text(json.dumps(report,indent=2),encoding='utf8')
print('A46_INDEPENDENT_KINETIC_PASS',json.dumps({'all_connected':True,
  'waist_exact_A62_reference':True,
  'hand_wrist_max_distance':max(v for v in report['wrist_body_distances'] if v is not None),
  'sword_tip_max_distance':max(v for v in report['tip_weapon_distances'] if v is not None),
  'changed_pixels_per_frame':report['changes_vs_A45']}),flush=True)
