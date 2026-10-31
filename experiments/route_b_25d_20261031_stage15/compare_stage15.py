from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np,hashlib
R=Path(__file__).resolve().parent
E=R/'evidence'
modes=[('STAGE14 B | HARD QUILT',R/'baseline_stage14/ground_long.png'),
       ('STAGE15 | MIN-ERROR SEAMS',R/'source/ground_long.png')]
canvas=Image.new('RGB',(1088,612),'#27313a')
p=ImageDraw.Draw(canvas)
for i,(title,f) in enumerate(modes):
 img=Image.open(f).convert('RGB');assert img.size==(544,576)
 canvas.paste(img,(544*i,36));p.text((544*i+12,12),title,fill='#f8f4de')
canvas.save(E/'STAGE14B_VS_STAGE15_GROUND_1X.png')
scenes=['A_BLUE_COTTAGE','B_OCHRE_GROVE']
side=Image.new('RGB',(1088,452),'#27313a')
D=ImageDraw.Draw(side)
q=json.loads((E/'STAGE12_GPU_PIXEL_QA.json').read_text())
a=json.loads((E/'STAGE12_ACTOR_SWEEP.json').read_text())
for i,s in enumerate(scenes):
 img=Image.open(R/'gpu'/s/'FULL_GPU.png').convert('RGB')
 side.paste(img,(544*i,36));D.text((544*i+12,12),s,fill='#f8f4de')
 assert all(q[s][key]['different_pixels']==0 for key in ['ground','par','full'])
 assert q[s]['par_alpha_exact'] and q[s]['gpu_par_border_nonzero']==0
 assert all(t['base_32tile_pass'] for t in q[s]['trees'])
 assert a[s]['sample_count']==35 and a[s]['front_nonzero']==0
side.save(E/'STAGE15_TWO_GODOT_SCENES.png')
# Comparative metric on hard-cut lines: descriptive only, never a formal art threshold.
scores={}
for name,source in modes:
 arr=np.array(Image.open(source).convert('RGB'),dtype=np.float32)
 dx=np.abs(np.diff(arr,axis=1)).mean(axis=2);dy=np.abs(np.diff(arr,axis=0)).mean(axis=2)
 scores[name]={'luma_hard_edges_gt50_percent':round(100*float(((dx>50).sum()+(dy>50).sum())/(dx.size+dy.size)),3),
               'rgb_unique':int(np.unique(arr.astype(np.uint8).reshape(-1,3),axis=0).shape[0])}
# Fail-closed negative: intentionally shifted PAR should NEVER pass strict alpha pixel parity
pa=np.array(Image.open(R/'gpu'/scenes[0]/'PAR_GPU.png').convert('RGBA'))
one=np.zeros_like(pa);one[:,1:]=pa[:,:-1]
neg=int(np.count_nonzero(np.any(one!=pa,axis=2)));assert neg>0
Image.fromarray(one,'RGBA').save(E/'NEGATIVE_PAR_SHIFT_1PX.png')
result={
 'source':'derived from old Style-first independent Ground; no new AI source image',
 'engine':'Godot 4.7.2 Compatibility, not VX',
 'input_size':[544,576],'render_size':[544,416],
 'scenes':{s:{k:q[s][k]['different_pixels'] for k in ['ground','par','full']} for s in scenes},
 'border_alpha':{s:q[s]['gpu_par_border_nonzero'] for s in scenes},
 'contacts_single_tile':{s:all(t['base_32tile_pass'] for t in q[s]['trees']) for s in scenes},
 'actor_static_positions':70,'front_zero_positions':20,'front_errors':sum(a[s]['front_nonzero'] for s in scenes),
 'negative_one_pixel_shift_diff':neg,
 'descriptive_color_gradient_not_quality_score':scores,
 'art_gate':'FAIL_PENDING_GROUND3_QUALITY','vx_gate':'NOT_RUN','formal_seal':False
}
(E/'STAGE15_QA.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(result,ensure_ascii=False,indent=2))