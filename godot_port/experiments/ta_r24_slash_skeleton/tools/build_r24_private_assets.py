#!/usr/bin/env python3
"""Rehydrate ORIGINAL A62 64x64 body + ORIGINAL A52 sword from owner-private A52 source ZIP.

Rig/QA source lives alongside script in the repo. This does not draw a new body,
claim complete original LPC underpaint, generate art, or contact a paid API.
"""
from __future__ import annotations
import argparse, hashlib, io, json, zipfile
from pathlib import Path
from PIL import Image

F0_SHA='70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
A52_BODY_SHA='a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f'
SWORD_ATLAS_SHA='6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b'
SPRITE_SOURCE='godot_a52_lower_body_lunge/assets/actor01_a52_weapon_12frames.png'
BODY_SOURCE='A52_REAL_MODEL_BODY_12FRAME_256x192.png'
F0_SOURCE='source_provenance/A62_APPROVED_ACTOR01_F0_64.png'
CUT=(38,24,45,45)

def digest(b:bytes):return hashlib.sha256(b).hexdigest()
def content(z:zipfile.ZipFile,name:str,sha:str):
 b=z.read(name)
 if digest(b)!=sha:raise ValueError('R24 SOURCE SHA MISMATCH '+name)
 return b

def rebuild(a52_zip:Path,assets:Path,source_manifest:Path):
 assets.mkdir(exist_ok=True,parents=True)
 with zipfile.ZipFile(a52_zip) as z:
  if z.testzip():raise ValueError('A52 ZIP CRC FAIL')
  f0=content(z,F0_SOURCE,F0_SHA)
  body=content(z,BODY_SOURCE,A52_BODY_SHA)
  source=content(z,SPRITE_SOURCE,SWORD_ATLAS_SHA)
 original=Image.open(io.BytesIO(f0)).convert('RGBA')
 assert original.size==(64,64)
 allbody=Image.open(io.BytesIO(body)).convert('RGBA')
 assert original.tobytes()==allbody.crop((0,0,64,64)).tobytes(), 'A52 original identity mismatch'
 original_weapon=Image.open(io.BytesIO(source)).convert('RGBA')
 assert original_weapon.size==(256,192)
 frame=original_weapon.crop((64,0,128,64))
 sword=frame.crop(CUT)
 assert sword.size==(7,21) and sword.getchannel('A').getbbox()==(0,0,7,21)
 sword_path=assets/'source_a52_sword_F1_grip_pivot_7x21.png'
 f0_path=assets/'actor01_a62_approved_F0_64.png'
 f0_path.write_bytes(f0)
 sword.save(sword_path)
 # Validates all positive pixel provenance, not just file size.
 assert sword.tobytes()==Image.open(sword_path).convert('RGBA').tobytes()
 manifest={'source_A52_zip_sha256':digest(a52_zip.read_bytes()), 'approved_F0_png_sha256':digest(f0),'source_A52_body_sha256':digest(body),'original_weapon_atlas_sha256':digest(source),'blade_from_original_weapon_frame_index':1,'source_atlas_crop_xyxy':list(CUT),'sword_grip_cropped_xy':[3,19], 'cropped_sword_sha256':digest(sword_path.read_bytes()), 'body_source_pixel_mutations':0,'blade_source_pixel_mutations':0,'source_native_original_LPC_hidden_layers_available':False,'production_art_approved':False,'godot_actual_FS_gameplay':'NOT_RUN'}
 source_manifest.parent.mkdir(exist_ok=True,parents=True)
 source_manifest.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 return manifest

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--a52',type=Path,required=True);ap.add_argument('--assets',type=Path,required=True);ap.add_argument('--manifest',type=Path,required=True);a=ap.parse_args()
 print(json.dumps(rebuild(a.a52,a.assets,a.manifest),indent=2))
if __name__=='__main__':main()
