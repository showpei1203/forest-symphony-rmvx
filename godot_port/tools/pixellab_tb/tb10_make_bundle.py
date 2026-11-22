#!/usr/bin/env python3
"""Private T-B R10 monster family media bundle, deterministic atlas QA and gallery.
Never classifies technical frame inspection as owner art acceptance.
"""
from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
from collections import Counter
import hashlib,json,zipfile,math,sys,random
root=Path(__file__).resolve().parent;game=root/'godot';assets=game/'assets/monsters/tb02';reports=root/'reports'
reports.mkdir(exist_ok=True,parents=True)
expected=[('idle',8,8,True),('attack',11,10,False),('hurt',6,9,False),('ko',8,7,False),('guard',7,8,False),('skill',8,8,False),('fly',8,8,True)]
manifest={'schema':'fs-tb10-family-art-v1','family_id':'TB02_LEAF_BAT','engine':'Godot 4.7.2','original_view':'south-east 3/4','owner_approved':['BAT_STAGE1_ATTACK_11F_128px.png'],'stages':[],'art_gate':'TECH_QA_IS_NOT_OWNER_ART_APPROVAL','battle_system_changes':False}
issues=[];overall=[]
for stage in range(1,4):
 src=assets/f'BAT_STAGE{stage}.png';assert src.exists()
 si=Image.open(src).convert('RGBA'); assert si.size==((96,96) if stage==1 else ((128,128) if stage==2 else (160,160)))
 entry={'index':stage,'name':['Leaf Bat Young','Forest Guardian','Ancient Crown'][stage-1], 'source_path':f'assets/monsters/tb02/{src.name}', 'source_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'source_size':list(si.size),'motions':{}}
 for action,frame_count,fps,loop in expected:
  candidates=sorted(assets.glob(f'BAT_STAGE{stage}_{action.upper()}_{frame_count}F_*px.png'))
  # Only highest-resolution user-controlled successful edit. Other versions retained in archive as HOLD only.
  if not candidates:continue
  candidate=max(candidates,key=lambda p:int(p.stem.rsplit('_',1)[-1].removesuffix('px')))
  im=Image.open(candidate).convert('RGBA');dim=int(candidate.stem.rsplit('_',1)[-1].removesuffix('px'))
  frames=[];border=[];pixels=[];hashes=[];bbox=[]
  expected_size=(dim*4,dim*math.ceil(frame_count/4))
  if im.size!=expected_size:issues.append({'stage':stage,'action':action,'problem':f'bad sheet dimensions {im.size} expected {expected_size}','blocking':True});continue
  for n in range(frame_count):
   frame=im.crop(((n%4)*dim,(n//4)*dim,((n%4)+1)*dim,((n//4)+1)*dim));frames.append(frame)
   alpha=frame.getchannel('A');b=alpha.getbbox();bbox.append(b)
   border.append(sum(alpha.getpixel((k,y))!=0 for k in range(dim) for y in (0,dim-1))+sum(alpha.getpixel((x,k))!=0 for k in range(1,dim-1) for x in (0,dim-1)))
   hashes.append(hashlib.sha256(frame.tobytes()).hexdigest())
   pixels.append(sum(1 for v in alpha.getdata() if v>0))
  tech='PASS' if all(x==0 for x in border) and len(set(hashes))>=3 and all(p>300 for p in pixels) else 'HOLD'
  if tech!='PASS':issues.append({'stage':stage,'action':action,'problem':'edge contact / repeated frames / empty body','border':border,'unique':len(set(hashes)),'blocking':True})
  entry['motions'][action]={'path':f'assets/monsters/tb02/{candidate.name}','frames':frame_count,'columns':4,'cell':[dim,dim],'fps':fps,'loop':loop,'sha256':hashlib.sha256(candidate.read_bytes()).hexdigest(),'source_locked':True,'nonempty_alpha_pixels':pixels,'border_counts':border,'unique_frames':len(set(hashes)),'tech_qa':tech,'art_status':('OWNER_ACCEPTED' if stage==1 and action=='attack' else 'CANDIDATE_REVIEW_PENDING')}
  overall.append({'stage':stage,'action':action,'frames':frame_count,'tech':tech,'file':candidate.name,'sha256':entry['motions'][action]['sha256'],'dimensions':list(im.size),'border_counts':border,'unique':len(set(hashes))})
 manifest['stages'].append(entry)
manifest['motions_technically_passed']=sum(x['tech']=='PASS' for x in overall)
manifest['motions_present']=len(overall)
manifest['missing_actions']=[{'stage':stage['index'],'action':x[0]} for stage in manifest['stages'] for x in expected if x[0] not in stage['motions']]
manifest['blocking_issues']=issues
(game/'TB10_ANIMATION_FAMILY_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
(reports/'R10_PER_FRAME_TECH_QA.json').write_text(json.dumps({'family':'TB02_LEAF_BAT','generated':overall,'issues':issues,'missing':manifest['missing_actions']},ensure_ascii=False,indent=2))
# Create visual contact of 3 stages × all actions. Text only in PREVIEW, not actual sheets.
W=1350;CELLW=430;CELLH=220;H=150+CELLH*4
canvas=Image.new('RGB',(W,H),(24,35,51));d=ImageDraw.Draw(canvas)
try:font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',17)
except:font=ImageFont.load_default()
d.text((32,20),'FOREST SYMPHONY | TB02 LEAF BAT - 3 EVOLUTION STAGES',font=font,fill=(229,240,234))
d.text((32,54),'ORIGINAL PIXELLAB SAMPLES: IDLE / ATTACK / HURT / KO  (NOT GAME UI)',font=font,fill=(162,195,186))
for i,stage in enumerate(manifest['stages']):d.text((40+i*CELLW,95),f'STAGE {i+1} {stage["name"]}',font=font,fill=(192,223,199))
for j,action in enumerate(['idle','attack','hurt','ko']):
 y=140+j*CELLH
 d.text((12,y+8),action.upper(),font=font,fill=(255,206,113))
 for i,stage in enumerate(manifest['stages']):
  x=i*CELLW+65
  if action in stage['motions']:
   meta=stage['motions'][action];size=meta['cell'][0];src=Image.open(game/meta['path']).convert('RGBA')
   index=5 if action=='attack' else (2 if action=='hurt' else (5 if action=='ko' else 1))
   k=min(index,meta['frames']-1)
   fr=src.crop(((k%4)*size,(k//4)*size,((k%4)+1)*size,((k//4)+1)*size))
   scale=min(2,180/size)
   newsize=(int(size*scale),int(size*scale));fr=fr.resize(newsize,Image.Resampling.NEAREST)
   canvas.paste(fr,(x+(CELLW-70-newsize[0])//2,y+15),fr)
   d.text((x+30,y+185),f'{meta["frames"]}F | {meta["cell"][0]}px | {meta["tech_qa"]}',font=font,fill=(153,222,167) if meta['tech_qa']=='PASS' else (255,144,99))
  else:d.text((x+70,y+95),'NOT GENERATED',font=font,fill=(243,156,138))
canvas.save(reports/'TB10_THREE_STAGE_ACTION_GRID.png')
# Animated sample GIF for each stage and action (nearest neighbour upscale, no source modification).
preview=reports/'gifs';preview.mkdir(exist_ok=True)
for stage in manifest['stages']:
 for action,meta in stage['motions'].items():
  im=Image.open(game/meta['path']).convert('RGBA');dim=meta['cell'][0];n=meta['frames']
  frames=[]
  for k in range(n):
   f=im.crop(((k%4)*dim,(k//4)*dim,((k%4)+1)*dim,((k//4)+1)*dim))
   back=Image.new('RGBA',(dim,dim),(26,38,52,255));back.alpha_composite(f)
   frames.append(back.convert('RGB').resize((dim*2,dim*2),Image.Resampling.NEAREST))
  duration=int(1000/meta['fps']);out=preview/f'STAGE{stage["index"]}_{action.upper()}_{n}F.gif'
  frames[0].save(out,save_all=True,append_images=frames[1:],duration=duration,loop=0,disposal=2,optimize=False)
print('manifest',manifest['motions_present'],manifest['motions_technically_passed'],'issues',issues,'missing',len(manifest['missing_actions']))
