from pathlib import Path
import numpy as np,json,hashlib
from PIL import Image,ImageDraw
r=Path(r'E:\\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031')
src=Path(r'E:\\GameAssetToolLab_20261023\\ASF_Test_20261031\\VX_A09_3_INENGINE_BRIDGE\\Graphics\\Parallaxes\\ground3.png')
source=Image.open(src).convert('RGB')
sand=Image.open(r'E:\\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031\\A09_GROUND3_ORIGINAL_48.png').convert('RGB')
grass=source.crop((752,282,816,346))
grass.save(r/'A10_GROUND3_GRASS_SOURCE_64.png')
sand.save(r/'A10_GROUND3_SAND_SOURCE_48.png')
assert hashlib.sha256((r/'A10_GROUND3_SAND_SOURCE_48.png').read_bytes()).hexdigest()=='ca7c4ea242a9b81ab39113acdad1de47ed193117d1f5db6c6d2dea5383548adb'
# Exact A05 road geometry, no new geometry variables introduced.
m=np.asarray(Image.open(r'E:\\FS_ROUTE_B_STAGE16_A05_MASKED_INPAINT_20261031\\A05_ROAD_TARGET_MASK_384.png').convert('L'))==255
assert m.shape==(384,384) and m.sum()==28818
Image.fromarray((m*255).astype(np.uint8)).save(r/'A10_ORIGINAL_ROAD_GEOMETRY_384.png')
def fmodel(ref,h,w,seed):
 a=np.asarray(ref,dtype=np.float64);rs=np.random.default_rng(seed)
 n=a.shape[0];p=a.shape[1]
 z=a-a.mean(axis=(0,1))
 amp=np.sqrt(np.mean(np.abs(np.fft.fft2(z,axes=(0,1)))**2,axis=2))
 # Periodic bilinear sampling of source frequency PSD in cycles per pixel.
 fx=np.fft.fftfreq(w)*p;fy=np.fft.fftfreq(h)*n
 xx,yy=np.meshgrid(fx,fy)
 x0=np.floor(xx).astype(int);y0=np.floor(yy).astype(int)
 wx=xx-x0;wy=yy-y0
 def v(dx,dy):return amp[(y0+dy)%n,(x0+dx)%p]
 target=(1-wx)*(1-wy)*v(0,0)+wx*(1-wy)*v(1,0)+(1-wx)*wy*v(0,1)+wx*wy*v(1,1)
 target[0,0]=0
 # Independent random phases, not source pixels or original phase.
 fields=[]
 for k in range(3):
  noise=rs.standard_normal((h,w))
  ft=np.fft.fft2(noise)
  field=np.fft.ifft2(ft/(np.abs(ft)+1e-10)*target).real
  field=(field-field.mean())/(field.std()+1e-9)
  fields.append(field)
 X=np.stack(fields,axis=-1)
 C=np.cov(z.reshape((-1,3)),rowvar=False)
 L=np.linalg.cholesky(C+np.eye(3)*1e-6)
 X=X@L.T+a.mean(axis=(0,1))
 # Match color ranks by channel, avoiding literal copying of 2D source pixels.
 for k in range(3):
  order=np.argsort(X[:,:,k].reshape(-1),kind='stable')
  sourcevals=np.sort(a[:,:,k].reshape(-1))
  index=np.clip(np.rint(np.linspace(0,len(sourcevals)-1,h*w)).astype(int),0,len(sourcevals)-1)
  values=np.empty(h*w,dtype=np.float64)
  values[order]=sourcevals[index]
  X[:,:,k]=values.reshape((h,w))
 return np.clip(X,0,255).astype(np.uint8)
g=fmodel(grass,384,384,101064)
s=fmodel(sand,384,384,101048)
a09=np.asarray(Image.open(r'E:\\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031\\A09_SYNTHETIC_MATERIAL_PRIOR_384.png').convert('RGB'),dtype=np.uint8)
# Create equal green-surface and edge policy; only road texture differs between A and B.
def compose(roadtex):
 out=g.copy();inside=m.copy()
 # 4-neighbor erode 4 times, blend only within the specified road pixels.
 alpha=np.zeros((384,384),dtype=np.float64)
 for layer in range(1,6):
  if not inside.any():break
  alpha[inside]=min(layer/4,1)
  padded=np.pad(inside,((1,1),(1,1)),constant_values=False)
  inside=inside&padded[:-2,1:-1]&padded[2:,1:-1]&padded[1:-1,:-2]&padded[1:-1,2:]
 blend=g.astype(float)*(1-alpha[:,:,None])+roadtex.astype(float)*alpha[:,:,None]
 out[m]=np.clip(blend[m],0,255).astype(np.uint8)
 return out
out_base=compose(a09)
out_spec=compose(s)
Image.fromarray(g).save(r/'A10_NEW_GRASS_SPECTRAL_384.png')
Image.fromarray(s).save(r/'A10_NEW_SAND_SPECTRAL_384.png')
Image.fromarray(out_base).save(r/'A10_A09_PRIOR_COMPARISON_384.png')
Image.fromarray(out_spec).save(r/'A10_SPECTRAL_CANDIDATE_384.png')
Image.fromarray(a09).save(r/'A10_BASELINE_SAND_PRIOR.png')
manifest={'source_full_ground3_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'grass_crop':[752,282,816,346],'sand_crop':[1032,321,1080,369],'grass_source_sha256':hashlib.sha256((r/'A10_GROUND3_GRASS_SOURCE_64.png').read_bytes()).hexdigest(),'sand_source_sha256':hashlib.sha256((r/'A10_GROUND3_SAND_SOURCE_48.png').read_bytes()).hexdigest(),'candidate_source_files':['A10_GROUND3_GRASS_SOURCE_64.png','A10_GROUND3_SAND_SOURCE_48.png'],'generation':{'spectral_phase_seed_grass':101064,'spectral_phase_seed_sand':101048,'algorithm':'2D PSD periodic interpolation + independent random phase + cross-channel covariance + color-rank mapping; no source tile patch donor compositing'},'comparison':'Same grass, same road mask, same feather, only road texture method changed','road_pixels':int(m.sum()),'size':[384,384],'no_AI_model_run_this_stage':True,'formal_seal':'NO'}
(r/'A10_SYNTHESIS_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf8')
sheet=Image.new('RGB',(4*386,419),(20,22,24));dr=ImageDraw.Draw(sheet)
for i,(name,pic) in enumerate([('Grass spectral 384',g),('A09 road + grass',out_base),('A10 spectrum road',out_spec),('A10 sand only 384',s)]):
 x=i*386+1;dr.text((x,7),name,fill='white');sheet.paste(Image.fromarray(pic),(x,27))
sheet.save(r/'A10_FOUR_WAY_1X.png')
print('A10_GENERATED',json.dumps(manifest,indent=2),flush=True)
