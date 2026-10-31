from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np, json, hashlib, time, shutil
R=Path(__file__).resolve().parent
A14=R if (R/'A14_GENUINE_AI_SOURCE_1435x1096.png').exists() else Path('/mnt/data/FS_STAGE16_A14_GENERATIVE_ART_TRIAL_20261031')
sha=lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
src=A14/'A14_GENUINE_AI_SOURCE_1435x1096.png'
assert sha(src)=='4701511907354048515a969f88f18b77bd5608f6259c286335c7c78f29c6dca7'
src_crop=A14/'A14_SOURCE_ASPECT_CROP_1433x1096.png'
assert sha(src_crop)=='f710d7d4e35d91a6b87fbc30caafcb282c3e52e90eb2ab8992e959dfc7ab3db6'
for f in ['A14_GENUINE_AI_SOURCE_1435x1096.png','A14_SOURCE_ASPECT_CROP_1433x1096.png','A14_NATIVE_544x416_LANCZOS_RGB.png','A14_NATIVE_544x416_PALETTE128.png']:
 if (A14/f).resolve() != (R/f).resolve(): shutil.copy2(A14/f,R/f)
arr=np.asarray(Image.open(src_crop).convert('RGB'),dtype=np.uint8)
H,W=arr.shape[:2]
assert (H,W)==(1096,1433)
T_W,T_H=544,416

def grid_test(img,pitches=range(2,17)):
 a=np.asarray(img,dtype=np.float32)
 dx=np.abs(a[:,1:,:]-a[:,:-1,:]).mean(axis=(0,2))
 dy=np.abs(a[1:,:,:]-a[:-1,:,:]).mean(axis=(1,2))
 out=[]
 for pitch in pitches:
  x_avg=np.array([dx[np.arange(dx.size)%pitch==phase].mean() for phase in range(pitch)])
  y_avg=np.array([dy[np.arange(dy.size)%pitch==phase].mean() for phase in range(pitch)])
  # Boundary score: if one lattice phase has all changes, max/bulk significantly >1.
  score_x=float(x_avg.max()/max(np.median(x_avg),.000001))
  score_y=float(y_avg.max()/max(np.median(y_avg),.000001))
  out.append({'pitch':pitch,'x_peak_ratio':round(score_x,4),'y_peak_ratio':round(score_y,4), 'joint_min_ratio':round(min(score_x,score_y),4), 'x_phase':int(x_avg.argmax()),'y_phase':int(y_avg.argmax())})
 return sorted(out,key=lambda x:-x['joint_min_ratio'])
# Synthetic positive control for detector that truly contains uniform 4x lattice.
rng=np.random.default_rng(1540)
check=np.repeat(np.repeat(rng.integers(0,256,(48,64,3),dtype=np.uint8),4,0),4,1)
calib=grid_test(check,range(2,10))
actual=grid_test(arr)
assert any(c['pitch']==4 and c['joint_min_ratio']>5 for c in calib),calib[:2]
# We do NOT count weak auto-grid 'peaks' as detection. Threshold predeclared at 2.0.
detected=bool(actual[0]['joint_min_ratio']>=2.0)
json.dump({'source':[W,H],'method':'modulo-source-boundary-periodicity vs internal gradients; mean RGB L1 differences; positive-control nearest4 grid','threshold_joint_ratio':2.0,'calibration':calib[:8],'AI_source_candidates':actual,'source_grid_detected':detected,'interpretation':'When false, source does not show measurable periodic lattice at 2–16px; forced grid resampling is NOT a recovered artist-authored grid.'},open(R/'A15_SOURCE_LATTICE_DIAGNOSTIC.json','w'),indent=2)

def sample_grid(gridw,gridh,method='robust'):
 # For each fractional output cell, estimate sampled color by center or robust medoid over 5x5 source samples.
 target=np.zeros((gridh,gridw,3),dtype=np.uint8)
 stepx=W/gridw;stepy=H/gridh
 # row-wise vectorized batches, deterministic no grid-spacing claims on upstream original
 fx=(np.arange(gridw)+.5)*stepx
 offx=np.array([-.39,-.20,0,.20,.39])*stepx
 offy=np.array([-.39,-.20,0,.20,.39])*stepy
 ix=np.clip(np.floor(fx[None,:]+offx[:,None]).astype(int),0,W-1)
 for y in range(gridh):
  cy=(y+.5)*stepy
  iy=np.clip(np.floor(cy+offy).astype(int),0,H-1)
  samples=arr[iy[:,None,None],ix[None,:,:],:] # [5,5,gridw,3]
  samples=samples.transpose(2,0,1,3).reshape(gridw,25,3)
  if method=='center':
   target[y]=samples[:,12,:]
  elif method=='robust':
   med=np.median(samples.astype('float64'),axis=1)
   distance=np.sum((samples.astype('float64')-med[:,None,:])**2,axis=2)
   which=np.argmin(distance,axis=1)
   target[y]=samples[np.arange(gridw),which,:]
  else:raise ValueError(method)
 return Image.fromarray(target,'RGB')

def quantize(im,ncol):
 return im.quantize(colors=ncol,method=Image.Quantize.MEDIANCUT,dither=Image.Dither.NONE).convert('RGB')

def variants():
 out={
  'A15_GRID544_ROBUST_PALETTE128.png':quantize(sample_grid(544,416,'robust'),128),
  'A15_GRID272_ROBUST_PALETTE128_NEAREST2X.png':quantize(sample_grid(272,208,'robust'),128).resize((544,416),Image.Resampling.NEAREST),
  'A15_GRID136_ROBUST_PALETTE64_NEAREST4X.png':quantize(sample_grid(136,104,'robust'),64).resize((544,416),Image.Resampling.NEAREST),
  'A15_GRID272_CENTER_PALETTE128_NEAREST2X.png':quantize(sample_grid(272,208,'center'),128).resize((544,416),Image.Resampling.NEAREST)
 }
 for n,im in out.items():im.save(R/n)
 return out
made=variants()

def mean_adjacent(a):
 return round(float((np.abs(a[:,1:].astype('int16')-a[:,:-1].astype('int16')).mean()+np.abs(a[1:].astype('int16')-a[:-1].astype('int16')).mean())/2),3)

def block_compliance(a,pitch):
 assert a.shape[:2]==(416,544) and 544%pitch==416%pitch==0
 blocks=a.reshape(416//pitch,pitch,544//pitch,pitch,3)
 std=blocks.std(axis=(1,3)).mean()
 fully_uniform=np.all(blocks==blocks[:,0:1,:,0:1,:],axis=(1,3)).mean()
 return {'within_block_mean_std':round(float(std),5),'uniform_blocks_fraction':round(float(fully_uniform),6)}

def summary(im):
 a=np.asarray(im.convert('RGB'),dtype=np.uint8)
 return {'size':[im.width,im.height],'unique_rgb':int(np.unique(a.reshape(-1,3),axis=0).shape[0]),'mean_rgb':np.round(a.mean((0,1)),2).tolist(),'neighbor_L1':mean_adjacent(a),'block2':block_compliance(a,2),'block4':block_compliance(a,4)}
allim={}
for n in ['A14_NATIVE_544x416_LANCZOS_RGB.png','A14_NATIVE_544x416_PALETTE128.png']:
 allim[n]=Image.open(R/n).convert('RGB')
allim.update(made)
benchmark={n:dict(summary(img),sha256=sha(R/n)) for n,img in allim.items()}
# Strong deterministic promises only for explicit forced 2px/4px outputs.
assert benchmark['A15_GRID272_ROBUST_PALETTE128_NEAREST2X.png']['block2']['uniform_blocks_fraction']==1
assert benchmark['A15_GRID136_ROBUST_PALETTE64_NEAREST4X.png']['block4']['uniform_blocks_fraction']==1
assert benchmark['A15_GRID272_CENTER_PALETTE128_NEAREST2X.png']['block2']['uniform_blocks_fraction']==1
assert all(x['size']==[544,416] for x in benchmark.values())
# Native 1x contact sheet, unchanged pixels, no stretch.
contact=Image.new('RGB',(3*546,2*447),(23,25,28)); d=ImageDraw.Draw(contact)
order=[('A14 LANCZOS128','A14_NATIVE_544x416_PALETTE128.png'),('A15 robust 544 / 128','A15_GRID544_ROBUST_PALETTE128.png'),('A15 robust 272 x2 /128','A15_GRID272_ROBUST_PALETTE128_NEAREST2X.png'),('A15 center 272 x2 /128','A15_GRID272_CENTER_PALETTE128_NEAREST2X.png'),('A15 robust 136 x4 /64','A15_GRID136_ROBUST_PALETTE64_NEAREST4X.png'),('A14 LANCZOS RGB','A14_NATIVE_544x416_LANCZOS_RGB.png')]
for i,(label,f) in enumerate(order):
 x=(i%3)*546+1;y=(i//3)*447
 d.text((x+2,y+5),label,fill='white')
 contact.paste(allim[f],(x,y+27))
contact.save(R/'A15_A14_VS_GRID_1X_6WAY.png')
# Center each 32px native patch and upsample strictly for the review sheet
regions=[('flower west',81,240),('flower east',451,165),('road edge',236,193),('center sand',274,273)]
audit=Image.new('RGB',(4*258,len(regions)*279),(22,24,26));d=ImageDraw.Draw(audit)
files=[('A14 Pal128','A14_NATIVE_544x416_PALETTE128.png'),('A15 544','A15_GRID544_ROBUST_PALETTE128.png'),('A15 grid2','A15_GRID272_ROBUST_PALETTE128_NEAREST2X.png'),('A15 grid4','A15_GRID136_ROBUST_PALETTE64_NEAREST4X.png')]
for row,(area,x,y) in enumerate(regions):
 for col,(lab,f) in enumerate(files):
  px=col*258;py=row*279
  d.text((px+2,py+6),f'{area}: {lab}',fill='white')
  tile=allim[f].crop((x,y,x+32,y+32)).resize((256,256),Image.Resampling.NEAREST)
  audit.paste(tile,(px,py+24))
audit.save(R/'A15_32PX_4_REGIONS_NEAREST8X.png')
metadata={'stage':'A15','date':'2026-10-31','real_external_pixelpipeline_code_executed':False,'tools':'Local independently implemented fixed-grid robust-medoid / center fractional-cell sampling + Pillow median-cut palette quantization + integer nearest export','reference_methodology':'ComfyUI-PixelPipeline and pixel-perfect GitHub README, not a binary-equivalent tested implementation','original_gen_id':'7c98239c-d8df-4afc-982a-e6acd595b0ce','source_sha256':sha(src),'source_grid_detected':detected,'native_544x416_grid_variants':benchmark,'interpretation':'2x/4x geometric grid PASS by construction. Does NOT prove artistic Ground3 style or that original high-res AI source had an implied grid. Exact source ground3 reference not included in this container.','art_gate':'PENDING_VISUAL','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO'}
json.dump(metadata,open(R/'A15_PIXEL_GRID_QA.json','w'),indent=2,ensure_ascii=False)
print(json.dumps({'detection':actual[:5],'calibration':calib[:2],'benchmark':benchmark},indent=2)[:6500])
