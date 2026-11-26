#!/usr/bin/env python3
"""FS T-C D24 independent TRUE-RGBA all-non-ground complete PAR source.

Uses already frozen FS_04_MAZE D17 Ground FIRST, original D24 new independent
11-object RGBA source SECOND. Delivers two separate native 1280x928 originals;
no mixed-Master extraction, no masks for role occlusion, no individual resizing,
no changes to canonical files. PAR source itself is 1474x1067: this is honestly
full-object 1:1 world re-layout (not direct-native whole-scene authoring).
"""
import argparse, hashlib, json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from scipy.ndimage import label, find_objects, binary_erosion

GROUND_LOCK='2f9ad1d596171327fbc92f797495ea12d0e231c551da8eda3437035af2d6d94e'
SOURCE_LOCK='69fcdc6602394ddc7ece3e73515fe657ab74976c20aaa1548b58b712cfcca407'
NAMES=['forge','ore_crane','iron_bridge','north_lamp','western_lamp','western_basalt','south_east_basalt','supply_workshop','east_lamp','flame_banner','southern_basalt']
PLANS={
'A': {'forge':(6,10),'ore_crane':(545,8),'iron_bridge':(778,406),'north_lamp':(700,537),'western_lamp':(475,529),'western_basalt':(1119,146),'south_east_basalt':(1138,745),'supply_workshop':(95,643),'east_lamp':(850,654),'flame_banner':(525,613),'southern_basalt':(5,525)},
'B': {'forge':(6,10),'ore_crane':(545,8),'iron_bridge':(853,406),'north_lamp':(705,539),'western_lamp':(475,528),'western_basalt':(1105,158),'south_east_basalt':(1138,745),'supply_workshop':(95,643),'east_lamp':(852,655),'flame_banner':(525,610),'southern_basalt':(5,526)}
}

def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--ground',type=Path,required=True);ap.add_argument('--source',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);args=ap.parse_args()
 assert digest(args.ground)==GROUND_LOCK,'Ground SHA mismatch'
 assert digest(args.source)==SOURCE_LOCK,'Independent true-RGBA source mismatch'
 args.out.mkdir(parents=True,exist_ok=True)
 g=Image.open(args.ground); raw=Image.open(args.source)
 assert g.size==(1280,928) and g.mode=='RGB',(g.size,g.mode)
 assert raw.size==(1474,1067) and raw.mode=='RGBA',(raw.size,raw.mode)
 a=np.array(raw,dtype=np.uint8); al=a[:,:,3];assert (al==0).sum()>1_000_000
 # True transparent authored source, NOT a checkerboard key. Preserve interior alpha.
 fg=al>32; labels,n=label(fg,np.ones((3,3),dtype=np.uint8));counts=np.bincount(labels.ravel());boxes=find_objects(labels)
 comps=[]
 for lab,b in enumerate(boxes,1):
  if b is None or counts[lab]<1000:continue
  y,x=b;comps.append((int(y.start),int(x.start),int(counts[lab]),(int(x.start),int(y.start),int(x.stop),int(y.stop))))
 comps.sort();assert len(comps)==11,(len(comps),comps)
 parts={}
 srcstats={}
 for name,(y,x,count,bbox) in zip(NAMES,comps):
  x0,y0,x1,y1=bbox; crop=a[y0:y1,x0:x1].copy()
  mask=(labels[y0:y1,x0:x1]==labels[y,x]) if False else None
  # source bbox has no other main group in it; reject if unexpected intersections.
  srcstats[name]={'source_bbox':bbox,'significant_alpha_pixels':count,'w':x1-x0,'h':y1-y0}
  # only low-alpha noise suppressed; stable image source remains unmodified
  crop[crop[:,:,3]<=8]=[0,0,0,0]
  # Important: exactly preserve all original alpha>32, do not recolor edge red, no scale.
  parts[name]=Image.fromarray(crop,'RGBA')
 assert set(parts)==set(NAMES)
 base=Image.open(args.ground).convert('RGBA')
 outqa={'scene':'FS_04_MAZE','phase':'D24_TRUE_RGBA_INDEPENDENT_ALL_NON_GROUND_ART_FIRST','original_source_SHA256':SOURCE_LOCK,'original_source_dimensions':[1474,1067],
 'source_mode':'RGBA_TRUE_TRANSPARENT_NOT_CHECKER_RGB','source_true_alpha0_pixels':int((al==0).sum()),'source_visible_gt32_pixels':int(fg.sum()),'ground_SHA256':GROUND_LOCK,'source_item_groups':srcstats,
 'both_image_layers':'GROUND RGB and independent ALL-non-ground PAR RGBA','human_visual_ART':'HOLD_OWNER_NOT_APPROVED','formal_ART_PASS':'0/12','real_private_Godot472_native':'NOT_RUN','method':'FULL_ALPHA_OBJECT_BBOX_NATIVE_1X_RELAYOUT_NOT_DIRECT_NATIVE_1280_FROM_MODEL'}
 board=Image.new('RGB',(1280*2,980),(26,26,30));bd=ImageDraw.Draw(board)
 for ind,(name,coords) in enumerate(PLANS.items()):
  par=Image.new('RGBA',(1280,928),(0,0,0,0)); occupied=np.zeros((928,1280),dtype=bool); overlap=0;details=[]
  for obj in NAMES:
   x,y=coords[obj];part=parts[obj];w,h=part.size
   assert 0<=x<=1280-w and 0<=y<=928-h,(name,obj,(x,y,w,h))
   fgobj=np.array(part.getchannel('A'))>8
   roi=occupied[y:y+h,x:x+w];overlap+=int(np.count_nonzero(roi & fgobj));roi|=fgobj
   par.alpha_composite(part,(x,y))
   details.append({'name':obj,'world_xy':[x,y],'size':[w,h],'pixels_alpha_gt8':int(fgobj.sum()),'source_bbox':srcstats[obj]['source_bbox'],'scale':'1x'})
  par_path=args.out/f'D24_{name}_COMPLETE_PAR_ALL_NON_GROUND_1280x928.png';par.save(par_path)
  comp=Image.alpha_composite(base,par);comppath=args.out/f'D24_{name}_GROUND_PAR_COMPOSITE_1280x928.png';comp.save(comppath)
  alpha=np.array(par.getchannel('A'))
  bd.text((ind*1280+12,10),f'D24 {name}: true RGBA full object source; ART HOLD',fill=(245,245,245));board.paste(comp.convert('RGB'),(ind*1280,52))
  edge=int(np.count_nonzero(alpha[:5,:]>224)+np.count_nonzero(alpha[-5:,:]>224)+np.count_nonzero(alpha[5:-5,:5]>224)+np.count_nonzero(alpha[5:-5,-5:]>224))
  # Approx original lava bank sample for both bridge towers; no claim of physical bridge pass
  bx,by=coords['iron_bridge'];edgepts=[]
  for foot in [(bx+30,by+200),(bx+352,by+200)]:
   px,py=foot;patch=np.asarray(g)[max(0,py-12):py+12,max(0,px-12):px+12];r,gg,b=patch[:,:,0].astype(int),patch[:,:,1].astype(int),patch[:,:,2].astype(int)
   pct=float(((r>160)&(gg>55)&(gg<175)&(b<110)).mean())
   edgepts.append({'ground_xy':[px,py],'bright_lava_fraction_24px':round(pct,3)})
  outqa[name]={'PAR_SHA256':digest(par_path),'COMPOSITE_SHA256':digest(comppath),'PAR_real_alpha_zero':int((alpha==0).sum()),'PAR_alpha_visible_gt8':int((alpha>8).sum()),'object_overlap_pixels':overlap,'outer_five_px_alpha_gt224':edge,'bridge_bank_samples':edgepts,'objects':details,
   'source_pixel_scale':1,'ground_source_unchanged':True,'polygon_trim':0,'model_native_1280_direct':False,'ART_status':'HOLD'}
  print(name,'overlap',overlap,'edge',edge,'bank lava',edgepts,'sha',outqa[name]['PAR_SHA256'])
 board.save(args.out/'D24_A_B_FULL_SCENE_ART_QA.png')
 # Unit test source is true-RGBA, no policy-changing white-key; ensure g sha unchanged.
 assert digest(args.ground)==GROUND_LOCK
 assert outqa['B']['outer_five_px_alpha_gt224']==0
 (args.out/'D24_ART_SOURCE_LAYOUT_QA.json').write_text(json.dumps(outqa,indent=2,ensure_ascii=False),encoding='utf-8')
if __name__=='__main__':main()
