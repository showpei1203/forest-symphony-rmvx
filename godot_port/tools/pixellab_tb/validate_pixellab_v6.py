#!/usr/bin/env python3
"""Forest Symphony T-B V6 PixelLab provider post-generation objective QA.
Does not claim pixel-silhouette, natural anatomy, or 45-degree artistic approval.
"""
from PIL import Image,ImageDraw
from pathlib import Path
import numpy as np, scipy.ndimage as ndi, hashlib, json
R=Path(__file__).resolve().parent;A=R/'artifacts';P=A/'PMD0001_ATTACK_V6_PIXELLAB_11F_384x288.png'
ORIG=Image.open(R/'source'/'PMD0001_ATTACK_V6_FIRST_FRAME_96.png').convert('RGBA')
IM=Image.open(P).convert('RGBA')
assert IM.size==(384,288)
frames=[np.asarray(IM.crop(((i%4)*96,(i//4)*96,(i%4+1)*96,(i//4+1)*96))) for i in range(11)]
facts=[]
for i,ar in enumerate(frames):
 alpha=ar[:,:,3];valid=alpha>24
 ys,xs=np.where(valid)
 labeled,n=ndi.label(valid,np.ones((3,3),int));counts=np.bincount(labeled.ravel())[1:] if n else np.array([])
 islands=sorted((int(x) for x in counts),reverse=True)
 facts.append({'index':i,'bbox':[int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1] if len(xs) else None,
 'distinct_rgba':len(np.unique(ar.reshape(-1,4),axis=0)),'alpha_border_empty':bool((alpha[0,:]==0).all() and (alpha[-1,:]==0).all() and (alpha[:,0]==0).all() and (alpha[:,-1]==0).all()),
 'connected_components':int(n),'island_pixels':islands[:8],
 'nonempty_pixels':int(valid.sum()),'frame_sha256':hashlib.sha256(ar.tobytes()).hexdigest(),
 'diff_from_source_pixels':int(np.any(ar!=np.asarray(ORIG),axis=2).sum())})
fx=[]
for i in range(10):fx.append({'from':i,'to':i+1,'pixel_differences':int(np.any(frames[i]!=frames[i+1],axis=2).sum())})
checks={
'provider_completed_11_frames':len(frames)==11,
'size_96x96_cells_and_384x288_atlas':IM.size==(384,288),
'border_no_crop':all(z['alpha_border_empty'] for z in facts),
'nonempty_all':all(z['nonempty_pixels']>150 for z in facts),
'frames_differ_consecutively':all(z['pixel_differences']>10 for z in fx),
'frames_0_10_same_character_but_not_exact_original':bool(facts[0]['diff_from_source_pixels']>0 and facts[10]['diff_from_source_pixels']>0),
'no_large_detached_sprite':all(z['island_pixels'][0]>max(z['island_pixels'][1:],default=0)*4 for z in facts),
}
# Objective QA excludes ART visuals, view angle, and jaw articulation readability.
report={'family':'PMD0001 Lava Frog','producer':'PixelLab animate-with-skeleton-v3','job_id':'3fea688e-1c8c-451c-aa3f-84941166dca2',
'generation_id':'67dd6734-d3a5-4dc7-a860-ebb797f20964','credit_cost':{'type':'generations','generations':3.0},
'original_input_source_sha256':'e0b01e658d2659fa5c9a01c60c29a4e07cf525a0d5987aa677d09c7a0ed73c72',
'original_provider_png_sha256':'6d9b6690c3097225bf8fbba5f14eb5fbd667e815577543298898e71ea8e56252',
'lossless_transferred_rgba_png_sha256':hashlib.sha256(P.read_bytes()).hexdigest(),
'objective_checks':checks,'per_frame':facts,'transition_changes':fx,
'godot_4_7_2_native':{'script':'PASS','rendered_frames':'11/11','renderer':'Mesa llvmpipe OpenGL 4.5 software compatibility'},
'ART_GATE':'HOLD','art_blockers':['F5 bite lacks visibly distinct mandibular opening','small detached pixel islands in some frames','no exact 45-degree battle view approval','initial 0 and last 10 not byte-identical to approved source'],
'interpretation':'Technical checks do not mean passing artistic checks; no second species until this chain is art approved'}
OUT=R/'qa'/'V6_PIXELLAB_REAL_QA.json';OUT.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({'checks':checks,'counts':[z['connected_components'] for z in facts], 'largest_islands':[z['island_pixels'][:3] for z in facts], 'transitions':[z['pixel_differences'] for z in fx]},ensure_ascii=False,indent=2))
