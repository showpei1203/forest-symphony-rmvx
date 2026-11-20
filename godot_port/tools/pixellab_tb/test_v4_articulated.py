#!/usr/bin/env python3
"""Source-locked QA for PMD0001 V4, deliberately NOT an ART PASS validator."""
from pathlib import Path
from PIL import Image
import hashlib, json, os
import numpy as np

HERE=Path(__file__).resolve().parent
O=Path(os.environ.get('TB_ATTACK_V4_OUTPUT',str(HERE/'v4_articulated')))
SOURCE=Path(os.environ.get('TB_PMD0001_SOURCE',str(HERE.parent/'assets/PMD0001_STATIC_64.png')))
A=np.asarray(Image.open(SOURCE).convert('RGBA'))
S=np.asarray(Image.open(O/'PMD0001_ATTACK_V4_11F_384x288.png').convert('RGBA'))
M=json.loads((O/'PMD0001_ATTACK_V4_MANIFEST.json').read_text(encoding='utf8'))
assert S.shape==(288,384,4) and len(M['poses'])==11
f=[S[(i//4)*96:(i//4+1)*96,(i%4)*96:(i%4+1)*96,:] for i in range(11)]
checks=[]
def ok(check,cond):
 checks.append((check,bool(cond)))
 assert cond,check

ok('source_hash_matches_frozen_authority',hashlib.sha256(SOURCE.read_bytes()).hexdigest()==M['source_sha256'])
exact=np.zeros((96,96,4),dtype=np.uint8);exact[24:88,16:80,:]=A
ok('frame0_exact_approved_source',np.array_equal(f[0],exact))
ok('frame10_exact_approved_source',np.array_equal(f[10],exact))
ok('ten_independent_rasters_including_first_end_repeat',len(set(hashlib.sha256(p.tobytes()).hexdigest() for p in f))==10)
ok('all_frames_raster_inside_96px_canvas',all(p[0].max()==0 and p[-1].max()==0 and p[:,0].max()==0 and p[:,-1].max()==0 for p in f))
ok('all_frames_nonempty',all((p[:,:,3]>0).sum()>100 for p in f))
ok('hit_event_index_is_5',M['events']['hit']==5)
ok('rush_return_events_unchanged',(M['events']['rush'],M['events']['return'])==(2,7))
ok('attack_durations_source_locked',M['durations_ticks']==[4,2,4,2,2,2,2,2,2,2,4])
ok('feet_have_independent_target_poses',all(tuple(p['rear'])!=tuple(p['near']) for p in M['poses'][2:8]))
ok('lower_jaw_extends_at_hit',M['poses'][5]['jaw']>=4)
# Does the front lunge deviate strongly from mere rigid translation of source?
for i in [3,5,7]:
 pose=M['poses'][i];dy,dx=pose['root'][1],pose['root'][0]
 shifted=np.zeros_like(f[i]);
 y0=max(0,dy); y1=min(96,96+dy); x0=max(0,dx);x1=min(96,96+dx)
 shifted[y0:y1,x0:x1]=exact[y0-dy:y1-dy,x0-dx:x1-dx]
 different=((f[i]!=shifted).any(axis=2)&((f[i][:,:,3]>0)|(shifted[:,:,3]>0))).sum()
 ok(f'F{i}_not_pure_rigid_translate_{different}_pixels',int(different)>=70)
# source alpha remains transparent far from frog
ok('source_alpha_not_baked',np.all(f[0][0,0]==0))
ok('all_source_images_are_unchanged_by_builder',hashlib.sha256(SOURCE.read_bytes()).hexdigest()=='fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c')

report={'status':'TECHNICAL_QA_PASS_ART_HOLD','count':len(checks),'checks':[{'name':n,'passed':v} for n,v in checks], 'native_godot':'NOT_RUN','pixel_lab_generation_jobs':0,'art': 'HOLD'}
(O/'PMD0001_ATTACK_V4_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
print('V4 SOURCE / FRAME / ARTICULATION CODE QA:',len(checks),'/',len(checks),'PASS; native Godot NOT_RUN; visual ART HOLD')
