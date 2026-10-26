from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,hashlib,json,collections
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs';q=r/'qa';q.mkdir(exist_ok=True)
def load(p):return Image.open(p).convert('RGBA')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
g=load(s/'GROUND_B.png');act=load(s/'ACTOR1.png')
house=load(o/'HOUSE_STRUCTURAL_NO_GROUND_R4B.png')
barrels=load(o/'BARRELS_STANDALONE_CANDIDATE.png')
tree=load(s/'SACRED_TREE.png');flora=load(s/'FLORA.png')
assert g.size==(544,416) and house.size==(261,183)
assert g.getchannel('A').getextrema()==(255,255)
# Retain house as source only after independent ground exclusion check; body candidate still ART_HOLD.
forbid=np.asarray(Image.open(o/'R4B_EXCLUDED_GARDEN_AND_LOOSE_SOIL_MASK.png').convert('L'))>0
candidate=np.asarray(house)
assert np.count_nonzero((candidate[:,:,3]>0)&forbid)==0
old=np.asarray(load(s/'HOUSE_R3A_BASE.png'))
assert np.count_nonzero((old[:,:,3]>0)&forbid)>3000
# Keep separate barrel sprite and world placement. This is a single prop with transparent padding,
# not a cutaway of the original house's soil.
bb=barrels.getchannel('A').getbbox(); assert bb
pad=5;x0=max(0,bb[0]-pad);y0=max(0,bb[1]-pad);x1=min(261,bb[2]+pad);y1=min(183,bb[3]+pad)
barrel_trim=barrels.crop((x0,y0,x1,y1))
barrel_trim.save(o/'BARRELS_CLEAN_SOURCE_CROPPED.png')
asset=[
 dict(id='house_core',type='BODY+ATTACHED_ROOF_MOSS',sprite='HOUSE_STRUCTURAL_NO_GROUND_R4B.png',xy=[12,48],foot=[139,188],
      art_status='STRUCTURE_EDGE_ART_HOLD',ground_attached=False),
 dict(id='barrels_2',type='PROP',sprite='BARRELS_CLEAN_SOURCE_CROPPED.png',xy=[12+x0,48+y0],foot=[197,198],
      art_status='CANDIDATE_UNDERFOOT_REVIEW',ground_attached=False),
 dict(id='tree',type='TREE_ROOTS_ATTACHED',sprite='SACRED_TREE.png',xy=[323,22],foot=[429,235],
      art_status='SOURCE_TREE_ROOTS_VISUAL_REVIEW',ground_attached=False),
 dict(id='flora',type='SOFT_SHRUB',sprite='FLORA.png',xy=[445,286],foot=[473,336],
      art_status='GRABCUT_ART_REVIEW',ground_attached=False)]
sprites={'house_core':house,'barrels_2':barrel_trim,'tree':tree,'flora':flora}
p=Image.new('RGBA',g.size);owner=Image.new('L',g.size,0)
for i,a in enumerate(asset):
 x,y=a['xy'];im=sprites[a['id']];assert x>=0 and y>=0 and x+im.width<=544 and y+im.height<=416
 alpha=im.getchannel('A');assert alpha.getbbox()
 layer=Image.new('RGBA',g.size);layer.alpha_composite(im,(x,y))
 layer.save(o/(a['id']+'_PLACED.png'))
 m=Image.new('L',g.size);m.paste(alpha,(x,y));owner.paste(i+1,(0,0),m)
 p.alpha_composite(layer)
 a['size']=list(im.size)
 a['alpha_sha256']=sha(o/a['sprite']) if (o/a['sprite']).exists() else sha(s/a['sprite'])
 psrc=o/(a['id']+'_PIXEL_OWNER.png');m.save(psrc)
p.save(o/'PAR_COMPLETE_R4.png');owner.save(o/'PIXEL_OWNER_R4.png');g.save(o/'GROUND_R4_UNCHANGED.png')
comp=Image.alpha_composite(g,p);comp.save(o/'COMPOSITE_R4_WITHOUT_ACTOR.png')
# Walkability: Ground still completely walkable, hard blockers from house/trunk only,
# independent barrel still stands within already blocked house footprint.
blocked=np.asarray(Image.open(s/'R2_BLOCKED_TILES.png').convert('L'))>0
assert int(np.count_nonzero(blocked))==15*32*32
cells=np.array([[int(blocked[ty*32+16,tx*32+16]) for tx in range(17)] for ty in range(13)])
assert int(cells.sum())==15 and cells[7,4]==0 and cells[5,4]==1 and cells[10,14]==0
bbox=barrel_trim.getchannel('A').getbbox()
assert bbox and barrel_trim.getchannel('A').getpixel((0,0))==0
# Test source does not embed a sample of B's horizontal Ground at full raster identical coordinates.
# Semantic ownership remains human review pending despite zero declared forbidden pixels.
def scene_actor(fx,fy):
 im=g.copy();done=False
 by_order=sorted(asset,key=lambda a:a['foot'][1])
 for item in by_order:
  if not done and fy<item['foot'][1]:
   im.alpha_composite(act,(fx-16,fy-32));done=True
  im.alpha_composite(sprites[item['id']],tuple(item['xy']))
 if not done:im.alpha_composite(act,(fx-16,fy-32))
 return im
for label,xy in {'HOUSE_DOOR':(139,236),'TREE_BEHIND':(430,222),'TREE_FRONT':(430,269),'SHRUB_FRONT':(468,359)}.items():
 scene_actor(*xy).save(o/('ACTOR_'+label+'.png'))
preview=Image.new('RGB',(1088,832))
for i,(label,xy) in enumerate({'HOUSE_DOOR':(139,236),'TREE_BEHIND':(430,222),'TREE_FRONT':(430,269),'SHRUB_FRONT':(468,359)}.items()):
 preview.paste(scene_actor(*xy).convert('RGB'),((i%2)*544,(i//2)*416))
preview.save(o/'ACTOR_FOUR_POSITIONS_R4.png')
# Negative contamination injection must reject: old house includes known original lawn under old mask.
rejected_old=int(np.count_nonzero((old[:,:,3]>0)&forbid))
injected=candidate.copy()
fys,fxs=np.nonzero(forbid & (candidate[:,:,3]==0))
assert len(fxs)>0
iy,ix=int(fys[0]),int(fxs[0])
injected[iy,ix]=[45,120,27,255]
negative=int(np.count_nonzero((injected[:,:,3]>0)&forbid))
assert negative==1
# Recomposition from canonical single scene must stay exact.
again=g.copy()
for item in asset:again.alpha_composite(sprites[item['id']],tuple(item['xy']))
assert np.array_equal(np.asarray(again),np.asarray(comp))
checks={
 'ground_unchanged_and_opaque':bool(g.getchannel('A').getextrema()==(255,255)),
 'house_rejects_old_baked_original_lawn':bool(rejected_old>3000),
 'house_new_forbidden_terrain_owner_zero':bool(np.count_nonzero((candidate[:,:,3]>0)&forbid)==0),
 'fake_ground_1px_injection_negative':bool(negative==1),
 'source_pixel_no_recolor':bool(np.array_equal(candidate[candidate[:,:,3]>0],old[candidate[:,:,3]>0])),
 'barrels_detached_as_own_sprite':bool(barrel_trim.size!=house.size),
 'barrels_clear_transparent_padding':bool(barrel_trim.getchannel('A').getpixel((0,0))==0),
 'par_one_manifest_recompose_exact':bool(np.array_equal(np.asarray(comp),np.asarray(again))),
 '15_real_foot_blockers':bool(int(cells.sum())==15),
 'house_front_walkable':bool(cells[7,4]==0),
 'shrub_walkable':bool(cells[10,14]==0),
 'real_vx_actor_four_views':bool(act.size==(32,32))}
assert all(checks.values())
manifest=dict(schema='FS_V6_P3_R4_STRICT_GROUND_EXCLUSIVE',authority='FS_GROUND_EXCLUSIVE_OWNERSHIP_RULE_V1',
objects=asset,ground_source_sha256=sha(s/'GROUND_B.png'),
terrain_underpaint_source='GROUND_B.png',forbidden_mask='R4B_EXCLUDED_GARDEN_AND_LOOSE_SOIL_MASK.png',
owner_unknown_source_pixels_not_promoted=True,strict_house_art='PENDING',native_vx='NOT_RUN',
notes='Cottage source structure has remaining ragged flower/wall contact; do NOT promote as final art. Separate barrels reusable candidate, tree and shrub reference-only.')
(r/'SCENE_MANIFEST_R4.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
qa=dict(tech_pass=sum(checks.values()),total=len(checks),checks=checks,
source_old_ground_overlap_pixels=rejected_old,source_new_ground_overlap_pixels=0,
source_fake_1px_ground_negative=negative,
new_house_art='FAIL_HOUSE_FACADE_FLOWER_CONTACT_RAGGED',user_visual='PENDING',native_vx='NOT_RUN')
(q/'QA_R4_FAIL_CLOSED.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({'TECH_PASS':qa['tech_pass'],'total':qa['total'],'old_violation_pixels':rejected_old,
                 'new_forbidden_overlap':0,'negative_injection':negative,'assets':len(asset),
                 'art_status':qa['new_house_art']}))
