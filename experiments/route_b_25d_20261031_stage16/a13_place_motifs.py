from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib,math
R=Path(__file__).resolve().parent
with Image.open(R/'A13_A12_TINT_BASE_544x416.png') as im:tint=np.asarray(im.convert('RGB'),dtype=np.uint8).copy()
with Image.open(R/'A13_A12_FINAL_COMPARATOR_544x416.png') as im:a12=np.asarray(im.convert('RGB'),dtype=np.uint8).copy()
with Image.open(R/'A13_PROTECTED_MASK.png') as im:protected=np.asarray(im.convert('L'))>0
with Image.open(R/'A13_SOIL_LEGAL_PIXELS.png') as im:soil=np.asarray(im.convert('L'))>0
with Image.open(R/'A13_DENSE_BLUEPRINT.png') as im:dense=np.asarray(im.convert('L'),dtype='float64')/255.
with Image.open(R/'A13_FLOWER_BLUEPRINT.png') as im:flowers=np.asarray(im.convert('L'),dtype='float64')/255.
assert a12.shape==tint.shape==(416,544,3)
assert int(protected.sum())==47649
assert int(soil.sum())==900 and not (soil&protected).any()
# Keep the actual A12 soil fleck pixels. All replaced vegetation starts from A12 tint base.
base=tint.copy();base[soil]=a12[soil]
out=base.copy()
with Image.open(R/'A13_BOTANICAL_MOTIFS_RGBA_8x16.png') as im:
 atlas=np.asarray(im.convert('RGBA'),dtype=np.uint8)
assert atlas.shape==(16,128,4)
motifs=[atlas[:,i*16:(i+1)*16,:].copy() for i in range(8)]
rng=np.random.default_rng(130416)
occupied=np.zeros((416,544),dtype=np.bool_)
motif_mask=np.zeros((416,544),dtype=np.bool_)
flower_mask=np.zeros((416,544),dtype=np.bool_)
cover_mask=np.zeros((416,544),dtype=np.bool_)
records=[]
def place_weighted(category,indices,count,weight,seed,distance):
 rr=np.random.default_rng(seed)
 prob=np.maximum(weight,0)**2
 prob[protected|soil]=0.
 prob[:15,:]=0;prob[-15:,:]=0;prob[:,:15]=0;prob[:,-15:]=0
 prob=(prob/max(float(prob.sum()),1e-9)).ravel()
 cand=rr.choice(prob.size,size=count*160,replace=True,p=prob)
 placed=0
 for idx in cand:
  cy=int(idx//544);cx=int(idx%544)
  if weight[cy,cx]<.40:continue
  if occupied[cy-distance:cy+distance+1,cx-distance:cx+distance+1].any():continue
  i=int(indices[int(rr.integers(0,len(indices)))])
  a=motifs[i]
  if rr.random()<.5:a=np.fliplr(a)
  x0=cx-8;y0=cy-8
  solid=a[:,:,3]!=0
  local_protected=protected[y0:y0+16,x0:x0+16]|soil[y0:y0+16,x0:x0+16]
  if np.any(solid&local_protected):continue
  # Avoid motif's entire semantic support being on a crossing edge of the declared cluster.
  regional=weight[y0:y0+16,x0:x0+16]
  if float(np.mean(regional[solid]))<.28:continue
  crop=out[y0:y0+16,x0:x0+16]
  crop[solid]=a[:,:,:3][solid]
  occupied[cy,cx]=True
  sub=motif_mask[y0:y0+16,x0:x0+16];sub[solid]=True
  target=flower_mask if category=='flower' else cover_mask
  sub=target[y0:y0+16,x0:x0+16];sub[solid]=True
  records.append({'kind':category,'motif':i,'anchor':[cx,cy],'top_left':[x0,y0],'pixel_count':int(solid.sum()),'reflected':bool(not np.array_equal(a,motifs[i]))})
  placed+=1
  if placed==count:break
 return placed
cover_count=place_weighted('cover',[0,1,2,3,7],210,dense,130417,7)
flower_count=place_weighted('flower',[4,5,6],96,flowers,130418,9)
assert cover_count>=170 and flower_count>=75,(cover_count,flower_count)
assert np.array_equal(out[protected],a12[protected])
assert np.array_equal(out[soil],a12[soil])
changed=np.any(out!=a12,axis=2)
# Every changed point must be within new art or the previous A12 removed leaf/flower dots.
with Image.open(R/'A13_OLD_A12_LEAF_PIXELS_MASK.png') as im:old_leaf=np.asarray(im.convert('L'))>0
with Image.open(R/'A13_OLD_A12_FLOWER_PIXELS_MASK.png') as im:old_flower=np.asarray(im.convert('L'))>0
old_painted=old_leaf|old_flower
assert not np.any(changed&~(motif_mask|old_painted)),int((changed&~(motif_mask|old_painted)).sum())
Image.fromarray(out,'RGB').save(R/'A13_BOTANICAL_CLUSTER_GROUND_544x416.png')
Image.fromarray(base,'RGB').save(R/'A13_REPLACEMENT_BASE_544x416.png')
for name,mask in [('A13_NEW_MOTIF_PIXELS_MASK.png',motif_mask),('A13_FLOWER_PIXELS_MASK.png',flower_mask),('A13_COVER_PIXELS_MASK.png',cover_mask),('A13_OLD_DOTS_REPLACED_MASK.png',old_painted)]:
 Image.fromarray((mask*255).astype('uint8'),'L').save(R/name)
manifest={'stage':'A13','method':'authored 8 native 16x16 transparent RGBA botanical motifs applied to A12 landscape semantic masks; previous tiny leaf/flower strokes removed while same soil pixels preserved','native_size':[544,416],'atlas_rgba_sha256':hashlib.sha256((R/'A13_BOTANICAL_MOTIFS_RGBA_8x16.png').read_bytes()).hexdigest(),'ground_sha256':hashlib.sha256((R/'A13_BOTANICAL_CLUSTER_GROUND_544x416.png').read_bytes()).hexdigest(),'A12_source_sha256':hashlib.sha256((R/'A13_A12_FINAL_COMPARATOR_544x416.png').read_bytes()).hexdigest(),'total_new_motifs':len(records),'cover_groups':cover_count,'flower_groups':flower_count,'new_flower_pixels':int(flower_mask.sum()),'new_cover_pixels':int(cover_mask.sum()),'new_motif_total_pixels':int(motif_mask.sum()),'previous_tiny_stroke_pixels_removed':int(old_painted.sum()),'soil_pixels_preserved':int(soil.sum()),'road_plus_edge_protected_pixels':int(protected.sum()),'protected_changed_px':int(np.count_nonzero(changed&protected)),'illegal_diff_outside_old_and_new_motifs_px':int(np.count_nonzero(changed&~(motif_mask|old_painted))),'visual_art':'FAIL_INTERNAL_GROUND3_STYLE','native_VX':'NOT_RUN','godot':'NOT_RUN','formal_seal':'NO','generator_class':'hand-authored procedural pixel art, NO neural model'}
(R/'A13_SPRITE_PLACEMENTS.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf8')
(R/'A13_GENERATION_QA.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print('A13_PLACED',json.dumps(manifest,ensure_ascii=False,indent=2),flush=True)
