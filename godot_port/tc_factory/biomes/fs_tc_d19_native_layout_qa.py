#!/usr/bin/env python3
"""Forest Symphony T-C D19: locked D18 source -> whole-object safe-edge layout.

Preserves the D17 Ground byte-for-byte; preserves six complete independent
D18 PAR islands at 1:1. The bridge remains anchored to its D18 location.
No Polygon crops, resampling, Master reversal, Godot/ART PASS claims.

This scene-specific M3 repair is opt-in; the D18 positions remain the default
in fs_tc_d18_complete_par_components.py.
"""
from __future__ import annotations
import argparse
import json
import hashlib
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from fs_tc_d18_complete_par_components import render, POSITIONS, CANVAS

D19_POSITIONS: dict[str, tuple[int,int]] = {
 "A_FORGE_MARKET": (4,4),
 "B_WHOLE_BRIDGE": (554,334),
 "C_SOUTH_WORKSHOP": (4,566),
 "D_SOUTH_FOUNDRY": (644,570),
 "E_FULL_LAMP": (542,743),
 "F_FULL_BANNER": (544,410),
}
GROUND_LOCK = "2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e"
PAR_SOURCE_LOCK = "a0c0f71b9db96d18ec4c8cbddee5f16366609206ec09bc474bbbe714a4dc7780"
EXPECTED_VISIBLE_SOURCE_PIXELS = 641682


def sha(path: Path)->str:
 return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def build(ground: Path, source: Path, destination: Path, *, original_par: Path | None=None)->dict:
 ground,source,destination=Path(ground),Path(source),Path(destination)
 if D19_POSITIONS["B_WHOLE_BRIDGE"] != POSITIONS["B_WHOLE_BRIDGE"]:
  raise ValueError("Bridge world anchor cannot be moved by safe-edge layout")
 if len(D19_POSITIONS)!=6 or set(D19_POSITIONS)!=set(POSITIONS):
  raise ValueError("Six complete source families required")
 if sha(ground)!=GROUND_LOCK or sha(source)!=PAR_SOURCE_LOCK:
  raise ValueError("D17 Ground or independently generated D18 PAR source SHA mismatch")
 data=render(ground,source,destination,GROUND_LOCK,PAR_SOURCE_LOCK,placements=D19_POSITIONS,phase="D19_WHOLE_ISLANDS_SAFE_EDGE_RELAYOUT")
 if data["source_significant_pixels_preserved"]!=EXPECTED_VISIBLE_SOURCE_PIXELS:
  raise ValueError("A complete source component is missing")
 if data["polygon_trim_pixels"]!=0:
  raise ValueError("Polygon trimming or cutting was detected")
 if data["source_object_overlap_pixels_before_composite"]>1800:
  raise ValueError("Foreground objects intersect too much after relayout")
 if any(data["edge_contact_qa"].values()):
  raise ValueError("High-alpha foreground touches the outer four pixels")
 if data["locked_ground_sha256"]!=GROUND_LOCK or sha(ground)!=GROUND_LOCK:
  raise ValueError("Locked Ground changed")
 if sha(source)!=PAR_SOURCE_LOCK:
  raise ValueError("Independent original PAR was altered")
 if original_par is not None:
  if sha(Path(original_par))!="8534997f5d897a8ed586e01ac8d356682dd9e3bab8f84a6a5b00a0467112c52e":
   raise ValueError("D18 PAR comparison SHA invalid")
  base=np.asarray(Image.open(original_par).convert('RGBA'))[:,:,3]
  b={"top_4px":int(np.count_nonzero(base[:4,:]>224)),
     "bottom_4px":int(np.count_nonzero(base[-4:,:]>224)),
     "left_4px":int(np.count_nonzero(base[:,:4]>224)),
     "right_4px":int(np.count_nonzero(base[:,-4:]>224))}
 else:
  b=None # old D18 alpha border requires verified original source, not an invented measurement
 # Add QA-only 32 px grid & full source object bboxes; never write these to PAR.
 comp=Image.open(destination/"GROUND_PLUS_PAR_STATIC_QA_1280x928.png").convert('RGB')
 overlay=comp.copy();d=ImageDraw.Draw(overlay,'RGBA')
 for x in range(32,CANVAS[0],32):d.line([(x,0),(x,CANVAS[1]-1)], fill=(255,255,255,36), width=1)
 for y in range(32,CANVAS[1],32):d.line([(0,y),(CANVAS[0]-1,y)], fill=(255,255,255,36), width=1)
 colors=[(30,220,200,235),(243,228,82,235),(80,183,245,235),(238,101,237,235),(120,255,110,235),(255,128,55,235)]
 for entry,color in zip(data['source_family_ledger'],colors):
  x0,y0,x1,y1=entry['world_bbox']
  d.rectangle((x0,y0,x1-1,y1-1),outline=color,width=2)
  d.rectangle((max(0,x0),max(0,y0),min(CANVAS[0]-1,x0+165),max(0,y0)+19),fill=(0,0,0,175))
  d.text((x0+4,y0+3),entry['family'],fill=color)
 overlay.save(destination/'D19_GRID_FAMILY_QA_ONLY.png')
 result={
  'scene_id':'FS_04_MAZE','phase':'D19_SAFE_EDGE_WHOLE_SCENE_M3_REPAIR',
  'ground_sha256':GROUND_LOCK,'original_independent_par_sha256':PAR_SOURCE_LOCK,
  'par_output_sha256':data['PAR_sha256'],
  'static_composite_sha256':data['composite_sha256'],
  'source_all_six_significant_alpha_pixels_preserved':data['source_significant_pixels_preserved'],
  'polygon_trim_pixels':data['polygon_trim_pixels'],
  'old_D18_overlap_pixels':868,
  'new_D19_overlap_pixels':data['source_object_overlap_pixels_before_composite'],
  'old_D18_4px_highalpha_border':b,
  'new_D19_4px_highalpha_border':data['edge_contact_qa'],
  'world_coordinate_lock_bridge':D19_POSITIONS['B_WHOLE_BRIDGE'],
  'positions':{k:list(v) for k,v in D19_POSITIONS.items()},
  'native_1x_size':list(CANVAS),'resample_pixels':0,
  'static_qa':'PASS',
  'full_semantic_world_ground_footpoint_alignment':'REQUIRES_HUMAN_1X_VISUAL_QA',
  'Godot_4_7_2_actual_private_art_native':'NOT_RUN',
  'human_ART_gate':'HOLD','integration':'NOT_RUN',
  'formal_ART_PASS':'0/12',
  'warning':'A technical safe-edge layout is not a Godot engine screenshot or user-approved art.'
 }
 (destination/'D19_SAFETY_QA.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
 return result

if __name__=='__main__':
 p=argparse.ArgumentParser()
 p.add_argument('--ground',type=Path,required=True)
 p.add_argument('--par-source',type=Path,required=True)
 p.add_argument('--out',type=Path,required=True)
 p.add_argument('--original-par',type=Path)
 a=p.parse_args()
 print(json.dumps(build(a.ground,a.par_source,a.out,original_par=a.original_par),ensure_ascii=False))
