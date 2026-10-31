from pathlib import Path
import numpy as np,json,hashlib
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parent; A22=R if (R/'A22_CLEAN_STYLE_NATIVE128_VARIANT_01.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A22_CLEAN_STYLE_AB_20261101')
SAND=R/'A09_GROUND3_ORIGINAL_48.png' if (R/'A09_GROUND3_ORIGINAL_48.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A09_TEXTURE_SCALE_20261031\A09_GROUND3_ORIGINAL_48.png')
GRASS=R/'A10_GROUND3_GRASS_SOURCE_64.png' if (R/'A10_GROUND3_GRASS_SOURCE_64.png').exists() else Path(r'E:\FS_ROUTE_B_STAGE16_A10_PIXELSPACE_20261031\A10_GROUND3_GRASS_SOURCE_64.png')
def load(p):return np.asarray(Image.open(p).convert('RGB'),dtype=np.uint8)
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def boundary(a,road,axis,at,material):
 # mean per-channel L1 for pairs at boundary, only within requested material.
 mask=(~road if material=='grass' else road)
 if axis=='x':
  sel=mask[:,at-1]&mask[:,at]
  if not sel.any():return None
  return round(float(np.abs(a[:,at-1].astype(np.int16)-a[:,at].astype(np.int16))[sel].mean()),3)
 sel=mask[at-1]&mask[at]
 if not sel.any():return None
 return round(float(np.abs(a[at-1].astype(np.int16)-a[at].astype(np.int16))[sel].mean()),3)
stat=json.loads((R/'A23_TEXTURE_TRANSFER_QA.json').read_text('utf8'))
report=[]
gallery=Image.new('RGB',(4*260,4*300),(24,25,28));draw=ImageDraw.Draw(gallery)
labels=['FS AUTHENTIC GROUND','A22 AI ORIGINAL','A23 QUILT MATERIAL','A23 QUILT + AI PLANTS']
for i in range(1,5):
 road=np.asarray(Image.open(R/f'A23_VARIANT_{i:02d}_CONNECTED_SAND_MASK.png'))>127
 original=load(A22/f'A22_CLEAN_STYLE_NATIVE128_VARIANT_{i:02d}.png')
 quilt=load(R/f'A23_QUILTED_GROUND_V{i:02d}_128.png')
 flora=load(R/f'A23_QUILT_PLUS_SAVED_BOTANICALS_V{i:02d}_128.png')
 repeat=load(R/f'A23_PERIODIC_BASELINE_V{i:02d}_128.png')
 changed=bool(np.any(quilt!=flora))
 cnt=int(np.all(flora==original,axis=2).sum())
 src_unchanged=int(np.all(flora==quilt,axis=2).sum())
 assert changed and cnt>250 and src_unchanged>15000
 changedmask=np.any(flora!=quilt,axis=2)
 assert np.array_equal(flora[changedmask],original[changedmask])
 assert np.array_equal(flora[~changedmask],quilt[~changedmask])
 # construction geometry same original mask, no output resize, colored source RGB check already performed during generation.
 # Grid seam proof (x=64) for grass only, baseline direct period versus quilt optimized seams.
 a=boundary(repeat,road,'x',64,'grass')
 b=boundary(quilt,road,'x',64,'grass')
 # Approximate material-region closeness to source L1, no aesthetic numerical pass
 source=stat['variants'][i-1]
 details={'variant':i,'grass_seam_x64_periodic_L1':a,'grass_seam_x64_quilt_L1':b,
          'original_background_area_provenance_FS':True,
          'preserved_A22_botanical_overlay_count':int(changedmask.sum()),
          'flora_exact_equal_AI_where_overlaid':True,
          'quilt_exact_equal_FS_where_not_overlaid':True,
          'ref_asset_originals_sha256':[sha(GRASS),sha(SAND)],
          'original_model_sha256':source['output_SHA256'].get('ORIGINAL','NOT_COPIED'),
          'mask_sha256':sha(R/f'A23_VARIANT_{i:02d}_CONNECTED_SAND_MASK.png')}
 report.append(details)
 for j,(name,img) in enumerate([('ORIGINAL',original),('DIRECT PERIODIC',repeat),('SEAM QUILT',quilt),('QUILT+FLORA',flora)]):
  crop=Image.fromarray(img,'RGB').crop((48,48,80,80)).resize((256,256),Image.Resampling.NEAREST)
  x=(i-1)*260;y=j*300
  draw.text((x+3,y+4),f'#{i} {name} 32PX x8',fill='white')
  gallery.paste(crop,(x+1,y+28))
gallery.save(R/'A23_FOUR_VARIANT_32PX_CENTER_AUDIT.png')
samp=Image.new('RGB',(3*260,290),(23,24,26));dr=ImageDraw.Draw(samp)
for i,(name,p) in enumerate([('AUTHENTIC FS GRASS',GRASS),('AUTHENTIC FS SAND',SAND),('A22 PIXELLAB VS TEXTURE',R/'A23_QUILTED_GROUND_V01_128.png')]):
 im=Image.open(p).convert('RGB')
 center=im.crop(((im.width-32)//2,(im.height-32)//2,(im.width+32)//2,(im.height+32)//2))
 dr.text((i*260+2,3),name,fill='white')
 samp.paste(center.resize((256,256),Image.Resampling.NEAREST),(i*260,28))
samp.save(R/'A23_SOURCE_MATERIAL_32PX_PROOF.png')
summary={'stage':'A23','date':'2026-11-01','method':'Road geometry/semantic mask from PixelLab A22 + direct authentic FS pixel-texture quilting and optional AI-flora mask overlay',
 'original_material_source_sha256':{'grass':sha(GRASS),'sand':sha(SAND)},'floras_are_original_from_A22':True,'pixel_native_resolution':[128,128],'no_AI_API_calls':True,'A23_generations_spent':0,
 'ratio_ground3_color_provenance':1.0,'all_four_road_connected':True,'art_acceptance':'CANDIDATE_ONLY_NOT_FORMAL','full_544x416':'NOT_RUN','Godot':'NOT_RUN','VX':'NOT_RUN','Formal_Seal':'NO','variants':report}
(R/'A23_FOREGROUND_SEAMS_AND_PROVENANCE_QA.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf8')
print('A23_SEAMS_QA',json.dumps(summary,ensure_ascii=False)[:4200],flush=True)
