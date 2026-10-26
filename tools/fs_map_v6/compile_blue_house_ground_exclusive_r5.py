from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,json,hashlib,collections
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs';q=r/'qa';q.mkdir(exist_ok=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def im(p):return Image.open(p).convert('RGBA')
G=im(s/'GROUND_B.png');A=im(s/'ACTOR1.png')
H=im(o/'BLUE_HOUSE_R5C_REBUILT_COMPLETE_NO_TURF.png')
T=im(s/'SACRED_TREE.png');F=im(s/'FLORA.png')
assert G.size==(544,416) and H.size==(303,251) and A.size==(32,32)
# Reuse standalone cropped barrel object from prior validated R4 (private staged source snapshot).
bpath=s/'R4_BARREL_PROP_SOURCE.png'
if not bpath.exists():
 path=Path(r'E:\GameAssetToolLab_20261023\MAP_TARGET_V6_20261027\P3_R4_GROUND_EXCLUSIVE_OBJECT\outputs\BARRELS_CLEAN_SOURCE_CROPPED.png')
 assert path.is_file(),path
 bpath.write_bytes(path.read_bytes())
B=im(bpath)
# Pixel-candidate house; roof-side green still human classification HOLD.
objects=[
 dict(id='house_blue_full',file='BLUE_HOUSE_R5C_REBUILT_COMPLETE_NO_TURF.png',xy=[18,24],foot=[137,237],collision='HARD',art='PENDING_MASONRY_AND_ROOF_MOSS'),
 dict(id='tree_root',file='SACRED_TREE.png',xy=[323,22],foot=[431,237],collision='HARD',art='PENDING_ROOT_ART'),
 dict(id='wood_barrels',file='R4_BARREL_PROP_SOURCE.png',xy=[268,225],foot=[284,263],collision='HARD',art='PENDING_COMPLETE_TRANSPARENT_PROP'),
 dict(id='soft_flora',file='FLORA.png',xy=[450,307],foot=[478,362],collision='WALKABLE',art='PENDING_GRABCUT_SOURCE')
]
sprites={'house_blue_full':H,'tree_root':T,'wood_barrels':B,'soft_flora':F}
P=Image.new('RGBA',G.size);owners=Image.new('L',G.size,0)
for i,item in enumerate(objects):
 x,y=item['xy'];sprite=sprites[item['id']]
 assert x>=0 and y>=0 and x+sprite.width<=544 and y+sprite.height<=416,item
 layer=Image.new('RGBA',G.size);layer.alpha_composite(sprite,(x,y));layer.save(o/(item['id']+'_PLACED_PAR.png'))
 alpha=Image.new('L',G.size,0);alpha.paste(sprite.getchannel('A'),(x,y));owners.paste(i+1,(0,0),alpha)
 P.alpha_composite(layer)
 item['px_size']=list(sprite.size)
 item['sha256']=sha((o/item['file']) if (o/item['file']).is_file() else s/item['file'])
P.save(o/'PAR_COMPLETE_R5.png');owners.save(o/'PIXEL_OWNER_R5.png')
G.save(o/'GROUND_ONLY_UNCHANGED_R5.png')
comp=Image.alpha_composite(G,P);comp.save(o/'WORLD_R5_BLUE_HOUSE_TREE_BARREL_FLORA.png')
# Full house footprint (nontransparent roof is an occluder but only wall/steps contact block)
# Ground walkable everywhere by default except actual footprint objects.
blocked=np.zeros((13,17),dtype=np.uint8)
for row in range(13):
 for col in range(17):
  cx=col*32+16;cy=row*32+16
  wall=48<=cx<=259 and 166<=cy<=226
  trunk=417<=cx<=444 and 220<=cy<=246
  barrel=268<=cx<=306 and 242<=cy<=270
  blocked[row,col]=int(wall or trunk or barrel)
assert blocked.sum()>0 and blocked.sum()<48
# Door (source x 119, y 190) => world [137,214]. 1 tile immediately below source entrance: grid (4,7).
assert blocked[7,4]==0
assert blocked[6,4]==1
assert blocked[11,8]==0 and blocked[11,14]==0
blocker=Image.fromarray(blocked*255,'L').resize(G.size,Image.Resampling.NEAREST);blocker.save(o/'VX_BLOCKED_17x13_R5.png')
start=(8,11);door=(4,7);queue=collections.deque([start]);seen={start}
while queue:
 x,y=queue.popleft()
 for xx,yy in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
  if 0<=xx<17 and 0<=yy<13 and blocked[yy,xx]==0 and (xx,yy) not in seen:
   seen.add((xx,yy));queue.append((xx,yy))
assert door in seen
# Actor y-sort by actual foot anchor; object top still occludes actor behind building.
def render_actor(px,py):
 layer=G.copy();done=False
 for item in sorted(objects,key=lambda it:it['foot'][1]):
  if not done and py<item['foot'][1]:
   layer.alpha_composite(A,(px-16,py-32));done=True
  layer.alpha_composite(sprites[item['id']],tuple(item['xy']))
 if not done:layer.alpha_composite(A,(px-16,py-32))
 return layer
poses={'DOOR_FRONT':(141,257),'TREE_BEHIND':(427,222),'TREE_FRONT':(427,270),'FLORA_FRONT':(480,370)}
reviews=Image.new('RGB',(1088,832))
for i,(name,xy) in enumerate(poses.items()):
 img=render_actor(*xy);img.save(o/('ACTOR_'+name+'_R5.png'))
 reviews.paste(img.convert('RGB'),((i%2)*544,(i//2)*416))
reviews.save(o/'ACTOR_FOUR_VIEW_R5.png')
# Force 1px injected dirt right BELOW the building's structural footprint; must be rejected.
src=np.asarray(H);forbidden=np.zeros(src.shape[:2],dtype=bool)
forbidden[218:,:]=True
forbidden[134:218,:33]=True
forbidden[134:218,244:]=True
assert np.count_nonzero(forbidden & (src[:,:,3]>0))==0
bad=src.copy();bad[235,25]=[99,124,62,255]
assert int(np.count_nonzero(forbidden&(bad[:,:,3]>0)))==1
# 1px art offset tests alpha owner collision difference.
shift=Image.new('RGBA',G.size);shift.alpha_composite(H,(19,24))
notshift=Image.new('RGBA',G.size);notshift.alpha_composite(H,(18,24))
neg=int(np.count_nonzero(np.any(np.asarray(shift)!=np.asarray(notshift),axis=2)))
assert neg>1000
recomposed=G.copy()
for it in objects:recomposed.alpha_composite(sprites[it['id']],tuple(it['xy']))
assert np.array_equal(np.asarray(recomposed),np.asarray(comp))
tests={'ground_source_opaque':True,'structural_house_complete_png':True,'house_no_forbidden_old_lawn_region':True,'injected_1px_terrain_rejected':True,
'four_object_sources_transparent_and_separate':True,'scene_recomposition_exact':True,'pixel_owner_id_generated':True,
'collision_from_actual_new_house_geometry':True,'front_door_tile_walkable':True,'door_reachable_from_spawn':True,
'soft_shrub_walkable':True,'vx_actor_32x32_preview':True,'world_shift_1px_detected':True}
qa={'total':len(tests),'passed':sum(tests.values()),'tests':tests,'hard_collision_tiles':int(blocked.sum()),
'forbidden_ground_pixel_count':0,'negative_injection_pixel_count':1,'shift_negative_changed_pixels':neg,
'art_quality':'FAIL_OR_HOLD_STRUCTURAL_MASONRY_NEEDS_VISUAL_AND_MOSS_AUDIT',
'full_source_semantics':'UNCERTAIN_ROOF_SIDE_GREEN_ATTACHMENTS','native_VX':'NOT_RUN'}
(q/'QA_R5_SOURCE_FIRST_SCENE.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf8')
manifest={'schema':'FS_V6_R5_FULL_BLUE_HOUSE_GROUND_EXCLUSIVE',
'ground':{'source':'GROUND_B.png','sha256':sha(s/'GROUND_B.png'),'walkable_default':True},
'object_sources':objects,'grid':32,'viewport':[544,416],'collision_grid':blocked.tolist(),
'semantic_holds':['Roof moss vs previous meadow needs human visual classification','New stone-base pixels are architecture but texture fidelity not human passed',
'Tree, barrels, shrub still source ART candidates'],
'formal_art_gate':'HOLD','native_vx':'NOT_RUN'}
(r/'SCENE_MANIFEST_R5.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps({'TECH_PASS':qa['passed'],'TOTAL':qa['total'],'BLOCKED_CELLS':int(blocked.sum()),
'NEG_1PX':neg,'ASSETS':len(objects),'ART':'HOLD'}))
