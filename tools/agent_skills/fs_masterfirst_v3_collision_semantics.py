#!/usr/bin/env python3
"""FS Master-first V3: collision-semantic revision + reproducible probe evidence.
Only original frozen master/C2 source alpha, nothing independently repainted.
Native VX gate is NEVER claimed by this script.
"""
import json, hashlib, shutil
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont

src=Path('/mnt/data/FS_MASTER_FIRST_V2_20261107')
out=Path('/mnt/data/FS_MASTER_FIRST_V3_20261107')
if out.exists():
    raise SystemExit('FAIL-CLOSED: V3 destination exists')
out.mkdir()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
full=src/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png'
master=np.asarray(Image.open(full).convert('RGB'))
assert master.shape==(928,1280,3)
masknames=['LEFT_HOUSE_ROOF','RIGHT_HOUSE_ROOF','LEFT_TREE_CANOPY','LOWER_RIGHT_TREE_CANOPY']
masks={n:np.asarray(Image.open(src/(n+'_ALPHA_GRABCUT_REFINED_DRAFT.png')).convert('L'))>127 for n in masknames}
ma=np.maximum.reduce([m.astype(np.uint8)*255 for m in masks.values()])
oldq=json.loads((src/'FS_MASTER_FIRST_V2_QA.json').read_text('utf8'))
oldb=np.array(oldq['collision_grid_29x40'],dtype=np.uint8)
assert oldb.shape==(29,40)
b=oldb.copy()
# Fix known visual-semantic false positive: the proposed roof-overlapped tiles are not standing places.
# Only use this constrained rule for identified house footprints, not all forest canopy alpha.
changes=[]
for name,rect in [('LEFT_HOUSE_ROOF',(4,3,15,12)),('RIGHT_HOUSE_ROOF',(24,3,35,12))]:
    xmin,ymin,xmax,ymax=rect
    for ty in range(ymin,ymax):
        for tx in range(xmin,xmax):
            y0,y1=ty*32,(ty+1)*32;x0,x1=tx*32,(tx+1)*32
            coverage=float(masks[name][y0:y1,x0:x1].mean())
            # block tile if its roof artwork intersects a meaningful area; keep plan limited to roofs.
            if coverage>=0.16 and b[ty,tx]==0:
                b[ty,tx]=1;changes.append({'tile':[tx,ty],'house':name,'roof_tile_coverage':round(coverage,3)})
# Independent check: V2 'walkable on roof' was a bad gate. Get covered fraction and free candidates.
def frac(arr,x,y):
    px=x*32+16;feet=(y+1)*32
    body=arr[feet-30:feet,px-11:px+12]
    assert body.shape==(30,23)
    return float(body.mean())
def step_case(name,orig,dest):
    sx,sy=orig;dx,dy=dest
    assert abs(sx-dx)+abs(sy-dy)==1
    assert 0<=sx<40 and 0<=dx<40 and 0<=sy<29 and 0<=dy<29
    assert b[sy,sx]==0 and b[dy,dx]==0,(name,orig,dest,'not actually draft walkable')
    v0,v1=frac(masks[name],sx,sy),frac(masks[name],dx,dy)
    assert v0>=.55 and v1<=.15,(name,v0,v1)
    return {'object':name,'start':[sx,sy],'end':[dx,dy], 'start_overlap':round(v0,5), 'end_overlap':round(v1,5), 'start_collision_free':True, 'end_collision_free':True, 'status':'CANDIDATE_ENGINE_UNTESTED'}
# Two genuine in/out attempts for canopy at positions away from trunk/house footprints.
steps=[step_case('LEFT_TREE_CANOPY',(10,16),(10,17)),
       step_case('LOWER_RIGHT_TREE_CANOPY',(33,24),(32,24))]
controls=[]
for tx,ty in [(20,15),(24,24),(14,12)]:
    controls.append({'tile':[tx,ty], 'walkable_draft':bool(b[ty,tx]==0), 'actor_overlay_coverage':round(float(frac(ma>127,tx,ty)),5)})
assert all(q['walkable_draft'] and q['actor_overlay_coverage']<=.001 for q in controls)
roofpos={}
for name in ['LEFT_HOUSE_ROOF','RIGHT_HOUSE_ROOF']:
    positives=[(frac(masks[name],tx,ty),tx,ty) for ty in range(29) for tx in range(40) if b[ty,tx]==0 and frac(masks[name],tx,ty)>.2]
    roofpos[name]={'walkable_actor_candidates_with_any_roof_overlap':len(positives),
                   'max_walkable_overlap':round(max((v for v,*_ in positives),default=0),5),
                   'physical_eligibility':'UNVERIFIED; no roof-actor pass unless roof eave depth proven',
                   'engine_only_teleport_probe':([6,5] if 'LEFT' in name else [27,5])}
# Actual PNGs: only mask source RGB. alpha binary; CV C2 already exists and may remain inaccurate.
shutil.copy2(full,out/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png')
par=np.zeros((928,1280,4),np.uint8)
par[:,:,:3]=master;par[:,:,3]=ma
Image.fromarray(par,'RGBA').save(out/'VX_RUNTIME_4OBJECT_PAR_C2_SOURCE_RGB_UNVERIFIED.png')
for name in masknames:
    data=np.zeros_like(par);data[:,:,:3]=master;data[:,:,3]=masks[name]*255
    Image.fromarray(data,'RGBA').save(out/(name+'_SOURCE_REGISTERED_FULL_ALPHA_DRAFT.png'))
# Visual 1x witnesses; no false green C2 acceptance shown.
vis=Image.fromarray(master).convert('RGB');d=ImageDraw.Draw(vis)
for ty in range(29):
    d.line((0,ty*32,1279,ty*32),fill=(255,255,255),width=1)
for tx in range(40):
    d.line((tx*32,0,tx*32,927),fill=(255,255,255),width=1)
for ty in range(29):
    for tx in range(40):
        if b[ty,tx] and (3<=ty<=12 and (4<=tx<=15 or 24<=tx<=35)):
            d.rectangle((tx*32+3,ty*32+3,tx*32+29,ty*32+29),outline=(230,48,36),width=2)
for i,p in enumerate(steps):
    for key,color in [('start',(255,235,50)),('end',(50,235,88))]:
        tx,ty=p[key];d.rectangle((tx*32+4,ty*32+3,tx*32+27,ty*32+29),outline=color,width=3)
        d.text((tx*32,max(0,ty*32-12)),f'{i+1}:{key}',fill=(255,255,255),stroke_width=1,stroke_fill=(0,0,0))
for q in controls:
    tx,ty=q['tile'];d.rectangle((tx*32+8,ty*32+7,tx*32+23,ty*32+25),outline=(35,225,252),width=2)
vis.save(out/'V3_CANDIDATE_32PX_ROOF_BLOCKS_AND_CANOPY_EXITS_1X.png')
# Render source RGB actor stand-in with actual masks to make pixel-overlap easy to inspect; NOT native engine screenshots.
def standin(tile):
    x,y=tile;cx=x*32+16;feet=(y+1)*32
    a=np.zeros((928,1280,4),np.uint8)
    yy,xx=np.ogrid[0:928,0:1280]
    ell=(((xx-cx)/11.)**2+((yy-(feet-17))/16.)**2<=1)&(yy<feet)
    a[ell,:3]=[225,60,78];a[ell,3]=255
    return Image.fromarray(a,'RGBA')
shots=[]
for p in steps:
    for pos in ['start','end']:
        actor=standin(p[pos]);base=Image.fromarray(master,'RGB').convert('RGBA')
        base.alpha_composite(actor)
        off=base.convert('RGB')
        base.alpha_composite(Image.fromarray(par,'RGBA'))
        on=base.convert('RGB')
        dpx=int(np.any(np.array(off)!=np.array(on),axis=2).sum())
        shots.append({'object':p['object'],'position':pos,'tile':p[pos],'standin_changed_px':dpx,'native':False})
        if pos=='start':
            c=Image.new('RGB',(1088,416));xx,yy=p[pos][0]*32,p[pos][1]*32
            # Fixed crop around actor not a faux native VX screen claim.
            bounds=(max(0,min(1280-544,xx-272)),max(0,min(928-416,yy-208)))
            crop=(bounds[0],bounds[1],bounds[0]+544,bounds[1]+416)
            c.paste(off.crop(crop),(0,0));c.paste(on.crop(crop),(544,0))
            c.save(out/(p['object']+'_STANDIN_NOT_NATIVE_OFF_ON.png'))
# Save auditable collision plan; no claim of semantic full-map acceptance.
qa={
 'stage':'FS_MASTER_FIRST_V3_CANDIDATE_NATIVE_PLAN',
 'source_master_sha256':sha(full),
 'new_master_sha256':sha(out/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png'),
 'unchanged_frozen_master':True,'canvas':[1280,928],'tile_size':32,'grid':[40,29],
 'C2_mask_source':'FS_MASTER_FIRST_V2_20261107',
 'C2_mask_pixels':{k:int(v.sum()) for k,v in masks.items()},
 'source_RGB_exact_under_alpha':bool(np.array_equal(par[ma>0,:3],master[ma>0,:3])),
 'master_plus_PAR_rgb_diff_pixels':0,
 'collision_draft_v2_blocked':int(oldb.sum()),'collision_draft_v3_blocked':int(b.sum()),
 'v2_false_walkable_roof_tiles_corrected':len(changes),
 'rooftop_rejections':changes,
 'full_collision_art_gate':'NOT_REVIEWED',
 'roofs':roofpos,
 'canopy_walkable_dynamic_candidates':steps,
 'clear_controls':controls,
 'simulated_25px_actor_tests':shots,
 'engine_test':'NOT_RUN', 'human_semantics':'UNVERIFIED',
 'warning':'Overlays are current C2 semantic proposals; zero RGB diff is automatic and not semantic acceptance. Roof teleport tile is blocked and cannot count as a gameplay route.',
 'formal_seal':'NO'
}
(out/'FS_MASTER_FIRST_V3_PROBE_PLAN_QA.json').write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding='utf8')
(out/'FS_MASTER_FIRST_V3_COLLISION_GRID_29x40.json').write_text(json.dumps({'blocked':b.tolist(),'reference':'DRAFT from V2, corrected house roof collision tile exposure','blocked_count':int(b.sum()),'walkable_count':int(b.size-b.sum()),'full_visual_audit':'NOT DONE'},ensure_ascii=False,indent=2),encoding='utf8')
print(json.dumps({k:qa[k] for k in ['v2_false_walkable_roof_tiles_corrected','collision_draft_v3_blocked','roofs','canopy_walkable_dynamic_candidates','clear_controls','simulated_25px_actor_tests']},ensure_ascii=False,indent=2))