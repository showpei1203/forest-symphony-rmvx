#!/usr/bin/env python3
"""FS T-A R21 source-first, owner-private staging. Not an ART acceptance.

Recover pixel-exact approved A62 64px from legacy A52 and match original A62
PixelLab provider F0 (48px centered 8px). Reuse existing 12-frame A52 attack
Body completely unchanged, blank its independent Weapon/FX layers for an
unarmed candidate, and compile existing A62 3-source run loop into 12 slots.
No image generation, palette or body geometry reconstruction occurs.
"""
from __future__ import annotations
import argparse,hashlib,io,json,zipfile,shutil
from pathlib import Path
from PIL import Image,ImageDraw

A62_SOURCE_SHA='0ca4ce9f55a718882b801114602c14e3d288ea4371806fe8afcb3d9b64510c37'
A62_APPROVED64_SHA='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
A52_BODY_SHA='a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f'
A62_F0_PROVIDER_SHA='a58685cdecfc73bb5bb798a453735bc6c247b53406ee6190886b9cbe00a7d9ba'
A52_BODY_PATH='A52_REAL_MODEL_BODY_12FRAME_256x192.png'
A62_REF_PATH='source_provenance/A62_APPROVED_ACTOR01_F0_64.png'
RUN_ORDER=[0,1,0,2]*3
ATTACK_TIMES=[0,0.100,0.190,0.275,0.350,0.455,0.560,0.620,0.735,0.830,0.910,0.980]

def sha(b:bytes)->str:return hashlib.sha256(b).hexdigest()
def image_from(b:bytes):return Image.open(io.BytesIO(b)).convert('RGBA')
def pixel_diff(a,b):return sum(x!=y for x,y in zip(a.getdata(),b.getdata()))
def tile(atlas,i):return atlas.crop((64*(i%4),64*(i//4),64*((i%4)+1),64*((i//4)+1)))
def main():
 p=argparse.ArgumentParser();p.add_argument('--a52',type=Path,required=True);p.add_argument('--a62',type=Path,required=True);p.add_argument('--out',type=Path,required=True);args=p.parse_args()
 args.out.mkdir(parents=True,exist_ok=True)
 za=zipfile.ZipFile(args.a52);zr=zipfile.ZipFile(args.a62)
 assert za.testzip() is None and zr.testzip() is None
 refbytes=za.read(A62_REF_PATH);assert sha(refbytes)==A62_APPROVED64_SHA
 approved=image_from(refbytes);assert approved.size==(64,64)
 source48=zr.read('A62_SOURCE_F0_48.png');assert sha(source48)==A62_SOURCE_SHA
 providerbytes=[zr.read('A62_PROVIDER_RAW_F%d.png'%i) for i in range(3)]
 assert sha(providerbytes[0])==A62_F0_PROVIDER_SHA
 raws=[image_from(b) for b in providerbytes];assert all(f.size==(48,48) for f in raws)
 assert approved.crop((8,8,56,56)).tobytes()==raws[0].tobytes()
 # Prove the R20 error is choosing pre-provider source (47 changed RGBA pixels).
 source_img=image_from(source48);wrong_diff=pixel_diff(source_img,raws[0]);assert wrong_diff==47
 a52bytes=za.read(A52_BODY_PATH);assert sha(a52bytes)==A52_BODY_SHA
 attack=image_from(a52bytes);assert attack.size==(256,192)
 assert tile(attack,0).tobytes()==approved.tobytes()==tile(attack,11).tobytes()
 # No generated filler, only real past provider pixels. Actual distinct poses: 3 run, 11 attack.
 padded=[]
 for i,raw in enumerate(raws):
  canvas=Image.new('RGBA',(64,64));canvas.alpha_composite(raw,(8,8));padded.append(canvas)
 assert padded[0].tobytes()==approved.tobytes()
 run=Image.new('RGBA',(256,192));
 for i,source_index in enumerate(RUN_ORDER):run.alpha_composite(padded[source_index],(64*(i%4),64*(i//4)))
 assert len(set(tile(run,i).tobytes() for i in range(12)))==3
 assert len(set(tile(attack,i).tobytes() for i in range(12)))==11
 # All original A52 body pixels, no sword or effects.
 shutil.copyfileobj(io.BytesIO(a52bytes),(args.out/'R21_ATTACK_BODY_12X64_SOURCE_A52.png').open('wb'))
 shutil.copyfileobj(io.BytesIO(refbytes),(args.out/'R21_APPROVED_A62_F0_64.png').open('wb'))
 run.save(args.out/'R21_RUN_BODY_12X64_SOURCE_A62.png')
 for action in ('RUN','ATTACK'):
  for layer in ('WEAPON','FX'):
   Image.new('RGBA',(256,192)).save(args.out/f'R21_{action}_{layer}_ZERO.png')
 # Real original size 1x reviews, 4x is nearest-neighbor pixel view (not AI interpolation).
 panel=Image.new('RGBA',(4*64,6*64),(22,24,29,255))
 for row,atlas in enumerate((run,attack)):
  for i in range(12): panel.alpha_composite(tile(atlas,i),(64*(i%4),64*(i//4+3*row)))
 panel.convert('RGB').save(args.out/'R21_RUN_ATTACK_1X_CONTACT.png')
 panel.resize((1024,1536),Image.Resampling.NEAREST).convert('RGB').save(args.out/'R21_RUN_ATTACK_4X_CONTACT.png')
 for label,atlas,ticks in [('RUN',run,[0,1,0,2]*3),('ATTACK',attack,list(range(12)))]:
  frames=[]
  for i in range(12):
   img=Image.new('RGBA',(256,256),(22,24,29,255));img.alpha_composite(tile(atlas,i).resize((256,256),Image.Resampling.NEAREST));frames.append(img.convert('RGB'))
  frames[0].save(args.out/f'R21_{label}_SOURCE_REPLAY_4X.gif',save_all=True,append_images=frames[1:],loop=0,duration=95 if label=='RUN' else 80,optimize=False)
 # Every original A52 Frame + new RUN frame accessible standalone for native scan.
 for action,atlas in [('RUN',run),('ATTACK',attack)]:
  for i in range(12):tile(atlas,i).save(args.out/f'{action}_F{i:02d}.png')
 manifest={
  'stage':'R21_SOURCE_LOCKED_M1_FULL_RUN_ATTACK_CANDIDATE',
  'authority':'T-A R20 source lock superseded only in A62 approved F0 selection, no claim of new original layered LPC costume',
  'input_a52_zip_sha256':sha(args.a52.read_bytes()),'input_a62_zip_sha256':sha(args.a62.read_bytes()),
  'approved_A62_64_source_sha256':A62_APPROVED64_SHA,'A62_48_provider_F0_sha256':sha(providerbytes[0]),
  'A62_pre_provider_source_48_sha256':A62_SOURCE_SHA,
  'approved64_matches_padded_providerF0_rgba':True,'pre_provider48_vs_approved48_changed_pixels':wrong_diff,
  'A52_original_body_sha256':A52_BODY_SHA,
  'run_body_sha256':sha((args.out/'R21_RUN_BODY_12X64_SOURCE_A62.png').read_bytes()),
  'attack_body_sha256':sha((args.out/'R21_ATTACK_BODY_12X64_SOURCE_A52.png').read_bytes()),
  'image_frame_size':[64,64],'atlas_size':[256,192],
  'run_phase_source_columns':RUN_ORDER,'run_source_poses_distinct':3,'run12_is_repeat_of_3_source_poses':True,
  'attack_frames_distinct':11,'attack_pose_source_original_vendor_A52':True,
  'F0_F11_attack_RGBA_equal':True, 'weapon_pixels':0,'fx_pixels':0,
  'attack_frame_index_contact':7,'attack_event_time_seconds':0.630,'hitstop_seconds':0.070,
  'art_status':'HOLD_A62_RUN_AND_A52_UNARMED_ATTACK_NOT_OWNER_APPROVED',
  'source_status':'ORIGINAL_PIXELS_LOCKED_AND_ALIGNED',
  'paperdoll_status':'WEAPON_FX_SEPARATED_ONLY_LPC_OUTFIT_MODULES_NOT_VERIFIED',
  'new_paid_API_request':'NOT_RUN',
  'full_FS_battle_integration':'NOT_RUN',
  'native_engine':'PENDING_EXECUTION',
  'run_risks':['only three unique real RUN poses, repeated twelve slots', 'F1/F2 model render can change face/clothing within original provider output', 'original 45degree style visually unapproved'],
  'attack_risks':['reused historic sword-holding A52 BODY without sword; authentic unarmed punch gesture not established', 'old A52 native demo is not migrated original FS Battle']
 }
 (args.out/'R21_SOURCE_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 print(json.dumps({'stage':'M1','padded_f0_matches_A52':True,'wrong_48_diff':wrong_diff,'run_distinct':3,'attack_distinct':11,'source':'PASS','art':'HOLD'},ensure_ascii=False))

if __name__=='__main__':main()
