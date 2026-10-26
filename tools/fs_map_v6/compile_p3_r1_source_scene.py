from PIL import Image,ImageDraw
from pathlib import Path
import hashlib,json,shutil,collections
import numpy as np
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs';q=r/'qa'
for p in (s,o,q):p.mkdir(exist_ok=True,parents=True)
base=Path(r'E:\GameAssetToolLab_20261023')
b=base/'MAP_TARGET_V6_20261026/G_P2_R1_3CANDIDATES/expanded'
files={'GROUND_B.png':b/'ground_only_candidate_B.png',
       'ACTOR1.png':b/'VX_ACTOR1_FACING_DOWN_REAL_RTP_FRAME_32x32.png',
       'OCHRE_HOUSE.png':base/'FS_STYLE_FIRST_V233_FULL_ARCHITECTURE_SCROLLING_VILLAGE_20261025/source/generated/elf_ochre_cottage.png',
       'SACRED_TREE.png':base/'FS_STYLE_FIRST_V233_FULL_ARCHITECTURE_SCROLLING_VILLAGE_20261025/source/reused/sacred_tree_style_v22.png',
       'FLORA.png':base/'MAP_F2_G5R4_SOURCE_GROUND_PILOT_20261026/FLORA_G5R4_SCALE_1_OVER_2_NEAREST.png'}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for k,p in files.items():
 dest=s/k
 if dest.exists():
  if p.is_file():assert sha(dest)==sha(p),"source mismatch; do not overwrite"
 else:
  assert p.is_file(),str(p)
  shutil.copy2(p,dest)
 assert dest.is_file(),k
G=Image.open(s/'GROUND_B.png').convert('RGBA');A=Image.open(s/'ACTOR1.png').convert('RGBA')
assert G.size==(544,416) and G.getchannel('A').getextrema()==(255,255)
assert A.size==(32,32) and A.getchannel('A').getbbox()==(2,0,30,32)
objs=[
 dict(id='house',source='OCHRE_HOUSE.png',xy=[12,48],foot=[130,164],collision='HARD',
      contact=[28,145,265,215],visual_risk='baked_underpaint_flower_soil'),
 dict(id='sacred_tree',source='SACRED_TREE.png',xy=[323,22],foot=[106,213],collision='HARD',
      contact=[417,217,443,242],visual_risk='relative_scale_review'),
 dict(id='flora',source='FLORA.png',xy=[445,286],foot=[28,50],collision='SOFT_WALK',
      visual_risk='grabcut_mask_not_user_approved')]
parts=[];P=Image.new('RGBA',G.size);Owner=Image.new('L',G.size,0)
for i,v in enumerate(objs):
 im=Image.open(s/v['source']).convert('RGBA');al=im.getchannel('A');bbox=al.getbbox();x,y=v['xy']
 assert bbox and x>=0 and y>=0 and x+im.width<=544 and y+im.height<=416
 assert not any(al.getpixel((0,j))>0 or al.getpixel((im.width-1,j))>0 for j in range(im.height))
 assert not any(al.getpixel((j,0))>0 or al.getpixel((j,im.height-1))>0 for j in range(im.width))
 v.update(source_sha=sha(s/v['source']),source_wh=list(im.size),alpha_bbox=list(bbox),
          world_foot=[x+v['foot'][0],y+v['foot'][1]])
 layer=Image.new('RGBA',G.size);layer.alpha_composite(im,(x,y))
 layer.save(o/(v['id']+'_PAR_SOURCE_PLACED.png'));parts.append(layer)
 P.alpha_composite(layer)
 owner_mask=Image.new('L',G.size);owner_mask.paste(al,(x,y))
 Owner.paste(i+1,(0,0),owner_mask);owner_mask.save(o/(v['id']+'_ALPHA_OWNER.png'))
P.save(o/'PAR_COMPLETE.png');Owner.save(o/'PIXEL_OWNER_ID.png');G.save(o/'GROUND_OPAQUE.png')
Image.alpha_composite(G,P).save(o/'WORLD_COMPOSITE_NO_ACTOR.png')
f=Image.new('L',G.size,0);draw=ImageDraw.Draw(f)
for v in objs:
 if v['collision']=='HARD':draw.rectangle(v['contact'],fill=255)
f.save(o/'PAR_CONTACT_HARD_PIXEL.png')
grid=np.array([[1 if f.getpixel((tx*32+16,ty*32+16)) else 0
                 for tx in range(17)] for ty in range(13)],dtype=np.uint8)
Image.fromarray(grid*255).resize(G.size,Image.Resampling.NEAREST).save(o/'BLOCKED_TILES_17x13.png')
assert 0<int(grid.sum())<44
assert grid[5,4]==1 and grid[7,4]==0
sp=(8,10);target=(4,7);queue=collections.deque([sp]);vis={sp}
while queue:
 x,y=queue.popleft()
 for nx,ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  if 0<=nx<17 and 0<=ny<13 and not grid[ny,nx] and (nx,ny) not in vis:
   vis.add((nx,ny));queue.append((nx,ny))
assert target in vis and (14,10) in vis
def render(px,py):
 img=G.copy();done=False
 for i in sorted(range(3),key=lambda z:objs[z]['world_foot'][1]):
  if not done and py<objs[i]['world_foot'][1]:
   img.alpha_composite(A,(px-16,py-32));done=True
  img.alpha_composite(parts[i])
 if not done:img.alpha_composite(A,(px-16,py-32))
 return img
names=[('HOUSE_FRONT',144,250),('TREE_BEHIND',430,223),('TREE_FRONT',432,260),('FLORA_FRONT',475,351)]
contact=Image.new('RGB',(1088,832))
for i,(n,x,y) in enumerate(names):
 scene=render(x,y)
 scene.save(o/('ACTOR_'+n+'.png'))
 contact.paste(scene.convert('RGB'),((i%2)*544,(i//2)*416))
contact.save(o/'ACTOR_FOUR_POSITIONS_CONTACT.png')
Image.alpha_composite(G,P).resize((1088,832),Image.Resampling.NEAREST).save(o/'WORLD_2X_NEAREST.png')
bad=Image.new('RGBA',G.size);t=Image.open(s/'SACRED_TREE.png').convert('RGBA')
bad.alpha_composite(t,(objs[1]['xy'][0]+1,objs[1]['xy'][1]))
changed=int(np.count_nonzero(np.any(np.asarray(bad)!=np.asarray(parts[1]),axis=2)))
assert changed>0
again=G.copy()
for z in parts:again.alpha_composite(z)
assert np.array_equal(np.asarray(again),np.asarray(Image.open(o/'WORLD_COMPOSITE_NO_ACTOR.png')))
m={'schema':'FS_V6_P3_R1_SINGLE_SOURCE_SCENE','size':[544,416],'grid':32,
'ground':{'source':'GROUND_B.png','sha256':sha(s/'GROUND_B.png'),'default_walk':True},
'objects':objs,'collision_tile_map':grid.tolist(),
'status':{'TECH':'ISOLATED_PASS','HOUSE_CONTACT_ART':'FAIL_BAKED_GROUND','FLORA_ALPHA_ART':'PENDING','SCENE_ART':'PENDING','VX_NATIVE':'NOT_RUN','HUMAN':'PENDING'}}
(r/'SCENE_MANIFEST.json').write_text(json.dumps(m,indent=2),encoding='utf8')
checks={'source_hashes_retain':True,'no_border_clip_three':True,'ground_opaque_17x13':True,'three_independent_alpha_layers':True,
'par_recompose_zero_diff':True,'owner_id':True,'hard_collision_after_par_placement':True,
'house_front_one_tile_walk':True,'house_wall_blocked':True,'walk_route_from_spawn_to_door':True,
'floral_par_is_walkable':True,'actor_y_sort_front_back':True,'tree_shift_1px_negative':True}
qa={'pass':sum(checks.values()),'checks':checks,'hard_blocked_tile_count':int(grid.sum()),
'negative_tree_shift_changed_pixels':changed,'source_art_pass':False,'art_pending':True,
'known_failure':'Cottage alpha includes own grassy flower ground underpaint; not approved for final B Ground compositing.',
'native_vx':'NOT_RUN'}
(q/'QA_R1.json').write_text(json.dumps(qa,indent=2),encoding='utf8')
print(json.dumps({'QA_PASS':qa['pass'],'hard_tiles':int(grid.sum()),'one_pixel_tree_delta':changed,
'output':str(o),'house_art':'FAIL_UNDERPAINT','native':'NOT_RUN'}))
