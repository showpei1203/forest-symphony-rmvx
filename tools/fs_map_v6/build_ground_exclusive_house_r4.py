from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np, cv2, hashlib, json
r=Path(__file__).resolve().parent;s=r/'source';o=r/'outputs';o.mkdir(exist_ok=True)
src=Image.open(s/'HOUSE_R3A_BASE.png').convert('RGBA');raw=np.asarray(src).copy()
assert src.size==(261,183)
W,H=src.size
def polygon(points):
 m=Image.new('L',(W,H));ImageDraw.Draw(m).polygon(points,fill=255)
 return np.asarray(m)>0
def rect(coords): 
 im=Image.new('L',(W,H));ImageDraw.Draw(im).rectangle(coords,fill=255);return np.asarray(im)>0
def png(name,rgba):Image.fromarray(rgba.astype('uint8'),'RGBA').save(o/name)
def maskpng(name,m):Image.fromarray((m.astype('uint8')*255),'L').save(o/name)
alpha=raw[:,:,3]>0
# Material regions annotated against original 4x source. Planar background outside ALL owned structure is forbidden.
roof=polygon([(19,50),(25,41),(44,31),(57,31),(58,20),(65,16),(71,23),
              (188,23),(191,11),(195,5),(207,6),(211,22),(222,24),(230,34),
              (231,79),(223,85),(60,85),(25,83)])
wall=polygon([(62,77),(222,77),(221,116),(213,137),(164,141),(160,145),
              (108,145),(103,139),(83,139),(64,127)])
# Preserve actual threshold/door-step, never the green original lawn adjacent to it.
step=polygon([(108,130),(159,130),(160,144),(149,149),(119,149),(108,145)])
chimney=polygon([(191,4),(208,4),(218,24),(216,84),(211,126),(191,124),(190,25)])
gross_body=(roof|wall|step|chimney)&alpha
hsv=cv2.cvtColor(raw[:,:,:3],cv2.COLOR_RGB2HSV)
green=(hsv[:,:,0]>=28)&(hsv[:,:,0]<=100)&(hsv[:,:,1]>=55)&(raw[:,:,1]>raw[:,:,0])
yy,xx=np.indices((H,W))
# Attachments require being on roof/chimney or upper wall, never a horizontal lawn under the house.
roof_attached=green & (roof|chimney)&(yy<79)
wall_ivy=green&wall&(yy>=80)&(yy<115)&(xx>=67)&(xx<=182)
attached=(roof_attached|wall_ivy)&gross_body
# A defensible conservative structural cutter removes all independent foot-level green;
# y >=136 retains ONLY stair stones in the central x111..158 span.
forbidden_lower=(yy>=132)&((xx<110)|(xx>162))
forbidden_green_foot=(yy>=115)&green
forbidden_background=(~gross_body)|(forbidden_lower&~chimney)|(forbidden_green_foot&~attached)
# Anything below 146 is detached lawn or irrelevant world source, except no part of chimney there.
forbidden_background |= (yy>=149)
retain=gross_body&~forbidden_background
body=retain&~attached
growth=retain&attached
# independent barrel props are extracted as separate candidates, but NOT included in final house object.
# Barrel polygons avoid the original lawn and are evaluated separately.
barrels=polygon([(165,124),(173,117),(189,117),(197,127),(202,140),(193,150),
                 (184,150),(178,142),(165,141)])|polygon([(191,118),(199,112),(211,115),
                 (219,123),(221,141),(214,152),(201,151),(196,141)])
barrels &= alpha&~green&(yy<151)
def owned(name,m):
 pixels=raw.copy();pixels[~m]=0;png(name,pixels);return pixels
a=owned('HOUSE_BODY_NO_GROUND.png',body)
b=owned('HOUSE_ATTACHED_MOSS_VINES.png',growth)
c=owned('BARRELS_STANDALONE_CANDIDATE.png',barrels)
combined=raw.copy();combined[~retain]=0;png('HOUSE_STRICT_GROUND_EXCLUSIVE_CANDIDATE.png',combined)
maskpng('FORBIDDEN_ORIGINAL_GROUND_SEMANTIC_MASK.png',forbidden_background & alpha)
maskpng('HOUSE_BODY_OWNER.png',body)
maskpng('ATTACHED_GROWTH_OWNER.png',growth)
maskpng('BARREL_OWNER_STANDALONE.png',barrels)
maskpng('UNCERTAIN_EXCLUDED_SOURCE_PIXELS.png',alpha&~retain)
# Scene proof: source alpha owner no overlap, all retained RGBA byte exact.
assert np.array_equal(np.asarray(Image.alpha_composite(Image.fromarray(a,'RGBA'),Image.fromarray(b,'RGBA'))),combined)
assert not np.any(body&growth)
assert not np.any(retain&forbidden_background)
assert np.array_equal(combined[retain],raw[retain]) and np.all(combined[~retain]==0)
ground=Image.open(s/'GROUND_B.png').convert('RGBA');assert ground.size==(544,416)
before=ground.copy();before.alpha_composite(src,(12,48))
after=ground.copy();after.alpha_composite(Image.fromarray(combined,'RGBA'),(12,48))
before.save(o/'OLD_HOUSE_AND_GROUND.png')
after.save(o/'STRICT_HOUSE_AND_GROUND.png')
actor=Image.open(s/'ACTOR1.png').convert('RGBA')
withactor=after.copy();withactor.alpha_composite(actor,(139-16,225-32))
withactor.save(o/'STRICT_HOUSE_1X_ACTOR.png')
contact=Image.new('RGB',(1088,416));contact.paste(before.convert('RGB'),(0,0));contact.paste(after.convert('RGB'),(544,0))
contact.save(o/'BEFORE_AFTER_GROUND_EXCLUSIVE_1X.png')
big=Image.new('RGB',(261*8,183*4),(0,0,0))
for idx,layer in enumerate([raw,combined]):
 bg=Image.new('RGBA',(W,H),(0,0,0,0));dr=ImageDraw.Draw(bg)
 for y in range(0,H,8):
  for x in range(0,W,8):dr.rectangle((x,y,x+7,y+7),fill=((65,65,66,255) if((x//8+y//8)%2) else (145,145,146,255)))
 bg.alpha_composite(Image.fromarray(layer,'RGBA'))
 big.paste(bg.resize((W*4,H*4),Image.Resampling.NEAREST).convert('RGB'),(idx*W*4,0))
big.save(o/'BEFORE_AFTER_SOURCE_CHECKER_4X.png')
# Strict gate: deliberate ground injection must fail even though its PNG has valid RGBA.
def forbidden_count(rendered):return int(np.count_nonzero((rendered[:,:,3]>0) & forbidden_background))
observed=forbidden_count(combined)
assert observed==0
soil=np.asarray(ground.crop((260,220,276,236))).copy()
fake=combined.copy();fake[147:163,15:31]=soil
injected=forbidden_count(fake)
assert injected>=180,('negative source terrain did not trigger',injected)
png('NEGATIVE_INJECTED_GROUND_DO_NOT_USE.png',fake)
# The audit DOES NOT certify semantic perfection; hard gate eliminates explicitly-defined source ground,
# and unresolved source regions stay excluded. Human must inspect retained moss.
oldn=int(alpha.sum());newn=int(retain.sum());n_excluded=int((alpha&~retain).sum())
qa={
 'rule':'FS_GROUND_EXCLUSIVE_OWNERSHIP_RULE_V1',
 'candidate':'HOUSE_STRICT_GROUND_EXCLUSIVE_CANDIDATE',
 'status':'GROUND_OWNERSHIP_RESTRICTED_TECH_PASS__HUMAN_ART_PENDING',
 'original_source_RGBA_sha256':hashlib.sha256((s/'HOUSE_R3A_BASE.png').read_bytes()).hexdigest(),
 'original_nontransparent_pixels':oldn,'strict_house_nontransparent_pixels':newn,
 'excluded_original_ground_or_uncertain_pixels':n_excluded,
 'structure_pixels':int(body.sum()),'attached_moss_vines_pixels':int(growth.sum()),
 'separate_barrels_provisional_pixels':int(barrels.sum()),
 'object_forbidden_ground_overlap_pixels':observed,'negative_injected_ground_detected_pixels':injected,
 'source_kept_RGBA_exact':True,'ground_unchanged':True,'art_human_gate':'PENDING',
 'uncertainty':'Source architecture and ivy may be jagged at contact line; verify human at 1x/4x. Discarded original flowers/lawn are not promoted to object assets.',
 'native_VX_gameexe':'NOT_RUN'}
(r/'QA_GROUND_EXCLUSIVE_R4.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({k:qa[k] for k in ('original_nontransparent_pixels','strict_house_nontransparent_pixels','excluded_original_ground_or_uncertain_pixels','structure_pixels','attached_moss_vines_pixels','separate_barrels_provisional_pixels','object_forbidden_ground_overlap_pixels','negative_injected_ground_detected_pixels','status')},ensure_ascii=False))
