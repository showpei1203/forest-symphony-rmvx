#!/usr/bin/env python3
"""FS T-A R23: exact A62/A52 visible-source layer decomposition, NOT new art.

Uses only original 64px source pixels. Pixel ownership is exclusive and static;
no underpaint, no garment backfaces, no true LPC-original costume modules.
"""
from __future__ import annotations
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED, ZIP_STORED
from PIL import Image, ImageDraw
from io import BytesIO
from collections import Counter
import json,hashlib,xml.etree.ElementTree as ET,shutil

REF_SHA='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
BODY_SHA='a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f'
SOURCE_PATH='source_provenance/A62_APPROVED_ACTOR01_F0_64.png'
BODY_PATH='A52_REAL_MODEL_BODY_12FRAME_256x192.png'
LAYER_NAMES=['head_hair_visible','far_arm_sleeve_visible','near_arm_sleeve_visible','torso_coat_belly_visible','belt_waist_visible','pants_visible','boots_visible']
SHA=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()

def img_bytes(im):
 b=BytesIO();im.save(b,'PNG');return b.getvalue()

def chunk(frame,i):
 return frame.crop((64*(i%4),64*(i//4),64*(i%4+1),64*(i//4+1)))

def role(x,y,rgba):
 # Deterministic provenance masks, not inferred anatomical boundary truth.
 # No drawing, anti-aliasing, interpolated color or added underpaint.
 r,g,b,a=rgba
 if y<=31 or (y<=34 and 22<=x<=35 and (r+g+b)>260): return 0
 if y>=49 and r>g and g>=b: return 6
 if y>=47: return 5
 if 42<=y<=46 and 27<=x<=40: return 4
 if 30<=y<=46 and x<=28: return 1
 if 30<=y<=46 and x>=39: return 2
 if y>=44 and 29<=x<=38: return 5
 return 3

def segment(frame):
 layers=[Image.new('RGBA',(64,64)) for _ in LAYER_NAMES]
 picks=[lay.load() for lay in layers]
 src=frame.load()
 counts=[0]*len(layers)
 for y in range(64):
  for x in range(64):
   c=src[x,y]
   if c[3]==0: continue
   idx=role(x,y,c)
   picks[idx][x,y]=c
   counts[idx]+=1
 reconstructed=Image.new('RGBA',(64,64))
 for lay in layers:reconstructed.alpha_composite(lay)
 assert reconstructed.tobytes()==frame.tobytes(), 'R23 source RGBA parity broken'
 assert sum(counts)==len([a for a in frame.getchannel('A').getdata() if a>0])
 return layers,counts

def ora(path,frame,layers,frame_num):
 root=ET.Element('image',version='0.0.3',w='64',h='64',name=f'FS-A62-F{frame_num:02d}-VISIBLE-ONLY')
 stack=ET.SubElement(root,'stack',{'name':'VisiblePixelOwners_ONLY_NotOriginalHiddenLPC','opacity':'1.0','visibility':'visible','composite-op':'svg:src-over'})
 for idx in reversed(range(len(layers))):
  ET.SubElement(stack,'layer',{'name':LAYER_NAMES[idx]+' [VISIBLE-SOURCE-ONLY]','src':f'data/layer{idx:02d}.png','x':'0','y':'0','opacity':'1','visibility':'visible','composite-op':'svg:src-over'})
 with ZipFile(path,'w') as z:
  z.writestr('mimetype','image/openraster',compress_type=ZIP_STORED)
  z.writestr('stack.xml',b'<?xml version="1.0" encoding="UTF-8"?>\n'+ET.tostring(root,encoding='utf-8'))
  for i,layer in enumerate(layers):z.writestr(f'data/layer{i:02d}.png',img_bytes(layer),ZIP_DEFLATED)
  z.writestr('mergedimage.png',img_bytes(frame),ZIP_DEFLATED)
  z.writestr('Thumbnails/thumbnail.png',img_bytes(frame),ZIP_DEFLATED)
 with ZipFile(path) as z:
  assert z.testzip() is None
  assert len(ET.fromstring(z.read('stack.xml')).find('stack').findall('layer'))==7
  assert Image.open(BytesIO(z.read('mergedimage.png'))).convert('RGBA').tobytes()==frame.tobytes()

def build(a52,output,concept):
 output.mkdir(parents=True,exist_ok=True)
 (output/'layers').mkdir(exist_ok=True);(output/'openraster').mkdir(exist_ok=True)
 with ZipFile(a52) as z:
  assert z.testzip() is None
  body=z.read(BODY_PATH); ref=z.read(SOURCE_PATH)
 assert hashlib.sha256(body).hexdigest()==BODY_SHA
 assert hashlib.sha256(ref).hexdigest()==REF_SHA
 source=Image.open(BytesIO(body)).convert('RGBA')
 approved=Image.open(BytesIO(ref)).convert('RGBA')
 assert source.size==(256,192) and approved.size==(64,64)
 assert chunk(source,0).tobytes()==approved.tobytes()==chunk(source,11).tobytes()
 assert set(source.getchannel('A').getdata())=={0,255},'expected binary original source alpha'
 original_png=output/'A62_ORIGINAL_FULLBODY_F0_64_SOURCE_LOCK.png';original_png.write_bytes(ref)
 counts_by_frame=[];original_frames=[];layer_atlases={name:Image.new('RGBA',(256,192)) for name in LAYER_NAMES}
 masks_sha=[]
 for i in range(12):
  original=chunk(source,i);original_frames.append(original)
  layers,counts=segment(original)
  counts_by_frame.append(dict(zip(LAYER_NAMES,counts)))
  assert sum(counts)>0
  ora(output/'openraster'/f'A52_F{i:02d}_VISIBLE_SOURCE_ONLY.ora',original,layers,i)
  for name,lay in zip(LAYER_NAMES,layers):
   layer_atlases[name].alpha_composite(lay,(64*(i%4),64*(i//4)))
  if i in (0,4,7):
   for name,lay in zip(LAYER_NAMES,layers):lay.save(output/'layers'/f'F{i:02d}_{name}.png')
 # Whole atlas reconstruction exactly matches actual complete model source
 complete=Image.new('RGBA',(256,192))
 for name in LAYER_NAMES:
  p=output/'layers'/f'R23_{name}_12x64.png'
  layer_atlases[name].save(p)
  complete.alpha_composite(layer_atlases[name])
  masks_sha.append({'layer':name,'png_sha256':SHA(p), 'opaque_pixels':sum(1 for a in layer_atlases[name].getchannel('A').getdata() if a)})
 assert complete.tobytes()==source.tobytes()
 complete.save(output/'A52_RECOMPOSED_EXACT_ALL_12.png')
 body_path=output/'A52_ORIGINAL_COMPLETE_BODY_12.png';body_path.write_bytes(body)
 assert SHA(body_path)==BODY_SHA
 assert len({f.tobytes() for f in original_frames})==11
 # Original F0, F4, F7/source part contact at 1x / 5x; cannot fake articulation.
 for scale in (1,5):
  s=64*scale
  panel=Image.new('RGBA',((len(LAYER_NAMES)+2)*s,s+23),(27,31,35,255))
  draw=ImageDraw.Draw(panel)
  fnum=7
  layers,_=segment(original_frames[fnum]);seq=[('A52 ORIG',original_frames[fnum])]+list(zip(LAYER_NAMES,layers))+[('RECOMPOSE',original_frames[fnum])]
  for n,(label,piece) in enumerate(seq):
   panel.alpha_composite(piece.resize((s,s),Image.Resampling.NEAREST),(n*s,23))
   draw.text((n*s+2,4),str(n) if scale==1 else label[:18],fill=(239,242,239,255))
  panel.convert('RGB').save(output/f'R23_F07_SOURCE_LAYERS_{scale}X.png')
 # 12 keypose comparison, model source unchanged
 panel=Image.new('RGBA',(4*64,3*64),(26,30,35,255))
 for i,fr in enumerate(original_frames):panel.alpha_composite(fr,(64*(i%4),64*(i//4)))
 panel.convert('RGB').save(output/'R23_COMPLETE_SOURCE_12FRAMES_1X.png')
 panel.resize((1024,768),Image.Resampling.NEAREST).convert('RGB').save(output/'R23_COMPLETE_SOURCE_12FRAMES_4X.png')
 # Can new conceptual 5-key drawing be promoted? No, dimensions, source F0, original art identity fail.
 concept_report={'available':bool(concept and concept.is_file()),'source_verified':False,'production_image_accepted':False}
 if concept and concept.exists():
  c=Image.open(concept)
  concept_report.update({'original_size':list(c.size),'mode':c.mode,'intended_original_character_size':[64,64],
   'not_valid_source_atlas':c.size!=(256,192),'is_5_pose_concept_only':True,
   'fail_reasons':['not original A62 full body pixel source','logical source silhouette and head scale differ','no five 64x64 independently verified source frames','background is baked checkerboard, not transparent original asset']})
  shutil.copyfile(concept,output/'R23_ART_CONCEPT_5POSE_QUARANTINED_NOT_GAME_ART.png')
 report={
  'stage':'R23_A62_FULLBODY_VISIBLE_LAYER_COMPOSITOR_SOURCE_APPROVED',
  'source_body_sha256':BODY_SHA,'source_F0_sha256':REF_SHA,
  'source_alpha_only':[0,255], 'frame_size':[64,64], 'grid':[4,3], 'atlas_size':[256,192],
  'source_frames':12,'source_unique_poses':11, 'provenance':'real original A52 paid PixelLab output; full original body RGBA unchanged',
  'layer_type':'7 exclusive visible-pixel ownership masks PER SOURCE FRAME, NOT actual original LPC hidden clothing layers',
  'mask_names':LAYER_NAMES,'mask_atlases':masks_sha,'counts_by_frame':counts_by_frame,
  'output_R23_source_recompose_rgba_diff_per_frame':[0]*12,
  'original_body_altered_pixels':0,'new_art_pixels':0,
  'real_original_LPC_hidden_clothes':False,'real_45degree_LPC_unarmed_source':False,
  'new_arm_underpaint':False,'new_natural_boxing_art':'NOT_GENERATED',
  'actual_art_quality':'HOLD', 'production_ready':False,'full_formal_FSBattle':'NOT_RUN',
  'concept_art':concept_report,'Godot_native':'PENDING_REAL_TEST'}
 (output/'R23_SOURCE_PROVENANCE.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 # negative source tamper and missing segment fail closed
 original_p=output/'layers'/f'R23_{LAYER_NAMES[3]}_12x64.png'
 b=original_p.read_bytes();im=Image.open(BytesIO(b)).convert('RGBA')
 r,g,bl,alpha=im.getpixel((32,38));assert alpha==255
 im.putpixel((32,38),((r+1)%256,g,bl,alpha))
 mutated=Image.new('RGBA',(256,192))
 for name in LAYER_NAMES:
  lay=im if name==LAYER_NAMES[3] else layer_atlases[name]
  mutated.alpha_composite(lay)
 assert mutated.tobytes()!=source.tobytes(), 'tamper did not fail'
 missing=Image.new('RGBA',(256,192))
 for name in LAYER_NAMES:
  if name!=LAYER_NAMES[3]:missing.alpha_composite(layer_atlases[name])
 assert missing.tobytes()!=source.tobytes(), 'missing belly layer not detected'
 qa={'full_source_RGBA_parity':'PASS_ZERO_DIFF_12_OF_12',
     'source_mask_ownership':'PASS_EXACT_NO_ADDED_ART_PIXELS',
     'verified_F0_64_source_sha':REF_SHA,'verified_A52_fullbody_source_sha':BODY_SHA,
     'reject_mutated_visible_torso_pixel':True,'reject_missing_belly_torso_layer':True,
     'n_real_original_underpaint_layers':0,
     'source_native_LPC_paperdoll_modules':'HOLD',
     'new_five_pose_concept':'SOURCE_IDENTITY_REJECTED_ART_HOLD',
     'model_generated_new_punch':'NOT_RUN'}
 (output/'R23_SOURCE_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 return report,qa

if __name__=='__main__':
 import argparse
 ap=argparse.ArgumentParser();ap.add_argument('--a52',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--concept',type=Path);args=ap.parse_args()
 r,q=build(args.a52,args.out,args.concept)
 print(json.dumps({'layer_count':len(r['mask_names']),'frames':r['source_frames'],'source_rgba_diff':r['original_body_altered_pixels'],'new_art_pixels':r['new_art_pixels'],'concept_accepted':r['concept_art']['production_image_accepted'],'source_status':'PASS','art_status':'HOLD'},ensure_ascii=False))
