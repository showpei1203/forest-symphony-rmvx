from PIL import Image,ImageDraw,ImageFilter
from pathlib import Path
from PIL import ImageOps
root=Path('/mnt/data/A11_LAYERED_RIG')
im=Image.open('/mnt/data/a_single_clear_scene_a_pixel_art_sprite_illustra.png').convert('RGBA')
# sword outline and hilt on AI attack-pose reference, excludes original character's hand
poly=[(111,337),(134,319),(393,482),(430,497),(444,482),(468,479),(488,512),(477,531),(462,542),(469,574),(454,586),(430,549),(404,536),(368,525),(353,514)]
mask=Image.new('L',im.size,0);d=ImageDraw.Draw(mask);d.polygon(poly,fill=255)
# magenta color is outside opaque cutout
pix=im.load();ma=mask.load()
for y in range(im.height):
 for x in range(im.width):
  r,g,b,a=pix[x,y]
  if r>160 and b>130 and g<95 and (r+b>2.8*max(g,1)):ma[x,y]=0
im.putalpha(mask)
crop=im.crop((100,300,510,610));crop.save(root/'sword_crop_large.png')
small=crop.resize((32,24),Image.Resampling.NEAREST)
small.save(root/'sword_32x24.png')
small.resize((320,240),Image.Resampling.NEAREST).save(root/'sword_crop_debug.png')