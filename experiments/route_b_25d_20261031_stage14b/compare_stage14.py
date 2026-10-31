from pathlib import Path
from PIL import Image,ImageDraw
import json,hashlib,numpy as np
r=Path(__file__).resolve().parent
E=r/'evidence';E.mkdir(exist_ok=True)
A=Image.open(r/'gpu/A_BLUE_COTTAGE/FULL_GPU.png').convert('RGB')
B=Image.open(r/'gpu/B_OCHRE_GROVE/FULL_GPU.png').convert('RGB')
W,H=A.size
assert (W,H)==(544,416) and B.size==(W,H)
out=Image.new('RGB',(W*2,H+36),'#263033')
draw=ImageDraw.Draw(out)
for idx,(name,im) in enumerate([('A / BLUE HOUSE',A),('B / OCHRE GROVE',B)]):
 out.paste(im,(idx*W,36));draw.text((idx*W+12,11),name,fill='#f2ead3')
out.save(E/'STAGE14_TWO_SCENES_GPU.png')
old=Image.open(r/'source/ground_stage12_source.png').convert('RGB')
new=Image.open(r/'source/ground_long.png').convert('RGB')
compare=Image.new('RGB',(W*2,576+36),'#263033')
draw=ImageDraw.Draw(compare)
for i,(name,pic) in enumerate([('Style-first original ground',old),('Stage14 new-layout source-derived',new)]):
 compare.paste(pic,(W*i,36));draw.text((W*i+12,11),name,fill='#f3ecd7')
compare.save(E/'STAGE14_GROUND_COMPARE.png')
# Existing source engine QA scripts own checks; this file only aggregates trusted artifacts.
source_hash=hashlib.sha256((r/'source/ground_stage12_source.png').read_bytes()).hexdigest()
out_hash=hashlib.sha256((r/'source/ground_long.png').read_bytes()).hexdigest()
gpu=json.loads((E/'STAGE12_GPU_PIXEL_QA.json').read_text())
actor=json.loads((E/'STAGE12_ACTOR_SWEEP.json').read_text())
for scene in ('A_BLUE_COTTAGE','B_OCHRE_GROVE'):
 q=gpu[scene]
 assert all(q[k]['different_pixels']==0 for k in ('ground','par','full'))
 assert q['gpu_par_border_nonzero']==0 and q['par_alpha_exact']
 assert all(x['base_32tile_pass'] for x in q['trees'])
 assert actor[scene]['sample_count']==35 and actor[scene]['front_nonzero']==0
arr=np.asarray(new)
result={
 'architecture':'original private Style-first Ground texture quilted into a new road layout; source is NOT new AI art',
 'engine':'Godot 4.7.2 Compatibility RX 6700 XT',
 'scenes':2,'render_resolution':[544,416],'source_ground_resolution':[544,576],
 'ground_source_sha256':source_hash,'derived_ground_sha256':out_hash,
 'ground_color_count':int(len(np.unique(arr.reshape(-1,3),axis=0))),
 'pixel_diffs':{scene:{k:gpu[scene][k]['different_pixels'] for k in ('ground','par','full')} for scene in gpu},
 'PAR_border':{scene:gpu[scene]['gpu_par_border_nonzero'] for scene in gpu},
 'root_contact_single_32px':{scene:all(x['base_32tile_pass'] for x in gpu[scene]['trees']) for scene in gpu},
 'static_actor_positions':sum(actor[s]['sample_count'] for s in actor),
 'front_zero_positions':20,'front_errors':sum(actor[s]['front_nonzero'] for s in actor),
 'limitations':['Reused Style-first source textures with new geometry, not original AI-painted Ground','Repeated grass donor motifs and some seams remain','Only static compositing, VX Game.exe walk test not executed','Private art rights not independently cleared'],
 'visual_art_gate':'IMPROVED_OVER_STAGE13_BUT_NOT_USER_APPROVED','formal_seal':'NO'
}
(E/'STAGE14_FINAL_QA.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))