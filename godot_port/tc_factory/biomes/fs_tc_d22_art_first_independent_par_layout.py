#!/usr/bin/env python3
"""T-C D22 full-scene 1x independent all-non-ground PAR candidate from a fresh
independent RGBA plate. Never reverse cut Ground, never crop actual object.
Every partial or rejected candidate stays ART HOLD. Does not modify original source.
"""
from pathlib import Path
import argparse
from PIL import Image,ImageDraw,ImageFont
from scipy.ndimage import label,find_objects,binary_erosion
import numpy as np,hashlib,json
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source',type=Path,required=True,help='Independent owner-private all-non-ground RGBA source PNG')
parser.add_argument('--ground',type=Path,required=True,help='Previously locked D17 ground RGB PNG')
parser.add_argument('--out',type=Path,required=True,help='PRIVATE output directory; never public GitHub')
args=parser.parse_args()
BASE=args.out
BASE.mkdir(parents=True,exist_ok=True)
SRC=args.source
GROUND=args.ground
SIZE=(1280,928)
LOCK='2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
SOURCE_LOCK='7ab52f35107f468439436ff23e43ae879df6a90d9d55039e0fb761273fe32828'

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(GROUND)==LOCK,'Ground source changed'
assert sha(SRC)==SOURCE_LOCK,'Independent PAR source changed'
original=Image.open(SRC).convert('RGBA'); src=np.array(original)
assert original.mode=='RGBA'
labels,n=label(src[:,:,3]>64,structure=np.ones((3,3),dtype=np.uint8))
objs=find_objects(labels); counts=np.bincount(labels.ravel()); comps={int(i):(int(counts[i]),objs[i-1]) for i in range(1,n+1) if counts[i]>3000}
assert len(comps)==10,f'expected 10 complete alpha islands, got {len(comps)}'
# Coordinates are deliberately authored against D17 Ground's distinct volcanic platforms.
placements={
 1:('main_forge',(30,23)),
 2:('ore_crane',(560,46)),
 3:('north_rock_column',(1110,195)),
 4:('east_lamp',(1120,311)),
 5:('whole_iron_bridge',(710,397)),
 6:('mid_lamp',(526,472)),
 7:('small_south_workshop',(119,674)),
 8:('southern_banner',(602,690)),
 9:('east_south_lamp',(959,723)),
 10:('south_rock_column',(1114,757))}
# one alternate to check macro layout, not production quality by itself
variants={'A':placements,
 'B':{**placements,1:('main_forge',(44,22)),2:('ore_crane',(529,43)),4:('east_lamp',(1070,286)),5:('whole_iron_bridge',(679,383)),6:('mid_lamp',(555,550)),7:('small_south_workshop',(79,673)),8:('southern_banner',(605,711)),9:('east_south_lamp',(983,717))}}
results={}
for variant,plan in variants.items():
 for cleaner in ['raw','matte']:
  par=Image.new('RGBA',SIZE,(0,0,0,0)); count_union=0; occupied=np.zeros((SIZE[1],SIZE[0]),dtype=bool);overlap=0; sources=[];removed_neon=0
  for label_id,(size,box) in comps.items():
   ys,xs=box; pad=5; x0=max(0,xs.start-pad);y0=max(0,ys.start-pad);x1=min(original.width,xs.stop+pad);y1=min(original.height,ys.stop+pad)
   crop=src[y0:y1,x0:x1,:].copy();
   # Detect complete object in its rectangular source crop: every other alpha island is far away.
   full_alpha=crop[:,:,3].copy()
   # Remove objectively low-alpha distant stipples without modifying RGB art.
   low=full_alpha<=8;crop[low,3]=0
   crop[full_alpha>=240,3]=255
   if cleaner=='matte':
    # Neon magenta-red halo on the OUTER perimeter is an image-model matte artifact.
    # Restrict edit to 6px exterior of object source. Interior red banners/fire preserved.
    nonempty=full_alpha>64
    near_edge=nonempty & ~binary_erosion(nonempty,iterations=7,border_value=0)
    r,g,b=[crop[:,:,i].astype(np.int16) for i in range(3)]
    neon=(r>=220)&(g<=85)&(b<=112)&(r>=g*2.5)&(r>=b*1.85)
    remove=neon & near_edge
    removed_neon+=int(remove.sum());crop[remove,3]=0
   nx,ny=plan[label_id][1]; h,w=crop.shape[:2]
   assert nx>=0 and ny>=0 and nx+w<=SIZE[0] and ny+h<=SIZE[1],f'{label_id} boundary exceeds canvas'
   active=crop[:,:,3]>8
   prev=occupied[ny:ny+h,nx:nx+w];overlap+=int(np.count_nonzero(prev&active));occupied[ny:ny+h,nx:nx+w]|=active
   par.alpha_composite(Image.fromarray(crop,'RGBA'),(nx,ny))
   sources.append({'id':label_id,'name':plan[label_id][0], 'source_bbox':(x0,y0,x1,y1), 'target_xy':(nx,ny),'source_alpha_gt64':int(size),'pixel_scale':'1x'})
  G=Image.open(GROUND).convert('RGBA');C=Image.alpha_composite(G,par)
  prefix=f'D22_{variant}_{cleaner}';outpar=BASE/f'{prefix}_COMPLETE_PAR_1280x928.png';outcom=BASE/f'{prefix}_GROUND_PAR_COMPOSITE.png';par.save(outpar);C.save(outcom)
  alpha=np.array(par.getchannel('A'))
  details={'variant':variant,'alpha_method':cleaner,'Ground_SHA':sha(GROUND),'Source_SHA':sha(SRC),'Source_size':original.size,'Source_alpha0':int((src[:,:,3]==0).sum()),'PAR_SHA':sha(outpar),'Composite_SHA':sha(outcom),'Source_component_count':len(comps),'components':sources,'PAR_size':par.size,'PAR_alpha0':int((alpha==0).sum()),'PAR_alpha_gt8':int((alpha>8).sum()),'source_alpha_gt64_component_pixels':int(sum(z[0] for z in comps.values())),'components_occupied_overlap_pixels':overlap,'rejected_neon_edge_pixels':removed_neon,'border_visible_high_alpha':int(np.sum(alpha[:5,:]>224)+np.sum(alpha[-5:,:]>224)+np.sum(alpha[5:-5,:5]>224)+np.sum(alpha[5:-5,-5:]>224)),'full_native_godot':'NOT_RUN','user_ART':'HOLD','formal_ART_PASS':'0/12','source_class':'INDEPENDENT_NON_GROUND_RGBA_NOT_MASTER','world_alignment':'AUTHOR_CANDIDATE_NOT_VERIFIED'}
  results[prefix]=details
  print(prefix,'overlap',overlap,'alpha0',details['PAR_alpha0'],'edges',details['border_visible_high_alpha'],'red_pixels_removed',removed_neon)
# A/B overview with labeled metadata outside the images, never baked into art.
thumbs=[]
for key in ['D22_A_raw','D22_A_matte','D22_B_raw','D22_B_matte']:
 c=Image.open(BASE/f'{key}_GROUND_PAR_COMPOSITE.png').convert('RGB');c.thumbnail((640,464));thumbs.append((key,c))
board=Image.new('RGB',(1280,1020),(20,22,30));d=ImageDraw.Draw(board)
for idx,(k,c) in enumerate(thumbs):
 x=(idx%2)*640; y=(idx//2)*510
 board.paste(c,(x,y+32));d.text((x+12,y+9),f'{k} / art HOLD',fill=(255,255,255))
board.save(BASE/'D22_SOURCE_MATTE_LAYOUT_4WAY_QA.jpg',quality=92)
(BASE/'D22_ART_FIRST_SOURCE_PROVENANCE_QA.json').write_text(json.dumps(results,indent=2,ensure_ascii=False),encoding='utf8')
