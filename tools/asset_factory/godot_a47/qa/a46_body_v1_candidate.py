from pathlib import Path
from PIL import Image, ImageDraw
import json,math
p=Path(__file__).resolve().parents[1]
a=p/'assets'
canonical=Image.open(a/'actor01_a62_approved_idle_source_64.png').convert('RGBA')
prior=Image.open(a/'actor01_a45_body_12frames.png').convert('RGBA')
weapon=Image.open(a/'actor01_a45_weapon_12frames.png').convert('RGBA')
fx=Image.open(a/'actor01_a45_fx_12frames.png').convert('RGBA')
sheet=Image.new('RGBA',(256,192))
compare=Image.new('RGBA',(768,128))
# Single canonical source for torso/abdomen, no per-frame horizontal surgery.
# Polygon boundary follows natural jacket silhouette, not a straight y46 cut.
core={
 35:(31,36),36:(29,38),37:(28,40),38:(27,40),
 39:(26,40),40:(25,40),41:(25,41),42:(25,41),
 43:(26,40),44:(27,40),45:(28,40),46:(27,40),
 47:(27,40),48:(26,40),49:(26,40),50:(28,38)
}
for i in range(12):
 box=(i%4*64,i//4*64,i%4*64+64,i//4*64+64)
 old=prior.crop(box)
 new=old.copy()
 if i not in (0,11):
  for y,(l,r) in core.items():
   for x in range(l,r+1):
    new.putpixel((x,y),canonical.getpixel((x,y)))
  # eliminate old y45 lower coat flat stripe in the right-hand region
  # only if not part of moving arm; preserve arm elsewhere.
  # Additional torso movement represented by overlapping angle-specific
  # shoulder armour highlights, but pelvis and chest are sourced from ONE.
  d=ImageDraw.Draw(new)
  if i in (2,3,4):
   d.point((37,39),fill=(38,75,66,255))
  elif i in (5,6,7):
   d.line([(36,38),(38,39)],fill=(45,94,79,255),width=1)
  elif i in (8,9):
   d.point((37,41),fill=(29,68,58,255))
 sheet.alpha_composite(new,(box[0],box[1]))
 compare.alpha_composite(old,(64*i,0))
 compare.alpha_composite(new,(64*i,64))
sheet.save(a/'actor01_a46_body_v1_12frames.png')
compare.resize((2304,384),Image.Resampling.NEAREST).save(p/'A46_V1_WAIST_CORE_RESTORE_COMPARE_3X.png')
print('A46_RECONSTRUCT_V1_DONE',len(core))
