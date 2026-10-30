from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np
r=Path(__file__).resolve().parent
variants=[('STAGE10 C (SOURCE)','baseline_stage10'),('STAGE11 A (BROAD)','candidates/A_BROAD'),('STAGE11 B (FINE)','candidates/B_FINE'),('STAGE11 C (PRUNED)','candidates/C_PRUNED')]
W,H=544,416
im=Image.new('RGB',(W*2,H*2+76),(26,36,42))
D=ImageDraw.Draw(im)
baseg=np.asarray(Image.open(r/'baseline_stage10/GROUND.png').convert('RGB'))
basep=np.asarray(Image.open(r/'baseline_stage10/PAR.png').convert('RGBA'))
zones={'WEST':(27,12,155,202),'EAST':(412,18,529,206),'HOUSE':(171,118,381,303)}
reports=[]
for i,(label,rel) in enumerate(variants):
 p=r/rel
 comp=Image.open(p/'COMPOSITE_PREVIEW.png').convert('RGB')
 ground=np.asarray(Image.open(p/'GROUND.png').convert('RGB'))
 par=np.asarray(Image.open(p/'PAR.png').convert('RGBA'))
 qa=json.loads((p/'QA_REPORT.json').read_text())
 assert comp.size==(W,H)
 xx=i%2*W; yy=i//2*(H+38)
 D.text((xx+10,yy+12),label,fill=(246,243,225))
 im.paste(comp,(xx,yy+38))
 diff=np.any(par!=basep,axis=2)
 region={}
 for key,(x0,y0,x1,y1) in zones.items():
  region[key]=int(np.sum(diff[y0:y1,x0:x1]))
 row={'label':label,'par_new_opaque':int(np.sum((par[:,:,3]>0)&(basep[:,:,3]==0))),
 'par_lost_opaque':int(np.sum((par[:,:,3]==0)&(basep[:,:,3]>0))),
 'par_alpha_changed':int(np.sum(par[:,:,3]!=basep[:,:,3])),
 'ground_changed_pixels':int(np.sum(np.any(ground!=baseg,axis=2))),
 'full_vs_2layers_diff':int(qa['full_vs_alpha_composite_differing_pixel_count']),
 'par_border_violations':int(qa['par_border_nonzero']),'regions_changed':region}
 reports.append(row)
im.save(r/'out/STAGE11_4WAY_NATIVE_1X.png')
# Native crop enlarged for visual inspection only, not distributed as source Ground/PAR.
zoom=Image.new('RGB',(4*272,420),(28,35,42))
z=ImageDraw.Draw(zoom)
for i,(label,rel) in enumerate(variants):
 src=Image.open(r/rel/'COMPOSITE_PREVIEW.png').convert('RGB')
 patch=src.crop((35,19,150,202)).resize((220,360),Image.Resampling.NEAREST)
 zoom.paste(patch,(i*272+25,45))
 z.text((i*272+9,12),label,fill=(241,238,214))
zoom.save(r/'out/STAGE11_TREE_DETAIL_4WAY.png')
stats={'stage':'STAGE11','resolution':[W,H],'authority':'One source 3D scene + native separately rendered Ground/PAR, geometry authored in Stage11','candidates':reports,
 'selected_candidate':'C_PRUNED_RESEARCH_ONLY','visual_reference_pass':False,'formal_seal':False,
 'caveat':'Pixel change is not an aesthetic score, reference Ground3 is higher fidelity.'}
(r/'out/STAGE11_GEOMETRY_QA.json').write_text(json.dumps(stats,indent=2,ensure_ascii=False),encoding='utf-8')
assert all(x['ground_changed_pixels']==0 for x in reports), 'Source Ground was changed'
assert all(x['par_lost_opaque']==0 for x in reports), 'Existing PAR unexpectedly lost occlusion'
assert all(x['par_border_violations']==0 for x in reports),'PAR leaked into canvas border'
print(json.dumps(stats,ensure_ascii=False,indent=2))