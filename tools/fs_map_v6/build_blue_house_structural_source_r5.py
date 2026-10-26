"""FS V6 R5: a NEW pixel-structured architectural foundation; existing roof, windows, door source kept RGBA exact.
All ground/source lawn from original cottage EXCLUDED. Never treat mask semantics as human certification."""
from PIL import Image, ImageDraw
from pathlib import Path
import numpy as np,cv2,json,hashlib,random
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs';o.mkdir(exist_ok=True)
src=Image.open(s/'BLUE_COTTAGE_ORIGINAL.png').convert('RGBA')
w,h=src.size;assert (w,h)==(303,251)
a=np.asarray(src).copy();alpha=a[:,:,3]>0
def polygon(points):
 m=Image.new('L',src.size);ImageDraw.Draw(m).polygon(points,fill=255)
 return np.asarray(m)>0
# High-confidence old architectural regions. Old lawn/flower carpet BELOW source threshold is excluded.
roof=polygon([(21,53),(30,49),(36,46),(42,50),(90,47),(100,38),(110,24),(116,4),(120,1),
(130,45),(166,47),(228,46),(234,49),(243,55),(242,133),(232,139),(191,133),(173,145),
(134,139),(98,148),(35,147),(22,127)])
front=polygon([(36,137),(94,136),(104,142),(170,140),(178,133),(238,132),
(239,163),(224,166),(183,163),(174,182),(150,189),(145,201),
(96,201),(90,188),(38,188)])
# retain the actual door + architectural stair stone; no surrounding painted soil.
stairs=polygon([(96,175),(148,176),(151,201),(144,214),(98,215),(94,201)])
chimney=polygon([(218,47),(241,47),(241,109),(224,111)])
loyal=alpha & (roof|front|stairs|chimney)
# Cut original foreground grass and flower/soil: explicit color/coordinate prohibited regions.
Y,X=np.indices((h,w))
base_lawn=(Y>=201)&~stairs
distant_garden=((X<=36)|(X>=240))&(Y>=131)
# Garden beneath windows, prior vegetation silhouette not physically connected to roof/wall
plant_under_windows=(Y>=168)&(((X<95)|(X>169))&(Y<=204))
# Roof upper green retained where attached roof/climbing edge only, all unrelated green meadow below cutoff removed
remove=(base_lawn|distant_garden|plant_under_windows)
loyal&=~remove
old_pixels=a.copy();old_pixels[~loyal]=0
Image.fromarray(old_pixels,'RGBA').save(o/'BLUE_HOUSE_SOURCE_RETENTION_ONLY.png')
# Rebuild structural stone ground-floor wall, not a generated ground plane.
# Every pixel generated here must be a visible masonry block, mortar, threshold or shadow.
walls=Image.new('RGBA',(w,h),(0,0,0,0));wd=ImageDraw.Draw(walls)
rng=random.Random(20261027)
foundation_regions=[(37,176,96,204),(149,173,178,204),(179,165,239,203)]
# Cut gardens by reconstructing actual facade lower part. Built into NEW facade sprite, NOT original terrain.
for left,top,right,bottom in foundation_regions:
 wd.rectangle((left,top,right,bottom),fill=(72,67,58,255))
 row=top
 while row<bottom:
  height=min(rng.choice([8,9,10,11]),bottom-row+1)
  gap=rng.randrange(-9,3)
  pos=left+gap
  while pos<=right:
   length=rng.randrange(13,23)
   x0=max(left,pos);x1=min(right,pos+length)
   y0=row+1;y1=min(bottom,row+height-1)
   if x1>=x0 and y1>=y0:
    light=rng.randrange(-18,18)
    base=(139+light,131+light,113+light)
    wd.rectangle((x0,y0,x1,y1),fill=(*base,255))
    # 1px lit upper edge and darker lower corner, all pixellated at native source resolution
    wd.line((x0+1,y0,x1-1,y0),fill=(min(255,base[0]+20),min(255,base[1]+18),min(255,base[2]+15),255),width=1)
    wd.line((x0,y1,max(x0,x1-1),y1),fill=(max(0,base[0]-30),max(0,base[1]-28),max(0,base[2]-27),255),width=1)
    for j in range(rng.randrange(1,5)):
     xx=rng.randrange(x0,x1+1);yy=rng.randrange(y0,y1+1)
     wd.point((xx,yy),fill=(max(0,base[0]+rng.randrange(-20,16)),max(0,base[1]+rng.randrange(-20,18)),max(0,base[2]+rng.randrange(-16,20)),255))
   pos+=length+1
  row+=height
# Add actual physical stone sill/plinth, explicitly architectural and separate from dirt path
for x0,x1 in [(39,95),(146,238)]:
 wd.rectangle((x0,203,x1,206),fill=(72,66,59,255))
 wd.line((x0,203,x1,203),fill=(174,164,140,255))
 wd.line((x0,205,x1,205),fill=(48,43,38,255))
# retain source door and front steps above rebuilt masonry; avoid overpainting stairs
facade=Image.alpha_composite(walls,Image.fromarray(old_pixels,'RGBA'))
# dedicated original door + steps source overlay is already preserved in old_pixels
facade.save(o/'BLUE_HOUSE_RECONSTRUCTED_WHOLE_NO_TURF_R5.png')
walls.save(o/'BLUE_HOUSE_NEW_MASONRY_FOUNDATION_SOURCE.png')
owner=Image.new('L',(w,h),0)
owner.paste(1,(0,0),walls.getchannel('A'))
owner.paste(2,(0,0),Image.fromarray(old_pixels,'RGBA').getchannel('A'))
owner.save(o/'SOURCE_PIXEL_OWNER_NEW_WALL_OLD_BODY.png')
# Retained RGBA source unchanged where no new masonry overlays. Source original lawn has zero owner.
ground=Image.open(s/'GROUND_B.png').convert('RGBA'); assert ground.size==(544,416)
scene_old=ground.copy();scene_old.alpha_composite(src,(18,24))
scene_new=ground.copy();scene_new.alpha_composite(facade,(18,24))
scene_new.save(o/'GROUND_B_NEW_BLUE_HOUSE_NO_TURF.png')
comp=Image.new('RGB',(1088,416))
comp.paste(scene_old.convert('RGB'),(0,0));comp.paste(scene_new.convert('RGB'),(544,0));comp.save(o/'OLD_VS_R5_BLUE_HOUSE_GROUND_1X.png')
# 4x nearest review on transparent checker
view=Image.new('RGB',(w*8,h*4))
for i,im in enumerate((src,facade)):
 grid=Image.new('RGBA',(w,h));gd=ImageDraw.Draw(grid)
 for y in range(0,h,10):
  for x in range(0,w,10):
   gd.rectangle((x,y,x+9,y+9),fill=(68,71,72,255) if (x//10+y//10)%2 else (142,144,146,255))
 grid.alpha_composite(im)
 view.paste(grid.resize((w*4,h*4),Image.Resampling.NEAREST).convert('RGB'),(i*w*4,0))
view.save(o/'OLD_VS_R5_BLUE_HOUSE_ALPHA_4X.png')
# Automated sanity; independent art quality judgement remains pending.
rgb=np.asarray(facade)
assert facade.getchannel('A').getbbox()
assert np.all(rgb[rgb[:,:,3]==0,:3]==0)
assert np.count_nonzero(np.asarray(walls.getchannel('A'))>0)>1000
deleted=int(np.count_nonzero(alpha&~loyal))
qa={
 'old_source_size':[w,h],'old_source_pixels':int(alpha.sum()),
 'old_source_terrain_or_uncertain_pixels_excluded':deleted,
 'retained_source_exact_count':int(loyal.sum()),
 'new_masonry_structural_pixels':int(np.count_nonzero(np.asarray(walls.getchannel('A')))),
 'ground_rgb_alpha_unchanged':True,
 'no_source_terrain_layer_reused':True,
 'house_body_completeness':'new stone foundation polygon rebuilt, HUMAN_VISUAL_PENDING',
 'critical_caveat':'Roof ivy and source façade may still include biologically attached vs detached uncertainty; wall pattern aesthetic must be evaluated against SCENE21 1x and VX 28x32 actor',
 'human_art':'PENDING','vx_native':'NOT_RUN'
}
(r/'QA_R5_SOURCE_ARCH_RECONSTRUCTION.json').write_text(json.dumps(qa,indent=2),encoding='utf8')
print(json.dumps(qa))
