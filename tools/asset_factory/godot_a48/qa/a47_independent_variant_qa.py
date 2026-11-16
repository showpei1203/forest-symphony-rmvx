from pathlib import Path
from PIL import Image
import json,math,subprocess,sys,hashlib
p=Path(__file__).resolve().parents[1];a=p/'assets'
source=Image.open(a/'actor01_a46_body_12frames.png').convert('RGBA')
baseline=Image.open(a/'actor01_a46_body_v1_12frames.png').convert('RGBA')
weapon=Image.open(a/'actor01_a46_weapon_12frames.png').convert('RGBA')
rig=json.loads((a/'actor01_a46_attack_anchors.json').read_text(encoding='utf8'))['pose_anchors']
def frame(im,i):
 return im.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
def comp(im):
 pts={(x,y) for y in range(64) for x in range(64) if im.getpixel((x,y))[3]>0}
 out=[]
 while pts:
  cur=pts.pop();queue=[cur];cnt=1
  while queue:
   x,y=queue.pop()
   for nx in range(x-1,x+2):
    for ny in range(y-1,y+2):
     if (nx,ny) in pts:
      pts.remove((nx,ny));queue.append((nx,ny));cnt+=1
  out.append(cnt)
 return sorted(out,reverse=True)
def near(im,pt):
 x,y=pt
 return min([math.hypot(x-xx,y-yy) for yy in range(max(0,y-5),min(64,y+6)) for xx in range(max(0,x-5),min(64,x+6)) if im.getpixel((xx,yy))[3]>0] or [99])
report={'stage':'A47','source_stage':'A46 V1 canonical full-body; A46 V2 comparator','candidates':{}}
for version in ['R1','R2','R3']:
 candidate=a/('actor01_a47_body_'+version+'_12frames.png')
 c=Image.open(candidate).convert('RGBA')
 val={'version':version,'sha256':hashlib.sha256(candidate.read_bytes()).hexdigest(),
 'body_connected_components':[],'waist':None,'per_frame_alpha_border':[],
 'planted_feet_unchanged':[],'wrist_to_body_distance':[],
 'delta_pixels_vs_A46V2':[],'delta_torso_px':[],'delta_head_px':[],
 'frame_unique':len(set(frame(c,i).tobytes() for i in range(12)))}
 for i in range(12):
  old=frame(source,i);before=frame(baseline,i);v=frame(c,i)
  val['body_connected_components'].append(comp(v))
  val['planted_feet_unchanged'].append(v.crop((0,47,64,64)).tobytes()==before.crop((0,47,64,64)).tobytes())
  val['delta_pixels_vs_A46V2'].append(sum(q!=t for q,t in zip(v.get_flattened_data(),old.get_flattened_data())))
  val['delta_torso_px'].append(sum(q!=t for q,t in zip(v.crop((24,34,46,44)).get_flattened_data(),old.crop((24,34,46,44)).get_flattened_data())))
  val['delta_head_px'].append(sum(q!=t for q,t in zip(v.crop((18,14,45,34)).get_flattened_data(),old.crop((18,14,45,34)).get_flattened_data())))
  val['per_frame_alpha_border'].append(sum(v.getpixel((x,y))[3]>0 for x,y in
    [(z,0) for z in range(64)]+[(z,63) for z in range(64)]+[(0,z) for z in range(64)]+[(63,z) for z in range(64)]))
  if 1<=i<=10:
   val['wrist_to_body_distance'].append(round(near(v,rig[i]['wrist_px']),2))
  else:val['wrist_to_body_distance'].append(None)
 gate=subprocess.run([sys.executable,str(p/'qa/a46_waist_gate.py'),'--candidate',str(candidate),
  '--reference',str(a/'actor01_a62_approved_idle_source_64.png')],capture_output=True,text=True,encoding='utf8',errors='replace',timeout=20)
 val['waist_gate_exit']=gate.returncode
 val['waist_gate_output']=gate.stdout.strip()
 val['technical_pass']=all(len(g)==1 for g in val['body_connected_components']) and all(val['planted_feet_unchanged']) and max(val['per_frame_alpha_border'])==0 and max(d for d in val['wrist_to_body_distance'] if d is not None)<=1.5 and gate.returncode==0
 report['candidates'][version]=val
 print('A47_VARIANT_QA',version,'PASS',val['technical_pass'],'WAIST',val['waist_gate_exit'],
 'CONNECTIONS',val['body_connected_components'],'TORSO',val['delta_torso_px'],'HEAD',val['delta_head_px'],flush=True)
(p/'qa/A47_VARIANT_VISUAL_GEOMETRY_QA.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf8')
