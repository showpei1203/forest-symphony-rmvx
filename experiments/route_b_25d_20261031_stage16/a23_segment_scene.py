from pathlib import Path
import numpy as np,json,hashlib
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent
A22=R if (R/'A22_CLEAN_STYLE_NATIVE128_VARIANT_01.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A22_CLEAN_STYLE_AB_20261101')
A21=Path(r'E:\FS_ROUTE_B_STAGE16_A21_FS_PURE_GROUND_REFS_20261101')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
expected=['b0338b6f1949be1066f30719ebca3d891a620e74b02f38e4a9f449ea93c32248','2de1a37dff0c42a76ab1dc1a09d01b09f42d663b1527b6f8e043931d73c467ec','58155bb1bd6578a6b264767be3b1de9f886b7840a9ba9eb8c29ea4eb65686067','afa37a231d1c8727f0136dcbe24228c46952a2504e25af188aff591b83485e2c']
def majority(mask,r=2,n=2):
 a=mask.copy()
 for _ in range(n):
  src=np.pad(a.astype(np.int16),r,mode='edge')
  count=np.zeros(a.shape,np.int16)
  for dy in range(2*r+1):
   for dx in range(2*r+1):count+=src[dy:dy+a.shape[0],dx:dx+a.shape[1]]
  a=count>((2*r+1)**2//2)
 return a
def largest(mask):
 h,w=mask.shape
 seen=np.zeros(mask.shape,bool);best=[]
 for y in range(h):
  for x in range(w):
   if seen[y,x] or not mask[y,x]:continue
   stack=[(y,x)];seen[y,x]=1;path=[]
   while stack:
    yy,xx=stack.pop();path.append((yy,xx))
    for ty,tx in ((yy-1,xx),(yy+1,xx),(yy,xx-1),(yy,xx+1)):
     if 0<=ty<h and 0<=tx<w and mask[ty,tx] and not seen[ty,tx]:
      seen[ty,tx]=1;stack.append((ty,tx))
   if len(path)>len(best):best=path
 out=np.zeros(mask.shape,bool)
 if best: ys,xs=np.array(best).T;out[ys,xs]=1
 return out,len(best)
qa=[]
sheet=Image.new('RGB',(4*264,3*158),(23,24,27));d=ImageDraw.Draw(sheet)
for i,hsh in enumerate(expected):
 p=A22/f'A22_CLEAN_STYLE_NATIVE128_VARIANT_{i+1:02d}.png'
 assert sha(p)==hsh
 arr=np.asarray(Image.open(p).convert('RGB'),dtype=np.uint8)
 a=arr.astype(np.int16);r,g,b=a[:,:,0],a[:,:,1],a[:,:,2]
 raw=(r>g+9)&(r>115)&(g>93)&(b>49)&(r>g*1.045)
 smoothed=majority(raw,1,2)
 keep,count=largest(smoothed)
 rawarea=int(raw.sum());ca=int(keep.sum());major=float(ca/max(int(smoothed.sum()),1))
 assert ca>900 and ca<10500 and major>0.92,(i,ca,major)
 rawmask=Image.fromarray((raw*255).astype('uint8'),'L')
 mask=Image.fromarray((keep*255).astype('uint8'),'L')
 rawmask.save(R/f'A23_VARIANT_{i+1:02d}_RAW_SAND_MASK.png')
 mask.save(R/f'A23_VARIANT_{i+1:02d}_CONNECTED_SAND_MASK.png')
 visual=arr.copy();visual[keep]=((visual[keep].astype(np.uint16)*3+np.array([255,240,80]))//4).astype('uint8')
 x=i*264
 sheet.paste(Image.fromarray(arr),(x,22))
 sheet.paste(mask.convert('RGB'),(x,179))
 sheet.paste(Image.fromarray(visual),(x,337))
 for row,name in enumerate(('RAW MODEL','SAND BINARY','PATH OVERLAY')):
  d.text((x+2,row*158+2),f'A22 #{i+1}: {name}',fill='white')
 qa.append({'model_variant':i+1,'model_source_sha256':hsh,'road_original_raw_mask_fraction':round(rawarea/16384,4),'road_connected_pixel_count':ca,'road_connected_fraction':round(ca/16384,4),'largest_component_of_smoothed_mask':round(major,6),'road_mask_sha256':sha(R/f'A23_VARIANT_{i+1:02d}_CONNECTED_SAND_MASK.png')})
sheet.save(R/'A23_SEMANTIC_ROAD_MASK_1X_AUDIT.png')
(R/'A23_SEGMENTATION_QA.json').write_text(json.dumps({'stage':'A23','date':'2026-11-01','method':'channel-rule+3x3 majority twice+largest 4-connected component','status':'PRELIMINARY_ENGINEERING_DIAGNOSTIC','paid_generations':0,'variants':qa,'formal_seal':'NO'},indent=2),encoding='utf8')
print('A23_SEGMENTATION',json.dumps(qa,ensure_ascii=False),flush=True)
