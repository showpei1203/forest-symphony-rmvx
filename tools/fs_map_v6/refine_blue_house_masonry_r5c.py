from pathlib import Path
from PIL import Image,ImageDraw
import random,numpy as np,json,hashlib
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs'
roof=Image.open(o/'BLUE_HOUSE_SOURCE_RETENTION_ONLY.png').convert('RGBA')
old=Image.open(o/'BLUE_HOUSE_RECONSTRUCTED_WHOLE_NO_TURF_R5.png').convert('RGBA')
ground=Image.open(s/'GROUND_B.png').convert('RGBA')
orig=Image.open(s/'BLUE_COTTAGE_ORIGINAL.png').convert('RGBA')
W,H=roof.size
rng=random.Random(20261027)
masonry=Image.new('RGBA',(W,H),(0,0,0,0));dr=ImageDraw.Draw(masonry)
areas=[(38,143,95,205),(149,174,178,205),(179,165,238,205)]
palette=[(147,133,110),(155,147,123),(175,160,138),(132,126,109),(199,188,165),(126,119,106),(182,166,139),(156,148,128)]
for left,top,right,bottom in areas:
 dr.rectangle((left,top,right,bottom),fill=(70,65,58,255))
 row=top
 rowid=0
 while row<=bottom:
  hh=rng.choice((6,7,8,9))
  offset=rng.randint(-16,-3) if rowid%2 else rng.randint(-9,2)
  pos=left+offset
  while pos<right+1:
   size=rng.randint(9,19)
   x0=max(left,pos);x1=min(right,pos+size)
   y0=row+1;y1=min(bottom,row+hh-1)
   if x1-x0>=2 and y1>=y0:
    base=palette[rng.randrange(len(palette))]
    light=rng.randint(-11,11)
    color=tuple(max(0,min(255,v+light)) for v in base)
    # slightly uneven stone contour, single-pixel mortar between blocks
    dr.polygon([(x0+1,y0),(x1-1,y0),(x1,y0+1),(x1,y1-1),(x1-1,y1),(x0+1,y1),(x0,y1-1),(x0,y0+1)],fill=(*color,255))
    dr.line((x0+1,y0,x1-1,y0),fill=tuple(min(255,q+27) for q in color)+(255,))
    dr.line((x0+1,y1,x1-1,y1),fill=tuple(max(0,q-35) for q in color)+(255,))
    for n in range(max(3, (x1-x0)*(y1-y0)//3)):
     xx=rng.randint(x0+1,max(x0+1,x1-1));yy=rng.randint(y0,max(y0,y1))
     shade=rng.choice((-30,-24,-15,-7,6,10,14,24))
     dr.point((xx,yy),fill=tuple(max(0,min(255,z+shade)) for z in color)+(255,))
    if rng.random()<0.34 and x1-x0>=8 and y1-y0>=2:
     cx=rng.randint(x0+3,x1-2);cy=rng.randint(y0+1,y1)
     dr.line([(cx,cy),(min(x1,cx+2),min(y1,cy+1))],fill=(75,71,65,255),width=1)
   pos+=size+2
  row+=hh+1;rowid+=1
 # stone plinth across continuous building base (no original ground crop)
 dr.rectangle((left,bottom,right,bottom+2),fill=(90,84,76,255))
 dr.line((left,bottom,right,bottom),fill=(191,182,155,255))
# hand-placed vertical half-timber columns, house structural edges
for x in (38,94,173,237):
 top=151 if x in (38,94) else 144
 bottom=204
 dr.rectangle((x,top,x+3,bottom),fill=(74,51,33,255))
 dr.line((x,top,x,bottom),fill=(123,87,53,255))
 dr.line((x+3,top,x+3,bottom),fill=(39,29,24,255))
# body above wall layer
new=Image.alpha_composite(masonry,roof)
new.save(o/'BLUE_HOUSE_R5C_REBUILT_COMPLETE_NO_TURF.png')
masonry.save(o/'BLUE_HOUSE_R5C_INDEPENDENT_STONE_FACADE.png')
world=ground.copy();world.alpha_composite(new,(18,24))
world.save(o/'WORLD_R5C_GROUND_B_NO_INHERITED_TURF.png')
compare=Image.new('RGB',(1088,416))
left=Image.alpha_composite(ground,Image.new('RGBA',ground.size))
left.alpha_composite(old,(18,24))
compare.paste(left.convert('RGB'),(0,0));compare.paste(world.convert('RGB'),(544,0))
compare.save(o/'WORLD_R5A_VS_R5C_MASONRY_1X.png')
# 4x cutout compare
big=Image.new('RGB',(W*4*2,H*4))
for i,im in enumerate([old,new]):
 bg=Image.new('RGBA',(W,H));draw=ImageDraw.Draw(bg)
 for y in range(0,H,8):
  for x in range(0,W,8):
   draw.rectangle((x,y,x+7,y+7),fill=(76,78,80,255) if (x//8+y//8)%2 else (150,152,154,255))
 bg.alpha_composite(im)
 big.paste(bg.resize((W*4,H*4),Image.Resampling.NEAREST).convert('RGB'),(i*W*4,0))
big.save(o/'R5A_VS_R5C_HOUSE_4X_SOURCE.png')
# alpha composition on fresh ground not cobbled old turf
assert np.array_equal(np.asarray(ground),np.asarray(Image.open(s/'GROUND_B.png').convert('RGBA')))
assert np.asarray(masonry)[:,:,3].sum()>100000
qa={'stage':'R5C','wall_source':'new architectural pixel masonry, not original lawn, source RGB palette matches stone',
'old_roof_and_window_rgba_preserved':True,'explicit_ground_source_used_as_house_pixels':False,
'wall_px_owned':int(np.count_nonzero(np.asarray(masonry.getchannel('A')))),'native_vx':'NOT_RUN',
'human_art':'PENDING','source_risk':'old original roof edge has attached moss and possibly backdrop flora requiring source art review',
'old_masonry_r5a_REJECTED':'stretched flat-looking wall panels'}
(r/'QA_R5C_MASONRY.json').write_text(json.dumps(qa,indent=2),encoding='utf8')
print(json.dumps(qa))
