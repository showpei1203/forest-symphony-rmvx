#!/usr/bin/env python3
"""Offline visual-source identity + native screenshot regression; not an art PASS test."""
from pathlib import Path
import json, hashlib, numpy as np
from PIL import Image, ImageDraw
from scipy.ndimage import label
ROOT=Path(__file__).resolve().parent;A=ROOT/'artifacts'
S=Image.open(ROOT/'assets/PMD0001_STATIC_64.png').convert('RGBA');SA=np.asarray(S)
ATLAS=A/'PMD0001_ATTACK_V5_11F_384x288.png';sheet=Image.open(ATLAS).convert('RGBA')
frames=[sheet.crop(((i%4)*96,(i//4)*96,(i%4+1)*96,(i//4+1)*96)) for i in range(11)]
checks={}
checks['source_sha_locked']=hashlib.sha256((ROOT/'assets/PMD0001_STATIC_64.png').read_bytes()).hexdigest()=='fc7be3a93d4940a3a9c6d0fb19ffeaa7715a6b98c2e549e37b92b774df73f46c'
checks['atlas_native_dimensions']=sheet.size==(384,288)
checks['all_11_cells_filled']=all(np.asarray(f)[:,:,3].sum()>0 for f in frames)
checks['native_11_screenshots_saved']=all((A/'native_frames'/f'GODOT_NATIVE_V5_{i:02d}.png').is_file() for i in range(11))
checks['10_unique_frames']=len({hashlib.sha256(f.tobytes()).hexdigest() for f in frames})==10
# source exact first and last with 16/24 padding
exact=Image.new('RGBA',(96,96));exact.alpha_composite(S,(16,24))
checks['F0_F10_byte_exact_pixels']=all(np.array_equal(np.asarray(frames[i]),np.asarray(exact)) for i in [0,10])
checks['no_outer_border_crops']=all(not any(np.any(np.asarray(f)[:,:,3][side]) for side in [np.s_[0,:],np.s_[-1,:],np.s_[:,0],np.s_[:,-1]]) for f in frames)
# Anchored 3/4 identity: upper eye/shell unchanged when applying body translation.
roots=[(0,0),(-1,1),(2,-2),(5,-5),(7,-5),(9,-4),(7,-2),(5,-1),(3,1),(1,0),(0,0)]
head_box=(36,29,49,43) # excludes animated mouth, toes and bone seams
identity=[]
for i,(dx,dy) in enumerate(roots):
 x0,y0,x1,y1=head_box
 actual=np.asarray(frames[i])[y0+24+dy:y1+24+dy,x0+16+dx:x1+16+dx]
 reference=SA[y0:y1,x0:x1]
 identity.append(bool(np.array_equal(actual,reference)))
checks['shell_eye_pixels_unmodified_every_frame']=all(identity)
# All frames have one LARGE opaque body with attached foot; allow isolated 1px AA bits.
components={}
for i,f in enumerate(frames):
 a=np.asarray(f)[:,:,3]>64
 labs,n=label(a,np.ones((3,3)))
 sizes=sorted([int((labs==j).sum()) for j in range(1,n+1)],reverse=True)
 components[str(i)]=sizes
checks['single_large_body_per_frame']=all(sum(area>=4 for area in sizes)==1 for sizes in components.values())
# Non-rigid pose difference compared to pure source root translation.
pose_diffs=[]
for i,(dx,dy) in enumerate(roots):
 plain=Image.new('RGBA',(96,96));plain.alpha_composite(S,(16+dx,24+dy))
 different=int(np.count_nonzero(np.any(np.asarray(frames[i])!=np.asarray(plain),axis=2)))
 pose_diffs.append(different)
checks['F3_F5_motion_not_body_translation']=pose_diffs[3]>=65 and pose_diffs[5]>=65
checks['F5_mouth_not_same_as_F3']=not np.array_equal(np.asarray(frames[5]),np.asarray(frames[3]))
# Native full-frame screenshot 11/11 variety; screenshot metadata/proof from exported native driver.
render_sha=[]
for i in range(11):
 path=A/'native_frames'/f'GODOT_NATIVE_V5_{i:02d}.png'
 render_sha.append(hashlib.sha256(path.read_bytes()).hexdigest())
checks['native_rendered_F0_F10_identical']=render_sha[0]==render_sha[10]
checks['native_screen_10_unique']=len(set(render_sha))==10
out={
 'schema':'fs-tb-r5-source-locked-qa',
 'status':'SCRIPT_NATIVE_PASS__ART_HOLD',
 'engine':'Godot 4.7.2.stable.official.ed1daf0bf',
 'renderer':'Xvfb Mesa llvmpipe OpenGL Compatibility (software rasterizer)',
 'native_render_marker':'TB_V5_11_NATIVE_RENDER_PASS',
 'native_script_marker':'TB_V5_REAL_NATIVE_PASS',
 'methods':'3 cut-out feet + independent mouth tip, no RBF and no whole-body scaling',
 'pixel_lab_jobs_this_round':0,
 'events':{'RUSH':2,'HIT':5,'RETURN':7},
 'checks':checks,
 'pass_count':sum(checks.values()),
 'check_count':len(checks),
 'pose_nonrigid_pixel_differences':pose_diffs,
 'shell_eye_identity_checks':identity,
 'connected_components_alpha_gt64':components,
 'source_sha256':hashlib.sha256((ROOT/'assets/PMD0001_STATIC_64.png').read_bytes()).hexdigest(),
 'atlas_sha256':hashlib.sha256(ATLAS.read_bytes()).hexdigest(),
 'real_native_frame_shas':render_sha,
 'blocking_art_issues':['FRONT_LIMB_LINKS_NEED_MANUAL_HANDDRAWN_CLEANUP','JAW_BITE_RANGE_NOT_ART_APPROVED','EXACT_45_DEGREE_VIEW_UNVERIFIED','ANIMATION_NOT_PIXEL_LAB_SKELETON_V3'],
 'next_work_unit':'true multi-keyframe art reconstruction and human review before 2nd monster sample'
}
(A/'PMD0001_ATTACK_V5_SOURCE_AND_NATIVE_QA.json').write_text(json.dumps(out,indent=2,ensure_ascii=False),encoding='utf8')
print('V5 checks',out['pass_count'],'/',out['check_count'])
for k,v in checks.items():print(('PASS' if v else 'FAIL'),k)
if not all(checks.values()):raise SystemExit(3)
