from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
R=Path(__file__).resolve().parent
state=json.loads((R/'A20_ONE_STYLE_JOB_STATE.json').read_text(encoding='utf8'))
assert state['status']=='COMPLETED_VALID_PNG' and state['submit_attempts']==1
refs=json.loads((R/'A20_FS_STYLE_REFERENCE_MANIFEST.json').read_text(encoding='utf8'))
for row in refs['references']:
 p=R/row['filename']
 assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
images=[]
for row in state['outputs']:
 p=R/row['file']
 assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
 with Image.open(p) as im:
  assert im.format=='PNG' and im.size==(128,128)
  images.append(im.convert('RGB').copy())
A19=Path(r'E:\FS_ROUTE_B_STAGE16_A19_PIXELLAB_AUTH_20261031\A19_PIXELLAB_PRO_NATIVE128_MODEL_ORIGINAL.png')
assert hashlib.sha256(A19.read_bytes()).hexdigest()=='ad073344c627c8d7e727ddbb36092d6f7010f87eb2fd4732166868115dc02c8e'
baseline=Image.open(A19).convert('RGB')
def detail(a):
 x=np.asarray(a,dtype=np.float64)
 return {'colors':int(np.unique(x.reshape(-1,3),axis=0).shape[0]),'neighbor_L1':round(float((np.abs(x[1:]-x[:-1]).mean()+np.abs(x[:,1:]-x[:,:-1]).mean())/2),3),'RGB_mean':np.round(x.mean(axis=(0,1)),2).tolist()}
stats={'stage':'A20','method':'ACTUAL_PIXEL_LAB_GENERATE_WITH_STYLE_V2','charged_post_count':1,'source_reference_count':3,'source_reference_native_pixels':True,'provider_outputs':len(images),'A19_baseline':detail(baseline),'variants':[],'formal_seal':'NO','ground3_art':'PENDING_VISUAL_REVIEW','game_544x416':'NOT_RUN','godot':'NOT_RUN','vx':'NOT_RUN'}
for n,im in enumerate(images):
 stats['variants'].append({'variant':n+1,'file':state['outputs'][n]['file'],'sha256':state['outputs'][n]['sha256'],**detail(im)})
if state.get('balance_after'):
 b,a=state['balance_before'],state['balance_after']
 stats['measured_generations_spent']=float(b['generations'])-float(a['generations'])
 stats['balance_before']=b['generations'];stats['balance_after']=a['generations']
 stats['usd_credits_delta']=float(b.get('usd_credits') or 0)-float(a.get('usd_credits') or 0)
# Original size 1x comparison (native pixels, no interpolation).
sheet=Image.new('RGB',(6*180,179),(22,24,26));dr=ImageDraw.Draw(sheet)
items=[('A19 PRO',baseline)]+[(f'A20 STYLE {i+1}',a)for i,a in enumerate(images)]
for i,(name,img) in enumerate(items):
 x=i*180+2
 dr.text((x+3,4),name,fill='white')
 sheet.paste(img,(x+18,27))
sheet.save(R/'A20_A19_VS_STYLE_NATIVE_1X.png')
sheet2=Image.new('RGB',(len(items)*260,292),(21,22,24));dr=ImageDraw.Draw(sheet2)
for i,(name,img) in enumerate(items):
 x=i*260
 dr.text((x+3,4),name+' nearest 2x',fill='white')
 sheet2.paste(img.resize((256,256),Image.Resampling.NEAREST),(x,28))
sheet2.save(R/'A20_A19_VS_STYLE_NEAREST2X.png')
# 32px source/reference and results at matching native grid (displays nearest 8x).
samples=[('FS real grass',Image.open(R/refs['references'][0]['filename']).convert('RGB').crop((22,35,54,67))),
 ('FS real sand',Image.open(R/refs['references'][1]['filename']).convert('RGB').crop((47,72,79,104))),
 ('A19 grass',baseline.crop((5,33,37,65))),('A19 road',baseline.crop((53,46,85,78)))]
for i,img in enumerate(images):
 samples.extend([(f'A20 #{i+1} grass',img.crop((5,33,37,65))),(f'A20 #{i+1} center',img.crop((48,45,80,77)))])
lens=Image.new('RGB',(4*260,((len(samples)+3)//4)*292),(22,23,25));dr=ImageDraw.Draw(lens)
for i,(name,img) in enumerate(samples):
 x=i%4*260;y=i//4*292
 dr.text((x+3,y+4),name,fill='white')
 lens.paste(img.resize((256,256),Image.Resampling.NEAREST),(x,y+27))
lens.save(R/'A20_32PX_FS_VS_STYLE_AUDIT.png')
(R/'A20_MODEL_VS_A19_QA.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2),encoding='utf8')
print('A20_NATIVE_QA',json.dumps(stats,ensure_ascii=False)[:3800],flush=True)
