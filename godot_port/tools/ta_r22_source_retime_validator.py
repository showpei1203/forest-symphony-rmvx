"""Verify R22 entire original provider frame provenance, including negative tamper tests."""
from pathlib import Path
from PIL import Image
from io import BytesIO
import argparse, hashlib, json, zipfile
from importlib.machinery import SourceFileLoader

SOURCE_SHA='a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f'
APPROVED_F0='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
SCHEDULE={'R22A_JAB':[0,1,2,1,2,2,3,4,5,6,9,0],'R22B_CROSS':[0,1,2,1,2,3,4,5,6,7,9,0]}

def frame(atlas,i):return atlas.crop((64*(i%4),64*(i//4),64*(i%4+1),64*(i//4+1)))
def inspect_zip(source, outputs):
 with zipfile.ZipFile(source) as z:
  raw=z.read('A52_REAL_MODEL_BODY_12FRAME_256x192.png')
  if hashlib.sha256(raw).hexdigest()!=SOURCE_SHA:raise ValueError('R22 SOURCE HASH MISMATCH')
  ref=z.read('source_provenance/A62_APPROVED_ACTOR01_F0_64.png')
  if hashlib.sha256(ref).hexdigest()!=APPROVED_F0:raise ValueError('R22 WRONG A62 IDENTITY')
  img=Image.open(BytesIO(raw)).convert('RGBA')
  master=Image.open(BytesIO(ref)).convert('RGBA')
  assert frame(img,0).tobytes()==master.tobytes()
 report={}
 for name,order in SCHEDULE.items():
  atlas=Image.open(outputs/f'{name}_ATTACK_BODY_12x64.png').convert('RGBA')
  if atlas.size!=(256,192):raise ValueError(f'{name} invalid 256x192 sheet')
  for i,srcidx in enumerate(order):
   actual=frame(atlas,i)
   expected=frame(img,srcidx)
   if actual.tobytes()!=expected.tobytes():raise ValueError(f'{name} non-original pixel or altered abdomen at F{i}')
  if frame(atlas,0).tobytes()!=frame(atlas,11).tobytes()!=master.tobytes():raise ValueError('wrong F0/F11')
  for layer in ('WEAPON','FX'):
   pic=Image.open(outputs/f'{name}_{layer}_ZERO.png').convert('RGBA')
   if pic.size!=(256,192) or pic.getchannel('A').getbbox() is not None:raise ValueError('unexpected weapon/fx')
  report[name]={'frame_count':12,'source_fullbody_retimed_pixels':12*64*64,'added_art_pixels':0,'original_full_body_source_only':True,'weapon_alpha_pixels':0,'fx_alpha_pixels':0}
 return report

def main():
 p=argparse.ArgumentParser();p.add_argument('--a52',type=Path,required=True);p.add_argument('--output',type=Path,required=True);args=p.parse_args()
 report=inspect_zip(args.a52,args.output)
 # Deliberately inject a real changed torso pixel and exercise the COMPLETE validator.
 target=args.output/'R22A_JAB_ATTACK_BODY_12x64.png'
 original=target.read_bytes()
 im=Image.open(target).convert('RGBA')
 assert im.getpixel((31,32))[3]>0
 r,g,b,alpha=im.getpixel((31,32));im.putpixel((31,32),((r+1)%256,g,b,alpha))
 try:
  im.save(target)
  caught=False
  try:inspect_zip(args.a52,args.output)
  except ValueError as exc:
   caught='non-original pixel' in str(exc)
  assert caught,'tamper negative test was not rejected by full source validator'
  report['negative_mutated_original_body_pixel']='REJECTED_BY_INSPECT_ZIP_AS_EXPECTED'
 finally:
  target.write_bytes(original)
 assert inspect_zip(args.a52,args.output)['R22A_JAB']['frame_count']==12
 report['art_approval']='HOLD';report['full_original_FS_battle_integration']='NOT_RUN'
 (args.output/'R22_SOURCE_EXACT_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps(report,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
