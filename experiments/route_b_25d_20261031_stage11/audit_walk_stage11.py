from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np
root=Path(__file__).resolve().parent
p=root/'candidates/C_PRUNED'
actor=np.asarray(Image.open(root/'out/ACTOR_TEST_32.png').convert('RGBA').getchannel('A'))>0
par=np.asarray(Image.open(p/'PAR.png').convert('RGBA').getchannel('A'))>0
contacts=json.loads((p/'CONTACT_32_GRID_AUDIT.json').read_text())['trees']
offsets_x=[-24,-12,0,12,24]
offsets_y=[-48,-32,-16,0,16,32,48]
rows=[]
img=Image.new('RGB',(980,530),(29,36,43))
draw=ImageDraw.Draw(img)
for ti,tree in enumerate(contacts):
 name=tree['name']
 rect=tree['rect']
 centerx=(rect[0]+rect[2])//2
 contacty=rect[3]
 x0=ti*490
 draw.text((x0+12,15),f'{name} / 35 actor walk positions',fill=(244,241,223))
 for ci,dx in enumerate(offsets_x):
  draw.text((x0+75+ci*78,64),f'{dx:+d} x',fill=(201,210,201))
 for ri,dy in enumerate(offsets_y):
  draw.text((x0+8,93+ri*55),f'{dy:+d} y',fill=(221,217,201))
  for ci,dx in enumerate(offsets_x):
   feet_x=centerx+dx
   feet_y=contacty+dy
   left=feet_x-16
   top=feet_y-32
   aa=np.zeros_like(par)
   ax0=max(0,left);ay0=max(0,top);ax1=min(544,left+32);ay1=min(416,top+32)
   if ax1>ax0 and ay1>ay0:
    aa[ay0:ay1,ax0:ax1]=actor[ay0-top:ay1-top,ax0-left:ax1-left]
   actor_pixels=int(aa.sum())
   occ=int(np.sum(aa&par))
   frac=round(100*occ/max(1,actor_pixels),2)
   pos=(x0+72+ci*78,85+ri*55)
   if frac==0:
    fill=(48,101,78)
   elif frac<30:
    fill=(121,99,59)
   else:
    fill=(134,70,61)
   draw.rounded_rectangle((pos[0],pos[1],pos[0]+72,pos[1]+41),radius=6,fill=fill)
   draw.text((pos[0]+11,pos[1]+13),f'{frac:.1f}%',fill=(255,248,224))
   rows.append({'tree':name,'x_delta':dx,'y_delta':dy,'actor_covered_pct':frac,'occluded_px':occ})
draw.text((20,500),'Overlay order: native GROUND -> actual 32x32 actor -> native PAR; positions relative to tree contact bottom',fill=(221,217,206))
img.save(root/'out/STAGE11_ACTOR_WALK_SWEEP_70.png')
front=[row for row in rows if row['y_delta'] in (16,32)]
rear=[row for row in rows if row['y_delta'] in (-32,-16)]
report={'sample_count':len(rows),'horizontal_offsets_px':offsets_x,'vertical_offsets_px':offsets_y,
 'front_20_tests':len(front),'front_nonzero':sum(x['actor_covered_pct']>0 for x in front),
 'front_max_occluded_pct':max(x['actor_covered_pct'] for x in front),
 'front_disagreements':[x for x in front if x['actor_covered_pct']>0],
 'rear_20_tests':len(rear),'rear_max_occluded_pct':max(x['actor_covered_pct'] for x in rear),
 'tests':rows,'limitations':['No true RPG Maker VX runtime movement or depth-sort','Static actor layering with fixed PAR','Tree contacts from exact Stage10 rendered 544x416 screen coordinates'],
 'formal_seal':False}
(root/'out/STAGE11_ACTOR_WALK_SWEEP_QA.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('SAMPLES',len(rows),'FRONT_NONZERO',report['front_nonzero'],'FRONT_MAX',report['front_max_occluded_pct'])
print('FRONT_ERRORS',report['front_disagreements'][:12])
