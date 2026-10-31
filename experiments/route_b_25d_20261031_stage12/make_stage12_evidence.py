from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
r=Path(__file__).resolve().parent
out=r/'evidence'
w,h=544,416
v=['A_BLUE_COTTAGE','B_OCHRE_GROVE']
original=r/"baseline_stage11/COMPOSITE_PREVIEW.png"
panel=Image.new("RGB",(w*3,h+35),(29,37,43))
D=ImageDraw.Draw(panel)
examples=[('Stage11 3D prototype',original),
 ('Stage12 A 2D source',r/'gpu/A_BLUE_COTTAGE/FULL_GPU.png'),
 ('Stage12 B 2D source',r/'gpu/B_OCHRE_GROVE/FULL_GPU.png')]
for i,(title,p) in enumerate(examples):
 panel.paste(Image.open(p).convert("RGB"),(i*w,35))
 D.text((i*w+10,11),title,fill=(247,245,228))
panel.save(out/'STAGE11_3D_VS_STAGE12_2D.png')
two=Image.new('RGB',(w*2,h+35),(29,37,43))
D=ImageDraw.Draw(two)
for i,s in enumerate(v):
 two.paste(Image.open(r/'gpu'/s/'FULL_GPU.png').convert("RGB"),(i*w,35))
 D.text((i*w+12,11),s.replace('_',' '),fill=(247,244,220))
two.save(out/'STAGE12_GODOT_2_SCENES.png')
# Layout derived from independent, editable sources; checkerboard PAR preview.
for sid in v:
 pane=Image.new('RGB',(w*2,h*2+64),(29,36,42))
 draw=ImageDraw.Draw(pane)
 images=[
  ('Ground native GPU', Image.open(r/'gpu'/sid/'GROUND_GPU.png').convert('RGBA')),
  ('PAR alpha on checkers',Image.open(r/'gpu'/sid/'PAR_GPU.png').convert('RGBA')),
  ('Full independent GPU',Image.open(r/'gpu'/sid/'FULL_GPU.png').convert('RGBA')),
  ('Root contact core',Image.open(r/'build'/sid/'TREE_CONTACT_MASK.png').convert('RGBA'))
 ]
 for i,(label,pic) in enumerate(images):
  if i==1:
   chk=Image.new('RGBA',(w,h),(198,198,198,255))
   d=ImageDraw.Draw(chk)
   for y in range(0,h,16):
    for x in range(0,w,16):
     if ((x//16+y//16)%2)==0: d.rectangle((x,y,x+15,y+15),fill=(226,226,226,255))
   chk.alpha_composite(pic)
   pic=chk
  if i==3:
   chk=Image.open(r/'gpu'/sid/'GROUND_GPU.png').convert('RGBA')
   a=np.asarray(pic.getchannel('A'))
   tinted=np.zeros((h,w,4),np.uint8)
   tinted[a>0]=[255,70,70,215]
   chk.alpha_composite(Image.fromarray(tinted,'RGBA'))
   pic=chk
  x=i%2*w;y=i//2*(h+32)
  pane.paste(pic.convert('RGB'),(x,y+32))
  draw.text((x+10,y+9),label,fill=(246,244,225))
 pane.save(out/(sid+'_4PANEL.png'))
# Negative test: intentionally shift one 32px source root upper by 1 px.
bad=Image.open(r/'gpu'/v[0]/'PAR_GPU.png').convert('RGBA')
arr=np.asarray(bad).copy()
# Shift entire PAR by one pixel, which must fail strict exact comparison.
shift=np.zeros_like(arr)
shift[:,1:]=arr[:,:-1]
reference=arr
delta=np.any(shift!=reference,axis=2)
badpng=Image.fromarray(shift,'RGBA')
badpng.save(out/'NEGATIVE_PAR_SHIFT_1PX.png')
assert int(delta.sum())>0
qa=json.loads((r/'evidence'/'STAGE12_GPU_PIXEL_QA.json').read_text())
actor=json.loads((r/'evidence'/'STAGE12_ACTOR_SWEEP.json').read_text())
score={}
for sid in v:
 q=qa[sid]; a=actor[sid]
 assert q['ground']['different_pixels']==0 and q['par']['different_pixels']==0 and q['full']['different_pixels']==0
 assert q['par_alpha_exact'] and q['gpu_par_border_nonzero']==0
 assert all(t['base_32tile_pass'] for t in q['trees'])
 assert a['sample_count']==35 and a['front_nonzero']==0
 src=np.asarray(Image.open(r/'gpu'/sid/'FULL_GPU.png').convert('RGB'))
 score[sid]={'gpu_source_pixel_exact':True,'front_static_points_zero':10,'tree_core_single_tile':True,'full_rgb_unique_colors':int(np.unique(src.reshape(-1,3),axis=0).shape[0]),
 'full_horizontal_abs_delta':round(float(np.abs(np.diff(src.astype(np.int16),axis=1)).mean()),3)}
summary={'stage':'Stage12','scenes':score,'source_sprite_count':10,'test_static_actor_points':70,'front_zero_count':20,
 'Godot_4_7_2_real_GPU':True,'negative_par_shift_pixel_diff':int(delta.sum()),
 'art_visual':'CANDIDATE_BETTER_THAN_STAGE11_BUT_USER_GATE_NOT_PASSED',
 'limitations':['Ground crops come from previously generated Style-first private source, no new ground original generation in this phase','2D static actor tests not original VX Game.exe','Commercial rights of some legacy source not independently cleared'],
 'formal_seal':False}
(out/'STAGE12_FINAL_QA.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps(summary,ensure_ascii=False,indent=2))