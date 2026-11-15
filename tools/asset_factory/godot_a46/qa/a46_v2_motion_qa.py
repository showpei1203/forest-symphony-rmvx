from pathlib import Path
from PIL import Image
import json,math,subprocess,sys
p=Path(__file__).resolve().parents[1];a=p/'assets'
v1=Image.open(a/'actor01_a46_body_v1_12frames.png').convert('RGBA')
v2=Image.open(a/'actor01_a46_body_v2_12frames.png').convert('RGBA')
ww=Image.open(a/'actor01_a46_weapon_v2_12frames.png').convert('RGBA')
fx=Image.open(a/'actor01_a46_fx_v2_12frames.png').convert('RGBA')
rig=json.loads((a/'actor01_a46_attack_anchors_v2.json').read_text(encoding='utf8'))
def tile(im,i):
 return im.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
def groups(im):
 pixels={(x,y) for y in range(64) for x in range(64) if im.getpixel((x,y))[3]>0}
 lengths=[]
 while pixels:
  s=pixels.pop();q=[s];len_ =1
  while q:
   x,y=q.pop()
   for xx in (x-1,x,x+1):
    for yy in (y-1,y,y+1):
     if (xx,yy) in pixels:pixels.remove((xx,yy));q.append((xx,yy));len_+=1
  lengths.append(len_)
 return sorted(lengths,reverse=True)
results={'source':'A46 v1 cohesive torso','candidate':'A46 v2 organic 1px upper lean',
 'frame_component_sizes':[],'waist_pixel_rows_same_as_v1':[],
 'head_content_shifted_correctly':[],'wrist_body_distance':[],
 'tip_weapon_distance':[],'border_alpha':[],
 'torso_waist_overlap_rows':[], 'expected_lean':rig['coherent_upper_body_lean_px']}
for i in range(12):
 base=tile(v1,i);body=tile(v2,i);weapon=tile(ww,i);effect=tile(fx,i)
 pose=rig['pose_anchors'][i]
 lean=int(rig['coherent_upper_body_lean_px'][str(i)]) if str(i) in rig['coherent_upper_body_lean_px'] else int(rig['coherent_upper_body_lean_px'][i])
 results['frame_component_sizes'].append(groups(body))
 results['waist_pixel_rows_same_as_v1'].append(body.crop((0,42,64,64)).tobytes()==base.crop((0,42,64,64)).tobytes())
 good=True
 for y in range(0,34):
  for x in range(64):
   ref=base.getpixel((x-lean,y)) if 0<=x-lean<64 else (0,0,0,0)
   if body.getpixel((x,y))!=ref:good=False;break
  if not good:break
 results['head_content_shifted_correctly'].append(good)
 def nearest(im,px):
  x,y=px
  d=[math.hypot(X-x,Y-y) for X in range(max(0,x-4),min(64,x+5)) for Y in range(max(0,y-4),min(64,y+5)) if im.getpixel((X,Y))[3]>0]
  return round(min(d or [99]),3)
 if i in range(1,11):
  results['wrist_body_distance'].append(nearest(body,pose['wrist_px']))
  results['tip_weapon_distance'].append(nearest(weapon,pose['sword_tip_px']))
 else:
  results['wrist_body_distance'].append(None);results['tip_weapon_distance'].append(None)
 full=Image.new('RGBA',(64,64))
 for im in [body,weapon,effect]:full.alpha_composite(im)
 results['border_alpha'].append(sum(full.getpixel((x,y))[3]>0 for x,y in
  [(x,0) for x in range(64)]+[(x,63) for x in range(64)]+[(0,y) for y in range(64)]+[(63,y) for y in range(64)]))
 # Torso shoulder row41 to pelvis row42 (one-pixel taper, zero-pixel gap)
 overlap=sum(body.getpixel((x,41))[3]>0 and body.getpixel((x,42))[3]>0 for x in range(30,41))
 results['torso_waist_overlap_rows'].append(overlap)
assert all(len(g)==1 for g in results['frame_component_sizes']),results['frame_component_sizes']
assert all(results['waist_pixel_rows_same_as_v1'])
assert all(results['head_content_shifted_correctly'])
assert max(x for x in results['wrist_body_distance'] if x is not None)<=1.4,results['wrist_body_distance']
assert max(x for x in results['tip_weapon_distance'] if x is not None)<=1.4,results['tip_weapon_distance']
assert all(v==0 for v in results['border_alpha']),results['border_alpha']
assert min(results['torso_waist_overlap_rows'])>=7,results['torso_waist_overlap_rows']
gate=[sys.executable,str(p/'qa/a46_waist_gate.py'),
 '--candidate',str(a/'actor01_a46_body_v2_12frames.png'),
 '--reference',str(a/'actor01_a62_approved_idle_source_64.png')]
r=subprocess.run(gate,capture_output=True,text=True,timeout=20)
results['waist_gate_exit']=r.returncode;results['waist_gate_stdout']=r.stdout.strip()
assert r.returncode==0,(r.stdout,r.stderr)
results['qa']='PASS'
(p/'qa/A46_V2_COHERENT_MOTION_QA.json').write_text(json.dumps(results,indent=2),encoding='utf8')
print('A46_V2_MOTION_QA_PASS',json.dumps({'overlap':results['torso_waist_overlap_rows'],
 'wrist':results['wrist_body_distance'],'tip':results['tip_weapon_distance'],
 'gate':results['waist_gate_exit']}),flush=True)
