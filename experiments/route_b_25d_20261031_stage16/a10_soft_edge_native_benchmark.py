from pathlib import Path
import numpy as np,json,runpy,hashlib
from PIL import Image,ImageDraw
r=Path(r'E:\\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031')
ctx=runpy.run_path(str(r/'a10_spectral_synthesis.py'))
fmodel=ctx['fmodel'];grass_ref=ctx['grass'];sand_ref=ctx['sand']
def mask_at(h,w):
 y=np.arange(h,dtype=float)
 center=(w*.50)+w*.084*np.sin(.82+y*np.pi*2/540)-.090*y
 width=w*.194+5.0*np.sin(.42+y*np.pi*2/210)
 mask=np.zeros((h,w),dtype=bool)
 for row in range(h):
  left=int(np.floor(center[row]-width[row]/2+2.3*np.sin(row*.113)))
  right=int(np.ceil(center[row]+width[row]/2+2.0*np.sin(row*.081+.6)))
  assert 3<left<right<w-3
  mask[row,left:right]=True
 return mask
def shift_adjacent(m):
 padded=np.pad(m,((1,1),(1,1)),constant_values=False)
 return padded[:-2,1:-1]|padded[2:,1:-1]|padded[1:-1,:-2]|padded[1:-1,2:]
def add_soft_transition(grass,sand,m):
 # The inner road stays identical to the A10 R1 result.
 out=grass.copy()
 inside=m.copy();alpha=np.zeros(m.shape,dtype=float)
 for layer in range(1,6):
  alpha[inside]=min(layer/4.,1.)
  padded=np.pad(inside,((1,1),(1,1)),constant_values=False)
  inside=inside&padded[:-2,1:-1]&padded[2:,1:-1]&padded[1:-1,:-2]&padded[1:-1,2:]
 ring=shift_adjacent(m)&~m
 outerband=np.zeros(m.shape,dtype=bool)
 for width,weight in [(1,.18),(2,.12),(3,.06),(4,.02)]:
  new=ring&~outerband
  alpha[new]=weight
  outerband|=new
  ring=shift_adjacent(ring)&~m
 blend=grass.astype(float)*(1-alpha[:,:,None])+sand.astype(float)*alpha[:,:,None]
 touched=m|outerband
 out[touched]=np.clip(blend[touched],0,255).astype(np.uint8)
 return out,outerband
def contrast(arr,m):
 a=arr.astype(float)
 edge=np.zeros(m.shape,dtype=bool)
 edge[:,:-1]=m[:,:-1]!=m[:,1:]
 dx=np.abs(a[:,:-1]-a[:,1:]).mean(axis=2)
 edgeh=m[:,:-1]!=m[:,1:]
 dy=np.abs(a[:-1,:]-a[1:,:]).mean(axis=2)
 edgev=m[:-1,:]!=m[1:,:]
 return round(float(np.r_[dx[edgeh],dy[edgev]].mean()),4)
m=np.asarray(Image.open(r/'A10_ORIGINAL_ROAD_GEOMETRY_384.png').convert('L'))==255
g=np.asarray(Image.open(r/'A10_NEW_GRASS_SPECTRAL_384.png').convert('RGB'))
s=np.asarray(Image.open(r/'A10_NEW_SAND_SPECTRAL_384.png').convert('RGB'))
r1=np.asarray(Image.open(r/'A10_SPECTRAL_CANDIDATE_384.png').convert('RGB'))
r2,buffer=add_soft_transition(g,s,m)
assert np.array_equal(r1[m],r2[m]),'R2 must keep exact R1 road inner pixels'
assert np.array_equal(r1[~(m|buffer)],r2[~(m|buffer)]),'R2 modified protected exterior'
assert 0<int(buffer.sum())<4000
qa={'stage':'A10_R2','test':'4px transition outside road only, same full material and source seeds','road_pixels':int(m.sum()),'transition_outside_pixels':int(buffer.sum()),'protected_exterior_pixels':int((~(m|buffer)).sum()),'road_R1_vs_R2_changed':int(np.any(r1[m]!=r2[m],axis=1).sum()),'protected_exterior_changed':int(np.any(r1[~(m|buffer)]!=r2[~(m|buffer)],axis=1).sum()),'boundary_crossing_rgb_mean_abs_R1':contrast(r1,m),'boundary_crossing_rgb_mean_abs_R2':contrast(r2,m),'visual_gate':'PENDING','no_neural_image_model_used':True,'formal_seal':'NO'}
Image.fromarray(r2).save(r/'A10_R2_SOFT_TRANSITION_384.png')
Image.fromarray((buffer*255).astype(np.uint8)).save(r/'A10_R2_ALLOWED_EDGE_BAND_384.png')
(r/'A10_R2_EDGE_QA.json').write_text(json.dumps(qa,indent=2),encoding='utf8')
print('A10_R2_QA',json.dumps(qa),flush=True)
# New native 544x416 test, no resizing of generated 384 art.
H,W=416,544
mask=mask_at(H,W)
newgrass=fmodel(grass_ref,H,W,101064)
newsand=fmodel(sand_ref,H,W,101048)
whole,band=add_soft_transition(newgrass,newsand,mask)
Image.fromarray(newgrass).save(r/'A10_BENCHMARK_GRASS_544x416.png')
Image.fromarray(newsand).save(r/'A10_BENCHMARK_SAND_544x416.png')
Image.fromarray(whole).save(r/'A10_BENCHMARK_GROUND_544x416.png')
Image.fromarray((mask*255).astype(np.uint8)).save(r/'A10_BENCHMARK_ROAD_MASK_544x416.png')
Image.fromarray((band*255).astype(np.uint8)).save(r/'A10_BENCHMARK_EDGE_BAND_544x416.png')
check={'stage':'A10_544','native_size':[W,H],'pixels':int(W*H),'road_pixels':int(mask.sum()),'road_fraction':round(float(mask.mean()),5),'allowed_external_transition_pixels':int(band.sum()),'outer_protected_pixels':int((~(mask|band)).sum()),'outside_protected_is_original_grass':bool(np.array_equal(whole[~(mask|band)],newgrass[~(mask|band)])),'all_road_rows_continuous':all(np.where(mask[y])[0].size>0 and np.ptp(np.where(mask[y])[0])+1==int(mask[y].sum()) for y in range(H)),'fresh_native_pixels_no_upscale':True,'semantic_ground_only':True,'ground3_art':'PENDING','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO','output_sha256':hashlib.sha256((r/'A10_BENCHMARK_GROUND_544x416.png').read_bytes()).hexdigest()}
assert check['outside_protected_is_original_grass'] and check['all_road_rows_continuous']
(r/'A10_BENCHMARK_NATIVE_QA.json').write_text(json.dumps(check,indent=2),encoding='utf8')
print('A10_NATIVE_BENCH',json.dumps(check),flush=True)
