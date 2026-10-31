from pathlib import Path
from PIL import Image,ImageDraw
import json,numpy as np,hashlib,shutil
ROOT=Path(__file__).resolve().parent
SRC=Path(r'E:\FS_ROUTE_B_STAGE16_A12_ECOLOGICAL_CLUSTERS_20261031')
inputs={
'A13_A12_TINT_BASE_544x416.png':'A12_TINT_ONLY_544x416.png',
'A13_A12_FINAL_COMPARATOR_544x416.png':'A12_ECOLOGICAL_CLUSTERS_544x416.png',
'A13_FLOWER_BLUEPRINT.png':'A12_FLOWER_BLUEPRINT_MASK.png',
'A13_DENSE_BLUEPRINT.png':'A12_DENSE_BLUEPRINT_MASK.png',
'A13_DRY_BLUEPRINT.png':'A12_DRY_BLUEPRINT_MASK.png',
'A13_SOIL_LEGAL_PIXELS.png':'A12_SOIL_PIXELS_MASK.png',
'A13_PROTECTED_MASK.png':'A12_PROTECTED_MASK.png',
'A13_A10_ROAD_MASK.png':'A12_INPUT_A10_BENCHMARK_ROAD_MASK_544x416.png',
'A13_A10_EDGE_MASK.png':'A12_INPUT_A10_BENCHMARK_EDGE_BAND_544x416.png'}
for name,src in inputs.items():
 a=SRC/src;dst=ROOT/name
 if dst.exists():
  assert dst.stat().st_size>0,dst
 else:
  assert a.exists(),a
  shutil.copy2(a,dst)
N=16
# Deliberately authored low-profile, side-free 16x16 pixel motifs, RGBA 0/255 only.
C={'shadow':(34,83,23,255),'leaf':(73,136,35,255),'highlight':(132,184,57,255),'olive':(100,129,36,255),
   'center':(168,137,40,255),'white':(240,223,178,255),'petalshadow':(178,179,111,255),
   'yellow':(239,196,86,255),'amber':(205,143,58,255),'purple':(179,137,192,255),
   'violet':(136,98,160,255),'dark':(61,112,32,255)}
def init():
 im=Image.new('RGBA',(N,N),(0,0,0,0))
 return im,ImageDraw.Draw(im)
def poly(d,coords,c): d.polygon(coords,fill=C[c])
def pt(d,x,y,c):d.point((x,y),fill=C[c])
def stem(d,points,c='shadow'):d.line(points,fill=C[c],width=1)
def ell(d,rect,c):d.ellipse(rect,fill=C[c])
def make0():
 im,d=init()
 for pts in [[(7,13),(4,9),(3,6)],[(8,13),(6,7),(6,3)],[(8,13),(9,8),(12,4)],[(9,12),(12,9),(13,7)],[(6,13),(3,11),(2,10)]]:stem(d,pts)
 for coords in [[(3,7),(2,6),(3,4),(5,7)],[(6,4),(5,2),(7,1),(8,4)],[(11,5),(13,3),(14,5),(12,7)],[(2,10),(1,8),(4,9)],[(13,8),(15,7),(14,10)]]:poly(d,coords,'leaf')
 for p in [(6,3),(3,5),(13,4),(2,8),(14,8),(8,10),(7,12)]:pt(d,*p,'highlight')
 return im
def make1():
 im,d=init()
 for p in [[(7,13),(7,10),(6,8)],[(7,13),(10,8)],[(7,13),(4,10)]]:stem(d,p)
 for x,y in [(5,6),(10,6),(5,10)]:
  ell(d,(x-2,y-2,x+1,y+1),'shadow')
  ell(d,(x-1,y-2,x,y),'leaf')
  pt(d,x-1,y-1,'highlight')
 ell(d,(7,9,9,11),'olive')
 pt(d,8,10,'highlight')
 return im
def make2():
 im,d=init()
 stem(d,[(3,11),(6,10),(9,8),(13,6)],'shadow')
 for x,y in [(4,10),(6,9),(8,8),(10,7),(12,6)]:
  poly(d,[(x,y),(x-2,y-2),(x-3,y-3),(x-1,y-3)],'leaf')
  poly(d,[(x,y),(x+2,y+1),(x+3,y+2),(x+1,y+3)],'olive')
  pt(d,x-2,y-2,'highlight')
 for x,y in [(6,12),(8,12),(10,11)]:pt(d,x,y,'dark')
 return im
def make3():
 im,d=init()
 stem(d,[(2,11),(5,10),(8,12),(11,10),(14,9)],'shadow')
 for x,y in [(4,10),(8,11),(12,10)]:
  poly(d,[(x,y),(x-2,y-2),(x-1,y-4),(x+1,y-2)],'leaf')
  poly(d,[(x,y),(x+1,y+1),(x+3,y+2),(x+2,y)],'olive')
  pt(d,x-1,y-2,'highlight')
 return im
def make4():
 im,d=init()
 for x,y in [(5,6),(11,10)]:
  for dx,dy in [(-2,0),(2,0),(0,-2),(0,2),(-1,-1),(1,1)]:
   pt(d,x+dx,y+dy,'petalshadow')
  for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:
   pt(d,x+dx,y+dy,'white')
  pt(d,x,y,'center')
 stem(d,[(5,8),(3,11),(2,12)])
 for x,y in [(3,11),(7,12),(10,6),(12,6)]:
  ell(d,(x,y,x+2,y+1),'leaf')
  pt(d,x,y,'highlight')
 return im
def make5():
 im,d=init()
 for x,y in [(5,5),(11,9)]:
  for dx,dy in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(1,1)]:
   pt(d,x+dx,y+dy,'amber')
  for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:pt(d,x+dx,y+dy,'yellow')
  pt(d,x,y,'center')
 for x,y in [(3,8),(4,10),(8,12),(10,6),(13,11)]:
  poly(d,[(x,y),(x+1,y-1),(x+3,y),(x+1,y+1)],'leaf')
  pt(d,x+1,y,'highlight')
 return im
def make6():
 im,d=init()
 for x,y in [(4,7),(10,5),(11,11)]:
  stem(d,[(x+1,y+2),(x+2,y+4)],'dark')
  for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:
   pt(d,x+dx,y+dy,'violet')
  pt(d,x,y,'purple')
 for x,y in [(3,11),(7,10),(12,13)]:
  ell(d,(x,y,x+2,y+1),'leaf')
  pt(d,x,y,'highlight')
 return im
def make7():
 im,d=init()
 # A low fern fan, not a tall plant: rachis and symmetric 2–3px leaflets.
 stem(d,[(7,13),(8,11),(7,8),(8,5)],'dark')
 for x,y,direction in [(7,11,-1),(8,10,1),(7,9,-1),(8,7,1),(8,5,-1)]:
  if direction<0:
   poly(d,[(x,y),(x-2,y-1),(x-4,y-3),(x-3,y)],'leaf')
   pt(d,x-3,y-2,'highlight')
  else:
   poly(d,[(x,y),(x+2,y-1),(x+5,y-3),(x+3,y)],'leaf')
   pt(d,x+3,y-2,'highlight')
 pt(d,8,4,'highlight')
 return im
motifs=[make0(),make1(),make2(),make3(),make4(),make5(),make6(),make7()]
names=['ground_grass_fan','clover_three_leaf','creeping_moss','ground_ivy','two_white_daisies','two_yellow_buttercups','violet_patch','fern_ground_rosette']
atlas=Image.new('RGBA',(8*N,N))
for i,m in enumerate(motifs):atlas.paste(m,(i*N,0))
atlas.save(ROOT/'A13_BOTANICAL_MOTIFS_RGBA_8x16.png')
zoom=Image.new('RGB',(8*145,188),(25,29,31))
z=ImageDraw.Draw(zoom)
for i,m in enumerate(motifs):
 x=i*145
 zoom.paste(m.resize((128,128),Image.Resampling.NEAREST),(x,26),m.resize((128,128),Image.Resampling.NEAREST))
 z.text((x+1,4),names[i][:17],fill='white')
zoom.save(ROOT/'A13_BOTANICAL_MOTIFS_NEAREST8X_PREVIEW.png')
records=[]
for i,m in enumerate(motifs):
 a=np.asarray(m)
 rect=m.getbbox()
 assert rect and rect[2]-rect[0]<=16 and rect[3]-rect[1]<=16
 assert set(np.unique(a[:,:,3]).tolist())<={0,255}
 records.append({'index':i,'name':names[i],'bounds':rect,'solid_pixels':int((a[:,:,3]>0).sum()),'category':'flower' if 4<=i<=6 else 'groundcover'})
(ROOT/'A13_MOTIF_ATLAS_MANIFEST.json').write_text(json.dumps({'tile_size':[16,16],'atlas_size':[128,16],'native_nearest_only':True,'pixel_art_geometry_created_from_own_drawing_instructions':True,'model_image_generation':'NOT_USED','source_Ground3_crops_copied_into_atlas':False,'motifs':records},indent=2,ensure_ascii=False),encoding='utf8')
print('A13_ATLAS_CREATED',json.dumps(records),flush=True)
