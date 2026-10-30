from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np,json
r=Path(__file__).resolve().parent
items=[
 ('STAGE 9 BASELINE','baseline_stage9'),
 ('A / ELLIPSOID LOBES','candidates/A_LOBES'),
 ('B / SCATTERED LEAF FANS','candidates/B_SPRAYS_SCATTERED'),
 ('C / WOVEN LEAF ROSETTES','candidates/C_WOVEN_LEAF_ROSETTES')
]
W,H=544,416
canvas=Image.new('RGB',(W*2,H*2+74),(27,36,43))
pen=ImageDraw.Draw(canvas)
base_ground=np.asarray(Image.open(r/'baseline_stage9/GROUND.png').convert('RGB'))
base_par=np.asarray(Image.open(r/'baseline_stage9/PAR.png').convert('RGBA'))
rows=[]
trees={'WEST':(28,16,157,200),'EAST':(408,15,530,202)}
for i,(title,loc) in enumerate(items):
 p=r/loc
 im=Image.open(p/'COMPOSITE_PREVIEW.png').convert('RGB')
 g=np.asarray(Image.open(p/'GROUND.png').convert('RGB'))
 par=np.asarray(Image.open(p/'PAR.png').convert('RGBA'))
 qa=json.loads((p/'QA_REPORT.json').read_text())
 c=i%2
 row=i//2
 top=row*(H+37)
 canvas.paste(im,(c*W,top+37))
 pen.text((c*W+12,top+10),title,fill=(248,245,224))
 assert np.array_equal(g,base_ground),'Ground is not invariant'
 par_new=np.any(par!=base_par,axis=2)
 by_tree={name:int(np.sum(par_new[y0:y1,x0:x1])) for name,(x0,y0,x1,y1) in trees.items()}
 alpha_new=par[:,:,3]>0
 alpha_old=base_par[:,:,3]>0
 metrics={'version':title,'diff_3d_vs_2layer':int(qa['full_vs_alpha_composite_differing_pixel_count']),
 'par_alpha_changed':int(np.sum(par[:,:,3]!=base_par[:,:,3])),'added_par_pixels':int(np.sum(alpha_new&~alpha_old)),
 'lost_par_pixels':int(np.sum(alpha_old&~alpha_new)),'ground_rgb_changed':int(np.sum(np.any(g!=base_ground,axis=2))),
 'tree_zone_changed_pixels':by_tree,'par_border':int(qa['par_border_nonzero'])}
 rows.append(metrics)
canvas.save(r/'out/STAGE10_GEOMETRY_ABCD_1X.png')
zoom=Image.new('RGB',(1280,420),(28,35,43))
d=ImageDraw.Draw(zoom)
for i,(title,loc) in enumerate(items):
 im=Image.open(r/loc/'COMPOSITE_PREVIEW.png').convert('RGB')
 crop=im.crop((27,22,156,199)).resize((260,356),Image.Resampling.NEAREST)
 left=i*320+30
 zoom.paste(crop,(left,42))
 d.text((i*320+12,10),title[:26],fill=(248,245,224))
zoom.save(r/'out/STAGE10_WEST_TREE_4WAY_ZOOM.png')
(r/'out/STAGE10_GEOMETRY_QA.json').write_text(json.dumps({'variants':rows,'native_render_resolution':[W,H],'source_first_3d_geometry':True,'source_reference':'Stage9 CC0 oak GLB','ground_unchanged_for_all_variants':True,'art_pass':False,'formal_seal':False},indent=2),encoding='utf-8')
for x in rows: print(x)