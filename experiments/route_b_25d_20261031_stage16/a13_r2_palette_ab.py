from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
R=Path(__file__).resolve().parent
def rgb(n):
 with Image.open(R/n) as im:return np.asarray(im.convert('RGB'),dtype=np.uint8).copy()
base=rgb('A13_REPLACEMENT_BASE_544x416.png')
r1=rgb('A13_BOTANICAL_CLUSTER_GROUND_544x416.png')
a12=rgb('A13_A12_FINAL_COMPARATOR_544x416.png')
with Image.open(R/'A13_PROTECTED_MASK.png') as im:protected=np.asarray(im.convert('L'))>0
with Image.open(R/'A13_SOIL_LEGAL_PIXELS.png') as im:soil=np.asarray(im.convert('L'))>0
with Image.open(R/'A13_BOTANICAL_MOTIFS_RGBA_8x16.png') as im:atlas=np.asarray(im.convert('RGBA'),dtype=np.uint8).copy()
motifs=[atlas[:,16*i:16*(i+1),:].copy() for i in range(8)]
records=json.loads((R/'A13_SPRITE_PLACEMENTS.json').read_text(encoding='utf8'))
assert len(records)==292
out=base.copy()
r2mask=np.zeros((416,544),dtype=bool)
for rec in records:
 k=rec['motif'];x0,y0=rec['top_left']
 sprite=motifs[k]
 if rec['reflected']:sprite=np.fliplr(sprite)
 solid=sprite[:,:,3]>0
 assert not np.any((protected|soil)[y0:y0+16,x0:x0+16]&solid)
 patch=out[y0:y0+16,x0:x0+16]
 # Controlled palette-only ablation: identical native sprite geometry, placements, count and seed.
 alpha=.68 if rec['kind']=='cover' else .88
 new=patch.astype('float64')*(1.-alpha)+sprite[:,:,:3].astype('float64')*alpha
 patch[solid]=np.rint(np.clip(new[solid],0,255)).astype('uint8')
 r2mask[y0:y0+16,x0:x0+16][solid]=True
assert np.array_equal(out[protected],r1[protected])
assert np.array_equal(out[soil],r1[soil])
assert not np.any(np.any(r1!=out,axis=2)&~r2mask)
Image.fromarray(out,'RGB').save(R/'A13_R2_PALETTE_HARMONIZED_544x416.png')
Image.fromarray(r2mask.astype('uint8')*255,'L').save(R/'A13_R2_CHANGED_ALLOWED_MASK.png')
# 1x tri-panel no resampling.
canvas=Image.new('RGB',(3*546,447),(20,23,25));d=ImageDraw.Draw(canvas)
for i,(title,arr) in enumerate([('A12 dots (old)',a12),('A13 R1 hard-color sprites',r1),('A13 R2 color-harmonized sprites',out)]):
 x=i*546+1;d.text((x,6),title,fill='white');canvas.paste(Image.fromarray(arr),(x,28))
canvas.save(R/'A13_A12_R1_R2_1X_COMPARISON.png')
# Repeat same 32x32 fragments from high-priority cluster region.
regions=[('NW fern',65,36),('W meadow',76,143),('NE wildflower',439,94),('SE meadow',449,325)]
lens=Image.new('RGB',(3*258,4*281),(19,22,25));dd=ImageDraw.Draw(lens)
for row,(label,x,y) in enumerate(regions):
 for col,(name,arr) in enumerate([('A12',a12),('R1',r1),('R2',out)]):
  px=col*258;py=row*281
  dd.text((px+2,py+6),label+' / '+name,fill='white')
  tile=Image.fromarray(arr).crop((x,y,x+32,y+32)).resize((256,256),Image.Resampling.NEAREST)
  lens.paste(tile,(px,py+25))
lens.save(R/'A13_A12_R1_R2_32PX_AUDIT.png')
diff=np.any(r1!=out,axis=2)
qa={'experiment':'A13_R2_PALETTE_HARMONIZATION_ONLY','sprite_count':len(records),'cover_alpha':.68,'flower_alpha':.88,'same_16x16_atlas':True,'same_placements':True,'same_A12_tint_and_soil':True,'road_and_transition_unchanged':int(np.count_nonzero(diff&protected)),'soil_unchanged':int(np.count_nonzero(diff&soil)),'illegal_changed_outside_new_motif_pixels':int(np.count_nonzero(diff&~r2mask)),'palette_blended_pixels':int(diff.sum()),'R1_sha256':hashlib.sha256((R/'A13_BOTANICAL_CLUSTER_GROUND_544x416.png').read_bytes()).hexdigest(),'R2_sha256':hashlib.sha256((R/'A13_R2_PALETTE_HARMONIZED_544x416.png').read_bytes()).hexdigest(),'art':'FAIL_INTERNAL_GROUND3_STYLE','godot':'NOT_RUN','vx':'NOT_RUN','formal_seal':'NO'}
(R/'A13_R1_R2_CONTROLLED_AB_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf8')
print('A13_R1_R2',json.dumps(qa,ensure_ascii=False),flush=True)
