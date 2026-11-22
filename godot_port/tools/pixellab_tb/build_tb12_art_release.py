#!/usr/bin/env python3
"""T-B R12 private monster-art release builder. No battle engine changes.
Inputs: the R10 Leaf Bat and R11 Lava Frog private archives/staging folders,
and provider-generated R12 atlases downloaded from the user's authorized device.
This builder contains NO proprietary art, API credentials or authentication.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json, hashlib, shutil, re, zipfile, math
R=Path('/mnt/data/fs_tb12_factory')
G=R/'godot'; AS=G/'assets/monsters'; REPORT=R/'reports';REPORT.mkdir(parents=True,exist_ok=True)
OLD_B=Path('/mnt/data/fs_tb10_factory/godot');OLD_F=Path('/mnt/data/fs_tb11_frog/godot')
JOBS=json.loads(Path('/mnt/data/TB_R12_PROVIDER_PROVENANCE_BRIDGE_DELETE.txt').read_text(encoding='utf-8-sig'))
ACTIONS=('idle','attack','hurt','ko','guard','skill','locomotion')
PAD={'bat':{1:128,2:160,3:224},'frog':{1:128,2:128,3:128}}
FPS={'guard':8,'skill':10,'fly':9,'hop':10}
COUNT={'guard':7,'skill':8,'fly':8,'hop':10}

def sha(b):return hashlib.sha256(b).hexdigest()

def safe_copy(src,target):
 target.parent.mkdir(parents=True,exist_ok=True)
 if not target.exists():shutil.copyfile(src,target)
 assert sha(src.read_bytes())==sha(target.read_bytes()),(src,target)

def quality(path,n,cell,cols):
 im=Image.open(path).convert('RGBA')
 assert im.size==(cols*cell,math.ceil(n/cols)*cell),(path.name,im.size,n,cell,cols)
 borders=[]; nonempty=[]; unique=[];mean_opaque=[]
 for k in range(n):
  frame=im.crop(((k%cols)*cell,(k//cols)*cell,(k%cols+1)*cell,(k//cols+1)*cell))
  al=frame.getchannel('A');bb=al.getbbox();nonempty.append(bb is not None)
  edge=sum(al.getpixel((x,y))>0 for x in range(cell) for y in (0,cell-1))+sum(al.getpixel((x,y))>0 for y in range(1,cell-1) for x in (0,cell-1))
  borders.append(edge)
  unique.append(sha(frame.tobytes()))
  mean_opaque.append(sum(1 for a in al.getdata() if a>0))
 return {'border':borders,'unique':len(set(unique)),'alpha_nonempty':nonempty,'alpha_pixel_count':mean_opaque,'qa':'PASS' if max(borders)==0 and all(nonempty) and len(set(unique))>=3 else 'HOLD'}

FAMILIES=[]
SUMMARY=[];issues=[]
for fid,key,source_root,folder in [('TB02_LEAF_BAT','bat',OLD_B,'tb02'),('PMD_LAVA_FROG','frog',OLD_F,'pmd')]:
 legacy_path='TB10_ANIMATION_FAMILY_MANIFEST.json' if key=='bat' else 'TB11_FROG_FAMILY_MANIFEST.json'
 leg=json.loads((source_root/legacy_path).read_text())
 family={'family_id':fid,'kind':key,'stages':[]}
 for stage in leg['stages']:
  ix=int(stage['index']);s=dict(stage);s['motions']=dict(stage['motions'])
  old_source=source_root/s['source_path'];out_source=G/s['source_path'];safe_copy(old_source,out_source)
  assert sha(out_source.read_bytes())==s['source_sha256'],('source lock broken',key,ix)
  for name,meta in list(s['motions'].items()):
   safe_copy(source_root/meta['path'],G/meta['path'])
  for action in ('guard','skill', 'fly' if key=='bat' else 'hop'):
   record=JOBS[key][f'{ix}_{action}'];assert record['status']=='completed',record
   assert record['technical_qa' if key=='bat' else 'qa']=='PASS',record
   cell=PAD[key][ix];count=(9 if key=='frog' and action=='skill' else COUNT[action]);cols=4
   basename=(f'BAT_STAGE{ix}_{action.upper()}_{count}F_{cell}px.png' if key=='bat' else f'PMD000{ix}_{action.upper()}_{count}F_{cell}px.png')
   path=f'assets/monsters/{folder}/{basename}'
   atlas=G/path;assert atlas.exists(),atlas
   assert sha(atlas.read_bytes())==record['sheet_sha256'],('provider output differs',basename)
   q=quality(atlas,count,cell,cols)
   if q['qa']!='PASS':issues.append({'family':fid,'stage':ix,'action':action,'why':q})
   s['motions'][action]={
     'path':path,'frames':count,'columns':cols,'cell':[cell,cell],
     'fps':FPS[action],'loop':action in ('fly','hop'),
     'sha256':sha(atlas.read_bytes()),'source_sha256':s['source_sha256'],
     'provider_job_id':record['job_id'],'generation_id':record.get('generation_id'),
     'usage':record.get('usage'),'border_counts':q['border'],
     'frame_unique':q['unique'],'alpha_pixel_count':q['alpha_pixel_count'],
     'technical_qa':q['qa'],'art_status':'OWNER_ART_REVIEW_PENDING'
   }
  assert all(k in s['motions'] for k in ('idle','attack','hurt','ko','guard','skill','fly' if key=='bat' else 'hop')),s['motions']
  family['stages'].append(s)
  for action,meta in s['motions'].items():
   path=G/meta['path'];n=int(meta['frames']);w=int(meta['cell'][0]);cols=int(meta['columns'])
   q=quality(path,n,w,cols)
   original_status=meta.get('art_status','LEGACY_REVIEW_PENDING')
   # Track old approved art separately; a nonzero new edge can block release.
   if q['qa']!='PASS':issues.append({'family':fid,'stage':ix,'action':action,'why':q})
   SUMMARY.append({'family':fid,'stage':ix,'action':action,'frames':n,'cell':w,'qa':q['qa'],'human_art_status':original_status,'sha256':sha(path.read_bytes()),'source_sha256':s['source_sha256']})
 FAMILIES.append(family)

clip_count=len(SUMMARY);frames=sum(x['frames'] for x in SUMMARY)
assert len(FAMILIES)==2 and sum(len(x['stages']) for x in FAMILIES)==6
assert clip_count==42 and frames==340,(clip_count,frames)
assert not issues,issues
assert sum(1 for fam in JOBS.values() for v in fam.values() if v.get('status')=='completed')==18
cost=sum(float(rec.get('usage',{}).get('generations',0)) for fm in JOBS.values() for rec in fm.values() if rec.get('status')=='completed')
assert cost==54,(cost,'provider quota')
manifest={'schema':'FS_TB_R12_TWO_EVOLUTION_FAMILIES_SEVEN_ACTIONS','engine':'Godot 4.7.2','mode':'ART_ONLY_NO_BATTLE_ENGINE_INTEGRATION','families':FAMILIES,'stage_count':6,'clip_count':clip_count,'total_frames':frames,'new_pixel_lab_jobs':18,'new_provider_generations':cost,'unapproved_new_art':18,'technical_qa':'PASS','human_art_gate':'OWNER_REVIEW_PENDING','issues':issues,
          'control_note':'Real source-locked PixelLab atlases. DO NOT overwrite previously approved attack V6 / R8. Only battle-independent gallery.'}
(G/'TB12_MONSTER_FAMILY_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
(REPORT/'R12_ALL_42_CLIP_FRAME_QA.json').write_text(json.dumps({'rows':SUMMARY,'issues':issues},ensure_ascii=False,indent=2))
(REPORT/'R12_PROVIDER_JOB_LEDGER.json').write_text(json.dumps(JOBS,indent=2,ensure_ascii=False))

# 3-stage x 7-action contact sheet per species, original RGBA frames only.
font_file='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
font=ImageFont.truetype(font_file,20)
for family in FAMILIES:
 img=Image.new('RGB',(1400,1480),(16,30,40));d=ImageDraw.Draw(img)
 d.text((20,12),f"FOREST SYMPHONY | R12  {family['family_id']}   3 STAGES x 7 ACTIONS",font=font,fill=(237,245,227))
 d.text((20,46),'REAL PIXELLAB SPRITE FRAMES   |   TECHNICAL PASS   |   HUMAN ART REVIEW PENDING',font=font,fill=(160,192,194))
 for i in range(3):d.text((180+i*404,80),f'STAGE {i+1}',font=font,fill=(245,218,172))
 for row,action in enumerate(ACTIONS):
  y=118+row*187;d.text((18,y+68),action.upper(),font=font,fill=(241,193,128))
  for i,s in enumerate(family['stages']):
   key='fly' if action=='locomotion' and family['kind']=='bat' else ('hop' if action=='locomotion' else action)
   meta=s['motions'][key];cell=int(meta['cell'][0]);cols=int(meta['columns']);n=int(meta['frames']);k=min({'idle':2,'attack':5,'hurt':2,'ko':5,'guard':3,'skill':4,'fly':3,'hop':4}.get(key,2),n-1)
   sheet=Image.open(G/meta['path']).convert('RGBA')
   tile=sheet.crop(((k%cols)*cell,(k//cols)*cell,((k%cols)+1)*cell,((k//cols)+1)*cell))
   scale=min(2.6,158/cell);tile=tile.resize((round(cell*scale),round(cell*scale)),Image.Resampling.NEAREST)
   bg=Image.new('RGBA',tile.size,(32,52,65,255));bg.alpha_composite(tile)
   x=140+i*405+(300-tile.width)//2;img.paste(bg.convert('RGB'),(x,y))
   d.text((190+i*405,y+163),f'{n} authentic frames | {cell}px',font=font,fill=(147,224,165))
 fname='TB12_BAT_3STAGE_7ACTION_CONTACT.png' if family['kind']=='bat' else 'TB12_FROG_3STAGE_7ACTION_CONTACT.png'
 img.save(REPORT/fname)

# GIFs each of the 18 new clips for human animation review. No interpolated sprite frames.
gif_dir=REPORT/'new_action_gifs';gif_dir.mkdir(exist_ok=True)
for family in FAMILIES:
 for s in family['stages']:
  for act in ('guard','skill','fly' if family['kind']=='bat' else 'hop'):
   m=s['motions'][act];c=m['cell'][0];cols=m['columns'];n=m['frames'];frames=[]
   sheet=Image.open(G/m['path']).convert('RGBA')
   for j in range(n):
    f=sheet.crop(((j%cols)*c,(j//cols)*c,((j%cols)+1)*c,(j//cols+1)*c))
    bg=Image.new('RGBA',(c,c),(24,39,52,255));bg.alpha_composite(f)
    frames.append(bg.convert('RGB').resize((c*2,c*2),Image.Resampling.NEAREST))
   gif=gif_dir/f"{family['kind'].upper()}_STAGE{s['index']}_{act.upper()}_{n}F.gif"
   frames[0].save(gif,save_all=True,append_images=frames[1:],duration=round(1000/m['fps']),loop=0,disposal=2,optimize=False)

print('R12_RELEASE_PREP_OK',clip_count,'CLIPS',frames.__class__.__name__,'FRAME_SLOTS',manifest['total_frames'],'NEW_JOBS',18,'GENERATIONS',cost,'ISSUES',len(issues))
