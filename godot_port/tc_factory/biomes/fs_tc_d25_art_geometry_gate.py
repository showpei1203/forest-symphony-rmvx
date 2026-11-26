#!/usr/bin/env python3
"""FS T-C D25 ART-FIRST source geometry gate and true-ground QA annotation.

This is an ART-preflight REJECTION/blueprint tool, NOT PAR generation.
Never transform, resize, mask, modify or overwrite the art PNGs.
The lava detector is an *annotation heuristic*, not validated collision/nav art.
"""
from __future__ import annotations
import argparse, hashlib, json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import numpy as np
from scipy.ndimage import label,find_objects

GROUND_LOCK='2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
SOURCE_D24_LOCK='69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407'
GRID_PX=32
BRIDGE_W_MIN=160
BRIDGE_W_MAX=192
FORGE_W_MAX=288
FORGE_H_MAX=360
TARGET={
  'bridge': {'bbox_xyxy':[944,420,1136,626], 'max_width':192,'min_width':160,'expected_footpoints_xy':[[970,603],[1110,603]], 'desired_style':'one continuous source-authored arched bridge, intact piers, no resizing'},
  'forge': {'bbox_xyxy':[64,96,352,456], 'max_width':288,'max_height':360,'desired_style':'compact intact forge 32px game-world scale'},
  'crane':{'bbox_xyxy':[605,65,842,382], 'max_width':237,'desired_style':'one family at consistent 3/4 top-down perspective'},
  'shed':{'bbox_xyxy':[95,648,332,860], 'max_width':237},
  'road_keep_clear':[[390,460,880,650]],
  'native_canvas':[1280,928]
}

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def components(img, threshold=32):
  alpha=np.array(img.getchannel('A'))
  labels,n=label(alpha>threshold,structure=np.ones((3,3),dtype=np.uint8))
  count=np.bincount(labels.ravel());rects=find_objects(labels)
  out=[]
  for i,sl in enumerate(rects,1):
    if sl is None or count[i]<1000:continue
    ys,xs=sl
    out.append({'source_bbox':[int(xs.start),int(ys.start),int(xs.stop),int(ys.stop)],
      'source_width_px':int(xs.stop-xs.start),'source_height_px':int(ys.stop-ys.start),'alpha_gt32_pixels':int(count[i])})
  return sorted(out,key=lambda q:q['source_bbox'][1])

def font(size):
  for path in ['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf','/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf']:
    if Path(path).exists():return ImageFont.truetype(path,size)
  return ImageFont.load_default()

def annotation(ground,source_composite,out):
  # QA ONLY: all outlines and texts exist on a SEPARATE annotated preview, never art.
  preview=ground.convert('RGB').copy()
  p=ImageDraw.Draw(preview,'RGBA')
  def box(bbox,fill,outline,width=4):
    p.rectangle(tuple(bbox),fill=fill,outline=outline,width=width)
  box(TARGET['bridge']['bbox_xyxy'],(70,185,255,35),(66,219,255,255),5)
  box(TARGET['forge']['bbox_xyxy'],(113,220,92,20),(122,255,129,245),4)
  box(TARGET['crane']['bbox_xyxy'],(245,198,55,18),(255,224,108,255),3)
  box(TARGET['shed']['bbox_xyxy'],(174,118,244,18),(214,157,255,255),3)
  box(TARGET['road_keep_clear'][0],(0,0,0,0),(255,249,90,245),3)
  for x,y in TARGET['bridge']['expected_footpoints_xy']:
    p.ellipse((x-9,y-9,x+9,y+9),fill=(7,237,83,200),outline=(255,255,255,245),width=2)
  p.line((970,603,1110,603),fill=(66,219,255,255),width=3)
  # Overlay chart at the top of the actual Ground, no claims of native art
  p.rectangle((340,0,1040,78),fill=(20,24,28,225))
  p.text((354,12),'D25 QA BLUEPRINT - NOT PRODUCTION ART',font=font(21),fill=(252,252,252,255))
  p.text((354,45),'Bridge 160-192px  |  Forge <=288px  |  Grid 32px',font=font(17),fill=(221,233,233,255))
  p.text((955,389),'BRIDGE',font=font(17),fill=(66,219,255,255))
  p.text((110,85),'FORGE',font=font(17),fill=(150,255,155,255))
  p.text((646,66),'CRANE',font=font(17),fill=(255,220,108,255))
  p.text((400,620),'CLEAR ROAD (QA)',font=font(17),fill=(255,249,90,255))
  p.text((980,640),'Landings are provisional art guides',font=font(13),fill=(255,255,255,255))
  out.mkdir(parents=True,exist_ok=True)
  preview.save(out/'D25_LOCKED_GROUND_SHORT_BRIDGE_FOOTPRINT_QA_ONLY.png')
  # Full-scene two-panel: comparison is QA only and does not alter private artwork
  w,h=ground.size
  panel=Image.new('RGB',(2*w,980),(25,28,32))
  canvas=ImageDraw.Draw(panel)
  panel.paste(source_composite.convert('RGB'),(0,44));panel.paste(preview,(w,44))
  canvas.text((15,9),'D24 PREVIOUS ART HOLD: 388px BRIDGE / 495px FORGE',font=font(20),fill=(255,210,138))
  canvas.text((w+15,9),'D25 REVISED SOURCE CONSTRAINTS: 160-192px BRIDGE / <=288px FORGE',font=font(20),fill=(164,240,211))
  panel.save(out/'D25_D24_VS_LOCKED_GROUND_ART_GEOMETRY_AB_QA_ONLY.png')

def art_geometry_failures(forge,bridge):
  """Reject bad world-scale authoring *before* any expensive native import."""
  reasons=[]
  if bridge['source_width_px']>BRIDGE_W_MAX: reasons.append('BRIDGE_WIDTH_EXCEEDS_6_TILES')
  if bridge['source_width_px']<BRIDGE_W_MIN: reasons.append('BRIDGE_TOO_SHORT_FOR_TARGET_SPAN')
  if forge['source_width_px']>FORGE_W_MAX: reasons.append('FORGE_MORE_THAN_9_TILES_WIDE')
  if forge['source_height_px']>FORGE_H_MAX: reasons.append('FORGE_HEIGHT_TOO_LARGE')
  return reasons


def validate(ground_file,source_file,previous_composite_file,out):
  out.mkdir(parents=True,exist_ok=True)
  if sha(ground_file)!=GROUND_LOCK: raise ValueError('Locked D17 Ground SHA is not the authority source')
  if sha(source_file)!=SOURCE_D24_LOCK: raise ValueError('D24 original independent source changed; fail closed')
  g=Image.open(ground_file);source=Image.open(source_file);comp=Image.open(previous_composite_file)
  if g.size!=(1280,928) or g.mode!='RGB': raise ValueError('Ground invalid mode/size')
  if source.size!=(1474,1067) or source.mode!='RGBA': raise ValueError('Expected original independently-authored native-alpha source')
  if comp.size!=(1280,928):raise ValueError('D24 comparison output invalid size')
  islands=components(source)
  assert len(islands)==11, 'D24 expected eleven intact source object groups'
  forge,bridge=islands[0],islands[2]
  if not (forge['source_width_px']==495 and bridge['source_width_px']==388):
    raise ValueError('Actual D24 source geometry no longer matches Handoff')
  # Art semantics: before placement and native engine, reject oversized authoring.
  reasons=art_geometry_failures(forge,bridge)
  rgb=np.asarray(g,dtype=np.int16)
  points=[]
  for x,y in TARGET['bridge']['expected_footpoints_xy']:
    patch=rgb[y-12:y+12,x-12:x+12]
    rr,gg,bb=patch[:,:,0],patch[:,:,1],patch[:,:,2]
    heat=(rr>160)&(gg>55)&(gg<180)&(bb<115)
    points.append({'xy':[x,y],'heuristic_bright_lava_fraction_24px':round(float(heat.mean()),4),'NOTE':'approximate color heuristic only; not confirmed walkable bank'})
  qa={
    'phase':'D25_AUTHORING_PROPORTION_GATE_AFTER_D24_ART_HOLD','scene':'FS_04_MAZE','source_provenance':'LOCKED_D17_GROUND_AND_UNMODIFIED_D24_RGBA',
    'ground_sha256':GROUND_LOCK,'original_D24_RGBA_sha256':SOURCE_D24_LOCK,'ground_size':[1280,928],
    'grid_px':32,'previous_source_groups':len(islands),'D24_forge_source_bbox':forge,'D24_bridge_source_bbox':bridge,
    'current_bridge_tiles':round(bridge['source_width_px']/GRID_PX,4),
    'current_forge_tiles':round(forge['source_width_px']/GRID_PX,4),
    'target_bridge_width_px':[BRIDGE_W_MIN,BRIDGE_W_MAX], 'target_bridge_width_tiles':[5,6],
    'target_forge_width_px_max':FORGE_W_MAX, 'target_forge_width_tiles_max':9,
    'target_geometry':TARGET,'candidate_landings':points,'D24_ART_PREFLIGHT_STATUS':'REJECTED_BY_GEOMETRY_GATE',
    'rejection_reasons':reasons,'D25_new_complete_art_image':'NOT_ACCEPTED_NO_VALID_SHORT_BRIDGE_GENERATION',
    'D25_real_private_Godot472_native':'NOT_RUN','HUMAN_VISUAL_ART':'HOLD', 'FORMAL_ART_PASS':'0/12',
    'full_ground_PNG_unchanged':True,'artwork_modification':False,
    'D25_images_are_annotations_only':True,'IMPORTANT':'Heuristic color is not a physically authored bridge collision mask or ground semantic label',
  }
  annotation(g,comp,out)
  qa['annotation_ground_sha256']=sha(out/'D25_LOCKED_GROUND_SHORT_BRIDGE_FOOTPRINT_QA_ONLY.png')
  qa['A_B_art_QA_sha256']=sha(out/'D25_D24_VS_LOCKED_GROUND_ART_GEOMETRY_AB_QA_ONLY.png')
  (out/'D25_AUTHORING_GEOMETRY_GATE_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
  print(json.dumps({'gate':qa['D24_ART_PREFLIGHT_STATUS'],'reasons':reasons,'source':SOURCE_D24_LOCK[:12],'two_QA_images':True,'bridge_tiles':qa['current_bridge_tiles'],'forge_tiles':qa['current_forge_tiles']}))
  return qa

if __name__=='__main__':
  ap=argparse.ArgumentParser();ap.add_argument('--ground',type=Path,required=True);ap.add_argument('--source',type=Path,required=True);ap.add_argument('--previous-composite',type=Path,required=True);ap.add_argument('--out',type=Path,required=True)
  a=ap.parse_args();validate(a.ground,a.source,a.previous_composite,a.out)
