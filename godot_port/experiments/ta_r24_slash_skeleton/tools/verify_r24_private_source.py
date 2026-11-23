#!/usr/bin/env python3
"""R24 byte-level positive/negative provenance tests, deliberately NOT an ART quality check."""
from __future__ import annotations
from pathlib import Path
import argparse,hashlib,json,tempfile
from PIL import Image
from build_r24_private_assets import rebuild,F0_SHA,SWORD_ATLAS_SHA


def verify(original:Path,assets:Path,manifest:Path):
 m=json.loads(manifest.read_text(encoding='utf-8'))
 assert m['approved_F0_png_sha256']==F0_SHA
 assert m['original_weapon_atlas_sha256']==SWORD_ATLAS_SHA
 f0=assets/'actor01_a62_approved_F0_64.png'
 sw=assets/'source_a52_sword_F1_grip_pivot_7x21.png'
 assert hashlib.sha256(f0.read_bytes()).hexdigest()==F0_SHA
 assert hashlib.sha256(sw.read_bytes()).hexdigest()==m['cropped_sword_sha256']
 assert Image.open(f0).size==(64,64) and Image.open(sw).size==(7,21)
 # Check source original exactly reconstructs approved game F0 and source cropped sword.
 with tempfile.TemporaryDirectory() as td:
  t=Path(td)
  check=rebuild(original,t/'assets',t/'manifest.json')
  assert check['cropped_sword_sha256']==m['cropped_sword_sha256']
  assert (t/'assets/source_a52_sword_F1_grip_pivot_7x21.png').read_bytes()==sw.read_bytes()
  # Tampered one ORIGINAL weapon pixel cannot pass source lock.
  im=Image.open(sw).convert('RGBA');r,g,b,a=im.getpixel((4,2))
  assert a>0
  im.putpixel((4,2),((r+1)%256,g,b,a))
  im.save(t/'assets/source_a52_sword_F1_grip_pivot_7x21.png')
  rejected=hashlib.sha256((t/'assets/source_a52_sword_F1_grip_pivot_7x21.png').read_bytes()).hexdigest()!=m['cropped_sword_sha256']
  assert rejected, 'mutated private sword was accepted'
  # Incorrect A62 reference must also fail source lock.
  x=Image.open(f0).convert('RGBA');x.putpixel((32,38),(255,0,255,255))
  x.save(t/'assets/actor01_a62_approved_F0_64.png')
  assert hashlib.sha256((t/'assets/actor01_a62_approved_F0_64.png').read_bytes()).hexdigest()!=F0_SHA
 return {'source_A62_SHA_lock':'PASS','real_A52_sword_source_crop_exact_RGBA':'PASS','negative_mutate_sword_pixel':'REJECTED','negative_mutate_A62_body':'REJECTED','true_original_LPC_hidden_garment_source':'MISSING','art_quality':'HOLD'}

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--a52',type=Path,required=True);ap.add_argument('--assets',type=Path,required=True);ap.add_argument('--manifest',type=Path,required=True);a=ap.parse_args()
 print(json.dumps(verify(a.a52,a.assets,a.manifest),indent=2))
if __name__=='__main__':main()
