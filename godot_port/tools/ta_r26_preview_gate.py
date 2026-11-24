#!/usr/bin/env python3
"""Forest Symphony T-A R26: source-locked 5-key PixelLab preview ingest and QA.

This script NEVER calls an image model and NEVER claims artistic approval.
`prepare` makes an explicitly labelled five-pose SKELETON GUIDE, not 5 sprite frames.
`ingest` accepts exactly five real, user/provider authored 64px PNGs and produces
1x/4x previews, a GIF and technical validation for HUMAN ART REVIEW.
"""
from __future__ import annotations
import argparse, hashlib, io, json, math, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

SOURCE_SHA = '70a8e6aaddbad052e3ea12fe8def8be90fe8932f89154da3c93da98edfddea1e'
KEYS=(0,3,5,7,9)
N=64
LABELS=('F00 準備','F03 蓄力','F05 出手','F07 命中','F09 收招')
FONT='/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'

def sha(data:bytes)->str:return hashlib.sha256(data).hexdigest()
def check_source(path:Path)->Image.Image:
    b=path.read_bytes()
    if sha(b)!=SOURCE_SHA:raise ValueError('A62 APPROVED SOURCE SHA MISMATCH')
    im=Image.open(io.BytesIO(b)).convert('RGBA')
    if im.size!=(N,N):raise ValueError('A62 source not 64x64')
    return im

def font(n:int):
    try:return ImageFont.truetype(FONT,n)
    except OSError:return ImageFont.load_default()

def rgba_bbox(im):return im.getchannel('A').getbbox()
def rgb_coverage(im):return sum(1 for a in im.getchannel('A').tobytes() if a>0)

def draw_checker(canvas:Image.Image,left:int,top:int,cell:int=8,width:int=64,height:int=64):
    d=ImageDraw.Draw(canvas)
    for y in range(height):
        for x in range(width):
            if ((x//cell)+(y//cell))%2:d.point((left+x,top+y),fill=(217,224,233,255))
            else:d.point((left+x,top+y),fill=(240,243,246,255))

def paint_preview(frames, out:Path, *, notes:list[str]|None=None, ghost:bool=False):
    out.mkdir(parents=True,exist_ok=True)
    display=Image.new('RGBA',(N*5,N),(0,0,0,0))
    for i,im in enumerate(frames):display.alpha_composite(im,(i*N,0))
    display.save(out/'R26_5POSE_NATIVE_1X.png')
    display.resize((N*5*4,N*4),Image.Resampling.NEAREST).save(out/'R26_5POSE_NEAREST_4X.png')
    canvas=Image.new('RGBA',(5*192,278),(255,255,255,255));d=ImageDraw.Draw(canvas)
    for i,im in enumerate(frames):
        x=i*192
        draw_checker(canvas,x+32,57)
        canvas.alpha_composite(im,(x+32,57))
        canvas.alpha_composite(im.resize((128,128),Image.Resampling.NEAREST),(x+32,132))
        d.text((x+8,11),LABELS[i],font=font(21),fill=(12,28,43,255))
        d.text((x+9,38),('SKELETON PLAN' if ghost and i else 'SOURCE F00' if ghost else 'PIXEL ART CANDIDATE'),font=font(9),fill=(80,96,112,255))
    canvas.convert('RGB').save(out/'R26_REVIEW_CONTACT.jpg',quality=93)
    durations=[230,240,140,240,310]
    frames[0].save(out/'R26_KEYPOSE_PREVIEW.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2,optimize=False)
    return [str(x.name) for x in sorted(out.iterdir())]

def pose_plan():
    # Pixel coordinates from R24 validated IK targets; only used as a pose brief.
    return [
      {'frame':0,'hand':[40,37],'hips_deg':0,'chest_deg':0,'blade_deg':-75,'phase':'ready'},
      {'frame':3,'hand':[31,24],'hips_deg':-8,'chest_deg':-11,'blade_deg':-165,'phase':'windup'},
      {'frame':5,'hand':[38,25],'hips_deg':-4,'chest_deg':-6,'blade_deg':-105,'phase':'drive'},
      {'frame':7,'hand':[47,33],'hips_deg':10,'chest_deg':19,'blade_deg':20,'phase':'impact'},
      {'frame':9,'hand':[42,42],'hips_deg':8,'chest_deg':10,'blade_deg':108,'phase':'followthrough'}
    ]

def _stick_pose(p):
    # Not a pixel-art generator. Technical diagram; never use in game.
    im=Image.new('RGBA',(N,N),(0,0,0,0));d=ImageDraw.Draw(im)
    h=float(p['hips_deg'])*math.pi/180;c=float(p['chest_deg'])*math.pi/180
    pelvis=(32,43);shoulder=(33+round(5*math.sin(c)),32)
    elbow=(round((shoulder[0]+p['hand'][0])/2)-2,round((shoulder[1]+p['hand'][1])/2)-3)
    hand=tuple(p['hand']);head=(29+round(2*math.sin(c)),23)
    d.line([pelvis,shoulder,head],fill=(32,72,97,255),width=3)
    d.line([shoulder,elbow,hand],fill=(242,144,46,255),width=2)
    d.line([pelvis,(27,52),(23,57)],fill=(32,72,97,255),width=2)
    d.line([pelvis,(38,51),(40,57)],fill=(32,72,97,255),width=2)
    blade=math.radians(p['blade_deg']);tip=(round(hand[0]+19*math.cos(blade)),round(hand[1]+19*math.sin(blade)))
    d.line([hand,tip],fill=(59,122,207,255),width=2)
    for pt in (pelvis,shoulder,elbow,hand,head):d.ellipse((pt[0]-1,pt[1]-1,pt[0]+1,pt[1]+1),fill=(255,242,127,255))
    return im

def prepare(source:Path,out:Path):
    ref=check_source(source)
    plans=pose_plan();(out/'source').mkdir(parents=True,exist_ok=True)
    (out/'source'/'R26_POSE_BLUEPRINT_NOT_PIXELLAB_PAYLOAD.json').write_text(json.dumps({'original_SHA256':SOURCE_SHA,'status':'TECHNICAL_GUIDE_ONLY_NOT_NEW_ART','coordinate_units':'pixels on original A62 64px canvas; not API v3 native schema','poses':plans},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    frames=[ref]+[_stick_pose(p) for p in plans[1:]]
    names=paint_preview(frames,out/'previews',ghost=True)
    ledger={'source_SHA256':SOURCE_SHA,'pose_blueprint_count':len(plans),'actual_new_provider_frames':0,'pixelLab_invocation':'NOT_RUN','art_review':'NOT_AVAILABLE','technical_pose_guide_files':names,'status':'WAIT_FOR_REAL_PIXELLAB_PIXELS'}
    (out/'R26_PREPARE_MANIFEST.json').write_text(json.dumps(ledger,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    return ledger

def validate(frames,source):
    problems=[];notes=[];sha_list=[];bbox_list=[]
    for idx,(k,f) in enumerate(zip(KEYS,frames)):
        if f.size!=(64,64):problems.append(f'F{k:02d} wrong size {f.size}');continue
        if rgba_bbox(f) is None:problems.append(f'F{k:02d} empty');continue
        b=rgba_bbox(f);bbox_list.append(b)
        if b[0]==0 or b[1]==0 or b[2]==64 or b[3]==64:problems.append(f'F{k:02d} touches canvas border / clipped')
        n=rgb_coverage(f)
        if n<250 or n>1450:problems.append(f'F{k:02d} implausible nontransparent pixel count={n}')
        sha_list.append(sha(f.tobytes()))
        if idx>0:
            opaque_count=sum(1 for a in f.getchannel('A').tobytes() if a>0)
            if opaque_count:
                overlap=sum(1 for aa,bb in zip(f.getchannel('A').tobytes(),source.getchannel('A').tobytes()) if aa>0 and bb>0)
                if overlap<120:notes.append(f'F{k:02d} person location drifts a lot; confirm anchor')
    if not frames[0].tobytes()==source.tobytes():problems.append('F00 not exact approved A62 source')
    if len(set(sha_list))!=5:problems.append('Repeated/identical keyframes: no new distinct pose production')
    return {'technical_PNG_validation':'PASS' if not problems else 'FAIL','issues':problems,'warnings':notes,'source_sha256':SOURCE_SHA,'body_frame_RGBA_sha256':sha_list,'body_bounds':bbox_list,'five_keyframes_distinct':len(set(sha_list)),'human_ART_gate':'PENDING_VISUAL_REVIEW','real_Godot_runtime':'NOT_RUN','formal_FS_Battle':'NOT_RUN'}

def ingest(source:Path,frame_dir:Path,out:Path):
    ref=check_source(source)
    files=[frame_dir/f'F{k:02d}.png' for k in KEYS]
    for file in files:
        if not file.is_file():raise ValueError('MISSING_PIXEL_LAB_FRAME: '+file.name)
    frames=[Image.open(f).convert('RGBA') for f in files]
    report=validate(frames,ref)
    if report['technical_PNG_validation']=='FAIL':
        out.mkdir(parents=True,exist_ok=True)
        (out/'R26_TECHNICAL_REJECTED.json').write_text(json.dumps(report,indent=2)+'\n')
        raise ValueError('REJECTED: '+', '.join(report['issues']))
    receipts=frame_dir/'PIXELLAB_JOB_RECEIPT.json'
    if receipts.is_file():
        r=json.loads(receipts.read_text(encoding='utf-8'))
        if not r.get('provider_job_id') or not str(r.get('model','')).startswith('animate-with-'):
            raise ValueError('PIXELLAB_JOB_RECEIPT invalid provider job/model')
        report['provider_job_id']=str(r['provider_job_id'])
        report['provider_model']=str(r['model'])
        report['provider_claim']='PROVIDER_RECEIPT_ATTACHED_NOT_CRYPTOGRAPHICALLY_VERIFIED'
    else: report['provider_claim']='NOT_VERIFIED_NO_RECEIPT'
    report['preview_files']=paint_preview(frames,out)
    (out/'R26_TECHNICAL_QA.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    return report

def selftest(source:Path):
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        root=Path(d);src=check_source(source)
        # Must detect lack of real art instead of falsely producing a full sprite sheet.
        folder=root/'badframes';folder.mkdir()
        for k in KEYS:src.save(folder/f'F{k:02d}.png')
        try:ingest(source,folder,root/'bad_output')
        except ValueError as e:assert 'Repeated/identical keyframes' in str(e)
        else:raise AssertionError('five duplicate F00 frames incorrectly accepted')
        # F00 tamper is a second mandatory negative.
        wrong=src.copy();wrong.putpixel((30,30),(255,0,255,255));wrong.save(folder/'F00.png')
        try:ingest(source,folder,root/'bad_output2')
        except ValueError as e:assert 'F00 not exact approved' in str(e)
        else:raise AssertionError('tampered approved source accepted')
        # No surrogate/new image generation in `prepare`: count remains exactly zero.
        result=prepare(source,root/'prepared')
        assert result['actual_new_provider_frames']==0 and len(result['technical_pose_guide_files'])==4
        out=root/'prepared'/'previews'/'R26_5POSE_NATIVE_1X.png'
        assert Image.open(out).size==(320,64)
    return {'source_SHA':SOURCE_SHA,'negative_duplicate_frames':'REJECTED','negative_tampered_F00':'REJECTED','nonprovider_pose_blueprint':'PASS','actual_new_pixelLab_frames':0,'status':'OFFLINE_PREVIEW_GATE_UNIT_TEST_PASS_ART_NOT_RUN'}

def main():
    a=argparse.ArgumentParser();a.add_argument('mode',choices=['prepare','ingest','selftest']);a.add_argument('--source',type=Path,required=True);a.add_argument('--out',type=Path,required=True);a.add_argument('--frames',type=Path);args=a.parse_args()
    if args.mode=='selftest':q=selftest(args.source)
    elif args.mode=='prepare':q=prepare(args.source,args.out)
    else:
        if args.frames is None:raise ValueError('--frames folder required')
        q=ingest(args.source,args.frames,args.out)
    print(json.dumps(q,ensure_ascii=False,indent=2))
if __name__=='__main__': main()
