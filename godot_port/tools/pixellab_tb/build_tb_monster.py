#!/usr/bin/env python3
"""T-B source-locked candidate builder. Private image inputs; outputs remain private.

Important: This is a deterministic, procedural fallback, NOT a PixelLab API generation.
It uses existing PMD0001/0002/0003 user-sourced art and historical PMD0001
PixelLab 3-frame Waiting sheet. Does NOT rewrite PMD's native XML or atlases.
"""
from __future__ import annotations
import argparse, hashlib, json, math
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

SOURCE_NAMES = {
    "PMD0001": "PMD0001_SOURCE_CONCEPT128.png",
    "PMD0002": "PMD0002_SOURCE_CONCEPT128.png",
    "PMD0003": "CONCEPT_REFERENCE_PMD0003_128.png",
}
SRC_DRIVE = {
    "PMD0001": "1uW0MbruUOHjKu7f_coEr1ebuUQFnucdh",
    "PMD0002": "1xw11JS2wR1tjxi-q2tb1DZeU1bQNUdb7",
    "PMD0003": "1p3CFtpD2lpLNQmweFL1goZwV4xF0lgYO",
    "PMD0001_HISTORICAL_IDLE": "1An7EAOsy32v8bPuWr6YbOZSjEIvPV7EE",
}
FRAME = 64
SOURCE_SCALE = .48   # same world scale throughout the family
FOOT = 59


def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def fit_existing(source: Image.Image, *, source_scale=SOURCE_SCALE, foot=FOOT, dx=0, dy=0):
    source = source.convert('RGBA')
    cropbox = source.getbbox()
    if not cropbox: raise ValueError('Empty source alpha')
    crop = source.crop(cropbox)
    w, h = round(crop.width*source_scale), round(crop.height*source_scale)
    if max(w, h)>FRAME-4: raise ValueError('Source will not fit; never silently crop: '+str((w,h)))
    crop = crop.resize((w,h), Image.Resampling.NEAREST)
    out = Image.new('RGBA', (FRAME,FRAME))
    x = (FRAME-w)//2+dx
    y = foot-h+dy
    if x<2 or y<2 or x+w>FRAME-2 or y+h>FRAME-2:
        raise ValueError(f'CROP_BLOCKER bbox={(x,y,x+w,y+h)}')
    out.alpha_composite(crop,(x,y))
    return out


def anchor_bbox(im):
    a=im.getchannel('A')
    return a.getbbox()


def atlas(frames, ncol=4):
    nrow=math.ceil(len(frames)/ncol)
    out=Image.new('RGBA',(FRAME*ncol,FRAME*nrow))
    for i,frame in enumerate(frames):
        if frame.size!=(FRAME,FRAME): raise ValueError('bad frame')
        out.alpha_composite(frame,((i%ncol)*FRAME,(i//ncol)*FRAME))
    return out


def body_pose(master, compress=1.0, dy=0, dx=0, lean=0):
    # Body squash and re-centering preserve family silhouette and feet contact.
    box=master.getbbox()
    if box is None: raise ValueError('empty master')
    crop=master.crop(box)
    new_h=max(1,round(crop.height*compress))
    crop=crop.resize((crop.width,new_h),Image.Resampling.NEAREST)
    new=Image.new('RGBA',(FRAME,FRAME))
    x=box[0]+dx
    y=FOOT-new_h+dy
    if lean:
        # Horizontal per-row lunge, near hips anchored. Transform remains within frame.
        warped=Image.new('RGBA',(crop.width+abs(lean),crop.height))
        for yy in range(crop.height):
            row=crop.crop((0,yy,crop.width,yy+1))
            warp=round(lean*(1-yy/max(1,crop.height)))
            warped.alpha_composite(row,(max(0,warp),yy))
        crop=warped
    if min(x,y)<2 or x+crop.width>FRAME-2 or y+crop.height>FRAME-2:
        raise ValueError(f'Attack body cropped at {x},{y} size {crop.size}')
    new.alpha_composite(crop,(x,y))
    return new


def add_lava_bolt(im, pos, trail=0):
    out=im.copy(); d=ImageDraw.Draw(out)
    x,y=pos
    # Even the early ejection has animation-independent visual semantics.
    d.ellipse((x-3,y-2,x+3,y+2),fill=(255,117,21,255))
    d.rectangle((x-1,y-1,x+1,y),fill=(255,230,69,255))
    if trail>0:
        for i in range(1,trail+1):
            d.point((x-4-3*i,y+i%2),fill=(222,70,19,245))
    return out


def attack_frames(master):
    # 8 meaningful key poses: crouch / crouch deeper / lift / lunge /
    # spit / projectile flight / recovery / rest. NOT PixelLab authored.
    poses=[(.94,0,0,0),(.86,0,0,0),(.98,-3,1,0),(1.0,-5,2,2),
           (.95,-3,1,3),(.92,-1,0,0),(.97,0,0,0),(1.,0,0,0)]
    frames=[body_pose(master,compress=scale,dy=dy,dx=dx,lean=lean)
            for scale,dy,dx,lean in poses]
    # Ejection right of head for the canonical southeast/right-facing 3/4 view.
    frames[4]=add_lava_bolt(frames[4],(51,37),trail=1)
    frames[5]=add_lava_bolt(frames[5],(57,35),trail=2)
    return frames


def idle_frames(historical_provider, static_base):
    # Historical genuine PixelLab Waiting 3F sheet, not a newly generated job.
    if historical_provider.size!=(384,128):
        raise ValueError(f'Provider sheet is not the documented 3x128 image: {historical_provider.size}')
    frames=[]
    for i in range(3):
        crop=historical_provider.crop((i*128,0,(i+1)*128,128))
        frames.append(fit_existing(crop))
    if any(not f.getbbox() for f in frames): raise ValueError('empty provider frame')
    return frames


def make_preview(statics, idle, attacks):
    # Evidence preview, not Godot renderer screenshot.
    from PIL import ImageFont
    bg=(24,30,34,255)
    out=Image.new('RGBA',(768,420),bg)
    d=ImageDraw.Draw(out)
    labels=['PMD0001 / juvenile','PMD0002 / basalt','PMD0003 / molten core']
    for j,(name, im) in enumerate(statics.items()):
        big=im.resize((160,160),Image.Resampling.NEAREST)
        out.alpha_composite(big,(45+j*245,32))
        d.text((48+j*245,200),labels[j],fill='#eeeeee')
    d.text((16,250),'PMD0001 Idle: historical PixelLab 3F', fill='#eeeeee')
    for k,im in enumerate(idle):
        out.alpha_composite(im.resize((96,96),Image.Resampling.NEAREST),(18+k*110,270))
    d.text((390,250),'PMD0001 Attack: procedural 8F (sample)',fill='#eeeeee')
    for k,im in enumerate(attacks[:3]):
        out.alpha_composite(im.resize((96,96),Image.Resampling.NEAREST),(410+k*110,270))
    return out


def build(src_dir, out_dir):
    src_dir=Path(src_dir); out_dir=Path(out_dir); out_dir.mkdir(exist_ok=True,parents=True)
    sources={key:src_dir/name for key,name in SOURCE_NAMES.items()}
    sources['PMD0001_HISTORICAL_IDLE']=src_dir/'PMD0001_WAITING_3FRAME_PROVIDER_SHEET.png'
    for file in sources.values():
        if not file.is_file(): raise FileNotFoundError(str(file))
    statics={id:fit_existing(Image.open(sources[id])) for id in SOURCE_NAMES}
    frames_idle=idle_frames(Image.open(sources['PMD0001_HISTORICAL_IDLE']).convert('RGBA'),statics['PMD0001'])
    frames_attack=attack_frames(statics['PMD0001'])
    for i,(name,im) in enumerate(statics.items()): im.save(out_dir/f'{name}_STATIC_64.png')
    atlas(frames_idle,3).save(out_dir/'PMD0001_IDLE_3F_192x64.png')
    atlas(frames_attack,4).save(out_dir/'PMD0001_ATTACK_8F_256x128.png')
    make_preview(statics,frames_idle,frames_attack).convert('RGB').save(out_dir/'PMD_FAMILY_SOURCE_LOCKED_PREVIEW.png')
    manifest={
        'schema':'fs-tb-monster-v1', 'status':'CANDIDATE_NOT_ART_APPROVED',
        'engine':'Godot 4.7.2', 'family':'PMD_lava_frog',
        'source_scale':SOURCE_SCALE,'foot_y':FOOT,'view':'historical 3/4 right-facing reference; native 45-degree still requires user art confirmation',
        'generation':{'provider':'no new PixelLab API call','model':'PROCEDURAL_SOURCE_LOCKED_FALLBACK',
            'job_id':None,'actual_generations_spent':0},
        'sources':{k:{'drive_id':SRC_DRIVE[k],'sha256':sha(v),'filename':v.name} for k,v in sources.items()},
        'stages':{},
        'animations':{
            'PMD0001_IDLE':{'file':'PMD0001_IDLE_3F_192x64.png','frames':3,'frame_size':[64,64], 'columns':3,
                'fps':4,'loop':True,'origin':'historical original PMD0001 PixelLab provider Waiting sheet; cropped/resized only'},
            'PMD0001_ATTACK':{'file':'PMD0001_ATTACK_8F_256x128.png','frames':8,'frame_size':[64,64], 'columns':4,
                'fps':9,'loop':False,'origin':'source-locked deterministic rig and pixel projectile, NOT PixelLab generation'}},
        'gates':{'source':'SOURCE_HASH_RECORDED','geometry':'SCRIPT_CHECK','godot_native':'NOT_RUN', 'art':'HOLD',
                 'family_silhouette':'REQUIRES_USER_REVIEW','45deg_view':'HOLD'},
    }
    for k,v in statics.items():
        manifest['stages'][k]={'texture':f'{k}_STATIC_64.png','bbox':anchor_bbox(v),'sha256':sha(out_dir/f'{k}_STATIC_64.png')}
    manifest['qa']={
        'static_all_64':all(im.size==(64,64) for im in statics.values()),
        'non_empty_idle':len(frames_idle)==3 and all(f.getbbox() for f in frames_idle),
        'non_empty_attack':len(frames_attack)==8 and all(f.getbbox() for f in frames_attack),
        'alpha_border_empty':all(im.getchannel('A').getbbox() and (im.getbbox()[0]>0 and im.getbbox()[1]>0 and im.getbbox()[2]<64 and im.getbbox()[3]<64) for im in list(statics.values())+frames_idle+frames_attack),
        'idle_distinct':len({f.tobytes() for f in frames_idle})>=2,
        'attack_distinct':len({f.tobytes() for f in frames_attack})>=4,
        'three_stage_distinct':len({im.tobytes() for im in statics.values()})==3,
        'note':'automated geometry only; does not prove native Godot or art approval'
    }
    for f in ('PMD0001_IDLE_3F_192x64.png','PMD0001_ATTACK_8F_256x128.png','PMD_FAMILY_SOURCE_LOCKED_PREVIEW.png'):
        manifest.setdefault('outputs_sha256',{})[f]=sha(out_dir/f)
    (out_dir/'FAMILY_MANIFEST.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    (out_dir/'QA_SUMMARY.json').write_text(json.dumps(manifest['qa'],indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    return manifest


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--source',required=True)
    parser.add_argument('--out',required=True)
    a=parser.parse_args()
    m=build(a.source,a.out)
    print(json.dumps({'stages':list(m['stages']),'animations':list(m['animations']), 'qa':m['qa']},indent=2,ensure_ascii=False))
