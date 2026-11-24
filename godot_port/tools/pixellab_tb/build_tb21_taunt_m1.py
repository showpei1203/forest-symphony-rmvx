#!/usr/bin/env python3
"""T-B R21: source-locked 3x8 real TAUNT, offline M1 and Godot 4.7.2 native test.
Does not call PixelLab. Only actual owner-private source/archives can enter a real M1.
"""
from __future__ import annotations
import argparse,copy,hashlib,io,json,math,zipfile,tempfile
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
BASE=Path('/mnt/data')
SRC_NAME='FS_TB_R20_GLACIER_JACKAL_3STUN_8F_NATIVE_VERIFIED_PRIVATE_20261124.zip'
SRC_SHA='99ef8ab4e12239f32dfbf9573035b149834ac0bcd48243c09ff4b15b69a34b2a'
SRC_SIZE=14871599
M='FS_TB_R21_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=102 evolutions=6 clips=108 frames=982 frost_taunt=3'
def sha(data):return hashlib.sha256(data).hexdigest()
def dump(obj):return json.dumps(obj,indent=2,ensure_ascii=False).encode('utf8')
def png(im):
 b=io.BytesIO();im.save(b,'PNG');return b.getvalue()
def getimage(b):return Image.open(io.BytesIO(b)).convert('RGBA')
def zipcheck(z):
 assert z.testzip() is None
 names=z.namelist();assert len(names)==len(set(names))
 assert all(not Path(x).is_absolute() and '..' not in Path(x).parts and not x.startswith(('\\','/')) for x in names)
 return names
def checkstage(path,stage,meta,test_only=False):
 assert path.is_file()
 with zipfile.ZipFile(path) as z:
  names=zipcheck(z)
  d=json.loads(z.read('R21_JOB_LEDGER.json'))
  assert d['stage']==stage and d['source_r20_sha256']==SRC_SHA
  assert d['source_stage_sha256']==meta['source_sha256']
  assert d['idle_atlas_sha256']==meta['motions']['idle']['sha256']
  assert d['status']=='COMPLETED_SOURCE_QA_PASS'
  assert d['requested_frames']==8 and d['selected_frame_count']==8
  assert d['qa']['frame_qa']=='PASS' and d['qa']['first_last_exact_idle_source'] is True
  assert 0<float(d['reported_usage']['generations'])<=12
  assert isinstance(d['job_id'],str) and len(d['job_id'])>14
  assert d.get('generation_id')
  if not test_only:assert d['task']=='FS_TB_R21_TRUE_PROVOCATION_TAUNT_STAGE'
  raw=z.read('R21_TAUNT_8F_ATLAS.png')
  assert sha(raw)==d['atlas_png_sha256']
  size=meta['source_size'][0]
  a=getimage(raw);assert a.size==(size*4,size*2)
  frames=[a.crop(((k%4)*size,(k//4)*size,(k%4+1)*size,(k//4+1)*size)) for k in range(8)]
  assert [sha(f.tobytes()) for f in frames]==d['qa']['frame_rgba_shas']
  source=getimage(z.read('R21_IDLE_SOURCE_F0.png'))
  assert source.size==(size,size) and frames[0].tobytes()==frames[7].tobytes()==source.tobytes()
  assert len(set(sha(f.tobytes()) for f in frames))>=6
  bounds=[f.getchannel('A').getbbox() for f in frames]
  assert all(b and min(b[0],b[1],size-b[2],size-b[3])>=2 for b in bounds)
  r=[n for n in names if n.startswith('raw_frames/F') and n.endswith('.png')]
  assert len(r) in (8,9) and len(r)==d['raw_returned_frames']
  assert [sha(z.read(n)) for n in sorted(r)]==d['raw_frame_sha256']
  return d,raw,frames

def scene(prev):
 s=prev.replace('TB20_MONSTER_FAMILY_MANIFEST.json','TB21_MONSTER_FAMILY_MANIFEST.json')
 s=s.replace('R20: 3 SOURCE-LOCKED PIXELLAB STUN 8F ANIMATIONS','R21: 3 SOURCE-LOCKED PIXELLAB TAUNT 8F ANIMATIONS')
 s=s.replace('"stun"','"taunt"')
 assert 'range(8)' in s and 'ani.set_animation_loop("taunt",false)' in s
 assert 'TB21_MONSTER_FAMILY_MANIFEST.json' in s
 return s

def native_script(prev):
 s=prev.replace('TB20_MONSTER_FAMILY_MANIFEST.json','TB21_MONSTER_FAMILY_MANIFEST.json')
 for a,b in [
 ('int(doc["clip_count"])==105','int(doc["clip_count"])==108'),
 ('int(doc["total_frames"])==958','int(doc["total_frames"])==982'),
 ('int(doc["baseline_clip_count"])==99','int(doc["baseline_clip_count"])==102'),
 ('assert(count==99 and slots==862)','assert(count==102 and slots==886)'),
 ('tb20_frost_stun_gallery.tscn','tb21_frost_taunt_gallery.tscn'),
 ('"stun"','"taunt"'),
 ('FS_TB_R20_GODOT472_NATIVE_ART_ONLY_PASS families=3 stages=9 motions=99 evolutions=6 clips=105 frames=958 frost_stun=3',M)]:
  assert a in s,('R21 native template source missing',a)
  s=s.replace(a,b)
 assert M in s and 'assert(not spr.sprite_frames.get_animation_loop("taunt"))' in s
 return s

def build(base,stage_paths,out,proof,test_only=False):
 assert not out.exists() and not proof.exists()
 data=base.read_bytes();assert len(data)==SRC_SIZE and sha(data)==SRC_SHA
 with zipfile.ZipFile(io.BytesIO(data)) as z:
  names=zipcheck(z)
  assert len(names)==484
  docs={n:z.read(n) for n in names if not n.endswith('/')}
 manifest=json.loads(docs['godot/TB20_MONSTER_FAMILY_MANIFEST.json'])
 assert (manifest['clip_count'],manifest['total_frames'],manifest['baseline_clip_count'])==(105,958,99)
 frost=next(f for f in manifest['families'] if f['kind']=='frost')
 assert all(len(st['motions'])==9 and 'taunt' not in st['motions'] for st in frost['stages'])
 original_pngs={n:sha(v) for n,v in docs.items() if n.lower().endswith('.png')}
 stages=[checkstage(path,i,frost['stages'][i-1],test_only=test_only) for i,path in enumerate(stage_paths,1)]
 nm=copy.deepcopy(manifest)
 for key in tuple(nm):
  if key.startswith(('native_','official_windows_godot_')):nm.pop(key)
 nm['source_r20_previous_native_log_sha256']=manifest.get('native_log_sha256')
 nm['storage_status']='OWNER_PRIVATE_M1_PENDING'
 frost=next(f for f in nm['families'] if f['kind']=='frost')
 total=0.;ledger=[];review={}
 for i,((d,atlas,frames),path) in enumerate(zip(stages,stage_paths),1):
  st=frost['stages'][i-1];size=st['source_size'][0]
  rel=f'assets/monsters/tb03/FROST_STAGE{i}_TAUNT_R21_TRUE_PIXELLAB_8F_{size}px.png'
  fn='godot/'+rel;assert fn not in docs
  docs[fn]=atlas
  cc=float(d['reported_usage']['generations']);total+=cc
  st['motions']['taunt']={
    'path':rel,'frames':8,'columns':4,'cell':[size,size],'fps':8,'loop':False,
    'sha256':sha(atlas),'source_sha256':st['source_sha256'],
    'source_idle_sha256':d['idle_atlas_sha256'],'endpoint':'animate-with-text-v3',
    'provider_job_id':d['job_id'],'generation_id':d['generation_id'],
    'provider_usage':d['reported_usage'],'raw_returned_frames':d['raw_returned_frames'],
    'raw_original_source_zip_sha256':sha(path.read_bytes()),'exact_source_frames':[0,7],
    'technical_qa':'PASS','semantic_taunt_art':'OWNER_ART_REVIEW_PENDING'}
  ledger.append({'stage':i,'job_id':d['job_id'],'generations':cc,'stage_zip_sha256':sha(path.read_bytes()),
    'source_sha256':st['source_sha256'],'atlas_sha256':sha(atlas)})
  docs['reports/r21_provider_raw/'+path.name]=path.read_bytes()
  review[i]=frames
 assert all(len(x['motions'])==10 for x in frost['stages'])
 nm.update(schema='FS_TB_R21_REAL_PIXELLAB_CHALLENGE_TAUNT_THREE_STAGE_8F',clip_count=108,
    total_frames=982,baseline_clip_count=102,actions_per_family={'bat':12,'frog':12,'frost':10},
    third_family_motions=30,new_pixel_lab_jobs=3,new_provider_generations=total,
    new_true_provider_frame_slots=24,source_r20_zip_sha256=SRC_SHA,
    technical_qa='NATIVE_NOT_RUN',human_art_gate='OWNER_ART_REVIEW_PENDING',
    integration_qa='NOT_RUN_ART_ONLY',
    visual_gate_note='8F genuine PixelLab defiant taunt; not attack, stun or skill. Owner 1x ART assessment pending')
 docs['godot/TB21_MONSTER_FAMILY_MANIFEST.json']=dump(nm)
 docs['reports/R21_THREE_STAGE_PROVIDER_LEDGER.json']=dump(ledger)
 docs['reports/R21_THREE_STAGE_SOURCE_AND_TAUNT_QA.json']=dump({'stages':[{'stage':i,'unique_frames':len(set(sha(f.tobytes()) for f in frames)),
   'status':'STATIC_QA_PASS','taunt_vs_attack_or_skill':'OWNER_REVIEW_PENDING'} for i,frames in review.items()],
   'real_total_generations':total,'art':'OWNER_REVIEW_PENDING'})
 docs['godot/tb21_frost_taunt_gallery.gd']=scene(docs['godot/tb20_frost_stun_gallery.gd'].decode()).encode()
 docs['godot/tb21_frost_taunt_gallery.tscn']=docs['godot/tb20_frost_stun_gallery.tscn'].decode().replace('tb20_frost_stun_gallery.gd','tb21_frost_taunt_gallery.gd').replace('TB20FrostStun','TB21FrostTaunt').encode()
 docs['godot/tests/test_tb21_frost_taunt_native.gd']=native_script(docs['godot/tests/test_tb20_frost_stun_native.gd'].decode()).encode()
 # Render genuine provider outputs ONLY for review; no generative art fabricated in this builder.
 contact=Image.new('RGB',(1280,730),(25,41,59));draw=ImageDraw.Draw(contact)
 draw.text((16,8),'R21 THREE GLACIER JACKAL FORMS / 8F TAUNT EACH / OWNER ART PENDING',fill=(240,220,192))
 for stage,frames in review.items():
  y0=30+(stage-1)*230;draw.text((16,y0+16),f'STAGE {stage} / {frames[0].width}px / F0..F7',fill=(240,220,192))
  for j,f in enumerate(frames):
   x=125+j*144
   q=f.copy();q.thumbnail((130,170),Image.Resampling.NEAREST)
   bg=Image.new('RGBA',q.size,(42,62,82,255));bg.alpha_composite(q)
   contact.paste(bg.convert('RGB'),(x,y0+27));draw.text((x,y0+12),f'F{j}',fill=(225,237,236))
  gif=[]
  for f in frames:
   x=Image.new('RGBA',f.size,(30,49,69,255));x.alpha_composite(f)
   gif.append(x.resize((f.width*2,f.height*2),Image.Resampling.NEAREST).convert('RGB'))
  outgif=io.BytesIO();gif[0].save(outgif,format='GIF',save_all=True,append_images=gif[1:],duration=140,loop=0,disposal=2)
  docs[f'reports/R21_FROST_STAGE{stage}_TAUNT_TRUE_PIXEL_LAB_8F.gif']=outgif.getvalue()
 preview=io.BytesIO();contact.save(preview,'PNG')
 docs['reports/R21_FROST_3STAGE_TAUNT_24F_CONTACT.png']=preview.getvalue()
 assert all(sha(docs[n])==oldsha for n,oldsha in original_pngs.items())
 assert nm['technical_qa']=='NATIVE_NOT_RUN'
 with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for n in sorted(docs):z.writestr(n,docs[n])
 with zipfile.ZipFile(out) as z:
  assert zipcheck(z) and len(z.namelist())==500
  assert M in z.read('godot/tests/test_tb21_frost_taunt_native.gd').decode()
  assert json.loads(z.read('godot/TB21_MONSTER_FAMILY_MANIFEST.json'))['total_frames']==982
 result={'artifact':out.name,'sha256':sha(out.read_bytes()),'bytes':out.stat().st_size,'entries':500,
         'zip_crc':'PASS','source_r20_sha256':SRC_SHA,'provider_jobs':3,'generations':total,
         'new_taunt_clips':3,'new_taunt_frames':24,'total_clips':108,'total_frame_slots':982,
         'godot_4_7_2_native':'NOT_RUN','art':'OWNER_ART_REVIEW_PENDING',
         'battle_integration':'NOT_RUN_ART_ONLY','older_png_bytes_unchanged':True,
         'test_only_synthetic':test_only}
 proof.write_bytes(dump(result))
 print('FS_TB_R21_M1_REAL_THREE_STAGE_SOURCE_QA_PASS',json.dumps(result))
 return result

def synthetic_selftest():
 with tempfile.TemporaryDirectory(prefix='fs_tb21_mock_') as td:
  t=Path(td)
  with zipfile.ZipFile(BASE/SRC_NAME) as z:
   m=json.loads(z.read('godot/TB20_MONSTER_FAMILY_MANIFEST.json'))
   stages=m['families'][2]['stages']
   paths=[]
   for k in (1,2,3):
    st=stages[k-1];size=st['source_size'][0]
    prev=getimage(z.read('godot/'+st['motions']['idle']['path'])).crop((0,0,size,size))
    orig=png(prev);frames=[prev.copy() for i in range(8)]
    # clearly synthetic non-paid frame test; create tiny nonblank perturbations
    for i in range(1,7):
     frames[i].putpixel((max(0,size//2),max(0,size//3)),(55,200+i,231,255))
    atlas=Image.new('RGBA',(4*size,2*size))
    for i,f in enumerate(frames):atlas.alpha_composite(f,((i%4)*size,(i//4)*size))
    p=t/f'MOCK_STAGE{k}.zip'
    ledger={'task':'FS_TB_R21_MOCK_ONLY','stage':k,'source_r20_sha256':SRC_SHA,
            'source_stage_sha256':st['source_sha256'],'idle_atlas_sha256':st['motions']['idle']['sha256'],
            'status':'COMPLETED_SOURCE_QA_PASS','job_id':f'MOCK_TEST_ONLY_STAGE_{k}','generation_id':'MOCK_ID',
            'requested_frames':8,'selected_frame_count':8,'reported_usage':{'generations':4},
            'atlas_png_sha256':sha(png(atlas)),'raw_returned_frames':8,
            'raw_frame_sha256':[sha(png(f)) for f in frames],
            'qa':{'frame_qa':'PASS','first_last_exact_idle_source':True,'frame_rgba_shas':[sha(f.tobytes()) for f in frames]}}
    with zipfile.ZipFile(p,'w',zipfile.ZIP_DEFLATED) as q:
     q.writestr('R21_JOB_LEDGER.json',dump(ledger));q.writestr('R21_IDLE_SOURCE_F0.png',orig)
     q.writestr('R21_TAUNT_8F_ATLAS.png',png(atlas))
     for i,f in enumerate(frames):q.writestr(f'raw_frames/F{i:02d}.png',png(f))
    paths.append(p)
  out=t/'MOCK_SOURCE.zip';proof=t/'MOCK_PROOF.json'
  res=build(BASE/SRC_NAME,paths,out,proof,test_only=True)
  assert res['test_only_synthetic'] and res['godot_4_7_2_native']=='NOT_RUN'
  print('FS_TB_R21_OFFLINE_FULL_M1_SCHEMA_NATIVE_SCENE_AND_GALLERY_MOCK_PASS paid_jobs=0')

if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--selftest',action='store_true');ap.add_argument('--stage1',type=Path);ap.add_argument('--stage2',type=Path);ap.add_argument('--stage3',type=Path);ap.add_argument('--out',type=Path);ap.add_argument('--proof',type=Path)
 args=ap.parse_args()
 if args.selftest:synthetic_selftest()
 else:
  assert all((args.stage1,args.stage2,args.stage3,args.out,args.proof))
  build(BASE/SRC_NAME,[args.stage1,args.stage2,args.stage3],args.out,args.proof)