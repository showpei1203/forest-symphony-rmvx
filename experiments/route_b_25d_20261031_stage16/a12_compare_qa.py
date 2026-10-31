from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,shutil
R=Path(__file__).resolve().parent
A11=R/'A12_COMPARATOR_A11_544x416.png'
assert A11.is_file()
assert A11.stat().st_size>0
def load(n):
 with Image.open(R/n) as im:
  assert im.size==(544,416)
  return np.asarray(im.convert('RGB'),dtype='uint8').copy()
A10=load('A12_INPUT_A10_BENCHMARK_GROUND_544x416.png')
A11=load('A12_COMPARATOR_A11_544x416.png')
A12=load('A12_ECOLOGICAL_CLUSTERS_544x416.png')
with Image.open(R/'A12_INPUT_A10_BENCHMARK_ROAD_MASK_544x416.png') as im:road=np.asarray(im.convert('L'))>0
with Image.open(R/'A12_INPUT_A10_BENCHMARK_EDGE_BAND_544x416.png') as im:edge=np.asarray(im.convert('L'))>0
protected=road|edge
assert protected.sum()==47649
def stats(a,b,region):
 p=np.abs(a.astype('float64')-b.astype('float64'))
 ch=np.any(p>0,axis=2)
 return {'changed':int(np.count_nonzero(ch&region)),'fraction_changed':round(float(ch[region].mean()),6),'mean_abs_rgb_channel_difference':round(float(p[region].mean()),4),'max_channel_change':int(p[region].max())}
masks={}
for kind in ('DENSE','DRY','FLOWER'):
 with Image.open(R/('A12_'+kind+'_BLUEPRINT_MASK.png')) as im:masks[kind.lower()]=np.asarray(im.convert('L'))>130
flowers=np.asarray(Image.open(R/'A12_FLOWER_PIXELS_MASK.png').convert('L'))>0
leaves=np.asarray(Image.open(R/'A12_LEAF_PIXELS_MASK.png').convert('L'))>0
soils=np.asarray(Image.open(R/'A12_SOIL_PIXELS_MASK.png').convert('L'))>0
assert not np.any((flowers|leaves|soils)&protected)
for z in ('dense','dry','flower'):assert masks[z].sum()>1000
flower_concentration=int(np.count_nonzero(flowers&masks['flower']))/max(int(flowers.sum()),1)
leaves_concentration=int(np.count_nonzero(leaves&masks['dense']))/max(int(leaves.sum()),1)
road_a10_a12=stats(A10,A12,protected)
assert road_a10_a12['changed']==0
qa={'stage':'A12','date':'2026-10-31','resolution':[544,416],'road_mask_px':int(road.sum()),'edge_px':int(edge.sum()),'protected_px':int(protected.sum()),'editable_px':int((~protected).sum()),'A11_vs_A10_editable':stats(A10,A11,~protected),'A12_vs_A10_editable':stats(A10,A12,~protected),'A12_vs_A11_editable':stats(A11,A12,~protected),'protected_A10_vs_A12':road_a10_a12,'flower_pixel_concentration_inside_blueprint':round(flower_concentration,4),'leaf_pixel_concentration_inside_blueprint':round(leaves_concentration,4),'leaf_pixel_count':int(leaves.sum()),'flower_pixel_count':int(flowers.sum()),'soil_pixel_count':int(soils.sum()),'art_status':'FAIL_INTERNAL_VISUAL_GROUND3','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO','note':'Pixel difference and concentration are not art quality indicators.'}
(R/'A12_A10_A11_COMPARATIVE_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf8')
# True original 1x tri-panel, image size intentionally expands horizontally only, no resampling.
sheet=Image.new('RGB',(3*546,447),(22,24,26));d=ImageDraw.Draw(sheet)
for i,(lab,data) in enumerate([('A10 base | original 544x416',A10),('A11 dispersed ecology | 544x416',A11),('A12 semantic ecology clusters | 544x416',A12)]):
 x=i*546+1;d.text((x+2,6),lab,fill='white');sheet.paste(Image.fromarray(data),(x,28))
sheet.save(R/'A12_A10_A11_1X_TRI_PANEL.png')
# 32px NEAREST source detail at areas in cluster types; repeat exact coordinates across methods.
regions=[('upper west flowers',92,142),('lower left mixed turf',88,327),('east flower field',463,100),('road control',258,150)]
l=Image.new('RGB',(3*258,4*280),(21,23,25));dr=ImageDraw.Draw(l)
for row,(name,x,y) in enumerate(regions):
 for col,(label,data) in enumerate([('A10',A10),('A11',A11),('A12',A12)]):
  x0=col*258;y0=row*280
  dr.text((x0+3,y0+3),name+' / '+label,fill='white')
  sample=Image.fromarray(data).crop((x,y,x+32,y+32)).resize((256,256),Image.Resampling.NEAREST)
  l.paste(sample,(x0,y0+20))
l.save(R/'A12_32PX_FOUR_AREAS_COMPARE.png')
# Blueprint overlay for review only, avoid changing source output.
color=np.zeros((416,544,3),dtype=np.uint8)
color[masks['dense']]=[42,118,52]
color[masks['dry']]=[160,128,58]
color[masks['flower']]=[176,103,167]
color[protected]=[67,79,86]
Image.fromarray(color,'RGB').save(R/'A12_ECOLOGICAL_SEMANTIC_MAP.png')
print('A12_COMPARISON_QA',json.dumps(qa,ensure_ascii=False,indent=2),flush=True)
