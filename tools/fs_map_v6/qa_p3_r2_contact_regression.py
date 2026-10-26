from pathlib import Path
from PIL import Image
import numpy as np,json,hashlib
r=Path(__file__).resolve().parent
def rgba(name):return np.array(Image.open(r/name).convert('RGBA'))
def raw(name):return np.array(Image.open(r/name))
def sh(path):return hashlib.sha256(path.read_bytes()).hexdigest()
old=rgba('HOUSE_R1_ORIGINAL_REFERENCE.png')
clean=rgba('HOUSE_R2_CLEANED_ALPHA_CANDIDATE.png')
arch=rgba('HOUSE_ARCHITECTURE_SOURCE_MASKED.png')
flowers=rgba('HOUSE_FLOWERS_ACCESSORIES_SOURCE_MASKED.png')
remove=raw('REMOVED_BAKED_GROUND_OWNER.png')>0
ground=rgba('source/GROUND_B.png')
gout=rgba('outputs/GROUND_OPAQUE.png')
oldworld=rgba('WORLD_R1_COMPOSITE_REFERENCE.png')
newworld=rgba('outputs/WORLD_COMPOSITE_NO_ACTOR.png')
par=rgba('outputs/PAR_COMPLETE.png')
actor=rgba('source/ACTOR1.png')
grid=raw('outputs/BLOCKED_TILES_17x13.png')
qa_old=json.loads((r/'HOUSE_R2_SOURCE_OWNERSHIP_QA.json').read_text(encoding='utf8'))
qa_comp=json.loads((r/'qa/QA_R1.json').read_text(encoding='utf8'))
checks={}
def check(k,result): checks[k]=bool(result)
check('size_544x416_32px', ground.shape==(416,544,4))
check('r1_house_rgba_261x183', old.shape==(183,261,4))
check('r2_house_rgba_261x183', clean.shape==old.shape)
check('r2_retained_exact_rgba_from_r1',np.array_equal(clean[clean[:,:,3]>0],old[clean[:,:,3]>0]))
check('r2_removed_pixels_exact_6501',int(remove.sum())==6501)
check('r2_removed_are_old_alpha_and_clean_zero',bool(np.all(old[remove,3]>0) and np.all(clean[remove]==0)))
check('r2_fully_transparent_pixels_zero_rgb',bool(np.all(clean[clean[:,:,3]==0,:3]==0)))
check('r2_house_alpha_not_canvas_clipped',not bool(np.any(clean[0,:,3]) or np.any(clean[-1,:,3]) or np.any(clean[:,0,3]) or np.any(clean[:,-1,3])))
check('original_source_SHA_untouched',sh(r/'HOUSE_R1_ORIGINAL_REFERENCE.png')=='4362a04a19f95ea2aec5b3ff1b9a82f5a1f6d7394e58ae5d13181c8cc4944b6b')
check('r2_clean_source_byte_identity',sh(r/'HOUSE_R2_CLEANED_ALPHA_CANDIDATE.png')==sh(r/'source/OCHRE_HOUSE_R2_CLEAN.png'))
check('architecture_flora_no_double_ownership',bool(not np.any((arch[:,:,3]>0)&(flowers[:,:,3]>0))))
test=Image.alpha_composite(Image.fromarray(arch,'RGBA'),Image.fromarray(flowers,'RGBA'))
check('arch_plus_floral_recompose_clean_RGBA',np.array_equal(np.asarray(test),clean))
check('ground_source_unchanged',np.array_equal(ground,gout))
check('ground_fully_opaque',bool(np.all(ground[:,:,3]==255)))
check('actor_actual_32x32',actor.shape==(32,32,4) and Image.fromarray(actor,'RGBA').getchannel('A').getbbox()==(2,0,30,32))
check('par_extracted_alpha_present',bool(np.count_nonzero(par[:,:,3])>0))
check('scene_pixel_placement_correct',np.array_equal(np.asarray(Image.alpha_composite(Image.fromarray(ground,'RGBA'),Image.fromarray(par,'RGBA'))),newworld))
outside=np.ones((416,544),bool);outside[48:231,12:273]=False
check('R1_R2_world_only_house_scope_changes',np.array_equal(oldworld[outside],newworld[outside]))
under=Image.fromarray(ground,'RGBA');under.alpha_composite(Image.fromarray(clean,'RGBA'),(12,48))
underarr=np.asarray(under)[48:231,12:273]
check('removed_underpaint_reveals_exact_ground',np.array_equal(underarr[remove],ground[48:231,12:273][remove]))
check('15_grid_cells_blocked',int(np.count_nonzero(grid))==15*32*32)
check('door_front_one_cell_walkable',int(grid[7*32+16,4*32+16])==0)
check('house_real_wall_blocked',int(grid[5*32+16,4*32+16])==255)
check('native_vx_not_claimed',qa_comp['native_vx']=='NOT_RUN')
check('human_art_not_claimed',qa_comp.get('source_art_pass') is False)
for typ in ('SHORT','SOFTLONG'):
 shadow=rgba('CONTACT_SHADOW_'+typ+'.png')
 scene=rgba('WORLD_CONTACT_SHADOW_'+typ+'.png')
 image=Image.alpha_composite(Image.alpha_composite(Image.fromarray(ground,'RGBA'),Image.fromarray(shadow,'RGBA')),Image.fromarray(par,'RGBA'))
 check(typ+'_separate_shadow_no_ground_mutation',np.array_equal(np.asarray(image),scene))
 check(typ+'_shadow_only_under_house',bool(np.count_nonzero(shadow[:,:,3])>0 and not np.any(shadow[:165,:,3])))
check('negative_tree_pixel_shift_registered',qa_comp['negative_tree_shift_changed_pixels']>=1)
check('R2_source_ownership_qa_human_pending',qa_old['candidate_only'].startswith('HUMAN_'))
npass=sum(checks.values())
result={
 'schema':'FS_V6_P3_R2_FAIL_CLOSED_QA','passed':npass,'total':len(checks),
 'result':'PASS_TECH_ONLY' if npass==len(checks) else 'FAIL_TECH',
 'checks':checks,
 'baked_ground_pixels_removed':int(remove.sum()),
 'R1_R2_composite_changed_pixels':int(np.count_nonzero(np.any(oldworld!=newworld,axis=2))),
 'human_art':'PENDING','native_vx':'NOT_RUN','house_contact':'VISUAL_REVIEW_REQUIRED',
 'declined_promotion':'Technical proof and exact alpha ownership are not a substitute for high-fidelity human art'
}
(r/'QA_P3_R2_REPORT.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf8')
print(json.dumps({'passed':npass,'total':len(checks),'result':result['result'],'r1_r2_diff_pixels':result['R1_R2_composite_changed_pixels']}))
if npass<len(checks):
 print('FAILS',[k for k,v in checks.items() if not v])
 raise SystemExit(2)
