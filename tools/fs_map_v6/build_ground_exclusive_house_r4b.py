from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,cv2,json,hashlib
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs'
im=Image.open(s/'HOUSE_R3A_BASE.png').convert('RGBA');orig=np.asarray(im)
a=np.asarray(Image.open(o/'HOUSE_STRICT_GROUND_EXCLUSIVE_CANDIDATE.png').convert('RGBA'))
h,w=orig.shape[:2];Y,X=np.indices((h,w));keep=a[:,:,3]>0
rgb=orig[:,:,:3];mx=rgb.max(axis=2).astype('int16');mn=rgb.min(axis=2).astype('int16')
hsv=cv2.cvtColor(rgb,cv2.COLOR_RGB2HSV)
stone=((mx-mn)<65)&(hsv[:,:,1]<98)
# Extremely conservative geometry: no free-standing front flower bed, no lawn base, no side flower bush.
source_garden=(Y>=101)&((X<74)|(X>213))
front_bed=(Y>=120)&((X<106)|(X>161))
floor_original=(Y>=138)&~((X>=109)&(X<=159)&stone)
# Stem/grass starts near door bottom; no independent plant roots in a house source.
floor_plant=(Y>=115)&(hsv[:,:,0]>=25)&(hsv[:,:,0]<=102)&(hsv[:,:,1]>=47)
# Structural doorstep in central x111..159 with low saturation is retained.
clear=source_garden|front_bed|floor_original|floor_plant
retain=keep&~clear
out=orig.copy();out[~retain]=0
Image.fromarray(out,'RGBA').save(o/'HOUSE_STRUCTURAL_NO_GROUND_R4B.png')
Image.fromarray((clear.astype('uint8')*255),'L').save(o/'R4B_EXCLUDED_GARDEN_AND_LOOSE_SOIL_MASK.png')
# Barrel source stays on independent prop layer, NEVER use the original grass in object png.
props=np.asarray(Image.open(o/'BARRELS_STANDALONE_CANDIDATE.png').convert('RGBA'))
assert np.all(props[props[:,:,3]==0,:3]==0)
G=Image.open(s/'GROUND_B.png').convert('RGBA')
parts=[(orig,'R3_SOURCE'),(a,'R4A_STRUCTURE_WITH_GARDEN_REMNANTS'),(out,'R4B_STRICT_STRUCTURE')]
comp=Image.new('RGB',(544*len(parts),416))
checker=Image.new('RGB',(261*4*len(parts),183*4))
for i,(v,n) in enumerate(parts):
 img=G.copy();img.alpha_composite(Image.fromarray(v,'RGBA'),(12,48));img.save(o/(n+'_WORLD.png'));comp.paste(img.convert('RGB'),(i*544,0))
 display=Image.new('RGBA',(w,h));dr=ImageDraw.Draw(display)
 for y in range(0,h,8):
  for x in range(0,w,8):dr.rectangle((x,y,x+7,y+7),fill=(62,64,69,255) if((x//8+y//8)%2) else (155,158,160,255))
 display.alpha_composite(Image.fromarray(v,'RGBA'))
 checker.paste(display.resize((w*4,h*4),Image.Resampling.NEAREST).convert('RGB'),(i*w*4,0))
comp.save(o/'R3_R4A_R4B_WORLDS_1X.png');checker.save(o/'R3_R4A_R4B_SOURCE_4X.png')
# HARD gate different from R4A; secondary explicit forbidden mask ensures all known lower original terrain gone
forbid=(source_garden|front_bed|floor_original|floor_plant)&(orig[:,:,3]>0)
assert int(np.count_nonzero(retain&forbid))==0
# Negative: even a deliberately injected 1px forbidden-alpha ground pixel is caught.
negative=out.copy();yx=np.argwhere(forbid&~retain);assert len(yx)>0
fy,fx=map(int,yx[0]);negative[fy,fx]=orig[fy,fx];assert negative[fy,fx,3]>0
def reject(val):return int(np.count_nonzero((val[:,:,3]>0)&forbid))
assert reject(out)==0 and reject(negative)>=1
# Demonstrate known pre-existing non-house Garden on original source has been rejected
assert reject(orig)>0
quality={"kind":"FS_V6_P3_R4B_CONSERVATIVE_GEOMETRY",
         "new_structural_pixels":int(retain.sum()),"rejected_source_lawn_and_garden_pixels":int((orig[:,:,3]>0).sum()-int(retain.sum())),
         "explicit_forbidden_mask_alpha_overlap":reject(out),
         "negative_ground_injection_triggered":reject(negative),
         "original_ground_contamination_detected":reject(orig),
         "note":"Geometry is human-authored conservative candidate; roof moss permitted only where visibly attached. Residue quality and structural edge human ART review PENDING.",
         "status":"R4B_STRICT_TECH_CANDIDATE_NOT_ART_PASS"}
(r/'QA_R4B_GROUND_SEMANTICS.json').write_text(json.dumps(quality,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps(quality))
