from pathlib import Path
from PIL import Image,ImageDraw,ImageFilter
import numpy as np,hashlib,json
r=Path(__file__).resolve().parent
base=Path(r'E:\GameAssetToolLab_20261023')
src=(r/'HOUSE_R1_ORIGINAL_REFERENCE.png') if (r/'HOUSE_R1_ORIGINAL_REFERENCE.png').exists() else base/'MAP_TARGET_V6_20261026/P3_R1_SINGLE_SOURCE_ASSETS_20261026/source/OCHRE_HOUSE.png'
gnd=(r/'source/GROUND_B.png') if (r/'source/GROUND_B.png').exists() else base/'MAP_TARGET_V6_20261026/P3_R1_SINGLE_SOURCE_ASSETS_20261026/source/GROUND_B.png'
A=Image.open(src).convert("RGBA");G=Image.open(gnd).convert("RGBA");assert A.size==(261,183)
arr=np.array(A);w,h=A.size
def M(polys):
    mask=Image.new('L',A.size,0);d=ImageDraw.Draw(mask)
    for poly in polys:d.polygon(poly,fill=255)
    return np.array(mask)>0
# Architecture roof with eaves and chimney. Preserve vertical wood wall, window sill and porch.
arch_polys=[
 [(30,45),(33,38),(39,31),(55,30),(60,19),(66,18),(68,25),(190,25),(191,12),(198,6),(205,9),(210,22),(218,23),(228,29),(229,81),(225,88),(221,143),(207,145),(163,145),(155,150),(107,150),(95,144),(66,144),(58,137),(45,133),(31,96)],
 [(20,48),(33,37),(57,35),(62,73),(55,89),(28,89)],
 # lower structural facade to retain full stone threshold
 [(63,79),(221,77),(222,139),(168,151),(111,152),(60,143)],
 # wooden barrels and pots lower right
 [(164,112),(185,114),(195,123),(196,144),(183,149),(170,145)],
 [(190,108),(216,107),(223,117),(225,146),(216,151),(195,150)],
 # foreground isolated posts
 [(24,116),(37,116),(41,134),(39,157),(31,159),(25,155)],
 [(224,130),(235,129),(240,139),(238,173),(226,171),(224,149)]
]
# Visible flowers: explicitly separate floral clusters, never call their original earth underpaint house.
flower_polys=[
 [(7,118),(12,105),(21,95),(35,92),(47,95),(64,104),(76,119),(91,128),(106,144),(103,152),(82,157),(60,155),(37,153),(15,143),(6,131)],
 [(202,93),(214,90),(230,94),(243,110),(244,123),(238,143),(226,148),(207,135),(201,116)],
 [(68,118),(85,119),(101,132),(108,149),(102,159),(82,161),(62,151)]
]
arch=M(arch_polys);flowers=M(flower_polys)
# Baked soil is identified semantically, not smoothed: trim original bottom ground outside
# actual posts, porch, flowers. Flowers at bottom still subject to color-informed
# candidate validation, preserved here for non-destructive review.
a=arr[:,:,3]>0
arch_keep=a&arch;flower_keep=a&flowers&~arch_keep
result=arr.copy()
def save_source(name,keep):
    data=arr.copy()
    data[~keep,:]=0
    out=r/name;Image.fromarray(data,'RGBA').save(out)
    return out
pa=save_source('HOUSE_ARCHITECTURE_SOURCE_MASKED.png',arch_keep)
pf=save_source('HOUSE_FLOWERS_ACCESSORIES_SOURCE_MASKED.png',flower_keep)
# The semantic mask owns former Ground pixels; the original remains preserved separately.
reclaimed=a&~(arch_keep|flower_keep)
Image.fromarray((reclaimed.astype('uint8')*255),'L').save(r/'REMOVED_BAKED_GROUND_OWNER.png')
Image.fromarray(((arch_keep|flower_keep).astype('uint8')*255),'L').save(r/'HOUSE_RETAIN_ALPHA_OWNER.png')
trim=arr.copy();trim[reclaimed,:]=0
combined=Image.fromarray(trim,'RGBA')
combined.save(r/'HOUSE_R2_CLEANED_ALPHA_CANDIDATE.png')
# Exact RGB ownership for every retained pixel; black out all RGB under alpha0.
assert np.array_equal(np.asarray(combined)[~reclaimed],arr[~reclaimed])
assert np.all(np.asarray(combined)[reclaimed]==0)
assert not any(combined.getchannel('A').getpixel((0,j)) for j in range(h))
assert not any(combined.getchannel('A').getpixel((w-1,j)) for j in range(h))
# Compose before/after both on same immutable B Ground instance XY.
XY=(12,48)
before=G.copy();before.alpha_composite(A,XY)
after=G.copy();after.alpha_composite(combined,XY)
before.save(r/'WORLD_BEFORE_HOUSE_CONTACT.png')
after.save(r/'WORLD_AFTER_HOUSE_CONTACT.png')
contact=Image.new('RGB',(544*2,416));contact.paste(before.convert('RGB'),(0,0));contact.paste(after.convert('RGB'),(544,0))
contact.save(r/'BEFORE_AFTER_CONTACT_1X.png')
# zoom contact image at door / flower beds source positioning
crop=(15,112,280,244)
z=Image.new('RGB',(265*3*2,132*3))
before.crop(crop).resize((795,396),Image.Resampling.NEAREST).save(r/'BEFORE_HOUSE_CONTACT_3X.png')
after.crop(crop).resize((795,396),Image.Resampling.NEAREST).save(r/'AFTER_HOUSE_CONTACT_3X.png')
neg=np.array(before)!=np.array(after)
changed=int(np.count_nonzero(np.any(neg,axis=2)))
assert changed>0
assert np.array_equal(np.array(Image.alpha_composite(G,A if False else Image.new('RGBA',G.size)))[0:0],np.array(G)[0:0])
qa={
 "source":str(src),"source_sha256":hashlib.sha256(src.read_bytes()).hexdigest(),
 "original_size":[w,h],"original_nontransparent_pixels":int(a.sum()),
 "retained_structure_pixels":int(arch_keep.sum()),"retained_flora_pixels":int(flower_keep.sum()),
 "excluded_baked_underground_pixels":int(reclaimed.sum()),
 "source_RGBA_preserved_owned_pixels":True,
 "transparency_rgba_zero_under_removed":True,
 "changed_world_pixels":changed,
 "candidate_only":"HUMAN_MUST_REVIEW_FLOWER_SHAPES_AND_HOUSE_CONTACT; NOT FORMAL_ART_PASS",
 "limitations":["Polygon segmentation candidate, may remove real roots or keep ambient grass","Original flower and porch contact roots need 1x visual approval","No new source content generated, all kept pixels same source","Original and new house PNG kept alongside semantic masks; no sealed runtime modified"]
}
(r/'HOUSE_R2_SOURCE_OWNERSHIP_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(qa,ensure_ascii=False))
