#!/usr/bin/env python3
"""R11 original PMD lava frog family 3 stages. Sprite-only QA + previews.
Exact user-approved PMD0001 V6 never edited. No battle code touched.
"""
from pathlib import Path
import json,hashlib,math,zipfile
from PIL import Image,ImageDraw,ImageFont
R=Path(__file__).resolve().parent
G=R/'godot'; A=G/'assets/monsters/pmd';REPORT=R/'reports';REPORT.mkdir(exist_ok=True)
JOBS=json.loads((REPORT/'R11_PROVIDER_JOB_LEDGER.json').read_text())
FRAMECOUNTS={'idle':8,'attack':11,'hurt':6,'ko':8}
FPS={'idle':8,'attack':10,'hurt':9,'ko':7}
SHA=lambda b:hashlib.sha256(b).hexdigest()
manifest={'schema':'fs-tb11-original-lava-frog-family-v1','family_id':'PMD_LAVA_FROG','target_engine':'Godot 4.7.2','art_gate':'OWNER_REVIEW_NEEDED_FOR_NEW_ANIMATIONS','battle_engine_modifications':False,'original_approved':'PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png','stages':[]}
rows=[];issues=[]
for stage in range(1,4):
 source=A/f'PMD000{stage}_STATIC_64.png'
 assert source.is_file() and Image.open(source).size==(64,64)
 ent={'index':stage,'name':['Lava Frog Young','Magma Frog Guardian','Ancient Lava Toad'][stage-1],'source_path':'assets/monsters/pmd/'+source.name,'source_size':[64,64],'source_sha256':SHA(source.read_bytes()),'motions':{}}
 for action in ('idle','attack','hurt','ko'):
  name=(f'PMD0001_IDLE_3F_192x64.png' if stage==1 and action=='idle' else
   f'PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png' if stage==1 and action=='attack' else
   f'PMD000{stage}_{action.upper()}_{FRAMECOUNTS[action]}F_128px.png')
  path=A/name
  if not path.is_file():continue
  count=3 if stage==1 and action=='idle' else FRAMECOUNTS[action]
  size=64 if stage==1 and action=='idle' else 96 if stage==1 and action=='attack' else 128
  cols=3 if stage==1 and action=='idle' else 4
  expected=(size*cols,math.ceil(count/cols)*size)
  im=Image.open(path).convert('RGBA')
  if im.size!=expected:
   issues.append({'stage':stage,'action':action,'reason':f'wrong atlas {im.size} != {expected}','blocking':True});continue
  alpha_nonempty=[];borders=[];unique=[]
  for k in range(count):
   f=im.crop(((k%cols)*size,(k//cols)*size,((k%cols)+1)*size,((k//cols)+1)*size))
   a=f.getchannel('A');alpha_nonempty.append(sum(v>0 for v in a.getdata()))
   borders.append(sum(a.getpixel((x,y))>0 for x in range(size) for y in (0,size-1))+sum(a.getpixel((x,y))>0 for y in range(1,size-1) for x in (0,size-1)))
   unique.append(SHA(f.tobytes()))
  ok=(all(z==0 for z in borders) and len(set(unique))>=min(3,count) and min(alpha_nonempty)>100)
  # Legacy original V6 attack and idle were already accepted/tested as source; do not regress a legacy approved frame on new border-only heuristic.
  if stage==1 and action in ('idle','attack'):
   qa='PREVIOUSLY_VALIDATED' if len(set(unique))>=min(3,count) else 'HOLD'
  else:qa='PASS' if ok else 'HOLD'
  if qa=='HOLD':issues.append({'stage':stage,'action':action,'reason':'border contact, empty frames or <3 unique frames','border':borders,'alpha_nonempty':alpha_nonempty,'blocking':True})
  status='USER_ART_ACCEPTED' if stage==1 and action=='attack' else ('LEGACY_SOURCE_ACCEPTED' if stage==1 and action=='idle' else 'ART_REVIEW_PENDING')
  meta={'path':'assets/monsters/pmd/'+path.name,'frames':count,'columns':cols,'cell':[size,size],'fps':FPS[action],'loop':action=='idle','sha256':SHA(path.read_bytes()),'frame_unique':len(set(unique)),'border_counts':borders,'technical_qa':qa,'art_status':status}
  if stage>1 or action in ('hurt','ko'):
   job=JOBS.get(f'{stage}_{action}',{})
   meta.update({'provider_job_id':job.get('job_id'),'generation_id':job.get('generation_id'),'provider_usage':job.get('usage'),'source_sha256':job.get('source_sha256')})
  ent['motions'][action]=meta
  rows.append({'stage':stage,'action':action,'frames':count,'qa':qa,'source':source.name,'atlas':path.name,'sha':meta['sha256'],'border':borders,'unique':len(set(unique))})
 manifest['stages'].append(ent)
manifest['motion_count']=len(rows);manifest['total_frames']=sum(x['frames'] for x in rows);manifest['qa_hold']=issues
manifest['new_jobs_count']=len(JOBS);manifest['new_generation_cost']=sum(float(j.get('usage',{}).get('generations',0)) for j in JOBS.values() if j.get('usage',{}).get('type')=='generations')
manifest['missing']=[{'stage':s['index'],'action':a} for s in manifest['stages'] for a in ('idle','attack','hurt','ko','guard','skill') if a not in s['motions']]
(G/'TB11_FROG_FAMILY_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
(REPORT/'R11_ALL_FRAME_TECH_QA.json').write_text(json.dumps({'rows':rows,'issues':issues},ensure_ascii=False,indent=2))
# Stage x action illustrated contact (preview only)
img=Image.new('RGBA',(1410,1100),(19,34,49,255));D=ImageDraw.Draw(img)
try:font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',20)
except:font=ImageFont.load_default()
D.text((34,20),'FOREST SYMPHONY | PMD LAVA FROG EVOLUTION - TRUE PIXELLAB 3-STAGE MOTIONS',font=font,fill='white')
D.text((34,58),'ART GALLERY ONLY  |  Stage1 V6 Bite unchanged  |  Original PMD0002/3 each used as generation source',font=font,fill=(166,197,200))
for st in range(1,4):D.text((155+(st-1)*430,108),'STAGE %d'%st,font=font,fill=(224,236,217))
for j,action in enumerate(('idle','attack','hurt','ko')):
 y=148+j*230;D.text((22,y+90),action.upper(),font=font,fill=(255,206,129))
 for i,s in enumerate(manifest['stages']):
  x=114+i*430
  meta=s['motions'].get(action)
  if not meta:
   D.text((x+75,y+94),'NOT GENERATED',font=font,fill=(246,130,127));continue
  sheet=Image.open(G/meta['path']).convert('RGBA');size=meta['cell'][0];cols=meta['columns'];index={'idle':1,'attack':5,'hurt':2,'ko':4}[action];index=min(index,meta['frames']-1)
  f=sheet.crop(((index%cols)*size,(index//cols)*size,((index%cols)+1)*size,((index//cols)+1)*size))
  scal=min(3,195/size);f=f.resize((int(size*scal),int(size*scal)),Image.Resampling.NEAREST)
  img.alpha_composite(f,(x+(335-f.width)//2,y+9+(195-f.height)//2))
  D.text((x+50,y+199),f"{meta['frames']} frames | {meta['technical_qa']}",font=font,fill=(144,224,165) if meta['technical_qa']!='HOLD' else (251,132,110))
img.convert('RGB').save(REPORT/'TB11_LAVA_FROG_3STAGE_4ACTIONS_CONTACT.png')
# GIFs with actual source frames, no interpolated new sprites
for act in ('idle','attack','hurt','ko'):
 for s in manifest['stages']:
  meta=s['motions'].get(act)
  if not meta:continue
  src=Image.open(G/meta['path']).convert('RGBA');size=meta['cell'][0];cols=meta['columns'];frames=[]
  for k in range(meta['frames']):
   fr=src.crop(((k%cols)*size,(k//cols)*size,((k%cols)+1)*size,((k//cols)+1)*size))
   bg=Image.new('RGBA',(size,size),(22,35,49,255));bg.alpha_composite(fr)
   frames.append(bg.convert('RGB').resize((size*3,size*3),Image.Resampling.NEAREST))
  out=REPORT/f'PMD000{s["index"]}_{act.upper()}_TRUE_{meta["frames"]}F.gif'
  frames[0].save(out,save_all=True,append_images=frames[1:],duration=round(1000/meta['fps']),loop=0,disposal=2,optimize=False)
print('R11_MANIFEST',manifest['motion_count'],'FRAMES',manifest['total_frames'],'ISSUES',issues,'COST',manifest['new_generation_cost'])
