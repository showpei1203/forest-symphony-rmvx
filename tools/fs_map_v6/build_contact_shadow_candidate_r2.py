from PIL import Image
from pathlib import Path
import numpy as np,json,hashlib
r=Path(__file__).resolve().parent
source=Image.open(r/'HOUSE_R2_CLEANED_ALPHA_CANDIDATE.png').convert('RGBA')
G=Image.open(r/'source/GROUND_B.png').convert('RGBA')
PAR=Image.open(r/'outputs/PAR_COMPLETE.png').convert('RGBA')
R1=Image.open(r/'WORLD_R1_COMPOSITE_REFERENCE.png').convert('RGBA')
assert G.size==PAR.size==R1.size==(544,416)
x,y=12,48
alpha=np.asarray(source.getchannel('A'))>0
shadows={}
for label,distance,strength in [('SHORT',1,40),('SOFTLONG',2,45)]:
 shifted=np.zeros_like(alpha)
 shifted[distance:,:]=alpha[:-distance,:]
 # Under the bottom visible contour only, no screen-sized gradient
 edge=shifted & ~alpha
 edge[:120,:]=False
 mask=np.zeros((416,544),dtype=np.uint8)
 mask[y:y+183,x:x+261]=(edge.astype(np.uint8)*strength)
 sh=np.zeros((416,544,4),dtype=np.uint8)
 sh[:,:,:3]=[46,43,27];sh[:,:,3]=mask
 sh[np.where(mask==0)]=0
 image=Image.fromarray(sh,'RGBA')
 image.save(r/('CONTACT_SHADOW_'+label+'.png'))
 withshadow=Image.alpha_composite(Image.alpha_composite(G,image),PAR)
 withshadow.save(r/('WORLD_CONTACT_SHADOW_'+label+'.png'))
 withshadow.crop((15,112,280,244)).resize((795,396),Image.Resampling.NEAREST).save(r/('WORLD_CONTACT_SHADOW_'+label+'_3X.png'))
 shadows[label]={"pixels":int((mask>0).sum()),"alpha_strength":strength,"world_output":str(r/('WORLD_CONTACT_SHADOW_'+label+'.png'))}
# Compare old R1, R2 w/o shadow, 1px shadow
new=Image.open(r/'outputs/WORLD_COMPOSITE_NO_ACTOR.png').convert('RGBA')
board=Image.new('RGB',(544*3,416),(18,18,18))
for i,im in enumerate([R1,new,Image.open(r/'WORLD_CONTACT_SHADOW_SHORT.png').convert('RGBA')]):
 board.paste(im.convert('RGB'),(544*i,0))
board.save(r/'R1_R2_NO_SHADOW_AND_SHORT_SHADOW_CONTACT.png')
assert all(info['pixels']>0 for info in shadows.values())
# Source-owned crop QA: every unchanged area outside house sprite is byte identical
outside=np.ones((416,544),dtype=bool);outside[y:y+183,x:x+261]=False
assert np.array_equal(np.asarray(R1)[outside],np.asarray(new)[outside])
# Original full Ground under deleted source pixels restored automatically
raw_house=Image.open(r/'HOUSE_R1_ORIGINAL_REFERENCE.png').convert('RGBA')
clean_house=source
deleted=(np.asarray(raw_house.getchannel('A'))>0)&(np.asarray(clean_house.getchannel('A'))==0)
assert int(deleted.sum())==6501
# Overlaps of later sources do not count for exact underpaint; compare house-only compositing
houseonly=G.copy();houseonly.alpha_composite(clean_house,(x,y))
assert np.array_equal(np.asarray(houseonly)[y:y+183,x:x+261][deleted],np.asarray(G)[y:y+183,x:x+261][deleted])
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
qa={"r1_r2_other_pixels_exact":True,"deleted_baked_ground_count":int(deleted.sum()),
    "recovered_ground_under_deleted_pixels_exact":True,
    "ground_source_unchanged_sha256":sha(r/'source/GROUND_B.png'),
    "contact_shadow_layer_is_separate_from_ground":True,
    "shadow_masks":shadows,
    "status":"VISUAL_CANDIDATE_ART_NOT_SIGNED_NATIVE_NOT_RUN"}
(r/'R2_CONTACT_SHADOW_QA.json').write_text(json.dumps(qa,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps(qa,ensure_ascii=False))
